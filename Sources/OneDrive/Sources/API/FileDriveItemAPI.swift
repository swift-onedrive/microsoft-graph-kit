//
//  FileDriveItemAPI.swift
//  Core
//
//  Created by vine on 2021/1/4.
//
// https://docs.microsoft.com/zh-cn/graph/api/resources/driveitem?view=graph-rest-1.0

import Foundation
import NIO
import NIOHTTP1
import AsyncHTTPClient
import MicrosoftGraphCore

/// 驱动器项目
///
/// 通过 driveItem 唯一标识符使用 `drive/items/{item-id}` 的方式
/// 通过使用文件系统路径 `/drive/root:/path/to/file` 的方式
public protocol FileDriveItemAPI {
    
    // MARK: get
    
    /// 获取项目
    /// https://docs.microsoft.com/zh-cn/graph/api/driveitem-get?view=graph-rest-1.0&tabs=http
    ///
    /// - Parameter file: 项目模型
    /// - Returns: 项目详情
    func getDriveItem<T: DriveItemProtocol>(file: T) -> EventLoopFuture<DriveItemModel>
    
    // MARK: delete
    
    /// 删除项目
    /// - Parameter file: 项目模型，key 为 ID
    /// - Returns: 删除详情
    func deleteDriveItem<T: DriveItemProtocol>(file: T) -> EventLoopFuture<MsGraphOneDriveAPIStatus>
    
    /// 搜索项目
    /// - Parameters:
    ///   - file: 项目模型，必须bucket，key 可空
    ///   - queryParameters: 搜索参数
    /// - Returns: 搜索结果
    func searchDriveItem(bucket: DriveBucket, queryParameters: [String: String]?) -> EventLoopFuture<FileDriveItemSearchModel>
    
    /// 下载项目文件
    /// - Parameter file: 项目模型， key 为 ID
    /// - Returns: 文件详情
    func downloadDriveItem<T: DriveFileItemProtocol>(file: T) -> EventLoopFuture<DriveItemModel>
    
    /// 创建文件夹
    /// - Parameters:
    ///   - folder: 文件夹, key eg: root 、 items/{parent-item-id}
    ///   - name: 文件夹名
    /// - Returns: 文件夹信息
    func createDriveFolder<T: DriveFolderItemProtocol>(folder: T, name: String) -> EventLoopFuture<DriveItemModel>
    
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
                                                      isUpdate: Bool) -> EventLoopFuture<DriveItemModel>
    
    /// 创建大文件
    ///
    /// [大文件上传文档](https://docs.microsoft.com/zh-cn/graph/api/driveitem-createuploadsession?view=graph-rest-1.0)
    /// 
    /// - Parameters:
    ///   - file: 文件项目
    ///   - fileUrl: 本地文件
    /// - Returns: 上传结果
    func createLargeFileUploadSession<T: DriveFileItemProtocol>(file: T, fileUrl: URL) -> EventLoopFuture<LargeFileSessionResponse>
    
    /// 开始上传块
    func startLargeFileChunk(file path: String, uploadUrlString: String) -> EventLoopFuture<DriveItemModel>
    
    /// 续传块
    func resumeLargeFileChunk(file path: String, uploadUrlString: String) -> EventLoopFuture<DriveItemModel>
    
    /// 取消块
    func cancelLargeFileChunk(uploadUrlString: String) -> EventLoopFuture<MsGraphOneDriveAPIStatus>
    
    
    /// 本地文件上传
    /// - Parameters:
    ///   - path: 本地文件路径
    ///   - odFile: 远端文件路径
    ///   - progress: 进度
    /// - Returns: 上传结果
    func copy<T: DriveFileItemProtocol>(from path: String, to odFile: T, progress: @escaping (Double) throws -> Void) -> EventLoopFuture<DriveItemModel>
    
    
    /// 本地文件夹上传
    /// - Parameters:
    ///   - folder: 本地文件夹路径
    ///   - odFolder: 远端文件夹路径
    /// - Returns: 上传结果
    func copyFolder<U: DriveFolderItemProtocol>(from folder: String, to odFolder: U) -> EventLoopFuture<Void>
    
    /// 移动项目
    /// - Parameters:
    ///   - odItem: 原始
    ///   - parentReferenceId: 目标文件夹`id`
    ///   - name: 新名字
    /// - Returns: 移动结果
    func moveItem<T: DriveItemProtocol>(from odItem: T,
                                        parentReferenceId: String, name: String?) -> EventLoopFuture<DriveItemModel>
    
    /// 复制项目
    /// - Parameters:
    ///   - odItem: 原始项目
    ///   - parentReferenceDriveId: 目标文件夹`driveId`
    ///   - parentReferenceId: 目标文件夹`id`
    ///   - name: 新名字
    /// - Returns: 复制结果
    func copyItem<T: DriveItemProtocol>(from odItem: T,
                                        parentReferenceDriveId: String,
                                        parentReferenceId: String, name: String?) -> EventLoopFuture<DriveItemModel>

}

