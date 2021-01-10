//
//  File.swift
//  
//
//  Created by Finer  Vine on 2021/1/5.
//

import Foundation

public protocol MsGraphAPIConfiguration {
    
}

public protocol MsGraphAPIScope {
    var value: String { get }
}

public enum MsGraphDefaultScope: MsGraphAPIScope {
    case defalut
    
    public var value: String {
        switch self {
        case .defalut:
            return "https://graph.microsoft.com/.default"
        }
    }
}
