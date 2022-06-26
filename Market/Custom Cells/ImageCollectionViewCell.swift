//
//  ImageCollectionViewCell.swift
//  Market
//
//  Created by Love Shrivastava on 6/21/22.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func setupImageWith(itemImage:UIImage){
        imageView.image = itemImage
    }
    
}
