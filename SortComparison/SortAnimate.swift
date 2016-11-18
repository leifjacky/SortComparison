//
//  SortAnimate.swift
//  SortComparison
//
//  Created by Leif on 9/18/16.
//  Copyright © 2016 Leif. All rights reserved.
//

import Cocoa

// Sort 用于排序并生成动画序列，返回动画序列给ViewController
class Sort: NSObject {
    var numbers: [UInt32]!,countOfNumbers: Int!, copy: [UInt32]!    // numbers保存随机数，copy为numbers的副本，countOfNumbers表示当前规模
    var ret = [PositionOperation]()     // 返回一个动画序列
    
    // 生成随机数
    func generateNumbers(countOfNumbers: Int) -> [UInt32]{
        self.countOfNumbers = countOfNumbers
        numbers = [UInt32](repeating: 0, count: countOfNumbers * 2 + 1)
        for i in 1...countOfNumbers{
            numbers[i] = arc4random() % 99 + 1
        }
        copy = numbers
        return numbers
    }
    
    // 重置
    func resetNumbers() -> [UInt32]{
        numbers = copy
        return numbers
    }
    
    // 给每个位置一个编号，动画序列使用编号操作数字移动
    func generateId(countOfNumbers: Int) -> [Int]{
        var id = [Int](repeating: 0, count: countOfNumbers * 2 + 1)
        for i in 1...countOfNumbers{
            id[i] = Int(i)
        }
        return id
    }
    
    // 重置id
    func resetId() -> [Int]{
        return generateId(countOfNumbers: countOfNumbers)
    }
    
    // 运行排序
    func run(index: Int) -> [PositionOperation]{
        ret = [PositionOperation]()
        
        let algorithm = getSort(index)
        algorithm(1, countOfNumbers)
        return ret
    }
    
    // 获取当前选择排序方法
    func getSort(_ index: Int) -> (Int, Int) -> (){
        switch index {
        case 0:
            return selectionSort
        case 1:
            return bubbleSort
        case 2:
            return mergeSort
        case 3:
            return quickSort
        case 4:
            return insertSort
        default:
            return selectionSort
        }
    }
    
    // 选择排序
    func selectionSort(_ L: Int, R:Int){
        for i in 1..<countOfNumbers{
            var pos = i
            ret.append(PositionOperation(type: 3, from: i, to : countOfNumbers, other:1))
            for j in i+1...countOfNumbers{
                if numbers[pos] > numbers[j]{
                    pos = j
                }
            }
            ret.append(PositionOperation(type: 3, from: pos, to: pos, other: 1))
            if (pos != i){
                ret.append(swap(pos, j: i, a: &numbers[pos], b: &numbers[i]))
            }
        }
    }
    
    // 冒泡排序
    func bubbleSort(_ L: Int, R:Int){
        for i in 1..<countOfNumbers{
            for j in 1...countOfNumbers - i{
                ret.append(PositionOperation(type: 3, from: j, to: j + 1, other: 0))
                if numbers[j] > numbers[j+1]{
                    ret.append(swap(j, j: j+1, a: &numbers[j], b: &numbers[j + 1]))
                }
            }
            ret.append(PositionOperation(type: 2, from: countOfNumbers - i + 1, to: countOfNumbers - i + 1, other: 2))
        }
        ret.append(PositionOperation(type: 2, from: 1, to: 1, other: 2))
        ret.append(PositionOperation(type: 3, from: L, to: R, other: 21))
    }
    
    // 归并排序，递归函数
    func mergeSort(_ L: Int, R:Int){
        if L<R{
            let M = (L + R) >> 1
            mergeSort(L, R: M)
            mergeSort(M+1, R: R)
            merge(L, R: R)
        }
    }
    
