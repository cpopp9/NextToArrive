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
    
        // Timer setup to trigger once ever 10 seconds
    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            ZStack {
                ContainerRelativeShape()
                    .fill(.green.gradient).ignoresSafeArea()
                VStack {
                    VStack(alignment: .leading) {
                        Text("Route \(scheduleVM.selectedStop.route)")
                            .font(.largeTitle.bold())
                            .animation(.easeIn)
                        
                        NavigationLink {
                            MapView(mapLocation: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: Double(scheduleVM.selectedStop.stop.lat) ?? 0.0, longitude: Double(scheduleVM.selectedStop.stop.lng) ?? 0.0), span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)), location: CLLocationCoordinate2D(latitude: Double(scheduleVM.selectedStop.stop.lat) ?? 0.0, longitude: Double(scheduleVM.selectedStop.stop.lng) ?? 0.0))
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
                    HStack {
                        Text(String(scheduleVM.timeUntilArrival))
                            .font(.system(size: 100).bold())
                            .animation(.easeIn)
                        Text("Minutes")
                            .font(.title3.bold())
                    }
                    Text("Until the next bus")
                        .onReceive(timer) { time in
                            if showingSheet == false {
                                scheduleVM.refreshSchedule()
                            }
                        }
                    Spacer()
                    Text(scheduleVM.nextArrivingAt)
                        .animation(.easeIn)
                }
                .padding()
            }
            .task {
                scheduleVM.refreshSchedule()
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
