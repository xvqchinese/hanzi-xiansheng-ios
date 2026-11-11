//
//  EngineService.swift
//  TastyImitationKeyboard
//
//  Created by mac on 14-10-20.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

import Foundation

struct IDouble
{
    static let piNYIN: Int32 = 0x01
}

struct EST
{
    static let KBT_DIGIT: Int32 = 0x01
    static let KBT_QWERTY: Int32 = 0x02
    static let KBT_COUNT: Int32 = 0x03
    
    
    static let SPKT_Down: Int32 = 0x0000
    static let SPKT_Up:   Int32 = 0x0001
    static let SPKT_Swypeing: Int32 = 0x0002
    static let SPKT_Stop: Int32 = 0x0003
    static let SPKT_LongPress: Int32 = 0x0004
    
    static let SL_Chinese: Int32 = 0x0008
    static let SL_English: Int32 = 13
    
    static let IM_STROKE : Int32 = 0x02
    static let IM_LATIN : Int32 = 0x05
    static let IM_CHAR : Int32 = 0x06
    static let IM_DIGITAL : Int32 = 0x07
    
    // 以下是按键定义
    static let SPKEY_NULL: Int32				= 0
    static let SPKEY_Sharp: Int32				= 35    //'#'      /* 0x23 */
    static let SPKEY_SEPARATOR: Int32          = 39    //'\''     /* 0x27 */
    static let SPKEY_Star: Int32				= 42    //'*'		/* 0x2A */
    static let SPKEY_Dot: Int32                = 46    //'.'      /* 0x2E */
    static let SPKEY_Cross: Int32              = 45    //'-'      /* 0x2d */
    static let SPKEY_0: Int32					= 48    //'0'      /* 0x30 */
    static let SPKEY_1: Int32					= 49    //'1'      /* 0x31 */
    static let SPKEY_2: Int32					= 50    //'2'      /* 0x32 */
    static let SPKEY_3: Int32					= 51    //'3'      /* 0x33 */
    static let SPKEY_4: Int32					= 52    //'4'      /* 0x34 */
    static let SPKEY_5: Int32					= 53    //'5'	    /* 0x35 */
    static let SPKEY_6: Int32					= 54    //'6'	    /* 0x36 */
    static let SPKEY_7: Int32					= 55    //'7'      /* 0x37 */
    static let SPKEY_8: Int32					= 56    //'8'      /* 0x38 */
    static let SPKEY_9: Int32					= 57    //'9'      /* 0x39 */
    static let SPKEY_WILDCHAR: Int32           = 63    //'?'      /* 0x3F */
    static let SPKEY_AT: Int32					= 64    //'@'      /* 0x40 */
    static let SPKEY_A: Int32                  = 97    //'a'      /* 0x61 */
    static let SPKEY_B: Int32                  = 98    //'b'      /* 0x62 */
    static let SPKEY_C: Int32                  = 99    //'c'      /* 0x63 */
    static let SPKEY_D: Int32                  = 100   //'d',      /* 0x64 */
    static let SPKEY_E: Int32                  = 101   //'e',      /* 0x65 */
    static let SPKEY_F: Int32                  = 102   //'f',      /* 0x66 */
    static let SPKEY_G: Int32                  = 103   //'g',      /* 0x67 */
    static let SPKEY_H: Int32                  = 104   //'h',      /* 0x68 */
    static let SPKEY_I: Int32                  = 105   //'i',      /* 0x69 */
    static let SPKEY_J: Int32                  = 106   //'j',      /* 0x6A */
    static let SPKEY_K: Int32                  = 107   //'k',      /* 0x6B */
    static let SPKEY_L: Int32                  = 108   //'l',      /* 0x6C */
    static let SPKEY_M: Int32                  = 109   //'m',      /* 0x6D */
    static let SPKEY_N: Int32                  = 110   //'n',      /* 0x6E */
    static let SPKEY_O: Int32                  = 111   //'o',      /* 0x6F */
    static let SPKEY_P: Int32                  = 112   //'p',      /* 0x70 */
    static let SPKEY_Q: Int32                  = 113   //'q',      /* 0x71 */
    static let SPKEY_R: Int32                  = 114   //'r',      /* 0x72 */
    static let SPKEY_S: Int32                  = 115   //'s',      /* 0x73 */
    static let SPKEY_T: Int32                  = 116   //'t',      /* 0x74 */
    static let SPKEY_U: Int32                  = 117   //'u',      /* 0x75 */
    static let SPKEY_V: Int32                  = 118   //'v',      /* 0x76 */
    static let SPKEY_W: Int32                  = 119   //'w',      /* 0x77 */
    static let SPKEY_X: Int32                  = 120   //'x',      /* 0x78 */
    static let SPKEY_Y: Int32                  = 121   //'y',      /* 0x79 */
    static let SPKEY_Z: Int32                  = 122   //'z',      /* 0x7A */
    static let SPKEY_UA: Int32                 = 65    //'A'
    static let SPKEY_UB: Int32                 = 66    //'B'
    static let SPKEY_UC: Int32                 = 67    //'C'
    static let SPKEY_UD: Int32                 = 68    //'D'
    static let SPKEY_UE: Int32                 = 69    //'E'
    static let SPKEY_UF: Int32                 = 70    //'F'
    static let SPKEY_UG: Int32                 = 71    //'G'
    static let SPKEY_UH: Int32                 = 72    //'H'
    static let SPKEY_UI: Int32                 = 73    //'I'
    static let SPKEY_UJ: Int32                 = 74    //'J'
    static let SPKEY_UK: Int32                 = 75    //'K'
    static let SPKEY_UL: Int32                 = 76    //'L'
    static let SPKEY_UM: Int32                 = 77    //'M'
    static let SPKEY_UN: Int32                 = 78    //'N'
    static let SPKEY_UO: Int32                 = 79    //'O'
    static let SPKEY_UP: Int32                 = 80    //'P'
    static let SPKEY_UQ: Int32                 = 81    //'Q'
    static let SPKEY_UR: Int32                 = 82    //'R'
    static let SPKEY_US: Int32                 = 83    //'S'
    static let SPKEY_UT: Int32                 = 84    //'T'
    static let SPKEY_UU: Int32                 = 85    //'U'
    static let SPKEY_UV: Int32                 = 86    //'V'
    static let SPKEY_UW: Int32                 = 87    //'W'
    static let SPKEY_UX: Int32                 = 88    //'X'
    static let SPKEY_UY: Int32                 = 89    //'Y'
    static let SPKEY_UZ: Int32                 = 90    //'Z'
    /* function key */
    static let SPKEY_FUNC_NULL: Int32           = 0x80
    static let SPKEY_Left: Int32                = 0x81
    static let SPKEY_Right: Int32               = 0x82
    static let SPKEY_Up: Int32                  = 0x83
    static let SPKEY_Down: Int32                = 0x84
    static let SPKEY_OK: Int32                  = 0x85
    static let SPKEY_Back: Int32                = 0x86
    static let SPKEY_Return: Int32              = 0x87
    /* api key */
    static let SPKEY_API_NULL: Int32            = 0x90
    static let SPKEY_API_SHORTCUTS: Int32       = 0x91
    static let SPKEY_API_SWITCH_LT_LOWUP: Int32 = 0x92
    static let SPKEY_API_RESET: Int32           = 0x93
    static let SPKEY_API_SYLLABLE: Int32		= 0x94
    static let SPKEY_API_ASSOCIATE: Int32       = 0x95
    static let SPKEY_API_AUTOCOMMIT: Int32      = 0x96
    
