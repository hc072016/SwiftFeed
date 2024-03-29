//
//  NewsFeed.swift
//  SwiftFeed
//
//  Created by Howie C on 6/26/19.
//  Copyright © 2019 Howie C. All rights reserved.
//

import Foundation

struct NewsFeed {
    
    let id: String
    let title: String
    let text: String
    let thumbnail: Thumbnail?
    
    init(id: String, title: String, text: String, thumbnail: Thumbnail? = nil) {
        self.id = id
        self.title = title
        self.text = text
        self.thumbnail = thumbnail
    }
    
}

struct Thumbnail {
    
    let id: String
    let width: UInt
    let height: UInt
    
    init(id: String, width: UInt, height: UInt) {
        self.id = id
        self.width = width
        self.height = height
    }
    
}
