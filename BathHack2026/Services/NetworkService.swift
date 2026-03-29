//
//  NetworkService.swift
//  BathHack2026
//
//  Created by Matt Dustin Cruz on 28/03/2026.
//

import Foundation
import MultipartFormData

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
}

final class NetworkService {
    let baseURL: String
    var token: String?
    
    init(baseURL: String, token: String? = nil) {
        self.baseURL = baseURL
        self.token = token
    }
    
    func get(_ path: String) async throws -> Data {
        return try await execute(.get, path: path)
    }
    
    func post(_ path: String, _ body: some Encodable) async throws -> Data {
        return try await execute(.post, path: path, body: body)
    }
    
    func postWithJpeg(_ path: String, _ body: some Encodable, jpegFilename: String?, jpegData: Data?) async throws -> Data {
        let jsonData = try JSONEncoder().encode(body)
        
        let boundary = Boundary.random()
        let formData = try MultipartFormData(boundary: boundary) {
            // JSON body
            Subpart {
                ContentDisposition(name: "jsonData")
                ContentType(mediaType: .applicationJson)
            } body: {
                jsonData
            }
            
            // JPEG body
            if let jpegFilename, let jpegData {
                try Subpart {
                    try ContentDisposition(uncheckedName: "image", uncheckedFilename: jpegFilename)
                    ContentType(mediaType: .imageJpeg)
                } body: {
                    jpegData
                }
            }
        }
        
        guard let url = URL(string: baseURL + path) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url, multipartFormData: formData)
        
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpMethod = "POST"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let http = response as? HTTPURLResponse, http.statusCode >= 500 {
            throw URLError(.badServerResponse)
        }
        
        return data
    }
    
    func delete(_ path: String, _ body: some Encodable) async throws -> Data {
        return try await execute(.delete, path: path, body: body)
    }
    
    private func execute(_ method: HTTPMethod, path: String) async throws -> Data {
        return try await execute(method, path: path, body: nil as String?)
    }
    
    private func execute<B: Encodable>(_ method: HTTPMethod, path: String, body: B?) async throws -> Data {
        guard let url = URL(string: baseURL + path) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Required for ngrok free tier to skip the browser interstitial page
        request.setValue("true", forHTTPHeaderField: "ngrok-skip-browser-warning")
        
        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse, http.statusCode >= 500 {
            throw URLError(.badServerResponse)
        }

        return data
    }
}
