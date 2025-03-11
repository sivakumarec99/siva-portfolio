import Foundation
import Combine

class AuthenticationViewModel: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let authService: AuthenticationServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(authService: AuthenticationServiceProtocol = AuthenticationService()) {
        self.authService = authService
        self.user = authService.currentUser
        self.isAuthenticated = user != nil
    }
    
    func signIn(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        authService.signIn(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] user in
                self?.user = user
                self?.isAuthenticated = true
            }
            .store(in: &cancellables)
    }
    
    func signUp(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        authService.signUp(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] user in
                self?.user = user
                self?.isAuthenticated = true
            }
            .store(in: &cancellables)
    }
    
    func signOut() {
        authService.signOut()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                self?.user = nil
                self?.isAuthenticated = false
            }
            .store(in: &cancellables)
    }
}
