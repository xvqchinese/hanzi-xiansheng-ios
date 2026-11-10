//
//  FirstViewController.swift
//  RefreshExample
//
//  Created by SunSet on 14-6-23.
//  Copyright (c) 2014 zhaokaiyuan. All rights reserved.
//

import UIKit

class NewsViewController: UITableViewController, XMLParserDelegate
{
    var titleAry: [String]?
    var urlAry: [String]?
    var element: String = String()
    
    func setupRefresh()
    {
        self.tableView.addHeaderWithCallback({
            let url: URL? = URL(string: "http://www.xvqchinese.com/dsv2/txz/news.php?kind=ios")
            let data: Data! = try? Data(contentsOf: url!)
            if data != nil
            {
                let path = fileUrlFromGroup("news.txt")
                try? data?.write(to: path, options: [])
                
                self.load()
                self.tableView.reloadData()
            }
            self.tableView.headerEndRefreshing()
        })
    }
    
    private func load()
    {
        self.titleAry?.removeAll(keepingCapacity: false)
        self.titleAry = []
        self.urlAry?.removeAll(keepingCapacity: false)
        self.urlAry = []
        
        if loadStringFileFromGroup("news.txt") != nil
        {
            let mainPath = fileUrlFromGroup("news.txt")
            let txtData: Data! = try? Data(contentsOf: mainPath)
            //let content: NSString = String(data: txtData, encoding: String.Encoding.utf8)!
            //let dataAry = content.components(separatedBy: "#`#")
            
            let xml: XMLParser = XMLParser(data: txtData)
            xml.delegate = self
            xml.parse()

            /*
            for str1 in dataAry
            {
                let str = (str1 as NSString)
                if str.length > 0
                {
                    self.stringAry?.append(str)
                }
            }**/
        }
        NSLog("load end")
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        if elementName == "title"
        {
            self.titleAry!.append(self.element)
        }
        if elementName == "page"
        {
            self.urlAry!.append(self.element)
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String)
    {
        self.element = string
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationItem.title = Lang("news_title")
        
        self.load()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TableViewCellIdentifier")
        self.setupRefresh()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.titleAry!.count
    }
    
    var statusLabel: UILabel? = nil
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if self.statusLabel == nil
        {
            self.statusLabel = UILabel()
            self.statusLabel!.font = UIFont.boldSystemFont(ofSize: 16)
            self.statusLabel!.textColor = UIColor.black
            self.statusLabel!.backgroundColor = UIColor.clear
            self.statusLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping
            self.statusLabel!.textAlignment = .left
            self.statusLabel!.numberOfLines = 0
        }
        self.statusLabel!.frame = CGRect(x: 20, y: 6, width: self.tableView.frame.width - 30, height: 36)
        self.statusLabel!.text = self.titleAry![indexPath.row]
        self.statusLabel!.sizeToFit()
        
        return self.statusLabel!.frame.height + self.statusLabel!.font.lineHeight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.cellForRow(at: indexPath)?.isSelected = false
        
        let url = self.urlAry![indexPath.row]
        self.navigationController?.pushViewController(CommonWebView(url: url, title:Lang("新闻"), scalesPage: true), animated: true)
    }
    
    override  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        if cell == nil
        {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "Cell") as UITableViewCell
            cell!.selectionStyle = UITableViewCell.SelectionStyle.default
            let statusLabel = UILabel()
            statusLabel.frame = CGRect(x: 20, y: 6, width: self.tableView.frame.width - 30, height: 36)
            statusLabel.font = UIFont.boldSystemFont(ofSize: 16)
            statusLabel.textColor = UIColor.black
            statusLabel.backgroundColor = UIColor.clear
            statusLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
            statusLabel.textAlignment = .left
            statusLabel.numberOfLines = 0
            cell!.contentView.addSubview(statusLabel)
            statusLabel.tag = 1000001
        }
        let statusLabel:UILabel = cell!.contentView.viewWithTag(1000001) as!  UILabel
        statusLabel.text = self.titleAry![indexPath.row]
        statusLabel.sizeToFit()
        
        return cell!
    }
}

