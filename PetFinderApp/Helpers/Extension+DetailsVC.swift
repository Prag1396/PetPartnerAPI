//
//  Extension+UIView.swift
//  PetFinderApp
//
//  Created by Pragun Sharma on 7/24/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit
import CoreLocation

extension DetailsVC {

    
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
    

}
