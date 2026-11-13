import Darwin
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


// MARK: - 本地拼音引擎（自建索引，不依赖内置 C 引擎）
// 数据来自 py.data 尾部追加的 PYIMBIN1 段：拼音(无调) -> 候选词表
final class LocalPinyin
{
    private let bytes: [UInt8]
    private let base: Int
    private let count: Int

    private(set) var input: String = ""
    private(set) var cands: [String] = []
    private(set) var codes: [String] = []
    private(set) var pending: String = ""
    private(set) var pendingOn: Bool = false
    private(set) var ready: Bool = false
    private let strokeMode: Bool
    private(set) var composed: String = ""
    private var typed: String = ""
    private var learned: [String: String] = [:]
    var displayInput: String { return self.composed + self.input }

    static let syList: String = "a ai an ang ao ba bai ban bao bei ben beng bi bian bie bin bing bo bu cai cang cao ce cen cha chai chan chang chao che chen cheng chi chong chou chu chuan cong cuan cui cun cuo da dai dan dang dao de deng di dian diao ding dong dou du duan dui duo e er fan fang fei feng fo fu gan gang gao ge geng gong gou gu guan gui gun guo ha hai han hang hao he hei heng hong hou hu hua huai huan huang hui huo ji jia jian jiang jiao jie jin jing jiu ju juan jue kai kan kang ke kong ku kuai kuan kuang kui kun lai lan lang lao le lei leng li lian liang liao lin ling liu long lou lu luan lun luo ma mai man mang mao mei men meng mi mian miao min ming mo mou mu na nan nao neng ni nian nie niu nong nu ou p pa pan pang pei peng pi pian piao ping po pu q qi qian qiang qiao qie qin qing qiong qiu qu quan que rang rao ren rong ru ruan rui sa san sang sen sha shan shang shao she shen sheng shi shou shu shua shuai shuang shui shun shuo si song sou su sui sun suo t ta tai tan tang tao teng ti tian tie tong tou tu tuo wa wan wang wei wen weng wu xi xia xian xiang xiao xie xin xing xiong xiu xu xuan xue xun ya yan yang yao ye yi yin ying yong you yu yuan yue yun zan zang zeng zha zhai zhan zhang zhao zhe zhen zheng zhi zhong zhou zhu zhuan zhuang zhui zhuo zi zong zou zu zuo a ai an ang ao ba bai baike baimi baiwa ban bang bao bei ben beng bi bian biang biao bie bin bing bo bu ca cai can cang cao ce cen ceng cha chai chan chang chao che chen cheng chi chong chou chu chua chuai chuan chuang chui chun chuo ci cong cou cu cuan cui cun cuo da dai dan dang dao de den deng di dia dian diao die ding diu dong dou du duan dui dun duo e ei en eng er fa fan fang fei fen feng fenke fenwa fiao fo fou fu ga gai gan gang gao ge gei gen geng gong gou gu gua guai guan guang gui gun guo ha hai han hang hao haoke haowa he hei hen heng hm hong hou hu hua huai huan huang hui hun huo ji jia jian jiang jiao jie jin jing jiong jiu ju juan jue jun ka kai kan kang kao ke kei ken keng kong kou ku kua kuai kuan kuang kui kun kuo la lai lan lang lao le lei leng li lia lian liang liao lie like lin ling liu liwa long lou lu luan lun luo m ma mai man mang mao me mei men meng mi mian miao mie min ming miu mo mou mu na nai nan nang nao ne nei nen ni nian niang niao nie nin ning niu nong nou nu nuan nun nuo o ou pa pai pan pang pao pei pen peng pi pian piao pie pin ping po pou pu qi qia qian qiang qianke qianwa qiao qie qin qing qiong qiu qu quan que qun ran rang rao re ren reng ri rong rou ru rua ruan rui run ruo sa sai san sang sao se sen seng sha shai shan shang shao she shei shen sheng shi shike shiwa shou shu shua shuai shuan shuang shui shun shuo si song sou su suan sui sun suo ta tai tan tang tao te teng ti tian tiao tie ting tong tou tu tuan tui tun tuo w wa wai wan wang wei wen weng wo wu xi xia xian xiang xiao xie xin xing xiong xiu xu xuan xue xun xx ya yan yang yao ye yi yin ying yo yong you yu yuan yue yun za zai zan zang zao ze zei zen zeng zha zhai zhan zhang zhao zhe zhen zheng zhi zhong zhou zhu zhua zhuai zhuan zhuang zhui zhun zhuo zi zong zou zu zuan zui zun zuo"
    var candCountSign: Int { return self.count }
    var isDigitsOnly: Bool { return self.strokeMode }