public
struct LargeFileSessionResponse: MicrosoftAzureModel {
    let expirationDateTime: String
    let nextExpectedRanges: [String]?
    public let uploadUrl: String
}

/// 请求上载的状态
struct LargeFileUploadStatusModel: MicrosoftAzureModel {
    let expirationDateTime: String
    let nextExpectedRanges: [String]?
}

public class MsGraphFileDriveItemAPI: FileDriveItemAPI {
    let endpoint = "https://graph.microsoft.com/v1.0"
    let request: OneDriveRequest
    let objectID: String
    let configuration: MsGraphOneDriveConfig
        
    /// Thread pool used by transfer manager
    public let threadPool: NIOThreadPool
    
    init(request: OneDriveRequest, config: MsGraphOneDriveConfig, threadPool: NIOThreadPool) {
        self.request = request
        self.objectID = config.objectID
        self.configuration = config
        self.threadPool = threadPool
    }
}

// MARK: Transfer
extension MsGraphFileDriveItemAPI {
    /// 复制项目
    /// - Parameters:
    ///   - odItem: 原始项目
    ///   - parentReferenceDriveId: 目标文件夹`driveId`
    ///   - parentReferenceId: 目标文件夹`id`
    ///   - name: 新名字
    /// - Returns: 复制结果
    public func copyItem<T: DriveItemProtocol>(from odItem: T,
                                        parentReferenceDriveId: String,
                                        parentReferenceId: String, name: String?) -> EventLoopFuture<DriveItemModel> {
        let driveBucket = odItem.bucket
        let driveKey = odItem.key
        let reqPath: String = "\(endpoint)/\(driveBucket)/\(driveKey)"
        do {
            var body: [String: Any] = [:]
            body["parentReference"] = ["id": parentReferenceId, "driveId": parentReferenceDriveId]
            if let name = name {
                body["name"] = name
            }
            let requestBody = try JSONSerialization.data(withJSONObject: body)
            return request.send(method: .PATCH, path: reqPath, body: .data(requestBody))
        } catch {
            return request.eventLoop.makeFailedFuture(error)
        }
    }
    /// 移动项目
    /// - Parameters:
    ///   - odItem: 原始
    ///   - parentReferenceId: 目标文件夹`id`
    ///   - name: 新名字
    /// - Returns: 移动结果
    public func moveItem<T: DriveItemProtocol>(from odItem: T,
                                               parentReferenceId: String,
                                               name: String?) -> EventLoopFuture<DriveItemModel> {
        let driveBucket = odItem.bucket
        let driveKey = odItem.key
        let reqPath: String = "\(endpoint)/\(driveBucket)/\(driveKey)"
        do {
            var body: [String: Any] = [:]
            body["parentReference"] = ["id": "\(parentReferenceId)"]
            if let name = name {
                body["name"] = name
            }
            let requestBody = try JSONSerialization.data(withJSONObject: body)
            return request.send(method: .PATCH, path: reqPath, body: .data(requestBody))
        } catch {
            return request.eventLoop.makeFailedFuture(error)
        }
    }
    
