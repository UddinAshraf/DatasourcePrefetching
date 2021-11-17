//
//  HorizontalCollectionViewCell.swift
//  DataSourcePrefetching
//
//  Created by Ashraf Uddin on 16/11/21.
//

import UIKit
import SDWebImage

class HorizontalCollectionViewCell: UICollectionViewCell, Nibable {
    static var id = "HorizontalCollectionViewCell"
    
    private lazy var imageView: UIImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .gray.withAlphaComponent(0.5)
        $0.contentMode = .scaleAspectFill
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 10
        return $0
    }(UIImageView())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
        ])
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUp(with imageUrl: String) {
        guard let url = URL(string: imageUrl) else { return }
        
        imageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "placeholder"), options: .highPriority, context: nil)
    }
}
