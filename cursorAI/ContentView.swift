import SwiftUI

struct ContentView: View {
    @Environment(\.openSettings) private var openSettings

    let controller: AssistantController
    @State private var isShowingHelp = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            topBar
            actionBar
        }
        .padding(18)
        .frame(width: 360)
        .sheet(isPresented: $isShowingHelp) {
            HelpView()
        }
    }

    private var topBar: some View {
        HStack(spacing: 10) {
            Button {
                controller.fixClipboardText()
            } label: {
                Label("Fix clipboard", systemImage: "text.badge.checkmark")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Spacer()

            Button {
                isShowingHelp = true
            } label: {
                Image(systemName: "questionmark.circle")
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .help("How to use")

            Button {
                openSettings()
            } label: {
                Image(systemName: "gearshape")
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .help("Settings")
        }
    }

    private var actionBar: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Label(controller.dependencies.settings.correctionPersonality.title, systemImage: "person.text.rectangle")
                    Label(controller.dependencies.settings.correctionStrength.title, systemImage: "slider.horizontal.3")
                }
                .lineLimit(1)

                Text("⌃⌥Space fixes selection")
                    .font(.callout.monospaced())
                    .foregroundStyle(.secondary)
            }
            .font(.callout)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 2)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    let dependencies = AppDependencies.preview()
    let controller = AssistantController(dependencies: dependencies)

    ContentView(controller: controller)
}
