//
//  AgeView.swift
//  BathHack2026
//
//  Created by Oscar Leigh on 28/03/2026.
//

import MapKit
import SwiftUI

struct AddToiletView: View {
    @Environment(LocationService.self) var locationService
    @State private var viewModel = AddToiletViewModel()
    
    var body: some View {
        NavigationStack {
            
            Text("Add A New Toilet")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 30)
            
            VStack {
                
                Text("Name")
                    .font(.system(size: 20, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 5)
                
                TextField("67 Skibidi Toilet", text: $viewModel.toiletName)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .padding(.bottom, 20)
                
                Text("Description")
                    .font(.system(size: 20, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 5)
                
                TextField("Very very sigma skibidi", text: $viewModel.toiletDescription)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .padding(.bottom, 50)
                
                HStack {
                    Text("Location")
                        .font(.system(size: 20, weight: .bold))
                        .frame(alignment: .leading)
                    
                    Spacer()
                    
                    Button {
                        viewModel.lockForLocationRequest = true
                        Task {
                            let coordinates = try? await locationService.getLocation()
                            
                            if let coordinates {
                                viewModel.markerCoordinate = coordinates
                                
                                viewModel.mapCameraPosition = .region(MKCoordinateRegion(
                                    center: coordinates,
                                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                ))
                                
                                viewModel.mapView.toggle()
                            }
                            viewModel.lockForLocationRequest = false
                        }
                    } label: {
                        ZStack {
                            Text("Use my location")
                                .opacity(viewModel.lockForLocationRequest ? 0 : 1)
                            
                            ProgressView()
                                .opacity(viewModel.lockForLocationRequest ? 1 : 0)
                        }
                        .foregroundStyle(.secondary)
                        .font(.caption)
                    }
                    .buttonStyle(.glass)
                    .disabled(viewModel.lockForLocationRequest)
                }
                .padding(.bottom, 30)
                
                Text("Longitude")
                    .font(.system(size: 12, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 5)
                    .foregroundStyle(.secondary)
                
                TextField("longitude", text: $viewModel.longitude)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .padding(.bottom, 20)
                
                Text("Latitude")
                    .font(.system(size: 12, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 5)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 5)
                
                TextField("latitude", text: $viewModel.latitude)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .padding(.bottom, 20)
                
                Button {
                    viewModel.addToilet()
                } label: {
                    Text("Add")
                        .font(.system(size: 20))
                        .padding(.horizontal, 30)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .buttonStyle(.glassProminent)
                .tint(Color.green)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .sheet(isPresented: $viewModel.mapView) {
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
                    
                    VStack {
                        Spacer()
                        
                        Button {
                            if let coord = viewModel.markerCoordinate {
                                viewModel.latitude = String(format: "%.6f", coord.latitude)
                                viewModel.longitude = String(format: "%.6f", coord.longitude)
                            }
                            viewModel.mapView.toggle()
                        } label: {
                            Text("Use this location")
                                .padding()
                        }
                        .buttonStyle(.glass)
                        .disabled(viewModel.markerCoordinate == nil)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Back", systemImage: "chevron.left") {
                            viewModel.mapView.toggle()
                        }
                    }
                }
            }
        }
        .alert("Invalid Credentials", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please enter valid data for all fields.")
        }
    }
}

struct AddToiletView_Previews: PreviewProvider {
    static var previews: some View {
        AddToiletView()
    }
}
