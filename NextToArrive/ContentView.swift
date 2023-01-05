    //
    //  ContentView.swift
    //  NextToArrive
    //
    //  Created by Cory Popp on 1/3/23.
    //

import SwiftUI


struct ContentView: View {
    
    var busTime = "01:18p"
    
    var body: some View {
        ZStack {
            Color.green.ignoresSafeArea()
            
            VStack {
                
                Spacer()
                
                HStack {
                    Text(String(compareTimes(busTime: busTime)))
                        .font(.system(size: 100).bold())
                    Text("Minutes")

                        .font(.title3.bold())
                }
                Text("Until the next bus")
                
                Spacer()
                
                Text("Scheduled to arrive at \(busTime)")
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
