//
//  ViewController.swift
//  JeMeSouviens
//
//  Created by TA Trung Thanh on 23/11/2018.
//  Copyright © 2018 TA Trung Thanh. All rights reserved.
//

import UIKit
import CoreLocation //do not forget!!

class ViewController: UIViewController {
    private let v = MyMap(frame: UIScreen.main.bounds)
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view = v
    }

    override func viewDidAppear(_ animated: Bool) {
        // The location stuffs can not be done in viewDidLoad
        //(too early for self to be able to perform present
        if !CLLocationManager.locationServicesEnabled() {
            self.view = UIView()
            self.view.backgroundColor = .red
            let alert = UIAlertController(title: "Error", message: "Please activate location for my app", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        v.drawInSize(size)
    }
}