    /// 本地文件上传
    /// - Parameters:
    ///   - path: 本地文件路径
    ///   - odFile: 远端文件路径
    ///   - progress: 进度
    /// - Returns: 上传结果
    public func copy<T: DriveFileItemProtocol>(from path: String, to odFile: T, progress: @escaping (Double) throws -> Void) -> EventLoopFuture<DriveItemModel> {
        let driveBucket = odFile.bucket
        let driveKey = odFile.key
        let reqPath: String = "\(endpoint)/\(driveBucket)/\(driveKey)/createUploadSession".urlEncoded()
        do {
            var body: [String: Any] = ["@microsoft.graph.conflictBehavior": "fail (default) | replace | rename"]
            body["deferCommit"] = true
            
            let attributes = try FileManager.default.attributesOfItem(atPath: path)
            guard let number = attributes[.size] as? Int else {
                fatalError("fetch file size error")
            }
            body["size"] = number
            let requestBody = try JSONSerialization.data(withJSONObject: body)
            let result:EventLoopFuture<LargeFileSessionResponse> = request.send(method: .POST, path: reqPath, body: .data(requestBody))
            return result.flatMap { (response) -> EventLoopFuture<DriveItemModel> in
                    return self.startLargeFileChunk(file: path, uploadUrlString: response.uploadUrl)
                }
        } catch {
            return request.eventLoop.makeFailedFuture(error)
        }

    }
    
    
    /// 本地文件夹上传
    /// - Parameters:
    ///   - folder: 本地文件夹路径
    ///   - odFolder: 远端文件夹路径
    /// - Returns: 上传结果
    public func copyFolder<U: DriveFolderItemProtocol>(from folder: String, to odFolder: U) -> EventLoopFuture<Void> {
        let eventLoop = self.request.eventLoop
        return listFiles(in: folder)
            .flatMap { (files) in
                let taskQueue = TaskQueue<Void>(maxConcurrentTasks: self.configuration.maxConcurrentTasks, on: eventLoop)
                let transfers = Self.targetFiles(files: files, from: folder, to: odFolder)
                transfers.forEach { transfer in
                    taskQueue.submitTask {
                        // 单文件上传
                        self.copy(from: transfer.from.name, to: transfer.to) { progress in
                            
                        }
                        .map { _ in () }
                    }
                }
                return self.complete(taskQueue: taskQueue)
            }
    }
        
    /// Wait on all tasks succeeding. If there is an error the operation will either continue or cancel depending on `Configuration.cancelOnError`
    func complete<T>(taskQueue: TaskQueue<T>) -> EventLoopFuture<Void> {
        taskQueue.andAllSucceed()
            .flatMapError { error in
                if self.configuration.cancelOnError {
                    return taskQueue.cancel().flatMapThrowing { throw error }
                } else {
                    return taskQueue.flush().flatMapThrowing { throw error }
                }
            }
    }
    /// convert file descriptors to equivalent OneDrive file descriptors when copying one folder to another. Function assumes the files have srcFolder prefixed
    static func targetFiles<T: DriveFolderItemProtocol>(files: [FileDescriptor], from srcFolder: String, to destFolder: T) -> [(from: FileDescriptor, to: DriveFile<DriveKeyPath>)] {
        let srcFolder = srcFolder.appendingSuffixIfNeeded("/")
        return files.map { file in
            let pathRelative = file.name.removingPrefix(srcFolder)
            let keyPath: String = destFolder.key.description + pathRelative
            return (from: file, to: DriveFile(bucket: destFolder.bucket, key: .constant(keyPath)))
        }
    }
    /// List files in local folder
    func listFiles(in folder: String) -> EventLoopFuture<[FileDescriptor]> {
        let eventLoop = self.request.eventLoop
        return self.threadPool.runIfActive(eventLoop: eventLoop) {
            var files: [FileDescriptor] = []
            let path = URL(fileURLWithPath: folder)
            guard let fileEnumerator = FileManager.default.enumerator(
                at: path,
                includingPropertiesForKeys: [.contentModificationDateKey, .isDirectoryKey],
                options: .skipsHiddenFiles
            ) else {
                throw TransferError.failedToEnumerateFolder(folder)
            }
            while let file = fileEnumerator.nextObject() as? URL {
                let path = file.path
                var isDirectory: ObjCBool = false
                // ignore if it is a directory
                _ = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
                guard !isDirectory.boolValue else { continue }
                // get modification data and append along with file name
                let attributes = try FileManager.default.attributesOfItem(atPath: file.path)
                guard let modificationDate = attributes[.modificationDate] as? Date else { continue }
                files.append(.init(name: file.path, modificationDate: modificationDate))
            }
            return files
        }
    }
}

