//
//  CurrentPetData.swift
//  PetFinderApp
//
//  Created by Pragun Sharma on 7/24/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit
import Alamofire

class PetData {
    
    private var _name: String!
    private var _description: String!
    private var _ImageURLSmall: String!
    private var _ImageURLBig: String!
    private var _animalDetails: String!
    private var _contactEmail: String!
    private var _contactPhone: String!
    private var _animalSex: String!
    private var _animalMix: String!
    private var _animalBreed: String!
    private var _age: String!
    
    var name: String {
        if _name == nil {
            _name = ""
        }
        return _name
    }
    
    var description: String {
        if _description == nil {
            _description = ""
        }
        return _description
    }
    
    var imageURLSmall: String {
        if _ImageURLSmall == nil {
            _ImageURLSmall = ""
        }
        return _ImageURLSmall
    }
    
    var imageURLBig: String {
        if _ImageURLBig == nil {
            _ImageURLBig = ""
        }
        return _ImageURLBig
    }
    
    var contactEmail: String {
        if _contactEmail == nil {
            _contactEmail = "No Email Provided"
        }
        return _contactEmail
    }
    
    var contactPhone: String {
        if _contactPhone == nil {
            _contactPhone = "No Phone Provided"
        }
        return _contactPhone
    }

    var animalSex: String {
        if _animalSex == nil {
            _animalSex = ""
        }
        return _animalSex
    }
    
    var animalMix: String {
        if _animalMix == nil {
            _animalMix = ""
        }
        return _animalMix
    }
    
    var animalBreed: String {
        if _animalBreed == nil {
            _animalBreed = ""
        }
        return _animalBreed
    }
    
    var age: String {
        if _age == nil {
            _age = ""
        }
        return _age
    }
    
    
    init(petdict: Dictionary<String, AnyObject>) {
        if let nameDict = petdict["name"] as? Dictionary<String, AnyObject> {
            if let name = nameDict["$t"] as? String {
                self._name = name
                
            }
        }
        
        if let descriptionDict = petdict["description"] as? Dictionary<String, AnyObject>  {
            if let description = descriptionDict["$t"] as? String {
                self._description = description
            }
        }
        
        
        //Store ImageURL
        if let media = petdict["media"] as? Dictionary<String, AnyObject> {
            if let photos = media["photos"] as? Dictionary<String, AnyObject> {
                if let photo = photos["photo"] as? [Dictionary<String, AnyObject>] {
                    if let imageurl = photo[0]["$t"] as? String {
                        self._ImageURLSmall = imageurl
                    }
                    
                    if let bigImageUrl = photo[2]["$t"] as? String {
                        self._ImageURLBig = bigImageUrl
                    }
                }
            }
        }


        
        //Store Contact Info
        if let contactDict = petdict["contact"] as? Dictionary<String, AnyObject> {
            if let phoneDict = contactDict["phone"] as? Dictionary<String, AnyObject> {
                if let phone = phoneDict["$t"] as? String {
                    self._contactPhone = phone
                }
            }
            if let emailDict = contactDict["email"] as? Dictionary<String, AnyObject> {
                if let email = emailDict["$t"] as? String {
                    self._contactEmail = email
                }
            }
        }
        
        //Store Animal Details
        if let sexDict = petdict["sex"] as? Dictionary<String, AnyObject> {
            if let asex = sexDict["$t"] as? String {
                self._animalSex = asex
            }
        }
        
        if let mixDict = petdict["mix"] as? Dictionary<String, AnyObject> {
            if let amix = mixDict["$t"] as? String {
                self._animalMix = amix
            }
        }
        
        if let ageDict = petdict["age"] as? Dictionary<String, AnyObject> {
            if let age = ageDict["$t"] as? String {
                self._age = age
            }
        }
        
        
        if let breedDict = petdict["breeds"] as? Dictionary<String, AnyObject> {
            if let breedDictArray = breedDict["breed"] as? [Dictionary<String, AnyObject>] {
                for obj in breedDictArray {
                    if let breed = obj["$t"] as? String {
                        self._animalBreed = breed
                    }
                }
            } else {
                if let breedDictArray = breedDict["breed"] as? Dictionary<String, AnyObject> {
                    if let breed = breedDictArray["$t"] as? String {
                        self._animalBreed = breed
                    }
                }
            }
        }
        
    }
}
