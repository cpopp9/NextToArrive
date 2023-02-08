    //
    //  ClockVM.swift
    //  NextToArrive
    //
    //  Created by Cory Popp on 1/10/23.
    //

import Foundation
import WidgetKit

class ContentViewModel: ObservableObject {
    
    let widgetVM: WidgetViewModel
    @Published var timeUntilArrival = 0
    @Published var selectedStop = SelectedStop.exampleStop
    var busTimes: [Date] = []
    var busStops: [BusStop] = []
    
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
        widgetVM = WidgetViewModel()
        selectedStop = widgetVM.decodeFromUserDefaults()
    }
    
    func overwriteSelectedRoute() {
        
        encodeToUserDefaults()
        
        busStops = []
        
        Task {
            await downloadBusStops()
        }
        
    }
    
    func overwriteSelectedStop() {
        
        encodeToUserDefaults()
        
        busTimes = []
        
        Task {
            await widgetVM.downloadSchedule(stopID: selectedStop.stop.stopid, route: selectedStop.route)
        }
        
        calculateTimeUntilNextArrival()
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func refreshSchedule() {
        if busTimes.isEmpty {
            Task {
                busTimes = await widgetVM.downloadSchedule(stopID: selectedStop.stop.stopid, route: selectedStop.route)
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
            var timeUntil = Calendar.current.dateComponents([.minute], from: .now, to: busTimes[0]).minute ?? 0
            timeUntil += 1
            DispatchQueue.main.async {
                self.timeUntilArrival = timeUntil
            }
        }
    }
    
    func downloadBusStops() async {
        
        guard busStops.isEmpty else {
            return
        }
        
        guard let url = URL(string: "https://www3.septa.org/api/Stops/index.php?req1=\(selectedStop.route)") else {
            print("Invalid URL")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let decodedResponse = try? JSONDecoder().decode([BusStop].self, from: data) {
                
                for var stop in decodedResponse {
                    stop.stopname = stop.stopname.replacingOccurrences(of: "&amp;", with: "&")
                    
                    busStops.append(stop)
                }
                
                // Reassign selected stop so that it has the correct associated tag
                for stop in busStops {
                    if stop.stopid == selectedStop.stop.stopid {
                        DispatchQueue.main.async {
                            self.selectedStop.stop = stop
                            return
                        }
                    }
                }
                
                // If selected stop id doesn't match list of stops, assign the first stop so we have something to display to the user
                if let first = busStops.first {
                    DispatchQueue.main.async {
                        self.selectedStop.stop = first
                    }
                }
            }
            
        } catch let error {
            print("Invalid Data \(error)")
        }
    }
    
    func encodeToUserDefaults() {
        
        do {
            let stopData = try JSONEncoder().encode(selectedStop)
            
            UserDefaults(suiteName: "group.com.coryjpopp.nexttoarrive")!.set(stopData, forKey: "stop")
            print("✅ Encoding Successful - Saved stop as Route \(selectedStop.route) at \(selectedStop.stop.stopname)")
        } catch {
            print("Error Encoding \(error)")
        }
    }
    
    
}


class WidgetViewModel {
    
    func decodeFromUserDefaults() -> SelectedStop {
        
        let encodedData = UserDefaults(suiteName: "group.com.coryjpopp.nexttoarrive")!.object(forKey: "stop") as? Data
        
        if let stopEncoded = encodedData {
            
            let stopDecoded = try? JSONDecoder().decode(SelectedStop.self, from: stopEncoded)
            if let stop = stopDecoded {
                print("✅ Decoding Successful - loaded saved stop as Route \(stop.route) at \(stop.stop.stopname)")
                return stop
            }
        }
        print("Failed to Decode")
        return SelectedStop.exampleStop
    }
    
    func downloadSchedule(stopID: String, route: String) async -> [Date] {
        
        var newTimes: [Date] = []
        
        guard let url = URL(string: "https://www3.septa.org/api/BusSchedules/index.php?stop_id=\(stopID)") else {
            print("❌ Invalid URL")
            return newTimes
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
                        if item.Route == route {
                            newTimes.append(item.DateCalender)
                        }
                    }
                }
                print("✅ Successfully downloaded Schedule for Route \(route) - \(newTimes.count) new times added")
            }
            
        } catch let error {
            print("❌ Invalid Data \(error)")
        }
        return newTimes
    }
    
}
