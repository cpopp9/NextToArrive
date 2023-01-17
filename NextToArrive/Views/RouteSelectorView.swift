//
//  RouteSelectorView.swift
//  NextToArrive
//
//  Created by Cory Popp on 1/17/23.
//

import SwiftUI

struct RouteSelectorView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Button("Dismiss") {
            dismiss()
        }
        .foregroundColor(.white)
    }
}

struct RouteSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        RouteSelectorView()
    }
}
