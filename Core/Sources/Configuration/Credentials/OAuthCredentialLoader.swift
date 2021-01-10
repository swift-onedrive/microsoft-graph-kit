//
//  File.swift
//  
//
//  Created by vine on 2021/1/4.
//

import Foundation
import NIO
import AsyncHTTPClient

public class OAuthCredentialLoader {
    public static func getRefreshableToken(credentials: MsGraphCredentialsConfiguration,
                                           andClient client: HTTPClient,
                                           eventLoop: EventLoop) -> OAuthRefreshable {
        
        // Check Service account first.
        return OAuthServiceAccount.init(credentials: credentials.serviceAccountCredentials, httpClient: client, eventLoop: eventLoop)
    }
}
