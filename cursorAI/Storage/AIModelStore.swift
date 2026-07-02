import Foundation
import SwiftData

@MainActor
protocol AIModelStoring: AnyObject {
    func reload() throws
    func addModel(name: String, endpoint: String, modelName: String) throws -> String
    func deleteModel(id: String) throws
    func selectModel(id: String) throws
    func updateModel(id: String, name: String, endpoint: String, modelName: String) throws
}

@MainActor
final class AIModelStore: AIModelStoring {
    private let context: ModelContext
    private let settings: AppSettings

    init(context: ModelContext, settings: AppSettings) {
        self.context = context
        self.settings = settings
    }

    func reload() throws {
        let models = try fetchModels()
        settings.aiModels = models.map(\.snapshot)

        if let selected = models.first(where: \.isSelected) {
            settings.selectedAIModelID = selected.id
        } else if let first = models.first {
            first.isSelected = true
            settings.selectedAIModelID = first.id
            try context.save()
        } else {
            settings.selectedAIModelID = nil
        }
    }

    func addModel(name: String, endpoint: String, modelName: String) throws -> String {
        let hasModels = try fetchModels().isEmpty == false
        let model = StoredAIModel(
            name: name,
            endpoint: endpoint,
            modelName: modelName,
            isSelected: true
        )

        if hasModels {
            let models = try fetchModels()
            for model in models {
                model.isSelected = false
            }
        }

        context.insert(model)
        settings.selectedAIModelID = model.id
        try context.save()
        try reload()

        return model.id
    }

    func deleteModel(id: String) throws {
        let models = try fetchModels()
        guard let selected = models.first(where: { $0.id == id }) else {
            return
        }

        context.delete(selected)
        try context.save()

        let remaining = try fetchModels()
        if let first = remaining.first {
            try selectModel(id: first.id)
        } else {
            try reload()
        }
    }

    func selectModel(id: String) throws {
        let models = try fetchModels()
        guard models.contains(where: { $0.id == id }) else {
            return
        }

        guard models.contains(where: { $0.id == id && !$0.isSelected }) else {
            try reload()
            return
        }

        for model in models {
            model.isSelected = model.id == id
        }

        if let selected = models.first(where: { $0.id == id }) {
            selected.updatedAt = .now
        }

        try context.save()
        try reload()
    }

    func updateModel(id: String, name: String, endpoint: String, modelName: String) throws {
        let models = try fetchModels()
        guard let selected = models.first(where: { $0.id == id }) else {
            return
        }

        selected.name = name
        selected.endpoint = endpoint
        selected.modelName = modelName
        selected.updatedAt = .now
        try context.save()
        try reload()
    }

    private func fetchModels() throws -> [StoredAIModel] {
        let descriptor = FetchDescriptor<StoredAIModel>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )

        return try context.fetch(descriptor)
    }
}
