//
//  ViewController.swift
//  PetFinderApp
//
//  Created by Pragun Sharma on 7/24/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation

class PetVC: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var animalTextField: UITextField!
    @IBOutlet weak var locationTextfield: UITextField!
    @IBOutlet weak var userlocationLabel: UILabel!
    @IBOutlet weak var petTableView: UITableView!
    @IBOutlet weak var tabletopContraint: NSLayoutConstraint!
    
    var petDataArray = [PetData]()
    var imageurl: URL? = nil
    var imagefromData: Data? = nil
    let locationManager = CLLocationManager()
    var placeMark: CLPlacemark? = nil
    var locationEntered: String? = nil
    var animalEntered: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.petTableView.delegate = self
        self.petTableView.dataSource = self
        self.locationTextfield.delegate = self
        self.animalTextField.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            locationManager.distanceFilter = 100
            locationManager.startUpdatingLocation()
        }

        self.downloadPetDetails {
            DispatchQueue.main.async {
                self.petTableView.reloadData()
            }
        }
        
    }
    
    
    @IBAction func searchbtnpressed(_ sender: Any) {
        UIView.animate(withDuration: 1, animations: {
            self.tabletopContraint.constant = 200
            self.view.layoutIfNeeded()
        })
    }
    
    func resetContraint() {
        UIView.animate(withDuration: 1, animations: {
            self.tabletopContraint.constant = 0
            self.view.layoutIfNeeded()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let indexPath = petTableView.indexPathForSelectedRow else { return }
        self.petTableView.deselectRow(at: indexPath, animated: false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func checkInput() {
        if(locationTextfield.text != nil || locationTextfield.text != "") {
            self.locationEntered = locationTextfield.text
        }
        if(animalTextField.text != nil || animalTextField.text != "") {
            self.animalEntered = animalTextField.text
        }
    }
 
    @IBAction func initiateSearch(_ sender: Any) {
        
        self.resetContraint()
        self.checkInput()
        self.petDataArray.removeAll()
        
        //Call download PetDetails with location
        if let loc = self.locationEntered, let animal = self.animalEntered, self.locationEntered != "", self.animalEntered != "" {
            self.downloadPetDetails(locEntered: loc, animalEntered: animal, downloadCompleted: {
                DispatchQueue.main.async {
                    self.petTableView.reloadData()
                }
            })
        } else if let loc = self.locationEntered, self.locationEntered != "" {
            self.downloadPetDetails(locEntered: loc, animalEntered: nil, downloadCompleted: {
                DispatchQueue.main.async {
                    self.petTableView.reloadData()
                }
            })
        } else if let animal = self.animalEntered, self.animalEntered != "" {
            self.downloadPetDetails(locEntered: nil, animalEntered: animal, downloadCompleted: {
                DispatchQueue.main.async {
                    self.petTableView.reloadData()
                }
            })
        }
        
    }
    
    
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
    
    //API Call to download Pet Details
    func downloadPetDetails(locEntered: String? = nil, animalEntered: String? = nil, downloadCompleted: @escaping() -> ()) {
        
        var url: String = NEW_SEARCH_URL
        if let loc = locEntered, let animal = animalEntered {
            url = NEW_SEARCH_URL + NEWLOCATION + loc + NEWANIMAL + animal
        } else if let loc = locEntered {
            url = NEW_SEARCH_URL + NEWLOCATION + loc + ANIMALPLACEHOLDER
        } else if let animal = animalEntered {
            url = NEW_SEARCH_URL + LOCATIONPLACEHOLDER + NEWANIMAL + animal
        } else {
            url = NEW_SEARCH_URL + LOCATIONPLACEHOLDER + ANIMALPLACEHOLDER
        }
        
        guard let currentURL = URL(string: url) else { return }
        Alamofire.request(currentURL).responseJSON { (response) in
            
            //Download as store in dictionaries
            guard let dict = response.value as? Dictionary<String, AnyObject> else {return}
            guard let petfinder = dict["petfinder"] as? Dictionary<String, AnyObject> else {return}
            guard let allPets = petfinder["pets"] as? Dictionary<String, AnyObject> else {return}
            guard let petdict = allPets["pet"] as? [Dictionary<String, AnyObject>] else {return}

            for i in 0...petdict.count - 1 {
                //Store Appropriate Data
                let petData = PetData(petdict: petdict[i])
                self.petDataArray.append(petData)
            }
            downloadCompleted()
        }
    }
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = petTableView.indexPathForSelectedRow else { return }
        let selectedrow = indexPath.row
        
        if segue.identifier == "todetailsVC" {
            if let destination = segue.destination as? DetailsVC {
                destination.PetIndexObj = self.petDataArray[selectedrow]
                destination.contactEmail = self.petDataArray[selectedrow].contactEmail
                destination.contactphone = self.petDataArray[selectedrow].contactPhone
                destination.image = self.petDataArray[selectedrow].imageURLBig
                destination.animalSex = self.petDataArray[selectedrow].animalSex
                destination.animalmix = self.petDataArray[selectedrow].animalMix
                destination.animalBreeds = self.petDataArray[selectedrow].animalBreed
                destination.Age = self.petDataArray[selectedrow].age
            }
        }
    }

}

