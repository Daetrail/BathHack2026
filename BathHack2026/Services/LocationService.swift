//
//  LocationService.swift
//  BathHack2026
//
//  Created by Matt Dustin Cruz on 28/03/2026.
//

import CoreLocation

@Observable
class LocationService: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocationCoordinate2D, Error>?
    
    var latitude: Double?
    var longitude: Double?
    var permissionDenied = false
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func getLocation() async throws -> CLLocationCoordinate2D {
        manager.requestWhenInUseAuthorization()
        
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            
            // If permission is already granted, request immediately
            if manager.authorizationStatus == .authorizedWhenInUse ||
               manager.authorizationStatus == .authorizedAlways {
                manager.requestLocation()
            }
            // Otherwise, locationManagerDidChangeAuthorization will handle it
        }
    }
    
    // MARK: - Delegate Methods
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            // Only request if we're actively waiting for a location
            if continuation != nil {
                manager.requestLocation()
            }
        case .denied, .restricted:
            permissionDenied = true
            continuation?.resume(throwing: LocationError.permissionDenied)
            continuation = nil
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        continuation?.resume(returning: location.coordinate)
        continuation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location failed: \(error.localizedDescription)")
        continuation?.resume(throwing: error)
        continuation = nil
    }
}

enum LocationError: LocalizedError {
    case permissionDenied
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Location permission was denied"
        }
    }
}
