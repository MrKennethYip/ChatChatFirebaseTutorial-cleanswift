/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit
import Photos
import JSQMessagesViewController

protocol ChatDisplayLogic: class
{
//    func displaySomething(viewModel: Chat.Something.ViewModel)
    func displayTextMessage(viewModel: Chat.TextMessage.ViewModel)
    func displayPhotoMessage(viewModel: Chat.PhotoMessage.ViewModel)
    func displayFetchedImage(viewModel: Chat.ImageData.ViewModel)
    func displayTypingUpdate(viewModel:Chat.Typing.ViewModel)
    func displayPhotoMessageSent()
}

final class ChatViewController: JSQMessagesViewController, ChatDisplayLogic {
  
    var interactor: ChatBusinessLogic?
    var router: (NSObjectProtocol & ChatRoutingLogic & ChatDataPassing)?
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup()
    {
        let viewController = self
        let interactor = ChatInteractor()
        let presenter = ChatPresenter()
        let router = ChatRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }

    // MARK: Routing
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
    

  // MARK: Properties
  private let imageURLNotSetKey = "NOTSET"
    
  var messages: [JSQMessage] = []
  var photoMessageMap = [String: JSQPhotoMediaItem]()
  
  private var localTyping = false
  var channel: Channel? {
    didSet {
      title = channel?.name
    }
  }

  var isTyping: Bool {
    get {
      return localTyping
    }
    set {
      localTyping = newValue
        let request = Chat.Typing.Request(isTyping: newValue)
      self.interactor?.setTyping(request: request)
    }
  }
  
  lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
  lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
  
  // MARK: View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.senderId = self.router?.dataStore?.senderId
    self.senderDisplayName = router?.dataStore?.senderDisplayName
    self.channel = router?.dataStore?.channel
    let request = Chat.SelectedChannel.Request(channelId: (router?.dataStore?.channel.id)!)
    self.interactor?.setChatChannel(request: request)
    self.interactor?.observeMessages()
    
    // No avatars
    collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
    collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
  }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.interactor?.observeTyping()
    }

    // MARK: Presenter Methods

    func displayTextMessage(viewModel: Chat.TextMessage.ViewModel)
    {
        self.addMessage(withId: viewModel.senderId, name: viewModel.senderName, text: viewModel.text)
        self.finishReceivingMessage()
    }
    
    func displayPhotoMessage(viewModel: Chat.PhotoMessage.ViewModel) {
        if let mediaItem = JSQPhotoMediaItem(maskAsOutgoing: viewModel.senderId == self.senderId) {
            self.addPhotoMessage(withId: viewModel.senderId, key: viewModel.key, mediaItem: mediaItem)
        }
    }
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    private func addPhotoMessage(withId id: String, key: String, mediaItem: JSQPhotoMediaItem) {
        if let message = JSQMessage(senderId: id, displayName: "", media: mediaItem) {
            messages.append(message)
            if (mediaItem.image == nil) {
                photoMessageMap[key] = mediaItem
            }
            collectionView.reloadData()
        }
    }
    
    func displayFetchedImage(viewModel: Chat.ImageData.ViewModel) {
        if let photoKey = viewModel.key, let mediaItem = self.photoMessageMap[photoKey] {
            mediaItem.image = viewModel.image
            self.photoMessageMap.removeValue(forKey: photoKey)
        }
        self.collectionView.reloadData()
    }

    func displayPhotoMessageSent() {
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        finishSendingMessage()
    }

    func displayTypingUpdate(viewModel:Chat.Typing.ViewModel) {
        if self.isTyping {
            return
        }
        self.showTypingIndicator = viewModel.isTyping > 0
        self.scrollToBottom(animated: true)
    }

    
  // MARK: Collection view data source (and related) methods
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
    return messages[indexPath.item]
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return messages.count
  }
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
    let message = messages[indexPath.item] // 1
    if message.senderId == self.senderId { // 2
      return outgoingBubbleImageView
    } else { // 3
      return incomingBubbleImageView
    }
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
    
    let message = messages[indexPath.item]
    
    if message.senderId == self.senderId { // 1
      cell.textView?.textColor = UIColor.white // 2
    } else {
      cell.textView?.textColor = UIColor.black // 3
    }
    
    return cell
  }
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
    return nil
  }
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
    return 15
  }
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView?, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString? {
    let message = messages[indexPath.item]
    switch message.senderId {
    case senderId:
      return nil
    default:
      guard let senderDisplayName = message.senderDisplayName else {
        assertionFailure()
        return nil
      }
      return NSAttributedString(string: senderDisplayName)
    }
  }
    
    // MARK: JSQMessagesViewController methods
  override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
    let request = Chat.TextMessage.Request(senderDisplayName: senderDisplayName, senderText: text)
    self.interactor?.sendMessage(request: request)
    
    // 4
    JSQSystemSoundPlayer.jsq_playMessageSentSound()
    
    // 5
    finishSendingMessage()
    isTyping = false
  }
  
  // MARK: UI and User Interaction
  
  private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
    let bubbleImageFactory = JSQMessagesBubbleImageFactory()
    return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
  }

  private func setupIncomingBubble() -> JSQMessagesBubbleImage {
    let bubbleImageFactory = JSQMessagesBubbleImageFactory()
    return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
  }

  override func didPressAccessoryButton(_ sender: UIButton) {
    let picker = UIImagePickerController()
    picker.delegate = self
    if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
      picker.sourceType = UIImagePickerControllerSourceType.camera
    } else {
      picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
    }
    
    present(picker, animated: true, completion:nil)
  }
    
    // MARK: UITextViewDelegate methods
  
  override func textViewDidChange(_ textView: UITextView) {
    super.textViewDidChange(textView)
    // If the text is not empty, the user is typing
    isTyping = textView.text != ""
  }
}

// MARK: Image Picker Delegate
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController,
                             didFinishPickingMediaWithInfo info: [String : Any]) {

    picker.dismiss(animated: true, completion:nil)

    if let photoReferenceUrl = info[UIImagePickerControllerReferenceURL] as? URL {
      // Handle picking a Photo from the Photo Library
        let request = Chat.PhotoMessage.Request(photoReferenceUrl: photoReferenceUrl)
        self.interactor?.sendPhotoMessage(request: request)
    } else {
      // Handle picking a Photo from the Camera - TODO
    }
  }

  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion:nil)
  }
}