    // 归并排序，合并函数
    func merge(_ L:Int, R:Int){
        let M = (L + R) >> 1
        var temp = [UInt32](repeating: 0, count: R - L + 2), pos = 1
        var i = L, j = M + 1
        ret.append(PositionOperation(type: 3, from: L, to: M, other: 1))
        ret.append(PositionOperation(type: 3, from: M + 1, to: R, other: 1))
        while i <= M && j <= R{
            ret.append(PositionOperation(type: 3, from: i, to: j, other: 0))
            if numbers[i] < numbers[j]{
                ret.append(PositionOperation(type: 2, from: i, to: countOfNumbers + pos, other: 1))
                temp[pos] = numbers[i]
                pos += 1; i += 1;
            }else{
                ret.append(PositionOperation(type: 2, from: j, to: countOfNumbers + pos, other: 1))
                temp[pos] = numbers[j]
                pos += 1; j += 1;
            }
        }
        while i <= M{
            ret.append(PositionOperation(type: 2, from: i, to: countOfNumbers + pos, other: 1))
            temp[pos] = numbers[i]
            pos += 1; i += 1;
        }
        while j <= R{
            ret.append(PositionOperation(type: 2, from: j, to: countOfNumbers + pos, other: 1))
            temp[pos] = numbers[j]
            pos += 1; j += 1;
        }
        for k in L...R{
            ret.append(PositionOperation(type: 2, from: countOfNumbers + k - L + 1, to: k, other: 0))
            numbers[k] = temp[k - L + 1]
        }
    }
    
    // 快速排序
    func quickSort(_ L: Int, R:Int){
        var i = L, j = R
        ret.append(PositionOperation(type: 3, from: L, to: R, other: 1))
        ret.append(PositionOperation(type: 2, from: i, to: countOfNumbers + 1, other: 1))
        numbers[countOfNumbers + 1] = numbers[i]
        
        while i < j{
            while numbers[j] > numbers[countOfNumbers + 1] && i < j{
                ret.append(PositionOperation(type: 2, from: j, to: j, other: 2))
                j -= 1
            }
            if i < j{
                ret.append(PositionOperation(type: 2, from: j, to: i, other: 2))
                numbers[i] = numbers[j]
                i += 1
            }
            
            while numbers[i] < numbers[countOfNumbers + 1] && i < j{
                ret.append(PositionOperation(type: 2, from: i, to: i, other: 2))
                i += 1
            }
            if i < j{
                ret.append(PositionOperation(type: 2, from: i, to: j, other: 2))
                numbers[j] = numbers[i]
                j -= 1
            }
        }
        
        ret.append(PositionOperation(type: 2, from: countOfNumbers + 1, to: i, other: 0))
        ret.append(PositionOperation(type: 3, from: L, to: R, other: 21))
        numbers[i] = numbers[countOfNumbers + 1]
        i += 1; j -= 1;
        if (L < j){ quickSort(L, R: j) }
        if (i < R){ quickSort(i, R: R) }
    }
    
    // 插入排序
    func insertSort(_ L: Int, R:Int){
        ret.append(PositionOperation(type: 2, from: 1, to: 1, other: 2))
        for i in 2...countOfNumbers{
            numbers[countOfNumbers + 1] = numbers[i]
            ret.append(PositionOperation(type: 2, from: i, to: countOfNumbers + 1, other: 3))
            var j = i
            for _ in 1..<i {
                if numbers[j - 1] <= numbers[countOfNumbers + 1]{
                    break
                }
                ret.append(PositionOperation(type: 2, from: j - 1, to: j, other: 2))
                numbers[j] = numbers[j - 1]
                j -= 1
            }
            ret.append(PositionOperation(type: 2, from: countOfNumbers + 1, to: j, other: 2))
            numbers[j] = numbers[countOfNumbers + 1]
        }
        ret.append(PositionOperation(type: 3, from: L, to: R, other: 21))
    }
    
    // 交换函数
    func swap(_ i: Int, j: Int, a: inout UInt32, b: inout UInt32) -> PositionOperation{
        let c = a
        a = b
        b = c
        return PositionOperation(type: 1, from: i, to: j, other: 0)
    }
}
