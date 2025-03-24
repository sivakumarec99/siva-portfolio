//
//  Onboarding.swift
//  CkaeStore
//
//  Created by JIDTP1408 on 24/03/25.
//

import Foundation
import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentPage = 0

    private let slides: [OnboardingSlide] = [
        OnboardingSlide(imageName: "onboard_1", title: "Delicious Cakes", description: "Discover a variety of freshly baked cakes made with love and premium ingredients."),
        OnboardingSlide(imageName: "onboard_2", title: "Custom-Made Designs", description: "Order personalized cakes for birthdays, weddings, and special occasions."),
        OnboardingSlide(imageName: "onboard_3", title: "Fast & Safe Delivery", description: "Get your cakes delivered fresh and on time, right to your doorstep."),
        OnboardingSlide(imageName: "onboard_4", title: "Order with Ease", description: "Browse, customize, and place your cake order in just a few taps!")
    ]

    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(0..<slides.count, id: \.self) { index in
                    VStack {
                        Image(slides[index].imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)

                        Text(slides[index].title)
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top, 20)

                        Text(slides[index].description)
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle())

            VStack(spacing: 15) {  // ✅ Improved spacing
                Button("Skip") {
                    hasSeenOnboarding = true
                    navigateToViewController()
                }
                .padding()
                .foregroundColor(.gray)

                Button(action: {
                    if currentPage == slides.count - 1 {
                        hasSeenOnboarding = true
                        navigateToViewController()
                    } else {
                        currentPage += 1
                    }
                }) {
                    Text(currentPage == slides.count - 1 ? "Done" : "Next")
                        .font(.headline)
                        .frame(width: 140, height: 50)  // ✅ Improved button size
                        .background(Color.orange)       // ✅ Changed background to Orange
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }

    private func navigateToViewController() {
        // ✅ Switch back to UIKit ViewController
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let rootViewController = window.rootViewController
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let mainVC = mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            mainVC.modalPresentationStyle = .fullScreen
            rootViewController?.dismiss(animated: true) {
                rootViewController?.present(mainVC, animated: true, completion: nil)
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
