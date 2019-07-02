//
//  SwiftFeedMasterTableViewDelegate.swift
//  SwiftFeed
//
//  Created by Howie C on 6/30/19.
//  Copyright © 2019 Howie C. All rights reserved.
//

import UIKit

class SwiftFeedMasterTableViewDelegate: NewsFeedMasterTableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.tableView(tableView, didSelectRowAt: indexPath)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            // crash if fail to cast
            loadThummbnailsForVisibleCells(inTableView: scrollView as! UITableView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // crash if fail to cast
        loadThummbnailsForVisibleCells(inTableView: scrollView as! UITableView)
    }
    
    private func loadThummbnailsForVisibleCells(inTableView tableView: UITableView) {
        if let visibleCellIndexPaths = tableView.indexPathsForVisibleRows {
            for indexPath in visibleCellIndexPaths {
                let newsfeed = newsFeedMasterTableViewModel.newsFeed(atIndexPath: indexPath)
                if let thumbnail = newsfeed.thumbnail {
                    if thumbnail.data == nil {
                        newsFeedMasterTableViewModel.loadThumbnail(atIndexPath: indexPath) { (data, error) in
                            if error == nil {
                                DispatchQueue.main.async { [weak self, weak tableView] in
                                    // read in the main queue to prevent race condiction
                                    // check if the list is updated while downloading
                                    if let indexPath = self?.newsFeedMasterTableViewModel.indexPath(forIDPath: newsfeed.id + "." + thumbnail.id) {
                                        if let tableViewCell = tableView?.cellForRow(at: indexPath) {
                                            // let it crash if the downcast is not successful; ensure the correct cell type used
                                            let swiftFeedMasterTableViewCell = tableViewCell as! SwiftFeedMasterTableViewCell
                                            swiftFeedMasterTableViewCell.thumbnailImage = UIImage(data: data)
                                        } else {
                                            // it means the cell is not visible on screen
                                            // test if .fade animation is ok; saw bugs in the past
                                            tableView?.reloadRows(at: [indexPath], with: .none)
                                        }
                                    }
                                }
                            } else {
                                print("indexPath: \(indexPath) – " + String(describing: error))
                            }
                        }
                    }
                }
            }
        }
    }
    
}

// https://github.com/apple/swift-corelibs-libdispatch

// Queue.swift
// public class func concurrentPerform(iterations: Int, execute work: (Int) -> Void) {
//    _swift_dispatch_apply_current(iterations, work)
//}

// DispatchOverlayShims.h
// static inline void _swift_dispatch_apply_current(
// size_t iterations,
// void SWIFT_DISPATCH_NOESCAPE (^block)(intptr_t)) {
//     dispatch_apply(iterations, (dispatch_queue_t _Nonnull)0, ^(size_t i){
//         block((intptr_t)i);
//         });
// }

// queue.h
/*!
 * @constant DISPATCH_APPLY_AUTO
 *
 * @abstract
 * Constant to pass to dispatch_apply() or dispatch_apply_f() to request that
 * the system automatically use worker threads that match the configuration of
 * the current thread as closely as possible.
 *
 * @discussion
 * When submitting a block for parallel invocation, passing this constant as the
 * queue argument will automatically use the global concurrent queue that
 * matches the Quality of Service of the caller most closely.
 *
 * No assumptions should be made about which global concurrent queue will
 * actually be used.
 *
 * Using this constant deploys backward to macOS 10.9, iOS 7.0 and any tvOS or
 * watchOS version.
 */
// #if DISPATCH_APPLY_AUTO_AVAILABLE
// #define DISPATCH_APPLY_AUTO ((dispatch_queue_t _Nonnull)0)
// #endif

/*!
 * @function dispatch_apply
 *
 * @abstract
 * Submits a block to a dispatch queue for parallel invocation.
 *
 * @discussion
 * Submits a block to a dispatch queue for parallel invocation. This function
 * waits for the task block to complete before returning. If the specified queue
 * is concurrent, the block may be invoked concurrently, and it must therefore
 * be reentrant safe.
 *
 * Each invocation of the block will be passed the current index of iteration.
 *
 * @param iterations
 * The number of iterations to perform.
 *
 * @param queue
 * The dispatch queue to which the block is submitted.
 * The preferred value to pass is DISPATCH_APPLY_AUTO to automatically use
 * a queue appropriate for the calling thread.
 *
 * @param block
 * The block to be invoked the specified number of iterations.
 * The result of passing NULL in this parameter is undefined.
 */
// #ifdef __BLOCKS__
// API_AVAILABLE(macos(10.6), ios(4.0))
// DISPATCH_EXPORT DISPATCH_NONNULL3 DISPATCH_NOTHROW
// void
// dispatch_apply(size_t iterations, dispatch_queue_t queue,
// DISPATCH_NOESCAPE void (^block)(size_t));
// #endif