    static let SMR_OK:Int32                     = 0x00
    static let SMR_Ignored:Int32                = 0x01
    
}

func Page2KbType(_ page: Int) -> Int32
{
    switch(page)
    {
    case KbPage.M_SK9, KbPage.M_En9:
        return EST.KBT_DIGIT;

    case KbPage.M_Chn:
        return EST.KBT_QWERTY;
    default:
        return EST.KBT_QWERTY;
    }
}

func Page2Mode(_ page: Int) -> Int32
{
    switch(page)
    {
    case KbPage.M_HW, KbPage.M_Chn:
        return IDouble.piNYIN
        
    case KbPage.M_SK9:
        return EST.IM_STROKE

    case KbPage.M_En26, KbPage.M_En9:
        return EST.IM_LATIN
    default:
        return EST.IM_CHAR
    }
}

func Page2DataFile(_ page: Int) -> String
{
    switch(page)
    {
    case KbPage.M_Chn:
        return "py.data"
        
    case KbPage.M_SK9:
        return "sk.data"
    
    case KbPage.M_En9, KbPage.M_En26:
        return "en.data"

    default:
        return ""
    }
}


class EngineService
{
    var mMode: Int32
    var mKbType: Int32
    var mDbMain: Data?
    var mDbUser: NSData?
    var mUserPtr: UnsafeMutableRawPointer?
    var lastInitCode: Int32 = -1     // dwimeInit 原始返回码
    var lastDbLen: Int = 0           // 实际吃到的词库字节数
    var isReady: Bool = false        // 初始化成功才允许按键
    
