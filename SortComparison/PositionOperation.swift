//
//  PositionOperation.swift
//  SortComparison
//
//  Created by Leif on 9/18/16.
//  Copyright © 2016 Leif. All rights reserved.
//

import Cocoa

// PositionOperation 定义动画类型

//操作1：交换位置
//操作2：移动到新位置
//操作3：other 0 两者比较    other 1 范围闪烁
class PositionOperation:NSObject{
    var type: Int!, from: Int!, to: Int!, other: Int!
    
    init(type: Int, from: Int, to: Int, other: Int){
        self.type = type
        self.from = from
        self.to = to
        self.other = other
    }
}
