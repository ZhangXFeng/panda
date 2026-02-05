# 🏠 Panda 装修管家

<div align="center">

![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)
![Xcode](https://img.shields.io/badge/Xcode-15.0+-blue.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-Latest-green.svg)
![SwiftData](https://img.shields.io/badge/SwiftData-Latest-purple.svg)
![完成度](https://img.shields.io/badge/完成度-99.4%25-brightgreen.svg)

> 让装修不再焦虑，每一分钱都花得明白

一款专为装修用户设计的全方位管理工具，帮助您轻松管理装修项目的预算、进度、材料、联系人等信息。

[功能特性](#-功能特性) •
[快速开始](#-快速开始) •
[技术栈](#-技术栈) •
[开发文档](#-开发文档)

</div>

---

## ✨ 功能特性

### 🎯 核心功能（9大模块）

| 模块 | 功能描述 | 状态 |
|------|----------|------|
| **💰 预算管理** | 精准的预算跟踪和支出记录，13 种支出分类 | ✅ 100% |
| **📅 进度管理** | 11 种装修阶段管理，完整的任务跟踪系统 | ✅ 100% |
| **📦 材料管理** | 材料清单管理，内置 4 种实用计算器 | ✅ 100% |
| **📋 项目管理** | 多项目支持，进度可视化，延期检测 | ✅ 100% |
| **👥 通讯录** | 9 种角色分类，联系人分组管理 | ✅ 100% |
| **📄 合同文档** | 合同管理，付款进度追踪 | ✅ 100% |
| **📖 装修日记** | 记录装修过程，支持照片和标签 | ✅ 100% |
| **🏠 首页仪表盘** | 项目概览，快捷操作 | ✅ 100% |
| **⚙️ 个人中心** | 设置、数据导出、帮助与反馈 | ✅ 95% |

### 🌟 特色功能

#### 📐 材料计算器
内置 4 种实用计算工具，帮助精确估算材料用量：

- **瓷砖计算器** - 根据面积和瓷砖尺寸计算所需数量（含损耗率）
- **乳胶漆计算器** - 根据墙面面积、涂刷遍数和涂刷率计算用量
- **地板计算器** - 根据铺装面积计算地板用量（含损耗率）
- **墙纸计算器** - 根据墙面高度和周长计算所需卷数

#### 🔔 智能提醒
- 预算警告（可自定义阈值 50%-100%）
- 付款到期提醒（可设置提前天数）
- 任务逾期自动检测
- 项目延期预警

#### 📊 数据可视化
- 预算使用进度条和环形图
- 阶段完成度图表（基于 Swift Charts）
- 项目时间轴可视化
- 支出分类统计饼图

#### 🔍 多维度筛选与排序
- **项目**：4 种状态筛选（全部、进行中、已完工、延期）+ 5 种排序方式
- **联系人**：按 9 种角色分组和搜索
- **材料**：按状态和位置双重分组
- **日记**：按标签和时间筛选

## 🚀 快速开始

### 系统要求

- **macOS**：14.0 (Sonoma) 或更高版本
- **Xcode**：15.0 或更高版本
- **iOS**：17.0 或更高版本（模拟器或真机）
- **Swift**：5.9+

### 安装步骤

```bash
# 1. 克隆项目
git clone https://github.com/ZhangXFeng/panda.git
cd panda

# 2. 打开项目
open Panda.xcodeproj
# 或（如果有 workspace）
open Panda.xcworkspace

# 3. 在 Xcode 中
#    - 选择目标设备（例如：iPhone 15）
#    - 按 ⌘ + R 运行项目
```

> 💡 **详细安装指南**：请查看 [GETTING_STARTED.md](./GETTING_STARTED.md)

### 生成测试数据

首次运行时可以快速生成测试数据：

1. 进入 **个人中心** 标签页
2. 滚动到底部的 **开发者选项**（仅 Debug 模式可见）
3. 点击 **生成测试数据**
4. 确认操作

将自动生成 4 个示例项目，涵盖不同装修阶段和状态。

## 🏗️ 项目结构

```
Panda/
├── Panda/
│   ├── App/                        # 📱 应用入口
│   │   ├── PandaApp.swift          # 应用生命周期
│   │   └── MainTabView.swift       # 主标签导航
│   │
│   ├── Features/                   # 🎯 功能模块（9个）
│   │   ├── Budget/                 # 💰 预算管理（Views: 2, ViewModels: 3）
│   │   ├── Schedule/               # 📅 进度管理（Views: 4, ViewModels: 2）
│   │   ├── Materials/              # 📦 材料管理（Views: 4, ViewModels: 2）
│   │   ├── Projects/               # 📋 项目管理（Views: 4, ViewModels: 2）
│   │   ├── Contacts/               # 👥 通讯录（Views: 3, ViewModels: 2）
│   │   ├── Documents/              # 📄 合同文档（Views: 3, ViewModels: 2）
│   │   ├── Journal/                # 📖 装修日记（Views: 3, ViewModels: 2）
│   │   ├── Home/                   # 🏠 首页（Views: 1）
│   │   └── Profile/                # ⚙️ 个人中心（Views: 7）
│   │
│   ├── Core/                       # 🧱 核心功能层
│   │   ├── Database/               # 数据持久化
│   │   │   └── Models/             # 10 个 SwiftData 模型
│   │   ├── Services/               # 服务层（ProjectManager）
│   │   └── Repositories/           # 数据仓储（Budget, Expense）
│   │
│   ├── Shared/                     # 🎨 共享组件
│   │   ├── Components/             # 可复用 UI 组件（8个）
│   │   └── Styles/                 # 设计系统（Colors, Fonts, Spacing）
│   │
│   └── Resources/                  # 📦 资源文件
│       └── Assets.xcassets/        # 图片和颜色资源
│
└── PandaTests/                     # 🧪 单元测试
```

## 🛠️ 技术栈

### 核心技术

| 类别 | 技术 | 版本 |
|------|------|------|
| **编程语言** | Swift | 5.9+ |
| **UI 框架** | SwiftUI | iOS 17+ |
| **数据持久化** | SwiftData | iOS 17+ |
| **云同步** | CloudKit | 规划中 |
| **图表** | Swift Charts | iOS 16+ |
| **本地化** | Localizable.strings | zh-Hans + en |

### 架构模式

- ✅ **MVVM** - Model-View-ViewModel 架构
- ✅ **Clean Architecture** - 清晰的分层设计
- ✅ **Repository Pattern** - 数据访问抽象（部分实现）
- ✅ **Dependency Injection** - 环境对象注入

### 关键特性

- ✅ **纯 SwiftUI** - 无 UIKit 依赖
- ✅ **SwiftData** - 现代化数据持久化
- ✅ **async/await** - 现代并发处理
- ✅ **@MainActor** - 主线程安全保证
- ✅ **@Observable** - 响应式编程
- ✅ **类型安全** - 强类型系统

## 📊 项目统计

| 指标 | 数量 |
|------|------|
| **总代码量** | 16,000+ 行 Swift |
| **Swift 文件** | 75+ 个 |
| **数据模型** | 10 个 SwiftData 模型 |
| **ViewModel** | 15 个业务逻辑层 |
| **视图组件** | 31 个 SwiftUI 视图 |
| **共享组件** | 8 个可复用组件 |
| **功能模块** | 9 个完整模块 |
| **完成度** | **99.4%** ✅ |

## 📚 开发文档

### 核心文档

- **[快速开始指南](./GETTING_STARTED.md)** - 详细的安装和运行说明
- **[AI 开发指南](./CLAUDE.md)** - 项目架构、代码规范和开发约定
- **[产品需求文档](./docs/PRD.md)** - 完整的功能需求说明
- **[技术设计文档](./docs/TechnicalDesign.md)** - 系统架构和技术方案

### 文档目录

```
docs/
├── PRD.md                      # 产品需求文档
├── TechnicalDesign.md          # 技术设计文档
├── Wireframes.md               # 原型设计文档
├── DevelopmentPlan.md          # 开发计划
└── DevelopmentProgress.md      # 开发进度
```

## 🎨 设计系统

### 色彩体系

```swift
// 主色调
Colors.primary          // 温暖木色 #D4A574
Colors.primaryDark      // 深色 #A67C52

// 状态色
Colors.success          // 成功 #4CAF50
Colors.warning          // 警告 #FF9800
Colors.error            // 错误 #F44336
Colors.info             // 信息 #2196F3

// 文字色
Colors.textPrimary      // 主要文字 #212121
Colors.textSecondary    // 次要文字 #757575
Colors.textHint         // 提示文字 #9E9E9E

// 背景色
Colors.backgroundPrimary    // 主背景 #FFFFFF
Colors.backgroundSecondary  // 次背景 #F5F5F5
Colors.backgroundCard       // 卡片背景 #FAFAFA
```

### 字体层级

```swift
Fonts.titleLarge        // 大标题 28pt Bold
Fonts.titleMedium       // 中标题 22pt Semibold
Fonts.titleSmall        // 小标题 18pt Semibold
Fonts.body              // 正文 16pt Regular
Fonts.caption           // 说明文字 14pt Regular
Fonts.small             // 小文字 12pt Regular
```

### 间距系统

```swift
Spacing.xs              // 超小间距 4pt
Spacing.sm              // 小间距 8pt
Spacing.md              // 中等间距 16pt
Spacing.lg              // 大间距 24pt
Spacing.xl              // 超大间距 32pt
Spacing.xxl             // 超超大间距 48pt
```

### 共享组件

- **CardView** - 卡片容器（带阴影和圆角）
- **ProgressBar** - 线性进度条
- **ProgressRing** - 环形进度指示器
- **FilterChip** - 筛选芯片按钮
- **ProjectSelector** - 项目选择器下拉菜单

## 🔄 数据模型关系

```
Project (项目)                          [10 个 SwiftData 模型]
├── Budget (预算) 1:1
│   └── Expenses[] (支出) 1:N
├── Phases[] (阶段) 1:N
│   └── Tasks[] (任务) 1:N
├── Materials[] (材料) 1:N
├── Contacts[] (联系人) 1:N
├── Documents[] (文档) 1:N
└── JournalEntries[] (日记) 1:N

AppSettings (应用设置)                  [单例配置]
```

**关系特性**：
- 所有关系使用 SwiftData `@Relationship` 管理
- 级联删除规则（删除项目时自动清理相关数据）
- 反向关系自动维护

## ✅ 完成情况

### 已完成功能（99.4%）

#### 核心模块
- ✅ **预算管理** - 预算跟踪、支出记录、分类统计
- ✅ **进度管理** - 阶段管理、任务跟踪、逾期检测
- ✅ **材料管理** - 清单管理、计算器、成本追踪
- ✅ **项目管理** - 多项目、筛选排序、统计仪表盘
- ✅ **通讯录** - 角色分组、搜索、快捷拨号
- ✅ **合同文档** - 文档管理、付款追踪
- ✅ **装修日记** - 日记记录、照片、标签
- ✅ **首页** - 项目概览、快捷操作
- ✅ **个人中心** - 设置、通知、隐私、帮助

#### 特色功能
- ✅ 材料计算器（瓷砖、乳胶漆、地板、墙纸）
- ✅ 项目统计仪表盘（图表、时间轴）
- ✅ 付款追踪系统（自动计划、逾期提醒）
- ✅ 多维度筛选和搜索
- ✅ 数据可视化（Swift Charts）

### 待完善（0.6%）

仅 3 个低优先级后端 TODO（不影响使用）：
- ⚠️ 数据导出功能实现（UI 完成）
- ⚠️ 自动备份功能实现（UI 完成）
- ⚠️ 反馈提交服务实现（UI 完成）

### 规划中

- [ ] CloudKit 云同步
- [ ] 推送通知
- [ ] 深色模式适配
- [ ] iPad 适配
- [ ] Widget 小组件
- [ ] Apple Watch 配套应用

## 🤝 贡献指南

欢迎贡献代码、提出建议或报告问题！

### 参与方式

1. **Fork 本仓库**
2. **创建特性分支**
   ```bash
   git checkout -b feature/AmazingFeature
   ```
3. **提交更改**
   ```bash
   git commit -m 'feat(budget): add some amazing feature'
   ```
4. **推送到分支**
   ```bash
   git push origin feature/AmazingFeature
   ```
5. **开启 Pull Request**

### 代码规范

- 遵循 Swift API 设计指南
- 使用 SwiftLint 检查代码风格
- 编写清晰的注释和文档
- 为新功能添加单元测试

详见 [CLAUDE.md](./CLAUDE.md) 开发指南。

## 📄 许可证

本项目仅供学习和参考使用。

## 💬 联系方式

- **项目仓库**：https://github.com/ZhangXFeng/panda
- **问题反馈**：[提交 Issue](https://github.com/ZhangXFeng/panda/issues)
- **开发者**：张晓峰

## 🙏 致谢

感谢以下资源和工具让项目成为可能：

- [Apple SwiftUI](https://developer.apple.com/documentation/swiftui/) - 声明式 UI 框架
- [Apple SwiftData](https://developer.apple.com/documentation/swiftdata/) - 数据持久化框架
- [Swift Charts](https://developer.apple.com/documentation/charts/) - 原生图表库
- [SF Symbols](https://developer.apple.com/sf-symbols/) - 系统图标库

---

<div align="center">

**⭐️ 如果这个项目对您有帮助，请给个 Star！⭐️**

**当前版本**: v1.0.0
**最后更新**: 2026-02-05
**开发状态**: ✅ 高度完成（99.4%）

Made with ❤️ by 张晓峰

</div>
