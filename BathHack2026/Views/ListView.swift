//
//  ListView.swift
//  BathHack2026
//
//  Created by Oscar Leigh on 28/03/2026.
//
//  Main home screen with map/list toggle, search, sort, and Code Brown.
//  This is the primary screen users see after signing in.
//

import MapKit
import SwiftUI

struct ListView: View {
    @Environment(AppState.self) var appState
    @Environment(LocationService.self) var locationService
    @State private var viewModel = ListViewModel()

    /// Toggle between map and list display modes
    enum ViewMode: String, CaseIterable {
        case map = "Map"
        case list = "List"
    }
    @State private var viewMode: ViewMode = .map

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Header bar
                headerBar

                // MARK: - View mode picker + sort controls
                controlsBar

                // MARK: - Content (Map or List)
                if viewModel.isLoading && viewModel.toilets.isEmpty {
                    Spacer()
                    ProgressView("Loading toilets...")
                    Spacer()
                } else {
                    switch viewMode {
                    case .map:
                        mapContent
                    case .list:
                        listContent
                    }
                }
            }
            // MARK: - Navigation destinations
            .navigationDestination(isPresented: $viewModel.navigateToAddToilet) {
                AddToiletView()
            }
            .navigationDestination(item: $viewModel.selectedToilet) { toilet in
                ToiletView(toilet: toilet)
            }
            // MARK: - Load data
            // Use .task for the one-time location fetch
            .task {
                if let coord = try? await locationService.getLocation() {
                    viewModel.userLocation = coord
                }
            }
            // Use .onAppear so toilets reload when navigating back
            // from AddToiletView or ToiletView (where reviews change avgStar)
            .onAppear {
                Task { await viewModel.loadToilets() }
            }
            .refreshable {
                await viewModel.loadToilets()
            }
            // MARK: - Code Brown alert
            .alert("Code Brown!", isPresented: $viewModel.showCodeBrownAlert) {
                if viewModel.codeBrownToilet != nil {
                    Button("Get Directions") {
                        openDirections(to: viewModel.codeBrownToilet!)
                    }
                    Button("View Details") {
                        viewModel.selectedToilet = viewModel.codeBrownToilet
                    }
                    Button("Cancel", role: .cancel) {}
                }
            } message: {
                if let toilet = viewModel.codeBrownToilet {
                    let distance = viewModel.userLocation != nil
                        ? " • \(toilet.formattedDistance(from: viewModel.userLocation!))"
                        : ""
                    let rating = toilet.avgStar > 0
                        ? String(format: "%.1f", toilet.avgStar) + " stars"
                        : "No reviews"
                    Text("Best nearby toilet:\n\(toilet.toiletName)\n\(rating)\(distance)")
                }
            }
        }
    }

    // MARK: - Header Bar

    private var headerBar: some View {
        HStack(spacing: 12) {
            // Search field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.gray)
                TextField("Search toilets...", text: $viewModel.searchText)
            }
            .padding(10)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(10)

            // Code Brown emergency button
            Button {
                viewModel.triggerCodeBrown()
            } label: {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.red)
            }

            // Add toilet button
            Button {
                viewModel.goToAddToilet()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.green)
            }

            // Sign out button
            Menu {
                if let username = appState.username {
                    Text("Signed in as @\(username)")
                }
                Button("Sign Out", role: .destructive) {
                    appState.signOut()
                }
            } label: {
                Image(systemName: "person.circle")
                    .font(.system(size: 24))
                    .foregroundStyle(.primary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    // MARK: - Controls Bar (picker + sort)

    private var controlsBar: some View {
        VStack(spacing: 6) {
            // Map/List toggle
            Picker("View Mode", selection: $viewMode) {
                ForEach(ViewMode.allCases, id: \.self) { mode in
                    Label(mode.rawValue, systemImage: mode == .map ? "map" : "list.bullet")
                        .tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            // Sort menu + count
            HStack {
                Menu {
                    ForEach(SortMode.allCases, id: \.self) { mode in
                        Button {
                            viewModel.sortMode = mode
                        } label: {
                            if viewModel.sortMode == mode {
                                Label(mode.rawValue, systemImage: "checkmark")
                            } else {
                                Text(mode.rawValue)
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.arrow.down")
                        Text(viewModel.sortMode.rawValue)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(viewModel.filteredToilets.count) toilet\(viewModel.filteredToilets.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 4)
    }

    // MARK: - Map Content

    private var mapContent: some View {
        ZStack(alignment: .bottom) {
            // Main map with toilet markers
            Map(position: $viewModel.mapCameraPosition, selection: $viewModel.selectedMapToiletId) {
                // Show user's blue dot
                UserAnnotation()

                // Toilet markers
                ForEach(viewModel.filteredToilets) { toilet in
                    Marker(
                        toilet.toiletName,
                        systemImage: toilet.isFree ? "toilet" : "sterlingsign.circle",
                        coordinate: toilet.coordinate
                    )
                    .tint(markerColor(for: toilet))
                    .tag(toilet.toiletId)
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            .mapStyle(.standard(pointsOfInterest: .excludingAll))

            // Bottom card when a marker is selected
            if let toilet = viewModel.selectedMapToilet {
                toiletMapCard(toilet)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.selectedMapToiletId)
    }

    /// Bottom card overlay for a selected toilet on the map
    private func toiletMapCard(_ toilet: Toilets) -> some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(toilet.toiletName)
                            .font(.headline)
                        if toilet.isFree {
                            Text("FREE")
                                .font(.caption2.bold())
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.green.opacity(0.2))
                                .foregroundStyle(.green)
                                .cornerRadius(4)
                        } else {
                            Text("PAID")
                                .font(.caption2.bold())
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.orange.opacity(0.2))
                                .foregroundStyle(.orange)
                                .cornerRadius(4)
                        }
                    }

                    HStack(spacing: 8) {
                        starRating(toilet.avgStar)

                        if let location = viewModel.userLocation {
                            Text(toilet.formattedDistance(from: location))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer()

                Button {
                    viewModel.selectedToilet = toilet
                    viewModel.selectedMapToiletId = nil
                } label: {
                    Text("Details")
                        .font(.subheadline.bold())
                }
                .buttonStyle(.glassProminent)
            }

            // Quick directions button
            Button {
                openDirections(to: toilet)
            } label: {
                Label("Get Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glass)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }

    // MARK: - List Content

    private var listContent: some View {
        ScrollView {
            if viewModel.filteredToilets.isEmpty {
                ContentUnavailableView(
                    "No Toilets Found",
                    systemImage: "toilet",
                    description: Text(viewModel.searchText.isEmpty
                        ? "Be the first to add a toilet!"
                        : "Try a different search term.")
                )
                .padding(.top, 40)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.filteredToilets) { toilet in
                        Button {
                            viewModel.goToToilet(toilet)
                        } label: {
                            toiletCard(toilet)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 4)
            }
        }
    }

    /// Card view for a toilet in the list
    private func toiletCard(_ toilet: Toilets) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Top row: name + rating badge
            HStack {
                // Status icon based on rating
                if toilet.avgStar >= 4 {
                    Image(systemName: "crown.fill")
                        .foregroundStyle(.yellow)
                        .font(.caption)
                } else if toilet.avgStar > 0 && toilet.avgStar <= 2 {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                        .font(.caption)
                }

                Text(toilet.toiletName)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Spacer()

                starRating(toilet.avgStar)
            }

            // Middle row: free/paid badge + distance
            HStack(spacing: 8) {
                if toilet.isFree {
                    Label("Free", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                } else {
                    Label("Paid", systemImage: "sterlingsign.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }

                if let location = viewModel.userLocation {
                    Text(toilet.formattedDistance(from: location))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("by @\(toilet.userCreator)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            // Description
            Text(toilet.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }

    // MARK: - Helpers

    /// Star rating display (filled and empty stars)
    private func starRating(_ rating: Float) -> some View {
        HStack(spacing: 2) {
            if rating > 0 {
                ForEach(1..<6) { star in
                    Image(systemName: Float(star) <= rating ? "star.fill" : "star")
                        .font(.caption2)
                        .foregroundStyle(.yellow)
                }
            } else {
                Text("New")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    /// Returns a tint colour for a toilet map marker based on its rating
    private func markerColor(for toilet: Toilets) -> Color {
        if toilet.avgStar >= 4 { return .green }
        if toilet.avgStar >= 2 { return .yellow }
        if toilet.avgStar > 0 { return .red }
        return .blue  // No reviews yet
    }

    /// Open Apple Maps with walking directions to a toilet
    private func openDirections(to toilet: Toilets) {
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: toilet.coordinate))
        destination.name = toilet.toiletName
        destination.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
        ])
    }
}
