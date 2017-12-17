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

enum Section: Int {
  case createNewChannelSection = 0
  case currentChannelsSection
}

protocol ChannelListDisplayLogic: class
{
    func displayUpdatedChannelList(viewModel: ChannelList.FetchChannels.ViewModel)
    func presentError(viewModel: ChannelList.Error.ViewModel)
}


class ChannelListViewController: UITableViewController, ChannelListDisplayLogic
{
    var interactor: ChannelListBusinessLogic?
    var router: (NSObjectProtocol & ChannelListRoutingLogic & ChannelListDataPassing)?
    
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
        let interactor = ChannelListInteractor()
        let presenter = ChannelListPresenter()
        let router = ChannelListRouter()
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
        if let scene = segue.identifier { //ShowChannel
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }


  // MARK: Properties
  var senderDisplayName: String?
  var newChannelTextField: UITextField?
  
  var channels: [Channel] = []
  
  lazy var firebaseBackend: FirebaseBackend = FirebaseBackend();
    
  override func viewDidLoad() {
    super.viewDidLoad()
    self.senderDisplayName = self.router?.dataStore?.senderDisplayName
    title = "RW RIC"
    interactor?.observeChannels()
  }
    
    func displayUpdatedChannelList(viewModel: ChannelList.FetchChannels.ViewModel) {
        self.channels = viewModel.displayedChannels
        self.tableView.reloadData()
    }
  
    func presentError(viewModel:ChannelList.Error.ViewModel) {
        let alert = UIAlertController(title: "Error", message: viewModel.errorMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
            case .cancel:
                print("cancel")
            case .destructive:
                print("destructive")
            }}))
        self.present(alert, animated: true, completion: nil)
    }

  // MARK :Actions

  @IBAction func createChannel(_ sender: AnyObject) {
    let channelRequestModel = ChannelList.CreateChannel.Request(channelName: newChannelTextField?.text)
    self.interactor?.createChannel(createChannelRequest: channelRequestModel)
  }
    
  // MARK: UITableViewDataSource
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let currentSection: Section = Section(rawValue: section) {
      switch currentSection {
      case .createNewChannelSection:
        return 1
      case .currentChannelsSection:
        return channels.count
      }
    } else {
      return 0
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let reuseIdentifier = (indexPath as NSIndexPath).section == Section.createNewChannelSection.rawValue ? "NewChannel" : "ExistingChannel"
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

    if (indexPath as NSIndexPath).section == Section.createNewChannelSection.rawValue {
      if let createNewChannelCell = cell as? CreateChannelCell {
        newChannelTextField = createNewChannelCell.newChannelNameField
      }
    } else if (indexPath as NSIndexPath).section == Section.currentChannelsSection.rawValue {
      cell.textLabel?.text = channels[(indexPath as NSIndexPath).row].name
    }
    
    return cell
  }

  // MARK: UITableViewDelegate
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if (indexPath as NSIndexPath).section == Section.currentChannelsSection.rawValue {
      let channel = channels[(indexPath as NSIndexPath).row]
        self.interactor?.saveSenderDisplayName(name: self.senderDisplayName!)
        self.interactor?.selectChannel(selectedChannel: channel)
      self.performSegue(withIdentifier: "ShowChannel", sender: channel)
    }
  }
  
}
