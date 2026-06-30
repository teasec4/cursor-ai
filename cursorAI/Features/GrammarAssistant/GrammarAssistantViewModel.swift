import Foundation

@Observable
@MainActor
final class GrammarAssistantViewModel {
    private let dependencies: AppDependencies

    var state: GrammarAssistantState = .idle

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
    }

    func loadClipboardText() {
        do {
            let text = try dependencies.clipboard.readText()
            state = .loadedClipboard(text)
        } catch {
            state = .failed(userMessage(for: error))
        }
    }

    func correctLoadedText() async {
        guard case let .loadedClipboard(text) = state else {
            state = .failed(AppError.clipboardIsEmpty.localizedDescription)
            return
        }

        state = .correcting(text)

        do {
            let result = try await dependencies.deepSeek.correctGrammar(text: text)
            state = .result(result)
        } catch is CancellationError {
            state = .loadedClipboard(text)
        } catch {
            state = .failed(userMessage(for: error))
        }
    }

    func reset() {
        state = .idle
    }

    private func userMessage(for error: Error) -> String {
        if let appError = error as? AppError {
            return appError.localizedDescription
        }

        return "Something went wrong."
    }
}
