import Testing

@Suite("OptionSet Additions Tests")
struct OptionSetAdditionsTests {
    private struct TestOptions: OptionSet {
        let rawValue: Int
        
        static let option1 = TestOptions(rawValue: 1)
        static let option2 = TestOptions(rawValue: 2)
    }
    
    struct IsNotEmptyTests {
        
        @Test("isNoEmpty - Empty Option Set")
        func isNotEmptyReturnFalse() async throws {
            let emptyOptions: TestOptions = []
            #expect(emptyOptions.isNotEmpty == false)
        }
        
        
        @Test("isNoEmpty - None empty option set")
        func isNotEmptyReturnTrue() async throws {
            let emptyOptions: TestOptions = [.option1, .option2]
            #expect(emptyOptions.isNotEmpty == true)
        }
    }
}
