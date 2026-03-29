//
//  AddToiletView.swift
//  BathHack2026
//
//  Created by Oscar Leigh on 28/03/2026.
//
//  Form for adding a new toilet. Includes name, description, free/paid toggle,
//  and a map-based location picker (or manual lat/long entry).
//

import MapKit
import SwiftUI
import PhotosUI

struct AddToiletView: View {
    @Environment(LocationService.self) var locationService
    @Environment(\.dismiss) var dismiss
    @State private var viewModel = AddToiletViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // MARK: - Name field
                VStack(alignment: .leading, spacing: 6) {
                    Text("Name")
                        .font(.headline)
                    TextField("e.g. Southgate Shopping Centre WC", text: $viewModel.toiletName)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                }

                // MARK: - Description field
                VStack(alignment: .leading, spacing: 6) {
                    Text("Description")
                        .font(.headline)
                    TextField("Describe the toilet and its condition", text: $viewModel.toiletDescription, axis: .vertical)
                        .lineLimit(3...6)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                }

                // MARK: - Free/Paid toggle
                HStack {
                    Label(
                        viewModel.isFree ? "Free to use" : "Paid entry",
                        systemImage: viewModel.isFree ? "checkmark.circle.fill" : "sterlingsign.circle.fill"
                    )
                    .foregroundStyle(viewModel.isFree ? .green : .orange)
                    .font(.headline)

                    Spacer()

                    Toggle("", isOn: $viewModel.isFree)
                        .labelsHidden()
                        .tint(.green)
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)

                // MARK: - Location section
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Location")
                            .font(.headline)

                        Spacer()

                        // Use my location button — gets GPS coordinates
                        Button {
                            viewModel.lockForLocationRequest = true
                            Task {
                                let coordinates = try? await locationService.getLocation()

                                if let coordinates {
                                    viewModel.markerCoordinate = coordinates
                                    viewModel.mapCameraPosition = .region(MKCoordinateRegion(
                                        center: coordinates,
                                        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                                    ))
                                    viewModel.latitude = String(format: "%.6f", coordinates.latitude)
                                    viewModel.longitude = String(format: "%.6f", coordinates.longitude)
                                }
                                viewModel.lockForLocationRequest = false
                            }
                        } label: {
                            ZStack {
                                Label("Use my location", systemImage: "location.fill")
                                    .opacity(viewModel.lockForLocationRequest ? 0 : 1)

                                ProgressView()
                                    .controlSize(.small)
                                    .opacity(viewModel.lockForLocationRequest ? 1 : 0)
                            }
                            .font(.caption)
                        }
                        .buttonStyle(.glass)
                        .disabled(viewModel.lockForLocationRequest)

                        // Open map picker
                        Button {
                            // If no marker set yet, centre on user location
                            if viewModel.markerCoordinate == nil,
                               let lat = locationService.latitude,
                               let lon = locationService.longitude {
                                viewModel.mapCameraPosition = .region(MKCoordinateRegion(
                                    center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                ))
                            }
                            viewModel.showMapSheet = true
                        } label: {
                            Label("Pick on map", systemImage: "map")
                                .font(.caption)
                        }
                        .buttonStyle(.glass)
                    }

                    // Show a mini preview map if coordinates are set
                    if let coord = viewModel.markerCoordinate {
                        Map(initialPosition: .region(MKCoordinateRegion(
                            center: coord,
                            span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
                        ))) {
                            Marker("Selected", coordinate: coord)
                                .tint(.red)
                        }
                        .frame(height: 120)
                        .cornerRadius(10)
                        .allowsHitTesting(false)
                    }

                    // Manual lat/long fields
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Latitude")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            TextField("51.3811", text: $viewModel.latitude)
                                .keyboardType(.decimalPad)
                                .padding(10)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Longitude")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            TextField("-2.3590", text: $viewModel.longitude)
                                .keyboardType(.decimalPad)
                                .padding(10)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                        }
                    }
                }
                
                // MARK: - Upload image button
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Photo")
                        .font(.headline)

                    PhotosPicker(selection: $viewModel.selectedPhoto, matching: .images) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(UIColor.systemGray6))
                                .frame(height: 120)

                            if let image = viewModel.selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            } else {
                                VStack(spacing: 8) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 30))
                                        .foregroundStyle(.secondary)
                                    Text("Tap to add photo")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
                .onChange(of: viewModel.selectedPhoto) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            viewModel.selectedImage = image
                        }
                    }
                }
                
                
                

                // MARK: - Submit button
                Button {
                    Task {
                        await viewModel.addToilet()
                    }
                } label: {
                    ZStack {
                        Label("Add Toilet", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .opacity(viewModel.isSubmitting ? 0 : 1)

                        ProgressView()
                            .opacity(viewModel.isSubmitting ? 1 : 0)
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(height: 56)
                .buttonStyle(.glassProminent)
                .tint(.green)
                .disabled(viewModel.isSubmitting || !viewModel.isFormValid)
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
        }
        .navigationTitle("Add a Toilet")
        .navigationBarTitleDisplayMode(.large)
        // MARK: - Map picker sheet
        .sheet(isPresented: $viewModel.showMapSheet) {
            mapPickerSheet
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
        // Dismiss when toilet is successfully created
        .onChange(of: viewModel.didCreateToilet) { _, created in
            if created { dismiss() }
        }
    }

    // MARK: - Map Picker Sheet

    /// Full-screen map for selecting a toilet location by tapping
    private var mapPickerSheet: some View {
        NavigationStack {
            ZStack {
                MapReader { proxy in
                    Map(position: $viewModel.mapCameraPosition) {
                        if let coord = viewModel.markerCoordinate {
                            Marker("Selected", systemImage: "mappin",
                                   coordinate: coord)
                                .tint(.red)
                        }
                    }
                    .onTapGesture { screenPosition in
                        if let coord = proxy.convert(screenPosition, from: .local) {
                            viewModel.markerCoordinate = coord
                        }
                    }
                }

                // Bottom confirm button
                VStack {
                    Spacer()

                    if let coord = viewModel.markerCoordinate {
                        Text("\(String(format: "%.6f", coord.latitude)), \(String(format: "%.6f", coord.longitude))")
                            .font(.caption)
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .cornerRadius(8)
                    }

                    Button {
                        if let coord = viewModel.markerCoordinate {
                            viewModel.latitude = String(format: "%.6f", coord.latitude)
                            viewModel.longitude = String(format: "%.6f", coord.longitude)
                        }
                        viewModel.showMapSheet = false
                    } label: {
                        Text("Use this location")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.glassProminent)
                    .disabled(viewModel.markerCoordinate == nil)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
            }
            .navigationTitle("Tap to select location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        viewModel.showMapSheet = false
                    }
                }
            }
        }
    }
}

struct AddToiletView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AddToiletView()
                .environment(LocationService())
        }
    }
}
