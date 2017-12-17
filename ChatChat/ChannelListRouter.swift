//
//  ChannelListRouter.swift
//  ChatChat
//
//  Created by Kenneth Yip on 2017-11-23.
//  Copyright (c) 2017 Razeware LLC. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

@objc protocol ChannelListRoutingLogic
{
  //func routeToSomewhere(segue: UIStoryboardSegue?)
}

protocol ChannelListDataPassing
{
  var dataStore: ChannelListDataStore? { get }
}

class ChannelListRouter: NSObject, ChannelListRoutingLogic, ChannelListDataPassing
{
  weak var viewController: ChannelListViewController?
  var dataStore: ChannelListDataStore?
  
  // MARK: Routing
  
  func routeToShowChannel(segue: UIStoryboardSegue?)
  {
    if let segue = segue {
      let destinationVC = segue.destination as! ChatViewController
      var destinationDS = destinationVC.router!.dataStore!
      passDataToChatViewController(source: dataStore!, destination: &destinationDS)
    }
  }
  
  // MARK: Passing data
  
  func passDataToChatViewController(source: ChannelListDataStore, destination: inout ChatDataStore)
  {
    destination.channel = source.channel
    destination.senderDisplayName = source.senderDisplayName
  }
}