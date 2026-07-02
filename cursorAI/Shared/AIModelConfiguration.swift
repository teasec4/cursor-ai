import Foundation

struct AIModelConfiguration: Identifiable, Equatable {
    let id: String
    var name: String
    var endpoint: String
    var modelName: String

    var endpointURL: URL? {
        URL(string: endpoint)
    }
}
