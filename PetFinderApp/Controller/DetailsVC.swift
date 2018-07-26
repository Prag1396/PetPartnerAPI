//
//  DetailsVC.swift
//  PetFinderApp
//
//  Created by Pragun Sharma on 7/24/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit

class DetailsVC: UIViewController {
    
    @IBOutlet weak var contactemail: UILabel!
    @IBOutlet weak var contactPhone: UILabel!
    @IBOutlet weak var animaldetails: UILabel!
    @IBOutlet weak var largeImage: UIImageView!
    @IBOutlet weak var animalsex: UILabel!
    @IBOutlet weak var animalBreed: UILabel!
    @IBOutlet weak var age: UILabel!
    
    private var _image: String? = nil
    private var _animalSex: String? = nil
    private var _animalMix: String? = nil
    private var _animalBreed: String? = nil
    private var _contactphone: String? = nil
    private var _contactemail: String? = nil
    private var _age: String? = nil
    
    var image: String {
        get {
            return _image!
        } set {
            _image = newValue
        }
    }
    
    var animalSex: String {
        get {
            return _animalSex!
        } set {
            _animalSex = newValue
        }
    }
    
    var animalmix: String {
        get {
            return _animalMix!
        } set {
            _animalMix = newValue
        }
    }
    
    var animalBreeds: String {
        get {
            return _animalBreed!
        } set {
            _animalBreed = newValue
        }
    }
    var contactEmail: String {
        get {
            return _contactemail!
        } set {
            _contactemail = newValue
        }
    }
    
    var contactphone: String {
        get {
            return _contactphone!
        } set {
            _contactphone = newValue
        }
    }
    
    var Age: String {
        get {
            return _age!
        } set {
            _age = newValue
        }
    }
    
    @IBAction func backbtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let localimage = self._image {
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
    }
    
    func setUpUI(data: Data? = nil) {
        DispatchQueue.main.async {
            self.contactemail.text = self.contactEmail
            self.contactPhone.text = self.contactphone
            self.animalsex.text = self.animalSex
            self.animalBreed.text = self.animalBreeds
            self.age.text = self.Age
            
            if let data = data {
                self.largeImage.image = UIImage(data: data)
            }
        }
    }
    
    
}