    static let sySet: Set<String> = Set(LocalPinyin.syList.split(separator: " ").map { String($0) })

    static var learnedURL: URL?
    {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.DWIME_DS")?.appendingPathComponent("learned_words.json")
    }

    func segments(_ s: String) -> [String]
    {
        var out: [String] = []
        var i = s.startIndex
        while i < s.endIndex
        {
            var best = ""
            var cur = ""
            var j = i
            while j < s.endIndex && cur.count < 6
            {
                cur.append(s[j])
                if LocalPinyin.sySet.contains(cur) { best = cur }
                j = s.index(after: j)
            }
            if best.isEmpty { out.append(String(s[i...])); break }
            out.append(best)
            i = s.index(i, offsetBy: best.count)
        }
        return out
    }

    func plainText() -> String?
    {
        if pendingOn && !pending.isEmpty { return pending }
        if !composed.isEmpty { return composed }
        return cands.first
    }

    func loadLearned()
    {
        guard let u = LocalPinyin.learnedURL, let d = try? Data(contentsOf: u) else { return }
        if let j = try? JSONSerialization.jsonObject(with: d) as? [String: String] { learned = j }
    }

    func saveLearned()
    {
        guard let u = LocalPinyin.learnedURL else { return }
        if let d = try? JSONSerialization.data(withJSONObject: learned, options: []) { try? d.write(to: u) }
    }

    func learn(_ letters: String, _ text: String)
    {
        if letters.count < 2 || text.count < 2 { return }
        if learned[letters] == text { return }
        learned[letters] = text
        let segs = segments(letters)
        if segs.count > 1
        {
            let ini = segs.map { String($0.prefix(1)) }.joined()
            if ini.count >= 2 { learned[ini] = text }
        }
        saveLearned()
    }

    static func readU32(_ b: [UInt8], _ o: Int) -> UInt32
    {
        if o + 3 >= b.count { return 0 }
        return UInt32(b[o]) | (UInt32(b[o+1]) << 8) | (UInt32(b[o+2]) << 16) | (UInt32(b[o+3]) << 24)
    }

    static func readU16(_ b: [UInt8], _ o: Int) -> UInt16
    {
        if o + 1 >= b.count { return 0 }
        return UInt16(b[o]) | (UInt16(b[o+1]) << 8)
    }

    init?(data: Data, marker: String = "PYIMBIN1", strokeMode: Bool = false)
    {
        self.strokeMode = strokeMode
        let b = [UInt8](data)
        let m: [UInt8] = Array(marker.utf8)
        var found: Int = -1
        if b.count >= m.count
        {
            var i = b.count - m.count
            while i >= 0
            {
                var same = true
                var k = 0
                while k < m.count
                {
                    if b[i + k] != m[k] { same = false; break }
                    k += 1
                }
                if same { found = i; break }
                i -= 1
            }
        }
        if found < 0 { return nil }
        let cnt = LocalPinyin.readU32(b, found + m.count)
        if cnt == 0 { return nil }

        self.bytes = b
        self.base = found + m.count
        self.count = Int(cnt)
        self.ready = true
    }

    private func entry(_ i: Int) -> (ko: Int, kl: Int, bo: Int, bl: Int)
    {
        let t = base + 8 + 14 * i
        return (Int(LocalPinyin.readU32(bytes, t)),
                Int(LocalPinyin.readU16(bytes, t + 4)),
                Int(LocalPinyin.readU32(bytes, t + 6)),
                Int(LocalPinyin.readU32(bytes, t + 10)))
    }

    private func keyString(_ i: Int) -> String
    {
        let e = entry(i)
        let s = base + e.ko
        if s + e.kl > bytes.count { return "" }
        return String(decoding: bytes[s..<(s + e.kl)], as: UTF8.self)
    }

    private func wordsString(_ i: Int) -> String
    {
        let e = entry(i)
        let s = base + e.bo
        if s + e.bl > bytes.count { return "" }
        return String(decoding: bytes[s..<(s + e.bl)], as: UTF8.self)
    }

