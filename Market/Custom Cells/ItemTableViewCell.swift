//
//  ItemTableViewCell.swift
//  Market
//
//  Created by Love Shrivastava on 6/20/22.
//

import UIKit

class ItemTableViewCell: UITableViewCell {
    
    
    //MARK: IBOutlets
    
    @IBOutlet weak var itemImageView: UIImageView!
    
    
    @IBOutlet weak var nameLabel: UILabel!
    
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func generateCell(_ item:Item)
    {
        nameLabel.text = item.name
        print(item.name)
        descriptionLabel.text = item.description
        priceLabel.text = convertToCurrency(item.price)
        priceLabel.adjustsFontSizeToFitWidth = true
        
        if item.imagesLinks != nil && item.imagesLinks.count>0{
            
            downloadImages(imageUrls: [item.imagesLinks.first!]) { (images) in
                self.itemImageView.image = images.first as? UIImage
            }
            
        }
    }

}
