# microsoft-graph-kit

A description of this package.
## create application

[https://portal.azure.com/](https://portal.azure.com/)

select `Azure Active Directory` 

register `Application`

### Config

```swift
let elg = MultiThreadedEventLoopGroup(numberOfThreads: 1)
let client = HTTPClient(eventLoopGroupProvider: .shared(elg),
                        configuration: .init(ignoreUncleanSSLShutdown: true))
defer {
    try? client.syncShutdown()
}

do {
    // https://go.microsoft.com/fwlink/?linkid=2083908
    let credentialsConfiguration = MsGraphCredentialsConfiguration.init(credentials:.init(tenantId: "tenant ID",
                                                                                           clientId: "clientID",
                                                                                           secret: "secret"))
        
    
    let onedrive = try OneDriveClient.init(credentials: credentialsConfiguration, driveConfig: .init(objectID: ""), httpClient: client, eventLoop: elg.next())
}
```



Upload

```swift
    let drive = onedrive.driveItem.createSimpleUpload(folder: "temp/first", body: .string("This is test"), name: "one.txt", contentType: "text/plain")
    let model: FileDriveItemModel = try drive.wait()
    print(model.webURL)
```



Drive

```
   // file
    let file = onedrive.drive.getDrive(releativeToRoot: "temp")
    let fileModel: FileDriveModel = try file.wait()
    
    print(fileModel.webURL)
```

