import AppKit
import SwiftUI

struct HelpView: View {
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("How it works")
                    .font(.title2.weight(.semibold))

                Spacer()

                ShortcutKeyComboView()
            }

            VStack(alignment: .leading, spacing: 12) {
                HelpRow(
                    icon: "selection.pin.in.out",
                    title: "Select text",
                    text: "Highlight text in any app."
                )

                HelpRow(
                    icon: "keyboard",
                    title: "Run shortcut",
                    customContent: AnyView(ShortcutKeyComboView())
                )

                HelpRow(
                    icon: "text.badge.checkmark",
                    title: "Review fix",
                    text: "The assistant copies the selection, corrects it, and shows the result near your cursor."
                )

                HelpRow(
                    icon: "command",
                    title: "Paste manually",
                    text: "The corrected text is already in your clipboard. Press Command + V to insert it."
                )

                HelpRow(
                    icon: "gearshape",
                    title: "Adjust settings",
                    text: "Open Settings to add an AI model, API key, and Accessibility access."
                )
            }

            HStack(spacing: 10) {
                Button {
                    openSettings()
                } label: {
                    Label("Settings", systemImage: "gearshape")
                }
                .buttonStyle(.borderedProminent)

                Button {
                    NSApp.terminate(nil)
                } label: {
                    Label("Quit", systemImage: "power")
                }

                Spacer()
            }
            .padding(.top, 4)
        }
        .padding(22)
        .frame(width: 460)
        .background(MainWindowConfigurator())
    }
}

private struct HelpRow: View {
    let icon: String
    let title: String
    var text: String?
    var customContent: AnyView?

    init(icon: String, title: String, text: String) {
        self.icon = icon
        self.title = title
        self.text = text
        self.customContent = nil
    }

    init(icon: String, title: String, customContent: AnyView) {
        self.icon = icon
        self.title = title
        self.text = nil
        self.customContent = customContent
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .frame(width: 22)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)

                if let text {
                    Text(text)
                        .foregroundStyle(.secondary)
                }

                if let customContent {
                    customContent
                }
            }
            .font(.callout)
        }
    }
}

private struct ShortcutKeyComboView: View {
    private let keys = [
        ShortcutKey(symbol: "control", title: "Control"),
        ShortcutKey(symbol: "option", title: "Option"),
        ShortcutKey(symbol: nil, title: "Space")
    ]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(Array(keys.enumerated()), id: \.offset) { index, key in
                if index > 0 {
                    Text("+")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                ShortcutKeyView(key: key)
            }
        }
        .accessibilityLabel("Control plus Option plus Space")
    }
}

private struct ShortcutKey: Equatable {
    let symbol: String?
    let title: String
}

private struct ShortcutKeyView: View {
    let key: ShortcutKey

    var body: some View {
        HStack(spacing: 4) {
            if let symbol = key.symbol {
                Image(systemName: symbol)
                    .font(.caption.weight(.semibold))
            }

            Text(key.title)
                .font(.caption.weight(.semibold))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
        .overlay {
            RoundedRectangle(cornerRadius: 6)
                .stroke(.quaternary, lineWidth: 1)
        }
    }
}

#Preview {
    HelpView()
}
