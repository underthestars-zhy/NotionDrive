//
//  File.swift
//  
//
//  Created by 朱浩宇 on 2022/2/14.
//

import Foundation

extension Array {
    func sub(_ count: Int) -> [[Element]] {
        var res = [[Element]]()
        var start = 0
        var end = count - 1
        
        while start < self.count {
            if end >= self.count {
                res.append(self[start..<self.count].map { $0 })
                break
            } else {
                res.append(self[start..<end].map { $0 })
                start = end
                end = start + count - 1
            }
        }
        
        return res
    }
}
