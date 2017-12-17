//
//  ChatWorker.swift
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

class ChatWorker
{
    var chatApi: ChatAPIProtocol
    init (chatApi:ChatAPIProtocol) {
        self.chatApi = chatApi
    }
    func setChatChannel(channelId:String) -> Void {
        self.chatApi.setChatChannel(channelId: channelId)
    }
    func observeMessages(onTextUpdate: @escaping (_ senderId: String, _ key: String, _ photoUrl: String) -> Void, onPhotoUpdate: @escaping (_ senderId: String, _ key: String, _ photoUrl: String) -> Void, onPhotoChange: @escaping (_ key: String, _ photoUrl: String) -> Void) {
        self.chatApi.observeMessages(onTextUpdate: onTextUpdate, onPhotoUpdate: onPhotoUpdate, onPhotoChange: onPhotoChange)
    }
    func fetchImageDataAtURL(photoURL: String, key: String?, completionHandler: @escaping (_ fetchedKey:String?, _ fetchedImage:UIImage?) -> Void) {
        self.chatApi.fetchImageDataAtURL(photoURL: photoURL, key: key, completionHandler: completionHandler)
    }
    func setTyping(isTyping:Bool) {
        self.chatApi.setTyping(isTyping: isTyping)
    }
    func observeTyping(onTypingUpdate: @escaping (Int) -> Void) {
        self.chatApi.observeTyping(onTypingUpdate: onTypingUpdate)
    }
    func sendMessage(text:String, displayName:String) {
        self.chatApi.sendMessage(text: text, senderDisplayName: displayName)
    }
    func getPhotoMessageKey() -> String? {
        return self.chatApi.getPhotoMessageKey()
    }
    func store(file fileURL:URL, atPath path:String, withKey key:String) {
        self.chatApi.store(file: fileURL, atPath: path, withKey: key)
    }
}

protocol ChatAPIProtocol {
    func setChatChannel(channelId:String)
    func observeMessages(onTextUpdate: @escaping (_ senderId: String, _ key: String, _ photoUrl: String) -> Void, onPhotoUpdate: @escaping (_ senderId: String, _ key: String, _ photoUrl: String) -> Void, onPhotoChange: @escaping (_ key: String, _ photoUrl: String) -> Void)
    func fetchImageDataAtURL(photoURL: String, key: String?, completionHandler: @escaping (_ fetchedKey:String?, _ fetchedImage:UIImage?) -> Void)
    func setTyping(isTyping:Bool)
    func observeTyping(onTypingUpdate: @escaping (Int) -> Void)
    func sendMessage(text:String, senderDisplayName:String)
    func getPhotoMessageKey() -> String?
    func store(file fileURL:URL, atPath path:String, withKey key:String)
}
