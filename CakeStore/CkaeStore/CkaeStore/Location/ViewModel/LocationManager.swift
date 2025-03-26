//
//  LocationManager.swift
//  CkaeStore
//
//  Created by JIDTP1408 on 25/03/25.
//

import Foundation
import CoreLocation

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    
    @Published var locationPermissionGranted: Bool = false

    @Published var currentAddress: String = "Unknown Address"
     
     override init() {
         super.init()
         locationManager.delegate = self
         locationManager.requestWhenInUseAuthorization()
     }

     func requestLocation() {
         locationManager.requestLocation()
     }
    func requestLocationPermission(){
        locationManager.requestWhenInUseAuthorization()
    }
     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
         guard let location = locations.first else { return }
         fetchAddress(from: location)
     }

     func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
         print("❌ Location Error: \(error.localizedDescription)")
     }

     private func fetchAddress(from location: CLLocation) {
         let geocoder = CLGeocoder()
         geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
             if let error = error {
                 print("❌ Geocoding Error: \(error.localizedDescription)")
                 return
             }
             
             if let placemark = placemarks?.first {
                 let addressString = "\(placemark.name ?? ""), \(placemark.locality ?? ""), \(placemark.administrativeArea ?? ""), \(placemark.country ?? "")"
                 DispatchQueue.main.async {
                     self.currentAddress = addressString
                 }
             }
         }
     }

    /// ✅ Handles changes in location permission status.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.locationPermissionGranted = true
                print("✅ Location Permission Granted")
            case .denied, .restricted:
                self.locationPermissionGranted = false
                print("❌ Location Permission Denied")
            case .notDetermined:
                print("🚀 Asking for location permission...")
                self.locationManager.requestWhenInUseAuthorization()
            @unknown default:
                self.locationPermissionGranted = false
            }
        }
    }
}
