//
//  NetworkManager.swift
//  Jono
//
//  Created by Husnain on 14/03/2024.
//

import Foundation
import Combine

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    
    var name: String { self.rawValue }
}

protocol Endpoint: Sendable {
    var path: String { get }
    var method: HttpMethod { get }
    var body: Data? { get }
}

extension Endpoint {
    var fullPath: String {
        return "\(Constants.BaseAPIURL)\(path)"
    }
}

enum NetworkError: LocalizedError {
    case badResponse(_ code: Int)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .badResponse(let code):
            return "Bad response. Status code: \(code)."
        case .unknown(let error):
            return "Unknown error: \(error)"
        }
    }
}

typealias ProgressHandler = (Double) -> Void
typealias ContinuationHandler = () -> Bool

final class NetworkManager: NSObject {
    private let defaultSession = URLSession(configuration: .default)
    
    private lazy var uploadSession = URLSession(
        configuration: .default,
        delegate: self,
        delegateQueue: .current
    )
    
    private lazy var downloadSession = URLSession(
        configuration: .default,
        delegate: self,
        delegateQueue: .current
    )
    
    static func reset() {
        HTTPCookieStorage.shared.cookies?.forEach(HTTPCookieStorage.shared.deleteCookie)
    }
    
    func requestAsync(_ endpoint: Endpoint, requiresAuth: Bool = false) async throws -> Data {
        let url = URL(string: Constants.BaseAPIURL + endpoint.path)!
        
        var req = URLRequest(url: url)
        
        print("\(endpoint.method.rawValue) \(url.relativePath)")
        
        req.httpMethod = endpoint.method.name
        req.setValue("application/x-protobuf", forHTTPHeaderField: "Content-Type")
        
        if case .post = endpoint.method {
            req.httpBody = endpoint.body
        }
        
        let (data, res) = try await self.defaultSession.data(for: req)
        
        try handleResponse(res)

        return data
    }
    
    func handleResponse(_ response: URLResponse?, error: Error? = nil) throws {
        if let error = error { throw error }
        
        guard let res = response as? HTTPURLResponse else { return }
        
        guard res.statusCode >= 200 && res.statusCode < 300 else {
            if res.statusCode == 401 {
                // TODO: Remove auth token
            }
            
            throw NetworkError.badResponse(res.statusCode)
        }
    }
    
    private var uploadProgressHandlers = [Int : ProgressHandler]()
    private var uploadContinuationHandlers = [Int : ContinuationHandler]()
    
    private var activeDownloadURLs = Set<String>()
    private var downloadProgressHandlers = [Int : ProgressHandler]()
    
    func uploadFile(_ source: URL, type: String, to destination: String, headers: [String: String],
                    progressHandler: @escaping ProgressHandler, continuationHandler: @escaping ContinuationHandler) async throws -> Data? {
        return try await withCheckedThrowingContinuation { continuation in
            var req = URLRequest(url: URL(string: destination)!)
            
            req.cachePolicy = .reloadIgnoringLocalCacheData
            req.httpMethod = "PUT"
            req.setValue(type, forHTTPHeaderField: "Content-Type")
            
            for (k, v) in headers {
                req.setValue(v, forHTTPHeaderField: k)
            }
            
            let task = uploadSession.uploadTask(with: req, fromFile: source, completionHandler: { data, response, error in
                do {
                    try self.handleResponse(response, error: error)
                } catch {
                    return continuation.resume(throwing: error)
                }
                
                continuation.resume(returning: data)
            })
            
            uploadProgressHandlers[task.taskIdentifier] = progressHandler
            uploadContinuationHandlers[task.taskIdentifier] = continuationHandler
            
            task.resume()
        }
    }
    
    @MainActor
    func downloadFile(_ source: String, to destination: URL) async throws -> Void {
        return try await withCheckedThrowingContinuation { continuation in
            if self.activeDownloadURLs.contains(source) {
                return continuation.resume(throwing: "already downloading")
            }
            
            let req = URLRequest(url: URL(string: source)!)
            
            self.activeDownloadURLs.insert(source)
            
            let task = downloadSession.downloadTask(with: req, completionHandler: { localURL, response, error in
                self.activeDownloadURLs.remove(source)
                
                do {
                    try self.handleResponse(response, error: error)
                } catch {
                    return continuation.resume(throwing: error)
                }
                
                do {
                    _ = destination.deleteIfExists()
                    try localURL?.move(destination)
                } catch {
                    return continuation.resume(throwing: "Could not move downloaded file to destination: \(error)")
                }
                
                continuation.resume()
            })
            
            task.resume()
        }
    }
}

extension NetworkManager: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let progress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        let handler = uploadProgressHandlers[task.taskIdentifier]
        handler?(progress)
        
        if let shouldContinue = uploadContinuationHandlers[task.taskIdentifier]?(), !shouldContinue {
            print("Cancelling upload task")
            task.cancel()
        }
    }
}

extension NetworkManager: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        let handler = downloadProgressHandlers[downloadTask.taskIdentifier]
        handler?(progress)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // Done downloading.
    }
}
