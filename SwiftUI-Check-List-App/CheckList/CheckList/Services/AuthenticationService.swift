import Foundation
import FirebaseAuth
import Combine

protocol AuthenticationServiceProtocol {
    func signIn(email: String, password: String) -> AnyPublisher<User, Error>
    func signUp(email: String, password: String) -> AnyPublisher<User, Error>
    func signOut() -> AnyPublisher<Void, Error>
    var currentUser: User? { get }
}

class AuthenticationService: AuthenticationServiceProtocol {
    private let auth = Auth.auth()
    
    var currentUser: User? {
        guard let firebaseUser = auth.currentUser else { return nil }
        return User(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? "",
            displayName: firebaseUser.displayName,
            isEmailVerified: firebaseUser.isEmailVerified
        )
    }
    
    func signIn(email: String, password: String) -> AnyPublisher<User, Error> {
        return Future<User, Error> { [weak self] promise in
            self?.auth.signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    promise(.failure(error))
                } else if let user = result?.user {
                    let appUser = User(
                        id: user.uid,
                        email: user.email ?? "",
                        displayName: user.displayName,
                        isEmailVerified: user.isEmailVerified
                    )
                    promise(.success(appUser))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func signUp(email: String, password: String) -> AnyPublisher<User, Error> {
        return Future<User, Error> { [weak self] promise in
            self?.auth.createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    promise(.failure(error))
                } else if let user = result?.user {
                    let appUser = User(
                        id: user.uid,
                        email: user.email ?? "",
                        displayName: user.displayName,
                        isEmailVerified: user.isEmailVerified
                    )
                    promise(.success(appUser))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func signOut() -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            do {
                try self?.auth.signOut()
                promise(.success(()))
            } catch let error {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
}
