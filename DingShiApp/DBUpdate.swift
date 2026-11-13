//
//  FirstViewController.swift
//  RefreshExample
//
//  Created by SunSet on 14-6-23.
//  Copyright (c) 2014 zhaokaiyuan. All rights reserved.
//

import UIKit

class DBUpdate: UITableViewController, XMLParserDelegate, NSURLConnectionDataDelegate
{
    var xmlContent: [String:String] = [:]
    var lastKey: String = String()
    var download: [String:NSURLConnection] = [:]
    var receivedData : [String:NSMutableData] = [:]
    var status: [String:UILabel] = [:]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationItem.title = Lang("dbupdate_title")
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TableViewCellIdentifier")
        
        DispatchQueue.global().async { self.checkUpdate() }
        self.setupRefresh()
    }
    
    func setupRefresh()
    {
        self.tableView.addHeaderWithCallback({
            self.xmlContent.removeAll(keepingCapacity: false)
            DispatchQueue.global().async { self.checkUpdate() }
            self.tableView.headerEndRefreshing()
        })
    }
    
    
    // 检查更新
    @objc func checkUpdate()
    {
        let url: URL? = URL(string: "http://www.xvqchinese.com/dsv2/txz/db_update/getdb.php?os=ios")
        let xmlData: Data! = try? Data(contentsOf: url!)
        
        if xmlData == nil
        {
            return
        }
        
        self.lastKey = "";
        let xml: XMLParser = XMLParser(data: xmlData)
        xml.delegate = self
        xml.parse()
        
        DispatchQueue.main.async { self.tableView.reloadData() }
        /**
        let content: NSString = String(data: xmlData, encoding: String.Encoding.utf8)!
        let alert = UIAlertView()
        alert.title = Lang("about_title")
        alert.delegate = self
        alert.message = content
        alert.addButtonWithTitle(Lang("about_button_ok"))
        alert.show()
        **/
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        if elementName == "item"
        {
            let name = attributeDict["name"]! as String
            
            MyLog("\(name)")
            self.lastKey = name
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String)
    {
        let value: NSString = string as NSString
        
        if value.length > 0 && self.xmlContent[self.lastKey] == nil && self.lastKey != ""
        {
            self.xmlContent[self.lastKey] = value as String
            MyLog("value = \(string)")
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 5 // 6  包含注音
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.cellForRow(at: indexPath)?.isSelected = false
        
        if indexPath.row == 0
        {
            // py
            if self.xmlContent["py_md5"] != nil && UserDefaults.standard.string(forKey: "py_md5") != self.xmlContent["py_md5"]
            {
                if self.xmlContent["py_url"] != nil && self.download["py"] == nil
                {
                    // 开始下载, 如果正在下载，就不运行
                    let request = URLRequest(url: URL(string: self.xmlContent["py_url"]!)!)
                    let conn = NSURLConnection(request: request, delegate: self)
                    self.download["py"] = conn
                }
            }
        }
        else if indexPath.row == 1
        {
            // sk
            if self.xmlContent["sk_md5"] != nil && UserDefaults.standard.string(forKey: "sk_md5") != self.xmlContent["sk_md5"]
            {
                if self.xmlContent["sk_url"] != nil && self.download["sk"] == nil
                {
                    // 开始下载, 如果正在下载，就不运行
                    let request = URLRequest(url: URL(string: self.xmlContent["sk_url"]!)!)
                    let conn = NSURLConnection(request: request, delegate: self)
                    self.download["sk"] = conn
                }
            }
        }
        else if indexPath.row == 2
        {
            // en
            if self.xmlContent["cn2en_md5"] != nil && UserDefaults.standard.string(forKey: "cn2en_md5") != self.xmlContent["cn2en_md5"]
            {
                if self.xmlContent["cn2en_url"] != nil && self.download["cn2en"] == nil
                {
                    // 开始下载, 如果正在下载，就不运行
                    let request = URLRequest(url: URL(string: self.xmlContent["cn2en_url"]!)!)
                    let conn = NSURLConnection(request: request, delegate: self)
                    self.download["cn2en"] = conn
                }
            }
        }
    }
    
    // 开始下载
    func connection(_ connection: NSURLConnection, didReceive response: URLResponse)
    {
        MyLog("didReceiveResponse")
        
        if connection == self.download["py"]
        {
            self.status["py"]?.text = Lang("开始下载")
            self.receivedData["py"] = NSMutableData()
        }
        else if connection == self.download["sk"]
        {
            self.status["sk"]?.text = Lang("开始下载")
            self.receivedData["sk"] = NSMutableData()
        }
        else if connection == self.download["cn2en"]
        {
            self.status["cn2en"]?.text = Lang("开始下载")
            self.receivedData["cn2en"] = NSMutableData()
        }
    }
    
    // 接收数据
    func connection(_ connection: NSURLConnection, didReceive data: Data)
    {
        MyLog("didReceiveData = \(data.count)")
        
        if connection == self.download["py"]
        {
            self.receivedData["py"]!.append(data)
            let size = self.receivedData["py"]!.length
            self.status["py"]?.text = "\(Lang("开始下载"))\(size)"
        }
        else if connection == self.download["sk"]
        {
            self.receivedData["sk"]!.append(data)
            let size = self.receivedData["sk"]!.length
            self.status["sk"]?.text = "\(Lang("开始下载"))\(size)"
        }
        else if connection == self.download["cn2en"]
        {
            self.receivedData["cn2en"]!.append(data)
            let size = self.receivedData["cn2en"]!.length
            self.status["cn2en"]?.text = "\(Lang("开始下载"))\(size)"
        }
    }
    
    // 完成，保存
    func connectionDidFinishLoading(_ connection: NSURLConnection)
    {
        MyLog("connectionDidFinishLoading")
        
        if connection == self.download["py"]
        {
            UserDefaults.standard.set(self.xmlContent["py_md5"], forKey: "py_md5")
            
            try? self.receivedData["py"]?.write(to: fileUrlFromGroup("py.data"), options: [])
            self.receivedData["py"] = nil
            self.download["py"] = nil
            self.status["py"]?.text = Lang("完成")
        }
        else if connection == self.download["sk"]
        {
            UserDefaults.standard.set(self.xmlContent["sk_md5"], forKey: "sk_md5")
            
            try? self.receivedData["sk"]?.write(to: fileUrlFromGroup("sk.data"), options: [])
            self.receivedData["sk"] = nil
            self.download["sk"] = nil
            self.status["sk"]?.text = Lang("完成")
        }
        else if connection == self.download["cn2en"]
        {
            UserDefaults.standard.set(self.xmlContent["cn2en_md5"], forKey: "cn2en_md5")
            
            try? self.receivedData["cn2en"]?.write(to: fileUrlFromGroup("cn2en.data"), options: [])
            self.receivedData["cn2en"] = nil
            self.download["cn2en"] = nil
            self.status["cn2en"]?.text = Lang("完成")
        }
    }
    
    
    override  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        if cell == nil
        {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "Cell") as UITableViewCell
            cell!.selectionStyle = UITableViewCell.SelectionStyle.default
            
            let titleLabel = UILabel()
            titleLabel.frame =  CGRect(x: cell!.frame.height / 2, y: 0, width: cell!.frame.width, height: cell!.frame.height)
            titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
            titleLabel.textColor = UIColor.black
            titleLabel.backgroundColor = UIColor.clear
            titleLabel.textAlignment = .left
            
            if (indexPath.row == 0)
            {
                titleLabel.text = Lang("拼音词库")
            }
            else if (indexPath.row == 1)
            {
                titleLabel.text = Lang("笔画词库")
            }
            else if (indexPath.row == 2)
            {
                titleLabel.text = Lang("英文单词库")
            }
            
            titleLabel.tag = 1000001
            cell!.contentView.addSubview(titleLabel)
            
            //let pyTime: String! = UserDefaults.standard.string(forKey: "pyUpdateTime")
            //let skTime: String! = UserDefaults.standard.string(forKey: "skUpdateTime")
            
            let timeLabel = UILabel()
            timeLabel.frame =  CGRect(x: cell!.frame.height / 2, y: 0, width: cell!.frame.width, height: cell!.frame.height)
            timeLabel.font = UIFont.boldSystemFont(ofSize: 12)
            timeLabel.textColor = UIColor.gray
            timeLabel.backgroundColor = UIColor.clear
            timeLabel.textAlignment = .center
            //((indexPath.row == 0) ? (pyTime == nil ? "" : pyTime) : (skTime == nil ? "" : skTime))
            
            timeLabel.tag = 1000002
            cell!.contentView.addSubview(timeLabel)
        }
        
        let statusLabel:UILabel = cell!.contentView.viewWithTag(1000002) as!  UILabel
        if (indexPath.row == 0)
        {
            // 简体拼音
            self.status["py"] = statusLabel
            if self.xmlContent["py_md5"] != nil && UserDefaults.standard.string(forKey: "py_md5") != self.xmlContent["py_md5"]
            {
                statusLabel.text = Lang("点击更新")
            }
            else
            {
                statusLabel.text = Lang("已是最新版本")
            }
        }
        else if (indexPath.row == 1)
        {
            // 笔画
            self.status["sk"] = statusLabel
            if self.xmlContent["sk_md5"] != nil && UserDefaults.standard.string(forKey: "sk_md5") != self.xmlContent["sk_md5"]
            {
                statusLabel.text = Lang("点击更新")
            }
            else
            {
                statusLabel.text = Lang("已是最新版本")
            }
        }
        else if (indexPath.row == 2)
        {
            // 笔画
            self.status["cn2en"] = statusLabel
            if self.xmlContent["cn2en_md5"] != nil && UserDefaults.standard.string(forKey: "cn2en_md5") != self.xmlContent["cn2en_md5"]
            {
                statusLabel.text = Lang("点击更新")
            }
            else
            {
                statusLabel.text = Lang("已是最新版本")
            }
        }
        
        return cell!
    }
    
    
    
}

