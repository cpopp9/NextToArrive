    //
    //  StopDetails.swift
    //  NextToArrive
    //
    //  Created by Cory Popp on 1/18/23.
    //

import Foundation

    // List of stops by route
struct BusStops: Codable, Identifiable, Equatable, Hashable {
    let id = UUID()
    let lng: String
    let lat: String
    let stopid: String
    var stopname: String
}
