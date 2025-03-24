//
//  LoginViewController.swift
//  CkaeStore
//
//  Created by JIDTP1408 on 24/03/25.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import AuthenticationServices

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground

        let titleLabel = UILabel()
        titleLabel.text = "Welcome to Cake World!"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 28)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let googleButton = createSocialButton(title: "Sign in with Google", color: .red, action: #selector(signInWithGoogle))
        let facebookButton = createSocialButton(title: "Sign in with Facebook", color: .blue, action: #selector(signInWithFacebook))
        let appleButton = createSocialButton(title: "Sign in with Apple", color: .black, action: #selector(signInWithApple))

        view.addSubview(titleLabel)
        view.addSubview(googleButton)
        view.addSubview(facebookButton)
        view.addSubview(appleButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            googleButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            googleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            googleButton.widthAnchor.constraint(equalToConstant: 250),
            googleButton.heightAnchor.constraint(equalToConstant: 50),

            facebookButton.topAnchor.constraint(equalTo: googleButton.bottomAnchor, constant: 20),
            facebookButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            facebookButton.widthAnchor.constraint(equalToConstant: 250),
            facebookButton.heightAnchor.constraint(equalToConstant: 50),

            appleButton.topAnchor.constraint(equalTo: facebookButton.bottomAnchor, constant: 20),
            appleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appleButton.widthAnchor.constraint(equalToConstant: 250),
            appleButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    private func createSocialButton(title: String, color: UIColor, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = color
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    // ✅ Google Sign-In
    @objc private func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
//        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { user, error in
//            if let error = error {
//                print("Google Sign-In Error: \(error.localizedDescription)")
//                return
//            }
//            guard let authentication = user?.authentication else { return }
//            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken!, accessToken: authentication.accessToken)
//
//            self.authenticateWithFirebase(credential)
//        }
    }

    // ✅ Facebook Sign-In
    @objc private func signInWithFacebook() {
//        let loginManager = LoginManager()
//        loginManager.logIn(permissions: ["email"], from: self) { result, error in
//            if let error = error {
//                print("Facebook Login Error: \(error.localizedDescription)")
//                return
//            }
//            guard let token = AccessToken.current?.tokenString else { return }
//            let credential = FacebookAuthProvider.credential(withAccessToken: token)
//
//            self.authenticateWithFirebase(credential)
//        }
    }

    // ✅ Apple Sign-In
    @objc private func signInWithApple() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authController = ASAuthorizationController(authorizationRequests: [request])
        authController.delegate = self
        authController.performRequests()
    }

    // ✅ Firebase Authentication
    private func authenticateWithFirebase(_ credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                print("Firebase Auth Error: \(error.localizedDescription)")
                return
            }
            self.dismiss(animated: true, completion: nil) // ✅ Close login screen after successful login
        }
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let appleIDToken = appleIDCredential.identityToken,
              let tokenString = String(data: appleIDToken, encoding: .utf8) else {
            return
        }

//        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, rawNonce: nil)
//        authenticateWithFirebase(credential)
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Apple Sign-In Error: \(error.localizedDescription)")
    }
}
