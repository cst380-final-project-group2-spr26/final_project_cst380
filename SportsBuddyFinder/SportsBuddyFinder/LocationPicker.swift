//
//  LocationPicker.swift
//  SportsBuddyFinder
//
//  Created by Felipe Lopez on 4/22/26.
//

import SwiftUI
import MapKit
import CoreLocation

struct LocationPickerView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var selectedCoordinate: CLLocationCoordinate2D?
    @Binding var selectedLocationName: String

    @StateObject private var searchService = LocationSearchService()
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 36.6522, longitude: -121.7989),
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
    )
    @State private var searchText = ""
    @State private var tempCoordinate: CLLocationCoordinate2D?
    @State private var tempLocationName = ""
    @State private var isResolvingLocation = false

    var body: some View {
        NavigationStack {
            VStack {
                MapReader { proxy in
                    Map(position: $cameraPosition, interactionModes: .all) {
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
                    if !searchService.results.isEmpty {
                        searchResults
                    }

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
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for a park, gym, or address")
            .onChange(of: searchText) { _, newValue in
                searchService.updateQuery(newValue)
            }
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
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

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

final class LocationSearchService: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var results: [MKLocalSearchCompletion] = []

    private let completer = MKLocalSearchCompleter()

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest]
    }

    func updateQuery(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            clearResults()
            return
        }

        completer.queryFragment = trimmed
    }

    func clearResults() {
        results = []
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.results = Array(completer.results.prefix(6))
        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.results = []
        }
    }
}
