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

class PetVC: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var animalTextField: UITextField!
    @IBOutlet weak var locationTextfield: UITextField!
    @IBOutlet weak var userlocationLabel: UILabel!
    @IBOutlet weak var petTableView: UITableView!
    @IBOutlet weak var tabletopContraint: NSLayoutConstraint!
    
    var petDataArray = [PetData]()
    var imageurl: URL? = nil
    var image: UIImage? = nil
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation? = nil
    var placeMark: CLPlacemark? = nil
    var locationEntered: String? = nil
    var animalEntered: String? = nil
    var curr_url: String!
    
    
    //Pagination
    var totalEnteries: Int = 0
    var limit: Int = 15
    
    //Caching
    //var imagecache = NSCache<NSString, UIImage>()
    var dataCacheURL: URL?
    let dataCacheQueue = OperationQueue()
    
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
        
        curr_url = CURRENT_SEARCH_URL
        
        if let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            dataCacheURL = cacheURL.appendingPathComponent("data.json")
        }
        
        //print(CURRENT_SEARCH_URL)
        self.calculateTotal(url: CURRENT_SEARCH_URL) {
            self.downloadPetDetails(url: CURRENT_SEARCH_URL, downloadCompleted: {
                DispatchQueue.main.async {
                    self.petTableView.reloadData()
                }
            })
        }
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.locationAuthStatus()
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
            self.constructURL(locEntered: loc, animalEntered: animal)
        } else if let loc = self.locationEntered, self.locationEntered != "" {
            self.constructURL(locEntered: loc, animalEntered: nil)
        } else if let animal = self.animalEntered, self.animalEntered != "" {
            self.constructURL(locEntered: nil, animalEntered: animal)
        } else {
            self.constructURL()
        }
        
    }
    
    func constructURL(locEntered: String? = nil, animalEntered: String? = nil) {
        var url: String!
        if let loc = locEntered, let animal = animalEntered {
            url = NEW_SEARCH_URL + NEWLOCATION + loc + NEWANIMAL + animal
        } else if let loc = locEntered {
            url = NEW_SEARCH_URL + NEWLOCATION + loc + ANIMALPLACEHOLDER
        } else if let animal = animalEntered {
            url = NEW_SEARCH_URL + LOCATIONPLACEHOLDER + NEWANIMAL + animal
        } else {
            url = NEW_SEARCH_URL + LOCATIONPLACEHOLDER + ANIMALPLACEHOLDER
        }
        curr_url = url
        self.downloadPetDetails(url: url) {
            DispatchQueue.main.async {
                self.petTableView.reloadData()
            }
        }
        
    }
    
    //API Call to download Pet Details
    func downloadPetDetails(url: String, downloadCompleted: @escaping() -> ()) {
        
        guard let currentURL = URL(string: url) else { return }
        Alamofire.request(currentURL).responseJSON { (response) in
            
            //Download as store in dictionaries
            guard let dict = response.value as? Dictionary<String, AnyObject> else {return}
            guard let petfinder = dict["petfinder"] as? Dictionary<String, AnyObject> else {return}
            guard let allPets = petfinder["pets"] as? Dictionary<String, AnyObject> else {return}
            guard let petdict = allPets["pet"] as? [Dictionary<String, AnyObject>] else {return}
            
            var index = self.petDataArray.count
            
            if (self.totalEnteries - self.petDataArray.count >= 15) {
                
                self.limit = index + 15
            } else {
                self.limit = index + (self.totalEnteries - self.petDataArray.count)
            }
            
            
            while index < self.limit {
                
                let petData = PetData(petdict: petdict[index])
                self.petDataArray.append(petData)
                index = index + 1
                
            }
            downloadCompleted()
        }
    }
    
    func calculateTotal(url: String, completed: @escaping () -> ()) {
        
        if Reachability.isConnectedToNetwork(){
            self.totalEnteries = 0
        
            guard let currentURL = URL(string: url) else { return }
            Alamofire.request(currentURL).responseJSON { (response) in

                //Download as store in dictionaries
                guard let dict = response.value as? Dictionary<String, AnyObject> else {return}
                guard let petfinder = dict["petfinder"] as? Dictionary<String, AnyObject> else {return}
                guard let allPets = petfinder["pets"] as? Dictionary<String, AnyObject> else {return}
                guard let petdict = allPets["pet"] as? [Dictionary<String, AnyObject>] else {return}

                for _ in 0...petdict.count - 1 {
                    //Store Appropriate Data
                    self.totalEnteries = self.totalEnteries + 1
                }
                
                if(self.dataCacheURL != nil) {
                    self.dataCacheQueue.addOperation {
                        if let stream = OutputStream(url: self.dataCacheURL!, append: false) {
                            stream.open()
                            
                            
                            if let obj = (try? JSONSerialization.jsonObject(with: response.data!, options: [])) as? Dictionary<String,AnyObject> {
                                JSONSerialization.writeJSONObject(obj, to: stream, options: [.prettyPrinted], error: nil)
                            }

                            stream.close()
                        }
                        
                    }
                }
                completed()
            }
        } else{
            print("Internet Connection not Available!")
            //Load Data from Cache
            if(self.dataCacheURL != nil) {
                self.dataCacheQueue.addOperation {
                    if let stream = InputStream(url: self.dataCacheURL!) {
                        stream.open()
                        if let response = ((try? JSONSerialization.jsonObject(with: stream, options: [])) as? [String: AnyObject]) {
                            self.showdataOffline(local: response)
                        }
                        stream.close()
                    }
                    
                }
            }
            
        }
        
        
    }
    
    func showdataOffline(local: [String: AnyObject]) {
        
        guard let petfinder = local["petfinder"] as? Dictionary<String, AnyObject> else {return}
        guard let allPets = petfinder["pets"] as? Dictionary<String, AnyObject> else {return}
        guard let petdict = allPets["pet"] as? [Dictionary<String, AnyObject>] else {return}
        
        for _ in 0...petdict.count - 1 {
            //Store Appropriate Data
            self.totalEnteries = self.totalEnteries + 1
        }
        
        var index = self.petDataArray.count
        
        if (self.totalEnteries - self.petDataArray.count >= 15) {
            
            self.limit = index + 15
        } else {
            self.limit = index + (self.totalEnteries - self.petDataArray.count)
        }
        
        while index < self.limit {
            
            let petData = PetData(petdict: petdict[index])
            self.petDataArray.append(petData)
            index = index + 1
            
        }
        DispatchQueue.main.async {
            self.petTableView.reloadData()
        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = petTableView.indexPathForSelectedRow else { return }
        let selectedrow = indexPath.row
        
        if segue.identifier == "todetailsVC" {
            if let destination = segue.destination as? DetailsVC {
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
