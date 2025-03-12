import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    @State private var isAnimating = false
    
    // Animation states
    @State private var imageScale: CGFloat = 1.2
    @State private var imageOpacity: Double = 0
    @State private var titleOffset: CGFloat = 50
    @State private var titleOpacity: Double = 0
    @State private var timeOffset: CGFloat = 50
    @State private var timeOpacity: Double = 0
    
    private let gradientColors: [Color] = [
        Color(red: 0.1, green: 0.2, blue: 0.45),    // Royal Blue
        Color(red: 0.3, green: 0.2, blue: 0.5),     // Deep Purple
        Color(red: 0.5, green: 0.2, blue: 0.6),     // Rich Violet
        Color(red: 0.7, green: 0.3, blue: 0.6)      // Magenta
    ]
    
    var body: some View {
        if isActive {
            LoginView()
        } else {
            GeometryReader { geometry in
                ZStack {
                    // Animated Gradient Background
                    LinearGradient(
                        gradient: Gradient(colors: gradientColors),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    .hueRotation(.degrees(isAnimating ? 15 : 0))
                    .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true),
                             value: isAnimating)
                    
                    // Floating Particles Effect
                    ForEach(0..<15) { index in
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
                    
                    VStack(spacing: 0) {
                        Spacer()
                        
                        // App Name
                        Text("CheckList")
                            .font(.system(size: 45, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .white.opacity(0.5), radius: 10)
                            .offset(y: titleOffset)
                            .opacity(titleOpacity)
                        
                        // Splash Image with Glow
                        ZStack {
                            // Glow Effect
//                            Image("flash")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: geometry.size.width * 0.8)
//                                .blur(radius: 20)
//                                .opacity(0.5)
//                                .scaleEffect(imageScale * 1.1)
//                            
//                            // Main Image
//                            Image("flash")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: geometry.size.width * 0.8)
//                                .scaleEffect(imageScale)
                        }
                        .opacity(imageOpacity)
                        .blendMode(.plusLighter)
                        
                        Spacer()
                        
                        // App Time
                        VStack(spacing: 5) {
                            Text("Your Time, Your Tasks")
                                .font(.system(size: 20, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                            
                            Text("Manage Efficiently")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.bottom, 50)
                        .offset(y: timeOffset)
                        .opacity(timeOpacity)
                    }
                }
                .onAppear {
                    isAnimating = true
                    startAnimations()
                    
                    // Navigate to LoginView after delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        withAnimation(.easeOut(duration: 0.3)) {
                            self.isActive = true
                        }
                    }
                }
            }
        }
    }
    
    private func startAnimations() {
        // Title Animation (from top)
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
            titleOffset = 0
            titleOpacity = 1
        }
        
        // Image Animation (scale from background to front)
        withAnimation(.spring(response: 1.0, dampingFraction: 0.7).delay(0.4)) {
            imageScale = 1.0
            imageOpacity = 1
        }
        
        // Time Text Animation (from bottom)
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.6)) {
            timeOffset = 0
            timeOpacity = 1
        }
    }
}

#Preview {
    SplashScreenView()
}
