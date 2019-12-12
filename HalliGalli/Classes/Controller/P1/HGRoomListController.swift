//
//  HGRoomListController.swift
//  HalliGalli
//
//  Created by apple on 2019/11/26.
//  Copyright © 2019 HalliGalli. All rights reserved.
//  房间列表页面

import UIKit

class HGRoomListController: UIViewController {

    //MARK: 需要修改
    /// 数据源
    public var dataSource: [RoomInfo] = []
    
    /// 选中的房间
    fileprivate var selectedRoomInfo: RoomInfo?
    
    /// TableView
    fileprivate lazy var tableView: UITableView = {
        let object = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
        object.delegate = self
        object.dataSource = self
        object.tableFooterView = UIView()
        object.showsVerticalScrollIndicator = false
        object.showsHorizontalScrollIndicator = false
        object.layer.cornerRadius = 5
        object.layer.masksToBounds = true
        return object
    }()
    
    //“加入”按钮的属性设置
    fileprivate lazy var joinButton: UIButton = {
        let object = UIButton(type: UIButton.ButtonType.custom)
        object.setTitle("加入", for: UIControl.State.normal);
        object.setTitle("加入", for: UIControl.State.highlighted);
        object.setTitleColor(UIColor.white, for: UIControl.State.normal)
        object.setTitleColor(UIColor.white, for: UIControl.State.highlighted)
        object.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        object.setBackgroundImage(UIImage.imageFromColor(color: kMainThemeColor), for: UIControl.State.normal)
        object.setBackgroundImage(UIImage.imageFromColor(color: kMainThemeColor.withAlphaComponent(0.5)), for: UIControl.State.highlighted)
        object.layer.cornerRadius = 5
        object.layer.masksToBounds = true
        object.addTarget(self, action: #selector(doAction(sender:)), for: UIControl.Event.touchUpInside)
        object.isEnabled = false
        return object;
    }()
    
    //一个简单的label“房间列表”
    fileprivate lazy var listTitleL: UILabel = {
        let object = UILabel()
        object.text = "房间列表"
        object.textAlignment = .center
        object.textColor = kMainThemeColor
        object.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium)
        return object
    }()
    
    //“取消“按钮的属性设置
    fileprivate lazy var cancelButton: UIButton = {
        let object = UIButton(type: UIButton.ButtonType.custom)
        object.setTitle("取消", for: UIControl.State.normal);
        object.setTitle("取消", for: UIControl.State.highlighted);
        object.setTitleColor(UIColor.white, for: UIControl.State.normal)
        object.setTitleColor(UIColor.white, for: UIControl.State.highlighted)
        object.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
        object.setBackgroundImage(UIImage.imageFromColor(color: kMainThemeColor), for: UIControl.State.normal)
        object.setBackgroundImage(UIImage.imageFromColor(color: kMainThemeColor.withAlphaComponent(0.5)), for: UIControl.State.highlighted)
        object.layer.cornerRadius = 5
        object.layer.masksToBounds = true
        object.addTarget(self, action: #selector(doAction(sender:)), for: UIControl.Event.touchUpInside)
        return object;
    }()

    //背景图片
    fileprivate lazy var backgroundImageView: UIImageView = {
        let object = UIImageView()
        object.contentMode = UIView.ContentMode.scaleAspectFill
        object.image = UIImage.imageFromColor(color: UIColor.lightGray, inSize: self.view.bounds.size)
        return object
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //开始接收udp信息
        player.Start_UDP_Receive()
        
        //房间列表的数据源，各个房间信息
        dataSource = [RoomInfo(roomID: "RUA"+"的房间", roomAddress: "1.0.0.0", roomCount: 3)]
//        dataSource = [
//            RoomInfo(isstarted:false,roomID: 1, count: 121),
//            RoomInfo(isstarted:false,roomID: 2, count: 122),
//            RoomInfo(isstarted:false,roomID: 3, count: 123),
//            RoomInfo(isstarted:false,roomID: 4, count: 124),
//            RoomInfo(isstarted:false,roomID: 5, count: 125),
//            RoomInfo(isstarted:false,roomID: 6, count: 126)]
        setupUI()
    }

    fileprivate func setupUI() {
        view.backgroundColor = UIColor.white
        view.addSubview(backgroundImageView)
        view.addSubview(listTitleL)
        view.addSubview(tableView)
        view.addSubview(joinButton)
        view.addSubview(cancelButton)
        
        //用snp约束对UI组件进行布局
        backgroundImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        listTitleL.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.left.right.equalTo(tableView)
            make.centerX.equalTo(view)
        }
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(listTitleL.snp.bottom).offset(5)
            make.width.equalTo(360)
            make.bottom.equalTo(-40)
            make.centerX.equalTo(view).offset(-50)
        }
        
        joinButton.snp.makeConstraints { (make) in
            make.left.equalTo(tableView.snp.right).offset(40)
            make.size.equalTo(CGSize(width: 100, height: 44))
            make.centerY.equalTo(tableView.snp.centerY).offset(-30)
        }
        
        cancelButton.snp.makeConstraints { (make) in
            make.left.equalTo(tableView.snp.right).offset(40)
            make.size.equalTo(CGSize(width: 100, height: 44))
            make.centerY.equalTo(tableView.snp.centerY).offset(30)
        }
    }
    
    
    //按钮行为
    @objc fileprivate func doAction(sender: UIButton) {
        if sender ==  joinButton {//选择好房间以后点击加入按钮，跳转到roomwait等待界面
            let roomController = HGRoomWaitController()
            //roomController.roomInfo = selectedRoomInfo
            navigationController?.pushViewController(roomController, animated: true)
        } else if sender == cancelButton {//点击取消按钮则回到上一页
            player.Close_UDP_Receive()
            navigationController?.popViewController(animated: true)
        }
    }
    
    override var canEdgePanBack: Bool {
        return false
    }
}


extension HGRoomListController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "UITableViewCell")
        }
        let currentInfo = dataSource[indexPath.row]//当前点击的行数，即要选择加入的房间
        cell.textLabel?.numberOfLines=0
        cell.textLabel?.text = """
        \(currentInfo.roomID ?? "error")
        \(currentInfo.roomAddress ?? "error")
        """ //cell的文本名称标注房间名（房间ID）
        cell.detailTextLabel?.snp.makeConstraints { (make) in
            make.centerX.equalTo(cell.textLabel!).offset(250)
            make.centerY.equalTo(cell.textLabel!)
        }
        cell.detailTextLabel?.font=UIFont.monospacedDigitSystemFont(ofSize: 25, weight: .heavy)
        cell.detailTextLabel?.text="\(currentInfo.roomCount ?? 0)/6"
        if selectedRoomInfo != nil && currentInfo.roomID == selectedRoomInfo?.roomID {
            cell.textLabel?.textColor = kMainThemeColor
        } else {
            cell.textLabel?.textColor = UIColor.black
        }
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRoomInfo = dataSource[indexPath.row]//当前点击的行数，即要选择加入的房间
        joinButton.isEnabled = true//选择好房间后让加入按钮亮起变成可点击状态
        tableView.reloadData()
    }
}