// MARK: GET
extension MsGraphFileDriveItemAPI {
    
    public func getDriveItem<T: DriveItemProtocol>(file: T) -> EventLoopFuture<DriveItemModel> {
        let driveBucket = file.bucket
        let driveKey = file.key
        let reqPath: String = "\(endpoint)/\(driveBucket)/\(driveKey)"
        return request.send(method: .GET, path: reqPath)
    }
    
    /// 搜索项目
    /// - Parameters:
    ///   - 项目模型，必须bucket
    ///   - queryParameters: 搜索参数 search_text
    /// - Returns: 搜索结果
    public func searchDriveItem(bucket: DriveBucket, queryParameters: [String : String]?) -> EventLoopFuture<FileDriveItemSearchModel> {
        let driveBucket = bucket
        var query = ""
        if let queryParameters = queryParameters {
            if let search_test = queryParameters["search_test"] {
                query = search_test
            } else {
                query = queryParameters.queryParameters
            }
        }
        return request.send(method: .GET, path: "\(endpoint)/\(driveBucket)/root/search(q='\(query)')")
    }
    
    /// 下载项目文件
    /// - Parameter file: 项目模型， key 为 ID
    /// - Returns: 文件详情
    public func downloadDriveItem<T: DriveFileItemProtocol>(file: T) -> EventLoopFuture<DriveItemModel> {
        let driveBucket = file.bucket
        let driveKey = file.key
        let reqPath: String = "\(endpoint)/\(driveBucket)/\(driveKey)/content"
        return request.send(method: .GET, path: reqPath)
    }
    
}
// MARK: POST
extension MsGraphFileDriveItemAPI {
    /// 创建文件夹
    /// - Parameters:
    ///   - folder: 文件夹, key eg: root 、 items/{parent-item-id}
    ///   - name: 文件夹名
    /// - Returns: 文件夹信息
    public func createDriveFolder<T: DriveFolderItemProtocol>(folder: T, name: String) -> EventLoopFuture<DriveItemModel> {
        let driveBucket = folder.bucket
        let driveKey = folder.key
        let reqPath: String = "\(endpoint)/\(driveBucket)/\(driveKey)/children"
        do {
            let body: [String: Any] = ["name": name, "folder": [:], "@microsoft.graph.conflictBehavior": "rename"]
            let requestBody = try JSONSerialization.data(withJSONObject: body)
            return request.send(method: .POST, path: reqPath, body: .data(requestBody))
        } catch {
            return request.eventLoop.makeFailedFuture(error)
        }
    }
}

// MARK: DELETE
extension MsGraphFileDriveItemAPI {
    /// 删除项目
    /// - Parameter file: 项目模型，key 为 ID
    /// - Returns: 删除详情
    public func deleteDriveItem<T: DriveItemProtocol>(file: T) -> EventLoopFuture<MsGraphOneDriveAPIStatus> {
        let driveBucket = file.bucket
        let driveKey = file.key
        let reqPath: String = "\(endpoint)/\(driveBucket)/\(driveKey)"
        return request.send(method: .DELETE, path: reqPath)
    }
}

public struct FileDriveItemSearchModel: MicrosoftAzureModel {
    let odataContext: String
    public let value: [FileDriveModel]

    enum CodingKeys: String, CodingKey {
        case odataContext = "@odata.context"
        case value
    }
}

// MARK: UPLOAD
extension MsGraphFileDriveItemAPI {
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
    public func createSimpleUpload<T: DriveFileItemProtocol>(file: T,
                                                      body: HTTPClient.Body,
                                                      contentType: String,
                                                      isUpdate: Bool) -> EventLoopFuture<DriveItemModel> {
        let driveBucket = file.bucket
        let driveKey = file.key
        let reqPath: String = isUpdate ? "\(endpoint)/\(driveBucket)/\(driveKey)/content" : "\(endpoint)/\(driveBucket)/\(driveKey)/content"
        
        var headers: HTTPHeaders = [:]
        headers.add(name: "Content-Type", value: contentType)
        return request.send(method: .PUT, headers: headers, path: reqPath, body: body)
    }
        
