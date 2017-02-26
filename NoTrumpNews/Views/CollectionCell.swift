//
//  CollectionCell.swift
//  NoTrumpNews
//
//  Created by Andrey Kasatkin on 2/21/17.
//  Copyright © 2017 Svetliy. All rights reserved.
//

import Foundation
import UIKit

class CollectionCell: UICollectionViewCell {
    var titleLabel: UILabel!
    var descriptionLabel: UILabel!
    var backgroundViewCell = UIView()
    var whiteRoundedView = UIView()
    var addToArticlesList: UIButton!
    var shareButton: UIButton!
    var backgroundViewImage = UIImageView()
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return layoutAttributes
    }
}

