//
//  ChatModels.swift
//  ChatChat
//
//  Created by Kenneth Yip on 2017-11-24.
//  Copyright (c) 2017 Razeware LLC. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

enum Chat
{
  // MARK: Use cases
  
  enum TextMessage
  {
    struct Request
    {
        var senderDisplayName:String
        var senderText:String
    }
    struct Response
    {
        var senderId: String
        var senderName: String
        var text: String
    }
    struct ViewModel
    {
        var senderId: String
        var senderName: String
        var text: String
    }
  }
    
    enum PhotoMessage
    {
        struct Request
        {
            var photoReferenceUrl:URL
        }
        struct Response
        {
            var senderId: String
            var key: String
            var photoUrl: String
        }
        struct ViewModel
        {
            var senderId: String
            var key: String
            var photoUrl: String
        }
    }
    enum ImageData
    {
        struct Request
        {
            var key: String
            var photoUrl: String
        }
        struct Response
        {
            var key: String?
            var image: UIImage?
        }
        struct ViewModel
        {
            var key: String?
            var image: UIImage?
        }
    }
    enum Typing
    {
        struct Request
        {
            var isTyping: Bool
        }
        struct Response
        {
            var isTyping: Int
        }
        struct ViewModel
        {
            var isTyping: Int
        }
    }
    enum SelectedChannel
    {
        struct Request
        {
            var channelId: String
        }
        struct Response
        {
        }
        struct ViewModel
        {
        }
    }


}
