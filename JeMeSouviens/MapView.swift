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

class MyMap: UIView, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate {
    private let find = UIButton(type: .system)
    private let add = UIButton(type: .contactAdd)
    private let location = UITextView()
    
    private let CLmngr = CLLocationManager() //for location
    private let map = MKMapView() //for map
    private var cam : MKMapCamera? //for 3D
    // location in map need : latitude, longtitude
    // camera needs : orientation, altitude

    private var count = 1
    private var color = UIColor.orange
    private let mapMode = UISegmentedControl(items: ["Map", "Satellite", "Mix", "3D"])
    
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
        mapMode.selectedSegmentIndex = 0
        
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        find.addTarget(self, action: #selector(computePosition(sender:)), for: .touchDown)
        add.addTarget(self, action: #selector(addPin(sender:)), for: .touchDown)
        mapMode.addTarget(self, action: #selector(changeMap(sender:)), for: .valueChanged)
        map.delegate = self
        CLmngr.delegate = self

        self.addSubview(find)
        self.addSubview(add)
        self.addSubview(location)
        self.addSubview(mapMode)
        self.addSubview(map)
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
    
    @objc func computePosition(sender: UIButton) {
        NSLog("computePosition")
        location.text = "I am searching..."
        CLmngr.startUpdatingLocation()
    }
    
    @objc func addPin(sender: UIButton) {
        let a = AnAnnotation(c: map.centerCoordinate, t: String(format:"location %d", count), st: "fill me")
        count += 1
        map.addAnnotation(a)
    }
    
    @objc func changeMap(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            map.mapType = .standard
        }
        if sender.selectedSegmentIndex == 1 {
            map.mapType = .satellite
        }
        if sender.selectedSegmentIndex == 2 {
            map.mapType = .hybrid
        }
        if sender.selectedSegmentIndex == 3 {
            map.mapType = .hybrid
        }
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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        location.text = "Coordinate of -" + (view.annotation?.title!)! + "-"
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        location.text = "You selected -" + (view.annotation?.title!)! + "-"
    }
}
