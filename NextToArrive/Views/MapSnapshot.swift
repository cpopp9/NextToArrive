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
    var location: CLLocationCoordinate2D
    
    var body: some View {
        VStack {
            if let image = snapshotImage {
                Image(uiImage: image)
            }
        }
        .task {
            snapshotGenerator(width: 400, height: 200)
        }
    }
    
    func snapshotGenerator(width: CGFloat, height: CGFloat) {
        
        let options = MKMapSnapshotter.Options()
        
        options.camera = MKMapCamera(lookingAtCenter: location, fromDistance: 250, pitch: 0, heading: 0)
        options.mapType = .standard
        options.size = CGSize(width: width, height: height)
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start() { snapshot, _ in
            let mapImage = snapshot?.image
            let finalImage = UIGraphicsImageRenderer(size: options.size).image { _ in
                mapImage?.draw(at: .zero)
                let pinView = MKPinAnnotationView(annotation: nil, reuseIdentifier: nil)
                let pinImage = pinView.image
                
                pinView.centerOffset = CGPointMake(0,-15)
                
                let point = snapshot?.point(for: location)
                
                
                
                
//                pinImage?.draw(at: CGPoint(x:190, y:65))
                pinImage?.draw(at: point!)
//                pinImage?.draw(at: pinView.center)
            }
            self.snapshotImage = finalImage
        }
        
        
    }
    
    init(location: CLLocationCoordinate2D) {
        
        self.location = location
        
//        snapshotGenerator(width: 600, height: 300)
    }
    
}

    //struct MapSnapshot_Previews: PreviewProvider {
    //    static var previews: some View {
    //        MapSnapshot()
    //    }
    //}
