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
        // 把整词重复两次的值（丁树雄丁树雄）折回一个
        uniq = uniq.map { ($0.0, { (v: String) -> String in
            let n = v.count
            if n % 2 == 0, n >= 4 { let h = String(v.prefix(n/2)); if h + h == v { return h } }
            return v
        }($0.1)) }

        // 清掉“是更长词条前缀”的半截词（如 丁树 / 丁树雄 同时存在时只留长的）
        let words = Set(uniq.map { $0.1 })
        uniq = uniq.filter { it in
            !words.contains { other in other.count > it.1.count && other.hasPrefix(it.1) }
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

        if let m = UserDefaults.standard.string(forKey: "dbgDelStep"), !m.hasPrefix("E-")
        {
            let al = UIAlertController(title: "上次删除停在", message: m, preferredStyle: .alert)
            al.addAction(UIAlertAction(title: "知道了", style: .default))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.present(al, animated: true) }
        }
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
        tableView.deselectRow(at: indexPath, animated: false)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> MyCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? MyCell
        if cell == nil
        {
            cell = MyCell(style: .default, reuseIdentifier: "Cell")
            let statusLabel = UILabel()
            statusLabel.tag = 1000001
            statusLabel.font = UIFont.boldSystemFont(ofSize: 16)
            statusLabel.textColor = UIColor.black
            statusLabel.backgroundColor = UIColor.clear
            statusLabel.lineBreakMode = .byWordWrapping
            statusLabel.textAlignment = .left
            statusLabel.numberOfLines = 0
            cell!.contentView.addSubview(statusLabel)
        }
        guard let statusLabel = cell!.contentView.viewWithTag(1000001) as? UILabel else { return cell! }
        guard indexPath.row >= 0, indexPath.row < self.items.count else { return cell! }
        let it = self.items[indexPath.row]
        statusLabel.text = String(format: "%05d   %@", indexPath.row, it.1 as NSString)
        statusLabel.frame = CGRect(x: 20, y: 6, width: tableView.frame.width - 30, height: max(24, cell!.frame.height - 12))
        return cell!
    }

    // 用系统自带的左滑删除，替掉自绘手势＋红色按钮（那条路是闪崩的来源）
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        guard indexPath.row >= 0, indexPath.row < self.items.count else { return nil }
        let word = self.items[indexPath.row].1
        let act = UIContextualAction(style: .destructive, title: Lang("button_delete")) { [weak self] _, _, done in
            guard let self = self else { done(false); return }
            self.removeWord(word)
            done(true)
        }
        act.backgroundColor = UIColor.red
        return UISwipeActionsConfiguration(actions: [act])
    }

    func removeWord(_ word: String)
    {
        if let row = self.items.firstIndex(where: { $0.1 == word })
        {
            self.items.remove(at: row)
            self.tableView.reloadData()
        }
        let g = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.DWIME_DS")
        if let u = g?.appendingPathComponent("learned_words.json"),
           let d = try? Data(contentsOf: u),
           let obj = try? JSONSerialization.jsonObject(with: d) as? [String: String]
        {
            var j = obj
            for k in j.filter({ $0.value == word }).map({ $0.key }) { j.removeValue(forKey: k) }
            if let nd = try? JSONSerialization.data(withJSONObject: j, options: []) { try? nd.write(to: u) }
        }
        if let u2 = g?.appendingPathComponent("user_word_ini.json"),
           let d2 = try? Data(contentsOf: u2),
           let obj2 = try? JSONSerialization.jsonObject(with: d2) as? [String: String]
        {
            var j2 = obj2
            for k in j2.filter({ $0.value == word }).map({ $0.key }) { j2.removeValue(forKey: k) }
            if let nd = try? JSONSerialization.data(withJSONObject: j2, options: []) { try? nd.write(to: u2) }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.loadDB()
            self?.tableView.reloadData()
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
        guard let button = self.contentView.viewWithTag(1000011) as? MyButton else { return }
        button.isHidden = !button.isHidden
    }

    @objc func handleSwipeLeft()
    {
        guard let button = self.contentView.viewWithTag(1000011) as? MyButton else { return }
        button.isHidden = !button.isHidden
    }
}


class MyButton: UIButton
{
    var row: Int = 0
}
