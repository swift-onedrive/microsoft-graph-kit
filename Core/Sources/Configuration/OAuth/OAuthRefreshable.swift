//
//  File.swift
//  
//
//  Created by vine on 2021/1/4.
//
/*
 https://docs.microsoft.com/zh-cn/azure/active-directory/develop/v2-oauth2-client-creds-grant-flow
 */
import Foundation
import NIO

let MsGraphOauthTokenUrl = "https://login.microsoftonline.com/{tenant}/oauth2/v2.0/token"
let MsGraphOauthTokenAudience = MsGraphOauthTokenUrl

public protocol OAuthRefreshable {
    func isFresh(token: OAuthAccessToken, created: Date) -> Bool
    func refresh() -> EventLoopFuture<OAuthAccessToken>
}

extension OAuthRefreshable {
    public func isFresh(token: OAuthAccessToken, created: Date) -> Bool {
        let now = Date()
        // Check if the token is about to expire within the next 15 seconds.
        // This gives us a buffer and avoids being too close to the expiration when making requests.
        let expiration = created.addingTimeInterval(TimeInterval(token.expires_in - 15))
        
        return expiration > now
    }
}
