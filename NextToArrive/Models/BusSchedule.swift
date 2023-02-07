    //
    //  BusSchedule.swift
    //  NextToArrive
    //
    //  Created by Cory Popp on 1/5/23.
    //

import Foundation

typealias StopData = [String:[Schedule]]

struct Schedule: Decodable, Equatable, Hashable {
    let Route: String
    let DateCalender: Date
}

struct SelectedStop: Codable, Equatable {
    var route: String
    var stop: BusStop
    
    static let exampleStop = SelectedStop(route: "2", stop: BusStop(lng: "--", lat: "--", stopid: "3046", stopname: "16th St. and Mifflin St."))
}
