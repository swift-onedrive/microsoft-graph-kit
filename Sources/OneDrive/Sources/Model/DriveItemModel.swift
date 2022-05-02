//
//  File.swift
//  
//
//  Created by vine on 2021/1/6.
// https://docs.microsoft.com/zh-cn/graph/api/resources/driveitem?view=graph-rest-1.0

import Foundation
import MicrosoftGraphCore

public final class DriveItemModel: BaseItemModel {
    public let odataContext: String
    public let microsoftGraphDownloadURL: String?
    public let cTag: String?
    public let size: Int
    public let file: File?
    public let fileSystemInfo: FileSystemInfo

    enum CodingKeys: String, CodingKey {
        case odataContext = "@odata.context"
        case microsoftGraphDownloadURL = "@microsoft.graph.downloadUrl"
        case cTag, size, file, fileSystemInfo
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
    struct FileSystemInfo: MicrosoftAzureModel {
        public let createdDateTime: String
        public let lastModifiedDateTime: String
    }
    
    /// 解码
    /// - Parameter decoder: 解析
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        odataContext = try container.decode(String.self, forKey: .odataContext)
        microsoftGraphDownloadURL = try container.decodeIfPresent(String.self, forKey: .microsoftGraphDownloadURL)
        // 可选值
        cTag = try container.decodeIfPresent(String.self, forKey: .cTag)
        size = try container.decode(Int.self, forKey: .size)
        file = try container.decodeIfPresent(File.self, forKey: .file)
        fileSystemInfo = try container.decode(FileSystemInfo.self, forKey: .fileSystemInfo)
        try super.init(from: decoder)
    }
    
    /// 编码
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(odataContext, forKey: .odataContext)
        // 可选值
        try container.encodeIfPresent(microsoftGraphDownloadURL, forKey: .microsoftGraphDownloadURL)
        try container.encodeIfPresent(cTag, forKey: .cTag)
        try container.encode(size, forKey: .size)
        try container.encodeIfPresent(file, forKey: .file)
        try container.encode(fileSystemInfo, forKey: .fileSystemInfo)
        // 父属性，倒序
        try super.encode(to: encoder)
    }
}


