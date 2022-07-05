//
//  OneDriveRequest.swift
//  Core
//
//  Created by vine on 2021/1/4.
//
import MicrosoftGraphCore
import Foundation
import NIO
import NIOHTTP1
import AsyncHTTPClient

class OneDriveRequest: MsGraphAPIRequest {
    let refreshableToken: OAuthRefreshable
    let httpClient: HTTPClient
    let responseDecoder: JSONDecoder = JSONDecoder()
    var currentToken: OAuthAccessToken?
    var tokenCreatedTime: Date?
    var eventLoop: EventLoop
    
    init(httpClient: HTTPClient, eventLoop: EventLoop, oauth: OAuthRefreshable) {
        self.refreshableToken = oauth
        self.httpClient = httpClient
        self.eventLoop = eventLoop
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
//        self.responseDecoder.dateDecodingStrategy = .formatted(dateFormatter)
    }
    
    public func send<MGM: MicrosoftAzureModel>(method: HTTPMethod,
                                               headers: HTTPHeaders = [:], path: String, query: String = "",
                                               body: HTTPClientRequest.Body = .bytes(.init(data: Data()))) async throws -> MGM {
        return try await withToken { token in
            let responseData = try await self._send(method: method, headers: headers, path: path, query: query, body: body, accessToken: token.access_token)
            if let info = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) {
                print("info:\n\(info)")
            }
            let model = try self.responseDecoder.decode(MGM.self, from: responseData)
            return model
        }
    }
    
    private func _send(method: HTTPMethod, headers: HTTPHeaders, path: String, query: String, body: HTTPClientRequest.Body, accessToken: String) async throws -> Data {
        var _headers: HTTPHeaders = ["Authorization": "Bearer \(accessToken)",
                                     "Content-Type": "application/json"]
        headers.forEach { _headers.replaceOrAdd(name: $0.name, value: $0.value) }

        var request = HTTPClientRequest(url: "\(path)")
        request.method = method
        request.headers = _headers
        request.body = body
        
        let response = try await httpClient.execute(request, timeout: .seconds(30))

        // If we get a 204 for example in the delete api call just return an empty body to decode.
        if response.status == .noContent {
            return "{}".data(using: .utf8)!
        }

        var byteBuffer = try await response.body.reduce(into: ByteBuffer()) { accumulatingBuffer, nextBuffer in
            var nextBuffer = nextBuffer
            accumulatingBuffer.writeBuffer(&nextBuffer)
        }
        let responseData = byteBuffer.readData(length: byteBuffer.readableBytes)!

        guard (200...299).contains(response.status.code) else {
            let error: Error
            if let jsonError = try? self.responseDecoder.decode(OneDriveAPIError.self, from: responseData) {
                error = jsonError
            } else {
                let body = byteBuffer.getString(at: byteBuffer.readerIndex , length: byteBuffer.readableBytes) ?? ""
                error = OneDriveAPIError(error: OneDriveAPIErrorBody(errors: [], code: Int(response.status.code), message: body))
            }

            throw error
        }
        return responseData
    }
}
