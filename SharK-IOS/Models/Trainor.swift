import Foundation

struct Trainor: Codable {
    let name: String
    let email: String
    let profilePictureUrl: String

    enum CodingKeys: String, CodingKey {
        case name
        case email
        case profilePictureUrl = "profilePictureUrl"
    }
}