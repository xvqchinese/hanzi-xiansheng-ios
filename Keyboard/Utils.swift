//
//  Utils.swift
//  TastyImitationKeyboard
//
//  Created by mac on 14-11-12.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

var logUrl: NSURL? = nil
var logTxt: String! = nil

func MyLog(_ format: String)
{
    if false
    {
        if logTxt == nil
        {
            logTxt = "\(format)<br>\n"
        }
        else
        {
            logTxt = logTxt! + "\(format)<br>\n"
        }
    
        // 写入文件
        if logUrl == nil
        {
            logUrl = fileUrlFromGroup("eLog.txt")
        }
        
        if logUrl != nil
        {
            do {
                try logTxt!.write(to: logUrl! as URL, atomically: false, encoding: String.Encoding.utf8)
            } catch _ {
            }
        }
    }

    NSLog(format)
}

var ___time: [TimeInterval] = [];

func RunTimeBegin()
{
    let time: Date = Date(timeIntervalSinceNow: 0)
    
    ___time.append(time.timeIntervalSince1970)
}

func RunTimeEnd(_ str: String)
{
    let time: Date = Date(timeIntervalSinceNow: 0)

    MyLog("\(str) ->> \(time.timeIntervalSince1970 - ___time.removeLast())")
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


func fileUrlFromGroup(_ file: String) -> NSURL
{
    let fm: FileManager = FileManager.default
    var base: URL
    if let c = fm.containerURL(forSecurityApplicationGroupIdentifier: "group.DWIME_DS") {
        base = c
    } else if let d = fm.urls(for: .documentDirectory, in: .userDomainMask).first {
        base = d
    } else {
        base = URL(fileURLWithPath: NSHomeDirectory())
    }
    let fileURL = base.appendingPathComponent(file)
    MyLog("fileURL = \(fileURL)")
    return fileURL as NSURL
}

func loadStringFileFromGroup(_ file: String) -> NSString?
{
    let fileURL = fileUrlFromGroup(file)
    
    return try? String(contentsOf: fileURL as URL, encoding: String.Encoding.utf8) as NSString
}


func delFileFromGroup(_ file: String)
{
    let fileURL = fileUrlFromGroup(file)
    
    let fm: FileManager = FileManager.default
    do {
        try fm.removeItem(at: fileURL as URL)
    } catch _ {
    }
}


func accessOpen_check() ->Bool
{
    let url = fileUrlFromGroup("accessOpen_check")
    let test = "accessOpen_check"
    
    do {
        try test.write(to: url as URL, atomically: true, encoding: .utf8)
        return true
    } catch _ {
    }
    
    return false
}


func hex2dec(_ num:String) -> Int
{
    let str = num.uppercased()
    var sum = 0
    for i in str.utf8 {
        sum = sum * 16 + Int(i) - 48 // 0-9 从48开始
        if i >= 65 {                 // A-Z 从65开始，但有初始值10，所以应该是减去55
            sum -= 7
        }
    }
    return sum
}


/****
 *  字符串转成 uicolor, str 必须是 10 个长度的字符串如：0xff998877
 ***/
func string2Color(_ str: String) -> UIColor
{
    let hex = str.lowercased() as NSString
    
    let a = hex.substring(with: NSRange(location: 2, length: 2))
    let r = hex.substring(with: NSRange(location: 4, length: 2))
    let g = hex.substring(with: NSRange(location: 6, length: 2))
    let b = hex.substring(with: NSRange(location: 8, length: 2))
    
    return UIColor(red: CGFloat(hex2dec(r))/255, green: CGFloat(hex2dec(g))/255, blue: CGFloat(hex2dec(b))/255, alpha: CGFloat(hex2dec(a))/255)
}


func getOrientation() -> UIInterfaceOrientation
{
    let h = UIScreen.main.bounds.height
    let w = UIScreen.main.bounds.width
    if (h > w)
    {
        return UIInterfaceOrientation.portrait
    }
    return UIInterfaceOrientation.landscapeLeft
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


var audioPlayer = AVAudioPlayer()
func playWav(_ tune: String)
{
    //if tune != nil
    //{
        let soundURL = fileUrlFromGroup("temp.wav")
        let size = WavEngine.wavCreate(byPys: tune, soundURL as URL)
    
        if size > 0
        {
            do {
                try audioPlayer = AVAudioPlayer(contentsOf: soundURL as URL)
                audioPlayer.prepareToPlay()
                audioPlayer.play()
            } catch _ {
            }
        }
    //}
    
        /**
        var mySound: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(soundURL, &mySound)
        // Play
        AudioServicesPlaySystemSound(mySound);**/

        /*
        let play = AVAudioPlayer(contentsOf: soundURL as URL)

        play.prepareToPlay()
        play.play()**/
}

func escape(_ string: String) -> String
{
    return string.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: ":&=;+!@#$()',*").inverted) ?? string
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


func createMyButton(_ title: String) -> UIButton
{
    let btn: UIButton = UIButton();
    let img = imageWithColor(KeyboardColor.mButtonBColor_hi, width: 1, height: 1);
    
    btn.setTitle(title, for: .normal)
    btn.setTitleColor(KeyboardColor.mButtonTxtColor, for: .normal)
    btn.setTitleColor(KeyboardColor.mButtonTxtColor_hi, for: .highlighted)
    btn.setTitleColor(KeyboardColor.mButtonTxtColor_hi, for: .selected)
    btn.sizeToFit()
    btn.backgroundColor = KeyboardColor.mButtonBColor
    btn.setBackgroundImage(img, for: .selected)
    btn.setBackgroundImage(img, for: .highlighted)
    btn.layer.cornerRadius = 5.0
    
    return btn
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


func openURL(_ obj: UIResponder, url: NSURL) -> Bool
{
    do
    {
        let application = try sharedApplication(obj)
        return application.perform(Selector(("openURL:")), with: url) != nil
    }
    catch
    {
        return false
    }
}

func sharedApplication(_ obj: UIResponder) throws -> UIApplication
{
    var responder: UIResponder? = obj
    while responder != nil
    {
        if let application = responder as? UIApplication
        {
            return application
        }
        responder = responder?.next
    }
    throw NSError(domain: "UIInputViewController+sharedApplication.swift", code: 1, userInfo: nil)
}




/*

func resFileExists(_ file: String) -> Bool
{
    let path = resFilePath(file)
    var fm: FileManager = FileManager.default
    
    if fm.fileExistsAtPath(path)
    {
        return true
    }
    return false
}


func docFileExists(_ file: String) -> Bool
{
    let path = docFilePath(file)
    var fm: FileManager = FileManager.default
    if fm.fileExistsAtPath(path)
    {
        return true
    }
    return false
}


func copyResFileToDoc(_ file: String)
{
    let srcPath = resFilePath(file)
    let toPath = docFilePath(file)

    var fm: FileManager = FileManager.default
    fm.copyItemAtPath(srcPath, toPath: toPath, error: nil)
}


func resFilePath(_ file: String) -> NSString
{
    let mb = Bundle.main
    let srcPath = mb.resourcePath?.appendingPathComponent(file)

    return srcPath!
}

func docFilePath(_ file: String) -> NSString
{
    let homeDir = NSHomeDirectory()
    let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
    let toPath: NSString = "\(paths[0])/\(file)"
    
    return toPath
}
**/


