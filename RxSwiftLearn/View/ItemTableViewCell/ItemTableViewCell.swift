//
//  ItemTableViewCell.swift
//  RxSwiftLearn
//
//  Created by Nguyễn Hồng Lĩnh on 05/05/2021.
//

import UIKit
import Kingfisher

class ItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    static let cellIdentifier = String(describing: ItemTableViewCell.self)

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setUpWith(item: Drink) {
        if let imageURL = URL(string: item.imageURL) {
            itemImage.kf.setImage(with: imageURL)
        }
        itemName.text = item.name
    }
    
}
