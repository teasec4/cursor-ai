import SwiftUI

struct HelpView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("How it works")
                    .font(.title2.weight(.semibold))

                Spacer()

                Text("⌃⌥Space")
                    .font(.callout.monospaced())
                    .foregroundStyle(.secondary)
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
                    text: "Press Control + Option + Space."
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
            }
        }
        .padding(22)
        .frame(width: 420)
    }
}

private struct HelpRow: View {
    let icon: String
    let title: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .frame(width: 22)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)

                Text(text)
                    .foregroundStyle(.secondary)
            }
            .font(.callout)
        }
    }
}

#Preview {
    HelpView()
}
