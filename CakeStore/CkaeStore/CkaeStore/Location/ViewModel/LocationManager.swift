//
//  LocationManager.swift
//  CkaeStore
//
//  Created by JIDTP1408 on 25/03/25.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    
    @Published var locationPermissionGranted: Bool = false

    override init() {
        super.init()
        locationManager.delegate = self
    }

    /// ✅ Requests location permission only if not already determined
    func requestLocationPermission() {
        if locationManager.authorizationStatus == .notDetermined {
            DispatchQueue.main.async { // ✅ Ensures UI updates remain responsive
                self.locationManager.requestWhenInUseAuthorization()
            }
        } else {
            checkAuthorizationStatus(locationManager.authorizationStatus)
        }
    }

    /// ✅ Handles changes in location permission status.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuthorizationStatus(manager.authorizationStatus)
    }

    /// ✅ Checks authorization status and updates permission state.
    private func checkAuthorizationStatus(_ status: CLAuthorizationStatus) {
        DispatchQueue.main.async { // ✅ Ensures UI updates are smooth
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.locationPermissionGranted = true
                print("✅ Location Permission Granted")
            case .denied, .restricted:
                self.locationPermissionGranted = false
                print("❌ Location Permission Denied")
            case .notDetermined:
                print("🚀 Asking for location permission...")
            @unknown default:
                self.locationPermissionGranted = false
            }
        }
    }
}
