    //
    //  ContentView.swift
    //  NextToArrive
    //
    //  Created by Cory Popp on 1/3/23.
    //

import SwiftUI


struct ContentView: View {
    
    @StateObject var scheduleVM = ScheduleViewModel()
    
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.green.ignoresSafeArea()
                VStack {
                    VStack(alignment: .leading) {
                        Text("Route \(scheduleVM.routeID)")
                            .font(.largeTitle.bold())
                            .animation(.easeIn)
                        Text(scheduleVM.stopLocation)
                            .font(.subheadline)
                            .animation(.easeIn)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    
                    Spacer()
                    HStack {
                        Text(String(scheduleVM.timeUntilArrival))
                            .font(.system(size: 100).bold())
                            .animation(.easeIn)
                        Text("Minutes")
                            .font(.title3.bold())
                    }
                    Text("Until the next bus")
                        .onReceive(timer) { time in
                            scheduleVM.refreshSchedule()
                        }
                    Spacer()
                    Text(scheduleVM.nextArrivingAt)
                        .animation(.easeIn)
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
//                    Link("Find", destination: URL(string: "https://www5.septa.org/travel/find-my-stop/")!)
//                        .foregroundColor(.white)
                    Button("press") {
                        print("\(scheduleVM.timeUntilArrival) minutes remaining")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button() {
                        scheduleVM.resetSchedule()
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .task {
            scheduleVM.refreshSchedule()
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