    /// 创建大文件
    ///
    /// [大文件上传文档](https://docs.microsoft.com/zh-cn/graph/api/driveitem-createuploadsession?view=graph-rest-1.0) `root:/\(folder)/\(name):`
    ///
    /// - Parameters:
    ///   - file: 文件项目
    ///   - fileUrl: 本地文件
    /// - Returns: 上传结果
    public func createLargeFileUploadSession<T: DriveFileItemProtocol>(file: T, fileUrl: URL) -> EventLoopFuture<LargeFileSessionResponse> {
        let driveBucket = file.bucket
        let driveKey = file.key
        let reqPath: String = "\(endpoint)/\(driveBucket)/\(driveKey)/createUploadSession".urlEncoded()
        do {
            var body: [String: Any] = ["@microsoft.graph.conflictBehavior": "fail (default) | replace | rename"]
            body["deferCommit"] = true
            
            let attributes = try FileManager.default.attributesOfItem(atPath: fileUrl.relativePath)
            guard let number = attributes[.size] as? Int else {
                fatalError("fetch file size error")
            }
            body["size"] = number
            let requestBody = try JSONSerialization.data(withJSONObject: body)
            let result:EventLoopFuture<LargeFileSessionResponse> = request.send(method: .POST, path: reqPath, body: .data(requestBody))
            return result
        } catch {
            return request.eventLoop.makeFailedFuture(error)
        }
    }
    
    /// 开始上传
    public func startLargeFileChunk(file path: String, uploadUrlString: String) -> EventLoopFuture<DriveItemModel> {
        /// 这里进行循环上传
        do {
            guard let file = FileHandle(forReadingAtPath: path) else {
                fatalError("read file error")
            }
            
            let attributes = try FileManager.default.attributesOfItem(atPath: path)
            guard let number = attributes[.size] as? Int else {
                fatalError("fetch file size error")
            }
            guard let uploadUrl =  URL(string: uploadUrlString) else {
                fatalError("upload url error")
            }
            let queue = DispatchQueue.init(label: "Serial queue")
            let promise = self.request.eventLoop.makePromise(of: Void.self)
            
            queue.async {
                var length = 0
                repeat {
                    #if os(Linux)
                    let offSet: Int = Int(file.offsetInFile)
                    let data = file.readData(ofLength: self.configuration.multipartPartSize)
                    length = data.count
                    
                    if length > 0 {
                        let range: Range<Int> = .init(uncheckedBounds: (lower: offSet, upper: offSet + length - 1))
                        let info = self.largeFilePutUpload(uploadUrl: uploadUrl, data: data, totalSize: number, range: range)
                        do {
                            let chunkInfo = try info.wait()
                            print("range:\(String(describing: chunkInfo.nextExpectedRanges))")
                        } catch {
                            print("error:\(error.localizedDescription)")
                        }
                    }
                    #else
                    autoreleasepool {
                        let offSet: Int = Int(file.offsetInFile)
                        let data = file.readData(ofLength: self.configuration.multipartPartSize)
                        length = data.count
                        
                        if length > 0 {
                            let range: Range<Int> = .init(uncheckedBounds: (lower: offSet, upper: offSet + length - 1))
                            let info = self.largeFilePutUpload(uploadUrl: uploadUrl, data: data, totalSize: number, range: range)
                            do {
                                let chunkInfo = try info.wait()
                                print("range:\(String(describing: chunkInfo.nextExpectedRanges))")
                            } catch {
                                print("error:\(error.localizedDescription)")
                            }
                        }
                    }
                    #endif
                } while length > 0
                // end
                file.closeFile()
                promise.succeed(())
            }
            return promise.futureResult.flatMap { () -> EventLoopFuture<DriveItemModel> in
                return self.largeFileUploadComplete(uploadUrl: uploadUrl)
            }
        } catch  {
            return request.eventLoop.makeFailedFuture(error)
        }
        
    }
    
    /// 续传
    public func resumeLargeFileChunk(file path: String, uploadUrlString: String) -> EventLoopFuture<DriveItemModel> {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: path)
            guard let number = attributes[.size] as? Int else {
                fatalError("fetch file size error")
            }
            guard let uploadUrl =  URL(string: uploadUrlString) else {
                fatalError("upload url error")
            }
            
            guard let file =  FileHandle(forReadingAtPath: path) else {
                fatalError("read file error")
            }
            
