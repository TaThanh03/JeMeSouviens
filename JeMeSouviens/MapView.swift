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
import UIKit
import MultiSelectSegmentedControl //3rd party library
import Contacts
import ContactsUI


class MyMap: UIView { //UITextFieldDelegate
    private var listPeople = [People]()
    private var currentPeople = People()
    //add, delete, home, contact, camera, folder
    private let toolbar = UIToolbar();
    private let toolbar_add = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
    private let toolbar_trash = UIBarButtonItem(barButtonSystemItem: .trash, target: nil, action: nil)
    private let toolbar_home = UIBarButtonItem(barButtonSystemItem: .refresh, target: nil, action: nil)
    private let toolbar_contact = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: nil, action: nil)
    private let toolbar_camera = UIBarButtonItem(barButtonSystemItem: .camera, target: nil, action: nil)
    private let toolbar_folder = UIBarButtonItem(barButtonSystemItem: .organize, target: nil, action: nil)
    
    // Location in map need : latitude, longtitude
    // Camera needs : orientation, altitude
    private let CLmngr = CLLocationManager() //for location
    private let map = MKMapView() //for map
    private let mapMode = MultiSelectSegmentedControl(items: ["Map", "Satellite", "Mix", "3D"])
    private var cam : MKMapCamera? //for 3D
    private var eagle_altitude = 50.0
    private var eagle_orientation = 50.0
    private var count = 1
    private var color = UIColor.orange
    private var zoom = 0
    private var previousMapRect = MKMapRect()
    
    //Photo
    private var aPicture = UIImageView()
    private var isShowPhoto = false
    
    //Contact
    private let contactsC = CNContactPickerViewController()
    private let contactsS = CNContactStore()
    private var contactVC : CNContactViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        //ToolBar
        let espace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        espace.width = 10
        let varEspace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace ,target: nil, action: nil)
        toolbar.items = [toolbar_add, espace, toolbar_trash, varEspace, toolbar_home, varEspace, toolbar_contact, espace, toolbar_camera, espace, toolbar_folder]
        enableToolBar(turnOn: false)
        toolbar_home.target = self.superview
        toolbar_home.action = #selector(computePosition(_:))
        toolbar_add.target = self.superview
        toolbar_add.action = #selector(addPin(sender:))
        toolbar_contact.target = self.superview
        toolbar_contact.action = #selector(searchContact)
        toolbar_folder.target = self.superview
        toolbar_folder.action = #selector(doSelectPhoto)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            NSLog( "Camera OK!")
            toolbar_camera.target = self.superview
            toolbar_camera.action = #selector(doTakePhoto)
        }
        //PhotoView
        aPicture.backgroundColor = .lightGray
        // Map and Location
        map.isScrollEnabled = true
        map.isZoomEnabled = true
        map.showsCompass = false
        CLmngr.distanceFilter = 1.0 //Precision = 1m
        CLmngr.requestWhenInUseAuthorization()
        mapMode.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        mapMode.selectedSegmentIndexes = IndexSet([2])
        mapMode.delegate = self
        map.delegate = self
        CLmngr.delegate = self
        self.addSubview(aPicture)
        self.addSubview(map)
        self.addSubview(mapMode)
        self.addSubview(toolbar)
        self.drawInSize(UIScreen.main.bounds.size)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawInSize(_ size: CGSize) {
        var top = 20
        let tbar = 44
        if UIDevice.current.userInterfaceIdiom == .phone && size.height >= 450 {
            top = 30
            if isShowPhoto {
                aPicture.isHidden = false
                map.frame = CGRect(x: 0, y: top, width: Int(size.width), height: Int(size.height/2))
                aPicture.frame = CGRect(x: 0, y: Int(size.height/2), width: Int(size.width), height: Int(size.height/2))
                mapMode.frame = CGRect(x: 20, y: top + 20, width: Int(size.width - 40), height: 30)
                toolbar.frame = CGRect(x: 0, y: Int(size.height) - tbar, width: Int(size.width), height: tbar)
            } else {
                aPicture.isHidden = true
                map.frame = CGRect(x: 0, y: top, width: Int(size.width), height: Int(size.height))
                mapMode.frame = CGRect(x: 20, y: top + 20, width: Int(size.width - 40), height: 30)
                toolbar.frame = CGRect(x: 0, y: Int(size.height) - tbar, width: Int(size.width), height: tbar)
            }
        } else if UIDevice.current.userInterfaceIdiom == .phone && size.width > size.height {
            top = 0
            if isShowPhoto {
                aPicture.isHidden = false
                map.frame = CGRect(x: 0, y: top, width: Int(size.width/2), height: Int(size.height))
                aPicture.frame = CGRect(x: Int(size.width/2), y: top, width: Int(size.width/2), height: Int(size.height))
                mapMode.frame = CGRect(x: 10, y: top + 10, width: Int(size.width/2 - 20), height: 30)
                toolbar.frame = CGRect(x: 0, y: Int(size.height) - tbar, width: Int(size.width/2), height: tbar)
            } else {
                aPicture.isHidden = true
                map.frame = CGRect(x: 0, y: top, width: Int(size.width), height: Int(size.height))
                mapMode.frame = CGRect(x: 20, y: top + 20, width: Int(size.width - 40), height: 30)
                toolbar.frame = CGRect(x: 0, y: Int(size.height) - tbar, width: Int(size.width), height: tbar)
            }
        }
        
    }
    func enableToolBar(turnOn: Bool) {
        if turnOn {
            toolbar_trash.isEnabled = true
            toolbar_contact.isEnabled = true
            toolbar_camera.isEnabled = true
            toolbar_folder.isEnabled = true
        } else {
            toolbar_trash.isEnabled = false
            toolbar_contact.isEnabled = false
            toolbar_camera.isEnabled = false
            toolbar_folder.isEnabled = false
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
}

extension MyMap : UINavigationControllerDelegate {
    @objc func doTakePhoto() {
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        imgPicker.sourceType = .camera
        let vc = UIApplication.shared.windows[0].rootViewController
        vc?.present(imgPicker, animated: true, completion: nil)
    }
    @objc func doSelectPhoto() {
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        imgPicker.sourceType = .photoLibrary
        let vc = UIApplication.shared.windows[0].rootViewController
        vc?.present(imgPicker, animated: true, completion: nil)
    }
}

extension MyMap : UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let img =  info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        aPicture.image = img
        aPicture.contentMode = .scaleAspectFit
        //Save the image
        currentPeople.myImage = aPicture.image
        aPicture.image = nil
    }
}

