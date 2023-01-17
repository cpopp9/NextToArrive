    //
    //  ClockVM.swift
    //  NextToArrive
    //
    //  Created by Cory Popp on 1/10/23.
    //

import Foundation

class ScheduleViewModel: ObservableObject {
    
    @Published var stopLocation = "--"
    @Published var routeID = "--"
    @Published var timeUntilArrival = 0
    private var busTimes: [String] = []
    private var stopID = 40
    private var selectedRoute = "2"
    
    
        // Display message for next scheduled bus
    var nextArrivingAt: String {
        if !busTimes.isEmpty {
            return "Scheduled to arrive at \(busTimes[0])"
        }
        return "Downloading bus schedule..."
    }
    
    
        // Calculate the number of minutes between now and the next bus
    func calculateTimeUntilArrival() {
        
        let nextScheduled: Date
        
            // Make sure there are upcoming times before calculating
        if !busTimes.isEmpty {
            nextScheduled = dateFormatter(nextScheduled: busTimes[0])
        } else {
            nextScheduled = Date()
        }
        
            // Convert current time and next scheduled times into total number of minutes
        let currentTime = 60 * Calendar.current.component(.hour, from: Date()) + Calendar.current.component(.minute, from: Date())
        let scheduledArrival = 60 * Calendar.current.component(.hour, from: nextScheduled) + Calendar.current.component(.minute, from: nextScheduled)
        
            // Remove times if they have already passed
        if scheduledArrival < currentTime {
            busTimes.remove(at: 0)
        }
        
            // Calculate the number of minutes between now and when the bus arrives
        timeUntilArrival = scheduledArrival - currentTime
    }
    
    
    func refreshSchedule() {
        calculateTimeUntilArrival()
        Task {
            await downloadSchedule(stopID: stopID)
        }
    }
    
    func resetSchedule() {
        busTimes = []
        stopLocation = "--"
        routeID = "--"
        
    }
    
    private func downloadSchedule(stopID: Int) async {
        
            // If there are no bus times available, attempt to download new ones
        if busTimes.isEmpty {
            
            guard let url = URL(string: "https://www3.septa.org/api/BusSchedules/index.php?stop_id=\(stopID)") else {
                print("Invalid URL")
                return
            }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                print("ping server")
                
                if let decodedResponse = try? JSONDecoder().decode(StopData.self, from: data) {
                    
                    for (key, value) in decodedResponse {
                        
                        if key == selectedRoute {
                            
                                // Published properties need to be updated on the main thread
                            DispatchQueue.main.async {
                                self.stopLocation = value.first?.StopName ?? "--"
                                self.routeID = value.first?.Route ?? "--"
                            }
                            
                            for time in value {
                                busTimes.append(time.date)

                            }
                        }
                    }
                }
                
            } catch let error {
                print("Invalid Data \(error)")
            }
        }
    }
    
    func dateFormatter(nextScheduled: String) -> Date {
            // Create Date Formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mma"
        
            // Convert String to Date and return
        return dateFormatter.date(from: nextScheduled) ?? Date.now
    }
    
}
