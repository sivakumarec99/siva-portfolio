import Foundation

struct User: Identifiable {
    let id: String
    let email: String
    var displayName: String?
    var isEmailVerified: Bool
    
    init(id: String, email: String, displayName: String? = nil, isEmailVerified: Bool = false) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.isEmailVerified = isEmailVerified
    }
}
