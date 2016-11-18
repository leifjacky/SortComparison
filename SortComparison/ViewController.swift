//
//  ViewController.swift
//  SortComparison
//
//  Created by Leif on 9/13/16.
//  Copyright © 2016 Leif. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, CAAnimationDelegate {

    @IBOutlet weak var slowMode: NSButton!
    @IBOutlet weak var popUpButtonSelect: NSPopUpButton!
    @IBOutlet weak var textFieldN: NSTextField!
    @IBOutlet weak var leftView: NSView!
    @IBOutlet weak var rightView: NSView!
    
    var selectSort: [String]!
    var numbers: [UInt32]!, id = [Int](), countOfNumbers: Int!
    var positionOperations: [PositionOperation]!, textFields: [NSTextField]!
    var sort = Sort(),now = 0, cnt = 0, lazy = 0    //ViewController主要负责显示界面与动画，排序用Sort类完成
    
    // 配置界面
    override func viewDidLoad() {
        super.viewDidLoad()
        
        slowMode.state = 0
        
        textFieldN.wantsLayer = true
        
        selectSort = ["选择排序", "冒泡排序", "合并排序", "快速排序", "插入排序"]
        popUpButtonSelect.removeAllItems()
        popUpButtonSelect.addItems(withTitles: selectSort)
        popUpButtonSelect.selectItem(at: 0)
        leftView.addSubview(popUpButtonSelect)
    
        textFieldN.isEditable = true
        textFieldN.stringValue = "8"
        leftView.addSubview(textFieldN)
        
        self.view.wantsLayer = true
        leftView.wantsLayer = true
        rightView.wantsLayer = true
        self.view.addSubview(leftView)
        self.view.addSubview(rightView)
    }
    
    // 生成随机数
    @IBAction func generateNumbers(_ sender: AnyObject) {
        removeNumbers()
        countOfNumbers = Int(textFieldN.stringValue)!
        numbers = sort.generateNumbers(countOfNumbers: countOfNumbers)
        id = sort.generateId(countOfNumbers: countOfNumbers)
        drawNumbers()
    }
    
    // 重置
    @IBAction func resetNumbers(_ sender: AnyObject) {
        removeNumbers()
        numbers = sort.resetNumbers()
        id = sort.resetId()
        drawNumbers()
    }
    
    // 删除数字
    func removeNumbers(){
        for uiview in rightView.subviews{
            uiview.removeFromSuperview()
        }
    }
    
    // 显示数字
    func drawNumbers(){
        let width:CGFloat = 30, height: CGFloat = 30
        let originX:CGFloat = 10.0, originY:CGFloat = 220.0
        
        textFields = [NSTextField](repeating: NSTextField(), count: 1)
        for k in 1...countOfNumbers{
            var i = (k - 1) / 8 + 1, j = k % 8
            if j == 0{ j = 8 }
            let rect = CGRect(x: originX + (width + 5.0) * CGFloat(j - 1), y: originY - (height + 5.0) * CGFloat(i - 1), width: width, height: height)
            let textView = NSTextField(frame: rect)
            
            textView.isEditable = false
            textView.wantsLayer = true
            textView.layer?.borderWidth = 2.0
            textView.layer?.borderColor = NSColor.white.cgColor
            textView.layer?.cornerRadius = width / 2
            
            textView.stringValue = String(numbers[k])
            textView.alignment = NSTextAlignment.center
            textView.font = NSFont(name: "Arial", size: textView.frame.height/2)
            
            textFields.append(textView)
            rightView.addSubview(textView)
        }
    }
    
    // 运行排序
    @IBAction func Run(_ sender: AnyObject) {
        positionOperations = sort.run(index: popUpButtonSelect.indexOfSelectedItem)     // 返回动画序列
        cnt = positionOperations.count      // 总共有cnt个动画
        now = 0     // 动画从0下标开始
        animationDidStop(CAAnimation(), finished: false)    // 调用animationDidStop，开始执行动画
    }
    
    // swap交换函数
    func swap(_ a: inout Int, b: inout Int){
        let c = a
        a = b
        b = c
    }
    
    func animationDidStart(_ anim: CAAnimation) {
        
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        let ratio: Double = slowMode.state == 1 ? 2.0 : min(0.8, 5.0/Double(countOfNumbers))
        let width:CGFloat = 30, height: CGFloat = 30
        let originX:CGFloat = 10.0, originY:CGFloat = 220.0
        let colors:[CGColor] = [NSColor.gray.cgColor, NSColor.blue.cgColor, NSColor.red.cgColor]

        // 根据不同动画类型显示动画
        if now < cnt{
            let oper = positionOperations[now]
            switch oper.type{
            case 1:
                lazy = 2
                let point1 = textFields[id[oper.from]].frame
                let point2 = textFields[id[oper.to]].frame
                var swapAnimation1 = CABasicAnimation(keyPath: "position")
                swapAnimation1.fromValue = NSValue(point: point1.origin)
                swapAnimation1.toValue = NSValue(point: point2.origin)
                swapAnimation1.duration = 1 * ratio
                swapAnimation1.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//                swapAnimation1.delegate = self
                
                var swapAnimation2 = CABasicAnimation(keyPath: "position")
                swapAnimation2.fromValue = NSValue(point: point2.origin)
                swapAnimation2.toValue = NSValue(point: point1.origin)
                swapAnimation2.duration = 1 * ratio
                swapAnimation2.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                swapAnimation2.delegate = self
                
                textFields[id[oper.from]].layer?.add(swapAnimation1, forKey: nil)
                textFields[id[oper.to]].layer?.add(swapAnimation2, forKey: nil)
                
                textFields[id[oper.from]].frame = point2
                textFields[id[oper.to]].frame = point1
                swap(&id[oper.from], b: &id[oper.to])
            case 2:
                lazy = 1
                
                var i = (oper.from - 1) / 8 + 1, j = oper.from % 8
                if j == 0{ j = 8 }
                let point1 = CGPoint(x: originX + (width + 5.0) * CGFloat(j - 1), y: originY - (height + 5.0) * CGFloat(i - 1));
                
                i = (oper.to - 1) / 8 + 1; j = oper.to % 8
                if j == 0{ j = 8 }
                let point2 = CGPoint(x: originX + (width + 5.0) * CGFloat(j - 1), y: originY - (height + 5.0) * CGFloat(i - 1));
                
                var alpha: NSNumber = 1.0
                switch oper.other{
                case 1:
                    alpha = 0.5
                case 2:
                    alpha = 0.5
                case 3:
                    alpha = 0.8
                default:
                    alpha = 1.0
                }
                
                var moveAnimation = CABasicAnimation(keyPath: "position")
                moveAnimation.fromValue = NSValue(point: point1)
                moveAnimation.toValue = NSValue(point: point2)
                moveAnimation.duration = 0.9 * ratio
                moveAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//                moveAnimation.delegate = self
                
                var alphaAnimation = CABasicAnimation(keyPath: "opacity")
                alphaAnimation.fromValue = textFields[id[oper.from]].alphaValue
                alphaAnimation.toValue = alpha
                alphaAnimation.duration = 0.9 * ratio
                alphaAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                moveAnimation.delegate = self
                
                textFields[id[oper.from]].layer?.add(moveAnimation, forKey: nil)
                textFields[id[oper.from]].layer?.add(alphaAnimation, forKey: nil)
                
                textFields[id[oper.from]].frame = NSRect(origin: point2, size: CGSize(width: width, height: height))
                textFields[id[oper.from]].alphaValue = CGFloat(alpha)
                
                id[oper.to] = id[oper.from]
            case 3:
                var alpha:Float = Float(1.0)
                let l = oper.from, r = oper.to
                
                var opacityAnimation = CABasicAnimation(keyPath: "opacity")
                opacityAnimation.fromValue = NSNumber(value: 1.0)
                opacityAnimation.toValue = NSNumber(value: 0.2)
                opacityAnimation.duration = 0.6 * ratio
                opacityAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                opacityAnimation.autoreverses = true
                
                if oper.other > 10{
                    switch oper.other / 10{
                    case 1:
                        opacityAnimation.toValue = NSNumber(value: 0.5)
                        alpha = Float(0.5)
                        opacityAnimation.autoreverses = false
                    case 2:
                        opacityAnimation.duration = 1.0 * ratio
                        opacityAnimation.fromValue = NSNumber(value: 0.5)
                        opacityAnimation.toValue = NSNumber(value: 1.0)
                        opacityAnimation.autoreverses = false
                    default:
                        print(3, oper.other)
                    }
                }
//                colorAnimation.delegate = self
                
                switch oper.other % 10{
                case 0:
                    textFields[id[oper.from]].layer?.add(opacityAnimation, forKey: nil)
                    opacityAnimation.delegate = self
                    textFields[id[oper.to]].layer?.add(opacityAnimation, forKey: nil)
                case 1:
                    if countOfNumbers >= 15 && slowMode.state == 0{
                        opacityAnimation.duration = 0.2
                    }
                    for i in l!...r!{
                        if i == r { opacityAnimation.delegate = self }
                        if oper.other > 10 { textFields[id[i]].alphaValue = CGFloat(alpha) }
                        textFields[id[i]].layer?.add(opacityAnimation, forKey: nil)
                    }
                default :
                    print(3-0)
                }
            default:
                print(0)
            }
            now += 1
        }
    }
}

