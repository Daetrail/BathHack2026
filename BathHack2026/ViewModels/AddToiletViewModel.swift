//
//  AddToiletViewModel.swift
//  BathHack2026
//
//  Created by Oscar Leigh on 28/03/2026.
//
//  Manages the "Add a Toilet" form: name, description, location picking,
//  and free/paid toggle. Submits to the backend API.
//

import CoreLocation
import MapKit
import SwiftUI
import PhotosUI

@Observable
class AddToiletViewModel {
    // MARK: - Form fields
    var toiletName: String = ""
    var toiletDescription: String = ""
    var longitude: String = ""
    var latitude: String = ""
    var isFree: Bool = true
    var selectedPhoto: PhotosPickerItem? = nil
    var selectedImage: UIImage? = nil

    // MARK: - Map state
    var showMapSheet = false
    var mapCameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 51.3811, longitude: -2.3590), // Sane defaults for the map when opening without finding user location
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    )
    var markerCoordinate: CLLocationCoordinate2D?

    // MARK: - UI state
    var showError: Bool = false
    var errorMessage: String = ""
    var lockForLocationRequest = false
    var isSubmitting = false
    var didCreateToilet = false

    // MARK: - Validation

    /// Returns true if all required fields are filled in with valid data
    var isFormValid: Bool {
        !toiletName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !toiletDescription.trimmingCharacters(in: .whitespaces).isEmpty &&
        Double(latitude) != nil &&
        Double(longitude) != nil
    }

    // MARK: - API

    /// Submit the new toilet to the backend.
    /// Shows an error if validation fails or the API request fails.
    func addToilet() async {
        guard isFormValid else {
            errorMessage = "Please fill in all fields and set a valid location."
            showError = true
            return
        }

        isSubmitting = true
        defer { isSubmitting = false }

        let newToilet = NewToilet(
            toiletName: toiletName.trimmingCharacters(in: .whitespaces),
            description: toiletDescription.trimmingCharacters(in: .whitespaces),
            latitude: latitude,
            longitude: longitude,
            isFree: isFree
        )

        do {
            try await ServiceContainer.shared.toiletService.createToilet(newToilet: newToilet, toiletImage: nil)
            didCreateToilet = true
        } catch let error as APIError {
            switch error {
            case .serverError(let message):
                errorMessage = message
            }
            showError = true
        } catch {
            errorMessage = "Failed to create toilet. Please try again."
            showError = true
        }
    }
}
