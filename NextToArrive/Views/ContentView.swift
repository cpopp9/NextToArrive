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
    @State private var showingSheet = false
    
    let test = false
    
        // Timer setup to trigger once ever 10 seconds
    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            ZStack {
                ContainerRelativeShape()
                    .fill(scheduleVM.networkSuccess ? Color.green.gradient : Color.red.gradient)
                    .ignoresSafeArea()
                VStack {
                    VStack(alignment: .leading) {
                        Text("Route \(scheduleVM.selectedStop.route)")
                            .font(.largeTitle.bold())
                            .animation(.easeIn)
                            .onReceive(timer) { time in
                                if showingSheet == false {
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
                            .foregroundColor(.primary)
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
                .padding()
            }
            .task {
                scheduleVM.refreshSchedule()
                scheduleVM.snapshotGenerator()
                await scheduleVM.downloadBusStops()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button() {
                        showingSheet.toggle()
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.white)
                    }
                    .sheet(isPresented: $showingSheet) {
                        SettingsView(scheduleVM: scheduleVM)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
