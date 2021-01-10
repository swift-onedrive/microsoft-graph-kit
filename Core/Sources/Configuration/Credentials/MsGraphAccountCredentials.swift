//
//  File.swift
//  
//
//  Created by vine on 2021/1/4.
//

import Foundation

public struct MsGraphAccountCredentials: Codable {
    public let tenant_id: String
    public let client_id: String
    public let secret: String
    
    public init(tenantId: String, clientId: String, secret: String ) {
        self.tenant_id = tenantId
        self.client_id = clientId
        self.secret = secret
    }
}
