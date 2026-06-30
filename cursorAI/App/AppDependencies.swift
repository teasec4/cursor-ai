import Foundation

struct AppDependencies {
    let settings: AppSettings
    let clipboard: ClipboardServiceProtocol
    let overlay: OverlayControlling
    let shortcut: GlobalShortcutServicing
    let textReplacement: TextReplacementServicing
    let apiKeyStore: APIKeyStoring
    let deepSeek: DeepSeekClientProtocol

    static func live() -> AppDependencies {
        let settings = AppSettings()
        let apiKeyStore = APIKeyStore()

        return AppDependencies(
            settings: settings,
            clipboard: ClipboardService(),
            overlay: OverlayController(settings: settings),
            shortcut: GlobalShortcutService(),
            textReplacement: TextReplacementService(),
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
            overlay: OverlayController(settings: settings),
            shortcut: GlobalShortcutService(),
            textReplacement: TextReplacementService(),
            apiKeyStore: apiKeyStore,
            deepSeek: PreviewDeepSeekClient()
        )
    }
}
