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
import Core


public protocol FileDriveItemAPI {
    
    // MARK: get
    
    /// 获取项目
    func getDriveItem(userID: String?, itemId: String) -> EventLoopFuture<FileDriveItemModel>
    
    // MARK: delete
    func deleteDriveItem(userID: String?, itemId: String) -> EventLoopFuture<MsGraphOneDriveAPIStatus>
    
    /// 搜索
    func searchDriveItem(userID: String?, queryParameters: [String: String]?) -> EventLoopFuture<FileDriveItemSearchModel>
    
    /// 下载文件
    func downloadDriveItem(userID: String?, itemId: String) -> EventLoopFuture<FileDriveItemModel>
    
    /// 创建默认公共文件夹
    func createDriveFolder(userID: String?, parentItemId: String?, name: String) -> EventLoopFuture<FileDriveItemModel>
    
    // MARK: upload
    /// 简单上传最大 4M
    func createSimpleUpload(userID: String?,
                            folder: String,
                            body: HTTPClient.Body,
                            name: String,
                            contentType: String) -> EventLoopFuture<FileDriveItemModel>
    
    /// 创建大文件 https://docs.microsoft.com/zh-cn/graph/api/driveitem-createuploadsession?view=graph-rest-1.0
    func createLargeFileUploadSession(userID: String?,
                                      folder: String,
                                      fileUrl: URL,
                                      name: String
    ) -> EventLoopFuture<LargeFileSessionResponse>
    
    /// 开始上传块
    func startLargeFileChunk(fileUrl: URL, uploadUrlString: String) -> EventLoopFuture<FileDriveItemModel>
    
    /// 续传块
    func resumeLargeFileChunk(fileUrl: URL, uploadUrlString: String) -> EventLoopFuture<FileDriveItemModel>
    
    /// 取消块
    func cancelLargeFileChunk(uploadUrlString: String) -> EventLoopFuture<MsGraphOneDriveAPIStatus>
}

extension FileDriveItemAPI {
    
    public func getDriveItem(userID: String? = nil, itemId: String) -> EventLoopFuture<FileDriveItemModel> {
        return getDriveItem(userID: userID, itemId: itemId)
    }
    public func deleteDriveItem(userID: String? = nil, itemId: String) -> EventLoopFuture<MsGraphOneDriveAPIStatus> {
        return deleteDriveItem(userID: userID, itemId: itemId)
    }
    public func searchDriveItem(userID: String? = nil, queryParameters: [String: String]?) -> EventLoopFuture<FileDriveItemSearchModel> {
        return searchDriveItem(userID: userID, queryParameters: queryParameters)
    }
    public func downloadDriveItem(userID: String? = nil, itemId: String) -> EventLoopFuture<FileDriveItemModel> {
        return downloadDriveItem(userID: userID, itemId: itemId)
    }
    public func createDriveFolder(userID: String? = nil, parentItemId: String? = nil, name: String) -> EventLoopFuture<FileDriveItemModel> {
        return createDriveFolder(userID: userID, parentItemId: parentItemId, name: name)
    }
    
    public func createSimpleUpload(userID: String? = nil,
                                   folder: String,
                                   body: HTTPClient.Body,
                                   name: String,
                                   contentType: String) -> EventLoopFuture<FileDriveItemModel> {
        return createSimpleUpload(userID: userID, folder: folder, body: body, name: name, contentType: contentType)
    }
    
    public func createLargeFileUploadSession(userID: String? = nil,
                                             folder: String,
                                             fileUrl: URL,
                                             name: String
    ) -> EventLoopFuture<LargeFileSessionResponse> {
        return createLargeFileUploadSession(userID: userID, folder: folder, fileUrl: fileUrl, name: name)
    }
    
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
    
    static let bufferSize = 1024 * 1024 * 5
    
    init(request: OneDriveRequest, objectID: String) {
        self.request = request
        self.objectID = objectID
    }
}

// MARK: GET
extension MsGraphFileDriveItemAPI {
    
    public func getDriveItem(userID: String?, itemId: String) -> EventLoopFuture<FileDriveItemModel> {
        let gasket = (userID ?? objectID).isEmpty ? "" : "/users/\(userID ?? objectID)"
        return request.send(method: .GET, path: "\(endpoint)\(gasket)/drive/items/\(itemId)")
    }
    
    public func searchDriveItem(userID: String?, queryParameters: [String : String]?) -> EventLoopFuture<FileDriveItemSearchModel> {
        let gasket = (userID ?? objectID).isEmpty ? "" : "/users/\(userID ?? objectID)"
        var query = ""
        
        if let queryParameters = queryParameters {
            query = queryParameters.queryParameters
        } else {
            query = ""
        }
        return request.send(method: .GET, path: "\(endpoint)\(gasket)/drive/root/search", query: query)
    }
    
