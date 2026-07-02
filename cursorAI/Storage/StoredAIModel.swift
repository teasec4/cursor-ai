import Foundation
import SwiftData

@Model
final class StoredAIModel {
    @Attribute(.unique) var id: String
    var name: String
    var endpoint: String
    var modelName: String
    var isSelected: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String = UUID().uuidString,
        name: String,
        endpoint: String,
        modelName: String,
        isSelected: Bool = false,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.endpoint = endpoint
        self.modelName = modelName
        self.isSelected = isSelected
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var snapshot: AIModelConfiguration {
        AIModelConfiguration(
            id: id,
            name: name,
            endpoint: endpoint,
            modelName: modelName
        )
    }
}
