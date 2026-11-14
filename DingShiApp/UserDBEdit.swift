//
//  FirstViewController.swift
//  RefreshExample
//
//  Created by SunSet on 14-6-23.
//  Copyright (c) 2014 zhaokaiyuan. All rights reserved.
//

import UIKit

class UserViewController: UITableViewController
{
    var userDB: UnsafeMutableRawPointer? = nil
    var userDBLen: Int = 0
    var dataAry: [Int32] = []
    var items: [(String, String)] = []
    var inputMode: Int32 = 0;
    var cmdbar : UIView!
    var pyBtn : UIButton!
    var skBtn: UIButton!
   
    func setupRefresh()
    {
        self.tableView.addHeaderWithCallback({
            self.loadDB()
            self.tableView.reloadData()
            self.tableView.headerEndRefreshing()
        })

        self.tableView.addFooterWithCallback({
            self.loadDB()
            self.tableView.reloadData()
            self.tableView.footerEndRefreshing()
        })
    }

    private func loadDB()
    {
        self.items.removeAll()
        guard let u = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.DWIME_DS")?.appendingPathComponent("learned_words.json"),
              let d = try? Data(contentsOf: u),
              let j = try? JSONSerialization.jsonObject(with: d) as? [String: String]
        else { return }
        var list = j.map { ($0.key, $0.value) }
        if self.inputMode == IM_STROKE { list = list.filter { $0.0.contains(where: { $0.isUppercase }) } }
        else { list = list.filter { !$0.0.contains(where: { $0.isUppercase }) } }
        list.sort { $0.0 < $1.0 }
        var uniq: [(String, String)] = []
        var seenWord = Set<String>()
        for it in list
        {
            if seenWord.contains(it.1) { continue }
            seenWord.insert(it.1)
            uniq.append(it)
        }
        self.items = uniq
    }

    override func viewDidDisappear(_ animated: Bool) {
        if self.userDB != nil
        {
            free(self.userDB!)
            self.userDB = nil
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.inputMode = IM_PINYIN;
        
        self.cmdbar = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 40))
        self.pyBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        self.pyBtn.setTitle(Lang("  拼 音  "), for: .normal)
        self.pyBtn.setTitleColor(UIColor.black, for: .normal)
        self.pyBtn.setTitleColor(UIColor.blue, for: .highlighted)
        self.pyBtn.setTitleColor(UIColor.white, for: .selected)
        self.pyBtn.sizeToFit()
        self.pyBtn.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        //self.pyBtn.layer.cornerRadius = 5
        self.pyBtn.frame.origin.x = 0//self.tableView.frame.width/2 - self.pyBtn.frame.width - 10
        self.pyBtn.frame.size.width = self.tableView.frame.width / 2
        self.pyBtn.addTarget(self, action: Selector("onPY"), for: UIControl.Event.touchUpInside)
        
        self.skBtn = UIButton(frame: CGRect(x: 50, y: 0, width: 40, height: 40))
        self.skBtn.setTitle(Lang("  笔 画  "), for: .normal)
        self.skBtn.setTitleColor(UIColor.black, for: .normal)
        self.skBtn.setTitleColor(UIColor.blue, for: .highlighted)
        self.skBtn.setTitleColor(UIColor.white, for: .selected)
        self.skBtn.sizeToFit()
        self.skBtn.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        //self.skBtn.layer.cornerRadius = 5
        self.skBtn.frame.origin.x = self.tableView.frame.width/2
        self.skBtn.frame.size.width = self.tableView.frame.width / 2
        self.skBtn.addTarget(self, action: Selector("onSK"), for: UIControl.Event.touchUpInside)

        
        self.cmdbar.addSubview(self.pyBtn)
        self.cmdbar.addSubview(self.skBtn)
        self.cmdbar.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        self.cmdbar.frame.size.height = self.pyBtn.frame.height
        self.pyBtn.backgroundColor = UIColor.blue.withAlphaComponent(0.5)

