//
//  ViewController.swift
//  CkaeStore
//
//  Created by JIDTP1408 on 21/03/25.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        checkOnboardingStatus()
    }

    private func checkOnboardingStatus() {
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")

        if !hasSeenOnboarding {
            showOnboardingScreen()
        } else {
            checkUserLoginStatus()
        }
    }

    private func showOnboardingScreen() {
        let storyboard = UIStoryboard(name: "Onboard", bundle: nil)
        if let onboardingVC = storyboard.instantiateViewController(withIdentifier: "OnboardingViewController") as? OnboardingViewController {
            onboardingVC.modalPresentationStyle = .fullScreen
            self.present(onboardingVC, animated: true, completion: nil)
        }
    }

    private func checkUserLoginStatus() {
        if Auth.auth().currentUser == nil {
            showLoginScreen()
        }
    }

    private func showLoginScreen() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            loginVC.modalPresentationStyle = .fullScreen
            self.present(loginVC, animated: true, completion: nil)
        }
    }
}
