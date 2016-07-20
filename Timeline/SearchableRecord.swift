//
//  SearchableRecord.swift
//  Timeline
//
//  Created by Jeff Norton on 7/20/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation

@objc
protocol SearchableRecord {
    
    // MARK: - Method(s)
    
    func matchesSearchTerm(searchTerm: String) -> Bool
}