public func updateProjectVersion(_ newVersion: String, pathToPBXProj: String) throws {
    let sedCommand = "sed -i '' -E 's/(MARKETING_VERSION = )([0-9]+\\.[0-9]+)(\\.[0-9]+)?;/\\1\(newVersion);/' \(pathToPBXProj)"
    try runInShell(sedCommand)
}
