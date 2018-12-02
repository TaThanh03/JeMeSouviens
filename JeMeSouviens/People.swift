//
//  People.swift
//  JeMeSouviens
//
//  Created by TA Trung Thanh on 02/12/2018.
//  Copyright © 2018 TA Trung Thanh. All rights reserved.
//

import Foundation
import UIKit

class People: NSObject {
    var myAnnotation : AnAnnotation?
    var myImage : UIImage?
    var myName : String?
    var myFirstName : String?
    var myNumber : String?
    func setInfo(myName : String, myFirstName : String,  myNumber : String) {
        self.myName = myName
        self.myFirstName = myFirstName
        self.myNumber = myNumber
    }
}
