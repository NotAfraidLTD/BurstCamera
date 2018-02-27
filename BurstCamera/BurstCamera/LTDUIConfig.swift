//
//  LTDUIConfig.swift
//  YLTService
//
//  Created by 雪 on 2017/6/8.
//  Copyright © 2017年 YLT. All rights reserved.
//

import Foundation
import UIKit

/**
 *  屏幕尺寸
 */
let kScreenWidth = UIScreen.main.bounds.size.width
let kScreenHeight = UIScreen.main.bounds.size.height

/**
 *  比例计算
 */

class LSize: NSObject {
    class func adapt(_ size: CGFloat) -> CGFloat {
        return kScreenWidth > 325.0 ? size : size/375*320
    }
}
/**
 *  字体大小
 */
let kBigTextFont = UIFont.systemFont(ofSize: 18)
let kMidTextFont = UIFont.systemFont(ofSize: 14)
let kSmallTextFont = UIFont.systemFont(ofSize: 12)

/**
 *  常规尺寸
 */
///边框粗细
let kBorderLineThickness : CGFloat = 0.8
///cell边线
let kBorderCellLineThickness : CGFloat = 8
///cell的高
let kCellNormal_H : CGFloat = 44
///NavigationBar
let kNav_H : CGFloat = 64
///TabBar的常规高
let kTabbar_H : CGFloat = 49
let kStutasBar_H : CGFloat = 20

/**
 *  获取系统时区的时间
 */
func getLocaleDate(_ date : Date) -> Date {
   
    let zone = TimeZone.current
    
    let interval : Int = zone.secondsFromGMT(for: date)
    let localeDate = date.addingTimeInterval(TimeInterval.init(interval))
    return localeDate
}

//RGB
func RGBA (_ r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat) -> UIColor {
    return UIColor (red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
}
func kThemeColor() -> UIColor {
    return RGBA(77, g: 160, b: 233, a: 1.0)
}
func anyColor() -> UIColor{
    return RGBA(CGFloat(arc4random()%256), g: CGFloat(arc4random()%256), b: CGFloat(arc4random()%256), a: 1.0)
}

func transferStringToColor(hexString:String, alpha:CGFloat) -> UIColor {
    
    var color = UIColor.red
    var cStr : String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    
    if cStr.hasPrefix("#") {
        let index = cStr.index(after: cStr.startIndex)
        cStr = cStr.substring(from: index)
    }
    if cStr.count != 6 {
        return UIColor.black
    }
    
    let rRange = cStr.startIndex ..< cStr.index(cStr.startIndex, offsetBy: 2)
    let rStr = cStr.substring(with: rRange)
    
    let gRange = cStr.index(cStr.startIndex, offsetBy: 2) ..< cStr.index(cStr.startIndex, offsetBy: 4)
    let gStr = cStr.substring(with: gRange)
    
    let bIndex = cStr.index(cStr.endIndex, offsetBy: -2)
    let bStr = cStr.substring(from: bIndex)
    
    var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
    Scanner(string: rStr).scanHexInt32(&r)
    Scanner(string: gStr).scanHexInt32(&g)
    Scanner(string: bStr).scanHexInt32(&b)
    
    color = UIColor.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    
    return color
}


//背景灰色
func kBgDarkColor() -> UIColor {
    return transferStringToColor(hexString:"#f2f2f2", alpha: 1.0)
}
//导航颜色
func kNavigationColor() -> UIColor {
    return transferStringToColor(hexString:"#33394a", alpha: 1.0)
}
//接单栏色
func kHeaderColor() -> UIColor {
    return transferStringToColor(hexString:"#41485a", alpha: 1.0)
}
//背景白色
func kBgWhiteColor() -> UIColor {
    return transferStringToColor(hexString:"#FFFFFF", alpha: 1.0)
}
//边框颜色
func kBorderLineColor() -> UIColor {
    return transferStringToColor(hexString:"#dfdfdf", alpha: 1.0)
}
//默认黑 用于默认黑色
func kMaxBlackColor() -> UIColor {
    return transferStringToColor(hexString:"#333333", alpha: 1.0)
}
//中性黑 用于灰色
func kMidBlackColor() -> UIColor {
    return transferStringToColor(hexString:"#666666", alpha: 1.0)
}
//浅黑 用于textField等placehorder文字颜色 还有时间
func kMinBlackColor() -> UIColor {
    return transferStringToColor(hexString:"#999999", alpha: 1.0)
}
//用于cell灰色
func kCellBackGroundColor() -> UIColor {
    return transferStringToColor(hexString:"#fafafa", alpha: 1.0)
}
//阴影
func kShadowColor() -> UIColor {
    return transferStringToColor(hexString:"#acbbc6", alpha: 1.0)
}
//橙色
func kOrangeColor() -> UIColor {
    return transferStringToColor(hexString:"#f48830", alpha: 1.0)
}
//红色
func kRedColor() -> UIColor {
    return transferStringToColor(hexString:"#e51d1d", alpha: 1.0)
}
//粉色
func kPinkColor() -> UIColor {
    return transferStringToColor(hexString:"#f22258", alpha: 1.0)
}
//黄色
func kYellowColor() -> UIColor {
    return transferStringToColor(hexString:"#f48830", alpha: 1.0)
}
//橘红色
func kHyacinthColor() -> UIColor {
    return transferStringToColor(hexString:"#f95b03", alpha: 1.0)
}
//蓝青色
func kIndigoColor() -> UIColor {
    return transferStringToColor(hexString:"#4993cb", alpha: 1.0)
}
//绿色
func kGreenColor() -> UIColor {
    return transferStringToColor(hexString:"#17c0a6", alpha: 1.0)
}
//灰色
func KGrayColor() -> UIColor {
    return transferStringToColor(hexString:"#8f8f8f", alpha: 1.0)
}
//蓝色
func kBlueColor() -> UIColor {
    return transferStringToColor(hexString:"#529bf4", alpha: 1.0)
}
//标题颜色
func kHeadColor() -> UIColor {
    return transferStringToColor(hexString:"#41485a", alpha: 1.0)
}
//输入颜色
func kTextColor() -> UIColor {
    return transferStringToColor(hexString:"#777777", alpha: 1.0)
}
//提示颜色
func kReminderColor() -> UIColor {
    return transferStringToColor(hexString:"#023765", alpha: 1.0)
}


