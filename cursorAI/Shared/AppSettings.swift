import Foundation

@Observable
final class AppSettings {
    var deepSeekEndpoint = URL(string: "https://api.deepseek.com/chat/completions")!
    var deepSeekModel = "deepseek-chat"
    var overlayAutoHideDelay: TimeInterval = 12
}
