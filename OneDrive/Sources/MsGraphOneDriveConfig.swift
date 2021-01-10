//
//  File.swift
//  
//
//  Created by Finer  Vine on 2021/1/9.
//

import Foundation
import Core

public struct MsGraphOneDriveConfig: MsGraphAPIConfiguration {
    
    /// 这里是用户ID
    public let objectID: String
    
    public init(objectID: String) {
        self.objectID = objectID
    }
}
