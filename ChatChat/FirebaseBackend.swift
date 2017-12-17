//
//  FirebaseBackend.swift
//  ChatChat
//
//  Created by Kenneth Yip on 2017-10-11.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import Foundation
import Firebase

class FirebaseBackend: BackendDatabaseProtocol {
    
    // MARK: Properties
    private let imageURLNotSetKey = "NOTSET"
    
    lazy var allChannelsRef: FIRDatabaseReference = FIRDatabase.database().reference().child("channels")
    private var allChannelsRefHandle: FIRDatabaseHandle?
    
    var channelRef: FIRDatabaseReference?

    private lazy var messageRef: FIRDatabaseReference = self.channelRef!.child("messages")
    private lazy var userIsTypingRef: FIRDatabaseReference = self.channelRef!.child("typingIndicator").child(self.senderId)
    private lazy var usersTypingQuery: FIRDatabaseQuery = self.channelRef!.child("typingIndicator").queryOrderedByValue().queryEqual(toValue: true)
    fileprivate lazy var storageRef: FIRStorageReference = FIRStorage.storage().reference(forURL: "gs://chitchat-512cb.appspot.com")

    private var newMessageRefHandle: FIRDatabaseHandle?
    private var updatedMessageRefHandle: FIRDatabaseHandle?
    
    var senderId: String!
        
    static var currentUser: String {
        get {
            return (FIRAuth.auth()?.currentUser?.uid)!
        }
    }
    
    var currentUserId: String {
        get {
            return (FIRAuth.auth()?.currentUser?.uid)!
        }
    }
    
    static func configure() {
        FIRApp.configure()
    }
    
    init() {
        self.senderId = FIRAuth.auth()?.currentUser?.uid
    }
    
    deinit {
        if let refHandle = newMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
        if let refHandle = updatedMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
        if let refHandle = allChannelsRefHandle {
            allChannelsRef.removeObserver(withHandle: refHandle)
        }
    }
    
    func signInAnonymously(onComplete: @escaping (Bool, BackendNetworkError?) -> Void) {
        FIRAuth.auth()?.signInAnonymously(completion: { (user, error) in
            if let err:Error = error {
                print(err.localizedDescription)
                onComplete(false, .CannotComplete(err.localizedDescription))
            }
            onComplete(true, nil)
        })
    }
    
    func createChannel(channel:Channel, onComplete: @escaping (Channel?, BackendNetworkError?) -> Void) {
        let newChannelRef = allChannelsRef.childByAutoId()
        let channelItem = [
            "name": channel.name
        ]
        newChannelRef.setValue(channelItem) { (firebaseError, firDatabaseReference) in
            if let error = firebaseError {
                onComplete(nil, BackendNetworkError.CannotCreate(error.localizedDescription))
            } else {
                let newChannel = Channel (id: newChannelRef.key, name: channel.name)
                onComplete(newChannel, nil)
            }
        }
    }
    
//    func setChannel(_ channelId:String) {
//        channelRef = allChannelsRef.child(channelId)
//    }
    
    func setChatChannel(channelId:String) {
        channelRef = allChannelsRef.child(channelId)
    }
    
