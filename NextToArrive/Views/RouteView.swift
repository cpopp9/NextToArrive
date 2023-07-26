//
//  RouteView.swift
//  NextToArrive
//
//  Created by Cory on 7/26/23.
//

import MapKit
import SwiftUI

struct RouteView: View {
    let routeNumber: String
    let stopName: String
    let location: CLLocationCoordinate2D
    
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("Route \(routeNumber)")
                .font(.largeTitle.bold())
                .animation(.easeIn)
            
            NavigationLink {
                MapView(location: location)
                Text("Map View")
            } label: {
                HStack {
                    Text(stopName)
                        .font(.subheadline)
                        .animation(.easeIn)
                    Image(systemName: "location.fill")
                        .font(.subheadline)
                }
            }
            
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
}

struct RouteView_Previews: PreviewProvider {
    static var previews: some View {
        RouteView(routeNumber: "2", stopName: "9th & Mifflin", location: Location.exampleLocation.coordinate)
    }
}
