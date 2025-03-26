//
//  ViewController.swift
//  CkaeStore
//
//  Created by JIDTP1408 on 21/03/25.
//

import UIKit
import FirebaseAuth
import SwiftUI
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .blue
        checkOnboardingStatus()
        
        // ✅ Create Seller Button
        let sellerButton = createButton(title: "Seller", color: .orange, action: #selector(openSellerDashboard))
        
        // ✅ Create Buyer Button
        let buyerButton = createButton(title: "Buyer", color: .blue, action: #selector(openBuyerDashboard))
        
        // ✅ Add Buttons to View
        view.addSubview(sellerButton)
        view.addSubview(buyerButton)
        
        // ✅ Set Auto Layout Constraints
        sellerButton.translatesAutoresizingMaskIntoConstraints = false
        buyerButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            sellerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sellerButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            sellerButton.widthAnchor.constraint(equalToConstant: 250),
            sellerButton.heightAnchor.constraint(equalToConstant: 80),
            
            buyerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buyerButton.topAnchor.constraint(equalTo: sellerButton.bottomAnchor, constant: 20),
            buyerButton.widthAnchor.constraint(equalToConstant: 250),
            buyerButton.heightAnchor.constraint(equalToConstant: 80)
        ])
        
    }
    /// ✅ Helper function to create buttons
    private func createButton(title: String, color: UIColor, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        button.backgroundColor = color
        button.layer.cornerRadius = 12
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    @objc private func openSellerDashboard() {
        print("✅ Seller button clicked")
        let chefProfile = ChefProfile(
            id: "12345",
            fullName: "John Doe",
            email: "johndoe@example.com",
            phoneNumber: "+1 234 567 890",
            profileImageURL: "https://via.placeholder.com/150",
            bio: "Expert Cake Seller & Baker",
            experience: 10,
            specialtyCuisines: ["French", "Italian", "Pastry"],
            certifications: [],
            rating: 4.8,
            totalReviews: 120,
            socialMediaLinks: [],
            availability: Availability(isAvailable: true, workingDays: ["Monday", "Wednesday"], startTime: "09:00 AM", endTime: "05:00 PM", availableTimeSlots: []),
            createdAt: Date(),
            updatedAt: Date()
        )
        let sellerSwiftUIView = SellerDashboardView(chefProfile: chefProfile)
        let hostingController = UIHostingController(rootView: sellerSwiftUIView)

        if let navController = navigationController {
            print("✅ NavigationController exists. Pushing view...")
            navController.pushViewController(hostingController, animated: true)
        } else {
            print("❌ NavigationController is nil. Presenting modally.")
            hostingController.modalPresentationStyle = .fullScreen
            present(hostingController, animated: true, completion: nil)
        }
    }

       /// ✅ Navigate to SwiftUI Buyer Dashboard
       @objc private func openBuyerDashboard() {
           print("✅ Seller button clicked")
           
           let buyerSwiftUIView = BuyerDashboardView()
           let hostingController = UIHostingController(rootView: buyerSwiftUIView)

           if let navController = navigationController {
               print("✅ NavigationController exists. Pushing view...")
               navController.pushViewController(hostingController, animated: true)
           } else {
               print("❌ NavigationController is nil. Presenting modally.")
               hostingController.modalPresentationStyle = .fullScreen
               present(hostingController, animated: true, completion: nil)
           }
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
        
        // ✅ Typecast to ensure correct subclass
        guard let onboardingVC = storyboard.instantiateViewController(withIdentifier: "OnboardingViewController") as? OnboardingViewController else {
            print("❌ Error: Could not instantiate OnboardingViewController")
            return
        }
        
        onboardingVC.modalPresentationStyle = .fullScreen
        self.present(onboardingVC, animated: true, completion: nil)
    }
    
    private func checkUserLoginStatus() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {  // ✅ Ensures UI update on main thread
                self.showLoginScreen{
                    self.checkLocationPermission()
                }
            }
        } else {
            checkLocationPermission()
        }
    }
    
    private func showLoginScreen(completion: @escaping () -> Void) {
        let loginSwiftUIView = LoginView(onLoginSuccess: {
            DispatchQueue.main.async {
                completion()
            }
        })
        
        let hostingController = UIHostingController(rootView: loginSwiftUIView)
        hostingController.modalPresentationStyle = .fullScreen
        self.present(hostingController, animated: true, completion: nil)
    }
    /// ✅ Checks location permission and navigates to `LocationPermissionView` if needed
    private func checkLocationPermission() {
        let authStatus = locationManager.authorizationStatus
        if authStatus == .authorizedWhenInUse || authStatus == .authorizedAlways {
            print("✅ Location permission already granted.")
        } else {
            print("🚀 Location permission not granted. Navigating to LocationPermissionView.")
            showLocationPermissionScreen()
        }
    }
    private func showLocationPermissionScreen() {
        let locationView = LocationPermissionView(islocationSucess: {
            self.checkLocationPermission()
        })
        let hostingController = UIHostingController(rootView: locationView)
        hostingController.modalPresentationStyle = .fullScreen
        self.present(hostingController, animated: true, completion: nil)
    }
    
}
