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

extension PetVC: CLLocationManagerDelegate {
    
    //Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userloc: CLLocationCoordinate2D = locationManager.location?.coordinate else { return }
        let location = CLLocation(latitude: userloc.latitude, longitude: userloc.longitude)
        self.convertLocationtoAddress(userlocation: location) { (error, retLoc) in
            if(error != nil) {
                print(String(describing: error))
            } else {
                //Update UI
                self.userlocationLabel.text = "\(String(describing: retLoc!))"
            }
        }
        
    }
}

extension PetVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.petDataArray.count > 0 {
            return self.petDataArray.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.petDataArray.count > 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "petCell", for: indexPath) as? PetCell {
                let petObj = self.petDataArray[indexPath.row]
                if let url = URL(string: petObj.imageURLSmall) {
                    self.downloadImage(withImageURL: url, downloadCompleted: { (status, error, data) in
                        if (error != nil) {
                            //present alert
                            print(error.debugDescription)
                        } else {
                            self.imagefromData = data
                        }
                    })
                    
                }
                cell.configureCell(petDataObj: petObj, imageData: imagefromData)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //load DetailsVC
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

















