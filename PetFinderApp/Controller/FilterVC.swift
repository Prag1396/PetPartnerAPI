//
//  FilterVC.swift
//  PetFinderApp
//
//  Created by Pragun Sharma on 7/25/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit

class FilterVC: UIViewController {

    @IBOutlet weak var locationTextField: UITextField!
    
    @IBOutlet weak var animalTextField: UITextField!
    
    let petObj: PetVC = PetVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func checkInput() {
        if(locationTextField.text != nil || locationTextField.text != "") {
            if let text = locationTextField.text {
                petObj.locationEntered = text
            }
        }
        if(animalTextField.text != nil || animalTextField.text != "") {
            if let text = animalTextField.text {
                petObj.animalEntered = text
            }
        }
    }

    @IBAction func searchbtnClicked(_ sender: Any) {
        self.checkInput()
        self.dismiss(animated: true) {
            self.petObj.initiateRequest()
        }
    }
    
    


}