extension MyMap : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLmngr.stopUpdatingLocation() //Only one mesure
        // Map update
        let span = MKCoordinateSpan(latitudeDelta: 0.035, longitudeDelta: 0.035)
        let region = MKCoordinateRegion(center: (manager.location?.coordinate)!, span: span)
        map.setRegion(region, animated: true)
        map.showsUserLocation = true // Add a pin on the current location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    @objc func computePosition(_ sender: Any) {
        print("searching....")
        CLmngr.startUpdatingLocation()
    }
    func setupCamera(is3D: Bool) {
        if is3D {
            let lat = map.centerCoordinate.latitude
            let lon = map.centerCoordinate.longitude
            let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            var viewPoint = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            viewPoint = CLLocationCoordinate2D(latitude: lat - 0.01, longitude: lon)
            let span = MKCoordinateSpan(latitudeDelta: 3, longitudeDelta: 3)
            print("location", location.latitude , location.longitude)
            print("viewPoint", viewPoint.latitude , viewPoint.longitude)
            map.setRegion(MKCoordinateRegion(center: location, span: span), animated: true)
            map.showsBuildings = true
            cam = MKMapCamera(lookingAtCenter: location, fromEyeCoordinate: viewPoint, eyeAltitude: eagle_altitude)
            cam?.heading = eagle_orientation
            map.camera = cam!
        }
    }
}

extension MyMap : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let epingle = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "reusePin")
        epingle.pinTintColor = color
        color = nextColor(c: color)
        epingle.canShowCallout = true
        epingle.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        //epingle.leftCalloutAccessoryView = aPicture;
        return epingle
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //when tap on the (i) button
        print("Add new contact for -" + (view.annotation?.title!)! + "-")
        addContact()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        var isHavingPhoto = false
        enableToolBar(turnOn: true)
        print("Selected -" + (view.annotation?.title!)! + "-")
        if view.annotation === mapView.userLocation {
            //aPicture.image = UIImage(named: "AppIcon")
            return
        } else {
            //Update the currentPeople
            for i in listPeople {
                if i.myAnnotation?.title == view.annotation?.title {
                    currentPeople = i
                    if currentPeople.myImage != nil {
                        isHavingPhoto = true
                        aPicture.image = currentPeople.myImage
                    }
                    break
                }
            }
        }
        view.annotation = currentPeople.myAnnotation
        //Show the image if exist
        if isHavingPhoto {
            isShowPhoto = true
            self.drawInSize(UIScreen.main.bounds.size)
        }
    }
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        enableToolBar(turnOn: false)
        isShowPhoto = false
        self.drawInSize(UIScreen.main.bounds.size)
    }
    @objc func addPin(sender: UIButton) {
        let newPeople = People()
        newPeople.myAnnotation = AnAnnotation(c: map.centerCoordinate, t: String(format:"Name %d", count), st: String(format:"Contact %d", count))
        listPeople.append(newPeople)
        count += 1
        map.addAnnotation(newPeople.myAnnotation!)
    }
}

