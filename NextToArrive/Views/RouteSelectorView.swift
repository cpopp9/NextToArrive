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
    @State var routes = ["2", "17"]
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    
                    Section("Find your stop ID") {
                        Link("Find", destination: URL(string: "https://www5.septa.org/travel/find-my-stop/")!)
                            .foregroundColor(.white)
                    }
                    
                    Section("Your bus stop info") {
//                        Picker("Route", selection: $scheduleVM.selectedRoute.Route) {
//                            ForEach(routes, id: \.self) { route in
//                                Text(route)
//                            }
//                        }
//                        .onChange(of: scheduleVM.selectedRoute) { _ in
//                            scheduleVM.resetSchedule()
//                        }
                        
                        Picker("Your Bus Stop", selection: $scheduleVM.selectedStop) {
                            ForEach(scheduleVM.busStops) { stop in
                                Text(stop.stopname)
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
                            Task {
                                await scheduleVM.downloadStops()
                            }
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
        }
    }
}

struct RouteSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        RouteSelectorView(scheduleVM: ScheduleViewModel())
    }
}
