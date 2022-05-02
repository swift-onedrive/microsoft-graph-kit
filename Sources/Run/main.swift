import Foundation
import AsyncHTTPClient
import OneDrive
import MicrosoftGraphCore
import NIO

let elg = MultiThreadedEventLoopGroup(numberOfThreads: 1)
let client = HTTPClient(eventLoopGroupProvider: .shared(elg),
                        configuration: .init(ignoreUncleanSSLShutdown: true))
defer {
    try? client.syncShutdown()
}

do {
    // https://go.microsoft.com/fwlink/?linkid=2083908
    let credentialsConfiguration = MsGraphCredentialsConfiguration.init(credentials:.init(tenantId: "tenant 租户ID",
                                                                                           clientId: "clientID 客户端ID",
                                                                                           secret: "秘钥"))
        
    
    let onedrive = try OneDriveClient.init(credentials: credentialsConfiguration, driveConfig: .init(objectID: ""), httpClient: client, eventLoop: elg.next())
    
    // large file
    let url = URL(fileURLWithPath: "/large.zip")
    let large = onedrive.driveItem
        .createLargeFileUploadSession(folder: "MyZip", fileUrl: url, name: url.lastPathComponent)
    let largeModel = try large.wait()
    print(largeModel.uploadUrl)
    
    // upload file
    let upload = onedrive.driveItem.createSimpleUpload(folder: "temp/first", body: .string("This is test"), name: "one.txt", contentType: "text/plain")
    let model: FileDriveItemModel = try upload.wait()
    print(model.webURL)

    // file
    let file = onedrive.drive.getDrive(releativeToRoot: "temp")
    let fileModel: FileDriveModel = try file.wait()
    
    print(fileModel.webURL)
    
} catch {
    print(error)
}
