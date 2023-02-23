    //
    //  SeptaWidgetTestWidget.swift
    //  SeptaWidgetTestWidget
    //
    //  Created by Cory Popp on 1/27/23.
    //

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), timeUntilArrival: 5, scheduleArrival: Date(), route: SelectedStop.exampleStop.route)
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, timeUntilArrival: 5, scheduleArrival: Date(), route: SelectedStop.exampleStop.route)
        completion(entry)
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        let scheduleVM = WidgetViewModel()
        let selectedStop = scheduleVM.decodeFromUserDefaults()
        
        Task {
            var entries: [SimpleEntry] = []
            var previousTime = Date()
            
            let busTimes = await scheduleVM.downloadSchedule(stopID: selectedStop.stop.stopid, route: selectedStop.route)
            
            for time in busTimes {
                let timeUntil = Calendar.current.dateComponents([.minute], from: previousTime, to: time).minute ?? 0
                
                previousTime = time
                let date = Date().zeroSeconds!
                
                for minuteOffset in 0..<timeUntil {
                    let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: date)!
                    let timeBefore = Calendar.current.dateComponents([.minute], from: entryDate, to: time).minute ?? 0
                    let newEntry = SimpleEntry(date: entryDate, configuration: ConfigurationIntent(), timeUntilArrival: timeBefore, scheduleArrival: time, route: selectedStop.route)
                    entries.append(newEntry)
                }
            }
            
            
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
            print("Timeline Reloaded")
        }
        
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let timeUntilArrival: Int
    let scheduleArrival: Date
    let route: String
}

struct SeptaWidgetTestWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(.green.gradient).ignoresSafeArea()
            VStack {
                HStack {
                    Text("RTE \(entry.route)")
                        .foregroundColor(.white)
                        .font(.caption)
                        .padding(.leading, 15)
                    
                    Spacer()
                    Text(entry.scheduleArrival.formatted(.dateTime.hour().minute()))
                        .foregroundColor(.white)
                        .font(.caption)
                        .padding(.trailing, 15)
                }.padding(.top, -25)
                VStack {
                    Text(String(entry.timeUntilArrival))
                        .foregroundColor(.white)
                        .font(.system(size: 60).bold())
                        .padding(.bottom, -20)
                    Text("Minutes")
                        .foregroundColor(.white)
                }
            }
        }
    }
}

@main
struct SeptaWidgetTestWidget: Widget {
    let kind: String = "Next to Arrive"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            SeptaWidgetTestWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Septa Tracker")
        .description("Bus schedules at a quick glance")
        .supportedFamilies([.systemSmall])
    }
}

struct SeptaWidgetTestWidget_Previews: PreviewProvider {
    static var previews: some View {
        SeptaWidgetTestWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), timeUntilArrival: 5, scheduleArrival: Date(), route: SelectedStop.exampleStop.route))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
