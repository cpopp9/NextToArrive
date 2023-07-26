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
    
    init(location: CLLocationCoordinate2D) {
        self.mapLocation = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
        self.location = location
    }
    
    var locations: [Location] {
        [Location(name: "", coordinate: location)]
    }
    
    var body: some View {
        Map(coordinateRegion: $mapLocation, showsUserLocation: true, userTrackingMode: .constant(.follow), annotationItems: locations) { _ in
            MapMarker(coordinate: location)
        }.ignoresSafeArea()
    }
    
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(location: Location.exampleLocation.coordinate)
    }
}