    public func downloadDriveItem(userID: String?, itemId: String) -> EventLoopFuture<FileDriveItemModel> {
        let gasket = (userID ?? objectID).isEmpty ? "" : "/users/\(userID ?? objectID)"
        return request.send(method: .GET, path: "\(endpoint)\(gasket)/drive/items/\(itemId)/content")
    }
    
}
// MARK: POST
extension MsGraphFileDriveItemAPI {
    public func createDriveFolder(userID: String?, parentItemId: String?, name: String) -> EventLoopFuture<FileDriveItemModel> {
        let gasket = (userID ?? objectID).isEmpty ? "" : "/users/\(userID ?? objectID)"
        var path = "root"
        if let parentItemId = parentItemId {
            path = "items/\(parentItemId)"
        }
        do {
            let body: [String: Any] = ["name": name, "folder": [:], "@microsoft.graph.conflictBehavior": "rename"]
            let requestBody = try JSONSerialization.data(withJSONObject: body)
            return request.send(method: .POST, path: "\(endpoint)\(gasket)/drive/\(path)/children", body: .data(requestBody))
        } catch {
            return request.eventLoop.makeFailedFuture(error)
        }
    }
}

// MARK: DELETE
extension MsGraphFileDriveItemAPI {
    public func deleteDriveItem(userID: String?, itemId: String) -> EventLoopFuture<MsGraphOneDriveAPIStatus> {
        let gasket = (userID ?? objectID).isEmpty ? "" : "/users/\(userID ?? objectID)"
        return request.send(method: .DELETE, path: "\(endpoint)\(gasket)/drive/items/\(itemId)")
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
    
    public func createSimpleUpload(userID: String?,
                                   folder: String,
                                   body: HTTPClient.Body,
                                   name: String,
                                   contentType: String) -> EventLoopFuture<FileDriveItemModel> {
        let gasket = (userID ?? objectID).isEmpty ? "" : "/users/\(userID ?? objectID)"
        var headers: HTTPHeaders = [:]
        headers.add(name: "Content-Type", value: contentType)
        return request.send(method: .PUT, headers: headers, path: "\(endpoint)\(gasket)/drive/root:/\(folder)/\(name):/content", body: body)
    }
    
    
    public func createLargeFileUploadSession(userID: String?,
                                             folder: String,
                                             fileUrl: URL,
                                             name: String) -> EventLoopFuture<LargeFileSessionResponse> {
        do {
            let gasket = (userID ?? objectID).isEmpty ? "" : "/users/\(userID ?? objectID)"
            var body: [String: Any] = ["@microsoft.graph.conflictBehavior": "fail (default) | replace | rename"]
            body["deferCommit"] = true
            body["name"] = name
            
            let attributes = try FileManager.default.attributesOfItem(atPath: fileUrl.relativePath)
            guard let number = attributes[.size] as? Int else {
                fatalError("fetch file size error")
            }
            body["size"] = number
            let requestBody = try JSONSerialization.data(withJSONObject: body)
            let result:EventLoopFuture<LargeFileSessionResponse> = request.send(method: .POST, path: "\(endpoint)\(gasket)/drive/root:/\(folder)/\(name):/createUploadSession".urlEncoded(), body: .data(requestBody))
            return result
        } catch {
            return request.eventLoop.makeFailedFuture(error)
        }
    }
    /// 开始上传
    public func startLargeFileChunk(fileUrl: URL, uploadUrlString: String) -> EventLoopFuture<FileDriveItemModel> {
        /// 这里进行循环上传
        do {
            let file = try FileHandle(forReadingFrom: fileUrl)
            
            let attributes = try FileManager.default.attributesOfItem(atPath: fileUrl.relativePath)
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
                    let data = file.readData(ofLength: MsGraphFileDriveItemAPI.bufferSize)
                    length = data.count
                    let range: Range<Int> = .init(uncheckedBounds: (lower: offSet, upper: offSet + length - 1))
                    if length > 0 {
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
                        let data = file.readData(ofLength: MsGraphFileDriveItemAPI.bufferSize)
                        length = data.count
                        let range: Range<Int> = .init(uncheckedBounds: (lower: offSet, upper: offSet + length - 1))
                        if length > 0 {
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
            return promise.futureResult.flatMap { () -> EventLoopFuture<FileDriveItemModel> in
                return self.largeFileUploadComplete(uploadUrl: uploadUrl)
            }
        } catch  {
            return request.eventLoop.makeFailedFuture(error)
        }
        
    }
    
    /// 续传
    public func resumeLargeFileChunk(fileUrl: URL, uploadUrlString: String) -> EventLoopFuture<FileDriveItemModel> {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: fileUrl.relativePath)
            guard let number = attributes[.size] as? Int else {
                fatalError("fetch file size error")
            }
            guard let uploadUrl =  URL(string: uploadUrlString) else {
                fatalError("upload url error")
            }
            
            let file = try FileHandle(forReadingFrom: fileUrl)
            
            let queue = DispatchQueue.init(label: "Serial queue")

            let checkResult = self.checkLargeFileChunkStatus(uploadUrl: uploadUrlString)
            return checkResult.flatMap { (res) -> EventLoopFuture<FileDriveItemModel> in
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
                        let data = file.readData(ofLength: MsGraphFileDriveItemAPI.bufferSize)
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
                            let data = file.readData(ofLength: MsGraphFileDriveItemAPI.bufferSize)
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
                
                return promise.futureResult.flatMap { () -> EventLoopFuture<FileDriveItemModel> in
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
    func largeFileUploadComplete(uploadUrl: URL) -> EventLoopFuture<FileDriveItemModel> {
        
        var headers: HTTPHeaders = [:]
        headers.add(name: "Content-Length", value: "\(0)")
        
        return request.send(method: .POST, headers: headers, path: uploadUrl.absoluteString)
    }
}

public struct MsGraphOneDriveAPIStatus: MicrosoftAzureModel {

}
