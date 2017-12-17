//
//  ChannelListWorker.swift
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

class ChannelListWorker
{
    var channelApi: ChannelAPIProtocol
    
    init (channelApi: ChannelAPIProtocol) {
        self.channelApi = channelApi
    }
    
    func createChannel(channel:Channel, onComplete: @escaping (Channel?, BackendNetworkError?) -> Void) {
        self.channelApi.createChannel(channel:channel, onComplete: onComplete)
    }
    func observeChannels(onChannelUpdate: @escaping (Channel) -> Void) {
        self.channelApi.observeChannels(onChannelUpdate: onChannelUpdate)
    }
}

protocol ChannelAPIProtocol {
    func createChannel(channel:Channel, onComplete: @escaping (Channel?, BackendNetworkError?) -> Void)
    func observeChannels(onChannelUpdate: @escaping (Channel) -> Void)
}
