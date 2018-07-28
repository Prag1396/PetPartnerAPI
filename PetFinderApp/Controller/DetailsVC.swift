//
//  DetailsVC.swift
//  PetFinderApp
//
//  Created by Pragun Sharma on 7/24/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit

class DetailsVC: UIViewController {
    
    var petData: PetData!
    
    @IBOutlet weak var contactemail: UILabel!
    @IBOutlet weak var contactPhone: UILabel!
    @IBOutlet weak var animaldetails: UILabel!
    @IBOutlet weak var largeImage: UIImageView!
    @IBOutlet weak var animalsex: UILabel!
    @IBOutlet weak var animalBreed: UILabel!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var animalMix: UILabel!
    
    @IBAction func backbtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let localimage = petData.imageURLBig
            if(localimage != "") {
            if let url = URL(string: localimage) {
                self.downloadImage(withImageURL: url, downloadCompleted: { (status, error, data) in
                    if (error != nil) {
                        print(error.debugDescription)
                    } else {
                        self.setUpUI(data: data!)
                    }
                })
            }
            } else {
                self.setUpUI()
            }
    }
    
    func setUpUI(data: Data? = nil) {
        DispatchQueue.main.async {
                self.contactemail.text = self.petData.contactEmail
                self.contactPhone.text = self.petData.contactPhone
                self.animalsex.text = self.petData.animalSex
                self.animalBreed.text = self.petData.animalBreed
                self.age.text = self.petData.age
                self.animalMix.text = self.petData.animalMix
            if let data = data {
                self.largeImage.image = UIImage(data: data)
            }
        }
    }
    
    
}
