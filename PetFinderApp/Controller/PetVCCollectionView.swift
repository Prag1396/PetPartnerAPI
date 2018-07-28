//
//  PetVCCollectionView.swift
//  PetFinderApp
//
//  Created by Pragun Sharma on 7/27/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation


class PetVCCollectionView: UIViewController, UITextFieldDelegate,  CLLocationManagerDelegate {

    var petDataArray = [PetData]()
    var imageurl: URL? = nil
    var image: UIImage? = nil
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation? = nil
    var placeMark: CLPlacemark? = nil
    var locationEntered: String? = nil
    var animalEntered: String? = nil
    var curr_url: String!
    
    
    @IBOutlet weak var animalTextField: UITextField!
    @IBOutlet weak var locationTextfield: UITextField!
    @IBOutlet weak var userlocationLabel: UILabel!
    @IBOutlet weak var CollectionViewtopContraint: NSLayoutConstraint!
    @IBOutlet weak var mycollectionView: UICollectionView!
    
    //Pagination
    var totalEnteries: Int = 0
    var limit: Int = 15
    
    var dataCacheURL: URL?
    let dataCacheQueue = OperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mycollectionView.delegate = self
        self.mycollectionView.dataSource = self
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
                    self.mycollectionView.reloadData()
                }
            })
        }
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.locationAuthStatus()
    }
    
    @IBAction func searchbtnpressed(_ sender: Any) {
        UIView.animate(withDuration: 1, animations: {
            self.CollectionViewtopContraint.constant = 200
            self.view.layoutIfNeeded()
        })
    }
    
    func resetContraint() {
        UIView.animate(withDuration: 1, animations: {
            self.CollectionViewtopContraint.constant = 0
            self.view.layoutIfNeeded()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.mycollectionView.deselectAllItems()
        
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
        self.calculateTotal(url: url) {
            self.downloadPetDetails(url: url) {
                DispatchQueue.main.async {
                    self.mycollectionView.reloadData()
                }
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
            self.mycollectionView.reloadData()
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
        //let point: CGPoint = self.mycollectionView.view.convert(.zero, to: self.view)
   
        if segue.identifier == "gotodetailsVC" {
            if let destination = segue.destination as? DetailsVC {
                if let petData = sender as? PetData {
                    destination.petData = petData
                }
            }
        }
    }
}

extension PetVCCollectionView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width/2 - 10
        let hieght = width
        
        return CGSize(width: width, height: hieght)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.resetContraint()
        let petaData = self.petDataArray[indexPath.row]
        performSegue(withIdentifier: "gotodetailsVC", sender: petaData)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.petDataArray.count > 0 {
            return self.petDataArray.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == self.petDataArray.count - 1 {
            //we are at the last cell load more content
            if self.petDataArray.count < self.totalEnteries {
                //download more content
                self.downloadPetDetails(url: self.curr_url) {
                    DispatchQueue.main.async {
                        self.mycollectionView.reloadData()
                    }
                }
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = mycollectionView.dequeueReusableCell(withReuseIdentifier: "petCell", for: indexPath) as? PetCellCollection {
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
            cell.layoutIfNeeded()
            return cell
        } else {
            return PetCellCollection()
        }
    }
}

extension PetVCCollectionView {
    
    func downloadImage(withImageURL url: URL, downloadCompleted: @escaping (_ status: Bool, _ error: Error?, _ image: UIImage?)->()) {
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if (error != nil) {
                print("HI-II: \(error.debugDescription)")
                downloadCompleted(false, error, nil)
            } else {
                if let data = data {
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

extension UICollectionView {
    func deselectAllItems(animated: Bool = false) {
        for indexPath in self.indexPathsForSelectedItems ?? [] {
            self.deselectItem(at: indexPath, animated: animated)
        }
    }
}



