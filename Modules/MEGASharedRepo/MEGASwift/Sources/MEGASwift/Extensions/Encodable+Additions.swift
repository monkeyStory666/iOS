import Foundation

/**
 Converts an Encodable instance into a dictionary representation.

 This method encodes the instance into JSON data using a `JSONEncoder` and then converts the JSON data
 into a dictionary using `JSONSerialization`. This is useful for scenarios where you need to work with the
 object in a key-value format, such as for debugging or passing to APIs that expect a dictionary.

 - Returns: A dictionary representation of the Encodable object.
 - Throws: An error if encoding fails or if the JSON data cannot be converted into a dictionary.
 */
public extension Encodable {
    func convertToDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError(domain: "ConvertToDictionaryError", code: 0, userInfo: nil)
        }
        return dictionary
    }
}
