//
//  ChatInteractorTests.swift
//  ChatChat
//
//  Created by Kenneth Yip on 2017-12-13.
//  Copyright (c) 2017 Razeware LLC. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

@testable import ChatChat
import XCTest

class ChatInteractorTests: XCTestCase
{
  // MARK: Subject under test
  
  var sut: ChatInteractor!
  
  // MARK: Test lifecycle
  
  override func setUp()
  {
    super.setUp()
    setupChatInteractor()
  }
  
  override func tearDown()
  {
    super.tearDown()
  }
  
  // MARK: Test setup
  
  func setupChatInteractor()
  {
    sut = ChatInteractor()
  }
  
  // MARK: Test doubles
  
  class ChatPresentationLogicSpy: ChatPresentationLogic
  {
    var presentTextMessageCalled = false
    func presentTextMessage(response: Chat.TextMessage.Response) {
        presentTextMessageCalled = true
    }
    
    var presentPhotoMessageCalled = false
    func presentPhotoMessage(response: Chat.PhotoMessage.Response) {
        presentPhotoMessageCalled = true
    }
    
    var presentFetchedImageCalled = false
    func presentFetchedImage(response: Chat.ImageData.Response) {
        presentFetchedImageCalled = true
    }

    var presentTypingUpdateCalled = false
    func presentTypingUpdate(response: Chat.Typing.Response) {
        presentTypingUpdateCalled = true
    }
    
    var presentPhotoMessageSentCalled = false
    func presentPhotoMessageSent() {
        presentPhotoMessageSentCalled = true
    }

  }
  
    class ChatWorkerSpy: ChatWorker {
        var observeMessagesCalled = false
        override func observeMessages(onTextUpdate: @escaping (String, String, String) -> Void, onPhotoUpdate: @escaping (String, String, String) -> Void, onPhotoChange: @escaping (String, String) -> Void) {
            observeMessagesCalled = true
        }
        var fetchImageDataAtURLCalled = false
        var fetchImageDataAtURLCompletionHandler: ((String?, UIImage?) -> Void)? = nil
        override func fetchImageDataAtURL(photoURL: String, key: String?, completionHandler: @escaping (String?, UIImage?) -> Void) {
            fetchImageDataAtURLCalled = true
            fetchImageDataAtURLCompletionHandler = completionHandler
            completionHandler("fetchedKey",UIImage())
        }
        
        override func setTyping(isTyping:Bool) {}
        
        var observeTypingCalled = false
        var onTypingUpdateHandler: ((Int) -> Void)? = nil
        override func observeTyping(onTypingUpdate: @escaping (Int) -> Void) {
            observeTypingCalled = true
            onTypingUpdateHandler = onTypingUpdate
        }
        
        var sendMessageCalled = false
        override func sendMessage(text:String, displayName:String) {
            sendMessageCalled = true
        }
        
        var getPhotoMessageKeyCalled = false
        override func getPhotoMessageKey() -> String? {
            getPhotoMessageKeyCalled = true
            return "dummyKey"
        }
        
        var storeCalled = false
        override func store(file fileURL:URL, atPath path:String, withKey key:String) {
            storeCalled = true
        }
    }
    
    
    
  // MARK: Tests
      func testObserveMessages()
      {
        // Given
        let workerSpy = ChatWorkerSpy(chatApi: FirebaseBackend())
        sut.chatWorker = workerSpy
        
        // When
        sut.observeMessages()
    
        // Then
        XCTAssertTrue(workerSpy.observeMessagesCalled, "observeMessages() should ask the worker to start observing messages")
      }
    
    func testFetchImageDataAtURL()
    {
        // Given
        let workerSpy = ChatWorkerSpy(chatApi: FirebaseBackend())
        sut.chatWorker = workerSpy
        let dummyReqImageData = Chat.ImageData.Request(key: "dummyKey", photoUrl: "dummyUrl")
        let presenterSpy = ChatPresentationLogicSpy()
        sut.presenter = presenterSpy
        
        // When
        sut.fetchImageDataAtURL(request: dummyReqImageData)
        workerSpy.fetchImageDataAtURLCompletionHandler!("fetchedKey",UIImage())
        
        // Then
        XCTAssertTrue(workerSpy.fetchImageDataAtURLCalled, "fetchImageDataAtURL() should ask the worker to fetch data at url")
        XCTAssertTrue(presenterSpy.presentFetchedImageCalled, "fetchImageDataAtURL() should ask the presenter to present the fetched Image")
    }
    