    // 比较第 i 条 key 与前缀 p：key 小于前缀返回 -1，相等（即 key 以 p 开头）返回 0，大于返回 1
    private func cmp(_ i: Int, _ p: [UInt8]) -> Int
    {
        let e = entry(i)
        let s = base + e.ko
        let l = e.kl < p.count ? e.kl : p.count
        var k = 0
        while k < l
        {
            let a = bytes[s + k]
            let c = p[k]
            if a < c { return -1 }
            if a > c { return 1 }
            k += 1
        }
        if e.kl < p.count { return -1 }
        return 0
    }

    func parseEntries(_ s: String) -> [(String, String)]
    {
        var out: [(String, String)] = []
        for e in s.split(separator: "\u{1f}")
        {
            let parts = e.split(separator: "\u{1e}")
            if parts.isEmpty { continue }
            let text = String(parts[0])
            let code = parts.count > 1 ? String(parts[1]) : ""
            out.append((text, code))
        }
        return out
    }

    func entries(forKey key: String) -> [(String, String)]
    {
        let p = Array(key.utf8)
        var lo = 0
        var hi = count
        while lo < hi
        {
            let mid = (lo + hi) / 2
            if cmp(mid, p) < 0 { lo = mid + 1 } else { hi = mid }
        }
        if lo < count && cmp(lo, p) == 0 { return parseEntries(wordsString(lo)) }
        return []
    }

    func refresh()
    {
        cands.removeAll()
        codes.removeAll()
        if input.isEmpty { return }
        var seen = Set<String>()
        func ok(_ cd: String) -> Bool
        {
            if self.strokeMode { return true }
            if cd.isEmpty { return true }
            return cd.hasPrefix(input)
        }
        func put(_ w: String, _ cd: String)
        {
            if seen.contains(w) { return }
            if !ok(cd) { return }
            cands.append(w)
            codes.append(self.strokeMode ? input.uppercased() : (cd.isEmpty ? input : cd))
            seen.insert(w)
        }
        if let w = learned[input] { put(w, input) }
        for (w, cd) in entries(forKey: input) { put(w, cd); if cands.count >= 40 { return } }
        if !self.strokeMode
        {
            let segs = segments(input)
            if segs.count > 1
            {
                for (w, cd) in entries(forKey: segs[0])
                {
                    if w.count != 1 { continue }
                    if cd.isEmpty || cd.hasPrefix(segs[0])
                    {
                        if !seen.contains(w)
                        {
                            cands.append(w); codes.append(cd.isEmpty ? segs[0] : cd); seen.insert(w)
                        }
                    }
                    if cands.count >= 40 { return }
                }
            }
        }
        if input.count <= 6
        {
            for (w, cd) in entries(forKey: "#" + input) { put(w, cd); if cands.count >= 40 { return } }
        }
        let p = Array(input.utf8)
        var lo = 0
        var hi = count
        while lo < hi
        {
            let mid = (lo + hi) / 2
            if cmp(mid, p) < 0 { lo = mid + 1 } else { hi = mid }
        }
        var i = lo
        var scanned = 0
        while i < count && scanned < 400
        {
            if cmp(i, p) != 0 { break }
            let k = keyString(i)
            if k != input
            {
                for (w, cd) in parseEntries(wordsString(i)) { put(w, cd); if cands.count >= 40 { return } }
            }
            i += 1
            scanned += 1
        }
        for (k, v) in learned where k.hasPrefix(input) && k.count > input.count
        {
            put(v, k)
            if cands.count >= 40 { return }
        }
    }

    func type(_ c: Character)
    {
        pendingOn = false
        if self.strokeMode
        {
            if "hspdnz".contains(c) || "HSPDNZ".contains(c) { let l = Character(c.lowercased()); input.append(l); typed.append(l) }
        }
        else if c >= "a" && c <= "z" { input.append(c); typed.append(c) }
        if input.count > 30 { input = String(input.suffix(30)) }
        refresh()
    }

    func back()
    {
        pendingOn = false
        if input.isEmpty
        {
            if !composed.isEmpty { composed.removeLast() }
            pending = ""
            return
        }
        input.removeLast()
        if !typed.isEmpty { typed.removeLast() }
        refresh()
    }

