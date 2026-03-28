//
//  AgeView.swift
//  BathHack2026
//
//  Created by Oscar Leigh on 28/03/2026.
//

import MapKit
import SwiftUI

struct AddToiletView: View {
    @State private var viewModel = AddToiletViewModel()
    
    var body: some View {
        NavigationStack {
            
            Text("Add A New Toilet")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 30)
            
            VStack () {
                
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
                
                Text("Location")
                    .font(.system(size: 20, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
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
        .fullScreenCover(isPresented: $viewModel.navigateToList) {
            ListView()
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
