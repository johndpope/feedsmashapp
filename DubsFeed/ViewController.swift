//
//  ViewController.swift
//  Feedsmash
//
//  Created by ChangJoo Park on 2016. 4. 7..
//  Copyright © 2016년 ChangJoo Park. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  var feedController: FeedController?
  var feedItems: [FeedItem]?
  var playStateCell: FeedItemCell?
  
  var refreshControl: UIRefreshControl!
  var customView: UIView!
  var labelsArray: Array<UILabel> = []
  
  @IBOutlet weak var tableView: UITableView!
  
  
  // Play State
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    // Initialize refresh control
    refreshControl = UIRefreshControl()
    refreshControl.backgroundColor = UIColor.clearColor()
    refreshControl.tintColor = UIColor.clearColor()
    
    tableView.addSubview(refreshControl)
    loadCustomRefreshContents()
    
    feedController = FeedController()
    updateFeedItems()
  }
  
  func loadCustomRefreshContents() {
    let refreshContents = NSBundle.mainBundle().loadNibNamed("RefreshControl", owner: self, options: nil)
    customView = refreshContents[0] as! UIView
    customView.frame = refreshControl.bounds
    log.info(customView.subviews[0].subviews.count)
    refreshControl.addSubview(customView)
  }
  
  func scrollViewDidScroll(scrollView: UIScrollView) {
    guard let unwrappedCell = playStateCell else {
      return
    }
  }
  
  
  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    if refreshControl.refreshing {
      updateFeedItems()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func updateFeedItems() {
    guard let feedCtrl = feedController else {
      return
    }
    
    feedCtrl.requestDubsmashes { (error) in
      if error != nil  {
        return
      }
      // Load Data
      guard let items = feedCtrl.feedItems else {
        log.error("item is nil")
        return
      }
      self.feedItems = items
      self.tableView.reloadData()
      self.refreshControl.endRefreshing()
    }
  }
}

extension ViewController: UITableViewDelegate {
  
}

extension ViewController: UITableViewDataSource {
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 400
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let unwrappedFeedItems = feedItems else {
      return 0
    }
    
    return unwrappedFeedItems.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell: FeedItemCell = tableView.dequeueReusableCellWithIdentifier("FeedItemCell", forIndexPath: indexPath) as! FeedItemCell
    
    guard let unwrappedfeedItems = feedItems else {
      return cell
    }
    cell.delegate = self
    cell.feedItem = unwrappedfeedItems[indexPath.row] as FeedItem
    cell.parentViewController = self
    return cell
  }
}

extension ViewController: FeedItemCellDelegate {
  func playerDidStart(cell: FeedItemCell) {
    print("playerDidStart")
    playStateCell?.stopVideo()
    playStateCell = cell
  }
  
  func playerDidStop() {
    print("playerDidStop")
    playStateCell = nil
  }
}