    func select(_ i: Int) -> Int32
    {
        if i < 0 || i >= cands.count { return EST.SMR_Ignored }
        let t = cands[i]
        if !self.strokeMode && !t.isEmpty
        {
            let segs = segments(input)
            let used = min(t.count, segs.count)
            if segs.count > used && used >= 1
            {
                composed += t
                input = String(input.dropFirst(segs.prefix(used).joined().count))
                pendingOn = false
                pending = composed + input
                refresh()
                return EST.SMR_OK
            }
        }
        pending = composed + t
        pendingOn = true
        if typed.count >= 2 { learn(typed, pending) }
        composed = ""
        input = ""
        typed = ""
        cands.removeAll()
        codes.removeAll()
        return EST.SMR_OK
    }

    func commitRaw()
    {
        if input.isEmpty { return }
        pending = composed + input
        pendingOn = true
        composed = ""
        input = ""
        typed = ""
        cands.removeAll()
    }

    func consumePending()
    {
        pendingOn = false
        pending = ""
    }

    func clear()
    {
        input = ""
        pending = ""
        pendingOn = false
        cands.removeAll()
        codes.removeAll()
    }
}


class EngineService
{
    var curKB: Int32 = 0
    var curMode: Int32 = 0
    var curLang: Int32 = 0
    var curKey: Int32 = 0
    var curParam: Int32 = 0
    var curDown: Int32 = 0
    var curDB = Data()
    static var sumBuf: String = ""

    var mMode: Int32
    var mKbType: Int32
    var mDbMain: Data?
    var mDbUser: NSData?
    var mUserPtr: UnsafeMutableRawPointer?
    var lastInitCode: Int32 = -1     // dwimeInit 原始返回码
    var lastDbLen: Int = 0           // 实际吃到的词库字节数
    var isReady: Bool = false        // 初始化成功才允许按键
    var localPY: LocalPinyin?        // 本地拼音索引（py.data 尾部 PYIMBIN1 段）
    var useLocalPY: Bool { return (self.mMode == IDouble.piNYIN || self.mMode == EST.IM_STROKE) && self.localPY != nil }
    var dictHook: ((String) -> Void)?

    func DeleteKey()
    {
        _ = self.SendKey(EST.SPKEY_Back, param: 0)
    }
    
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
    
    // 只读扩展包内的词库（跳过 App Group 里的旧在线词库，避免索引段缺失）
    func loadBundleDB(_ file: String) -> Data?
    {
        let innerPath = (Bundle.main.resourcePath! as NSString).appendingPathComponent(file)
        guard let d = try? Data(contentsOf: URL(fileURLWithPath: innerPath), options: .mappedIfSafe), d.count > 1024
        else { return nil }
        return d
    }

    func kbDiagLog(_ s: String)
    {
        guard let c = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.DWIME_DS") else { return }
        let u = c.appendingPathComponent("kb_diag.log")
        let line = "\(Date().timeIntervalSince1970) \(s)\n"
        if let h = try? FileHandle(forWritingTo: u)
        {
            h.seekToEndOfFile()
            h.write(line.data(using: .utf8)!)
            h.closeFile()
        }
        else
        {
            try? line.data(using: .utf8)!.write(to: u)
        }
    }

    func kbProbePinyin()
    {
        // 不再触碰 C 引擎：用本地索引做一键自检
        var s = "[LOCAL] "
        if let db = self.loadBundleDB("py.data"), let lp = LocalPinyin(data: db)
        {
            for ch in "nihao" { lp.type(ch) }
            s += "索引=就绪 v238 键=\(lp.candCountSign) 输入=nihao 候选=\(lp.cands.count)"
            if lp.cands.count > 0 { s += " 首=" + Array(lp.cands.prefix(6)).joined(separator: ",") }
        }
        else
        {
            s += "索引=未就绪（py.data 缺失或没有 PYIMBIN1 段）"
        }
        EngineService.sumBuf = s + "\n"
        self.writeSum()
        self.kbDiagLog(s)
    }

    // 词库常驻缓冲：引擎会长期持有这个指针，绝不能用临时指针（NSData.bytes / withUnsafeBytes 出了作用域就失效）
    static var gDBPtr: UnsafeMutableRawPointer?
    static var gDBSize: Int = 0

