import Foundation

protocol GlobalShortcutServicing {
    func start()
    func stop()
}

final class GlobalShortcutService: GlobalShortcutServicing {
    func start() {}
    func stop() {}
}
