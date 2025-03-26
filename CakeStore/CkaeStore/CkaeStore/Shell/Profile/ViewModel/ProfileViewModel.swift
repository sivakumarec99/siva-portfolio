//
//  ProfileViewModel.swift
//  CkaeStore
//
//  Created by JIDTP1408 on 26/03/25.
//

import Foundation
import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var chefProfile: ChefProfile?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    /// ✅ Fetch Profile Data from API
    func fetchProfile() async {
        guard let url = URL(string: "https://your-api-endpoint.com/profile") else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid API URL"
            }
            return
        }

        isLoading = true

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    self.errorMessage = "Server Error: Invalid Response"
                    self.isLoading = false
                }
                return
            }

            let decodedProfile = try JSONDecoder().decode(ChefProfile.self, from: data)

            DispatchQueue.main.async {
                self.chefProfile = decodedProfile
                self.isLoading = false
            }

        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to load profile: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
}
