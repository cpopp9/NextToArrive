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
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), timeUntilArrival: 5, scheduleArrival: Date())
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, timeUntilArrival: 5, scheduleArrival: Date())
        completion(entry)
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        Task {
            var entries: [SimpleEntry] = []
            entries = try await downloadSchedule() ?? []
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }
    
    func downloadSchedule() async throws -> [SimpleEntry]? {
        
        guard let url = URL(string: "https://www3.septa.org/api/BusSchedules/index.php?stop_id=3046") else {
            print("Invalid URL")
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "mm/dd/yy hh:mm aa"
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            
            if let decodedResponse = try? decoder.decode(StopData.self, from: data) {
                
                var entries: [SimpleEntry] = []
                
                var previous = Date()
                
                for (_, value) in decodedResponse {
                    
                    for item in value {
                        let timeUntil = Calendar.current.dateComponents([.minute], from: previous, to: item.DateCalender).minute ?? 0
                        
                        previous = item.DateCalender
                        let date = Date().zeroSeconds!
                        
                        for minuteOffset in 0...timeUntil {
                            
                            
                            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: date)!
                            
                            let timeBefore = Calendar.current.dateComponents([.minute], from: entryDate, to: item.DateCalender).minute ?? 0
                            
                            let newEntry = SimpleEntry(date: entryDate, configuration: ConfigurationIntent(), timeUntilArrival: timeBefore, scheduleArrival: item.DateCalender)
                            entries.append(newEntry)
                        }
                    }
                }
                return entries
            }
            
        } catch let error {
            print("Invalid Data \(error)")
        }
        return nil
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let timeUntilArrival: Int
    let scheduleArrival: Date
}

struct SeptaWidgetTestWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(.green.gradient).ignoresSafeArea()
            VStack {
                HStack {
                    Text("RTE 2")
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
    let kind: String = "SeptaWidgetTestWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            SeptaWidgetTestWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemSmall])
    }
}

struct SeptaWidgetTestWidget_Previews: PreviewProvider {
    static var previews: some View {
        SeptaWidgetTestWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), timeUntilArrival: 5, scheduleArrival: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
