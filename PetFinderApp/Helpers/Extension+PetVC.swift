//
//  Extension+PetVC.swift
//  PetFinderApp
//
//  Created by Pragun Sharma on 7/25/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit
import CoreLocation

//Extensions

extension PetVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.petDataArray.count > 0 {
            return self.petDataArray.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            if let cell = tableView.dequeueReusableCell(withIdentifier: "petCell", for: indexPath) as? PetCell {
                if self.petDataArray.count > 0 {
                let petObj = self.petDataArray[indexPath.row]
                if let url = URL(string: petObj.imageURLSmall) {
                    //Only download if image not available in cache
                    self.downloadImage(withImageURL: url, downloadCompleted: { (status, error, _image) in
                        if (error != nil) {
                            //present alert
                            print("HI: \(error.debugDescription)")
                        }
                        else {
                            if let _img = _image {
                                self.image = _img
                            }
                        }
                    })
                    
                }
                if let _image = self.image {
                    cell.configureCell(petDataObj: petObj, image: _image)
                }
            }
                return cell
            } else {
                return PetCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //load DetailsVC
        self.resetContraint()
        performSegue(withIdentifier: "todetailsVC", sender: Any.self)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.petDataArray.count - 1 {
            //we are at the last cell load more content
            if self.petDataArray.count < self.totalEnteries {
                //download more content
                self.downloadPetDetails(url: self.curr_url) {
                    DispatchQueue.main.async {
                        self.petTableView.reloadData()
                    }
                }
            } 
            
        }
    }
}

extension PetVC {
    func downloadImage(withImageURL url: URL, downloadCompleted: @escaping (_ status: Bool, _ error: Error?, _ image: UIImage?)->()) {
        
//        if let cachedImage = self.imagecache.object(forKey: url.absoluteString as NSString) {
//            downloadCompleted(true,nil, cachedImage)
//        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if (error != nil) {
                print("HI-II: \(error.debugDescription)")
                downloadCompleted(false, error, nil)
            } else {
                if let data = data {
                    //self.imagecache.setObject(UIImage(data: data)!, forKey: url.absoluteString as NSString)
                    downloadCompleted(true, nil, UIImage(data: data))
                }
            }
            }.resume()
    }
    
    func locationAuthStatus() {
        if(Reachability.isConnectedToNetwork()) {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            guard let userloc: CLLocationCoordinate2D = locationManager.location?.coordinate else { return }
            let location = CLLocation(latitude: userloc.latitude, longitude: userloc.longitude)
            self.convertLocationtoAddress(userlocation: location) { (error, retloc) in
                if(error != nil) {
                    print("HI=III: \(error.debugDescription)")
                } else {
                    //Update UI
                    self.userlocationLabel.text = "\(String(describing: retloc!))"
                    USER_LOCATION_DOWNLOADED = "\(String(describing: retloc!))"
                    self.locationManager.stopUpdatingLocation()
                }
            }
            
        }
        else {
            locationManager.requestWhenInUseAuthorization()
            locationAuthStatus()
        }
    }
    }
}


















