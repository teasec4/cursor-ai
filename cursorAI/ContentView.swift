import SwiftUI

struct ContentView: View {
    let dependencies: AppDependencies
    @State var viewModel: GrammarAssistantViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            header

            GrammarAssistantView(viewModel: viewModel)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("MVP status")
                    .font(.headline)

                Label("Clipboard reading is wired", systemImage: "checkmark.circle")
                Label("Floating overlay is wired", systemImage: "checkmark.circle")
                Label("Shortcut and replacement come next", systemImage: "clock")
            }
            .foregroundStyle(.secondary)
            .font(.callout)

            HStack {
                Button {
                    showOverlay()
                } label: {
                    Label("Show Overlay", systemImage: "rectangle.on.rectangle")
                }

                Button {
                    dependencies.overlay.hide()
                } label: {
                    Label("Hide", systemImage: "xmark.circle")
                }
            }
        }
        .padding(24)
        .frame(width: 460)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Cursor Assistant")
                .font(.largeTitle.weight(.semibold))

            Text("A small macOS assistant for grammar correction near the cursor.")
                .foregroundStyle(.secondary)
        }
    }

    private func showOverlay() {
        dependencies.overlay.show(
            content: AnyView(
                GrammarAssistantView(viewModel: viewModel)
                    .padding(16)
                    .frame(width: 420)
                    .frame(maxHeight: 360)
            )
        )
    }
}

#Preview {
    let dependencies = AppDependencies.preview()

    ContentView(
        dependencies: dependencies,
        viewModel: GrammarAssistantViewModel(dependencies: dependencies)
    )
}
