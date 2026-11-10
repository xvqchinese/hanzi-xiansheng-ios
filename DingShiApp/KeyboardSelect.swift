//
//  RootView.swift
//  RefreshExample
//
//  Created by SunSet on 14-6-24.
//  Copyright (c) 2014年 zhaokaiyuan. All rights reserved.
//

import UIKit

class KeyboardSelect: UITableViewController, UIAlertViewDelegate {
    
    let titles = [
        ["0", "拼音全键盘"],
        ["1", "拼音九宫格"],
        ["2", "五笔画（手机笔画）"],
        ["3", "手写（中文）"],
        ["4", "五笔字形（86版）"],
        ["5", "仓颉（港澳台）"],
        ["6", "注音（港澳台）"]
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TableViewCellIdentifier")
        
        self.navigationItem.title = Lang("kbselect_title")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.titles.count
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.isSelected = false
        
        switch(cell!.tag)
        {
        case 0:
            break
            
        default:
            break
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil
        {
            // no value
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "Cell") as UITableViewCell
            cell!.selectionStyle = UITableViewCell.SelectionStyle.default
            let label = UILabel()
            label.frame = CGRect(x: cell!.frame.height / 2, y: 0, width: 320, height: cell!.frame.height)
            label.font = UIFont.boldSystemFont(ofSize: 16)
            label.textColor = UIColor.black
            label.backgroundColor = UIColor.clear
            label.textAlignment = .left
            label.isUserInteractionEnabled = false
            label.text = self.titles[indexPath.row][1]
            
            cell!.tag = Int(self.titles[indexPath.row][0])!
            cell!.contentView.addSubview(label)
        }
        
        return cell!
    }
    
    
    
}