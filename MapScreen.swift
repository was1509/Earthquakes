//
//  MapScreen.swift
//  Earthquakes-iOS
//
//  Created by Wasitul Hoque on 30/5/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import SwiftUI
import MapKit

struct MapScreen: View {
    var mapViewFirst: MKMapView!
    @State private var returnToMapView = false
    @Binding var region: MKCoordinateRegion
    @State var destinationRegion: MKCoordinateRegion
    var body: some View {
        if returnToMapView == true {
            //MapView()
        }
        else {
            ZStack {
                // Show Map
                mapView(region: $region, destinationRegion: $destinationRegion)
                    .ignoresSafeArea(.all , edges: .all)

//                HStack {
//                    VStack {
//                        Button(action: {returnToMapView = true}) {
//                            Text("\(Image(systemName: "chevron.backward")) Back")
//                                .foregroundColor(.blue)
//                                .fontWeight(.semibold)
//                                .font(.system(size: 20))
//                        }
//                        Spacer()
//                    }
//                    Spacer()
//                }.padding()
            }
        }
    }
}

struct MapScreen_Previews: PreviewProvider {
    static var previews: some View {
        MapScreen(region: .constant(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.79190, longitude: -122.44776),
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        )), destinationRegion: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.79190, longitude: -122.44776),
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        ))
    }
}

struct mapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var destinationRegion: MKCoordinateRegion
    func makeCoordinator() -> Coordinator {
        return mapView.Coordinator()
    }
    func makeUIView(context: UIViewRepresentableContext<mapView>) -> MKMapView {
        let map = MKMapView()
        let startingPoint = CLLocationCoordinate2D(latitude: CLLocationDegrees(region.center.latitude), longitude: CLLocationDegrees(region.center.longitude))


        let destinationPoint = CLLocationCoordinate2D(latitude: destinationRegion.center.latitude, longitude: destinationRegion.center.longitude)

        let sourceMarker = MKPointAnnotation()
        sourceMarker.coordinate = startingPoint
        sourceMarker.title = "Start"
        map.addAnnotation(sourceMarker)

        let destinationMarker = MKPointAnnotation()
        destinationMarker.coordinate = destinationPoint
        destinationMarker.title = "End"
        map.addAnnotation(destinationMarker)

        map.region = region
        map.delegate = context.coordinator

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: startingPoint))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationPoint))

        let direction = MKDirections(request: request)

        direction.calculate { (response , error) in

            if error != nil  {
                //
            }

            let polyline = response?.routes.first?.polyline
            map.addOverlay(polyline!)
            map.setRegion(MKCoordinateRegion(polyline!.boundingMapRect), animated: true)
            map.showsUserLocation = true

        }
        return map
    }

    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<mapView>) {

    }

    class Coordinator: NSObject,MKMapViewDelegate {

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .blue
            renderer.lineWidth = 3

            return renderer
        }
    }

}
