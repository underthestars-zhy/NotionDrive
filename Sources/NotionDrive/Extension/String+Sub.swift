//
//  String+Sub.swift
//  
//
//  Created by 朱浩宇 on 2022/2/14.
//

import Foundation

extension String {
    func sub(_ count: Int) -> [String] {
        var res = [String]()
        var start = 0
        var end = count - 1
        
        while start < self.count {
            if end >= self.count {
                res.append(self[start..<self.count])
                break
            } else {
                res.append(self[start..<end])
                start = end
                end = start + count - 1
            }
        }
        
        return res
    }
}
