//
//  OnboardingView.swift
//  CheckList
//
//  Created by JIDTP1408 on 14/03/25.
//

import Foundation
import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var isAnimating = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    
    private let gradientColors: [Color] = [
        Color(red: 0.1, green: 0.2, blue: 0.45),    // Royal Blue
        Color(red: 0.3, green: 0.2, blue: 0.5),     // Deep Purple
        Color(red: 0.5, green: 0.2, blue: 0.6),     // Rich Violet
        Color(red: 0.7, green: 0.3, blue: 0.6)      // Magenta
    ]
    
    var body: some View {
        ZStack {
            // Animated Background
            LinearGradient(gradient: Gradient(colors: gradientColors),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
                .hueRotation(.degrees(isAnimating ? 15 : 0))
                .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: isAnimating)

            // Floating Particles
            ForEach(0..<15, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: CGFloat.random(in: 4...12))
                    .offset(x: CGFloat.random(in: -200...200),
                            y: CGFloat.random(in: -400...400))
                    .blur(radius: 2)
                    .animation(
                        Animation.linear(duration: Double.random(in: 5...10))
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                        value: isAnimating
                    )
            }

            VStack {
                // Onboarding Pages
                TabView(selection: $currentPage) {
                    OnboardingPageView(
                        title: "Welcome to CheckList",
                        description: "Organize your tasks, set reminders, and stay on top of your daily goals.",
                        imageName: "checkmark.circle.fill",
                        index: 0,
                        currentPage: $currentPage
                    )
                    
                    OnboardingPageView(
                        title: "Stay Productive",
                        description: "Create, edit, and organize checklists with ease. Never forget important tasks again!",
                        imageName: "list.bullet.rectangle",
                        index: 1,
                        currentPage: $currentPage
                    )
                    
                    OnboardingPageView(
                        title: "Get Started Now",
                        description: "Sign up to sync your lists across devices, or continue as a guest.",
                        imageName: "person.fill.checkmark",
                        index: 2,
                        currentPage: $currentPage
                    )
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .padding()

                // Next / Get Started Button
                Button(action: {
                    if currentPage < 2 {
                        currentPage += 1
                    } else {
                        hasSeenOnboarding = true
                    }
                }) {
                    Text(currentPage < 2 ? "Next" : "Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .shadow(radius: 5)
                }
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct OnboardingPageView: View {
    var title: String
    var description: String
    var imageName: String
    var index: Int
    @Binding var currentPage: Int

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .foregroundColor(.white)
                .shadow(radius: 10)
                .padding()
            
            Text(title)
                .font(.title)
                .bold()
                .foregroundColor(.white)
                .shadow(radius: 3)

            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal, 40)

            Spacer()
        }
        .tag(index)
    }
}
