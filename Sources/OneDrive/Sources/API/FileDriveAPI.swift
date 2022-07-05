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
    func get(userID: String?) async throws -> FileDriveModel
    func getDriveRoot(userID: String?) async throws -> FileDriveModel
    func getDriveRootChildren(userID: String?) async throws -> WrapperFileDriveModel
    
    /// 相对于根的路径
    func getDrive(userID: String?, releativeToRoot path: String) async throws -> FileDriveModel
    func getDriveChildren(userID: String?, releativeToRoot path: String) async throws -> WrapperFileDriveModel
}

extension FileDriveAPI {
    public func get(userID: String? = nil) async throws -> FileDriveModel {
        return try await get(userID: userID)
    }
    public func getDriveRoot(userID: String? = nil) async throws -> FileDriveModel {
        return try await getDriveRoot(userID: userID)
    }
    public func getDriveRootChildren(userID: String? = nil) async throws -> WrapperFileDriveModel {
        return try await getDriveRootChildren(userID: userID)
    }
    
    public func getDrive(userID: String? = nil, releativeToRoot path: String) async throws -> FileDriveModel {
        return try await getDrive(userID: userID, releativeToRoot: path)
    }
    
    public func getDriveChildren(userID: String? = nil, releativeToRoot path: String) async throws -> WrapperFileDriveModel {
        return try await getDriveChildren(userID: userID, releativeToRoot: path)
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
    
    public func get(userID: String?) async throws -> FileDriveModel {
        let gasket = (userID ?? objectID).isEmpty ? "" : "/users/\(userID ?? objectID)"
        return try await request.send(method: .GET, path: "\(endpoint)\(gasket)/drive")
    }
    
    public func getDriveRoot(userID: String?) async throws -> FileDriveModel {
        let gasket = (userID ?? objectID).isEmpty ? "" : "/users/\(userID ?? objectID)"
        return try await request.send(method: .GET, path: "\(endpoint)\(gasket)/drive/root")
    }
    
    public func getDriveRootChildren(userID: String?) async throws -> WrapperFileDriveModel {
        let gasket = (userID ?? objectID).isEmpty ? "" : "/users/\(userID ?? objectID)"
        return try await request.send(method: .GET, path: "\(endpoint)\(gasket)/drive/root/children")
    }
    
    public func getDrive(userID: String?, releativeToRoot path: String) async throws -> FileDriveModel {
        let gasket = (userID ?? objectID).isEmpty ? "" : "/users/\(userID ?? objectID)"
        return try await request.send(method: .GET, path: "\(endpoint)\(gasket)/drive/root:/\(path)")
    }
    
    public func getDriveChildren(userID: String?, releativeToRoot path: String) async throws -> WrapperFileDriveModel {
        let gasket = (userID ?? objectID).isEmpty ? "" : "/users/\(userID ?? objectID)"
        return try await request.send(method: .GET, path: "\(endpoint)\(gasket)/drive/root:/\(path):/children")
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
