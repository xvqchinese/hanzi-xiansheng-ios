//
//  FirstViewController.swift
//  RefreshExample
//
//  Created by SunSet on 14-6-23.
//  Copyright (c) 2014 zhaokaiyuan. All rights reserved.
//

import UIKit

class PhrsViewController: UITableViewController
{
    var stringAry: [String]?
    //var labelAry: [UILabel]?
    
    func setupRefresh()
    {
          self.tableView.addHeaderWithCallback({
            let url: URL? = URL(string: "http://www.xvqchinese.com/dsv2/txz/phrases.php?kind=\(self.getKind())")
            let data: Data! = try? Data(contentsOf: url!)
            if data != nil
            {
                //let mb = Bundle.main
                //let path = mb.resourcePath?.appendingPathComponent("Plugins/Keyboard.appex/\(self.getKind()).txt")
                let path = fileUrlFromGroup("\(self.getKind()).txt")
                try? data?.write(to: path, options: [])

                self.load(kind: self.getKind())
                self.tableView.reloadData()
                //self.reload = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: Selector("reloadTimer"), userInfo: nil, repeats: false)
            }
            self.tableView.headerEndRefreshing()
        })
    }
    
    private func load(kind: String)
    {
        self.stringAry?.removeAll(keepingCapacity: false)
        self.stringAry = []
        
        if loadStringFileFromGroup("\(kind).txt") == nil
        {
            return
        }
        
        let mainPath = fileUrlFromGroup("\(kind).txt")
        let txtData: Data! = try? Data(contentsOf: mainPath)
        let content: NSString = String(data: txtData, encoding: String.Encoding.utf8)! as NSString
        
        let dataAry = content.components(separatedBy: "#`#")
        
        for str1 in dataAry
        {
            let str = (str1 as NSString)
            if str.length > 0
            {
                self.stringAry?.append(str as String)
            }
        }
    }
    
    func getKind() -> String
    {
        return "daily"
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationItem.title = Lang("phrs_title")

        self.load(kind: self.getKind())
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TableViewCellIdentifier")
        self.setupRefresh()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.stringAry!.count
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
        self.statusLabel!.text = self.stringAry![indexPath.row]
        self.statusLabel!.sizeToFit()
        
        return self.statusLabel!.frame.height + self.statusLabel!.font.lineHeight
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.cellForRow(at: indexPath)?.isSelected = false
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
        statusLabel.text = self.stringAry![indexPath.row]
        statusLabel.sizeToFit()
        //statusLabel.frame.origin.y = (cell!.frame.height - statusLabel.frame.height) / 2
        
        return cell!
    }
    
    
    
}

