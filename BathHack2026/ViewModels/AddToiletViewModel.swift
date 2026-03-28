//
//  AddToiletViewModel.swift
//  BathHack2026
//
//  Created by Oscar Leigh on 28/03/2026.
//

import CoreLocation
import MapKit
import SwiftUI

@Observable
class AddToiletViewModel {
    var navigateToList = false
    var mapView = false
    var mapCameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
        
    var markerCoordinate: CLLocationCoordinate2D?
    var toiletName: String = ""
    var toiletDescription: String = ""
    var longitude: String = ""
    var latitude: String = ""
    var showError: Bool = false
    var lockForLocationRequest = false
    
    func isValidUserName(_ userName: String) -> Bool {
        return !userName.isEmpty
    }
    
    func isValidPassword(_ password: String) -> Bool {
        return !password.isEmpty
    }
    
    func addToilet() {
        //todo
        navigateToList = true
    }
    
}
