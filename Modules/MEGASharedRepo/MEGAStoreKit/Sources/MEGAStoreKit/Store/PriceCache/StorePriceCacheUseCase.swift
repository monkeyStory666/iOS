// Copyright © 2024 MEGA Limited. All rights reserved.

public protocol StorePriceCacheUseCaseProtocol {
    func save(price: String, for identifier: String)
    func getPrice(for identifier: String) -> String?
    func getPrices() -> [String: String]
}

public struct StorePriceCacheUseCase: StorePriceCacheUseCaseProtocol {
    private let storePriceCacheRepository: any StorePriceCacheRepositoryProtocol

    public init(storePriceCacheRepository: some StorePriceCacheRepositoryProtocol) {
        self.storePriceCacheRepository = storePriceCacheRepository
    }

    public func save(price: String, for identifier: String) {
        storePriceCacheRepository.save(price: price, for: identifier)
    }

    public func getPrice(for identifier: String) -> String? {
        storePriceCacheRepository.getPrice(for: identifier)
    }

    public func getPrices() -> [String: String] {
        storePriceCacheRepository.getPrices()
    }
}
