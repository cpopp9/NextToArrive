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
    var busTimes: [Date] = []
    var busStops: [BusStops] = []
    
        // Valid route numbers
    let routes = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "42", "43", "44", "45", "46", "47", "48", "49", "50", "52", "53", "54", "55", "56", "57", "58", "59", "60", "61", "62", "64", "65", "66", "67", "68", "70", "73", "75", "77", "78", "79", "80", "84", "88", "89", "90", "91", "92", "93", "94", "95", "96", "97", "98", "99", "101", "102", "103", "104", "105", "106", "107", "108", "109", "110", "111", "112", "113", "114", "115", "117", "118", "119", "120", "123", "124", "125", "126", "127", "128", "129", "130", "131", "132", "133", "135", "139", "150", "201", "204", "206", "310", "311"]
    
        // Display message for next scheduled bus
    var nextArrivingAt: String {
        if !busTimes.isEmpty {
            return "Scheduled to arrive at \(busTimes[0].formatted(.dateTime.hour().minute()))"
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
        
        reassignSelectedStop()
    }
    
    func calculateTimeUntilArrival() {
        
        if !busTimes.isEmpty {
            let timeUntil = Calendar.current.dateComponents([.minute], from: .now, to: busTimes[0]).minute ?? 0
            DispatchQueue.main.async {
                self.timeUntilArrival = timeUntil
            }
        }
    }
    
        // Overwrite existing bus stops
    func resetBusStops() {
        
            // Save route number in UserDefaults
        defaults.set(selectedRoute, forKey: "route")
        
            // Delete existing bus stops
        busStops = []
        
            // Download new route stops
        Task {
            await downloadStops()
        }
    }
    
        // Overwrite existing bus schedule
    func resetSchedule() {
        
            // Delete existing bus times
        busTimes = []
        
            // Save bus stop in UserDefaults
        do {
            let encoder = JSONEncoder()
            
            let data = try encoder.encode(selectedStop)
            
            defaults.set(data, forKey: "stop")
            
        } catch {
            print("Couldn't encode \(error)")
        }
        
            //Download new schedules
        Task {
            await downloadSchedule()
        }
    }
    
        // Download new schedule for selected Bus Stop
    func downloadSchedule() async {
        
            // If there are no bus times available, attempt to download new ones
        if busTimes.isEmpty {
            
            guard let url = URL(string: "https://www3.septa.org/api/BusSchedules/index.php?stop_id=\(selectedStop.stopid)") else {
                print("Invalid URL")
                return
            }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yy hh:mm aa"
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                
                if let decodedResponse = try? decoder.decode(StopData.self, from: data) {
                    
                    if decodedResponse.isEmpty {
                        print("Failed to download bus schedule - retrying")
                    }
                    
                    for (_, value) in decodedResponse {
                        for item in value {
                            if item.Route == selectedRoute {
                                busTimes.append(item.DateCalender)
                            }
                        }
                    }
                }
                
            } catch let error {
                print("Invalid Data \(error)")
            }
        }
        print(busTimes)
        calculateTimeUntilArrival()
    }
    
        // Reassigns selected stop so prevent picker error -- "Picker: "" is invalid and does not have an associated tag, this will give undefined results.
    func reassignSelectedStop() {
        for stop in busStops {
            if stop.stopid == selectedStop.stopid {
                selectedStop = stop
            }
        }
    }
    
        // Download new bus stops for selected Route
    func downloadStops() async {
        
            // If there are no bus times available, attempt to download new ones
        if busStops.isEmpty && selectedStop.stopid != "--" {
            
            guard let url = URL(string: "https://www3.septa.org/api/Stops/index.php?req1=\(selectedRoute)") else {
                print("Invalid URL")
                return
            }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                if let decodedResponse = try? JSONDecoder().decode([BusStops].self, from: data) {
                    
                    for var stop in decodedResponse {
                        stop.stopname = stop.stopname.replacingOccurrences(of: "&amp;", with: "&")
                        
                        busStops.append(stop)
                    }
                    
                        // Automatically assign a selected stop on download so it has something to show to the user
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
    
        // Convert upcoming bus times from string to date
    func dateFormatter(nextScheduled: String) -> Date {
            // Create Date Formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mma"
        
            // Convert String to Date and return
        return dateFormatter.date(from: nextScheduled) ?? Date.now
    }
    
}
