//
//  File.swift
//  
//
//  Created by vine on 2021/1/6.
// https://docs.microsoft.com/zh-cn/graph/api/resources/driveitem?view=graph-rest-1.0

import Foundation
import Core

public struct FileDriveItemModel: MicrosoftAzureModel {
    public let odataContext: String
    public let microsoftGraphDownloadURL: String?
    public let createdDateTime: String
    public let eTag, id: String
    public let lastModifiedDateTime: String
    public let name: String
    public let webURL: String
    public let cTag: String
    public let size: Int
    public let createdBy, lastModifiedBy: EdBy
    public let parentReference: ParentReference
    public let file: File
    public let fileSystemInfo: FileSystemInfo

    enum CodingKeys: String, CodingKey {
        case odataContext = "@odata.context"
        case microsoftGraphDownloadURL = "@microsoft.graph.downloadUrl"
        case createdDateTime, eTag, id, lastModifiedDateTime, name
        case webURL = "webUrl"
        case cTag, size, createdBy, lastModifiedBy, parentReference, file, fileSystemInfo
    }
    
    // MARK: - EdBy
    public
    struct EdBy: Codable {
        let application: Application
    }

    // MARK: - Application
    public
    struct Application: Codable {
        let id, displayName: String
    }

    // MARK: - File
    public
    struct File: Codable {
        let mimeType: String
        let hashes: Hashes
    }

    // MARK: - Hashes
    struct Hashes: Codable {
        let quickXorHash: String
    }

    // MARK: - FileSystemInfo
    public
    struct FileSystemInfo: Codable {
        let createdDateTime, lastModifiedDateTime: String
    }

    // MARK: - ParentReference
    public
    struct ParentReference: Codable {
        let driveID, driveType, id, path: String

        enum CodingKeys: String, CodingKey {
            case driveID = "driveId"
            case driveType, id, path
        }
    }
}


