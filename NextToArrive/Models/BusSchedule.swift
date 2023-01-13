    //
    //  BusSchedule.swift
    //  NextToArrive
    //
    //  Created by Cory Popp on 1/5/23.
    //

import Foundation

struct BusSchedule: Codable {
    var one: [StopDetails]?
    var two: [StopDetails]?
    
        // Coding keys to allow an int to be read as a string
    enum CodingKeys: String, CodingKey {
        case one = "1"
        case two = "2"
    }
}


struct StopDetails: Codable {
    
    let StopName: String
    let Route: String
    let date: String
        //    let day: String
        //    let Direction: String
        //    let DateCalendar: String
        //    let DirectionDesc: String
    
}
