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
    
    @State var currentTime = Date().displayFormat
    @State var nextScheduled = Date().displayFormat
    
    let nextScheduledString = "9:49"
    
    
    var body: some View {
        ZStack {
            Color.green.ignoresSafeArea()
            
            VStack {
                
                Spacer()
                
                Text("\(timeRemaining) minutes")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                Text("Until the next bus")
                    .foregroundColor(.white)
                
                Text("-")
                    .foregroundColor(.white)
                
                Text("next scheduled: \(nextScheduled)")
                    .foregroundColor(.white)
                
                Text("current time: \(currentTime)")
                    .foregroundColor(.white)
                
                Spacer()
                
                Button() {
                    dateFormatter()
                } label: {
                    Text("Format Date")
                        .foregroundColor(.white)
                }
                Button("Compare") {
                    compareTimes()
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
        
            //            // Set Date Format
        dateFormatter.dateFormat = "hh:mm"
        
            //            // Convert String to Date
        nextScheduled = dateFormatter.date(from: nextScheduledString)?.displayFormat ?? Date().displayFormat
        
        currentTime = Date.now.displayFormat
        
    }
    
    func compareTimes() {
        if currentTime < nextScheduled {
            print("True")
        } else {
            print("False")
        }
    }
    
    
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension Date {
    var displayFormat: String {
        self.formatted(
            .dateTime
            .hour(.conversationalDefaultDigits(amPM: .abbreviated))
            .minute())
    }
}
