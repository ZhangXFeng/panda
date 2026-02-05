# Panda 项目 Xcode 设置指南

本文档说明如何在 Xcode 中创建项目并运行 Panda 装修管家 App。

> 由于仓库中只包含 Swift 源码，没有 `.xcodeproj` 文件，需要手动在 Xcode 中创建项目并导入代码。

## 环境要求

| 项目 | 最低版本 |
|------|----------|
| macOS | 14.0 (Sonoma) |
| Xcode | 15.0+ |
| iOS 部署目标 | 17.0+ |
| Swift | 5.9+ |

## 步骤一：克隆仓库

```bash
git clone https://github.com/ZhangXFeng/panda.git
cd panda
```

## 步骤二：在 Xcode 中创建新项目

1. 打开 Xcode，选择 **File → New → Project...**
2. 选择模板：**iOS → App**，点击 **Next**
3. 填写项目信息：

| 字段 | 值 |
|------|-----|
| Product Name | `Panda` |
| Organization Identifier | 你的 identifier（如 `com.yourname`） |
| Interface | **SwiftUI** |
| Language | **Swift** |
| Storage | **SwiftData** |

4. 点击 **Next**，**将项目保存到克隆下来的 `panda/` 目录中**（即仓库根目录）

> **注意**：Xcode 会自动创建 `Panda.xcodeproj` 和一个 `Panda/` 目录。由于仓库中已经存在 `Panda/` 目录，Xcode 可能会提示冲突。建议先将项目保存到临时位置，然后只把 `.xcodeproj` 文件夹移到仓库根目录。

## 步骤三：导入已有源码

Xcode 新建项目后会自带一些模板文件（`ContentView.swift`、`PandaApp.swift` 等），需要用仓库中的源码替换。

### 3.1 删除模板文件

在 Xcode 左侧 Project Navigator 中，删除 Xcode 自动生成的以下文件（选择 **Move to Trash**）：

- `ContentView.swift`
- `Item.swift`（如果有）
- Xcode 自动生成的 `PandaApp.swift`

### 3.2 添加仓库源码

1. 在 Project Navigator 中，右键点击 `Panda` 文件夹
2. 选择 **Add Files to "Panda"...**
3. 导航到仓库的 `Panda/` 目录，选中以下文件夹：
   - `App/`
   - `Features/`
   - `Core/`
   - `Shared/`
4. 勾选以下选项：
   - ✅ **Copy items if needed**（如果源码不在项目目录内）
   - ✅ **Create groups**
   - ✅ 确保 Target `Panda` 被勾选
5. 点击 **Add**

### 3.3 验证文件结构

添加完成后，Project Navigator 中应该呈现以下结构：

```
Panda/
├── App/
│   ├── PandaApp.swift
│   └── MainTabView.swift
├── Features/
│   ├── Budget/
│   ├── Schedule/
│   ├── Materials/
│   ├── Contacts/
│   ├── Documents/
│   ├── Journal/
│   ├── Projects/
│   ├── Home/
│   └── Profile/
├── Core/
│   ├── Database/
│   ├── Repositories/
│   ├── Services/
│   ├── UseCases/
│   ├── SampleData/
│   └── Utils/
└── Shared/
    ├── Components/
    └── Styles/
```

## 步骤四：配置项目设置

### 4.1 设置部署目标

1. 在 Project Navigator 中点击项目根节点（蓝色图标）
2. 选择 **Panda** Target
3. 在 **General** 标签页中：
   - **Minimum Deployments** → iOS 设置为 **17.0**

### 4.2 配置 Swift 版本

1. 选择 **Build Settings** 标签页
2. 搜索 `Swift Language Version`
3. 确认设置为 **Swift 5** 或更高

### 4.3 添加所需的 Framework

项目使用了以下系统框架，通常 Xcode 会自动链接，但如果出现编译错误，需要手动添加：

1. 选择 Target → **General** → **Frameworks, Libraries, and Embedded Content**
2. 点击 **+** 号，搜索并添加：
   - `SwiftUI`（通常自动包含）
   - `SwiftData`
   - `Charts`（Swift Charts）
   - `CloudKit`（如需云同步功能）

### 4.4 配置签名

1. 选择 **Signing & Capabilities** 标签页
2. 勾选 **Automatically manage signing**
3. 选择你的 **Team**：
   - 如果没有 Team，点击下拉菜单中的 **Add an Account...**，用你的 Apple ID 登录
   - 登录后会出现 "Personal Team"，选择即可
