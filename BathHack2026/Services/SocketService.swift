//
//  SocketService.swift
//  BathHack2026
//
//  Created by Matt Dustin Cruz on 28/03/2026.
//

import Foundation
import Network
import SocketIO

enum SocketError: LocalizedError {
    case timeout
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .timeout: return "Request timed out."
        case .invalidResponse: return "Invalid response from server."
        }
    }
}

@Observable
final class SocketService {
    private let manager: SocketManager
    private let socket: SocketIOClient
    
    private let socketStatusChangeContinuation: AsyncStream<SocketIOStatus?>.Continuation
    let socketStatusChange: AsyncStream<SocketIOStatus?>
    
    init(url: URL) {
        // Init SocketIO
        self.manager = SocketManager(socketURL: url, config: [
            .log(true),
            .compress,
            .reconnects(true),
            .reconnectWait(2),
            .reconnectAttempts(-1),
            .forceWebsockets(true),
            .forceNew(true)
        ])
        self.socket = manager.defaultSocket
        
        // Init socket status changes stream
        let (socketStatusStream, socketStatusContinuation) = AsyncStream<SocketIOStatus?>.makeStream()
        self.socketStatusChange = socketStatusStream
        self.socketStatusChangeContinuation = socketStatusContinuation
        
        setupHandlers()
    }
    
    private func setupHandlers() {
        socket.on(clientEvent: .statusChange) { [weak self] data, _ in
            Task { @MainActor in
                self?.socketStatusChangeContinuation.yield(data.first as? SocketIOStatus)
            }
        }
    }
}