    init()
    {
        self.mMode = -1
        self.mKbType = -1
    }
    
    // 加载数据库
    private func loadDB(_ file:String) -> Data?
    {
        if file.count > 0
        {
            // 1) 优先读共享容器里的在线词库，但必须校验完整性（0 字节/残缺文件会让引擎索引表为空）
            let mainPath = fileUrlFromGroup(file)
            if let dbData = try? Data(contentsOf: mainPath as URL), dbData.count > 1024
            {
                MyLog("[DB] group \(file) = \(dbData.count) bytes")
                return dbData
            }
            else if let bad = try? Data(contentsOf: mainPath as URL)
            {
                MyLog("[DB] group \(file) 无效，长度=\(bad.count)，改用内置词库")
            }

            // 2) 回退到 App 内置词库（一定完整）
            let mb = Bundle.main
            let innerPath = (mb.resourcePath! as NSString).appendingPathComponent(file)
            guard let dbMain = try? Data(contentsOf: URL(fileURLWithPath: innerPath), options: .mappedIfSafe), dbMain.count > 1024
            else
            {
                MyLog("[DB] 内置词库 \(file) 读取失败")
                return nil
            }
            MyLog("[DB] bundle \(file) = \(dbMain.count) bytes")
            return dbMain
        }
        return nil
    }
    
    func InitIM(_ page: Int) -> Bool
    {
        var ret: Bool = false
        self.mMode = Page2Mode(page)
        self.mKbType = Page2KbType(page)

        IMEngine.dwimeExit()
        
        if IsNeedEngine(page)
        {
            if IsEnglishKB(page)
            {
                var dbMain: Data! = self.loadDB(Page2DataFile(page))
                self.lastInitCode = IMEngine.dwimeInit((dbMain as NSData).bytes, Int32(dbMain.count), nil, 0, nil, 0, Page2KbType(page), Page2Mode(page), EST.SL_English);
                ret = (self.lastInitCode == EST.SMR_OK)
                self.mDbMain = dbMain
            }
            else if page == KbPage.M_HW
            {
                IMEngine.dwhwInit(nil)
                // 联想初始化，用拼音的数据
                var dbMain: Data! = self.loadDB(Page2DataFile(KbPage.M_Chn))
                var dbUser: NSData? = self.loadUserDB().map { $0 as NSData }
                self.lastInitCode = IMEngine.dwimeInit((dbMain as NSData).bytes, Int32(dbMain.count),
                                    nil, 0,
                                    dbUser != nil ? (dbUser! as NSData).bytes : nil,
                                    dbUser != nil ? Int32(dbUser!.count) : 0, EST.KBT_QWERTY, IDouble.piNYIN, EST.SL_Chinese);
                ret = (self.lastInitCode == EST.SMR_OK)
                self.mDbMain = dbMain
                self.mDbUser = dbUser
            }
            else
            {
                // py, wb, sk ...
                guard let dbMainCheck = self.loadDB(Page2DataFile(page)), dbMainCheck.count > 1024 else { MyLog("[INIT] 词库不可用，跳过引擎"); return false }
                var dbMain: Data! = dbMainCheck
                var dbUser: NSData? = self.loadUserDB().map { $0 as NSData }
                self.lastInitCode = IMEngine.dwimeInit((dbMain as NSData).bytes, Int32(dbMain.count),
                                    nil, 0,
                                    dbUser != nil ? (dbUser! as NSData).bytes : nil,
                                    dbUser != nil ? Int32(dbUser!.count) : 0, Page2KbType(page), self.mMode, EST.SL_Chinese);
                ret = (self.lastInitCode == EST.SMR_OK)
	            self.mDbMain = dbMain
                self.mDbUser = dbUser
            }
            self.isReady = ret
            self.lastDbLen = self.mDbMain?.count ?? 0
            MyLog("[INIT] page=\(page) mode=\(self.mMode) code=\(self.lastInitCode) ret=\(ret) len=\(self.lastDbLen)")
            MyLog("[INIT2] count=\(IMEngine.dwimeCount())")

            if ret
            {
                IMEngine.dwimeProcessKey(EST.SPKEY_API_AUTOCOMMIT, EST.SPKT_Down, 0)
                IMEngine.dwimeProcessKey(EST.SPKEY_API_SHORTCUTS, EST.SPKT_Down, 0)
            }
        }

        return ret
    }
    
