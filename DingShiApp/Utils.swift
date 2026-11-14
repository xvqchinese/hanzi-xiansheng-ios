//
//  Utils.swift
//  TastyImitationKeyboard
//
//  Created by mac on 14-11-12.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

import Foundation

func MyLog(_ format: String)
{
    
    NSLog(format)
}

var ___time: TimeInterval = 0;

func RunTimeBegin()
{
    let time: Date = Date(timeIntervalSinceNow: 0)
    
    ___time = time.timeIntervalSince1970
}

func RunTimeEnd(_ str: String)
{
    let time: Date = Date(timeIntervalSinceNow: 0)

    NSLog("\(str) ->> \(time.timeIntervalSince1970 - ___time)")
}



func Lang(_ key: String) -> String
{
    return NSLocalizedString(key, comment: "")
}

func getSysTicks() -> TimeInterval
{
    let time: Date = Date(timeIntervalSinceNow: 0)
    
    return time.timeIntervalSince1970
}

func fileUrlFromGroup(_ file: String) -> URL
{
    let fm: FileManager = FileManager.default
    let containerURL = fm.containerURL(forSecurityApplicationGroupIdentifier: "group.DWIME_DS")
    let fileURL = (containerURL ?? fm.urls(for: .documentDirectory, in: .userDomainMask).first!).appendingPathComponent(file)

    return fileURL
}

func loadStringFileFromGroup(_ file: String) -> NSString?
{
    let fileURL = fileUrlFromGroup(file)
    
    return (try? String(contentsOf: fileURL, encoding: String.Encoding.utf8)).map { $0 as NSString }
}


func getGlobalPrefs() -> UserDefaults
{
    let gprefs : UserDefaults = UserDefaults(suiteName: "group.DWIME_DS") ?? UserDefaults.standard
    
    // 默认值
    //{
    gprefs.register(defaults: [
        "kbheight" : 1.1,           // 键盘高度
        "cnOutConv"  : 0,
        "enOutConv" : 0,
        "hwBrush" : true,
        "hwTimeOut" : 800,
        "pyStyle":0,        // 0 ds, 1 标准
        ])
    //}
    
    return gprefs
}



func getStringListByTxt(_ file: String) -> [String]?
{
    // 没有，先复制到共享内存
    let mb = Bundle.main
    let orgPath = (mb.resourcePath! as NSString).appendingPathComponent("\(file).txt")
    
    if let orgTxt = try? String(contentsOfFile: orgPath, encoding: String.Encoding.utf8)
    {
        return orgTxt.components(separatedBy: "\r\n")
    }
    
    return nil
}


func imageWithColor(_ color: UIColor, width: CGFloat, height: CGFloat) -> UIImage
{
    let rect = CGRect(x: 0, y: 0, width: width, height: height)
    
    UIGraphicsBeginImageContext(rect.size)
    let context = UIGraphicsGetCurrentContext()!
    context.setFillColor(color.cgColor)
    context.fill(rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return image!
}



func loadColorIcon(_ name: String, color:UIColor) -> UIImage?
{
    let img = UIImage(named: name)
    
    if (color.cgColor).alpha == 0
    {
        return img
    }
    
    return img?.rt_tintedImage(with: color)
}

func escape(_ string: String) -> String
{
    return string.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: ":&=;+!@#$()',*").inverted) ?? string
}


func md5String(_ str:String) -> String
{
    let cStr = (str as NSString).utf8String
    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
    CC_MD5(cStr!, (CC_LONG)(strlen(cStr!)), buffer)
    let md5String = NSMutableString()
    for i in 0..<16
    {
        md5String.appendFormat("%02x", buffer[i])
    }
    buffer.deallocate()
    return md5String as String
}


var audioPlayer = AVAudioPlayer()
func playWav(_ tune: String)
{
    // 确保 App 内也能出声（键盘扩展里已设置过）
    do {
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.duckOthers, .mixWithOthers])
        try AVAudioSession.sharedInstance().setActive(true)
    } catch _ {
    }
    let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.DWIME_DS")
    let soundURL = (groupURL ?? URL(fileURLWithPath: NSTemporaryDirectory())).appendingPathComponent("temp.wav")
    let size = WavEngine.wavCreate(byPys: tune, soundURL)
    
    if size > 0
    {
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: soundURL)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch _ {
        }
    }
}


// 读数据文件到内存
func loadDBToMem(_ fileName:String) -> UnsafeMutableRawPointer?
{
    let db = try? Data(contentsOf: fileUrlFromGroup(fileName))
    if db != nil
    {
        let userDB = malloc(Int(db!.count))
        if userDB != nil
        {
            memmove(userDB, (db! as NSData).bytes, Int(db!.count))
            return userDB
        }
    }
    
    return nil
}
