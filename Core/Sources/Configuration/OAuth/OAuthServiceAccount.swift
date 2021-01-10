//
//  File.swift
//  
//
//  Created by vine on 2021/1/4.
//

import Foundation
import NIOHTTP1
import AsyncHTTPClient
import NIO

public final class OAuthServiceAccount: OAuthRefreshable {
    public let httpClient: HTTPClient
    public let credentials: MsGraphAccountCredentials
    public let eventLoop: EventLoop
    
    public let scope: String
    
    private let decoder = JSONDecoder()
    
    init(credentials: MsGraphAccountCredentials, scopes: [MsGraphAPIScope] = [MsGraphDefaultScope.defalut], httpClient: HTTPClient, eventLoop: EventLoop) {
        self.credentials = credentials
        self.httpClient = httpClient
        self.eventLoop = eventLoop
        self.scope = scopes.map { $0.value }.joined(separator: " ")
    }
    
    public func refresh() -> EventLoopFuture<OAuthAccessToken> {
        do {
            let headers: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded"]
            let body: HTTPClient.Body = .string("client_id=\(credentials.client_id)&scope=\(scope)&client_secret=\(credentials.secret)&grant_type=\("client_credentials")"
                                        .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
            let tokenUrl = MsGraphOauthTokenUrl.replacingOccurrences(of: "{tenant}", with: "\(credentials.tenant_id)", range: nil)
            let request = try HTTPClient.Request(url: tokenUrl, method: .POST, headers: headers, body: body)
            
            return httpClient.execute(request: request, eventLoop: .delegate(on: self.eventLoop)).flatMap { response in
                
                guard var byteBuffer = response.body,
                let responseData = byteBuffer.readData(length: byteBuffer.readableBytes),
                response.status == .ok else {
                    return self.eventLoop.makeFailedFuture(OauthRefreshError.noResponse(response.status))
                }
                
                do {
                    let tokenModel = try self.decoder.decode(OAuthAccessToken.self, from: responseData)
                    return self.eventLoop.makeSucceededFuture(tokenModel)
                } catch {
                    return self.eventLoop.makeFailedFuture(error)
                }
            }
            
        } catch {
            return self.eventLoop.makeFailedFuture(error)
        }
    }
}
