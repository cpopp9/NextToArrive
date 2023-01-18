    //
    //  ClockVM.swift
    //  NextToArrive
    //
    //  Created by Cory Popp on 1/10/23.
    //

import Foundation

class ScheduleViewModel: ObservableObject {
    
//    @Published var stopLocation = "--"
//    @Published var routeID = "--"
    @Published var timeUntilArrival = 0
    var busTimes: [String] = []
    @Published var selectedStop: BusStops = BusStops(lng: "-75.172321", lat: "39.927134", stopid: "3046", stopname: "16th St &amp; Mifflin St")
    @Published var selectedRoute: StopDetails = StopDetails(StopName: "16th St &amp; Mifflin St", Route: "2", date: "1:04p")
    var busStops: [BusStops] = []
    
    
    
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
        DispatchQueue.main.async {
            self.timeUntilArrival = scheduledArrival - currentTime
        }
    }
    
    func refreshSchedule() {
        calculateTimeUntilArrival()
        Task {
            await downloadSchedule()
            await downloadStops()
        }
    }
    
    func resetSchedule() {
        busTimes = []
        selectedRoute = StopDetails(StopName: "16th St &amp; Mifflin St", Route: "2", date: "1:04p")
        selectedStop = BusStops(lng: "-75.172321", lat: "39.927134", stopid: "3046", stopname: "16th St &amp; Mifflin St")
        refreshSchedule()
    }
    
    private func downloadSchedule() async {
        
            // If there are no bus times available, attempt to download new ones
        if busTimes.isEmpty {
            
            guard let url = URL(string: "https://www3.septa.org/api/BusSchedules/index.php?stop_id=\(selectedStop.stopid)") else {
                print("Invalid URL")
                return
            }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                print("pinging server")
                
                if let decodedResponse = try? JSONDecoder().decode(StopData.self, from: data) {
                    
                    for (_, value) in decodedResponse {
                        for item in value {
                            if item.Route == selectedRoute.Route {
                                busTimes.append(item.date)
                            }
                        }
                    }
                }
                
            } catch let error {
                print("Invalid Data \(error)")
            }
        }
        
        calculateTimeUntilArrival()
    }
    
    func downloadStops() async {
        
            // If there are no bus times available, attempt to download new ones
        if busStops.isEmpty {
            
            guard let url = URL(string: "https://www3.septa.org/api/Stops/index.php?req1=\(selectedRoute.Route)") else {
                print("Invalid URL")
                return
            }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                print("pinging server")
                
                if let decodedResponse = try? JSONDecoder().decode([BusStops].self, from: data) {
                    
                    for stop in decodedResponse {
                        busStops.append(stop)
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
