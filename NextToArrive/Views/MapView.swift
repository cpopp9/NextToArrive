    //
    //  MapView.swift
    //  NextToArrive
    //
    //  Created by Cory Popp on 2/8/23.
    //

import MapKit
import SwiftUI

struct MapView: View {
    @State var mapLocation: MKCoordinateRegion
    var location: CLLocationCoordinate2D

    var locations: [Location] {
        [Location(name: "", coordinate: location)]
    }

    var body: some View {
        Map(coordinateRegion: $mapLocation, showsUserLocation: true, userTrackingMode: .constant(.follow), annotationItems: locations) { _ in
            MapMarker(coordinate: location)
        }
    }

}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(mapLocation: MKCoordinateRegion(), location: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
    }
}

