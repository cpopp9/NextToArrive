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
