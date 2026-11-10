# Xcode Cloud 上包配置指南（汉字先生 iOS V2.0）

> 目标：云端同时编译主 App（DingShiApp）+ 键盘扩展（DWIMECN.DingShi.App.Keyboard），编译成功自动产出 Build 进入 App Store Connect，可分配 TestFlight 内测。
> 约束：不新增任何功能，只打通云端编译打包链路。

---

## 〇、先纠正一个关键概念：Xcode Cloud 没有 yml 配置文件

- **yml 是 GitHub Actions 的配置格式**（放在 `.github/workflows/` 下）。你的仓库里已经有两个：`build-test.yml`（编译检查，已跑通 ✅）和 `build-ipa.yml`（手动打包上传，需要 7 个签名 secrets）。
- **Xcode Cloud 不用 yml**。它的配置 = 两部分：
  1. **仓库侧**：一个「共享 scheme」文件（`xcshareddata/xcschemes/*.xcscheme`），告诉 Xcode Cloud 编译哪个 target —— 本包已附，见下文第一节；
  2. **App Store Connect 网页侧**：在网页上点选创建 Workflow（工作流），不需要写任何配置文件。

签名也完全不同：GitHub Actions 路线要你手动维护 p12 证书 + 描述文件 secrets；**Xcode Cloud 用 Apple 官方的自动管理签名**，不需要任何 secrets，证书描述文件全部由 Apple 云端托管。

两条路线二选一即可，**推荐 Xcode Cloud**（免维护签名、构建产物直接进 App Store Connect）。已有的 `build-ipa.yml` 不用删，留作备用。

---

## 一、仓库侧：提交共享 scheme（唯一需要的代码仓库改动）

### 为什么需要

你的工程 `DWKeyboard.xcodeproj` 里目前**没有任何共享 scheme**（scheme 默认存在本地 `xcuserdata`，不上 git）。Xcode Cloud 在云端找不到 scheme 就无法配置工作流，这是唯一阻塞项。

### 方式 A（推荐，零操作）：直接拷贝本包附带文件

本包附带目录结构：

```
DWKeyboard.xcodeproj/
└── xcshareddata/
    └── xcschemes/
        └── DingShiApp.xcscheme
```

操作：把里面的 `xcshareddata` 整个文件夹，合并到你本地仓库的 `DWKeyboard.xcodeproj/` 目录里（即形成 `DWKeyboard.xcodeproj/xcshareddata/xcschemes/DingShiApp.xcscheme`），然后：

```bash
cd 你的仓库目录
git add DWKeyboard.xcodeproj/xcshareddata
git commit -m "chore: 共享 DingShiApp scheme 供 Xcode Cloud 使用"
git push
```

> 该 scheme 文件已按你工程的实际信息生成：target 蓝图 ID `4E807D9219461D9000D875D1`、产物名 `DingShiApp.app`、容器 `DWKeyboard.xcodeproj`、Archive 用 Release 配置。键盘扩展 target 由主 App 的「Embed App Extensions」阶段自动带出编译，无需单独建 scheme。

### 方式 B（图形界面，效果相同）

1. Xcode 打开 `DWKeyboard.xcodeproj`
2. 菜单 **Product → Scheme → Manage Schemes…**
3. 找到 **DingShiApp**，勾选右侧 **Shared** 复选框，关闭窗口
4. `git add DWKeyboard.xcodeproj/xcshareddata && git commit && git push`

### 验证

push 后在 GitHub 网页确认能看到这个文件：
`https://github.com/xvqchinese/hanzi-xiansheng-ios/tree/main/DWKeyboard.xcodeproj/xcshareddata/xcschemes`

---

## 二、App Store Connect 侧：保姆级操作步骤

> 前提：你有 Apple Developer Program 付费账号（Team ID: FT827LEPQL），且在 App Store Connect 里已有这个 App 的记录（Bundle ID 与工程一致）。

### 第 1 步：给 App Store Connect 授权访问 GitHub

1. 浏览器打开 https://appstoreconnect.apple.com ，用你的开发者账号登录
2. 左侧菜单点 **「用户和访问」(Users and Access)** → 顶部标签 **「Xcode Cloud」**（部分账号界面为：直接进入 App 详情页 → Xcode Cloud 标签，两者皆可）
3. 首次使用会看到 **「开始使用 Xcode Cloud」** 引导页，点 **「开始使用 / Get Started」**
4. 系统引导关联源代码管理：选择 **GitHub** → 点 **「授权 / Grant Access」**
5. 跳转 GitHub 登录页 → 登录你的 GitHub 账号 → 点 **「Authorize Apple」** 安装 Apple 的 GitHub App
6. 选择授权范围：**Only select repositories** → 勾选 **xvqchinese/hanzi-xiansheng-ios** → Install
7. 自动跳回 App Store Connect，显示「已连接 GitHub」即成功

> ⚠️ 这一步全程在 Apple 和 GitHub 官方页面之间跳转，**不要把 GitHub 密码发给任何人**。

### 第 2 步：创建 Xcode Cloud 工作流（Workflow）