    func End()
    {
        IMEngine.dwimeExit()
    }
    
    func Reset()
    {
        IMEngine.dwimeReset()
    }
    
    private func loadUserDB() -> Data?
    {
        var file : NSURL! = nil
        if self.mMode == IDouble.piNYIN
        {
            file = fileUrlFromGroup("userDB_PY.data")
        }
        else if (self.mMode == EST.IM_STROKE)
        {
            file = fileUrlFromGroup("userDB_SK.data")
        }
        else
        {
            return nil
        }

        if let data = try? Data(contentsOf: file as URL), data.count > 0
        {
            return data
        }

        // 没有则先创建：必须在 DWIMEInit 之前调用，否则 PrepareUserDB 返回 0
        let dbSize = Int(IMEngine.dwimePrepareUserDB(self.mMode))
        if dbSize <= 0
        {
            MyLog("[USERDB] PrepareUserDB 返回 0, mode=\(self.mMode)")
            return nil
        }
        guard let dbNew = malloc(dbSize) else { return nil }
        IMEngine.dwimeCreateUserDB(self.mMode, dbNew)
        let newData = Data(bytes: dbNew, count: dbSize)
        try? newData.write(to: file as URL, options: [])
        free(dbNew)
        return newData
    }
    
    private func saveUserDB()
    {
        if Globals.accessOpen
        {
            var file : NSURL!;
            if self.mMode == IDouble.piNYIN
            {
                file = fileUrlFromGroup("userDB_PY.data")
            }
            else if (self.mMode == EST.IM_STROKE)
            {
                file = fileUrlFromGroup("userDB_SK.data")
            }
            else
            {
                return
            }
            let dbSize = Int(IMEngine.dwimePrepareUserDB(self.mMode))
            if dbSize <= 0 { return }
            guard let dbNew = malloc(dbSize) else { return }
            IMEngine.dwimeCopyUserDB(dbNew)
            let newData = Data(bytes: dbNew, count: dbSize)
            try? newData.write(to: file as URL, options: [])
            free(dbNew)
        }
    }
    
    

    func SendKey(_ key: Int32, param: Int32) ->Int32
    {
        if !self.isReady { MyLog("[KEY] 引擎未就绪，忽略按键"); return EST.SMR_Ignored }
        if self.mMode == IDouble.piNYIN ||
           self.mMode == EST.IM_STROKE ||
           self.mMode == EST.IM_LATIN
        {
            return IMEngine.dwimeProcessKey(key, EST.SPKT_Down, param)
        }

        return EST.SMR_Ignored;
    }
    
