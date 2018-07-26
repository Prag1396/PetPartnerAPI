//
//  Extension+UIView.swift
//  PetFinderApp
//
//  Created by Pragun Sharma on 7/24/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit
import CoreLocation

extension UIViewController {
    
    func downloadImage(withImageURL url: URL, downloadCompleted: @escaping (_ status: Bool, _ error: Error?, _ data: Data?)->()) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if (error != nil) {
                print(error.debugDescription)
                downloadCompleted(false, error, nil)
            } else {
                downloadCompleted(true, nil, data)
            }
            }.resume()
    }
    
    //convert location to Readable Address
    func convertLocationtoAddress(userlocation: CLLocation, conversioncompleted: @escaping(_ error: String?, _ loc: CLPlacemark?) -> ()) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(userlocation) { (placemark, error) in
            if error != nil {
                conversioncompleted("\(error.debugDescription)", nil)
            } else if let placemarksArray = placemark {
                if let pmark = placemarksArray.first {
                    conversioncompleted(nil, pmark)
                } else {
                    conversioncompleted("Could not locate user", nil)
                }
            } else {
                conversioncompleted("Unkown Error", nil)
            }
            
        }
        
    }
}
