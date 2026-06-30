import SwiftUI

struct GrammarAssistantView: View {
    @Bindable var viewModel: GrammarAssistantViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            stateContent

            HStack(spacing: 10) {
                Button {
                    viewModel.loadClipboardText()
                } label: {
                    Label("Load Clipboard", systemImage: "doc.on.clipboard")
                }

                Button {
                    Task {
                        await viewModel.correctLoadedText()
                    }
                } label: {
                    Label("Correct", systemImage: "text.badge.checkmark")
                }
                .disabled(!canCorrect)

                Spacer()

                Button {
                    viewModel.reset()
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                }
                .disabled(viewModel.state == .idle)
            }
        }
    }

    @ViewBuilder
    private var stateContent: some View {
        switch viewModel.state {
        case .idle:
            Text("Copy text, then load it here. DeepSeek wiring starts in a later phase.")
                .foregroundStyle(.secondary)
        case let .loadedClipboard(text):
            TextPreview(title: "Clipboard text", text: text)
        case let .correcting(text):
            HStack(spacing: 10) {
                ProgressView()
                    .controlSize(.small)
                Text("Preparing correction for \(text.count) characters...")
                    .foregroundStyle(.secondary)
            }
        case let .result(result):
            TextPreview(title: "Corrected", text: result.correctedText, maxHeight: 220)
        case let .failed(message):
            Label(message, systemImage: "exclamationmark.triangle")
                .foregroundStyle(.orange)
        }
    }

    private var canCorrect: Bool {
        if case .loadedClipboard = viewModel.state {
            return true
        }

        return false
    }
}

private struct TextPreview: View {
    let title: String
    let text: String
    var maxHeight: CGFloat = 150

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)

            ScrollView {
                Text(text)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
            }
            .frame(maxHeight: maxHeight)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
        }
    }
}

#Preview {
    GrammarAssistantView(viewModel: GrammarAssistantViewModel(dependencies: .preview()))
        .padding()
        .frame(width: 460)
}