        self.loadDB();
        self.navigationItem.title = Lang("user_title")
        let backItem = UIBarButtonItem(title: Lang("返回"), style: .plain, target: self, action: Selector("onBackPage"))
        self.navigationItem.setLeftBarButtonItems([backItem], animated: true)
        self.tableView.register(MyCell.self, forCellReuseIdentifier: "TableViewCellIdentifier")
        self.tableView.tableHeaderView = self.cmdbar
        self.setupRefresh()
    }
    
    @objc func onPY()
    {
        self.inputMode = IM_PINYIN
        self.loadDB()
        self.tableView.reloadData()
        self.skBtn.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        self.skBtn.isSelected = false
        self.pyBtn.backgroundColor = UIColor.blue.withAlphaComponent(0.5)
        self.pyBtn.isSelected = true
    }

    @objc func onSK()
    {
        self.inputMode = IM_STROKE
        self.loadDB()
        self.tableView.reloadData()
        self.pyBtn.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        self.pyBtn.isSelected = false
        self.skBtn.backgroundColor = UIColor.blue.withAlphaComponent(0.5)
        self.skBtn.isSelected = true
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.items.count
    }
        
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.cellForRow(at: indexPath)?.isSelected = false
    }
    
    override  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> MyCell
    {
        var cell: MyCell? = tableView.dequeueReusableCell(withIdentifier: "Cell") as? MyCell
        
        if cell == nil
        {
            cell = MyCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "Cell") as MyCell
            cell!.selectionStyle = UITableViewCell.SelectionStyle.default
            let statusLabel = UILabel()
            statusLabel.frame = CGRect(x: 20, y: 6, width: self.tableView.frame.width - 30, height: cell!.frame.height)
            statusLabel.font = UIFont.boldSystemFont(ofSize: 16)
            statusLabel.textColor = UIColor.black
            statusLabel.backgroundColor = UIColor.clear
            statusLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
            statusLabel.textAlignment = .left
            statusLabel.numberOfLines = 0
            cell!.contentView.addSubview(statusLabel)
            statusLabel.tag = 1000001
            
            let button: MyButton = MyButton()
            button.setTitle(Lang("button_delete"), for: .normal)
            button.backgroundColor = UIColor.red
            button.sizeToFit()
            button.frame.origin.x = tableView.frame.width - button.frame.width
            button.frame.size.height = cell!.frame.height
            button.center.y = cell!.center.y
            button.isHidden =  true
            button.tag = 1000011
            button.addTarget(self, action: Selector("button_highlight:"), for: UIControl.Event.touchDown)
            button.addTarget(self, action: Selector("button_unighlight:"), for: [UIControl.Event.touchUpInside, UIControl.Event.touchUpOutside, UIControl.Event.touchCancel])
            button.addTarget(self, action: Selector("delete_item:"), for: UIControl.Event.touchUpInside)
            cell!.contentView.addSubview(button)
            
            let gestureRecognizerR: UISwipeGestureRecognizer = UISwipeGestureRecognizer()
            gestureRecognizerR.direction = UISwipeGestureRecognizer.Direction.right
            gestureRecognizerR.addTarget(cell!, action: Selector("handleSwipeRight"))
            cell!.addGestureRecognizer(gestureRecognizerR)

            let gestureRecognizerL: UISwipeGestureRecognizer = UISwipeGestureRecognizer()
            gestureRecognizerL.direction = UISwipeGestureRecognizer.Direction.left
            gestureRecognizerL.addTarget(cell!, action: Selector("handleSwipeLeft"))
            cell!.addGestureRecognizer(gestureRecognizerL)
        }
        let statusLabel:UILabel = cell!.contentView.viewWithTag(1000001) as!  UILabel
        let button:MyButton = cell!.contentView.viewWithTag(1000011) as!  MyButton
        let it = self.items[indexPath.row]
        statusLabel.text = String(format: "%05d   %@", indexPath.row, it.1)
        statusLabel.sizeToFit()
        statusLabel.frame.origin.y = (cell!.frame.height - statusLabel.frame.height) / 2
        statusLabel.frame.size.width = self.tableView.frame.width - 30
        button.row = indexPath.row
        
        return cell!
    }
    
    @objc func button_highlight(sender: MyButton)
    {
        sender.backgroundColor = UIColor.blue
    }
    @objc func button_unighlight(sender: MyButton)
    {
        sender.backgroundColor = UIColor.red
    }
    
    @objc func delete_item(sender: MyButton)
    {
        if sender.row >= 0 && sender.row < self.items.count
        {
            let word = self.items[sender.row].1
            var j = [String: String]()
            if let u = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.DWIME_DS")?.appendingPathComponent("learned_words.json"),
               let d = try? Data(contentsOf: u),
               let obj = try? JSONSerialization.jsonObject(with: d) as? [String: String]
            {
                j = obj
            }
            let deadKeys = j.filter { $0.value == word }.map { $0.key }
            for k in deadKeys { j.removeValue(forKey: k) }
            if let u = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.DWIME_DS")?.appendingPathComponent("learned_words.json"),
               let d = try? JSONSerialization.data(withJSONObject: j, options: [])
            {
                try? d.write(to: u)
            }
            self.loadDB()
            self.tableView.reloadData()
            sender.isHidden = true
        }
    }
    
    func saveDB()
    {
        if self.userDB != nil
        {
            let url = fileUrlFromGroup((self.inputMode == IM_PINYIN) ? "userDB_PY.data" : "userDB_SK.data")
            let db = Data(bytes: self.userDB!, count: self.userDBLen)
            try? db.write(to: url, options: [])
        }
    }
 
    @objc func onBackPage()
    {
        if let nav = self.navigationController, nav.viewControllers.count > 1 { nav.popViewController(animated: true) }
        else { self.dismiss(animated: true, completion: nil) }
    }
}


class MyCell : UITableViewCell
{
    @objc func handleSwipeRight()
    {
        let button:MyButton = self.contentView.viewWithTag(1000011) as!  MyButton
        button.isHidden = !button.isHidden
    }

    @objc func handleSwipeLeft()
    {
        let button:MyButton = self.contentView.viewWithTag(1000011) as!  MyButton
        button.isHidden = !button.isHidden
    }
}


class MyButton: UIButton
{
    var row: Int = 0
}
