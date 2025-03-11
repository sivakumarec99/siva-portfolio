import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isSignUp = false
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showPassword = false
    @State private var navigateToHome = false
    
    // Animation states
    @State private var titleOffset: CGFloat = 30
    @State private var formOffset: CGFloat = 60
    @State private var opacity: Double = 0
    @State private var isAnimating = false
    
    private let gradientColors: [Color] = [
        Color(red: 0.1, green: 0.2, blue: 0.45),    // Royal Blue
        Color(red: 0.3, green: 0.2, blue: 0.5),     // Deep Purple
        Color(red: 0.5, green: 0.2, blue: 0.6),     // Rich Violet
        Color(red: 0.7, green: 0.3, blue: 0.6)      // Magenta
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink(destination: HomeView(), isActive: $navigateToHome) {
                    EmptyView()
                }
                
                // Animated Gradient Background
                LinearGradient(gradient: Gradient(colors: gradientColors),
                             startPoint: .topLeading,
                             endPoint: .bottomTrailing)
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
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        VStack(spacing: 15) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(width: 120, height: 120)
                                    .blur(radius: isAnimating ? 5 : 0)
                                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true),
                                             value: isAnimating)
                                
                                Image(systemName: isSignUp ? "person.badge.plus" : "person.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.white)
                                    .shadow(color: .white.opacity(0.5), radius: 10)
                            }
                            .padding(.top, 50)
                            
                            Text(isSignUp ? "Create Account" : "Welcome Back")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: .white.opacity(0.5), radius: 5)
                        }
                        .offset(y: titleOffset)
                        .opacity(opacity)
                        
                        // Form Fields
                        VStack(spacing: 25) {
                            // Email Field
                            FormField(
                                icon: "envelope.fill",
                                placeholder: "Email",
                                text: $email,
                                backgroundColor: .white.opacity(0.15),
                                cornerRadius: 15
                            )
                            
                            // Username Field (only for sign up)
                            if isSignUp {
                                FormField(
                                    icon: "person.fill",
                                    placeholder: "Username",
                                    text: $username,
                                    backgroundColor: .white.opacity(0.15),
                                    cornerRadius: 15
                                )
                            }
                            
                            // Password Field
                            FormField(
                                icon: "lock.fill",
                                placeholder: "Password",
                                text: $password,
                                isSecure: !showPassword,
                                backgroundColor: .white.opacity(0.15),
                                cornerRadius: 15,
                                showPasswordToggle: true,
                                isPasswordVisible: $showPassword
                            )
                            
                            // Confirm Password Field (only for sign up)
                            if isSignUp {
                                FormField(
                                    icon: "lock.shield.fill",
                                    placeholder: "Confirm Password",
                                    text: $confirmPassword,
                                    isSecure: !showPassword,
                                    backgroundColor: .white.opacity(0.15),
                                    cornerRadius: 15,
                                    showPasswordToggle: true,
                                    isPasswordVisible: $showPassword
                                )
                            }
                        }
                        .padding(.horizontal)
                        .offset(y: formOffset)
                        .opacity(opacity)
                        
                        // Action Button
                        Button(action: handleAuthentication) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.8),
                                            Color.white
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                                    .frame(height: 55)
                                    .shadow(color: .white.opacity(0.3), radius: 10)
                                
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: gradientColors[0]))
                                } else {
                                    Text(isSignUp ? "Create Account" : "Sign In")
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundColor(gradientColors[0])
                                }
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.top, 20)
                        .disabled(isLoading)
                        .offset(y: formOffset)
                        .opacity(opacity)
                        
                        // Toggle Sign Up/Sign In
                        Button(action: { 
                            withAnimation(.spring()) {
                                isSignUp.toggle()
                                // Clear fields when switching modes
                                if isSignUp {
                                    username = ""
                                    confirmPassword = ""
                                }
                            }
                        }) {
                            Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                                .padding(.top, 20)
                        }
                        .offset(y: formOffset)
                        .opacity(opacity)
                    }
                    .padding(.horizontal)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(isSignUp ? "Sign Up Error" : "Sign In Error"),
                      message: Text(alertMessage),
                      dismissButton: .default(Text("OK")))
            }
            .onAppear {
                isAnimating = true
                startAnimations()
            }
        }
        .navigationBarHidden(true)
    }
    
    private func startAnimations() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1)) {
            titleOffset = 0
            opacity = 1
        }
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2)) {
            formOffset = 0
        }
    }
    
    private func validateFields() -> Bool {
        if email.isEmpty || password.isEmpty || (isSignUp && (username.isEmpty || confirmPassword.isEmpty)) {
            alertMessage = "Please fill in all fields"
            return false
        }
        
        if !email.contains("@") {
            alertMessage = "Please enter a valid email address"
            return false
        }
        
        if isSignUp {
            if password != confirmPassword {
                alertMessage = "Passwords do not match"
                return false
            }
            
            if password.count < 6 {
                alertMessage = "Password must be at least 6 characters"
                return false
            }
        }
        
        return true
    }
    
    private func handleAuthentication() {
        guard validateFields() else {
            showAlert = true
            return
        }
        
        isLoading = true
        
        if isSignUp {
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                handleAuthResult(result: result, error: error)
            }
        } else {
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                handleAuthResult(result: result, error: error)
            }
        }
    }
    
    private func handleAuthResult(result: AuthDataResult?, error: Error?) {
        isLoading = false
        
        if let error = error {
            alertMessage = error.localizedDescription
            showAlert = true
        } else {
            // Successfully authenticated, navigate to HomeView
            withAnimation {
                navigateToHome = true
            }
        }
    }
}

struct FormField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var backgroundColor: Color = .white.opacity(0.2)
    var cornerRadius: CGFloat = 10
    var showPasswordToggle: Bool = false
    var isPasswordVisible: Binding<Bool>?
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.white)
                .frame(width: 20)
            
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .textInputAutocapitalization(.never)
            .foregroundColor(.white)
            .font(.system(size: 17, weight: .medium, design: .rounded))
            
            if showPasswordToggle {
                Button(action: {
                    isPasswordVisible?.wrappedValue.toggle()
                }) {
                    Image(systemName: (isPasswordVisible?.wrappedValue ?? false) ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.white.opacity(0.8))
                        .frame(width: 20)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(backgroundColor)
        .cornerRadius(cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    LoginView()
}
