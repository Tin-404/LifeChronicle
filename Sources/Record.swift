import Foundation

enum RecordType: String, Codable, CaseIterable {
    case diary
    case photo
    case film
}

struct Record: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var type: RecordType
    var content: String
    var createdAt: Date
    var mood: String?
    var images: [String]?
    var imageUrl: String?
}
