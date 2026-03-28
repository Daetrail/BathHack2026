//
//  ServiceContainer.swift
//  BathHack2026
//
//  Centralized container for all API services.
//  Uses a singleton so ViewModels can easily access services
//  without complex dependency injection.
//

import Foundation

@MainActor
final class ServiceContainer {
    static let shared = ServiceContainer()

    let networkService: NetworkService
    let authService: AuthService
    let toiletService: ToiletService
    let reviewService: ReviewService

    private init() {
        networkService = NetworkService(baseURL: Constants.apiUrl)
        authService = AuthService(networkService: networkService)
        toiletService = ToiletService(networkService: networkService)
        reviewService = ReviewService(networkService: networkService)
    }
}
