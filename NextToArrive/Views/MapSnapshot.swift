    //
    //  MapSnapshot.swift
    //  NextToArrive
    //
    //  Created by Cory Popp on 3/6/23.
    //

import MapKit
import SwiftUI

struct MapSnapshot: View {
    @State var snapshotImage: UIImage?
    
    var body: some View {
            Section("Map") {
                if let image = snapshotImage {
                    Image(uiImage: image)
                        .frame(maxWidth: .infinity)
                }
            }
    }
    
    func snapshotGenerator(location: CLLocationCoordinate2D, width: CGFloat, height: CGFloat) {
        
        let options = MKMapSnapshotter.Options()
        
        options.camera = MKMapCamera(lookingAtCenter: location, fromDistance: 500, pitch: 0, heading: 0)
        options.mapType = .standard
        options.size = CGSize(width: width, height: height)
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start() { snapshot, _ in
            let mapImage = snapshot?.image
            let finalImage = UIGraphicsImageRenderer(size: options.size).image { _ in
                mapImage?.draw(at: .zero)
                let pinView = MKPinAnnotationView(annotation: nil, reuseIdentifier: nil)
                let pinImage = pinView.image
                let point = snapshot?.point(for: location)
                pinImage?.draw(at: point!)
            }
            self.snapshotImage = finalImage
            print("Success")
        }
        
        
    }
    
    init(location: CLLocationCoordinate2D) {
        
        snapshotGenerator(location: location, width: 600, height: 300)
    }
    
}

    //struct MapSnapshot_Previews: PreviewProvider {
    //    static var previews: some View {
    //        MapSnapshot()
    //    }
    //}
