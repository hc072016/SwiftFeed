//
//  NewsFeedDetailViewController.swift
//  SwiftFeed
//
//  Created by Howie C on 6/26/19.
//  Copyright © 2019 Howie C. All rights reserved.
//

import UIKit

protocol NewsFeedDetailViewModel {
    
    func title() -> String
    
}

class NewsFeedDetailViewController: UIViewController {
    
    var newsFeedDetailViewModel: NewsFeedDetailViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.white
        title = newsFeedDetailViewModel.title()
    }
    
}
