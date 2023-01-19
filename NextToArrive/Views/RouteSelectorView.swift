    //
    //  RouteSelectorView.swift
    //  NextToArrive
    //
    //  Created by Cory Popp on 1/17/23.
    //

import SwiftUI

struct RouteSelectorView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var scheduleVM: ScheduleViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    
                    Section("Find your stop ID") {
                        Link("Find", destination: URL(string: "https://www5.septa.org/travel/find-my-stop/")!)
                            .foregroundColor(.white)
                    }
                    
                    Section("Your bus stop info") {
                        Picker("Route", selection: $scheduleVM.selectedRoute) {
                            ForEach(scheduleVM.routes, id: \.self) { route in
                                Text(route)
                            }
                        }
                        .onChange(of: scheduleVM.selectedRoute) { _ in
                            scheduleVM.resetBusStops()
                        }
                        
                        Picker("Your Bus Stop", selection: $scheduleVM.selectedStop) {
                            ForEach(self.scheduleVM.busStops, id:\.id) { (stop: BusStops) in
                                Text(stop.stopname).tag(stop)
                            }
                        }
                        .onChange(of: scheduleVM.selectedStop) { _ in
                            scheduleVM.resetSchedule()
                        }
                    }
                    
                    Section("About") {
                        Text("About the developer")
                        Text(scheduleVM.selectedStop.stopid)
                        Button("Print StopID") {
                            scheduleVM.resetSchedule()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                Button("Dismiss") {
                    dismiss()
                }
                .foregroundColor(.white)
            }
            .task {
                await scheduleVM.downloadStops()
            }
        }
    }
}

struct RouteSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        RouteSelectorView(scheduleVM: ScheduleViewModel())
    }
}
