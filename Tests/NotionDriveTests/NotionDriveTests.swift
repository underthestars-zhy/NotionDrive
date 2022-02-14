import XCTest
@testable import NotionDrive

final class NotionDriveTests: XCTestCase {
    let token = "{your token}"
    let file = "{your file name}"
    let father = "{your father file id}"
    
    func testGetPages() async throws {
        print(try await NotionDrive.getAllPages(token))
    }
    
    func testUplpad() async throws {
        let drive = NotionDrive(.init(father), token: token)
        guard let url = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else { return }
        let data = try Data(contentsOf: url.appendingPathComponent(file))
        guard let uuid = try await drive.upload(data, name: UUID().uuidString) else { return }
        
        print(uuid.uuidString)
    }
    
    func testDonwload() async throws {
        guard let uuid = UUID(uuidString: "{testUplpad output}") else { return }
        let drive = NotionDrive(.init(father), token: token)
        let data = try await drive.download(uuid)
        guard let url = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else { return }
        try data?.write(to: url.appendingPathComponent("{new file name}"))
    }
    
    func testStringSub() throws {
        XCTAssertEqual("jwidaj;dmls;a,dhfljsla".sub(6).reduce("", +), "jwidaj;dmls;a,dhfljsla")
    }
    
    func testArrarySub() throws {
        print([1, 2, 3, 4, 5].sub(3))
    }
}
