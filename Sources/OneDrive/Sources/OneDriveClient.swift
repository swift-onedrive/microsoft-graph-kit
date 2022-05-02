//
//  File.swift
//  
//
//  Created by vine on 2021/1/4.
//

import Foundation
import MicrosoftGraphCore
import AsyncHTTPClient
import NIO

public final class OneDriveClient {
    public var drive: FileDriveAPI
    public var driveItem: FileDriveItemAPI
    /// Thread pool used by transfer manager
    public let threadPool: NIOThreadPool
    
    var onedriveRequest: OneDriveRequest
    
    public init(credentials: MsGraphCredentialsConfiguration,
                driveConfig: MsGraphOneDriveConfig,
                httpClient: HTTPClient,
                eventLoop: EventLoop) throws {
        let refreshableToken = OAuthCredentialLoader.getRefreshableToken(credentials: credentials,
                                                                         andClient: httpClient,
                                                                         eventLoop: eventLoop)
        
        onedriveRequest = OneDriveRequest(httpClient: httpClient,
                                          eventLoop: eventLoop,
                                          oauth: refreshableToken)
        
        self.threadPool = NIOThreadPool(numberOfThreads: 4)
        self.threadPool.start()
        
        drive = MsGraphFileDriveAPI(request: onedriveRequest, objectID: driveConfig.objectID)
        driveItem = MsGraphFileDriveItemAPI.init(request: onedriveRequest, config: driveConfig, threadPool: self.threadPool)
    }

    /// Hop to a new eventloop to execute requests on.
    /// - Parameter eventLoop: The eventloop to execute requests on.
    public func hopped(to eventLoop: EventLoop) -> OneDriveClient {
        onedriveRequest.eventLoop = eventLoop
        return self
    }
}
