//
//  Player.swift
//  HalliGalli
//
//  Created by JASON on 2019/12/9.
//  Copyright © 2019 HalliGalli. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

///继承 GCDAsyncUdpSocket 和 GCDAsyncSocket
class Player: NSObject, GCDAsyncUdpSocketDelegate, GCDAsyncSocketDelegate{
    
    /// 玩家信息
    var userinfo:UserInfo = UserInfo()
    /// true为房主 false为普通玩家
    var status:Bool?
    
    /// 房间列表信息
    var room_list:[RoomInfo] = []
    ///UDP socket
    var udp_socket:GCDAsyncUdpSocket?
    ///UDP error
    var udp_error:String?
    
    /// 房间人数
    var room_num:String?
    
    /// 服务器地址
    var server_ip: String?
    /// TCP socket
    var tcp_socket:GCDAsyncSocket?
    
//MARK: - 其他
    ///获得本机基本网络信息
    ///提醒打开wifi
    func Update_User_NetInfo(){
        userinfo.GetIPNetmask()
        userinfo.GetIdentifier()
        userinfo.ID = "player"
        
        //MARK:测试
//        print(userinfo.ip_address)
//        print(userinfo.identifier)
//        print(userinfo.net_mask)
        
    }
    
    ///按照时间差更新房间列表
    func Update_Roomlist_Info(){
        //对超时的房间进行remove处理
        var record:[Int] = []
        
        for i in 0..<room_list.count {
            let temp_room_time = room_list[i].rev_time!
            let timeInterval = -1 * temp_room_time.timeIntervalSinceNow
            
            //失联超过1s
            if timeInterval > 0.6 {
                record.append(i)
            }
        }
        
        //可能出错
        for i in 0..<record.count {
            room_list.remove(at: record[i] - i)
        }
        
        //清除房间列表
        room_list.removeAll()
    }

//MARK: - UDP
    ///UDP监听打开
    func Start_UDP_Receive(){
        //UDP初始化
        udp_socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do{
            try udp_socket?.bind(toPort: 2333, interface: udp_error)
        }catch{
            if let _ = udp_error{
                print(udp_error!)
            }
        }
        
        do{
            try udp_socket?.beginReceiving()
        }catch{
            print("start receiving fail")
        }
        print("开始监听UDP")
    }
    
    ///UDP监听关闭
    func Close_UDP_Receive(){
        udp_socket?.close()
        print("监听UDP关闭")
    }
    
    ///UDP接收
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        let msg:String = String(data: data,encoding: .utf8) ?? "error/error/error/error"
        
        //判断是否为指定的接收到的UDP（前缀判断）
        if msg.split(separator: "/")[0] == "HG"{
            //更新roominfo的信息和接收时间
            let temp_time:Date = Date()
            
            let temp_roomID = msg.split(separator: "/")[1]
            let temp_roomAddress = msg.split(separator: "/")[2]
            let temp_roomNumCount = msg.split(separator: "/")[3]
            
            var find_flag = false
            for room in room_list {
                if room.roomAddress! == String(temp_roomAddress) {
                    find_flag = true
                    room.roomID = String(temp_roomID)
                    room.roomCount = Int(String(temp_roomNumCount)) ?? 0
                    room.rev_time = temp_time
                }
            }
            
            if find_flag == false {
                room_list.append(RoomInfo(roomID: String(temp_roomID), roomAddress: String(temp_roomAddress), roomCount: Int(String(temp_roomNumCount)) ?? 0))
            }
        }
        
    }
    
    func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
        print("udp关闭成功")
    }
   
//MARK: - TCP
    
    /// TCP连接
    func Start_Connect()->Bool{
        tcp_socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        
        do{
            try tcp_socket?.connect(toHost: server_ip!, onPort: 3332,withTimeout: -1)
        }catch{
            print("连接失败")
            return false
        }
        
        print("连接 \(server_ip!)成功")
        tcp_socket?.readData(withTimeout: -1, tag: 0)
        return true
    }
    
    /// TCP断开连接
    func End_Connect(){
        tcp_socket?.disconnect()
        tcp_socket?.delegate = nil
        tcp_socket = nil
    }
    
    /// 发送TCP Socket
    func Send_TCP(socket_data: Data){
        tcp_socket?.write(socket_data, withTimeout: -1, tag: 0)
    }
    
    //MARK: 待完善
    /// 接收TCP socket
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        //读取和解读信息，处理信息
        let content:String = String(data:data,encoding: .utf8) ?? "wrong"
        if content.split(separator: "&")[0] == "HG" {
            if content.split(separator: "&")[1] == TCPKIND.Update_RoomPlayer_Num.rawValue {
                //更新房间人数
                room_num = String(content.split(separator: "&")[2])
                
            }else if content.split(separator: "&")[1] == TCPKIND.GAME_START.rawValue{
                //游戏开始
                room_status = 1
            }else if content.split(separator: "&")[1] == TCPKIND.ROOM_CLOSE.rawValue{
                //房间解散
                End_Connect()
                room_status = -1
            }else {
                
            }
        }
        
        //继续等待和读取服务器的TCP socket
        tcp_socket?.readData(withTimeout: -1, tag: 0)
    }
    
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        print("发送TCP成功")
    }
    
    //待观察
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print("成功连接到: \(host):\(port)")
    }

//MARK: - TCP INFO
    ///发送新加入玩家自己的信息
    func Send_Player_Info(){
        Send_TCP(socket_data: Tcp_Socket_ChangeInto_Data(tcp_socket: TCP_SOCKET(TCP_KIND: TCPKIND.ADD_PLAYER.rawValue, INFO: userinfo.UserInfo_into_String())))
    }
    
    ///发送玩家离开信息
    func Send_Player_Leave(){
        Send_TCP(socket_data: Tcp_Socket_ChangeInto_Data(tcp_socket: TCP_SOCKET(TCP_KIND: TCPKIND.PLAYER_LEAVE.rawValue, INFO: userinfo.UserInfo_into_String())))
    }
}
