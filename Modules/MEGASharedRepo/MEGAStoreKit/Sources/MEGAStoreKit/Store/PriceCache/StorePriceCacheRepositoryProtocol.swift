import Foundation

public protocol StorePriceCacheRepositoryProtocol {
    func save(price: String, for identifier: String)
    func getPrice(for identifier: String) -> String?
    func getPrices() -> [String: String]
}
