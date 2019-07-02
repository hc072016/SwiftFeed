//
//  SwiftFeedMasterViewNewsFeed.swift
//  SwiftFeed
//
//  Created by Howie C on 7/10/19.
//  Copyright © 2019 Howie C. All rights reserved.
//

import Foundation

struct SwiftFeedMasterViewNewsFeed {
    
    let id: String
    let title: String
    let text: String
    var thumbnail: SwiftFeedMasterViewThumbnail?
    
    init(id: String, title: String, text: String, thumbnail: SwiftFeedMasterViewThumbnail? = nil) {
        self.id = id
        self.title = title
        self.text = text
        self.thumbnail = thumbnail
    }
    
}

struct SwiftFeedMasterViewThumbnail {
    
    let id: String
    let width: UInt
    let height: UInt
    var data: Data?
    
    init(id: String, width: UInt, height: UInt, data: Data? = nil) {
        self.id = id
        self.width = width
        self.height = height
        self.data = data
    }
    
}
