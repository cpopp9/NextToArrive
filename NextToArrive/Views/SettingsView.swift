    //
    //  RouteSelectorView.swift
    //  NextToArrive
    //
    //  Created by Cory Popp on 1/17/23.
    //

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var scheduleVM: ScheduleViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section("Select Your Local Bus Stop") {
                        Picker("Route", selection: $scheduleVM.selectedRoute) {
                            ForEach(scheduleVM.routes, id: \.self) { route in
                                Text(route)
                            }
                        }
                        .onChange(of: scheduleVM.selectedRoute) { _ in
                            print(scheduleVM.selectedRoute)
                            scheduleVM.resetBusStops()
                        }
                        
                        Picker("Your Bus Stop", selection: $scheduleVM.selectedStop) {
                            ForEach(self.scheduleVM.busStops, id:\.stopid) { (stop: BusStops) in
                                Text(stop.stopname).tag(stop)
                            }
                        }
                        .onChange(of: scheduleVM.selectedStop) { _ in
                            scheduleVM.resetSchedule()
                        }
                    }
                    
                    Section("About") {
                        Link("About the Developer", destination: URL(string: "https://www.linkedin.com/in/coryjpopp/")!)
                            .foregroundColor(.white)
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(scheduleVM: ScheduleViewModel())
    }
}