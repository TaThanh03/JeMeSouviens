//
//  AnAnnotation.swift
//  JeMeSouviens
//
//  Created by TA Trung Thanh on 23/11/2018.
//  Copyright © 2018 TA Trung Thanh. All rights reserved.
//

import UIKit
import MapKit //for MKAnnotation

class AnAnnotation: NSObject, MKAnnotation {
    //Properties requested by the protocol
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    //var image: UIImage?
    
    init(c: CLLocationCoordinate2D) {
        coordinate = c
        super.init()
    }
    
    convenience init(c: CLLocationCoordinate2D, t: String) {
        self.init(c: c)
        title = t
    }
    
    convenience init(c: CLLocationCoordinate2D, t: String, st: String) {
        self.init(c: c, t: t)
        subtitle = st
    }
}
