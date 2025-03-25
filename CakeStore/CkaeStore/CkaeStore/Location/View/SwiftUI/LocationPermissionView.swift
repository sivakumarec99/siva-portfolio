//
//  LocationPermissionView.swift
//  CkaeStore
//
//  Created by JIDTP1408 on 25/03/25.
//


import SwiftUI
import CoreLocation

struct LocationPermissionView: View {
    var islocationSucess : () -> Void
    @StateObject private var locationManager = LocationManager()
    @Environment(\.presentationMode) var presentationMode  // ✅ Allows dismissing view
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.orange, Color.red]),
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Image(systemName: "location.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.white)

                Text("Enable Location Access")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("We need your location to provide better services.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)

                Button(action: {
                    locationManager.requestLocationPermission()
                }) {
                    Text("Enable Location")
                        .frame(width: 250, height: 50)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .font(.headline)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.top, 20)
            }
            .padding()
        }
        .onReceive(locationManager.$locationPermissionGranted) { granted in
            if granted {
                print("✅ Location permission granted, sending notification...")
                islocationSucess()
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
