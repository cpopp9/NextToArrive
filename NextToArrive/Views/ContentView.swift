    //
    //  ContentView.swift
    //  NextToArrive
    //
    //  Created by Cory Popp on 1/3/23.
    //

import SwiftUI


struct ContentView: View {
    
    @StateObject var scheduleVM = ScheduleViewModel()
    @State private var showingSheet = false
    
    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.green.ignoresSafeArea()
                VStack {
                    VStack(alignment: .leading) {
                        Text("Route \(scheduleVM.selectedRoute)")
                            .font(.largeTitle.bold())
                            .animation(.easeIn)
                        Text(scheduleVM.selectedStop.stopname)
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
                            if showingSheet == false {
                                Task {
                                    await scheduleVM.downloadSchedule()
                                }
                            }
                        }
                    Spacer()
                    Text(scheduleVM.nextArrivingAt)
                        .animation(.easeIn)
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button() {
                        showingSheet.toggle()
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.white)
                    }
                    .sheet(isPresented: $showingSheet) {
                        RouteSelectorView(scheduleVM: scheduleVM)
                    }
                }
            }
        }
        .task {
            await scheduleVM.downloadStops()
            await scheduleVM.downloadSchedule()
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