    func SendKeys(_ keys: [Int16], param: Int32) -> Int32
    {
        if !self.isReady { return EST.SMR_Ignored }
        if self.mMode == IDouble.piNYIN ||
            self.mMode == EST.IM_STROKE ||
            self.mMode == EST.IM_LATIN
        {
            return IMEngine.dwimeProcessKeys(keys, Int32(keys.count), param)
        }
        
        return EST.SMR_Ignored;
    }
    
    
    func SendKey(_ key: Key, uppercase: Bool, isSwipeDown:Bool) -> Bool
    {
        if key.type == Key.KeyType.Separate
        {
            // 分隔符
            let inputStr : NSString = self.inputStr()
            if (self.hasInput() && inputStr.length > 0 && inputStr.character(at: inputStr.length-1) != UInt16(EST.SPKEY_SEPARATOR))
            {
                return (self.SendKey(EST.SPKEY_SEPARATOR, param: 0);
                ret = (self.lastInitCode == EST.SMR_OK)
            }
            return true
        }
        else if key.type == Key.KeyType.Backspace
        {
            // 退格
            return (self.SendKey(EST.SPKEY_Back, param: 0);
                ret = (self.lastInitCode == EST.SMR_OK)
        }
        else
        {
            let k : NSString = key.keyCode!
            var v : Int32 = Int32(k.character(at: 0))
            
            if (v >= 97 && v <= 122 && uppercase)
            {
                v -= 32
            }
        
            if (v >= 97 && v <= 122) ||     // a ~ z
               (v >= 65 && v <= 90) ||      // A ~ Z
               (v >= 48 && v <= 57)         // 0 ~ 9
            {
                if isSwipeDown && self.mMode == EST.IM_STROKE
                {
                    return (self.SendKey(v, param: (uppercase ? 1 : 0));
                ret = (self.lastInitCode == EST.SMR_OK)
                }
                else
                {
                    return (self.SendKey(v, param: (uppercase ? 1 : 0));
                ret = (self.lastInitCode == EST.SMR_OK)
                }
            }
        }
        return false
    }
    
    func CandCount() -> Int32
    {
        return IMEngine.dwimeCount()
    }
    
    // 取同一个多次也会死机, 500 以上
    func GetCand(_ index: Int32) -> NSString
    {
        let cand = IMEngine.dwimeGetCand(index, false)
        if (cand != nil && cand!.count > 0)
        {
            return cand! as NSString
        }
        return "nil"
    }
    
    func GetCandCode(_ index: Int32) -> NSString
    {
        let code = IMEngine.dwimeGetCandCode(index);
        return (code ?? "") as NSString;
    }
    
    func Select(_ index: Int32) -> Int32
    {
        let count1 = IMEngine.dwimeUserDBGetCount(self.mMode, nil)
        let ret = IMEngine.dwimeSelect(index)
        let count2 = IMEngine.dwimeUserDBGetCount(self.mMode, nil)
        
        if count1 < count2
        {
            self.saveUserDB()
        }
        return ret
    }
    
    func hasInput() -> Bool
    {
        let input = IMEngine.dwimeGetInput()
        
        if input != nil && input!.count > 0
        {
            return true
        }
        return false
    }

    func showIMWin() -> Bool
    {
        return IMEngine.dwimeisShowIM()
    }

    func canUpscreen() -> Bool
    {
        return IMEngine.dwimeCanUpScrenn()
    }
    
    func UpscreenStr() -> NSString
    {
        return (IMEngine.dwimeGetUpScrenn() ?? "") as NSString
    }
    
    func inputStr() -> NSString
    {
        if let input = IMEngine.dwimeGetInput()
        {
            return input as NSString
        }
        return ""
    }

    func compStr() -> NSString
    {
        if (self.mMode == IDouble.piNYIN && self.hasInput() && self.CandCount() > 0)
        {
            return (IMEngine.dwimeGetCandPY9(Int32(0)) ?? "") as NSString
        }
        else if self.mMode == EST.IM_STROKE && self.hasInput()
        {
            var comp = IMEngine.dwimeGetComp() ?? ""
            if comp.count > 0
            {
                comp = comp.replacingOccurrences(of: "1", with: "h")
                comp = comp.replacingOccurrences(of: "2", with: "s")
                comp = comp.replacingOccurrences(of: "3", with: "p")
                comp = comp.replacingOccurrences(of: "4", with: "d")
                comp = comp.replacingOccurrences(of: "5", with: "n")
                comp = comp.replacingOccurrences(of: "6", with: "z")
                return comp as NSString
            }
        }
        return (IMEngine.dwimeGetComp() ?? "") as NSString
    }
    
    func syllableNum() -> Int
    {
        return Int(IMEngine.dwimeSyllableNum())
    }

    func syllableStr(_ index: Int) -> NSString
    {
        return (IMEngine.dwimeGetSyllable(Int32(index)) ?? "") as NSString
    }

    /*****************************************************************************************
     * 手写
     ******************************************************************************************/
    func hwRecognize(_ sAry: [Int16]) -> NSString
    {
        return (IMEngine.dwhwRecognize(sAry, 20, 0x8000 | 0x400 | 0x1 | 0x2 | 0x4) ?? "") as NSString
    }
    
    func hwAssociate(_ key: NSString) ->Int
    {
        return Int(IMEngine.dwhwAssociate(key as String))
    }
    
    /*****************************************************************************************
     * 反查
     ******************************************************************************************/
    func quertCnByEn(_ enStr: String) ->String?
    {
        let dbMain: Data! = self.loadDB("cn2en.data")
        return IMEngine.dwQueryCN(byEn: (dbMain as NSData).bytes, enStr, "^")
    }
    
    func quertEnByCn(_ cnStr: String) ->String?
    {
        let dbMain: Data! = self.loadDB("cn2en.data")
        return IMEngine.dwQueryEN(byCn: (dbMain as NSData).bytes, cnStr, "^")
    }
}

