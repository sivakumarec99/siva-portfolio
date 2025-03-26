//
//  AddressView.swift
//  CkaeStore
//
//  Created by JIDTP1408 on 26/03/25.
//

import Foundation
import SwiftUI
import CoreLocation

struct AddressView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var address: String = "Fetching location..."

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Select Address")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(address)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.systemBackground)).shadow(radius: 2))

                Button(action: {
                    locationManager.requestLocation()
                }) {
                    Text("Get Current Location")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()

                Spacer()
            }
            .padding()
            .onReceive(locationManager.$currentAddress) { newAddress in
                address = newAddress
            }
            .navigationTitle("Address")
        }
    }
}
