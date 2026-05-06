//
//  LocationPicker.swift
//  SportsBuddyFinder
//
//  Created by Felipe Lopez on 4/22/26.
//

import SwiftUI
import MapKit
import CoreLocation

// Allows the user to select a location on a map or search for one.
// Returns the selected coordinate and location name back to the parent view.
struct LocationPickerView: View {
    // Used to dismiss the sheet after selecting a location
    @Environment(\.dismiss) private var dismiss

    // Binding to pass selected coordinate back to parent view
    @Binding var selectedCoordinate: CLLocationCoordinate2D?
    
    // Binding to pass selected location name back to parent view
    @Binding var selectedLocationName: String

    // Handles location search and autocomplete results
    @StateObject private var searchService = LocationSearchService()
    
    // Controls the visible region of the map
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 36.6522, longitude: -121.7989),
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
    )
    // Search input text
    @State private var searchText = ""
    
    // Temporary coordinate selected by the user before confirmation
    @State private var tempCoordinate: CLLocationCoordinate2D?
    
    // Temporary location name (resolved from coordinates or search)
    @State private var tempLocationName = ""
    
    // Indicates if reverse geocoding is in progress
    @State private var isResolvingLocation = false

    var body: some View {
        NavigationStack {
            VStack {
                // Interactive map for selecting a location
                MapReader { proxy in
                    Map(position: $cameraPosition, interactionModes: .all) {
                        // Display pin if a location is selected
                        if let tempCoordinate {
                            Annotation("Selected Location", coordinate: tempCoordinate) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .mapControls {
                        MapCompass()
                        MapPitchToggle()
                        MapScaleView()
                    }
                    // Convert tap location into geographic coordinates
                    .onTapGesture { screenPoint in
                        if let coordinate = proxy.convert(screenPoint, from: .local) {
                            tempCoordinate = coordinate
                            tempLocationName = "Loading..."
                            resolveLocationName(for: coordinate)
                        }
                    }
                }
                .frame(maxHeight: .infinity)

                VStack(spacing: 12) {
                    // Display search results if available
                    if !searchService.results.isEmpty {
                        searchResults
                    }

                    // Show selected location info
                    if let tempCoordinate {
                        Text(tempLocationName.isEmpty ? "Pinned Location" : tempLocationName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("Lat: \(tempCoordinate.latitude)")
                            .font(.caption)
                        Text("Lng: \(tempCoordinate.longitude)")
                            .font(.caption)
                        if isResolvingLocation {
                            ProgressView()
                                .controlSize(.small)
                        }
                    } else {
                        Text("Tap anywhere on the map or search for a place.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // Confirm selected location
                    Button("Confirm Location") {
                        selectedCoordinate = tempCoordinate
                        selectedLocationName = tempLocationName.isEmpty ? "Pinned Location" : tempLocationName
                        dismiss()
                    }
                    .disabled(tempCoordinate == nil)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(tempCoordinate == nil ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding()
                .background(.white)
            }
            .navigationTitle("Pick Location")
            .navigationBarTitleDisplayMode(.inline)
            
            // Search bar for finding locations
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for a park, gym, or address")
            
            // Update search results when text changes
            .onChange(of: searchText) { _, newValue in
                searchService.updateQuery(newValue)
            }
            
            // Restore previous selection if available
            .onAppear {
                if let selectedCoordinate {
                    tempCoordinate = selectedCoordinate
                    tempLocationName = selectedLocationName
                    cameraPosition = .region(
                        MKCoordinateRegion(
                            center: selectedCoordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )
                    )
                }
            }
            // Cancel button to dismiss picker
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    // Displays search autocomplete results
    private var searchResults: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(searchService.results, id: \.self) { completion in
                    Button {
                        selectCompletion(completion)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(completion.title)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            if !completion.subtitle.isEmpty {
                                Text(completion.subtitle)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxHeight: 180)
    }

    // Converts a search result into coordinates and updates the map
    private func selectCompletion(_ completion: MKLocalSearchCompletion) {
        Task {
            do {
                let request = MKLocalSearch.Request(completion: completion)
                let response = try await MKLocalSearch(request: request).start()

                guard let coordinate = response.mapItems.first?.placemark.coordinate else {
                    return
                }

                await MainActor.run {
                    tempCoordinate = coordinate
                    tempLocationName = completion.subtitle.isEmpty ? completion.title : "\(completion.title), \(completion.subtitle)"
                    cameraPosition = .region(
                        MKCoordinateRegion(
                            center: coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
                        )
                    )
                    searchText = tempLocationName
                    searchService.clearResults()
                }
            } catch {
                await MainActor.run {
                    tempLocationName = completion.title
                }
            }
        }
    }

    // Converts coordinates into a human-readable location name using reverse geocoding
    private func resolveLocationName(for coordinate: CLLocationCoordinate2D) {
        isResolvingLocation = true

        Task {
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let geocoder = CLGeocoder()

            do {
                let placemarks = try await geocoder.reverseGeocodeLocation(location)
                let placemark = placemarks.first
                let resolvedName = [
                    placemark?.name,
                    placemark?.locality
                ]
                .compactMap { $0 }
                .joined(separator: ", ")

                await MainActor.run {
                    tempLocationName = resolvedName.isEmpty ? "Pinned Location" : resolvedName
                    isResolvingLocation = false
                }
            } catch {
                await MainActor.run {
                    tempLocationName = "Pinned Location"
                    isResolvingLocation = false
                }
            }
        }
    }
}

// Provides autocomplete location search using MapKit
final class LocationSearchService: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var results: [MKLocalSearchCompletion] = []

    private let completer = MKLocalSearchCompleter()

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest]
    }

    // Updates search query and triggers autocomplete suggestions
    func updateQuery(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            clearResults()
            return
        }

        completer.queryFragment = trimmed
    }

    // Clears current search results
    func clearResults() {
        results = []
    }

    // Called when the search completer returns updated autocomplete results.
    // Limits results to the top 6 suggestions and updates the UI.
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.results = Array(completer.results.prefix(6))
        }
    }

    // Called when the search completer encounters an error.
    // Clears results to prevent displaying outdated or invalid suggestions.
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.results = []
        }
    }
}
