////
////  RouteView.swift
////  NextToArrive
////
////  Created by Cory on 7/26/23.
////
//
//import SwiftUI
//
//struct RouteView: View {
//    let routeNumber: String
//    let stopName: String
//    
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            
//            Text("Route \(scheduleVM.selectedStop.route)")
//                .font(.largeTitle.bold())
//                .animation(.easeIn)
//                .onReceive(timer) { time in
//                    if showingOptionsSheet == false {
//                        scheduleVM.refreshSchedule()
//                    }
//                }
//            
//            NavigationLink {
//                MapView(mapLocation: scheduleVM.mapLocation, location: scheduleVM.location)
//            } label: {
//                HStack {
//                    Text(scheduleVM.selectedStop.stop.stopname)
//                        .font(.subheadline)
//                        .animation(.easeIn)
//                    Image(systemName: "location.fill")
//                        .font(.subheadline)
//                }
//            }
//            
//        }
//        .frame(maxWidth: .infinity, alignment: .leading)
//    }
//}
//
//struct RouteView_Previews: PreviewProvider {
//    static var previews: some View {
//        RouteView()
//    }
//}
