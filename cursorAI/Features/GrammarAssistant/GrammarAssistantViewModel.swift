import Foundation

@Observable
@MainActor
final class GrammarAssistantViewModel {
    private let dependencies: AppDependencies

    var state: GrammarAssistantState = .idle
    var lastMessage: String?
    private var lastResult: GrammarCorrectionResult?

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
    }

    func loadClipboardText() {
        do {
            let text = try dependencies.clipboard.readText()
            state = .loadedClipboard(text)
            lastMessage = nil
        } catch {
            state = .failed(userMessage(for: error))
        }
    }

    func correctClipboardText() async {
        loadClipboardText()

        guard case .loadedClipboard = state else {
            return
        }

        await correctLoadedText()
    }

    func correctSelectedText() async {
        do {
            let text = try await dependencies.selectionCopy.copySelectedText()

            if let lastResult, lastResult.originalText == text {
                state = .result(lastResult)
                dependencies.clipboard.writeText(lastResult.correctedText)
                lastMessage = "Copied previous fix"
                return
            }

            state = .loadedClipboard(text)
            lastMessage = nil
        } catch {
            if let lastResult {
                state = .result(lastResult)
                dependencies.clipboard.writeText(lastResult.correctedText)
                lastMessage = "Kept previous fix"
            } else {
                state = .failed(userMessage(for: error))
            }
            return
        }

        await correctLoadedText()
    }

    func correctLoadedText() async {
        guard case let .loadedClipboard(text) = state else {
            state = .failed(AppError.clipboardIsEmpty.localizedDescription)
            return
        }

        state = .correcting(text)

        do {
            let result = try await dependencies.deepSeek.correctGrammar(text: text)
            lastResult = result
            state = .result(result)
            lastMessage = nil
        } catch is CancellationError {
            state = .loadedClipboard(text)
        } catch {
            state = .failed(userMessage(for: error))
        }
    }

    func copyCorrectedText() {
        guard case let .result(result) = state else {
            return
        }

        dependencies.clipboard.writeText(result.correctedText)
        lastMessage = "Copied"
    }

    func reset() {
        state = .idle
        lastMessage = nil
    }

    private func userMessage(for error: Error) -> String {
        if let appError = error as? AppError {
            return appError.localizedDescription
        }

        return "Something went wrong."
    }
}