extension MyMap : MultiSelectSegmentedControlDelegate {
    func multiSelect(_ multiSelectSegmentedControl: MultiSelectSegmentedControl, didChangeValue value: Bool, at index: UInt) {
        if index == 0 {
            mapMode.selectAllSegments(true)
            mapMode.selectedSegmentIndexes.remove(1)
            mapMode.selectedSegmentIndexes.remove(2)
            mapMode.selectedSegmentIndexes.remove(3)
        }
        if index == 1 {
            mapMode.selectAllSegments(true)
            mapMode.selectedSegmentIndexes.remove(3)
            mapMode.selectedSegmentIndexes.remove(0)
            mapMode.selectedSegmentIndexes.remove(2)
        }
        if index == 2 {
            mapMode.selectAllSegments(true)
            mapMode.selectedSegmentIndexes.remove(3)
            mapMode.selectedSegmentIndexes.remove(1)
            mapMode.selectedSegmentIndexes.remove(0)
        }
        changeMap()
    }
    func changeMap() {
        if mapMode.selectedSegmentIndexes == [0] { //Map mode
            NSLog("changeMap standard")
            cam = nil
            map.mapType = .standard
        }
        if mapMode.selectedSegmentIndexes == [1] { //Satellite mode
            NSLog("changeMap satellite")
            cam = nil
            map.mapType = .satellite
        }
        if mapMode.selectedSegmentIndexes == [2] { //Mix mode
            NSLog("changeMap hybrid")
            cam = nil
            map.mapType = .hybrid
        }
        if mapMode.selectedSegmentIndexes == [0, 3] { //Map mode in 3D
            print("changeMap 3D standard")
            setupCamera(is3D: true)
            map.mapType = .standard
        }
        if mapMode.selectedSegmentIndexes == [1, 3] { //Satellite mode in 3D
            print("changeMap 3D satelliteFlyover")
            setupCamera(is3D: true)
            map.mapType = .satelliteFlyover
        }
        if mapMode.selectedSegmentIndexes == [2, 3] { //Mix mode in 3D
            print("changeMap 3D hybridFlyover")
            setupCamera(is3D: true)
            map.mapType = .hybridFlyover
        }
        if cam != nil {
            map.camera = cam!
        }
    }
}


extension MyMap : CNContactPickerDelegate , CNContactViewControllerDelegate {
    @objc func searchContact() {
        contactsS.requestAccess(for: .contacts) { (b : Bool, e : Error?) in
            //Important to execute on main thread to reach
            //UIApplication.shared.windows in a safe way
            DispatchQueue.main.async {
                let vc = UIApplication.shared.windows[0].rootViewController
                if !b {
                    let a = UIAlertController(title: "Error", message: "Access to contact refused", preferredStyle: .alert)
                    a.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    vc?.present(a, animated: true, completion: nil)
                } else {
                    print("=====CNContactPicker view controleur")
                    vc?.present(self.contactsC, animated: true, completion: nil)
                }
            }
        }
    }
    @objc func addContact() {
        contactsS.requestAccess(for: .contacts) { (b : Bool, e : Error?) in
            let vc = UIApplication.shared.windows[0].rootViewController
            if !b {
                let a = UIAlertController(title: "Error", message: "Access to contact refused", preferredStyle: .alert)
                a.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                vc?.present(a, animated: true, completion: nil)
            } else {
                let x = CNMutableContact()
                self.contactVC = CNContactViewController(forNewContact: x)
                self.contactVC!.delegate = self
                let n = UINavigationController(rootViewController: self.contactVC!)
                vc?.present(n, animated: true, completion: nil)
            }
        }
    }
    func addPeopleContactInfo(contact: CNContact?, people: People) {
        if contact != nil {
            if contact!.isKeyAvailable(CNContactFamilyNameKey) {
                people.myName = contact!.familyName
            }
            if contact!.isKeyAvailable(CNContactGivenNameKey) {
                people.myFirstName = contact!.givenName
            }
            people.myNumber = ""
            if contact!.isKeyAvailable(CNContactPhoneNumbersKey) {
                for n : CNLabeledValue in contact!.phoneNumbers{
                    let num = n.value.stringValue
                    people.myNumber = num
                }
            }
            if contact?.thumbnailImageData != nil {
                people.myImage = UIImage(data: contact!.thumbnailImageData!)
            }
        } else {
            people.myName = "<nul>"
            people.myFirstName = "<nul>"
            people.myNumber = "<nul>"
            people.myImage = nil
        }
        people.myAnnotation?.title = people.myName
        people.myAnnotation?.subtitle = people.myNumber
    }
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        contactVC?.dismiss(animated: true, completion: nil)
        contactVC = nil
        addPeopleContactInfo(contact: contact, people: currentPeople)
    }
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        print("didSelect contact")
        addPeopleContactInfo(contact: contact, people: currentPeople)
    }
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        print("contactPickerDidCancel")
    }
}
