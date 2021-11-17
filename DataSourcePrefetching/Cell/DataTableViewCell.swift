//
//  DataTableViewCell.swift
//  DataSourcePrefetching
//
//  Created by Ashraf Uddin on 16/11/21.
//

import UIKit

protocol DataTableViewCellDelegate: AnyObject {
    func horiozontalCellDidScroll(indexPath: IndexPath, contentOffSet: CGPoint)
}

class DataTableViewCell: UITableViewCell, Nibable {
    static var id = "DataTableViewCell"
    
    var collectionOffset: CGPoint = CGPoint.zero
    var indexPath: IndexPath?
    weak var viewDelegate: DataTableViewCellDelegate?
    var movies: [Movie]? {
        didSet {
            guard movies != nil else { return }
            collectionView.reloadData()
            collectionView.contentOffset = self.collectionOffset
        }
    }
    
    
    lazy var titleLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        
        $0.textColor = .black
        $0.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        return $0
    }(UILabel())
    
    lazy var collectionView: UICollectionView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        
        $0.dataSource = self
        $0.delegate = self
        $0.backgroundColor = .systemBackground
        $0.showsHorizontalScrollIndicator = false
        
        $0.register(HorizontalCollectionViewCell.self)
        return $0
    }(UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()))
    
    let activityView: UIActivityIndicatorView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        
        $0.hidesWhenStopped = true
        $0.color = .gray
        $0.layer.cornerRadius = 15
        return $0
    } (UIActivityIndicatorView(style: .medium))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        selectionStyle = .none
        [titleLabel, collectionView, activityView].forEach { contentView.addSubview($0) }
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            collectionView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: 0),
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            collectionView.heightAnchor.constraint(equalToConstant: 150),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            activityView.topAnchor.constraint(equalTo: collectionView.topAnchor),
            activityView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            activityView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            activityView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        movies = nil
        collectionView.dataSource = nil
        collectionView.delegate = nil
        self.collectionOffset = CGPoint.zero    }
    
    func setUp(with category: String) {
        titleLabel.text = category
    }
    
    func fetchData(with query: String) {
        self.activityView.startAnimating()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        DataService.shared.getMovies(with: query) { response, error in
            DispatchQueue.main.async {
                self.activityView.stopAnimating()
                guard let movies = response?.results else {
                    return
                }
                self.movies = movies
            }
        }
    }
    
    func cancelData(with query: String) {
        DataService.shared.cancelRequest(with: query)
    }
}

//MARK: UICollectionViewDatasource & Delegate methods
extension DataTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HorizontalCollectionViewCell.id, for: indexPath) as? HorizontalCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if let movieUrl = movies?[indexPath.row].fullPosterPath {
            cell.setUp(with: movieUrl)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 100.0, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16.0
    }

}

extension DataTableViewCell: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let indexPath = self.indexPath else { return }
        
        viewDelegate?.horiozontalCellDidScroll(indexPath: indexPath, contentOffSet: scrollView.contentOffset)
    }
}
