//
//  TimeView.swift
//  NextToArrive
//
//  Created by Cory Popp on 2/21/23.
//

import SwiftUI

struct TimeView: View {
    let timeUntil: Int?
    
    var timeProvided: Bool {
        if timeUntil != nil {
            return true
        }
        return false
    }
    
    var body: some View {
        
        VStack {
            HStack {
                Text(timeProvided ? String(timeUntil!) : "-")
                    .font(.system(size: 100).bold())
                    .animation(.easeIn)
                Text(timeProvided ? "Minutes" : "")
                    .font(.title3.bold())
                    .animation(.easeIn)
            }
            Text(timeProvided ? "Until the next bus" : "")
                .animation(.easeIn)
        }
    }
}

struct TimeView_Previews: PreviewProvider {
    static var previews: some View {
        TimeView(timeUntil: 10)
    }
}
