import SwiftUI

struct SettingsView: View {
    @Bindable var viewModel: SettingsViewModel
    @State private var isShowingAdvanced = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                correctionSection

                Divider()

                modelsSection

                Divider()

                accessibilitySection

                Divider()

                advancedSection
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: 560, height: 640)
        .onAppear {
            viewModel.onAppear()
        }
    }

    private var correctionSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Correction")
                    .font(.title2.weight(.semibold))

                Text("Choose how assertive the assistant should be.")
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Character")
                    .font(.headline)

                Picker("Character", selection: personalityBinding) {
                    ForEach(CorrectionPersonality.allCases) { personality in
                        Text(personality.title).tag(personality)
                    }
                }
                .pickerStyle(.segmented)

                Text(viewModel.settings.correctionPersonality.subtitle)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Correction level")
                    .font(.headline)

                Picker("Correction level", selection: strengthBinding) {
                    ForEach(CorrectionStrength.allCases) { strength in
                        Text(strength.title).tag(strength)
                    }
                }
                .pickerStyle(.segmented)

                Text(viewModel.settings.correctionStrength.subtitle)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var modelsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("AI Models")
                    .font(.headline)

                Spacer()

                Button {
                    viewModel.createNewModelDraft()
                } label: {
                    Label("New", systemImage: "plus")
                }

                Button {
                    viewModel.deleteCurrentModel()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                .disabled(viewModel.isEditingNewModel && !viewModel.hasUnsavedChanges)
            }

            if viewModel.models.isEmpty && viewModel.isEditingNewModel && !viewModel.hasUnsavedChanges {
                Text("Add an OpenAI-compatible model before using correction.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            if !viewModel.models.isEmpty {
                Picker("Selected model", selection: selectedModelIDBinding) {
                    if viewModel.isEditingNewModel {
                        Text("New draft").tag("")
                    }

                    ForEach(viewModel.models) { model in
                        Text(model.name).tag(model.id)
                    }
                }
                .pickerStyle(.menu)
            }

            if viewModel.isEditingModelDetails {
                modelEditor
                editorActions
            } else if !viewModel.isEditingNewModel {
                modelSummary
            }

            statusMessage
        }
    }

    private var modelSummary: some View {
        VStack(alignment: .leading, spacing: 10) {
            LabeledContent("Endpoint", value: viewModel.draftEndpoint)
            LabeledContent("Model", value: viewModel.draftModelName)

            LabeledContent {
                Label(
                    viewModel.selectedModelHasAPIKey ? "Saved in Keychain" : "Missing",
                    systemImage: viewModel.selectedModelHasAPIKey ? "checkmark.circle" : "exclamationmark.triangle"
                )
                .foregroundStyle(viewModel.selectedModelHasAPIKey ? .green : .orange)
            } label: {
                Text("API key")
            }

            HStack(spacing: 10) {
                Button {
                    viewModel.beginEditingModel()
                } label: {
                    Label("Edit", systemImage: "pencil")
                }

                Spacer()
            }
        }
        .font(.callout)
        .padding(12)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }

    private var editorActions: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Button {
                    viewModel.saveModel()
                } label: {
                    Label(viewModel.saveButtonTitle, systemImage: "square.and.arrow.down")
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canSaveModel)

                Button("Cancel") {
                    viewModel.cancelEditingModel()
                }

                if viewModel.hasUnsavedChanges {
                    Label("Unsaved changes", systemImage: "circle.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
        }
    }

    private var modelEditor: some View {
        Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 10) {
            GridRow {
                Text("Name")
                    .foregroundStyle(.secondary)
                TextField("Personal OpenAI", text: modelNameBinding)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: .infinity)
            }

            GridRow {
                Text("Endpoint")
                    .foregroundStyle(.secondary)
                TextField("https://api.openai.com/v1/chat/completions", text: endpointBinding)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: .infinity)
            }

            GridRow {
                Text("Model")
                    .foregroundStyle(.secondary)
                TextField("gpt-4.1-mini", text: apiModelNameBinding)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: .infinity)
            }

            GridRow {
                Text("API key")
                    .foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 4) {
                    SecureField(apiKeyPlaceholder, text: apiKeyBinding)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: .infinity)

                    Text(viewModel.apiKeyHelpText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .font(.callout)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var statusMessage: some View {
        if let message = viewModel.lastMessage {
            Label(
                message,
                systemImage: viewModel.isShowingError ? "exclamationmark.triangle" : "checkmark.circle"
            )
            .font(.callout)
            .foregroundStyle(viewModel.isShowingError ? .orange : .green)
        }
    }

    private var apiKeyPlaceholder: String {
        if viewModel.isEditingNewModel {
            return "Paste API key"
        }

        return viewModel.selectedModelHasAPIKey ? "Leave empty to keep saved key" : "Paste API key"
    }

    private var accessibilitySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(
                    viewModel.isAccessibilityTrusted ? "Accessibility enabled" : "Accessibility needed",
                    systemImage: viewModel.isAccessibilityTrusted ? "checkmark.circle" : "exclamationmark.triangle"
                )
                .foregroundStyle(viewModel.isAccessibilityTrusted ? .green : .orange)

                Spacer()
            }

            Text("Required to copy selected text with the global shortcut.")
                .font(.callout)
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                Button {
                    viewModel.requestAccessibilityPermission()
                } label: {
                    Label("Request", systemImage: "hand.raised")
                }

                Button {
                    viewModel.openAccessibilitySettings()
                } label: {
                    Label("Open Settings", systemImage: "gearshape")
                }
            }
        }
    }

    private var advancedSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Button {
                withAnimation(.easeInOut(duration: 0.12)) {
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
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isShowingAdvanced {
                Stepper(
                    "Auto-hide: \(Int(viewModel.settings.overlayAutoHideDelay))s",
                    value: overlayDelayBinding,
                    in: 3...30,
                    step: 1
                )
                .transition(.opacity)
            }
        }
    }

    private var personalityBinding: Binding<CorrectionPersonality> {
        Binding(
            get: { viewModel.settings.correctionPersonality },
            set: { viewModel.settings.correctionPersonality = $0 }
        )
    }

    private var strengthBinding: Binding<CorrectionStrength> {
        Binding(
            get: { viewModel.settings.correctionStrength },
            set: { viewModel.settings.correctionStrength = $0 }
        )
    }

    private var overlayDelayBinding: Binding<TimeInterval> {
        Binding(
            get: { viewModel.settings.overlayAutoHideDelay },
            set: { viewModel.settings.overlayAutoHideDelay = $0 }
        )
    }

    private var selectedModelIDBinding: Binding<String> {
        Binding(
            get: { viewModel.selectedModelID },
            set: { viewModel.selectModel(id: $0) }
        )
    }

    private var modelNameBinding: Binding<String> {
        Binding(
            get: { viewModel.draftName },
            set: { viewModel.updateDraftName($0) }
        )
    }

    private var endpointBinding: Binding<String> {
        Binding(
            get: { viewModel.draftEndpoint },
            set: { viewModel.updateDraftEndpoint($0) }
        )
    }

    private var apiModelNameBinding: Binding<String> {
        Binding(
            get: { viewModel.draftModelName },
            set: { viewModel.updateDraftModelName($0) }
        )
    }

    private var apiKeyBinding: Binding<String> {
        Binding(
            get: { viewModel.draftAPIKey },
            set: { viewModel.updateDraftAPIKey($0) }
        )
    }
}
