//
//  SwiftFeedMasterViewDelegate.swift
//  SwiftFeed
//
//  Created by Howie C on 6/30/19.
//  Copyright © 2019 Howie C. All rights reserved.
//

import UIKit

class SwiftFeedMasterViewDelegate: NewsFeedMasterTableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.tableView(tableView, didSelectRowAt: indexPath)
    }
}
