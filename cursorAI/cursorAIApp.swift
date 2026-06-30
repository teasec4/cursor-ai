import SwiftUI

@main
struct CursorAssistantApp: App {
    private let dependencies = AppDependencies.live()

    var body: some Scene {
        WindowGroup {
            ContentView(
                dependencies: dependencies,
                viewModel: GrammarAssistantViewModel(dependencies: dependencies)
            )
        }
        .windowResizability(.contentSize)

        Settings {
            SettingsView(settings: dependencies.settings)
        }
    }
}
