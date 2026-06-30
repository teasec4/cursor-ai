import AppKit
import SwiftUI

@MainActor
protocol OverlayControlling {
    func show(content: AnyView)
    func refreshFrame()
    func hide()
}

@MainActor
final class OverlayController: OverlayControlling {
    private let settings: AppSettings
    private var panel: FloatingOverlayPanel?
    private var autoHideTask: Task<Void, Never>?

    init(settings: AppSettings) {
        self.settings = settings
    }

    func show(content: AnyView) {
        autoHideTask?.cancel()

        let panel = panel ?? makePanel()
        let rootView = OverlayContainerView(content: content) { [weak self] in
            self?.hide()
        }

        panel.contentView = NSHostingView(rootView: rootView)
        panel.setFrame(positionedFrame(for: panel), display: true)
        panel.alphaValue = 0
        panel.orderFrontRegardless()

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.14
            panel.animator().alphaValue = 1
        }

        self.panel = panel
        scheduleAutoHide()
    }

    func refreshFrame() {
        guard let panel else {
            return
        }

        Task { @MainActor in
            await Task.yield()
            panel.setFrame(positionedFrame(for: panel), display: true, animate: true)
        }
    }

    func hide() {
        autoHideTask?.cancel()
        autoHideTask = nil

        guard let panel else {
            return
        }

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.12
            panel.animator().alphaValue = 0
        } completionHandler: {
            Task { @MainActor in
                panel.orderOut(nil)
            }
        }
    }

    private func makePanel() -> FloatingOverlayPanel {
        let panel = FloatingOverlayPanel(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 320),
            styleMask: [.nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        panel.isReleasedWhenClosed = false
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
        panel.hidesOnDeactivate = false
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isMovableByWindowBackground = true

        return panel
    }

    private func positionedFrame(for panel: NSPanel) -> NSRect {
        let fittingSize = panel.contentView?.fittingSize ?? NSSize(width: 420, height: 320)
        let size = NSSize(
            width: min(max(fittingSize.width, 420), 520),
            height: min(max(fittingSize.height, 180), 420)
        )
        let cursorLocation = NSEvent.mouseLocation
        let screen = NSScreen.screens.first { $0.visibleFrame.contains(cursorLocation) } ?? NSScreen.main
        let visibleFrame = screen?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1200, height: 800)

        let margin: CGFloat = 12
        let preferredOrigin = NSPoint(
            x: cursorLocation.x + 14,
            y: cursorLocation.y - size.height - 14
        )

        let clampedX = min(
            max(preferredOrigin.x, visibleFrame.minX + margin),
            visibleFrame.maxX - size.width - margin
        )
        let clampedY = min(
            max(preferredOrigin.y, visibleFrame.minY + margin),
            visibleFrame.maxY - size.height - margin
        )

        return NSRect(origin: NSPoint(x: clampedX, y: clampedY), size: size)
    }

    private func scheduleAutoHide() {
        autoHideTask = Task { [weak self] in
            guard let self else {
                return
            }

            let delay = UInt64(settings.overlayAutoHideDelay * 1_000_000_000)
            try? await Task.sleep(nanoseconds: delay)

            if !Task.isCancelled {
                hide()
            }
        }
    }
}
