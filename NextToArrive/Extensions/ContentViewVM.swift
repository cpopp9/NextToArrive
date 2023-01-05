//
//  ContentViewVM.swift
//  NextToArrive
//
//  Created by Cory Popp on 1/5/23.
//

import Foundation

extension ContentView {
    
    func compareTimes(busTime: String) -> Int {
        
            // Create Date Formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mma"
        
            // Convert String to Date
        let nextScheduled = dateFormatter.date(from: busTime) ?? Date.now
        
            // Convert both the current time and next upcoming scheduled bus into total number of minutes
        let currentTime = 60*Calendar.current.component(.hour, from: Date()) + Calendar.current.component(.minute, from: Date())
        let nextTime = 60*Calendar.current.component(.hour, from: nextScheduled) + Calendar.current.component(.minute, from: nextScheduled)
        
            // Calculate the number of minutes between now and when the bus arrives
        var timeDifference: Int {
            nextTime - currentTime
        }
        
        return timeDifference
    }
    
}
