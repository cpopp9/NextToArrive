    //
    //  BusSchedule.swift
    //  NextToArrive
    //
    //  Created by Cory Popp on 1/5/23.
    //

import Foundation

typealias StopData = [String:[Schedule]]

struct Schedule: Decodable, Equatable, Hashable {
    let StopName: String
    let Route: String
    let DateCalender: Date
}

struct Stop: Codable, Equatable {
    var selectedRoute: String
    var selectedStop: BusStops
    
    static let exampleStop = Stop(selectedRoute: "2", selectedStop: BusStops(lng: "--", lat: "--", stopid: "3046", stopname: "16th St. and Mifflin St."))
}
