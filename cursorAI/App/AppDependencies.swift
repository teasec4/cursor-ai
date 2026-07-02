import Foundation
import SwiftData

struct AppDependencies {
    let settings: AppSettings
    let modelContainer: ModelContainer
    let modelStore: AIModelStoring
    let clipboard: ClipboardServiceProtocol
    let selectionCopy: SelectionCopyServicing
    let overlay: OverlayControlling
    let shortcut: GlobalShortcutServicing
    let apiKeyStore: APIKeyStoring
    let textCorrectionClient: AITextCorrectionClientProtocol

    static func live() -> AppDependencies {
        let settings = AppSettings()
        let apiKeyStore = APIKeyStore()
        let modelContainer = makeModelContainer(isStoredInMemoryOnly: false)
        let modelStore = AIModelStore(
            context: ModelContext(modelContainer),
            settings: settings
        )
        try? modelStore.reload()

        return AppDependencies(
            settings: settings,
            modelContainer: modelContainer,
            modelStore: modelStore,
            clipboard: ClipboardService(),
            selectionCopy: SelectionCopyService(),
            overlay: OverlayController(settings: settings),
            shortcut: GlobalShortcutService(),
            apiKeyStore: apiKeyStore,
            textCorrectionClient: OpenAICompatibleClient(settings: settings, apiKeyStore: apiKeyStore)
        )
    }

    static func preview() -> AppDependencies {
        let settings = AppSettings()
        let apiKeyStore = APIKeyStore()
        let modelContainer = makeModelContainer(isStoredInMemoryOnly: true)
        let modelStore = AIModelStore(
            context: ModelContext(modelContainer),
            settings: settings
        )

        return AppDependencies(
            settings: settings,
            modelContainer: modelContainer,
            modelStore: modelStore,
            clipboard: PreviewClipboardService(),
            selectionCopy: PreviewSelectionCopyService(),
            overlay: OverlayController(settings: settings),
            shortcut: GlobalShortcutService(),
            apiKeyStore: apiKeyStore,
            textCorrectionClient: PreviewAITextCorrectionClient()
        )
    }

    private static func makeModelContainer(isStoredInMemoryOnly: Bool) -> ModelContainer {
        do {
            let configuration = ModelConfiguration(isStoredInMemoryOnly: isStoredInMemoryOnly)
            return try ModelContainer(for: StoredAIModel.self, configurations: configuration)
        } catch {
            fatalError("Could not create SwiftData model container: \(error)")
        }
    }
}
