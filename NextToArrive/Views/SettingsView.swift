    //
    //  RouteSelectorView.swift
    //  NextToArrive
    //
    //  Created by Cory Popp on 1/17/23.
    //

import SwiftUI
import WidgetKit

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var scheduleVM: ScheduleViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section("Select Your Local Bus Stop") {
                        Picker("Route", selection: $scheduleVM.selectedStop.selectedRoute) {
                            ForEach(scheduleVM.routes, id: \.self) { route in
                                Text(route)
                            }
                        }
                        .onChange(of: scheduleVM.selectedStop.selectedRoute) { _ in
                            print(scheduleVM.selectedStop.selectedRoute)
                            scheduleVM.resetBusStops()
                        }
                        
                        Picker("Your Bus Stop", selection: $scheduleVM.selectedStop.selectedStop) {
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
                        Button("Reload Timelines") {
                            WidgetCenter.shared.reloadAllTimelines()
                        }
                        Button("Encode") {
                            scheduleVM.encodeToUserDefaults()
                        }
                        Button("Decode") {
                            DispatchQueue.main.async {
                                scheduleVM.selectedStop = scheduleVM.decodeFromUserDefaults()
                            }
                        }
                        Button("Print selectedStop") {
                            print(scheduleVM.selectedStop)
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(scheduleVM: ScheduleViewModel())
    }
}
