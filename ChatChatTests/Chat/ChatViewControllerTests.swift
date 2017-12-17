//
//  ChatViewControllerTests.swift
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
import JSQMessagesViewController

class ChatViewControllerTests: XCTestCase
{
  // MARK: Subject under test
  
  var sut: ChatViewController!
  var window: UIWindow!
  
  // MARK: Test lifecycle
  
  override func setUp()
  {
    super.setUp()
    window = UIWindow()
    setupChatViewController()
  }
  
  override func tearDown()
  {
    window = nil
    super.tearDown()
  }
  
  // MARK: Test setup
  
  func setupChatViewController()
  {
    let bundle = Bundle.main
    let storyboard = UIStoryboard(name: "Main", bundle: bundle)
    sut = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
  }
  
  func loadView()
  {
    window.addSubview(sut.view)
    RunLoop.current.run(until: Date())
  }
  
  // MARK: Test doubles
  
  class ChatBusinessLogicSpy: ChatBusinessLogic
  {
    var chatChannelSaved = false
    func setChatChannel(request: Chat.SelectedChannel.Request) {
        chatChannelSaved = true
    }
    
    var observeMessagesCalled = false
    func observeMessages() {
        observeMessagesCalled = true
    }
    
    var fetchImageDataAtUrlCalled = false
    func fetchImageDataAtURL(request: Chat.ImageData.Request) {
        fetchImageDataAtUrlCalled = true
    }
    
    var setTypingCalled = false
    func setTyping(request: Chat.Typing.Request) {
        setTypingCalled = true
    }

    var observeTypingCalled = false
    func observeTyping() {
        observeTypingCalled = true
    }
    
    var sendMesssageCalled = false
    func sendMessage(request: Chat.TextMessage.Request) {
        sendMesssageCalled = true
    }
    
    var sendPhotoMessageCalled = false
    func sendPhotoMessage(request: Chat.PhotoMessage.Request) {
        sendPhotoMessageCalled = true
    }
    
  }
  
  // MARK: Tests
  
  func testChatChannelShouldBeSetWhenViewIsLoaded()
  {
    // Given
    let spy = ChatBusinessLogicSpy()
    sut.interactor = spy
    
    // When
    loadView()
    
    // Then
    XCTAssertTrue(spy.chatChannelSaved, "viewDidLoad() should ask the interactor to set the chat channel")
  }
    
    func testObserveMessagesCalledWhenViewIsLoaded()
    {
        // Given
        let spy = ChatBusinessLogicSpy()
        sut.interactor = spy
        
        // When
        loadView()
        
        // Then
        XCTAssertTrue(spy.observeMessagesCalled, "viewDidLoad() should ask the interactor to start observing messages")
    }
  
    func testDisplayTextMessage()
    {
        // Given
        let viewModel = Seeds.Messages.dummyVMTextMessage
        let messageCount = sut.messages.count
        let spy = ChatBusinessLogicSpy()
        sut.interactor = spy
        
        // When
        loadView()
        sut.displayTextMessage(viewModel: viewModel)

        // Then
        XCTAssertEqual(sut.messages.count, messageCount + 1, "displayTextMessage(viewModel:) should update and add to the list of messages")
    }
    
    func testDisplayPhotoMessage()
    {
        // Given
        let spy = ChatBusinessLogicSpy()
        sut.interactor = spy
        let viewModel = Seeds.Messages.dummyVMPhotoMessage
        let messageCount = sut.messages.count
        
        // When
        loadView()
        sut.displayPhotoMessage(viewModel: viewModel)
        
        // Then
        XCTAssertEqual(sut.messages.count, messageCount + 1, "displayPhotoMessage(viewModel:) should update and add to the list of messages")
    }

    func testDisplayFetchedImage() {
        // Given
        let spy = ChatBusinessLogicSpy()
        sut.interactor = spy
        let viewModel = Seeds.Messages.dummyVMImageData
        sut.photoMessageMap[viewModel.key!] = JSQPhotoMediaItem(maskAsOutgoing: true)
        let messageMapCount = sut.photoMessageMap.count

        // When
        loadView()
        sut.displayFetchedImage(viewModel: viewModel)
        
        // Then
        XCTAssertEqual(sut.photoMessageMap.count, messageMapCount - 1, "displayFetchedImage(viewModel:) should update and remove media item from photoMessageMap")
    }
    
    
    func testObserveTyping() {
        // Given
        let spy = ChatBusinessLogicSpy()
        sut.interactor = spy

        // When
        loadView()
        sut.viewDidAppear(true)
        
        // Then
        XCTAssertTrue(spy.observeTypingCalled, "viewDidAppear() should ask the interactor to start observing typing")
    }
    
    func testSendMessage() {
        // Given
        let spy = ChatBusinessLogicSpy()
        sut.interactor = spy
        let dummyButton: UIButton = UIButton()
        
        // When
        loadView()
        sut.didPressSend(dummyButton, withMessageText: "dummyText", senderId: sut.senderId, senderDisplayName: sut.senderDisplayName, date: Date())
        
        // Then
        XCTAssertTrue(spy.sendMesssageCalled, "didPressSend() should ask the interactor to send the message")
    }
    
    func testSendPhotoMessage() {
        // Given
        let spy = ChatBusinessLogicSpy()
        sut.interactor = spy
        let dummyImagePicker = UIImagePickerController()
        let dummyMedia = URL(string: "https://clean-swift.com")
        let dummyInfo: [String:Any] = [UIImagePickerControllerReferenceURL:dummyMedia as Any]
        
        // When
        loadView()
        sut.imagePickerController(dummyImagePicker, didFinishPickingMediaWithInfo: dummyInfo)
        
        // Then
        XCTAssertTrue(spy.sendPhotoMessageCalled, "imagePickerController() should ask the interactor to send the photo message")
    }
    
}







