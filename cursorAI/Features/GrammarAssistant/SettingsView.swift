import SwiftUI

struct SettingsView: View {
    @Bindable var settings: AppSettings
    @State private var isShowingAdvanced = false
    @State private var isAccessibilityTrusted = AccessibilityPermissionService.isTrusted

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Correction")
                    .font(.title2.weight(.semibold))

                Text("Choose how assertive the assistant should be.")
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Character")
                    .font(.headline)

                Picker("Character", selection: $settings.correctionPersonality) {
                    ForEach(CorrectionPersonality.allCases) { personality in
                        Text(personality.title).tag(personality)
                    }
                }
                .pickerStyle(.segmented)

                Text(settings.correctionPersonality.subtitle)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Correction level")
                    .font(.headline)

                Picker("Correction level", selection: $settings.correctionStrength) {
                    ForEach(CorrectionStrength.allCases) { strength in
                        Text(strength.title).tag(strength)
                    }
                }
                .pickerStyle(.segmented)

                Text(settings.correctionStrength.subtitle)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            Divider()

            accessibilitySection

            Divider()

            advancedSection

            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(width: 520, height: 600)
        .onAppear {
            refreshAccessibilityStatus()
        }
    }

    private var accessibilitySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(
                    isAccessibilityTrusted ? "Accessibility enabled" : "Accessibility needed",
                    systemImage: isAccessibilityTrusted ? "checkmark.circle" : "exclamationmark.triangle"
                )
                .foregroundStyle(isAccessibilityTrusted ? .green : .orange)

                Spacer()
            }

            Text("Required to copy selected text with the global shortcut.")
                .font(.callout)
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                Button {
                    AccessibilityPermissionService.requestPermission()
                    refreshAccessibilityStatus()
                } label: {
                    Label("Request", systemImage: "hand.raised")
                }

                Button {
                    AccessibilityPermissionService.openSystemSettings()
                } label: {
                    Label("Open Settings", systemImage: "gearshape")
                }
            }
        }
    }

    private var advancedSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Button {
                withAnimation(.snappy(duration: 0.18)) {
                    isShowingAdvanced.toggle()
                }
            } label: {
                HStack {
                    Text("Advanced")
                        .font(.headline)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isShowingAdvanced ? 90 : 0))
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            if isShowingAdvanced {
                VStack(alignment: .leading, spacing: 16) {
                    providerSettings

                    Divider()

                    Stepper("Auto-hide: \(Int(settings.overlayAutoHideDelay))s", value: $settings.overlayAutoHideDelay, in: 3...30, step: 1)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private var providerSettings: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("AI Provider")
                    .font(.headline)

                Spacer()

                Button {
                    settings.addCustomProvider()
                } label: {
                    Label("Add", systemImage: "plus")
                }

                Button {
                    settings.removeSelectedCustomProvider()
                } label: {
                    Image(systemName: "trash")
                }
                .disabled(settings.selectedProvider.isBuiltIn)
                .help("Remove custom provider")
            }

            Picker("Provider", selection: $settings.selectedProviderID) {
                ForEach(settings.providers) { provider in
                    Text(provider.name).tag(provider.id)
                }
            }

            TextField("Name", text: providerNameBinding)
                .disabled(settings.selectedProvider.isBuiltIn)

            TextField("Endpoint", text: endpointBinding)

            TextField("Model", text: providerModelBinding)

            Text("Providers must use an OpenAI-compatible chat completions API.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }

    private var providerNameBinding: Binding<String> {
        Binding(
            get: { settings.selectedProvider.name },
            set: { value in
                settings.updateSelectedProvider { provider in
                    provider.name = value
                }
            }
        )
    }

    private var endpointBinding: Binding<String> {
        Binding(
            get: { settings.selectedProvider.endpoint.absoluteString },
            set: { value in
                if let url = URL(string: value) {
                    settings.updateSelectedProvider { provider in
                        provider.endpoint = url
                    }
                }
            }
        )
    }

    private var providerModelBinding: Binding<String> {
        Binding(
            get: { settings.selectedProvider.model },
            set: { value in
                settings.updateSelectedProvider { provider in
                    provider.model = value
                }
            }
        )
    }

    private func refreshAccessibilityStatus() {
        isAccessibilityTrusted = AccessibilityPermissionService.isTrusted
    }
}
