    //
    //  ContentView.swift
    //  NextToArrive
    //
    //  Created by Cory Popp on 1/3/23.
    //

import SwiftUI


struct ContentView: View {
    
    @State var currentT = Date()
    
    @State var busTimes: [String] = []
    
    @State var stopLocation = "--"
    
    var nextArrivingAt: String {
        if !busTimes.isEmpty {
            return "Scheduled to arrive at \(busTimes[0])"
        }
        return "Downloading bus schedule..."
    }
    
    var stopID = 3046
    
        // Convert current time into total number of minutes
    var currentTime: Int {
        60 * Calendar.current.component(.hour, from: currentT) + Calendar.current.component(.minute, from: currentT)
    }
    
        // Convert next scheduled bus into total number of minutes
        // Checks that there are upcoming times before accessing the first index in busTimes array
    var nextTime: Int {
        if !busTimes.isEmpty {
            return 60 * Calendar.current.component(.hour, from: dateFormatter(nextScheduled: busTimes[0])) + Calendar.current.component(.minute, from: dateFormatter(nextScheduled: busTimes[0]))
        }
        return currentTime
    }
    
        // Calculate the number of minutes between now and when the bus arrives
    var TimeDiff: Int {
        nextTime - currentTime
    }
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.green.ignoresSafeArea()
                VStack {
                    VStack(alignment: .leading) {
                        Text("Route 2")
                            .font(.largeTitle.bold())
                        Text(stopLocation)
                            .font(.subheadline)
                            .animation(.easeIn)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    
                    Spacer()
                    HStack {
                        Text(String(TimeDiff))
                            .font(.system(size: 100).bold())
                        Text("Minutes")
                            .font(.title3.bold())
                    }
                    Text("Until the next bus")
                        .onReceive(timer) { time in
                            refreshSchedule()
                        }
                    Spacer()
                    Text(nextArrivingAt)
                        .animation(.easeIn)
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Link("Find", destination: URL(string: "https://www5.septa.org/travel/find-my-stop/")!)
                        .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button() {
                        resetSchedule()
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .task {
            await downloadSchedule(stopID: stopID)
        }
    }
    
    func refreshSchedule() {
        removeExpiredTimes()
        currentT = Date()
        Task {
            await downloadSchedule(stopID: stopID)
        }
    }
    
    func resetSchedule() {
        busTimes = []
        stopLocation = "--"
        
    }
    
    func removeExpiredTimes() {
        for time in busTimes {
            if 60 * Calendar.current.component(.hour, from: dateFormatter(nextScheduled: time)) + Calendar.current.component(.minute, from: dateFormatter(nextScheduled: time)) < currentTime {
                busTimes.remove(at: 0)
            }
        }
    }
    
    func downloadSchedule(stopID: Int) async {
            // If there are no bus times available, attempt to download new ones
        
        if busTimes.isEmpty {
            
            guard let url = URL(string: "https://www3.septa.org/api/BusSchedules/index.php?stop_id=\(stopID)") else {
                print("Invalid URL")
                return
            }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                if let decodedResponse = try? JSONDecoder().decode(BusSchedule.self, from: data) {
                    for time in decodedResponse.two {
                        busTimes.append(time.date)
                    }
                    
                    stopLocation = decodedResponse.two.first?.StopName ?? "--"
                    
                    print("downloaded schedule")
                }
                
            } catch let error {
                print("Invalid Data \(error)")
            }
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
