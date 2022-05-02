//
//  File.swift
//  
//
//  Created by Finer  Vine on 2022/5/7.
//

import Foundation
import NIOCore
import AsyncHTTPClient

public extension FileDriveItemAPI {
    // MARK: upload
    /// 简单上传最大 4M
    ///
    /// 新建 `root:/test/haha/a.jpg:`，替换 `items/{item-id}`
    ///
    /// - Parameters:
    ///   - file: 文件
    ///   - body: 内容
    ///   - name: 文件名
    ///   - contentType: 内容类型
    ///   - isisUpdate: 是否是更新
    /// - Returns: 上传结果
    func createSimpleUpload<T: DriveFileItemProtocol>(file: T,
                                                      body: HTTPClient.Body,
                                                      contentType: String,
                                                      isUpdate: Bool = false) -> EventLoopFuture<DriveItemModel> {
        createSimpleUpload(file: file, body: body, contentType: contentType, isUpdate: isUpdate)
    }
    /// 移动项目
    /// - Parameters:
    ///   - odItem: 原始
    ///   - parentReferenceId: 目标文件夹`id`
    ///   - name: 新名字
    /// - Returns: 移动结果
    func moveItem<T: DriveItemProtocol>(from odItem: T,
                                        parentReferenceId: String, name: String? = nil) -> EventLoopFuture<DriveItemModel> {
        moveItem(from: odItem, parentReferenceId: parentReferenceId, name: name)
    }
    
    /// 复制项目
    /// - Parameters:
    ///   - odItem: 原始项目
    ///   - parentReferenceDriveId: 目标文件夹`driveId`
    ///   - parentReferenceId: 目标文件夹`id`
    ///   - name: 新名字
    /// - Returns: 复制结果
    func copyItem<T: DriveItemProtocol>(from odItem: T,
                                        parentReferenceDriveId: String,
                                        parentReferenceId: String, name: String? = nil) -> EventLoopFuture<DriveItemModel> {
        copyItem(from: odItem, parentReferenceDriveId: parentReferenceDriveId, parentReferenceId: parentReferenceId, name: name)
    }
}
