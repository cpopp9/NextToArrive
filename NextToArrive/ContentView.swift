    //
    //  ContentView.swift
    //  NextToArrive
    //
    //  Created by Cory Popp on 1/3/23.
    //

import SwiftUI

struct ContentView: View {
    @State private var timeRemaining = 5
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    let nextScheduled = "01:41p"
    
    
    var body: some View {
        ZStack {
            Color.green.ignoresSafeArea()
            
            VStack {
                Text("\(timeRemaining) minutes")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                Text("Until the next bus")
                    .foregroundColor(.white)
                
                Text("-")
                    .foregroundColor(.white)
                
                Text("Scheduled to arrive at \(nextScheduled)")
                    .foregroundColor(.white)
                
                Button() {
                    dateFormatter()
                } label: {
                    Text("Format Date")
                        .foregroundColor(.white)
                }
            }
            .onReceive(timer) { time in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                }
            }
            
            .padding()
        }
    }
    
    func dateFormatter() {
        
        let dateFormatter = DateFormatter()
        
            // Set Date Format
        dateFormatter.dateFormat = "hh:mm"
        
            // Convert String to Date
        dateFormatter.date(from: nextScheduled)
    }
    
    
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
