//
//  BackendDatabaseProtocol.swift
//  ChatChat
//
//  Created by Kenneth Yip on 2017-10-11.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import Foundation

protocol BackendDatabaseProtocol: LoginAPIProtocol, ChannelAPIProtocol, ChatAPIProtocol {
}

enum BackendNetworkError: Equatable, Error
{
    case CannotFetch(String)
    case CannotCreate(String)
    case CannotUpdate(String)
    case CannotDelete(String)
    case CannotComplete(String)
}

func ==(lhs: BackendNetworkError, rhs: BackendNetworkError) -> Bool
{
    switch (lhs, rhs) {
    case (.CannotFetch(let a), .CannotFetch(let b)) where a == b: return true
    case (.CannotCreate(let a), .CannotCreate(let b)) where a == b: return true
    case (.CannotUpdate(let a), .CannotUpdate(let b)) where a == b: return true
    case (.CannotDelete(let a), .CannotDelete(let b)) where a == b: return true
    case (.CannotComplete(let a), .CannotComplete(let b)) where a == b: return true

    default: return false
    }
}
