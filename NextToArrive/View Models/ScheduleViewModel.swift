    //
    //  ClockVM.swift
    //  NextToArrive
    //
    //  Created by Cory Popp on 1/10/23.
    //

import Foundation
import WidgetKit

class ScheduleViewModel: ObservableObject {
    
    let userDefaults = UserDefaults()
    @Published var timeUntilArrival = 0
    @Published var selectedStop = Stop.exampleStop
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
        
        selectedStop = decodeFromUserDefaults()
        
        refreshSchedule()
        
        Task {
            await downloadStops()
        }
    }
    
        // Overwrite existing bus stops
    func resetBusStops() {
        
            // Save route number in UserDefaults
        encodeToUserDefaults()
        
            // Delete existing bus stops
        busStops = []
        
            // Download new route stops
        Task {
            await downloadStops()
        }
        
            // Reload Widgets
        WidgetCenter.shared.reloadAllTimelines()
    }
    
        // Overwrite existing bus schedule
    func resetSchedule() {
        
        encodeToUserDefaults()
        
            // Delete existing bus times
        busTimes = []
        
            //Download new schedules
        Task {
            await downloadSchedule()
        }
        
            // Reload Widgets
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func downloadSchedule() async -> [Date] {
        
        var newTimes: [Date] = []
        
        guard let url = URL(string: "https://www3.septa.org/api/BusSchedules/index.php?stop_id=\(selectedStop.selectedStop.stopid)") else {
            print("❌ Invalid URL")
            return busTimes
        }
        
        do {
            
            let (data, _) = try await URLSession.shared.data(from: url)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy hh:mm aa"
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            
            if let decodedResponse = try? decoder.decode(StopData.self, from: data) {
                
                for (_, value) in decodedResponse {
                    for item in value {
                        if item.Route == selectedStop.selectedRoute {
                            newTimes.append(item.DateCalender)
                        }
                    }
                }
                print("✅ Successfully downloaded Schedule for Route \(selectedStop.selectedRoute) - \(newTimes.count) new times added")
            }
            
        } catch let error {
            print("❌ Invalid Data \(error)")
        }
        return newTimes
    }
    
    func refreshSchedule() {
        if busTimes.isEmpty {
            Task {
                busTimes = await downloadSchedule()
                calculateTimeUntilNextArrival()
            }
        } else {
                // Remove Expired Arrivals
            for time in busTimes {
                if Date() > time {
                    print("🗑️ Expired time removed - \(time.formatted(.dateTime.hour().minute()))")
                    busTimes.remove(at: 0)
                }
            }
            calculateTimeUntilNextArrival()
        }
    }
    
    func calculateTimeUntilNextArrival() {
        if !busTimes.isEmpty {
            let timeUntil = Calendar.current.dateComponents([.minute], from: .now, to: busTimes[0]).minute ?? 0
            DispatchQueue.main.async {
                self.timeUntilArrival = timeUntil
            }
        }
    }
    
        // Reassigns selected stop so prevent picker error -- "Picker: "" is invalid and does not have an associated tag, this will give undefined results.
    
    
        // Download new bus stops for selected Route
    func downloadStops() async {
        
        guard busStops.isEmpty else {
            return
        }
        
        guard let url = URL(string: "https://www3.septa.org/api/Stops/index.php?req1=\(selectedStop.selectedRoute)") else {
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
                
                // Reassign selected stop so that it has the correct associated tag
                for stop in busStops {
                    if stop.stopid == selectedStop.selectedStop.stopid {
                        selectedStop.selectedStop = stop
                        return
                    }
                }
                
                // If selected stop id doesn't match list of stops, assign the first stop so we have something to display to the user
                if let first = busStops.first {
                    DispatchQueue.main.async {
                        self.selectedStop.selectedStop = first
                    }
                }
            }
            
        } catch let error {
            print("Invalid Data \(error)")
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
    
    func encodeToUserDefaults() {
        
        do {
            /* Since it's Codable, we can convert it to JSON using JSONEncoder */
            let stopData = try JSONEncoder().encode(selectedStop)
            
            /* ...and store it in your shared UserDefaults container */
            UserDefaults(suiteName: "group.com.coryjpopp.nexttoarrive")!.set(stopData, forKey: "stop")
            print("✅ Encoding Successful - Saved stop as Route \(selectedStop.selectedRoute) at \(selectedStop.selectedStop.stopname)")
        } catch {
            print("Error Encoding \(error)")
        }
    }
    
    func decodeFromUserDefaults() -> Stop {
        
        /* Reading the encoded data from your shared App Group container storage */
        let encodedData = UserDefaults(suiteName: "group.com.coryjpopp.nexttoarrive")!.object(forKey: "stop") as? Data
        
        /* Decoding it using JSONDecoder*/
        if let stopEncoded = encodedData {
            
            let stopDecoded = try? JSONDecoder().decode(Stop.self, from: stopEncoded)
            if let stop = stopDecoded {
                print("✅ Decoding Successful - loaded saved stop as Route \(stop.selectedRoute) at \(stop.selectedStop.stopname)")
                return stop
            }
        }
        
        return Stop.exampleStop
    }
    
}
