//
//  PetCellCollection.swift
//  PetFinderApp
//
//  Created by Pragun Sharma on 7/27/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit

class PetCellCollection: UICollectionViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var pet_description: UILabel!
    @IBOutlet weak var petImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.borderWidth = 1
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func configureCell(petDataObj: PetData, image: UIImage) {
        DispatchQueue.main.async {
            self.name.text = petDataObj.name
            self.pet_description.text = petDataObj.description
            self.petImage.image = image
        }
    }
}
