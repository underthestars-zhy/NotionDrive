import XCTest
@testable import NotionDrive

final class NotionDriveTests: XCTestCase {
    let token = "{notion token}"
    let file = "{file name}"
    let father = "{father file}"
    
    func testGetPages() async throws {
        print(try await NotionDrive.getAllPages(token))
    }
    
    func testUplpad() async throws {
        let drive = NotionDrive(.init(father), token: token)
        guard let url = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else { return }
        let data = try Data(contentsOf: url.appendingPathComponent(file))
        let uuid = try await drive.upload(data, name: UUID().uuidString) { (uploaded, all) in
            print("\((Double(uploaded) / Double(all)) * 100)%")
        }
        guard let uuid = uuid  else { return }
        
        print(uuid.uuidString)
    }
    
    func testDonwload() async throws {
        guard let uuid = UUID(uuidString: "{uuid from testUpload}") else { return }
        let drive = NotionDrive(.init(father), token: token)
        let data = try await drive.download(uuid) { (uploaded, all) in
            print("\((Double(uploaded) / Double(all)) * 100)%")
        }
        guard let url = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else { return }
        try data?.write(to: url.appendingPathComponent("{file name (download)}"))
    }
    
    func testStringSub() throws {
        XCTAssertEqual("jwidaj;dmls;a,dhfljsla".sub(6).reduce("", +), "jwidaj;dmls;a,dhfljsla")
    }
    
    func testArrarySub() throws {
        print([1, 2, 3, 4, 5].sub(3))
    }
}
