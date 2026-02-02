# Panda 装修管家 - 开发计划

> 版本：v1.0 | 创建日期：2026-02-02

## 目录

1. [开发策略](#1-开发策略)
2. [阶段划分](#2-阶段划分)
3. [详细任务清单](#3-详细任务清单)
4. [开发时间表](#4-开发时间表)
5. [质量保证](#5-质量保证)

---

## 1. 开发策略

### 1.1 开发原则

- **MVP 优先**：先实现核心功能（预算+进度），快速验证产品价值
- **模块化开发**：每个功能模块独立开发、测试、集成
- **增量交付**：每个阶段完成后都有可运行的版本
- **测试驱动**：关键业务逻辑先写测试
- **持续重构**：保持代码质量，避免技术债务

### 1.2 技术栈确认

| 技术 | 版本 | 用途 |
|------|------|------|
| Swift | 5.9+ | 编程语言 |
| SwiftUI | iOS 17+ | UI 框架 |
| SwiftData | iOS 17+ | 本地数据持久化 |
| CloudKit | - | 云同步（Phase 2+） |
| Swift Charts | iOS 16+ | 数据可视化 |
| PhotosUI | iOS 17+ | 图片选择 |
| Vision | iOS 17+ | OCR识别（Phase 2+） |

### 1.3 开发环境

- macOS 14.0 (Sonoma) +
- Xcode 15.0+
- iOS 17.0+ (部署目标)
- Git 版本控制

---

## 2. 阶段划分

### Phase 0: 项目基础搭建（Day 1）
**目标**：创建 Xcode 项目，搭建基础架构

**交付物**：
- ✅ Xcode 项目配置
- ✅ 基础目录结构
- ✅ SwiftData 容器配置
- ✅ 导航结构（TabView）
- ✅ 设计系统（Colors, Fonts, Styles）

---

### Phase 1: 核心数据模型（Day 1-2）
**目标**：实现所有 SwiftData 数据模型

**交付物**：
- ✅ Project（项目）模型
- ✅ Budget（预算）模型
- ✅ Expense（支出）模型
- ✅ ExpenseCategory（支出分类）枚举
- ✅ Phase（阶段）模型
- ✅ Task（任务）模型
- ✅ Material（材料）模型
- ✅ 数据模型单元测试

**技术要点**：
- 使用 @Model 宏
- 定义关系（@Relationship）
- 配置索引和唯一性约束

---

### Phase 2: 预算模块（Day 2-4）
**目标**：实现完整的预算管理功能（MVP 核心）

#### 2.1 数据层
- ✅ BudgetRepository（预算数据仓库）
- ✅ ExpenseRepository（支出数据仓库）

#### 2.2 业务层
- ✅ RecordExpenseUseCase（记录支出用例）
- ✅ CalculateBudgetUseCase（计算预算用例）
- ✅ GetBudgetAnalyticsUseCase（获取预算分析用例）

#### 2.3 视图层
- ✅ BudgetDashboardView（预算仪表盘）
  - 总预算展示
  - 圆环进度图
  - 分类预算列表
- ✅ ExpenseListView（支出列表）
  - 按月份分组
  - 搜索和筛选
- ✅ AddExpenseView（添加支出）
  - 金额输入
  - 分类选择
  - 日期选择
  - 照片上传
  - 备注输入
- ✅ BudgetAnalyticsView（预算分析）
  - 支出趋势图
  - 分类占比图
  - TOP 支出排行

#### 2.4 共享组件
- ✅ ProgressRingView（圆环进度）
- ✅ BudgetCategoryCard（分类卡片）
- ✅ ExpenseRow（支出行项）

**验收标准**：
- 能够设置总预算和分类预算
- 能够添加、编辑、删除支出记录
- 能够查看预算使用情况和分析图表
- 数据持久化正常

---

### Phase 3: 进度模块（Day 4-6）
**目标**：实现装修进度跟踪功能（MVP 核心）

#### 3.1 数据层
- ✅ ScheduleRepository（进度数据仓库）

#### 3.2 业务层
- ✅ UpdateTaskStatusUseCase（更新任务状态用例）
- ✅ GetProgressUseCase（获取进度用例）

#### 3.3 视图层
- ✅ ScheduleOverviewView（进度总览）
  - 整体进度展示
  - 当前阶段卡片
  - 阶段时间线
- ✅ PhaseDetailView（阶段详情）
  - 阶段信息
  - 任务列表
  - 验收清单
- ✅ TaskListView（任务清单）
  - 任务勾选
  - 任务筛选
  - 任务编辑
- ✅ GanttChartView（甘特图）
  - 时间线展示
  - 里程碑标记

#### 3.4 共享组件
- ✅ PhaseCard（阶段卡片）
- ✅ TaskRow（任务行项）
- ✅ ProgressBar（进度条）

**验收标准**：
- 能够添加和管理装修阶段
- 能够添加和管理任务
- 能够更新任务状态
- 能够查看整体进度和甘特图
- 延期提醒功能正常

---

### Phase 4: 首页模块（Day 6-7）
**目标**：整合数据，提供项目概览

#### 4.1 视图层
- ✅ HomeView（首页）
  - 项目封面
  - 预算概览卡片
  - 进度概览卡片
  - 快捷操作
  - 待办事项

#### 4.2 业务层
- ✅ GetProjectOverviewUseCase（获取项目概览用例）
- ✅ GetTodoItemsUseCase（获取待办事项用例）

**验收标准**：
- 首页能正确展示预算和进度摘要
- 快捷操作能跳转到对应功能
- 待办事项能正确显示并操作

---

### Phase 5: 材料模块（Day 7-8）
**目标**：实现材料管理功能

#### 5.1 数据层
- ✅ MaterialRepository（材料数据仓库）

#### 5.2 视图层
- ✅ MaterialListView（材料列表）
  - 材料卡片
  - 状态筛选
  - 搜索功能
- ✅ MaterialDetailView（材料详情）
  - 材料信息
  - 价格对比
  - 供应商信息
- ✅ MaterialCalculatorView（材料计算器）
  - 瓷砖计算
  - 地板计算
  - 油漆计算

**验收标准**：
- 能够添加、编辑、删除材料
- 能够记录多个报价
- 计算器功能准确

---

### Phase 6: 我的模块（Day 8-9）
**目标**：实现用户设置和辅助功能

#### 6.1 视图层
- ✅ ProfileView（我的页面）
- ✅ SettingsView（设置页面）
- ✅ DocumentsView（合同文档）
- ✅ ContactsView（通讯录）
- ✅ JournalView（装修日记）

#### 6.2 功能
- ✅ 项目管理
- ✅ 数据导出（PDF/Excel）
- ✅ 通知设置
- ✅ 隐私设置

**验收标准**：
- 能够管理项目信息
- 能够导出数据
- 设置功能正常

---

### Phase 7: 优化和测试（Day 9-10）
**目标**：性能优化、bug修复、测试

#### 7.1 性能优化
- ✅ 启动时间优化
- ✅ 列表滚动优化
- ✅ 内存使用优化
- ✅ 数据加载优化

#### 7.2 测试
- ✅ 单元测试覆盖率 > 70%
- ✅ UI 测试（关键流程）
- ✅ 设备测试（iPhone SE, iPhone 14, iPhone 14 Pro Max）
- ✅ 边界情况测试

#### 7.3 Bug 修复
- ✅ 修复已知 bug
- ✅ 代码审查
- ✅ 文档更新

---

## 3. 详细任务清单

### Phase 0: 项目基础搭建

```
[ ] 创建 Xcode 项目
    [ ] 配置项目信息（Bundle ID, Team, Deployment Target）
    [ ] 添加 .gitignore
    [ ] 初始化 Git 仓库

[ ] 创建目录结构
    [ ] App/
    [ ] Features/
    [ ] Core/
    [ ] Shared/
    [ ] Resources/

[ ] 设计系统
    [ ] Core/Shared/Styles/Colors.swift
    [ ] Core/Shared/Styles/Fonts.swift
    [ ] Core/Shared/Styles/Spacing.swift

[ ] 导航结构
    [ ] App/PandaApp.swift
    [ ] Features/MainTabView.swift

[ ] SwiftData 配置
    [ ] Core/Database/ModelContainer+Extension.swift
    [ ] 配置预览环境
```

### Phase 1: 核心数据模型

```
[ ] 创建基础模型
    [ ] Core/Database/Models/Project.swift
    [ ] Core/Database/Models/Budget.swift
    [ ] Core/Database/Models/Expense.swift
    [ ] Core/Database/Models/Phase.swift
    [ ] Core/Database/Models/Task.swift
    [ ] Core/Database/Models/Material.swift
    [ ] Core/Database/Models/Contact.swift
    [ ] Core/Database/Models/JournalEntry.swift

[ ] 创建枚举类型
    [ ] Core/Database/Enums/ExpenseCategory.swift
    [ ] Core/Database/Enums/PhaseType.swift
    [ ] Core/Database/Enums/TaskStatus.swift
    [ ] Core/Database/Enums/MaterialStatus.swift

[ ] 编写数据模型测试
    [ ] PandaTests/Database/ProjectTests.swift
    [ ] PandaTests/Database/ExpenseTests.swift
```

### Phase 2: 预算模块

```
[ ] 数据仓库
    [ ] Core/Repositories/BudgetRepository.swift
    [ ] Core/Repositories/ExpenseRepository.swift

[ ] 业务用例
    [ ] Core/UseCases/Budget/RecordExpenseUseCase.swift
    [ ] Core/UseCases/Budget/CalculateBudgetUseCase.swift
    [ ] Core/UseCases/Budget/GetBudgetAnalyticsUseCase.swift

[ ] ViewModel
    [ ] Features/Budget/ViewModels/BudgetDashboardViewModel.swift
    [ ] Features/Budget/ViewModels/ExpenseListViewModel.swift
    [ ] Features/Budget/ViewModels/AddExpenseViewModel.swift

[ ] Views
    [ ] Features/Budget/Views/BudgetDashboardView.swift
    [ ] Features/Budget/Views/ExpenseListView.swift
    [ ] Features/Budget/Views/AddExpenseView.swift
    [ ] Features/Budget/Views/BudgetAnalyticsView.swift

[ ] 组件
    [ ] Features/Budget/Components/ProgressRingView.swift
    [ ] Features/Budget/Components/BudgetCategoryCard.swift
    [ ] Features/Budget/Components/ExpenseRow.swift

[ ] 测试
    [ ] PandaTests/Budget/BudgetViewModelTests.swift
    [ ] PandaTests/Budget/ExpenseUseCaseTests.swift
```

### Phase 3: 进度模块

```
[ ] 数据仓库
    [ ] Core/Repositories/ScheduleRepository.swift

[ ] 业务用例
    [ ] Core/UseCases/Schedule/UpdateTaskStatusUseCase.swift
    [ ] Core/UseCases/Schedule/GetProgressUseCase.swift

[ ] ViewModel
    [ ] Features/Schedule/ViewModels/ScheduleOverviewViewModel.swift
    [ ] Features/Schedule/ViewModels/PhaseDetailViewModel.swift

[ ] Views
    [ ] Features/Schedule/Views/ScheduleOverviewView.swift
    [ ] Features/Schedule/Views/PhaseDetailView.swift
    [ ] Features/Schedule/Views/TaskListView.swift
    [ ] Features/Schedule/Views/GanttChartView.swift

[ ] 组件
    [ ] Features/Schedule/Components/PhaseCard.swift
    [ ] Features/Schedule/Components/TaskRow.swift

[ ] 测试
    [ ] PandaTests/Schedule/ScheduleViewModelTests.swift
```

### Phase 4: 首页模块

```
[ ] 业务用例
    [ ] Core/UseCases/Home/GetProjectOverviewUseCase.swift
    [ ] Core/UseCases/Home/GetTodoItemsUseCase.swift

[ ] ViewModel
    [ ] Features/Home/ViewModels/HomeViewModel.swift

[ ] Views
    [ ] Features/Home/Views/HomeView.swift
    [ ] Features/Home/Components/ProjectCoverView.swift
    [ ] Features/Home/Components/QuickActionView.swift

[ ] 测试
    [ ] PandaTests/Home/HomeViewModelTests.swift
```

### Phase 5-7: 其他模块（省略详细清单）

---

## 4. 开发时间表

### 总体时间（预计 10 天）

| 阶段 | 天数 | 日期（示例） | 里程碑 |
|------|------|-------------|--------|
| Phase 0 | 0.5天 | Day 1 上午 | ✅ 项目可运行 |
| Phase 1 | 1天 | Day 1 下午 - Day 2 上午 | ✅ 数据模型完成 |
| Phase 2 | 2天 | Day 2 下午 - Day 4 | ✅ 预算功能可用 |
| Phase 3 | 2天 | Day 4 - Day 6 | ✅ 进度功能可用 |
| Phase 4 | 1天 | Day 6 - Day 7 | ✅ MVP 完成 |
| Phase 5 | 1天 | Day 7 - Day 8 | ✅ 材料功能完成 |
| Phase 6 | 1天 | Day 8 - Day 9 | ✅ 全功能完成 |
| Phase 7 | 1.5天 | Day 9 - Day 10 | ✅ 发布就绪 |

### 每日计划示例

**Day 1**
- 上午：创建项目、搭建架构、设计系统
- 下午：数据模型（Project, Budget, Expense）

**Day 2**
- 上午：数据模型（Phase, Task, Material）+ 测试
- 下午：预算模块 Repository 和 UseCase

**Day 3**
- 全天：预算模块 UI（Dashboard, ExpenseList, AddExpense）

**Day 4**
- 上午：预算模块 Analytics + 测试
- 下午：进度模块 Repository 和 UseCase

**Day 5**
- 全天：进度模块 UI（Overview, PhaseDetail, TaskList）

**Day 6**
- 上午：进度模块 GanttChart + 测试
- 下午：首页模块

**Day 7**
- 上午：首页完善 + MVP 集成测试
- 下午：材料模块

**Day 8**
- 上午：材料模块完善
- 下午：我的模块（Settings, Documents）

**Day 9**
- 上午：我的模块（Contacts, Journal）
- 下午：优化和测试

**Day 10**
- 上午：Bug 修复、性能优化
- 下午：最终测试、文档更新

---

## 5. 质量保证

### 5.1 代码质量

- **命名规范**：遵循 Swift API Design Guidelines
- **代码审查**：每个 PR 必须审查
- **静态分析**：使用 SwiftLint
- **代码覆盖率**：单元测试覆盖率 > 70%

### 5.2 测试策略

#### 单元测试
- 所有 ViewModel 必须有测试
- 所有 UseCase 必须有测试
- 关键业务逻辑必须有测试

#### UI 测试
- 关键用户流程：记账、添加任务
- 导航流程：页面切换

#### 手动测试
- 不同设备尺寸测试
- 边界情况测试
- 性能测试

### 5.3 性能指标

| 指标 | 目标 |
|------|------|
| 冷启动时间 | < 2秒 |
| 页面切换 | < 300ms |
| 列表滚动 | 60 FPS |
| 内存占用 | < 100MB |
| 数据库查询 | < 100ms |

### 5.4 发布检查清单

```
[ ] 所有功能测试通过
[ ] 无已知 Critical/High Bug
[ ] 单元测试覆盖率 > 70%
[ ] UI 测试通过
[ ] 性能指标达标
[ ] 代码审查完成
[ ] 文档更新
[ ] App Icon 和 Launch Screen
[ ] Privacy Policy 和 Terms
[ ] App Store 截图和描述
```

---

## 6. 风险管理

### 6.1 技术风险

| 风险 | 概率 | 影响 | 应对策略 |
|------|------|------|---------|
| SwiftData 稳定性问题 | 中 | 高 | 准备 Core Data 降级方案 |
| CloudKit 同步复杂度 | 中 | 中 | Phase 1 不实现，后续版本添加 |
| 性能问题 | 低 | 中 | 早期性能测试，及时优化 |

### 6.2 进度风险

| 风险 | 应对策略 |
|------|---------|
| 需求变更 | 变更控制流程，评估影响 |
| 开发延期 | 调整功能优先级，砍掉非核心功能 |
| 测试不充分 | 预留充足测试时间，自动化测试 |

---

## 7. 后续版本规划

### v1.1 (MVP + 1 month)
- 📸 OCR 识别小票金额
- ☁️ iCloud 数据同步
- 📊 更丰富的图表
- 🔔 智能提醒

### v1.2 (MVP + 2 months)
- 🤖 AI 预算建议
- 👥 社区功能
- 📤 分享功能
- 🌙 暗黑模式

### v2.0 (MVP + 6 months)
- 📱 iPad 适配
- 🥽 AR 功能（量房、家具预览）
- 🔗 第三方集成（淘宝、京东）
- 🌍 国际化（英文）

---

## 附录：开发命令速查

### Git 工作流
```bash
# 创建新功能分支
git checkout -b feature/budget-module

# 提交代码
git add .
git commit -m "feat(budget): implement expense recording"

# 推送到远程
git push -u origin feature/budget-module

# 合并到主分支
git checkout main
git merge feature/budget-module
git push
```

### Xcode 命令
```bash
# 构建项目
xcodebuild -scheme Panda build

# 运行测试
xcodebuild test -scheme Panda -destination 'platform=iOS Simulator,name=iPhone 15'

# 清理构建
xcodebuild clean

# 创建归档
xcodebuild archive -scheme Panda -archivePath ./build/Panda.xcarchive
```

---

*文档版本：v1.0*
*创建日期：2026-02-02*
*预计完成日期：2026-02-12*
