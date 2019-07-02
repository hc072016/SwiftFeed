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

protocol NewsFeedMasterTableViewModel {
    
    func newsFeedCount() -> Int
    
    func newsFeed(atIndexPath indexPath: IndexPath) -> SwiftFeedMasterViewNewsFeed
    
    func rowHeight(AtIndexPath indexPath: IndexPath) -> CGFloat
    
    func indexPath(forIDPath idPath: String) -> IndexPath?
    
    func loadThumbnail(atIndexPath indexPath: IndexPath, withCompletionHandler completionHandler: @escaping (Data, Error?) -> Void)
    
}

// dependency inversion
// apply façade design pattern when it gets too complex
protocol NewsFeedMasterViewModel: NewsFeedMasterTableViewModel {
    
    func title() -> String
    
    func reloadNewsFeeds(withCompletionHandler completionHandler: @escaping (Error?) -> Void)
    
    func cancel()
}

protocol NewsFeedMasterTableViewDelegateDelegate: AnyObject {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    
}

// 'weak' cannot be applied to a property declaration in a protocol
class NewsFeedMasterTableViewDelegate: NSObject, UITableViewDelegate {
    
    var newsFeedMasterTableViewModel: NewsFeedMasterTableViewModel
    weak var delegate: NewsFeedMasterTableViewDelegateDelegate?
    
    init(newsFeedMasterTableViewModel: NewsFeedMasterTableViewModel) {
        self.newsFeedMasterTableViewModel = newsFeedMasterTableViewModel
    }
}

protocol NewsFeedMasterTableViewDataSource: UITableViewDataSource {
    
    var newsFeedMasterTableViewModel: NewsFeedMasterTableViewModel { get set }
    
    func cellClass() -> AnyClass
    
    func tableViewCellReuseIdentifier() -> String
    
}

class NewsFeedMasterViewController: UIViewController, NewsFeedMasterTableViewDelegateDelegate {
    
    private var tableView: UITableView!
    var newsFeedMasterViewModel: NewsFeedMasterViewModel!
    var newsFeedMasterTableViewDataSource: NewsFeedMasterTableViewDataSource!
    var newsFeedMasterTableViewDelegate: NewsFeedMasterTableViewDelegate!
    weak var delegate: NewsFeedMasterViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.white
        tableView = UITableView(frame: view.bounds, style: .plain)
        if newsFeedMasterViewModel != nil && newsFeedMasterTableViewDataSource != nil {
            title = newsFeedMasterViewModel.title()
            tableView.dataSource = newsFeedMasterTableViewDataSource
            tableView.delegate = newsFeedMasterTableViewDelegate
            newsFeedMasterTableViewDelegate.delegate = self
            tableView.register(newsFeedMasterTableViewDataSource.cellClass(), forCellReuseIdentifier: newsFeedMasterTableViewDataSource.tableViewCellReuseIdentifier())
            newsFeedMasterViewModel.reloadNewsFeeds { [weak self] (error) in
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
        //tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // auto layout begin; performance would be better without auto layout table view cells
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = 85.0 // should as accurate as possible
        tableView.rowHeight = UITableView.automaticDimension
        // auto layout end
        view.addSubview(tableView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        newsFeedMasterViewModel.cancel()
        super.viewWillDisappear(animated)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.tableViewDidSelectRow(atIndexPath: indexPath)
    }
    
}
