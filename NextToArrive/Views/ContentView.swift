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
                VStack(alignment: .leading) {
                    
                    Text("Route \(scheduleVM.selectedStop.route)")
                        .font(.largeTitle.bold())
                        .animation(.easeIn)
                        .onReceive(timer) { time in
                            if showingOptionsSheet == false {
                                scheduleVM.refreshSchedule()
                            }
                        }
                    
                    NavigationLink {
                        MapView(mapLocation: scheduleVM.mapLocation, location: scheduleVM.location)
                    } label: {
                        HStack {
                            Text(scheduleVM.selectedStop.stop.stopname)
                                .font(.subheadline)
                                .animation(.easeIn)
                            Image(systemName: "location.fill")
                                .font(.subheadline)
                        }
                    }
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                TimeView(timeUntil: scheduleVM.timeUntilArrival)
                
                Spacer()
                
                Text(scheduleVM.nextArrivingAt)
                    .multilineTextAlignment(.center)
                    .animation(.easeIn, value: scheduleVM.nextArrivingAt)
                
            }
            .foregroundColor(.white)
            .padding()
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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
