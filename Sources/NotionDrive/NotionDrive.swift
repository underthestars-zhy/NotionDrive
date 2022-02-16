import NotionSwift
import Foundation

public struct NotionDrive {
    private let id: Page.Identifier
    private let notion: NotionClient
    private let token: String
    
    public init(_ id: Page.Identifier, token: String) {
        self.id = id
        self.notion = NotionClient(accessKeyProvider: StringAccessKeyProvider(accessKey: token))
        self.token = token
    }
    
    public func upload(_ data: Data, name: String, progress: ((Int, Int) -> ())? = nil) async throws -> UUID? {
        let dataStrings = data.base64EncodedString()
        let all = dataStrings.count
        
        let request = PageCreateRequest(
            parent: .page(id),
            properties: [
                "title": .init(
                    type: .title([
                        .init(string: name + " \(all)")
                    ])
                ),
            ]
        )
        
        let page = try await notion.pageCreate(request: request)
        var uploaded = 0
        let datas = dataStrings.sub(2000)
        let subDatas = datas.sub(100)
        for (count, subData) in subDatas.enumerated() {
            let subRequest = PageCreateRequest(
                parent: .page(page.id),
                properties: [
                    "title": .init(
                        type: .title([
                            .init(string: "\(count)")
                        ])
                    ),
                ]
            )
            
            let subPage = try await notion.pageCreate(request: subRequest)
            
            for (count, _subData) in subData.sub(11).enumerated() {
                let subRequest = PageCreateRequest(
                    parent: .page(subPage.id),
                    properties: [
                        "title": .init(
                            type: .title([
                                .init(string: "\(count)")
                            ])
                        ),
                    ],
                    children: [
                        .init(type: .paragraph(.init(text: _subData.map { RichText(string: $0) })))
                    ]
                )
                
                _ = try await notion.pageCreate(request: subRequest)
                
                uploaded += _subData.reduce("", +).count
                progress?(uploaded, all)
            }
        }
        
        return UUID(uuidString: page.id.rawValue)
    }
    
    public func download(_ uuid: UUID, progress: ((Int, Int) -> ())? = nil) async throws -> Data? {
        let pageId = Page.Identifier.init(uuid.uuidString.lowercased())
        let page = try await notion.page(pageId: pageId)
        let all = Int(getTitle(page).split(separator: " ").last ?? "0") ?? 0
        let blocks = try await notion.blockChildren(blockId: page.id.toBlockIdentifier)
        var text = ""
        for block in blocks {
            let groupBloacks = try await notion.blockChildren(blockId: block.id)
            for groupBloack in groupBloacks {
                let childBloacks = try await notion.blockChildren(blockId: groupBloack.id)
                for childBloack in childBloacks {
                    if case BlockType.paragraph(let paragraph) = childBloack.type {
                        text += paragraph.text.compactMap(\.plainText).reduce("", +)
                        progress?(text.count, all)
                    }
                }
            }
        }
        
        return Data(base64Encoded: text)
    }
    
    private func getTitle(_ page: Page) -> String {
        if let type = page.properties["title"]?.type {
            if case PagePropertyType.title(let texts) = type {
                return texts.compactMap {
                    $0.plainText
                }.reduce("", +)
            }
        }
        
        return ""
    }

    
    public static func getAllPages(_ token: String) async throws -> [Page] {
        let notion = NotionClient(accessKeyProvider: StringAccessKeyProvider(accessKey: token))
        return try await notion.searchPages()
    }
}
