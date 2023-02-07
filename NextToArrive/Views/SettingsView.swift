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
    @ObservedObject var scheduleVM: ContentViewModel
    
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
                            scheduleVM.overwriteStops()
                        }
                        
                        Picker("Your Bus Stop", selection: $scheduleVM.selectedStop.selectedStop) {
                            ForEach(self.scheduleVM.busStops, id:\.stopid) { (stop: BusStops) in
                                Text(stop.stopname).tag(stop)
                            }
                        }
                        .onChange(of: scheduleVM.selectedStop) { _ in
                            scheduleVM.overwriteRoute()
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
        SettingsView(scheduleVM: ContentViewModel())
    }
}