    func observeMessages(onTextUpdate: @escaping (String, String, String) -> Void, onPhotoUpdate: @escaping (String, String, String) -> Void, onPhotoChange: @escaping (String, String) -> Void) {
        guard channelRef != nil else {
            print("must call setChannel(channelId) to initialize channelRef")
            return
        }
        messageRef = channelRef!.child("messages")
        let messageQuery = messageRef.queryLimited(toLast:25)
        
        // We can use the observe method to listen for new
        // messages being written to the Firebase DB
        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            let messageData = snapshot.value as! Dictionary<String, String>
            
            if let id = messageData["senderId"] as String!,
                let name = messageData["senderName"] as String!,
                let text = messageData["text"] as String!,
                text.characters.count > 0 {
                onTextUpdate(id, name, text);
            } else if let id = messageData["senderId"] as String!,
                let photoURL = messageData["photoURL"] as String! {
                onPhotoUpdate(id, snapshot.key, photoURL)
            } else {
                print("Error! Could not decode message data")
            }
        })
        
        // We can also use the observer method to listen for
        // changes to existing messages.
        // We use this to be notified when a photo has been stored
        // to the Firebase Storage, so we can update the message data
        updatedMessageRefHandle = messageRef.observe(.childChanged, with: { (snapshot) in
            let key = snapshot.key
            let messageData = snapshot.value as! Dictionary<String, String>
            
            if let photoURL = messageData["photoURL"] as String! {
                // The photo has been updated.
                onPhotoChange(key, photoURL)
//                self.fetchImageDataAtURL(photoURL: photoURL, key: key, completionHandler: {_ in})
            }
        })
        
    }

    func fetchImageDataAtURL(photoURL: String, key: String?, completionHandler: @escaping (_ key: String?, _ fetchedImage: UIImage?) -> Void) {
        let storageRef = FIRStorage.storage().reference(forURL: photoURL)
        storageRef.data(withMaxSize: INT64_MAX){ (data, error) in
            if let error = error {
                print("Error downloading image data: \(error)")
                return
            }
            
            storageRef.metadata(completion: { (metadata, metadataErr) in
                if let error = metadataErr {
                    print("Error downloading metadata: \(error)")
                    return
                }
                
                var image: UIImage?;
                if (metadata?.contentType == "image/gif") {
                    image = UIImage.gifWithData(data!)
                } else {
                    image = UIImage.init(data: data!)
                }
                completionHandler(key, image)
            })
        }
    }

    func observeTyping(onTypingUpdate: @escaping (Int) -> Void) {
        guard channelRef != nil else {
            print("must call setChannel(channelId) to initialize channelRef")
            return
        }
        let typingIndicatorRef = channelRef!.child("typingIndicator")
        userIsTypingRef = typingIndicatorRef.child(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        usersTypingQuery = typingIndicatorRef.queryOrderedByValue().queryEqual(toValue: true)
        
        usersTypingQuery.observe(.value) { (data: FIRDataSnapshot) in
            onTypingUpdate(Int(data.childrenCount))
        }
    }
    
    func observeChannels(onChannelUpdate: @escaping (Channel) -> Void) {
        // We can use the observe method to listen for new
        // channels being written to the Firebase DB
        allChannelsRefHandle = allChannelsRef.observe(.childAdded, with: { (snapshot) -> Void in
            let channelData = snapshot.value as! Dictionary<String, AnyObject>
            let id = snapshot.key
            if let name = channelData["name"] as! String!, name.characters.count > 0 {
                let channel = Channel(id: id, name: name)
                onChannelUpdate(channel)
            } else {
                print("Error! Could not decode channel data")
            }
        })
    }
    
    func setTyping(isTyping:Bool) {
        userIsTypingRef.setValue(isTyping)
    }
    
    func setImageURL(_ url: String, forPhotoMessageWithKey key: String) {
        let itemRef = messageRef.child(key)
        itemRef.updateChildValues(["photoURL": url])
    }
    
    func getPhotoMessageKey() -> String? {
        let itemRef = messageRef.childByAutoId()
        
        let messageItem = [
            "photoURL": imageURLNotSetKey,
            "senderId": senderId!,
            ]
        
        itemRef.setValue(messageItem)
        return itemRef.key
    }
    
    func sendPhotoMessage() -> String? {
        let itemRef = messageRef.childByAutoId()
        
        let messageItem = [
            "photoURL": imageURLNotSetKey,
            "senderId": senderId!,
            ]
        
        itemRef.setValue(messageItem)
        return itemRef.key
    }
    
    func sendMessage(text:String, senderDisplayName:String) {
        // 1
        let itemRef = messageRef.childByAutoId()
        
        // 2
        let messageItem = [
            "senderId": senderId!,
            "senderName": senderDisplayName,
            "text": text,
            ]
        
        // 3
        itemRef.setValue(messageItem)
    }

    func store(file fileURL:URL, atPath path:String, withKey key:String) {
        self.storageRef.child(path).putFile(fileURL, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Error uploading photo: \(error.localizedDescription)")
                return
            }
            self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
        }
    }
}
