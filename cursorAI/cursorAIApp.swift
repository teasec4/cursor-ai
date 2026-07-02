import AppKit
import SwiftData
import SwiftUI

@main
struct CursorAssistantApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    private let dependencies: AppDependencies
    @State private var controller: AssistantController

    init() {
        let dependencies = AppDependencies.live()
        let controller = AssistantController(dependencies: dependencies)
        controller.start()

        self.dependencies = dependencies
        _controller = State(initialValue: controller)
    }

    var body: some Scene {
        Window("Cursor Assistant", id: "main") {
            HelpView()
        }
        .windowResizability(.contentSize)

        Settings {
            SettingsView(
                viewModel: SettingsViewModel(
                    settings: dependencies.settings,
                    modelStore: dependencies.modelStore,
                    apiKeyStore: dependencies.apiKeyStore
                )
            )
        }
        .modelContainer(dependencies.modelContainer)
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
