//
//  MsGraphAPIError.swift
//  Core
//
//  Created by vine on 2021/1/4.
//
// https://docs.microsoft.com/zh-cn/graph/errors

import Foundation
import NIOHTTP1

public protocol MsGraphAPIError: Error {}


enum OauthRefreshError: MsGraphAPIError {
    case noResponse(HTTPResponseStatus)
    
    var localizedDescription: String {
        switch self {
        case .noResponse(let status):
            return "A request to the OAuth authorization server failed with response status \(status.code)."
        }
    }
}
