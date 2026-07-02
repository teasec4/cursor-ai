import Foundation

@Observable
@MainActor
final class SettingsViewModel {
    let settings: AppSettings

    private let modelStore: AIModelStoring
    private let apiKeyStore: APIKeyStoring

    var editingModelID: String?
    var draftName = ""
    var draftEndpoint = "https://api.openai.com/v1/chat/completions"
    var draftModelName = ""
    var draftAPIKey = ""
    var isEditingModelDetails = false
    var selectedModelHasAPIKey = false
    var hasUnsavedChanges = false
    var lastMessage: String?
    var isShowingError = false
    var isAccessibilityTrusted = AccessibilityPermissionService.isTrusted

    init(
        settings: AppSettings,
        modelStore: AIModelStoring,
        apiKeyStore: APIKeyStoring
    ) {
        self.settings = settings
        self.modelStore = modelStore
        self.apiKeyStore = apiKeyStore
    }

    var models: [AIModelConfiguration] {
        settings.aiModels
    }

    var selectedModelID: String {
        editingModelID ?? ""
    }

    var isEditingNewModel: Bool {
        editingModelID == nil
    }

    var canSaveModel: Bool {
        isEditingModelDetails &&
        draftName.trimmed.isEmpty == false &&
        draftEndpointURL != nil &&
        draftModelName.trimmed.isEmpty == false &&
        hasAPIKeyForSave &&
        (isEditingNewModel || hasUnsavedChanges)
    }

    var apiKeyHelpText: String {
        if isEditingNewModel {
            return "Required. Stored in Keychain after Save."
        }

        if selectedModelHasAPIKey {
            return "Leave empty to keep the saved key. Paste a new key only to replace it."
        }

        return "Required for this model. Stored in Keychain after Save."
    }

    var saveButtonTitle: String {
        isEditingNewModel ? "Save Model" : "Save Changes"
    }

    func onAppear() {
        reloadModels()
        refreshAccessibilityStatus()
    }

    func reloadModels() {
        do {
            try modelStore.reload()

            if let selected = settings.selectedAIModel {
                loadDraft(from: selected, showsMessage: false)
            } else {
                createNewModelDraft(showsMessage: false)
            }
        } catch {
            showError(error)
        }
    }

    func createNewModelDraft(showsMessage: Bool = true) {
        guard !hasUnsavedChanges || !showsMessage else {
            showError("Save or cancel the current edit first.")
            return
        }

        editingModelID = nil
        draftName = ""
        draftEndpoint = "https://api.openai.com/v1/chat/completions"
        draftModelName = ""
        draftAPIKey = ""
        isEditingModelDetails = true
        selectedModelHasAPIKey = false
        hasUnsavedChanges = false

        if showsMessage {
            showInfo("New model draft created.")
        }
    }

    func beginEditingModel() {
        isEditingModelDetails = true
        draftAPIKey = ""
        lastMessage = nil
        isShowingError = false
    }

    func cancelEditingModel() {
        if let selected = settings.selectedAIModel {
            loadDraft(from: selected, showsMessage: false)
        } else {
            createNewModelDraft(showsMessage: false)
        }
    }

    func deleteCurrentModel() {
        do {
            guard let editingModelID else {
                createNewModelDraft(showsMessage: false)
                showInfo("Draft cleared.")
                return
            }

            try apiKeyStore.deleteAPIKey(for: editingModelID)
            try modelStore.deleteModel(id: editingModelID)

            if let selected = settings.selectedAIModel {
                loadDraft(from: selected, showsMessage: false)
            } else {
                createNewModelDraft(showsMessage: false)
            }

            showInfo("Model deleted.")
        } catch {
            showError(error)
        }
    }

    func selectModel(id: String) {
        guard !hasUnsavedChanges else {
            showError("Save or cancel the current edit first.")
            return
        }

        guard id.isEmpty == false else {
            createNewModelDraft()
            return
        }

        guard id != editingModelID else {
            return
        }

        do {
            try modelStore.selectModel(id: id)

            guard let selected = settings.aiModels.first(where: { $0.id == id }) else {
                createNewModelDraft()
                return
            }

            loadDraft(from: selected, showsMessage: false)
        } catch {
            showError(error)
        }
    }

    func saveModel() {
        guard canSaveModel else {
            showError("Name, endpoint, model, and API key are required.")
            return
        }

        do {
            let modelID: String

            if let editingModelID {
                try modelStore.updateModel(
                    id: editingModelID,
                    name: draftName.trimmed,
                    endpoint: draftEndpoint.trimmed,
                    modelName: draftModelName.trimmed
                )
                modelID = editingModelID
            } else {
                modelID = try modelStore.addModel(
                    name: draftName.trimmed,
                    endpoint: draftEndpoint.trimmed,
                    modelName: draftModelName.trimmed
                )
            }

            if draftAPIKey.trimmed.isEmpty == false {
                try apiKeyStore.saveAPIKey(draftAPIKey, for: modelID)
            }

            try modelStore.selectModel(id: modelID)

            if let selected = settings.aiModels.first(where: { $0.id == modelID }) {
                loadDraft(from: selected, showsMessage: false)
            }

            hasUnsavedChanges = false
            showInfo("Model saved.")
        } catch {
            showError(error)
        }
    }

    func updateDraftName(_ value: String) {
        draftName = value
        markUnsaved()
    }

    func updateDraftEndpoint(_ value: String) {
        draftEndpoint = value
        markUnsaved()
    }

    func updateDraftModelName(_ value: String) {
        draftModelName = value
        markUnsaved()
    }

    func updateDraftAPIKey(_ value: String) {
        draftAPIKey = value
        markUnsaved()
    }

    func requestAccessibilityPermission() {
        AccessibilityPermissionService.requestPermission()
        refreshAccessibilityStatus()
    }

    func openAccessibilitySettings() {
        AccessibilityPermissionService.openSystemSettings()
    }

    func refreshAccessibilityStatus() {
        isAccessibilityTrusted = AccessibilityPermissionService.isTrusted
    }

    private var draftEndpointURL: URL? {
        guard let url = URL(string: draftEndpoint.trimmed),
              url.scheme?.hasPrefix("http") == true,
              url.host?.isEmpty == false else {
            return nil
        }

        return url
    }

    private var hasAPIKeyForSave: Bool {
        draftAPIKey.trimmed.isEmpty == false || (!isEditingNewModel && selectedModelHasAPIKey)
    }

    private func loadDraft(from model: AIModelConfiguration, showsMessage: Bool) {
        editingModelID = model.id
        draftName = model.name
        draftEndpoint = model.endpoint
        draftModelName = model.modelName
        draftAPIKey = ""
        selectedModelHasAPIKey = hasAPIKey(for: model.id)
        isEditingModelDetails = false
        hasUnsavedChanges = false

        if showsMessage {
            showInfo("Model loaded.")
        }
    }

    private func hasAPIKey(for modelID: String) -> Bool {
        do {
            return try apiKeyStore.loadAPIKey(for: modelID) != nil
        } catch {
            showError(error)
            return false
        }
    }

    private func markUnsaved() {
        hasUnsavedChanges = true
        lastMessage = nil
        isShowingError = false
    }

    private func showInfo(_ message: String) {
        lastMessage = message
        isShowingError = false
    }

    private func showError(_ message: String) {
        lastMessage = message
        isShowingError = true
    }

    private func showError(_ error: Error) {
        if let appError = error as? AppError {
            showError(appError.localizedDescription)
        } else {
            showError("Something went wrong.")
        }
    }
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
