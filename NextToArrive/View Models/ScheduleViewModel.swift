    //
    //  ClockVM.swift
    //  NextToArrive
    //
    //  Created by Cory Popp on 1/10/23.
    //

import Foundation

class ScheduleViewModel: ObservableObject {
    
    
    let defaults = UserDefaults.standard
    @Published var selectedRoute = "4"
    @Published var timeUntilArrival = 0
    @Published var selectedStop: BusStops = BusStops(lng: "--", lat: "--", stopid: "5281", stopname: "Broad St & Pine St")
    var busTimes: [String] = []
    var busStops: [BusStops] = []
    
    
    
    let routes = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "42", "43", "44", "45", "46", "47", "48", "49", "50", "52", "53", "54", "55", "56", "57", "58", "59", "60", "61", "62", "64", "65", "66", "67", "68", "70", "73", "75", "77", "78", "79", "80", "84", "88", "89", "90", "91", "92", "93", "94", "95", "96", "97", "98", "99", "101", "102", "103", "104", "105", "106", "107", "108", "109", "110", "111", "112", "113", "114", "115", "117", "118", "119", "120", "123", "124", "125", "126", "127", "128", "129", "130", "131", "132", "133", "135", "139", "150", "201", "204", "206", "310", "311", "406", "409", "411", "415", "426", "428", "433", "438", "439", "441", "442", "445", "446", "446", "447", "448", "446", "450", "452", "446", "461", "462", "475", "476", "477", "478", "484", "490", "492", "495"]
    
        // Display message for next scheduled bus
    var nextArrivingAt: String {
        if !busTimes.isEmpty {
            return "Scheduled to arrive at \(busTimes[0])"
        }
        return "Downloading bus schedule..."
    }
    
    init() {
        
        // read selectedRoute from UserDefaults
        selectedRoute = defaults.string(forKey: "route") ?? "4"
        
        // read selectedStop from UserDefaults
        if let selected = defaults.data(forKey: "stop") {
            
            do {
                let decoder = JSONDecoder()
                
                selectedStop = try decoder.decode(BusStops.self, from: selected)
            } catch {
                print("Error decoding \(error)")
            }
        }
        
        // read bus stops from UserDefaults
        if let savedStops = defaults.data(forKey: "busStops") {
            
            do {
                let decoder = JSONDecoder()
                
                busStops = try decoder.decode([BusStops].self, from: savedStops)
            } catch {
                print("Error decoding \(error)")
            }
            
            
        }
        
        Task {
            await downloadSchedule()
            await downloadStops()
        }
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
    
    func resetBusStops() {
        
        // Save route number in userdefaults
        defaults.set(selectedRoute, forKey: "route")
        
        // Clear existing bus stops
        busStops = []
        
        // Download new route stops
        Task {
            await downloadStops()
        }
    }
    
    func resetSchedule() {
        
        // Clear existing bus times
        busTimes = []
        
        // Save bus stop in userdefaults
        do {
            let encoder = JSONEncoder()
            
            let data = try encoder.encode(selectedStop)
            
            defaults.set(data, forKey: "stop")
            
        } catch {
            print("Couldn't encode \(error)")
        }
        
        Task {
            await downloadSchedule()
        }
    }
    
    func downloadSchedule() async {
        
            // If there are no bus times available, attempt to download new ones
        if busTimes.isEmpty {
            
            guard let url = URL(string: "https://www3.septa.org/api/BusSchedules/index.php?stop_id=\(selectedStop.stopid)") else {
                print("Invalid URL")
                return
            }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                print("Downloading schedule for \(selectedStop.stopname) on Route \(selectedRoute)")
                
                if let decodedResponse = try? JSONDecoder().decode(StopData.self, from: data) {
                    
                    for (_, value) in decodedResponse {
                        for item in value {
                            if item.Route == selectedRoute {
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
    
    func reassignSelectedStop() {
//        if !busStops.isEmpty {
            for stop in busStops {
                if stop.stopid == selectedStop.stopid {
                    selectedStop = stop
                }
            }
//        }
    }
    
    func downloadStops() async {
        
            // If there are no bus times available, attempt to download new ones
        if busStops.isEmpty && selectedStop.stopid != "--" {
            
            guard let url = URL(string: "https://www3.septa.org/api/Stops/index.php?req1=\(selectedRoute)") else {
                print("Invalid URL")
                return
            }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                print("Downloaded bus stops for Route \(selectedRoute)")
                
                if let decodedResponse = try? JSONDecoder().decode([BusStops].self, from: data) {
                    
                    
                    for var stop in decodedResponse {
                        stop.stopname = stop.stopname.replacingOccurrences(of: "&amp;", with: "&")
                        
                        busStops.append(stop)
                    }

                    
                    if let first = busStops.first {
                        DispatchQueue.main.async {
                            self.selectedStop = first
                        }
                    }
                    
                    do {
                        let encoder = JSONEncoder()
                        
                        let data = try encoder.encode(busStops)
                        
                        defaults.set(data, forKey: "busStops")
                        
                    } catch {
                        print("Couldn't encode bus stops \(error)")
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
