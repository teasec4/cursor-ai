import Foundation

struct AppDependencies {
    let settings: AppSettings
    let clipboard: ClipboardServiceProtocol
    let selectionCopy: SelectionCopyServicing
    let overlay: OverlayControlling
    let shortcut: GlobalShortcutServicing
    let apiKeyStore: APIKeyStoring
    let deepSeek: DeepSeekClientProtocol

    static func live() -> AppDependencies {
        let settings = AppSettings()
        let apiKeyStore = APIKeyStore()

        return AppDependencies(
            settings: settings,
            clipboard: ClipboardService(),
            selectionCopy: SelectionCopyService(),
            overlay: OverlayController(settings: settings),
            shortcut: GlobalShortcutService(),
            apiKeyStore: apiKeyStore,
            deepSeek: DeepSeekClient(settings: settings, apiKeyStore: apiKeyStore)
        )
    }

    static func preview() -> AppDependencies {
        let settings = AppSettings()
        let apiKeyStore = APIKeyStore()

        return AppDependencies(
            settings: settings,
            clipboard: PreviewClipboardService(),
            selectionCopy: PreviewSelectionCopyService(),
            overlay: OverlayController(settings: settings),
            shortcut: GlobalShortcutService(),
            apiKeyStore: apiKeyStore,
            deepSeek: PreviewDeepSeekClient()
        )
    }
}
