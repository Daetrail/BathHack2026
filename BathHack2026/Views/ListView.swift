//
//  ListView.swift
//  BathHack2026
//
//  Created by Oscar Leigh on 28/03/2026.
//

import SwiftUI

struct ListView: View {
@State private var viewModel = ListViewModel()
    
    var body: some View {
        NavigationStack {
            
            VStack {
                Text("Find My Toilet")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.gray)
                        TextField("Search...", text: $viewModel.searchText)
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)

                    Button {
                        viewModel.goToAddToilet()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.green)
                            .font(.system(size: 40))
                    }
                }
                .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(0..<10) { _ in
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(UIColor.systemGray6))
                                .frame(maxWidth: .infinity)
                                .frame(height: 100)
                                .overlay(
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Toilet Name")
                                            .font(.headline)
                                            .foregroundStyle(.primary)
                                        Text("Address goes here")
                                            .font(.subheadline)
                                            .foregroundStyle(.gray)
                                    }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                )
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationDestination(isPresented: $viewModel.navigateToAddToilet) {
                AddToiletView()
            }
        }
        
        
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
