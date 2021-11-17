//
//  DataViewModel.swift
//  DataSourcePrefetching
//
//  Created by Ashraf Uddin on 16/11/21.
//

import Foundation
import UIKit

class DataViewModel {
    
    var contentOffsets = [CGPoint]()
    let categories = ["Romance", "Western", "Thriller", "Fiction", "Crime", "Drama", "Horror","Action", "Science", "comedy", "war", "Gangster", "Animation", "Adventure", "Teen", "spy"]
    
    init() {
        for _ in categories {
            contentOffsets.append(CGPoint.zero)
        }
    }
}

