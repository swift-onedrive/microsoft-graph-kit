//
//  File.swift
//  
//
//  Created by vine on 2021/1/4.
//

import Foundation

public protocol MicrosoftAzureModel: Codable { }

// https://docs.microsoft.com/zh-cn/graph/query-parameters
extension Dictionary {
    
    public var queryParameters: String {
        guard let me = self as? [String: Any] else
        { return "" }
        return query(parameters: me)
    }
    
    func query(parameters: [String: Any]) -> String {
        var components: [(String, String)] = []
        
        for key in parameters.keys {
            let value = parameters[key]!
            components += queryComponents(key: key, value)
        }
        return (components.map { "\($0)=\($1)" } as [String]).joined(separator: "&")
    }
    
    public func queryComponents(key: String, _ value: Any) -> [(String, String)] {
        var components: [(String, String)] = []
        
        if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary {
                components += queryComponents(key: "\(key)[\(nestedKey)]", value)
            }
        } else if let array = value as? [Any] {
            for i in 0..<array.count {
                components += queryComponents(key: "\(key)[\(i)]", array[i])
            }
        } else {
            components.append((key, "\(value)"))
        }
        
        return components
    }
}
