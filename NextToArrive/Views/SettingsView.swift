    //
    //  RouteSelectorView.swift
    //  NextToArrive
    //
    //  Created by Cory Popp on 1/17/23.
    //

import MapKit
import SwiftUI
import WidgetKit

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var scheduleVM: ContentViewModel
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                
                List {
                    Section("Select Your Local Bus Stop") {
                        
                        Picker("Route", selection: $scheduleVM.selectedStop.route) {
                            ForEach(scheduleVM.routes, id: \.self) { route in
                                Text(route)
                            }
                        }
                        .onChange(of: scheduleVM.selectedStop.route) { _ in
                            print(scheduleVM.selectedStop.route)
                            scheduleVM.overwriteSelectedRoute()
                        }
                        
                        Picker("Stop", selection: $scheduleVM.selectedStop.stop) {
                            ForEach(self.scheduleVM.busStops, id:\.stopid) { (stop: BusStop) in
                                Text(stop.stopname).tag(stop)
                            }
                        }
                        .onChange(of: scheduleVM.selectedStop) { _ in
                            scheduleVM.overwriteSelectedStop()
                        }
                    }
                    
                    NavigationLink {
                        MapView(mapLocation: scheduleVM.mapLocation, location: scheduleVM.location)
                    } label: {
                        MapSnapshot(snapshotImage: scheduleVM.snapshotImage)
                    }
                    .listRowInsets(EdgeInsets(top: -20, leading: 0, bottom: -20, trailing: 0))
                    .animation(.easeIn)
                    
                    Section("About") {
                        Link("About the Developer", destination: URL(string: "https://www.linkedin.com/in/coryjpopp/")!)
                            .foregroundColor(.white)
                    }
                }
                
            }
            .navigationTitle("My Stop")
            .toolbar {
                Button("Dismiss") {
                    dismiss()
                }
                .foregroundColor(.white)
            }
        }
        .accentColor(.white)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(scheduleVM: ContentViewModel())
    }
}
