//
//  CommonDefine.swift
//  HalliGalli
//
//  Created by apple on 2019/11/26.
//  Copyright © 2019 HalliGalli. All rights reserved.
//

import Foundation
import UIKit

/// 服务器
var server:Server = Server()
/// 玩家
var player:Player = Player()
/// UDP广播时间控制器
var control_timer: Timer = Timer()
/// 房间列表刷新时间控制器
var roomlist_timer: Timer = Timer()
// 横屏是否显示状态栏，使用私有API显示， 崩溃请设置为false
let kShowStatusBarWhenLandScape: Bool = true
/// 项目主要颜色
let kMainThemeColor: UIColor = UIColor(hex: 0x0084FB)

/// 所有牌的种类，前缀为0  90张 3-5人一人16张 6人一人15张
let Cards:[String] = ["000100","000100","000100","001010","001010","001010","001110","001110","001110","011011","011011","011011","011111","011111","000200","000200","000200","002020","002020","002020","002220","002220","002220","022022","022022","022022","022222","022222","000300","000300","000300","003030","003030","003030","003330","003330","003330","033033","033033","033033","033333","033333","000400","000400","000400","004040","004040","004040","004440","004440","004440","044044","044044","044044","044444","044444","004120","004340","004240","004140","034044","024044","014044","003020","002040","003230","003430","003130","023033","043033","013033","011211","013042","001210","001410","001310","021011","041011","031011","003010","003040","012022","042022","032022","002120","002420","002320","003120","002010","004010"]
