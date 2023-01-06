//
//  ContentViewVM.swift
//  NextToArrive
//
//  Created by Cory Popp on 1/5/23.
//

import Foundation

extension ContentView {
    
    func dateFormatter(nextScheduled: String) -> Date {
            // Create Date Formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mma"
        
            // Convert String to Date
        
        return dateFormatter.date(from: nextScheduled) ?? Date.now
    }
    
}
