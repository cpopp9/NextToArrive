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
    
    let locations = [
        Location(name: "16th St. and Mifflin St.", coordinate: CLLocationCoordinate2D(latitude: 39.927134, longitude: -75.172321))
    ]
    
    var body: some View {
        Map(coordinateRegion: $mapLocation, showsUserLocation: true, annotationItems: locations) { _ in
            MapMarker(coordinate: location)
        }.edgesIgnoringSafeArea(.all)
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(mapLocation: MKCoordinateRegion(), location: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
    }
}
