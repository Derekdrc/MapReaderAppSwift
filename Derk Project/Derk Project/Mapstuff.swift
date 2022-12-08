//
//  Mapstuff.swift
//  Map Reader Project
//
//

import MapKit
import SwiftUI
import CoreLocation
import CoreLocationUI

struct Map: View {
    @StateObject var locationManager = LocationManager()

    @State var directions: [String] = [String]()
    @State var showDirections: Bool = false
    @State var loc: CLLocationCoordinate2D? = nil
    @State var lat: Double = 42.36
    @State var lon: Double = -71.05
    @State var showMap: Bool = false

    
    var body: some View {
        VStack {
            if let _ = loc {
                HStack {
                    Text("Latitude")
                    TextField("Latitude", value: $lat, formatter: NumberFormatter())
                    Spacer()
                    Text("Longitude")
                    TextField("Longitude", value: $lon, formatter: NumberFormatter())
                }
                Button("Navigate") {
                    showMap.toggle()
                }
                if showMap {
                    MapView(directions: $directions, loc: $loc, lat: $lat, lon: $lon)
                }
            }
            LocationButton {
                locationManager.requestLocation()
            }
            .frame(height: 44)
            .padding()
            Button(action: {
                self.showDirections.toggle()
            }, label: {
                Text("Show directions")
            })
            .disabled(directions.isEmpty)
            .padding()
        }
        .onChange(of: locationManager.updated) { _ in
            loc = locationManager.location
        }
        .sheet(isPresented: $showDirections, content: {
            VStack(spacing: 0) {
                Text("Directions")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                
                Divider().background(Color.blue)
                
                List(0..<self.directions.count, id: \.self) { i in
                    Text(self.directions[i]).padding()
                }
            }
        }
               )
    }
}

struct MapView: UIViewRepresentable {
    @Binding var directions: [String]
    @Binding var loc: CLLocationCoordinate2D!
    @Binding var lat: Double
    @Binding var lon: Double
    
    typealias UIViewType = MKMapView
    
    func makeCoordinator() -> MapViewCoordinator {
        return MapViewCoordinator()
      }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        let lat = loc.latitude
        let lon = loc.longitude
        
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
        mapView.setRegion(region, animated: true)
        
        let p1 = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
        
        let p2 = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: self.lat, longitude: self.lon))
        
        print("Getting directions to \(lat) \(lon)")
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: p1)
        request.destination = MKMapItem(placemark: p2)
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first else { return }
            mapView.addAnnotations([p1, p2])
            mapView.addOverlay(route.polyline)
            mapView.setVisibleMapRect(
                route.polyline.boundingMapRect,
                edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20),
                animated: true)
            self.directions = route.steps.map { $0.instructions }.filter { !$0.isEmpty }
        }
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {}
    
    class MapViewCoordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 5
            return renderer
        }
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()

    @Published var location: CLLocationCoordinate2D?
    @Published var updated: Bool = false

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestLocation() {
        manager.requestLocation()
        print("Requested location")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
        updated.toggle()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting local")
    }
}
