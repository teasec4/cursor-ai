import SwiftUI

@MainActor
final class AssistantController {
    let dependencies: AppDependencies
    let viewModel: GrammarAssistantViewModel

    private var isRunningShortcut = false

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        self.viewModel = GrammarAssistantViewModel(dependencies: dependencies)

        dependencies.shortcut.setHandler { [weak self] in
            self?.fixSelectedText()
        }
    }

    func start() {
        dependencies.shortcut.start()
    }

    func stop() {
        dependencies.shortcut.stop()
    }

    func fixClipboardText() {
        viewModel.reset()
        showOverlay()

        Task {
            await viewModel.correctClipboardText()
            dependencies.overlay.refreshFrame()
        }
    }

    func fixSelectedText() {
        guard !isRunningShortcut else {
            return
        }

        isRunningShortcut = true
        showOverlay()

        Task {
            defer {
                isRunningShortcut = false
            }

            await viewModel.correctSelectedText()
            viewModel.copyCorrectedText()
            dependencies.overlay.refreshFrame()
        }
    }

    private func showOverlay() {
        dependencies.overlay.show(
            content: AnyView(
                GrammarAssistantView(viewModel: viewModel, showsManualControls: false)
                    .padding(16)
                    .frame(width: 420)
                    .frame(maxHeight: 360)
            )
        )
    }
}
