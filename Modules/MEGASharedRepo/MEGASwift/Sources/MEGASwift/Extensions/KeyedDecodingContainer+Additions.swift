/**
 Decodes a value of the specified type for the given key if present.

 This convenience method wraps the standard `decodeIfPresent(_:forKey:)` call, allowing you to
 infer the type of the decoded value without having to explicitly pass the type.

 - Parameter key: The key that the value is associated with.
 - Returns: The decoded value of type `T` if present, or `nil` if the key is missing.
 - Throws: An error if the decoding process fails.
 */
public extension KeyedDecodingContainer {
    func decodeIfPresent<T>(for key: Key) throws -> T? where T: Decodable {
        try decodeIfPresent(T.self, forKey: key)
    }
}
