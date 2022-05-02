//
//  File.swift
//  
//
//  Created by Finer  Vine on 2021/4/3.
//

import Foundation

/// protocol for DrivePath descriptor
public protocol DrivePath: CustomStringConvertible {
    
    /// 驱动器，没有前导斜杠 [驱动器](https://docs.microsoft.com/zh-cn/graph/api/drive-get?view=graph-rest-1.0&tabs=http)
    ///
    /// - 获取当前用户的 OneDrive `/me/drive`
    /// - 获取用户的 OneDrive `/users/{idOrUserPrincipalName}/drive`
    /// - 获取与组关联的文档库 `/groups/{groupId}/drive`
    /// - 获取某个站点的文档库 `/sites/{siteId}/drive`
    /// - 根据 ID 获取驱动器 `/drives/{drive-id}`
    ///
    var bucket: DriveBucket { get }
    
    /// 驱动器项目。 没有前导斜杠
    ///
    /// ObjectKey、Key 以及 ObjectName 是同一概念，均表示对Object执行相关操作时需要填写的Object名称。
    ///
    /// 例如向某一存储空间上传Object时，ObjectKey表示上传的Object所在存储空间的完整名称，即包含文件后缀在内的完整路径，如填写为 `abc/efg/123.jpg`。
    associatedtype DriveKey: DriveKeyProtocol
    var key: DriveKey { get }
}

/// 项目`key`协议
public protocol DriveKeyProtocol: Equatable, ExpressibleByStringInterpolation, CustomStringConvertible {
    
}

public protocol DriveKeyPathProtocol: DriveKeyProtocol {
    
}

public protocol DriveKeyIDProtocol: DriveKeyProtocol {
    
}

/// ItemPath
public enum DriveKeyPath: DriveKeyPathProtocol {
    
    /// 常量
    case constant(String)
    
    /// 项目 路径, 不带前导斜杠
    case item(path: String)
    
    /// `ExpressibleByStringLiteral` conformance.
    public init(stringLiteral value: String) {
        if value.hasPrefix("root:/") {
            self = .item(path: value.removingPrefix("root:/"))
        } else {
            self = .constant(value.removingPrefix("/"))
        }
    }
    
    /// `CustomStringConvertible` conformance.
    public var description: String {
        switch self {
        case .item(let path):
            return "root:/" + path
        case .constant(let constant):
            return constant
        }
    }
}


/// ItemID
public enum DriveKeyID: DriveKeyIDProtocol {
    /// 常量
    case constant(String)
    
    /// 项目ID
    case item(Id: String)
    
    /// 驱动器上的 `root` 关系
    case root
    
    /// `ExpressibleByStringLiteral` conformance.
    public init(stringLiteral value: String) {
        if value == "root" {
            self = .root
        } else if value.hasPrefix("items/") {
            self = .item(Id: value.removingPrefix("items/"))
        } else {
            self = .constant(value.removingPrefix("/"))
        }
    }
    
    /// `CustomStringConvertible` conformance.
    public var description: String {
        switch self {
        case .root:
            return "root"
        case .item(let id):
            return "items/" + id
        case .constant(let constant):
            return constant
        }
    }
}

public extension DrivePath {
    /// return in URL form Drive
    var url: String { return "\(bucket)/\(key)" }

    /// CustomStringConvertible protocol requirement
    var description: String { return self.url }
}

public extension DrivePath where DriveKey == DriveKeyPath {
    //
    //    /// return parent folder
    //    func parent() -> DriveFolder? {
    //        let path = self.key.removingSuffix("/")
    //        guard path.count > 0 else { return nil }
    //        guard let slash: String.Index = path.lastIndex(of: "/") else { return DriveFolder(bucket: bucket, key: "") }
    //        return DriveFolder(bucket: bucket, key: String(path[path.startIndex...slash]))
    //    }
}
/// 驱动器项目
public protocol DriveItemProtocol: Equatable, DrivePath {
    
}

