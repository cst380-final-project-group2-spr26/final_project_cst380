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

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 36.6522, longitude: -121.7989),
        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    )

    @State private var tempCoordinate: CLLocationCoordinate2D?

    var body: some View {
        NavigationStack {
            VStack {
                MapReader { proxy in
                    Map(position: .constant(.region(region))) {
                        if let tempCoordinate {
                            Annotation("Selected Location", coordinate: tempCoordinate) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .onTapGesture { screenPoint in
                        if let coordinate = proxy.convert(screenPoint, from: .local) {
                            tempCoordinate = coordinate
                        }
                    }
                }
                .ignoresSafeArea(edges: .bottom)

                VStack(spacing: 12) {
                    if let tempCoordinate {
                        Text("Lat: \(tempCoordinate.latitude)")
                            .font(.caption)
                        Text("Lng: \(tempCoordinate.longitude)")
                            .font(.caption)
                    } else {
                        Text("Tap anywhere on the map to drop a pin.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Button("Confirm Location") {
                        selectedCoordinate = tempCoordinate
                        selectedLocationName = "Pinned Location"
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
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
