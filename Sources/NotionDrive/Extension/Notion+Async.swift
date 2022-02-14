//
//  Notion+Async.swift
//  
//
//  Created by 朱浩宇 on 2022/2/14.
//

import NotionSwift

extension NotionClient {
    func searchPages() async throws -> [Page] {
        return try await withCheckedThrowingContinuation { continuation in
            self.search(request: .init(filter: .page)) { result in
                switch result {
                case .success(let objects):
                    let items = objects.results.compactMap({ object -> Page? in
                        if case .page(let pg) = object {
                            return pg
                        }
                        
                        return nil
                    })
                    
                    continuation.resume(returning: items)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func pageCreate(request: PageCreateRequest) async throws -> Page {
        return try await withCheckedThrowingContinuation { continuation in
            self.pageCreate(request: request) {
                switch $0 {
                case .success(let page):
                    continuation.resume(returning: page)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func page(pageId: Page.Identifier) async throws -> Page {
        return try await withCheckedThrowingContinuation { continuation in
            self.page(pageId: pageId) {
                switch $0 {
                case .success(let page):
                    continuation.resume(returning: page)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func blockChildren(blockId: Block.Identifier, params: BaseQueryParams = .init()) async throws -> [ReadBlock] {
        return try await withCheckedThrowingContinuation { continuation in
            self.blockChildren(blockId: blockId, params: params) {
                switch $0 {
                case .success(let list):
                    continuation.resume(returning: list.results)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
