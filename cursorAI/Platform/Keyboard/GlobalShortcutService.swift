import Carbon
import Foundation

protocol GlobalShortcutServicing {
    func setHandler(_ handler: @escaping @MainActor () -> Void)
    func start()
    func stop()
}

final class GlobalShortcutService: GlobalShortcutServicing {
    private let hotKeyID = EventHotKeyID(signature: OSType("CRAI"), id: 1)
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?
    private var handler: (@MainActor () -> Void)?

    func setHandler(_ handler: @escaping @MainActor () -> Void) {
        self.handler = handler
    }

    func start() {
        guard hotKeyRef == nil else {
            return
        }

        installEventHandlerIfNeeded()

        let status = RegisterEventHotKey(
            UInt32(kVK_Space),
            UInt32(controlKey | optionKey),
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        if status != noErr {
            hotKeyRef = nil
        }
    }

    func stop() {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }

        if let eventHandlerRef {
            RemoveEventHandler(eventHandlerRef)
            self.eventHandlerRef = nil
        }
    }

    private func installEventHandlerIfNeeded() {
        guard eventHandlerRef == nil else {
            return
        }

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let selfPointer = Unmanaged.passUnretained(self).toOpaque()
        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, event, userData in
                guard let event, let userData else {
                    return noErr
                }

                var hotKeyID = EventHotKeyID()
                let status = GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )

                guard status == noErr, hotKeyID.signature == OSType("CRAI"), hotKeyID.id == 1 else {
                    return noErr
                }

                let service = Unmanaged<GlobalShortcutService>
                    .fromOpaque(userData)
                    .takeUnretainedValue()

                Task { @MainActor in
                    service.handler?()
                }

                return noErr
            },
            1,
            &eventType,
            selfPointer,
            &eventHandlerRef
        )
    }
}

private func OSType(_ string: String) -> OSType {
    string.utf8.reduce(0) { result, character in
        (result << 8) + OSType(character)
    }
}
