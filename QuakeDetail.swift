//
//  QuakeDetail.swift
//  Earthquakes-iOS
//
//  Created by Wasitul Hoque on 30/5/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import SwiftUI
import MapKit

struct QuakeDetail: View {
    var quake: Quake
    @EnvironmentObject private var quakesProvider: QuakesProvider
    @State private var location: QuakeLocation? = nil
    @State private var showMap = false;
    @State private var applePay = false;
    @State private var goScreen = false;
    @StateObject var myViewModel = MyMapViewModel()
    @State private var imageOffset: CGFloat = 0
    var body: some View {
        if (showMap == false) {
            VStack {
                ZStack {
                    if let location = self.location {
                        QuakeDetailMap(location: location, tintColor: quake.color)
                            .ignoresSafeArea(.container)
                    }
                    VStack {
                        Toggle(isOn: $showMap) {
                            HStack { Spacer()
                                Text("Show Map").fontWeight(.semibold)
                                    .padding()
                                    .overlay(RoundedRectangle(cornerRadius: 25).fill(Color.gray).opacity(0.2).shadow(radius: 7))
                                
                            }
                        }
                        .padding()
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                        .padding()
                    }.offset(y: -260)

                }
                QuakeMagnitude(quake: quake)
                Text(quake.place)
                    .font(.title3)
                    .bold()
                Text("\(quake.time.formatted())")
                    .foregroundStyle(Color.secondary)
                if let location = self.location {
                    Text("Latitude: \(location.latitude.formatted(.number.precision(.fractionLength(3))))")
                    Text("Longitude: \(location.longitude.formatted(.number.precision(.fractionLength(3))))")
                }

            }
            .task {
                if self.location == nil {
                    if let quakeLocation = quake.location {
                        self.location = quakeLocation
                    } else {
                        self.location = try? await quakesProvider.location(for: quake)
                    }
                }
            }
        }
        if (showMap == true) {
            if (goScreen == false && applePay == false) {
                ZStack {
                    Map(coordinateRegion: $myViewModel.destinationRegion, showsUserLocation: true)
                        .accentColor(Color.blue)
                        .ignoresSafeArea(.all , edges: .all)
                        .onAppear {
                            myViewModel.checkifLocationAvailable()
                    }
                        .blur(radius: 20)
                    VStack(spacing: -15) {
                        Button(action: {goScreen = true}) {
                            Text("Show Route")
                                .fontWeight(.semibold)
                                    .padding()
                                    .overlay(RoundedRectangle(cornerRadius: 25).fill(Color.white).opacity(0.15).shadow(radius: 7))
                        }
                        .padding()
                        .font(.system(size: 22))
                        .foregroundColor(.black)
                    .padding()
                        Button(action: {applePay = true}) {
                            HStack(spacing: -20) {
                                Text("Donate with")
                                    .fontWeight(.semibold)
                                        .padding()
                                Image(systemName: "applelogo")
                                        .padding()
                                Text("Pay")
                                    .fontWeight(.semibold)
                                    .padding()
                            }
                            .overlay(RoundedRectangle(cornerRadius: 25).fill(Color.white).opacity(0.15).shadow(radius: 7))
                        }
                        .padding()
                        .font(.system(size: 22))
                        .foregroundColor(.black)
                    .padding()
                    }
                }
            }
            if (goScreen == true) {
                MapScreen(region: $myViewModel.region, destinationRegion: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location?.latitude ?? 0, longitude: location?.longitude ?? 0), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)))
            }
            if (applePay == true) {
                AmountView()
            }
//
//            Map(coordinateRegion: $myViewModel.destinationRegion , showsUserLocation: true)
//                .accentColor(Color.blue)
//                .ignoresSafeArea(.all , edges: .all)
//                .onAppear {
//                    myViewModel.checkifLocationAvailable()
//                }
        }
    }
}

struct QuakeDetail_Previews: PreviewProvider {
    static var previews: some View {
        QuakeDetail(quake: Quake.preview)
    }
}

final class MyMapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @State var presidioEntry = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.79190, longitude: -122.44776),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.79190, longitude: -122.44776),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
    @Published var destinationRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.79190, longitude: -122.44776),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )

    var locationManager: CLLocationManager?

    func checkifLocationAvailable() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager!.delegate = self

        }
        else {
            print("Location access denied.")
        }
    }




    func checkLocationAllowed() {
        guard let locationManager = locationManager else { return }

        switch locationManager.authorizationStatus {

        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("Location access denied.")
        case .denied:
            print("Location access denied.")
        case .authorizedAlways:
            region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: locationManager.location?.coordinate.latitude ?? 0, longitude: locationManager.location?.coordinate.longitude ?? 0), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
            destinationRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: destinationRegion.center.latitude, longitude: destinationRegion.center.longitude), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
        case .authorizedWhenInUse:
            region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: locationManager.location?.coordinate.latitude ?? 0, longitude: locationManager.location?.coordinate.longitude ?? 0), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
            destinationRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: destinationRegion.center.latitude, longitude: destinationRegion.center.longitude), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
        @unknown default:
            break
        }
    }


    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAllowed()
    }
}
