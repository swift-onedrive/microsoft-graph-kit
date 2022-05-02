//
//  File.swift
//  
//
//  Created by Finer  Vine on 2021/1/9.
//

import Foundation
import MicrosoftGraphCore

public struct MsGraphOneDriveConfig: MsGraphAPIConfiguration {
    
    /// 这里是用户ID
    public let objectID: String
    
    /// Cancel operations as soon as an error is found. Otherwise the operation will be attempt to finish all transfers
    let cancelOnError: Bool
    /// maximum number of uploads/downloads running concurrently
    let maxConcurrentTasks: Int
    /// size of each multipart part upload
    let multipartPartSize: Int
    
    public init(objectID: String,
                cancelOnError: Bool = true,
                maxConcurrentTasks: Int = 4,
                multipartPartSize: Int = 5 * 1024 * 1024) {
        self.objectID = objectID
        self.cancelOnError = cancelOnError
        self.maxConcurrentTasks = maxConcurrentTasks
        self.multipartPartSize = multipartPartSize
    }
}
