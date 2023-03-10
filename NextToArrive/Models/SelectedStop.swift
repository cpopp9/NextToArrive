//
//  SelectedStop.swift
//  NextToArrive
//
//  Created by Cory Popp on 2/8/23.
//

import Foundation

struct SelectedStop: Codable, Equatable {
    var route: String
    var stop: BusStop
    
    static let exampleStop = SelectedStop(route: "2", stop: BusStop(lng: "-75.17402", lat: "39.927566", stopid: "3046", stopname: "16th St. and Mifflin St."))
}