    func testObserveTyping()
    {
        // Given
        let workerSpy = ChatWorkerSpy(chatApi: FirebaseBackend())
        sut.chatWorker = workerSpy
        let presenterSpy = ChatPresentationLogicSpy()
        sut.presenter = presenterSpy

        // When
        sut.observeTyping()
        workerSpy.onTypingUpdateHandler!(1)
        
        // Then
        XCTAssertTrue(workerSpy.observeTypingCalled, "observeTyping() should ask the worker to start observing typing")
        XCTAssertTrue(presenterSpy.presentTypingUpdateCalled, "observeTyping() should ask the presenter to present typing Update")
    }
    
    func testSendMessage()
    {
        // Given
        let workerSpy = ChatWorkerSpy(chatApi: FirebaseBackend())
        sut.chatWorker = workerSpy
        let dummyMessage = Chat.TextMessage.Request(senderDisplayName: "dummyName", senderText: "dummyText")
        
        // When
        sut.sendMessage(request: dummyMessage)
        
        // Then
        XCTAssertTrue(workerSpy.sendMessageCalled, "observeTyping() should ask the worker to start observing typing")
    }
    
    func testSendPhotoMessage()
    {
        // Given
        let workerSpy = ChatWorkerSpy(chatApi: FirebaseBackend())
        sut.chatWorker = workerSpy
        let presenterSpy = ChatPresentationLogicSpy()
        sut.presenter = presenterSpy
        let dummyMessage = Chat.PhotoMessage.Request(photoReferenceUrl: URL(string: "https://clean-swift.com/")!)
        
        // When
        sut.sendPhotoMessage(request: dummyMessage)
        
        // Then
        XCTAssertTrue(workerSpy.getPhotoMessageKeyCalled, "sendPhotoMessage() should ask the worker for a unique key to photo")
        XCTAssertTrue(presenterSpy.presentPhotoMessageSentCalled, "sendPhotoMessage() should ask the presenter to present presentPhotoMessageSent")
    }
    
    func testPresentTextMessage()
    {
        // Given
        let workerSpy = ChatWorkerSpy(chatApi: FirebaseBackend())
        sut.chatWorker = workerSpy
        let presenterSpy = ChatPresentationLogicSpy()
        sut.presenter = presenterSpy

        // When
        sut.onTextUpdate(senderId: sut.senderId, senderName: "DummyName", text: "DummyText")

        // Then
        XCTAssertTrue(presenterSpy.presentTextMessageCalled, "onTextUpdate(senderId:, senderName:, text:) should ask the presenter to present text message")
    }

    func testPresentPhotoMessage()
    {
        // Given
        let workerSpy = ChatWorkerSpy(chatApi: FirebaseBackend())
        sut.chatWorker = workerSpy
        let presenterSpy = ChatPresentationLogicSpy()
        sut.presenter = presenterSpy
        
        // When
        sut.onPhotoUpdate(senderId: sut.senderId, key: "dummyKey", photoUrl: "gs://dummyurl")
        
        // Then
        XCTAssertTrue(presenterSpy.presentPhotoMessageCalled, "onPhotoUpdate(senderId:, senderName:, text:) should ask the presenter to present photo message")
        XCTAssertTrue(workerSpy.fetchImageDataAtURLCalled, "fetchImageDataAtURL() should ask the worker to fetch data at url")
    }
    
    func testStore()
    {
        // Given
        let workerSpy = ChatWorkerSpy(chatApi: FirebaseBackend())
        sut.chatWorker = workerSpy
        
        // When
        sut.storeFileHandler(imageFileURL: URL(string: "imageFileUrl")!, path: "dummyPath", key: "dummyKey")
        
        // Then
        XCTAssertTrue(workerSpy.storeCalled, "storeFileHandler() should ask the worker to store file")
    }
}