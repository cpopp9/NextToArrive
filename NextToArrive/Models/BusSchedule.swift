    //
    //  BusSchedule.swift
    //  NextToArrive
    //
    //  Created by Cory Popp on 1/5/23.
    //

import Foundation

typealias StopData = [String:[StopDetails]]

struct StopDetails: Codable, Equatable, Hashable {
    let StopName: String
    let Route: String
    let date: String
}
