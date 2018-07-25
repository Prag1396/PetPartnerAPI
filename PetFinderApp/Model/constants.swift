//
//  constants.swift
//  PetFinderApp
//
//  Created by Pragun Sharma on 7/24/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import Foundation


let BASE_URL = "http://api.petfinder.com/pet.find?key="
let API_KEY = "88e6cc45d7f23dd8308b19256a3472c7"

let LOCATION = "&location=Raleigh,NC"
let ANIMAL = "&animal=rabbit"
let CONVERT_TO_JSON = "&format=json"

let CURRENT_SEARCH_URL = BASE_URL+API_KEY+LOCATION+ANIMAL+CONVERT_TO_JSON

