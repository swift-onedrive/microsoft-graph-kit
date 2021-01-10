//
//  File.swift
//  
//
//  Created by vine on 2021/1/4.
//

import Foundation

public struct MsGraphCredentialsConfiguration {
    public let serviceAccountCredentials: MsGraphAccountCredentials
    
    public init(credentials: MsGraphAccountCredentials) {
        self.serviceAccountCredentials = credentials
    }
}
