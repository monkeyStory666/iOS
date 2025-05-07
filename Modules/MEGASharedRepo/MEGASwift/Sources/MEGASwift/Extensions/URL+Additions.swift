import Foundation

// MARK: - URL Extensions for File Attributes

public extension URL {
    /// A dictionary of file attributes for the file at the URL.
    ///
    /// This computed property uses `FileManager.default.attributesOfItem(atPath:)` to retrieve
    /// the file attributes of the item located at the URL's path. If the attributes cannot be
    /// retrieved (for example, if the file does not exist), the property returns `nil`.
    var attributes: [FileAttributeKey: Any]? {
        do {
            return try FileManager.default.attributesOfItem(atPath: path)
        } catch {
            return nil
        }
    }
}

// MARK: - Conformance to FileExtensionGroupDataSource

extension URL: FileExtensionGroupDataSource {
    /// A key path used to extract the file extension from the URL.
    ///
    /// This static property provides a key path that accesses the `pathExtension` of the URL's
    /// `lastPathComponent`. It can be used to group or filter files based on their extensions.
    public static var fileExtensionPath: KeyPath<URL, String> { \.lastPathComponent.pathExtension }
}