    func stableDBPointer(_ data: Data) -> UnsafeMutableRawPointer?
    {
        if let p = EngineService.gDBPtr, EngineService.gDBSize == data.count { return p }
        if let old = EngineService.gDBPtr { free(old); EngineService.gDBPtr = nil; EngineService.gDBSize = 0 }
        guard data.count > 0 else { return nil }
        guard let p = malloc(data.count) else { return nil }
        data.withUnsafeBytes { raw in
            if let src = raw.baseAddress { p.copyMemory(from: src, byteCount: data.count) }
        }
        EngineService.gDBPtr = p
        EngineService.gDBSize = data.count
        MyLog("[DB] 常驻缓冲已建立 0x\(String(UInt(bitPattern: p), radix: 16)) len=\(data.count)")
        return p
    }

    func InitIM(_ page: Int) -> Bool
    {
        var ret: Bool = false
        self.mMode = Page2Mode(page)
        self.mKbType = Page2KbType(page)

        IMEngine.dwimeExit()

        if page == KbPage.M_Chn, let db = self.loadBundleDB("py.data"), let lp = LocalPinyin(data: db)
        {
            self.localPY = lp
            lp.loadLearned()
            self.mDbMain = db
            self.lastInitCode = EST.SMR_OK
            self.lastDbLen = db.count
            self.isReady = true
            self.kbDiagLog("[LOCAL] 本地拼音索引就绪 len=\(db.count) 条目=\(lp.candCountSign)")
            self.kbProbePinyin()
            return true
        }
        if page == KbPage.M_SK9, let db = self.loadBundleDB("sk.data"), let lp = LocalPinyin(data: db, marker: "SKIMBIN1", strokeMode: true)
        {
            self.localPY = lp
            self.mDbMain = db
            self.lastInitCode = EST.SMR_OK
            self.lastDbLen = db.count
            self.isReady = true
            self.kbDiagLog("[LOCAL SK] 笔母索引就绪 len=\(db.count)")
            return true
        }
        self.localPY = nil
        
        if IsNeedEngine(page)
        {
            if IsEnglishKB(page)
            {
                var dbMain: Data! = self.loadDB(Page2DataFile(page))
                guard let pEN = self.stableDBPointer(dbMain) else { return false }
                self.lastInitCode = IMEngine.dwimeInit(pEN, Int32(dbMain.count), nil, 0, nil, 0, Page2KbType(page), Page2Mode(page), EST.SL_English);
                ret = (self.lastInitCode == EST.SMR_OK)
                self.mDbMain = dbMain
            }
            else if page == KbPage.M_HW
            {
                IMEngine.dwhwInit(nil)
                // 联想初始化，用拼音的数据
                var dbMain: Data! = self.loadDB(Page2DataFile(KbPage.M_Chn))
                var dbUser: NSData? = self.loadUserDB().map { $0 as NSData }
                guard let pHW = self.stableDBPointer(dbMain) else { return false }
                self.lastInitCode = IMEngine.dwimeInit(pHW, Int32(dbMain.count),
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
                guard let pZH = self.stableDBPointer(dbMain) else { return false }
                self.lastInitCode = IMEngine.dwimeInit(pZH, Int32(dbMain.count),
                                    nil, 0,
                                    dbUser != nil ? (dbUser! as NSData).bytes : nil,
                                    dbUser != nil ? Int32(dbUser!.count) : 0, Page2KbType(page), self.mMode, EST.SL_Chinese);
                ret = (self.lastInitCode == EST.SMR_OK)
	            self.mDbMain = dbMain
                self.mDbUser = dbUser
            }
            self.isReady = ret
            self.lastDbLen = self.mDbMain?.count ?? 0
            UserDefaults(suiteName: "group.DWIME_DS")?.set("页面=\(page) mode=\(self.mMode)\ninit返回码=\(self.lastInitCode)\n词库字节=\(self.lastDbLen)\n可用于按键=\(self.isReady ? 1 : 0)", forKey: "diag")
            MyLog("[INIT] page=\(page) mode=\(self.mMode) code=\(self.lastInitCode) ret=\(ret) len=\(self.lastDbLen)")
            MyLog("[INIT2] count=\(IMEngine.dwimeCount())")

            if ret && page == KbPage.M_Chn
            {
                self.kbDiagLog("[PROBE] 拼音 init OK kb=\(self.mKbType) len=\(self.lastDbLen)")
                self.kbProbePinyin()
            }

            if ret
            {
                IMEngine.dwimeProcessKey(EST.SPKEY_API_AUTOCOMMIT, EST.SPKT_Down, 0)
                IMEngine.dwimeProcessKey(EST.SPKEY_API_SHORTCUTS, EST.SPKT_Down, 0)
            }
        }

        return ret
        self.localPY?.clear()
    }
    
    func End()
    {
        self.localPY?.clear()
        IMEngine.dwimeExit()
    }
    
    func Reset()
    {
        if self.useLocalPY, let lp = self.localPY { lp.clear(); return }
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

        if self.useLocalPY, let lp = self.localPY
        {
            if key >= 48 && key <= 57, lp.isDigitsOnly
            {
                var m: Character = "h"
                switch key
                {
                case 49: m = "h"
                case 50: m = "s"
                case 51: m = "p"
                case 52: m = "d"
                case 53: m = "n"
                case 54: m = "z"
                default: return EST.SMR_OK
                }
                lp.type(m)
                return EST.SMR_OK
            }
            if key >= 97 && key <= 122, let sc = UnicodeScalar(UInt32(key))
            {
                // 笔母直接用字母 H横 S竖 P撇 D点 N捺 Z折

                lp.type(Character(sc))
                return EST.SMR_OK
            }
            if key >= 65 && key <= 90, let sc = UnicodeScalar(UInt32(key + 32))
            {
                lp.type(Character(sc))
                return EST.SMR_OK
            }
            if key == EST.SPKEY_Back { lp.back(); return EST.SMR_OK }
            if key == EST.SPKEY_SEPARATOR || key == EST.SPKEY_OK || key == EST.SPKEY_Return
            {
                if key == EST.SPKEY_Return && lp.isDigitsOnly
                {
                    if let t = lp.plainText(), !t.isEmpty { self.dictHook?(t) }
                }
                if lp.cands.count > 0 { return lp.select(0) }
                lp.commitRaw()
                return EST.SMR_OK
            }
            if key == EST.SPKEY_API_RESET { lp.clear(); return EST.SMR_OK }
            return EST.SMR_OK
        }
        if self.mMode == IDouble.piNYIN ||
           self.mMode == EST.IM_STROKE ||
           self.mMode == EST.IM_LATIN
        {
            self.kbDiagLog("[KEY] before key=\(key) param=\(param)")
            let r = IMEngine.dwimeProcessKey(key, EST.SPKT_Down, param)
            self.kbDiagLog("[KEY] after key=\(key) ret=\(r) count=\(IMEngine.dwimeCount())")
            return r
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
                return (self.SendKey(EST.SPKEY_SEPARATOR, param: 0) == EST.SMR_OK)
            }
            return true
        }
        else if key.type == Key.KeyType.Backspace
        {
            // 退格
            return (self.SendKey(EST.SPKEY_Back, param: 0) == EST.SMR_OK)
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
                    return (self.SendKey(v, param: (uppercase ? 1 : 0)) == EST.SMR_OK)
                }
                else
                {
                    return (self.SendKey(v, param: (uppercase ? 1 : 0)) == EST.SMR_OK)
                }
            }
        }
        return false
    }
    
    func CandCount() -> Int32
    {
        if !self.isReady { return 0 }
        if self.useLocalPY, let lp = self.localPY { return Int32(lp.cands.count) }
        return IMEngine.dwimeCount()
    }
    
    // 取同一个多次也会死机, 500 以上
    func GetCand(_ index: Int32) -> NSString
    {
        if !self.isReady { return "" as NSString }
        if self.useLocalPY, let lp = self.localPY { let i = Int(index); return (i >= 0 && i < lp.cands.count ? lp.cands[i] : "nil") as NSString }
        let cand = IMEngine.dwimeGetCand(index, false)
        if (cand != nil && cand!.count > 0)
        {
            return cand! as NSString
        }
        return "nil"
    }
    
    func GetCandCode(_ index: Int32) -> NSString
    {
        if !self.isReady { return "" as NSString }
        if self.useLocalPY, let lp = self.localPY { let i = Int(index); return (i >= 0 && i < lp.codes.count ? lp.codes[i] : "") as NSString }
        let code = IMEngine.dwimeGetCandCode(index);
        return (code ?? "") as NSString;
    }
    
    func Select(_ index: Int32) -> Int32
    {
        if !self.isReady { return EST.SMR_Ignored }
        if self.useLocalPY, let lp = self.localPY { return lp.select(Int(index)) }
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
        if !self.isReady { return false }
        if self.useLocalPY, let lp = self.localPY { return !lp.input.isEmpty }
        let input = IMEngine.dwimeGetInput()
        
        if input != nil && input!.count > 0
        {
            return true
        }
        return false
    }

    func showIMWin() -> Bool
    {
        if !self.isReady { return false }
        if self.useLocalPY, let lp = self.localPY { return lp.cands.count > 0 }
        return IMEngine.dwimeisShowIM()
    }

    func canUpscreen() -> Bool
    {
        if !self.isReady { return false }
        if self.useLocalPY, let lp = self.localPY { return lp.pendingOn }
        return IMEngine.dwimeCanUpScrenn()
    }
    
    func UpscreenStr() -> NSString
    {
        if !self.isReady { return "" as NSString }
        if self.useLocalPY, let lp = self.localPY
        {
            let v = lp.pending
            lp.consumePending()
            return v as NSString
        }
        return (IMEngine.dwimeGetUpScrenn() ?? "") as NSString
    }
    
    func inputStr() -> NSString
    {
        if !self.isReady { return "" as NSString }
        if self.useLocalPY, let lp = self.localPY { return lp.displayInput as NSString }
        if let input = IMEngine.dwimeGetInput()
        {
            return input as NSString
        }
        return ""
    }

    func compStr() -> NSString
    {
        if !self.isReady { return "" as NSString }
        if self.useLocalPY, let lp = self.localPY { return lp.displayInput as NSString }
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
        if !self.isReady { return 0 }
        if self.useLocalPY { return 0 }
        return Int(IMEngine.dwimeSyllableNum())
    }

    func syllableStr(_ index: Int) -> NSString
    {
        if !self.isReady { return "" as NSString }
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



// MARK: - 崩溃隔离探针
@_silgen_name("DWLastCrash")
func DWLastCrash() -> UnsafePointer<CChar>?

@_silgen_name("DWPeekEngine")
func DWPeekEngine(_ db: UnsafeRawPointer?) -> UnsafePointer<CChar>?

@_silgen_name("DWPeekMore")
func DWPeekMore(_ db: UnsafeRawPointer?) -> UnsafePointer<CChar>?

@_silgen_name("DWGuardCall")
func DWGuardCall(_ fn: @convention(c) (Int32) -> Void, _ tag: Int32) -> Int32

final class DWProbeHost {
    static let shared = DWProbeHost()
    var body: ((Int32) -> Void)?
}

func dwProbeEntry(_ tag: Int32) {
    DWProbeHost.shared.body?(tag)
}

extension EngineService {
    func writeSum() {
        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.DWIME_DS")?
            .appendingPathComponent("kb_sum.log") else { return }
        try? EngineService.sumBuf.write(to: url, atomically: false, encoding: .utf8)
    }

    func runAttempt(_ tag: Int32) {
        IMEngine.dwimeExit()
        guard let pp = self.stableDBPointer(self.curDB) else { return }
        self.lastInitCode = IMEngine.dwimeInit(pp, Int32(self.curDB.count), nil, 0, nil, 0,
                                               self.curKB, self.curMode, self.curLang)
        var line = " init=\(self.lastInitCode)"
        if let c = DWPeekEngine(pp) { line += String(cString: c) }
        if let m = DWPeekMore(pp) { line += String(cString: m) }
        EngineService.sumBuf += line + "\n"
        self.writeSum()
        line = ""
        if self.lastInitCode == 0 {
            let r = IMEngine.dwimeProcessKey(self.curKey, self.curParam, self.curDown)
            line += " r=\(r) cnt=\(IMEngine.dwimeCount())"
            if IMEngine.dwimeCount() > 0, let cd = IMEngine.dwimeGetCand(0, false) {
                line += " 首=\(String(cString: cd))"
            }
        }
        EngineService.sumBuf += line + "\n"
    }
}
