//
//  MapView.swift
//  JeMeSouviens
//
//  Created by TA Trung Thanh on 23/11/2018.
//  Copyright © 2018 TA Trung Thanh. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit
import MultiSelectSegmentedControl //3rd party library


class MyMap: UIView, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate, MultiSelectSegmentedControlDelegate {
    private let find = UIButton(type: .system)
    private let add = UIButton(type: .contactAdd)
    private let location = UITextView()
    
    private let CLmngr = CLLocationManager() //for location
    private let map = MKMapView() //for map
    private var cam : MKMapCamera? //for 3D
    // location in map need : latitude, longtitude
    // camera needs : orientation, altitude
    private var eagle_altitude = 50.0
    private var eagle_orientation = 120.0
    private var count = 1
    private var color = UIColor.orange
    private var zoom = 0
    
    //private let mapMode = UISegmentedControl(items: ["Map", "Satellite", "Mix"])
    private let mapMode = MultiSelectSegmentedControl(items: ["Map", "Satellite", "Mix", "3D"])
    
    override init(frame: CGRect) {
        find.setTitle("Where am i?", for: .normal)
        location.isSelectable = false
        location.isEditable = false
        location.text = "Where am i?"
        location.textAlignment = .center
        map.isScrollEnabled = true
        map.isZoomEnabled = true
        CLmngr.distanceFilter = 1.0 //Precision = 1m
        CLmngr.requestWhenInUseAuthorization()
        mapMode.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        mapMode.selectedSegmentIndexes = IndexSet([0])
        
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        find.addTarget(self, action: #selector(computePosition(_:)), for: .touchDown)
        add.addTarget(self, action: #selector(addPin(sender:)), for: .touchDown)
        mapMode.addTarget(self, action: #selector(changeMap(sender:)), for: .valueChanged)
        mapMode.delegate = self
        map.delegate = self
        CLmngr.delegate = self

        self.addSubview(find)
        self.addSubview(add)
        self.addSubview(location)
        self.addSubview(map)
        self.addSubview(mapMode)
        self.drawInSize(UIScreen.main.bounds.size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawInSize(_ size: CGSize) {
        var top = 20
        if UIDevice.current.userInterfaceIdiom == .phone && size.height >= 812 {
            top = 30
        }
        else if UIDevice.current.userInterfaceIdiom == .phone && size.width > size.height {
            top = 0
        }
        find.frame = CGRect(x: Int(size.width/2 - 50), y: top + 10, width: 100, height: 30)
        add.frame = CGRect(x: Int(size.width - 40), y: top + 10, width: 30, height: 30)
        location.frame = CGRect(x: 10, y: top+100, width: Int(size.width - 20), height: 60)
        mapMode.frame = CGRect(x: 20, y: top + 180, width: Int(size.width - 40), height: 30)
        map.frame = CGRect(x: 0, y: top + 160, width: Int(size.width), height: Int(size.height - 160))
    }
    
    @objc func computePosition(_ sender: Any) {
        NSLog("computePosition")
        location.text = "searching..."
        CLmngr.startUpdatingLocation()
    }
    
    @objc func addPin(sender: UIButton) {
        let a = AnAnnotation(c: map.centerCoordinate, t: String(format:"location %d", count), st: "fill me")
        count += 1
        map.addAnnotation(a)
    }
    
    @objc func changeMap(sender: MultiSelectSegmentedControl) {
        NSLog("changeMap")
        if sender.selectedSegmentIndexes == [0] { //Map mode
            setupCamera(is3D: false)
            map.mapType = .standard
        }
        if sender.selectedSegmentIndexes == [1] { //Satellite mode
            setupCamera(is3D: false)
            map.mapType = .satellite
        }
        if sender.selectedSegmentIndexes == [2] { //Mix mode
            setupCamera(is3D: false)
            map.mapType = .hybrid
        }
        
        if sender.selectedSegmentIndexes == [0, 3] { //Map mode in 3D
            print("3D standard")
            cam = nil
            setupCamera(is3D: true)
            map.mapType = .standard
        }
        if sender.selectedSegmentIndexes == [1, 3] { //Satellite mode in 3D
            print("3D Satellite")
            cam = nil
            setupCamera(is3D: true)
            map.mapType = .satelliteFlyover
        }
        if sender.selectedSegmentIndexes == [2, 3] { //Mix mode in 3D
            print("3D Mix")
            cam = nil
            setupCamera(is3D: true)
            map.mapType = .hybridFlyover
        }
        
        if cam != nil {
            map.camera = cam!
        }
    }
    
    func setupCamera(is3D: Bool) {
        let lat = map.centerCoordinate.latitude
        let lon = map.centerCoordinate.longitude
        let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        var viewPoint = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        if is3D {
            viewPoint = CLLocationCoordinate2D(latitude: lat - 0.01, longitude: lon)
        }
        let span = MKCoordinateSpan(latitudeDelta: 3, longitudeDelta: 3)
        
        print("location", location.latitude , location.longitude)
        print("viewPoint", viewPoint.latitude , viewPoint.longitude)
        map.setRegion(MKCoordinateRegion(center: location, span: span), animated: true)
        map.showsBuildings = true
        cam = MKMapCamera(lookingAtCenter: location, fromEyeCoordinate: viewPoint, eyeAltitude: eagle_altitude)
        cam?.heading = eagle_orientation
        map.camera = cam!
    }
    
    func nextColor (c: UIColor) -> UIColor {
        switch c {
        case .orange: return .red
        case .red: return .blue
        case .blue: return .green
        case .green: return .black
        case .black: return .purple
        default: return .orange
        }
    }
    
    // CLLocationManagerDelegate protocol
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location.text = manager.location?.description
        CLmngr.stopUpdatingLocation() //Only one mesure
        // Map update
        let span = MKCoordinateSpan(latitudeDelta: 0.035, longitudeDelta: 0.035)
        let region = MKCoordinateRegion(center: (manager.location?.coordinate)!, span: span)
        map.setRegion(region, animated: true)
        map.showsUserLocation = true // Add a pin on the current location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        location.text = error.localizedDescription
    }
    
    // MKMapViewDelegate protocol
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let epingle = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "BaTe")
        epingle.pinTintColor = color
        color = nextColor(c: color)
        epingle.canShowCallout = true
        epingle.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        return epingle
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) { //when tap on the (i) button
        location.text = "Coordinate of -" + (view.annotation?.title!)! + "-"
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) { //
        location.text = "You selected -" + (view.annotation?.title!)! + "-"
    }
    /*
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let zoomWidth = mapView.visibleMapRect.size.width
        zoom = Int(log2(zoomWidth)) - 7
        print(mapView.visibleMapRect.size.width, mapView.visibleMapRect.size.height)
        print("...REGION DID CHANGE: ZOOM FACTOR \(zoom)")
    }*/
    
    // MultiSelectSegmentedControlDelegate protocol
    func multiSelect(_ multiSelectSegmentedControl: MultiSelectSegmentedControl, didChangeValue value: Bool, at index: UInt) {
        if index == 0 {
            mapMode.selectedSegmentIndexes.remove(1)
            mapMode.selectedSegmentIndexes.remove(2)
        }
        if index == 1 {
            mapMode.selectedSegmentIndexes.remove(0)
            mapMode.selectedSegmentIndexes.remove(2)
        }
        if index == 2 {
            mapMode.selectedSegmentIndexes.remove(1)
            mapMode.selectedSegmentIndexes.remove(0)
        }
    }
    
}