1. App Store Connect 首页 → **「我的 App」** → 点进 **汉字先生**（DingShiApp）
2. 顶部标签栏点 **「Xcode Cloud」**（如果没看到，先确认 App 记录的 Bundle ID 与工程 PRODUCT_BUNDLE_IDENTIFIER 完全一致）
3. 点 **「创建工作流程 / Create Workflow」**
4. 选择仓库：列表里点 **xvqchinese/hanzi-xiansheng-ios** → 下一步
5. Apple 会扫描仓库并列出可用 scheme。选择 **DingShiApp**（就是我们刚提交的共享 scheme）
6. 填写工作流配置，按下表逐项设置：

| 配置项 | 填什么 | 说明 |
|---|---|---|
| 名称 Name | `TestFlight 内测` | 随意，可辨识即可 |
| 描述 Description | 可留空 | |
| 仓库 Repository | xvqchinese/hanzi-xiansheng-ios | 已选好 |
| 分支 Branch | `main` | 监听主分支 |
| 启动条件 Start Condition | **「每次提交到此分支时」**(On every push) | push 即自动构建；想省构建时长可选手动 |
| Xcode 版本 | **Latest Release**（最新正式版） | 不要选 Beta，上传会受限 |
| macOS 版本 | Latest Release | 跟随 Xcode 即可 |
| 环境 Environment | Clean 勾选 | 干净环境构建 |

7. **添加操作 (Actions)** —— 这是核心，点「+ 添加操作」选 **「归档 / Archive」**：
   - 平台 Platform：**iOS**
   - Scheme：**DingShiApp**（自动带出）
   - 部署准备 Deployment Preparation：**「App Store Connect」**
   - 这会自动勾选 **「管理版本和构建号 / Manage Version and Build Number」**——建议保持勾选，让云端自动递增 build 号，避免「构建号重复」报错

8. **归档后操作 (Post-Actions)**：归档操作下方找到 **「TestFlight 内部测试 / TestFlight Internal Testing」**：
   - 勾选启用
   - 测试组：选 **「App Store Connect 用户」**（默认组，团队内成员自动收到）
   - 这样每次构建成功，Build 自动分发给内部测试员，无需再手动点

9. 点 **「存储 / Save」**，再点 **「开始构建 / Start Build」**（或等下一次 push 自动触发）

### 第 3 步：首次构建的授权确认

- 第一次构建时，Xcode Cloud 可能弹出 **「需要访问权限」** 提示，按页面提示点「允许」即可（Apple 自动创建云端证书和描述文件）
- 构建约 15–30 分钟。两个 target（DingShiApp + Keyboard 扩展）会在同一个 Archive 里一起编译——键盘扩展是嵌在主 App 里的，**不需要也不应该单独建第二个工作流**

### 第 4 步：构建完成后确认 Build 进了 TestFlight

1. 构建状态变绿 ✅ 后，左侧菜单点 **「TestFlight」**
2. 在 **「构建版本 / Builds」** 列表能看到新的构建号（如 2.0.0 (x)）
3. 状态显示 **「可供测试 / Ready to Test」**（首次可能出现 10–30 分钟的「处理中」，属正常）
4. 若提示「缺少出口合规信息」：点该 Build → 填 **「否，未使用加密」**（若你用了 HTTPS 下载词库，选「豁免：仅使用系统加密」即可，选错不影响功能只影响合规标记）
5. **添加内测员**：TestFlight → 内部测试 → 「App Store Connect 用户」组 → 点「+」添加团队成员的 Apple ID 邮箱（内测上限 100 人，必须是团队成员）
6. 测试员在 iPhone/iPad 上装 **TestFlight** App → 用同一 Apple ID 登录 → 即可看到并安装汉字先生

---

## 三、常见报错速查

| 报错 | 原因 | 解决 |
|---|---|---|
| 配置工作流时找不到 scheme | 共享 scheme 没提交/没 push | 回第一节，确认 GitHub 网页上能看到 xcscheme 文件 |
| `No signing certificate` | 首次授权未完成 | App Store Connect → Xcode Cloud → 构建详情页点「允许」 |
| `exportArchive: App Store Connect Operation Error` | Bundle ID 与 ASC 记录不一致 | 核对工程 PRODUCT_BUNDLE_IDENTIFIER 与 App 记录 |
| 构建号重复 (bundle version) | 没勾自动管理构建号 | 编辑工作流 → Archive 操作 → 勾「Manage Version and Build Number」 |
| 键盘扩展嵌入失败 `Invalid Bundle` | 扩展 target 未被 Embed | 不要给扩展单独建工作流；确认主 App target 的 Build Phases 里有「Embed App Extensions」（你工程已具备 ✅） |
| 每次 push 都构建太耗时长 | 免费账号每月 25 小时 | 工作流启动条件改「手动」或「打 tag 时」 |

---

## 四、与仓库已有 GitHub Actions（build-ipa.yml）的关系

| | Xcode Cloud（本指南，推荐） | build-ipa.yml（已有，备用） |
|---|---|---|
| 配置文件 | 无 yml，网页配置 + 共享 scheme | `.github/workflows/build-ipa.yml` |
| 签名 | Apple 云端自动管理 | 需 7 个 secrets（p12/描述文件/API Key） |
| 触发 | push 自动 / 手动 | 手动 (workflow_dispatch) |
| 上传 TestFlight | 归档成功自动进 ASC | xcrun altool 上传 |
| 证书过期维护 | 无 | 每年要换证书和描述文件 |

两套互不冲突。Xcode Cloud 跑通后，build-ipa.yml 可留作灾备；若长期不用，建议把工作流里触发条件保持为手动即可。
