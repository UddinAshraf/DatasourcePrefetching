//
//  DataListViewController.swift
//  DataSourcePrefetching
//
//  Created by Ashraf Uddin on 16/11/21.
//

import Foundation
import UIKit

class DataListViewController: UIViewController {
    
    lazy var tableView: UITableView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.dataSource = self
        $0.delegate = self
        $0.prefetchDataSource = self
        $0.separatorStyle = .none
        $0.register(DataTableViewCell.self)
        $0.estimatedRowHeight = 80
        $0.rowHeight = UITableView.automaticDimension
        $0.separatorStyle = .singleLine
        $0.tableFooterView = UIView(frame: CGRect.zero)
        $0.tableHeaderView = UIView(frame: CGRect.zero)
        
        return $0
    } (UITableView())
    
    let viewModel = DataViewModel()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        [tableView].forEach { view.addSubview($0) }
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
        tableView.reloadData()
    }
    
}

//MARK: UITABleViewDataSource and UITableViewDelegeta methods
extension DataListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DataTableViewCell.id) as? DataTableViewCell else {
            return UITableViewCell()
        }
        
        let category = viewModel.categories[indexPath.row]
        cell.setUp(with: category)
        cell.indexPath = indexPath
        cell.viewDelegate = self
        cell.collectionOffset = viewModel.contentOffsets[indexPath.row]
        if cell.movies == nil {
            cell.fetchData(with: category)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

//MARK: UItableViewDataSourcePrefetching
extension DataListViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        print("prefetchRowsAt \(indexPaths)")
        indexPaths.forEach { indexPath in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DataTableViewCell.id) as? DataTableViewCell else {
                return
            }
            let category = viewModel.categories[indexPath.row]
            cell.fetchData(with: category)
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        print("cancelPrefetchingForRowsAt \(indexPaths)")
        indexPaths.forEach { indexPath in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DataTableViewCell.id) as? DataTableViewCell else {
                return
            }
            let category = viewModel.categories[indexPath.row]
            cell.cancelData(with: category)
        }
    }
}

//MARK: DataTableViewCellDelegate methods
extension DataListViewController: DataTableViewCellDelegate {
    func horiozontalCellDidScroll(indexPath: IndexPath, contentOffSet: CGPoint) {
        self.viewModel.contentOffsets[indexPath.row] = contentOffSet
    }
}
