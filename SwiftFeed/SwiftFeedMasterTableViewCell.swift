//
//  SwiftFeedMasterTableViewCell.swift
//  SwiftFeed
//
//  Created by Howie C on 6/30/19.
//  Copyright © 2019 Howie C. All rights reserved.
//

import UIKit

class SwiftFeedMasterTableViewCell: UITableViewCell {
    
    private var titleLabel = UILabel()
    private var thumbnailImageView = UIImageView()
    private var thumbnailImageViewRatioConstraint: NSLayoutConstraint!
    var title: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }
    var thumbnailImage: UIImage? {
        get {
            return thumbnailImageView.image
        }
        set {
            thumbnailImageView.image = newValue
            thumbnailImageViewRatioConstraint.isActive = false
            let imageSize = newValue?.size
            thumbnailImageViewRatioConstraint = thumbnailImageView.widthAnchor.constraint(equalTo: thumbnailImageView.heightAnchor, multiplier: (imageSize?.height != nil ? imageSize?.width ?? 0 : 0) / (imageSize?.height ?? 1))
            // When a change occurs, the system schedules a deferred layout pass – Apple
            thumbnailImageViewRatioConstraint.isActive = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    private func initialize() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        titleLabel.numberOfLines = 0
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
        titleLabel.setContentHuggingPriority(UILayoutPriority(751), for: .vertical)
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.insertSubview(thumbnailImageView, belowSubview: titleLabel)
        thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15).isActive = true
        thumbnailImageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor, constant: 0).isActive = true
        thumbnailImageView.heightAnchor.constraint(equalTo: titleLabel.heightAnchor, constant: 0).isActive = true
        thumbnailImageViewRatioConstraint = thumbnailImageView.widthAnchor.constraint(equalTo: thumbnailImageView.heightAnchor, multiplier: 0)
        thumbnailImageViewRatioConstraint.isActive = true
    }
    
}
