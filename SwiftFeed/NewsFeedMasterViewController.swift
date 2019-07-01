//
//  NewsFeedMasterViewController.swift
//  SwiftFeed
//
//  Created by Howie C on 6/26/19.
//  Copyright © 2019 Howie C. All rights reserved.
//

import UIKit

// separates the view controller and the model behind view model
protocol NewsFeedMasterViewControllerDelegate: AnyObject {
    
    func tableViewDidSelectRow(atIndexPath indexPath: IndexPath)
    
}

// dependency inversion
protocol NewsFeedMasterViewModel: UITableViewDataSource {
    
    func title() -> String
    
    func tableViewCellReuseIdentifier() -> String
    
    func refresh(withCompletionHandler completionHandler: @escaping (Error?) -> Void)
}

protocol NewsFeedMasterTableViewDelegateDelegate: AnyObject {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    
}

// 'weak' cannot be applied to a property declaration in a protocol
class NewsFeedMasterTableViewDelegate: NSObject, UITableViewDelegate {
    
    var dataSource : UITableViewDataSource
    weak var delegate: NewsFeedMasterTableViewDelegateDelegate?
    
    init(dataSource: UITableViewDataSource) {
        self.dataSource = dataSource
    }
}

class NewsFeedMasterViewController: UIViewController, NewsFeedMasterTableViewDelegateDelegate {
    
    private var tableView: UITableView!
    private let data = ["haha", "hehe", "huhu"]
    var newsFeedMasterViewModel: NewsFeedMasterViewModel!
    var newsFeedMasterTableViewDelegate: NewsFeedMasterTableViewDelegate!
    weak var delegate: NewsFeedMasterViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.white
        tableView = UITableView(frame: view.bounds, style: .plain)
        if newsFeedMasterViewModel != nil && newsFeedMasterTableViewDelegate != nil {
            title = newsFeedMasterViewModel.title()
            tableView.dataSource = newsFeedMasterViewModel
            tableView.delegate = newsFeedMasterTableViewDelegate
            newsFeedMasterTableViewDelegate.delegate = self
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: newsFeedMasterViewModel.tableViewCellReuseIdentifier())
            newsFeedMasterViewModel.refresh { [weak self] (error) in
                DispatchQueue.main.async {
                    if error == nil {
                        self?.tableView.reloadData()
                    } else {
                        let alertController = UIAlertController(title: "Alert", message: String(describing: error), preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self?.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        } else {
            // maybe it is accepable as the business logic grows, so that it is possible to inject model at later point in time
            fatalError("NewsFeedMasterViewController – newsFeedMasterViewModel is nil in viewDidLoad")
        }
        tableView.contentInsetAdjustmentBehavior = .automatic
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(tableView)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.tableViewDidSelectRow(atIndexPath: indexPath)
    }
    
}
