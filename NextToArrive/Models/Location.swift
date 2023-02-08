//
//  Locations.swift
//  NextToArrive
//
//  Created by Cory Popp on 2/8/23.
//

import Foundation
import MapKit

struct Location: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}
