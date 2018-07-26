//
//  PetCell.swift
//  PetFinderApp
//
//  Created by Pragun Sharma on 7/24/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit

class PetCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var pet_description: UILabel!
    @IBOutlet weak var petImage: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.borderWidth = 1
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.selectionStyle = .default
    }
    
    func configureCell(petDataObj: PetData, imageData: Data?) {
        DispatchQueue.main.async {
            self.name.text = petDataObj.name
            self.pet_description.text = petDataObj.description
            if let imagedata = imageData {
                self.petImage.image = UIImage(data: imagedata)
            }
        }
    }
 

}
