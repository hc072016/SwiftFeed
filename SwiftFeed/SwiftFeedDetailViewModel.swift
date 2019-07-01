//
//  SwiftFeedDetailViewModel.swift
//  SwiftFeed
//
//  Created by Howie C on 6/30/19.
//  Copyright © 2019 Howie C. All rights reserved.
//

import UIKit

class SwiftFeedDetailViewModel: NewsFeedDetailViewModel {
    
    private var newsFeed: NewsFeed
    
    init(model newsFeed: NewsFeed) {
        self.newsFeed = newsFeed
    }
    
    func title() -> String {
        return newsFeed.title
    }
    
}
