import AppKit
import SwiftUI

@main
struct CursorAssistantApp: App {
    private let dependencies: AppDependencies
    @State private var controller: AssistantController

    init() {
        let dependencies = AppDependencies.live()
        self.dependencies = dependencies
        _controller = State(initialValue: AssistantController(dependencies: dependencies))
    }

    var body: some Scene {
        WindowGroup("Cursor Assistant", id: "main") {
            ContentView(controller: controller)
                .onAppear {
                    controller.start()
                }
        }
        .windowResizability(.contentSize)

        MenuBarExtra("Cursor Assistant", systemImage: "text.badge.checkmark") {
            MenuBarAssistantView(controller: controller)
        }

        WindowGroup("How it works", id: "help") {
            HelpView()
        }
        .windowResizability(.contentSize)

        Settings {
            SettingsView(settings: dependencies.settings)
        }
    }
}

private struct MenuBarAssistantView: View {
    @Environment(\.openWindow) private var openWindow

    let controller: AssistantController

    var body: some View {
        Button {
            openWindow(id: "main")
            NSApp.activate()
        } label: {
            Label("Open", systemImage: "macwindow")
        }

        Divider()

        Button {
            controller.fixSelectedText()
        } label: {
            Label("Fix Selection", systemImage: "text.cursor")
        }
        .keyboardShortcut(" ", modifiers: [.control, .option])

        Button {
            controller.fixClipboardText()
        } label: {
            Label("Fix Clipboard", systemImage: "doc.on.clipboard")
        }

        Divider()

        SettingsLink {
            Label("Settings", systemImage: "gearshape")
        }

        Button {
            openWindow(id: "help")
            NSApp.activate()
        } label: {
            Label("Help", systemImage: "questionmark.circle")
        }

        Button {
            NSApp.terminate(nil)
        } label: {
            Label("Quit", systemImage: "power")
        }
        .keyboardShortcut("q")
    }
}
