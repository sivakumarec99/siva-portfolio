import Foundation

struct User: Identifiable, Codable {
    let id: String
    let email: String
    var displayName: String?
    var profileImageUrl: String?
    var bio: String?
    var isEmailVerified: Bool
    var createdAt: Date
    var updatedAt: Date?

    // Default initializer
    init(
        id: String,
        email: String,
        displayName: String? = nil,
        profileImageUrl: String? = nil,
        bio: String? = nil,
        isEmailVerified: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.profileImageUrl = profileImageUrl
        self.bio = bio
        self.isEmailVerified = isEmailVerified
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // ✅ Convenience Initializer for Firestore Data
    init?(documentData: [String: Any]) {
        guard let id = documentData["id"] as? String,
              let email = documentData["email"] as? String,
              let createdAtTimestamp = documentData["createdAt"] as? TimeInterval else {
            return nil
        }

        self.id = id
        self.email = email
        self.displayName = documentData["displayName"] as? String
        self.profileImageUrl = documentData["profileImageUrl"] as? String
        self.bio = documentData["bio"] as? String
        self.isEmailVerified = documentData["isEmailVerified"] as? Bool ?? false
        self.createdAt = Date(timeIntervalSince1970: createdAtTimestamp)
        if let updatedAtTimestamp = documentData["updatedAt"] as? TimeInterval {
            self.updatedAt = Date(timeIntervalSince1970: updatedAtTimestamp)
        } else {
            self.updatedAt = nil
        }
    }

    // ✅ Convert to Firestore Dictionary
    var toFirestoreData: [String: Any] {
        return [
            "id": id,
            "email": email,
            "displayName": displayName ?? "",
            "profileImageUrl": profileImageUrl ?? "",
            "bio": bio ?? "",
            "isEmailVerified": isEmailVerified,
            "createdAt": createdAt.timeIntervalSince1970,
            "updatedAt": updatedAt?.timeIntervalSince1970 ?? createdAt.timeIntervalSince1970
        ]
    }

    // ✅ Static Placeholder User (For Previews / Mock Data)
    static let placeholder = User(
        id: "12345",
        email: "test@example.com",
        displayName: "John Doe",
        profileImageUrl: "https://example.com/profile.jpg",
        bio: "iOS Developer 🚀",
        isEmailVerified: true,
        createdAt: Date()
    )
}
