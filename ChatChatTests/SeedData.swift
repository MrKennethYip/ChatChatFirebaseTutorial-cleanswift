//
//  SeedData.swift
//  ChatChat
//
//  Created by Kenneth Yip on 2017-12-13.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

@testable import ChatChat
import XCTest

struct Seeds {
    struct Channels {
        static let swiftChannel = Channel(id: "Swift101", name: "Swifty Channel")
        static let iosChannel = Channel(id: "iOS101", name: "iOS Channel")
    }
    
    struct Messages {
        static let dummyResTextMessage = Chat.TextMessage.Response(senderId: "dummyTextId", senderName: "dummyName", text: "Dummy Text")
        static let dummyResPhotoMessage = Chat.PhotoMessage.Response(senderId: "dummyPhotoId", key: "dummyPhotoKey", photoUrl: "http://random.cat/view?i=1045")
        static let dummyResImageData = Chat.ImageData.Response(key: "dummyImageKey", image: UIImage.init(named: "AppIcon"))
        static let dummyVMTextMessage = Chat.TextMessage.ViewModel(senderId: "dummyTextId", senderName: "dummyName", text: "Dummy Text")
        static let dummyVMPhotoMessage = Chat.PhotoMessage.ViewModel(senderId: "dummyPhotoId", key: "dummyPhotoKey", photoUrl: "http://random.cat/view?i=1045")
        static let dummyVMImageData = Chat.ImageData.ViewModel(key: "dummyImageKey", image: UIImage.init(named: "AppIcon"))
    }
}
