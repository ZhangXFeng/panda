# Panda 装修管家 🐼

> 让装修不再焦虑，每一分钱都花得明白

一款简洁易用的 iOS 装修管理应用，帮助业主轻松掌控装修预算和进度。

## 📱 项目信息

- **平台**: iOS 17.0+
- **语言**: Swift 5.9+
- **框架**: SwiftUI + SwiftData
- **架构**: MVVM + Clean Architecture

## 📂 项目结构

```
panda/
├── docs/                          # 📄 项目文档
│   ├── PRD.md                    # 产品需求文档
│   ├── TechnicalDesign.md        # 技术设计文档
│   ├── Wireframes.md             # 原型设计文档
│   └── DevelopmentPlan.md        # 开发计划
│
├── prototype/                     # 🎨 HTML 交互原型
│   ├── index.html                # 主页面
│   ├── css/style.css             # 样式文件
│   ├── js/app.js                 # 交互逻辑
│   └── README.md                 # 原型说明
│
├── Panda/                         # 📱 iOS 应用源代码
│   ├── App/                      # 应用入口
│   │   ├── PandaApp.swift       # @main 入口
│   │   └── MainTabView.swift    # 主导航
│   │
│   ├── Features/                 # 功能模块
│   │   ├── Home/                # 首页
│   │   ├── Budget/              # 预算管理
│   │   ├── Schedule/            # 进度管理
│   │   ├── Materials/           # 材料管理
│   │   └── Profile/             # 我的
│   │
│   ├── Core/                     # 核心层
│   │   ├── Database/            # 数据模型
│   │   │   ├── Models/          # ✅ 8个SwiftData模型
│   │   │   └── Enums/           # ✅ 4个枚举类型
│   │   ├── Repositories/        # 数据仓库
│   │   ├── UseCases/            # 业务用例
│   │   └── Services/            # 服务层
│   │
│   ├── Shared/                   # 共享组件
│   │   ├── Components/          # UI组件
│   │   ├── Styles/              # ✅ 设计系统
│   │   └── Utils/               # 工具类
│   │
│   └── Resources/                # 资源文件
│
└── PandaTests/                    # 🧪 测试
```

## 🎯 核心功能

### 1. 预算管理 💰
- 总预算设置与跟踪
- 分类预算管理（硬装、主材、软装等）
- 支出记录（支持拍照、OCR识别）
- 预算分析与可视化

### 2. 进度管理 📅
- 装修阶段跟踪
- 任务清单管理
- 甘特图时间线
- 延期预警

### 3. 材料管理 🧱
- 材料清单记录
- 价格对比
- 材料计算器
- 状态跟踪

### 4. 辅助功能 📋
- 合同文档管理
- 通讯录
- 装修日记
- 数据导出

## ✅ 开发进度

### Phase 0: 项目基础 - ✅ 已完成
- [x] 创建目录结构
- [x] PandaApp 入口配置
- [x] 设计系统（Colors, Fonts, Spacing）
- [x] 主导航（TabView）

### Phase 1: 核心数据模型 - ✅ 已完成
- [x] **枚举类型** (4个)
  - ExpenseCategory（支出分类）
  - PhaseType（阶段类型）
  - TaskStatus（任务状态）
  - MaterialStatus（材料状态）

- [x] **SwiftData 模型** (8个)
  - Project（项目）
  - Budget（预算）
  - Expense（支出）
  - Phase（阶段）
  - Task（任务）
  - Material（材料）
  - Contact（联系人）
  - JournalEntry（日记）

### Phase 2: 预算模块 - 🚧 进行中
- [ ] Repository 层
- [ ] UseCase 层
- [ ] ViewModel 层
- [ ] View 层

### Phase 3-7: 其他模块 - ⏳ 待开发
- [ ] 进度模块
- [ ] 材料模块
- [ ] 首页模块
- [ ] 我的模块
- [ ] 测试与优化

## 🚀 快速开始

### 环境要求

- macOS 14.0 (Sonoma) +
- Xcode 15.0+
- iOS 17.0+ 设备或模拟器

### 运行步骤

1. **克隆仓库**
```bash
git clone <repository-url>
cd panda
```

2. **打开项目**
```bash
# 使用 Xcode 打开
open Panda/Panda.xcodeproj
# 或
open Panda/Panda.xcworkspace
```

3. **构建并运行**
```bash
# 命令行构建
xcodebuild -scheme Panda build

# 或在 Xcode 中按 Cmd + R
```

### 查看 HTML 原型

```bash
cd prototype
python3 -m http.server 8000
# 访问 http://localhost:8000
```

## 📖 文档

| 文档 | 描述 |
|------|------|
| [PRD.md](./docs/PRD.md) | 产品需求文档，定义功能和用户需求 |
| [TechnicalDesign.md](./docs/TechnicalDesign.md) | 技术设计文档，详细的技术方案 |
| [Wireframes.md](./docs/Wireframes.md) | 原型设计文档，UI设计和交互说明 |
| [DevelopmentPlan.md](./docs/DevelopmentPlan.md) | 开发计划，阶段划分和任务清单 |
| [CLAUDE.md](./CLAUDE.md) | AI 助手指南，开发规范和约定 |

## 🏗️ 技术栈

### 核心技术
- **SwiftUI**: 声明式 UI 框架
- **SwiftData**: 数据持久化（iOS 17+）
- **CloudKit**: 云同步（计划中）
- **Swift Charts**: 数据可视化

### 架构模式
- **MVVM**: Model-View-ViewModel
- **Clean Architecture**: 分层架构
- **Repository Pattern**: 数据访问抽象

### 开发工具
- **Git**: 版本控制
- **SwiftLint**: 代码规范检查
- **XCTest**: 单元测试和 UI 测试

## 🎨 设计系统

### 颜色
```swift
Color.primaryWood    // #D4A574 温暖木色
Color.success        // #4CAF50 绿色
Color.warning        // #FF9800 橙色
Color.error          // #F44336 红色
```

### 字体
```swift
Font.titleLarge     // 28pt, Bold
Font.bodyRegular    // 16pt, Regular
Font.numberLarge    // 32pt, Bold, Rounded
```

### 间距
```swift
Spacing.sm          // 8pt
Spacing.md          // 16pt
Spacing.lg          // 24pt
```

## 🧪 测试

```bash
# 运行所有测试
xcodebuild test -scheme Panda -destination 'platform=iOS Simulator,name=iPhone 15'

# 或在 Xcode 中按 Cmd + U
```

## 📝 Git 工作流

### 分支命名
```
feature/<description>  # 新功能
fix/<description>     # Bug 修复
docs/<description>    # 文档更新
```

### 提交信息格式
```
feat(budget): add expense recording view
fix(schedule): correct task completion status
docs: update README with setup instructions
```

## 📊 项目统计

| 指标 | 数量 |
|------|------|
| 数据模型 | 8 |
| 枚举类型 | 4 |
| 代码文件 | 18+ |
| 代码行数 | 3000+ |
| 文档 | 5 |

## 🤝 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'feat: add some amazing feature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 提交 Pull Request

## 📄 许可证

本项目仅供学习和参考使用。

## 📧 联系方式

如有问题或建议，欢迎提交 Issue。

---

**当前版本**: v0.2.0-alpha
**最后更新**: 2026-02-02
**开发状态**: 🚧 活跃开发中

**进度**: Phase 1 完成 ✅ → Phase 2 进行中 🚧
