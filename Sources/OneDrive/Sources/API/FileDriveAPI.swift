//
//  FileDriveAPI.swift
//  Core
//
//  Created by vine on 2021/1/4.
//
// https://docs.microsoft.com/zh-cn/graph/api/resources/drive?view=graph-rest-1.0

import Foundation
import NIO
import MicrosoftGraphCore

/// 驱动器
public protocol FileDriveAPI {
    /// 获取默认驱动器的根文件夹
    func get(userID: String?) -> EventLoopFuture<FileDriveModel>
    func getDriveRoot(userID: String?) -> EventLoopFuture<FileDriveModel>
    func getDriveRootChildren(userID: String?) -> EventLoopFuture<WrapperFileDriveModel>
    
    /// 相对于根的路径
    func getDrive(userID: String?, releativeToRoot path: String) -> EventLoopFuture<FileDriveModel>
    func getDriveChildren(userID: String?, releativeToRoot path: String) -> EventLoopFuture<WrapperFileDriveModel>
}

extension FileDriveAPI {
    public func get(userID: String? = nil) -> EventLoopFuture<FileDriveModel> {
        return get(userID: userID)
    }
    public func getDriveRoot(userID: String? = nil) -> EventLoopFuture<FileDriveModel> {
        return getDriveRoot(userID: userID)
    }
    public func getDriveRootChildren(userID: String? = nil) -> EventLoopFuture<WrapperFileDriveModel> {
        return getDriveRootChildren(userID: userID)
    }
    
    public func getDrive(userID: String? = nil, releativeToRoot path: String) -> EventLoopFuture<FileDriveModel> {
        return getDrive(userID: userID, releativeToRoot: path)
    }
    
    public func getDriveChildren(userID: String? = nil, releativeToRoot path: String) -> EventLoopFuture<WrapperFileDriveModel> {
        return getDriveChildren(userID: userID, releativeToRoot: path)
    }
}
public final class MsGraphFileDriveAPI: FileDriveAPI {
    let endpoint = "https://graph.microsoft.com/v1.0"
    let request: OneDriveRequest
    let objectID: String
    
    init(request: OneDriveRequest, objectID: String) {
        self.request = request
        self.objectID = objectID
    }
}

// MARK: GET
extension MsGraphFileDriveAPI {
    
    public func get(userID: String?) -> EventLoopFuture<FileDriveModel> {
        let gasket = (userID ?? objectID).isEmpty ? "" : "/users/\(userID ?? objectID)"
        return request.send(method: .GET, path: "\(endpoint)\(gasket)/drive")
    }
    
    public func getDriveRoot(userID: String?) -> EventLoopFuture<FileDriveModel> {
        let gasket = (userID ?? objectID).isEmpty ? "" : "/users/\(userID ?? objectID)"
        return request.send(method: .GET, path: "\(endpoint)\(gasket)/drive/root")
    }
    
    public func getDriveRootChildren(userID: String?) -> EventLoopFuture<WrapperFileDriveModel> {
        let gasket = (userID ?? objectID).isEmpty ? "" : "/users/\(userID ?? objectID)"
        return request.send(method: .GET, path: "\(endpoint)\(gasket)/drive/root/children")
    }
    
    public func getDrive(userID: String?, releativeToRoot path: String) -> EventLoopFuture<FileDriveModel> {
        let gasket = (userID ?? objectID).isEmpty ? "" : "/users/\(userID ?? objectID)"
        return request.send(method: .GET, path: "\(endpoint)\(gasket)/drive/root:/\(path)")
    }
    
    public func getDriveChildren(userID: String?, releativeToRoot path: String) -> EventLoopFuture<WrapperFileDriveModel> {
        let gasket = (userID ?? objectID).isEmpty ? "" : "/users/\(userID ?? objectID)"
        return request.send(method: .GET, path: "\(endpoint)\(gasket)/drive/root:/\(path):/children")
    }
}

// MARK: - WrapperFileDriveModel
public struct WrapperFileDriveModel: MicrosoftAzureModel {
    let odataContext: String
    public let value: [FileDriveModel]

    enum CodingKeys: String, CodingKey {
        case odataContext = "@odata.context"
        case value
    }
}
