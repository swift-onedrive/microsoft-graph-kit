//
//  File.swift
//  
//
//  Created by vine on 2021/1/4.
//

import Foundation

public struct OAuthAccessToken: Codable {
    public let access_token: String
    public let token_type: String
    public let expires_in: Int
    public let ext_expires_in: Int
}