            let queue = DispatchQueue.init(label: "Serial queue")

            let checkResult = self.checkLargeFileChunkStatus(uploadUrl: uploadUrlString)
            return checkResult.flatMap { (res) -> EventLoopFuture<DriveItemModel> in
                print("check-uploadUrl:\(String(describing: res.nextExpectedRanges))")
                guard let checkRange = res.nextExpectedRanges?.first,
                      let lower = checkRange.split(separator: "-").first,
                      let lowerNumber = UInt64(String(lower)) else {
                    fatalError("range error")
                }
                
                file.seek(toFileOffset: lowerNumber)
                
                let promise = self.request.eventLoop.makePromise(of: Void.self)
                queue.async {
                    
                    var count = 0
                    var length = 0
                    repeat {
                        #if os(Linux)
                        let offSet: Int = Int(file.offsetInFile)
                        let data = file.readData(ofLength: self.configuration.multipartPartSize)
                        length = data.count
                        let range: Range<Int> = .init(uncheckedBounds: (lower: offSet, upper: offSet + length - 1))
                        if length > 0 {
                            let info = self.largeFilePutUpload(uploadUrl: uploadUrl, data: data, totalSize: number, range: range)
                            do {
                                let chunkInfo = try info.wait()
                                print("count:\(count) range:\(String(describing: chunkInfo.nextExpectedRanges))")
                                count = count + 1
                            } catch {
                                print("error:\(error.localizedDescription)")
                            }
                        }
                        #else
                        autoreleasepool {
                            let offSet: Int = Int(file.offsetInFile)
                            let data = file.readData(ofLength: self.configuration.multipartPartSize)
                            length = data.count
                            let range: Range<Int> = .init(uncheckedBounds: (lower: offSet, upper: offSet + length - 1))
                            if length > 0 {
                                let info = self.largeFilePutUpload(uploadUrl: uploadUrl, data: data, totalSize: number, range: range)
                                do {
                                    let chunkInfo = try info.wait()
                                    print("count:\(count) range:\(String(describing: chunkInfo.nextExpectedRanges))")
                                    count = count + 1
                                } catch {
                                    print("error:\(error.localizedDescription)")
                                }
                            }
                        }
                        #endif
                    } while length > 0
                    
                    // end
                    file.closeFile()
                    promise.succeed(())
                }
                
                return promise.futureResult.flatMap { () -> EventLoopFuture<DriveItemModel> in
                    return self.largeFileUploadComplete(uploadUrl: uploadUrl)
                }
            }
        } catch {
            return request.eventLoop.makeFailedFuture(error)
        }
    }
    
    /// 取消上传
    public func cancelLargeFileChunk(uploadUrlString: String) -> EventLoopFuture<MsGraphOneDriveAPIStatus> {
        return request.send(method: .DELETE, path: uploadUrlString)
    }
    
    fileprivate
    func checkLargeFileChunkStatus(uploadUrl: String) -> EventLoopFuture<LargeFileUploadStatusModel> {
        return request.send(method: .GET, path: uploadUrl)
    }
    
    /// 单块的上传
    fileprivate
    func largeFilePutUpload(uploadUrl: URL, data: Data, totalSize: Int, range: Range<Int>) -> EventLoopFuture<LargeFileUploadStatusModel> {
        
        var headers: HTTPHeaders = [:]
        headers.add(name: "Content-Length", value: "\(totalSize)")
        headers.add(name: "Content-Range", value: "bytes \(range.lowerBound)-\(range.upperBound)/\(totalSize)")
        
        let progress: Float = Float(range.lowerBound) / Float(totalSize)
        print("progress:\(progress * 100)% total:\(totalSize) range:\(range)")
        return request.send(method: .PUT, headers: headers, path: uploadUrl.absoluteString, body: .data(data))
    }
    /// 完成的请求
    fileprivate
    func largeFileUploadComplete(uploadUrl: URL) -> EventLoopFuture<DriveItemModel> {
        
        var headers: HTTPHeaders = [:]
        headers.add(name: "Content-Length", value: "\(0)")
        
        return request.send(method: .POST, headers: headers, path: uploadUrl.absoluteString)
    }
}

public struct MsGraphOneDriveAPIStatus: MicrosoftAzureModel {

}
