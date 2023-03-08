    //
    //  MapSnapshot.swift
    //  NextToArrive
    //
    //  Created by Cory Popp on 3/6/23.
    //

import MapKit
import SwiftUI

struct MapSnapshot: View {
    let snapshotImage: UIImage?
    
    var body: some View {
        VStack {
            if let image = snapshotImage {
                Image(uiImage: image)
            }
        }
    }
    
}

struct MapSnapshot_Previews: PreviewProvider {
    static var previews: some View {
        MapSnapshot(snapshotImage: nil)
    }
}
