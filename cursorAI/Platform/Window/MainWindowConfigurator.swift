import AppKit
import SwiftUI

struct MainWindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()

        Task { @MainActor in
            await Task.yield()
            configure(window: view.window)
        }

        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        Task { @MainActor in
            await Task.yield()
            configure(window: nsView.window)
        }
    }

    private func configure(window: NSWindow?) {
        window?.standardWindowButton(.zoomButton)?.isHidden = true
    }
}