/// 文件驱动器项目
public protocol DriveFileItemProtocol: DriveItemProtocol {
    
}

/// 文件夹驱动器项目
public protocol DriveFolderItemProtocol: DriveItemProtocol {
    
}

/// 文件
public struct DriveFile<T: DriveKeyProtocol>: DriveFileItemProtocol {
    
    public let bucket: DriveBucket
    public let key: T
    
    /// 文件项目
    /// - Parameters:
    ///   - bucket: 驱动器
    ///   - key: 驱动器项目
    public init(bucket: DriveBucket, key: T) {
        self.bucket = bucket
        self.key = key
    }
    
//    /// 文件名，不带路径
//    public var name: String {
//        guard let slash = key.lastIndex(of: "/") else { return self.key }
//        return String(self.key[self.key.index(after: slash)..<self.key.endIndex])
//    }

//    /// 文件名，不包含扩展
//    public var nameWithoutExtension: String {
//        let name = self.name
//        guard let dot = name.lastIndex(of: ".") else { return name }
//        return String(name[name.startIndex..<dot])
//    }
//
//    /// file extension of file
//    public var `extension`: String? {
//        let name = self.name
//        guard let dot = name.lastIndex(of: ".") else { return nil }
//        return String(name[name.index(after: dot)..<name.endIndex])
//    }
}

/// 文件夹
public struct DriveFolder<T: DriveKeyProtocol>: DriveFolderItemProtocol {
    public let bucket: DriveBucket
    public let key: T

    public init(bucket: DriveBucket, key: T) {
        self.bucket = bucket
        self.key = key
    }
    /// Return sub folder of folder
    /// - Parameter name: sub folder name
//    public func subFolder(_ name: String) -> DriveFolder {
//        DriveFolder(bucket: self.bucket, key: "\(self.key)\(name)")
//    }

    /// Return file inside folder
    /// - Parameter name: file name
//    public func file(_ name: String) -> DriveFile {
//        guard name.firstIndex(of: "/") == nil else {
//            preconditionFailure("Filename \(name) cannot include '/'")
//        }
//        return DriveFile(bucket: self.bucket, key: "\(self.key)\(name)")
//    }
}

// MARK: bucket

/// 驱动器，没有前导斜杠
///
/// - 获取当前用户的 OneDrive `/me/drive`
/// - 获取用户的 OneDrive `/users/{idOrUserPrincipalName}/drive`
/// - 获取与组关联的文档库 `/groups/{groupId}/drive`
/// - 获取某个站点的文档库 `/sites/{siteId}/drive`
/// - 根据 ID 获取驱动器 `/drives/{drive-id}`
public enum DriveBucket: Equatable, CustomStringConvertible {
    case me
    case users(idOrUserPrincipalName: String)
    case groups(groupId: String)
    case sites(siteId: String)
    case drives(driveId: String)
    
    /// `CustomStringConvertible` conformance.
    public var description: String {
        switch self {
        case .me:
            return "me/drive"
        case .users(let idOrUserPrincipalName):
            return "users/\(idOrUserPrincipalName)/drive"
        case .groups(let groupId):
            return "groups/\(groupId)/drive"
        case .sites(let siteId):
            return "sites/\(siteId)/drive"
        case .drives(let driveId):
            return "drives/\(driveId)"
        }
    }
}

// MARK:

// MARK: 字符串扩展
internal extension String {
    func removingPrefix(_ prefix: String) -> String {
        guard hasPrefix(prefix) else { return self }
        return String(dropFirst(prefix.count))
    }

    func appendingPrefixIfNeeded(_ prefix: String) -> String {
        guard !hasPrefix(prefix) else { return self }
        return prefix + self
    }

    func removingSuffix(_ suffix: String) -> String {
        guard hasSuffix(suffix) else { return self }
        return String(dropLast(suffix.count))
    }

    func appendingSuffixIfNeeded(_ suffix: String) -> String {
        guard !hasSuffix(suffix) else { return self }
        return self + suffix
    }
}
