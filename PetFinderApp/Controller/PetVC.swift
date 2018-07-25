//
//  ViewController.swift
//  PetFinderApp
//
//  Created by Pragun Sharma on 7/24/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit
import Alamofire

class PetVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    @IBOutlet weak var petTableView: UITableView!
    var petDataArray = [PetData]()
    var imageurl: URL? = nil
    var imagefromData: Data? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.petTableView.delegate = self
        self.petTableView.dataSource = self

        self.downloadPetDetails {
            self.petTableView.reloadData()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let indexPath = petTableView.indexPathForSelectedRow else { return }
        self.petTableView.deselectRow(at: indexPath, animated: false)
    }
    
    func downloadPetDetails(downloadCompleted: @escaping() -> ()) {
        
        guard let currentURL = URL(string: CURRENT_SEARCH_URL) else { return }
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
                    self.view.downloadImage(withImageURL: url, downloadCompleted: { (status, error, data) in
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

