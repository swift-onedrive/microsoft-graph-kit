import NIO

// MARK: Close file handle
extension EventLoopFuture {
    func closeFileHandle(_ fileHandle: NIOFileHandle) -> EventLoopFuture<Value> {
        return self.flatMapErrorThrowing { error in
            try fileHandle.close()
            throw error
        }
        .flatMapThrowing { rt -> Value in
            try fileHandle.close()
            return rt
        }
    }
}
