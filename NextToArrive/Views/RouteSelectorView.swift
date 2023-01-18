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
    @State var busStops = [40, 3046]
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section {
                        Picker("Route", selection: $scheduleVM.selectedRoute) {
                            ForEach(routes, id: \.self) { route in
                                Text(route)
                            }
                        }
                        .onChange(of: scheduleVM.selectedRoute) { _ in
                            scheduleVM.resetSchedule()
                        }
                        
                        Picker("Stop ID", selection: $scheduleVM.stopID) {
                            ForEach(busStops, id: \.self) { stop in
                                Text(String(stop))
                            }
                        }
                        .onChange(of: scheduleVM.stopID) { _ in
                            scheduleVM.resetSchedule()
                        }
                    }
                    
                    Section {
                        Text("About the developer")
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                Button("dismiss") {
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
