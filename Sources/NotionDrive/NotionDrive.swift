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
    
    public func upload(_ data: Data, name: String) async throws -> UUID? {
        let request = PageCreateRequest(
            parent: .page(id),
            properties: [
                "title": .init(
                    type: .title([
                        .init(string: name)
                    ])
                ),
            ]
        )
        
        let page = try await notion.pageCreate(request: request)
        
        let datas = data.base64EncodedString().sub(2000)
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
            
            for (count, _subData) in subData.enumerated() {
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
                        .init(type: .paragraph(.init(text: [.init(string: _subData)])))
                    ]
                )
                
                _ = try await notion.pageCreate(request: subRequest)
            }
        }
        
        return UUID(uuidString: page.id.rawValue)
    }
    
    public func download(_ uuid: UUID) async throws -> Data? {
        let pageId = Page.Identifier.init(uuid.uuidString.lowercased())
        let page = try await notion.page(pageId: pageId)
        let blocks = try await notion.blockChildren(blockId: page.id.toBlockIdentifier)
        var text = ""
        for block in blocks {
            let groupBloacks = try await notion.blockChildren(blockId: block.id)
            for groupBloack in groupBloacks {
                let childBloacks = try await notion.blockChildren(blockId: groupBloack.id)
                for childBloack in childBloacks {
                    if case BlockType.paragraph(let paragraph) = childBloack.type {
                        if let subData = paragraph.text.first?.plainText{
                            text += subData
                        }
                    }
                }
            }
        }
        
        return Data(base64Encoded: text)
    }

    
    static func getAllPages(_ token: String) async throws -> [Page] {
        let notion = NotionClient(accessKeyProvider: StringAccessKeyProvider(accessKey: token))
        return try await notion.searchPages()
    }
}
