//
//  ContentView.swift
//  NextToArrive
//
//  Created by Cory Popp on 1/3/23.
//

import MapKit
import SwiftUI


struct ContentView: View {
    
    @StateObject var scheduleVM = ContentViewModel()
    @State private var showingOptionsSheet = false
    
    // Timer setup to trigger once every 10 seconds to prompt fetching missing data
    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
    var body: some View {
        
        NavigationStack {
            
            VStack {
                
                RouteView(routeNumber: scheduleVM.selectedStop.route, stopName: scheduleVM.selectedStop.stop.stopname, location: scheduleVM.location)
                
                Spacer()
                
                TimeView(timeUntil: scheduleVM.timeUntilArrival)
                
                Spacer()
                
                Text(scheduleVM.nextArrivingAt)
                    .multilineTextAlignment(.center)
                    .animation(.easeIn, value: scheduleVM.nextArrivingAt)
                
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.green.gradient)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button() {
                        showingOptionsSheet.toggle()
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.white)
                    }
                    .sheet(isPresented: $showingOptionsSheet) {
                        SettingsView(scheduleVM: scheduleVM)
                    }
                }
            }
            .task {
                scheduleVM.refreshSchedule()
                scheduleVM.snapshotGenerator()
                await scheduleVM.downloadBusStops()
            }
            
            // Attempt refresh when timer is triggered
            .onReceive(timer) { time in
                if showingOptionsSheet == false {
                    scheduleVM.refreshSchedule()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
