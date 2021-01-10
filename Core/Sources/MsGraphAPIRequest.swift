//
//  MsGraphAPIRequest.swift
//  Core
//
//  Created by vine on 2021/1/4.
//

import Foundation
import NIO
import AsyncHTTPClient

public protocol MsGraphAPIRequest: class {
    var refreshableToken: OAuthRefreshable { get }
//    var project: String { get }
    var httpClient: HTTPClient { get }
    var responseDecoder: JSONDecoder { get }
    var currentToken: OAuthAccessToken? { get set }
    var tokenCreatedTime: Date? { get set }
    
    /// As part of an API request this returns a valid OAuth token to use with any of the MsGraph.
    /// - Parameter closure: The closure to be executed with the valid access token.
    func withToken<MicrosoftAzureModel>(_ closure: @escaping (OAuthAccessToken) -> EventLoopFuture<MicrosoftAzureModel>) -> EventLoopFuture<MicrosoftAzureModel>
}

extension MsGraphAPIRequest {
    public func withToken<MicrosoftAzureModel>(_ closure: @escaping (OAuthAccessToken) -> EventLoopFuture<MicrosoftAzureModel>) -> EventLoopFuture<MicrosoftAzureModel> {
        guard let token = currentToken,
            let created = tokenCreatedTime,
            refreshableToken.isFresh(token: token, created: created) else {
            return refreshableToken.refresh().flatMap { newToken in
                self.currentToken = newToken
                self.tokenCreatedTime = Date()

                return closure(newToken)
            }
        }

        return closure(token)
    }

}

extension String {
    //将原始的url编码为合法的url
    public
    func urlEncoded() -> String {
        let encodeUrlString = self.addingPercentEncoding(withAllowedCharacters:
            .urlQueryAllowed)
        return encodeUrlString ?? ""
    }
     
    //将编码后的url转换回原始的url
    public
    func urlDecoded() -> String {
        return self.removingPercentEncoding ?? ""
    }
}


extension EventLoop {
    /// Returns a new `EventLoopFuture` that succeeds only when all the provided futures succeed.
    /// The new `EventLoopFuture` contains an array of results, maintaining same ordering as the futures.
    ///
    /// The returned `EventLoopFuture` will fail if any of the provided futures fails. All remaining
    /// `EventLoopFuture` objects will be ignored.
    /// - Parameter futures: An array of futures to flatten into a single `EventLoopFuture`.
    /// - Returns: A new `EventLoopFuture` with all the resolved values of the input collection.
    public func flatten<T>(_ futures: [EventLoopFuture<T>]) -> EventLoopFuture<[T]> {
        return EventLoopFuture<T>.whenAllSucceed(futures, on: self)
    }
}

extension Collection {
    /// Converts a collection of `EventLoopFuture`s to an `EventLoopFuture` that wraps an array with the future values.
    ///
    /// Acts as a helper for the `EventLoop.flatten(_:[EventLoopFuture<Value>])` method.
    ///
    ///     let futures = [el.future(1), el.future(2), el.future(3), el.future(4)]
    ///     let flattened = futures.flatten(on: el)
    ///     // flattened: EventLoopFuture([1, 2, 3, 4])
    ///
    /// - parameter eventLoop: The event-loop to succeed the futures on.
    /// - returns: The succeeded values in an array, wrapped in an `EventLoopFuture`.
    public func flatten<MicrosoftAzureModel>(on eventLoop: EventLoop) -> EventLoopFuture<[MicrosoftAzureModel]>
        where Element == EventLoopFuture<MicrosoftAzureModel>
    {
        return eventLoop.flatten(Array(self))
    }
}