4. **修改 Bundle Identifier**：将默认的 Bundle Identifier 改为你自己的唯一值，例如 `com.<你的名字>.Panda`

> **重要**：Bundle Identifier 必须全局唯一。如果使用了别人已注册的 identifier（如 `com.riverbank.Panda`），会报错 "No profiles for 'xxx' were found"。换一个未被占用的 identifier 即可解决。

> **提示**：如果你只在模拟器上运行，可以跳过签名配置。签名只在真机运行时才需要。

## 步骤五：构建并运行

1. 在 Xcode 顶部工具栏选择模拟器（推荐 **iPhone 15** 或 **iPhone 16**）
2. 按 **⌘ + B** 构建项目，检查是否有编译错误
3. 按 **⌘ + R** 运行项目

## 常见问题排查

### Q: 编译报错 "No such module 'SwiftData'"

**原因**：部署目标低于 iOS 17。

**解决**：确认 Target → General → Minimum Deployments 设置为 iOS 17.0+。

### Q: 编译报错找不到某个 Swift 文件中的类型

**原因**：文件没有被添加到 Target。

**解决**：
1. 在 Project Navigator 中选中报错涉及的文件
2. 打开右侧 File Inspector（⌥ + ⌘ + 1）
3. 在 **Target Membership** 中勾选 `Panda`

### Q: 运行后白屏或闪退

**原因**：App 入口配置可能不正确。

**解决**：
1. 检查 `PandaApp.swift` 是否包含 `@main` 标记
2. 确保没有重复的 `@main` 入口（删除 Xcode 自动生成的入口文件）

### Q: 颜色显示不正确

**原因**：项目使用代码定义颜色（`Shared/Styles/Colors.swift`），不依赖 Asset Catalog 中的颜色集。

**解决**：确认 `Colors.swift` 已正确添加到项目中即可。

### Q: 编译报错 "has copy command from ... README.md"

**原因**：项目中多个目录下存在同名的 `README.md` 文件（如 `Features/Contacts/README.md` 和 `Features/Journal/README.md`），Xcode 将它们都加入了 Copy Bundle Resources，导致复制目标冲突。

**解决**：
1. 选择 Target → **Build Phases** 标签页
2. 展开 **Copy Bundle Resources**
3. 找到所有 `README.md` 文件，选中后点 **-** 号移除
4. 重新编译即可（⌘ + B）

### Q: CloudKit 相关报错

**原因**：CloudKit 需要有效的 Apple Developer 账号和配置。

**解决**：如果暂时不需要云同步，可以忽略相关警告。项目在本地使用 SwiftData 存储数据，不影响基本功能。

### Q: 提示 "No profiles for 'com.xxx.Panda' were found"

**原因**：Bundle Identifier 已被其他开发者注册，Xcode 无法为其创建 provisioning profile。

**解决**：
1. 选择 Target → **Signing & Capabilities**
2. 修改 **Bundle Identifier** 为一个唯一值（如 `com.<你的名字>.Panda`）
3. 确认 **Automatically manage signing** 已勾选，并选择了正确的 Team
4. Xcode 会自动为新的 Bundle Identifier 创建 provisioning profile

### Q: 提示 "Signing for 'Panda' requires a development team"

**原因**：没有配置开发者团队。

**解决**：
- 如果只在模拟器上运行：选择任意 Team 或使用 Personal Team（免费 Apple ID 即可）
- 如果要在真机运行：需要一个 Apple Developer 账号

## 替代方案：使用 Swift Package 方式（高级）

如果你熟悉 Swift Package Manager，也可以考虑以下方式：

1. 在仓库根目录创建 `Package.swift`
2. 将源码组织为一个 Swift Package
3. 使用 `swift build` 编译

但由于项目是 iOS App 且依赖 SwiftUI / SwiftData，**推荐使用标准 Xcode 项目方式**。

## 下一步

项目跑起来后，你可以：

- 阅读 [产品需求文档（PRD）](./PRD.md) 了解功能规划
- 查看 [技术设计文档](./TechnicalDesign.md) 了解架构细节
- 参考 [开发计划](./DevelopmentPlan.md) 了解开发进度
- 浏览 [线框图](./Wireframes.md) 了解 UI 设计

---

*最后更新：2026-02-05*
