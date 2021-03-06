//
//  ChannelListModels.swift
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

enum ChannelList
{
  // MARK: Use cases
  
  enum FetchChannels
  {
    struct Request
    {
    }
    struct Response
    {
        var channels: [Channel]
    }
    struct ViewModel
    {
        var displayedChannels: [Channel]
    }
  }
    
    enum CreateChannel
    {
        struct Request
        {
            var channelName:String?
        }
        struct Response
        {
        }
        struct ViewModel
        {
        }
    }
    
    enum Navigation
    {
        struct Request
        {
            var senderDisplayName:String
        }
        struct Response
        {
        }
        struct ViewModel
        {
        }
    }
    
    enum Error
    {
        struct Request
        {
         
        }
        struct Response
        {
            var errorMessage:String
        }
        struct ViewModel
        {
            var errorMessage:String
        }
    }
}
