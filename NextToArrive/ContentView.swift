    //
    //  ContentView.swift
    //  NextToArrive
    //
    //  Created by Cory Popp on 1/3/23.
    //

import SwiftUI


struct ContentView: View {
    
    @State var currentT = Date()
    
    @State var busTimes: [String] = ["8:40a", "8:59a", "2:53p", "3:00p", "3:20p", "5:00p"]
    
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
        return -999
    }
    
        // Calculate the number of minutes between now and when the bus arrives
    var TimeDiff: Int {
        nextTime - currentTime
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.green.ignoresSafeArea()
                VStack {
                    Spacer()
                    HStack {
                        Text(String(TimeDiff))
                            .font(.system(size: 100).bold())
                        Text("Minutes")
                            .font(.title3.bold())
                    }
                    Text("Until the next bus")
                    Spacer()
                    Text("Scheduled to arrive at \(busTimes[0])")
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button() {
                        removeExpiredTimes()
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button() {
                        currentT = Date()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
    
    
    func removeExpiredTimes() {
        for time in busTimes {
            if 60*Calendar.current.component(.hour, from: dateFormatter(nextScheduled: time)) + Calendar.current.component(.minute, from: dateFormatter(nextScheduled: time)) < currentTime {
                busTimes.remove(at: 0)
            }
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
