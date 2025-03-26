//
//  ProfileView.swift
//  CkaeStore
//
//  Created by JIDTP1408 on 25/03/25.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading Profile...")
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else if let chef = viewModel.chefProfile {
                ProfileDetailsView(chef: chef)  // ✅ Show Profile Data
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchProfile()  // ✅ Fetch Profile on Load
            }
        }
        
    }
}
struct ProfileDetailsView: View {
    let chef: ChefProfile
    @State private var isEditing = false  // ✅ Tracks edit mode
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // ✅ Top Bar with Edit Button
                HStack {
                    Spacer()
                    Button(action: { isEditing.toggle() }) {
                        Image(systemName: "ellipsis.circle")
                            .font(.title)
                            .foregroundColor(.orange)
                    }
                    .padding(.trailing)
                }
                // ✅ Profile Header (Image, Name, Bio, Contact)
                ProfileHeaderView(chef: chef)
                
                // ✅ Experience & Specialties
                ProfileSection(title: "Experience & Specialties") {
                    VStack(alignment: .leading, spacing: 10) {
                        InfoRow(icon: "briefcase.fill", title: "Experience", value: "\(chef.experience) years")
                        InfoRow(icon: "fork.knife", title: "Specialty Cuisines", value: chef.specialtyCuisines.joined(separator: ", "))
                    }
                }
                
                // ✅ Certifications
                ProfileSection(title: "Certifications") {
                    ForEach(chef.certifications) { certification in
                        InfoRow(icon: "checkmark.seal.fill", title: certification.name, value: certification.issuedBy)
                    }
                }
                
                ProfileSection(title: "Ratings & Reviews") {
                    InfoRow(
                        icon: "star.fill",
                        title: "Rating",
                        value: "\(String(format: "%.1f", chef.rating)) ⭐ (\(chef.totalReviews) Reviews)"
                    )
                }
                
                // ✅ Social Media Links
                ProfileSection(title: "Social Media") {
                    ForEach(chef.socialMediaLinks) { link in
                        Link(link.platform, destination: URL(string: link.url)!)
                            .font(.body)
                            .foregroundColor(.blue)
                    }
                }
                
                // ✅ Availability
                ProfileSection(title: "Availability") {
                    InfoRow(icon: "calendar", title: "Working Days", value: chef.availability.workingDays.joined(separator: ", "))
                    InfoRow(icon: "clock.fill", title: "Working Hours", value: "\(chef.availability.startTime) - \(chef.availability.endTime)")
                }
            }
            .padding()
            .sheet(isPresented: $isEditing) {
                EditProfileView(chef: chef)  // ✅ Opens Edit Screen
            }
        }
        .navigationTitle("Chef Profile")
    }
}

struct ProfileHeaderView: View {
    let chef: ChefProfile
    
    var body: some View {
        VStack(spacing: 10) {
            // ✅ Profile Image
            AsyncImage(url: URL(string: chef.profileImageURL ?? "")) { image in
                image.resizable()
            } placeholder: {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .foregroundColor(.gray)
            }
            .frame(width: 120, height: 120)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.orange, lineWidth: 3))
            .shadow(radius: 5)
            
            // ✅ Name & Bio
            Text(chef.fullName)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            if let bio = chef.bio {
                Text(bio)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // ✅ Contact Details (Email, Phone)
            VStack(alignment: .leading, spacing: 5) {
                ContactRow(icon: "phone.fill", text: chef.phoneNumber)
                if let email = chef.email {
                    ContactRow(icon: "envelope.fill", text: email)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.systemBackground)).shadow(radius: 2))
        }
    }
}

struct ProfileSection<Content: View>: View {
    let title: String
    @State private var isExpanded = true
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack {
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
            }
            
            if isExpanded {
                content
                    .padding(.horizontal)
                    .padding(.bottom, 10)
            }
        }
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.systemBackground)).shadow(radius: 2))
        .padding(.vertical, 5)
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.orange)
                .frame(width: 30)
            Text(title + ":")
                .fontWeight(.semibold)
            Text(value)
                .foregroundColor(.primary)
            Spacer()
        }
    }
}

struct ContactRow: View {
    var icon: String
    var text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.orange)
                .frame(width: 30)
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.vertical, 5)
    }
}
