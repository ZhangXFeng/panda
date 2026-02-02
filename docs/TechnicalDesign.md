# Panda 装修管家 - 技术方案文档

> 版本：v1.0 | 更新日期：2026-02-02

## 目录

1. [技术概述](#1-技术概述)
2. [系统架构](#2-系统架构)
3. [数据模型设计](#3-数据模型设计)
4. [模块详细设计](#4-模块详细设计)
5. [数据存储方案](#5-数据存储方案)
6. [云同步策略](#6-云同步策略)
7. [安全性设计](#7-安全性设计)
8. [性能优化](#8-性能优化)
9. [测试策略](#9-测试策略)
10. [开发规范](#10-开发规范)
11. [部署与发布](#11-部署与发布)

---

## 1. 技术概述

### 1.1 技术选型

| 类别 | 技术方案 | 版本要求 | 选型理由 |
|-----|---------|---------|---------|
| **开发语言** | Swift | 5.9+ | 类型安全、现代语法、Apple 官方支持 |
| **UI 框架** | SwiftUI | iOS 17+ | 声明式 UI、跨 Apple 平台、实时预览 |
| **架构模式** | MVVM + Clean Architecture | - | 关注点分离、易于测试、可维护性强 |
| **本地存储** | SwiftData | iOS 17+ | Apple 新一代 ORM、与 SwiftUI 深度集成 |
| **云同步** | CloudKit | - | 免服务器、iCloud 集成、自动同步 |
| **图表** | Swift Charts | iOS 16+ | 原生支持、性能优秀、与 SwiftUI 集成 |
| **图片处理** | PhotosUI + Vision | - | 系统原生、OCR 支持 |
| **依赖管理** | Swift Package Manager | - | Apple 官方、Xcode 集成 |

### 1.2 系统要求

```
最低部署版本: iOS 17.0
推荐设备: iPhone (主要), iPad (适配)
开发环境:
  - macOS 14.0 (Sonoma) +
  - Xcode 15.0+
  - Swift 5.9+
```

### 1.3 第三方依赖策略

**原则：尽量使用系统原生方案，减少外部依赖**

| 功能 | 方案 | 备注 |
|-----|------|-----|
| 网络请求 | URLSession | 原生足够 |
| JSON 解析 | Codable | 原生支持 |
| 图片加载 | AsyncImage / PhotosUI | 原生支持 |
| 日期处理 | Foundation.Date | 原生支持 |
| 货币格式化 | NumberFormatter | 原生支持 |

**可选依赖（后期评估）**：

```swift
// Package.swift 示例
dependencies: [
    // 仅在需要时添加
    // .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.0.0"),
]
```

---

## 2. 系统架构

### 2.1 整体架构图

```
┌─────────────────────────────────────────────────────────────────┐
│                        Presentation Layer                        │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐│
│  │ BudgetView  │ │ScheduleView│ │MaterialView │ │ JournalView ││
│  └──────┬──────┘ └──────┬──────┘ └──────┬──────┘ └──────┬──────┘│
│         │               │               │               │        │
│  ┌──────▼──────┐ ┌──────▼──────┐ ┌──────▼──────┐ ┌──────▼──────┐│
│  │BudgetVM     │ │ScheduleVM  │ │MaterialVM  │ │ JournalVM   ││
│  └──────┬──────┘ └──────┬──────┘ └──────┬──────┘ └──────┬──────┘│
└─────────┼───────────────┼───────────────┼───────────────┼────────┘
          │               │               │               │
┌─────────▼───────────────▼───────────────▼───────────────▼────────┐
│                         Domain Layer                              │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                        Use Cases                             │ │
│  │  BudgetUseCase | ScheduleUseCase | MaterialUseCase | ...    │ │
│  └─────────────────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                      Domain Models                           │ │
│  │  Project | Budget | Expense | Task | Material | Contact     │ │
│  └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────┬────────────────────────────────┘
                                  │
┌─────────────────────────────────▼────────────────────────────────┐
│                          Data Layer                               │
│  ┌──────────────────┐  ┌──────────────────┐  ┌─────────────────┐ │
│  │  SwiftData       │  │   CloudKit       │  │  FileManager    │ │
│  │  Repository      │  │   Sync Service   │  │  (Photos/Docs)  │ │
│  └────────┬─────────┘  └────────┬─────────┘  └────────┬────────┘ │
│           │                     │                     │          │
│  ┌────────▼─────────────────────▼─────────────────────▼────────┐ │
│  │                    Local Database (SwiftData)                │ │
│  └──────────────────────────────────────────────────────────────┘ │
│                                 ↕                                 │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │                    iCloud (CloudKit)                          │ │
│  └──────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────┘
```

### 2.2 模块划分

```
Panda/
├── App/                          # 应用入口
│   ├── PandaApp.swift           # @main 入口
│   ├── AppDelegate.swift        # 生命周期（可选）
│   └── DependencyContainer.swift # 依赖注入容器
│
├── Features/                     # 功能模块（按业务划分）
│   ├── Budget/                  # 预算管理
│   │   ├── Views/
│   │   │   ├── BudgetDashboardView.swift
│   │   │   ├── ExpenseListView.swift
│   │   │   ├── AddExpenseView.swift
│   │   │   └── BudgetAnalyticsView.swift
│   │   ├── ViewModels/
│   │   │   ├── BudgetDashboardViewModel.swift
│   │   │   └── ExpenseListViewModel.swift
│   │   └── Components/
│   │       ├── BudgetProgressCard.swift
│   │       └── ExpenseRow.swift
│   │
│   ├── Schedule/                # 进度管理
│   │   ├── Views/
│   │   │   ├── ScheduleOverviewView.swift
│   │   │   ├── PhaseDetailView.swift
│   │   │   ├── TaskListView.swift
│   │   │   └── GanttChartView.swift
│   │   ├── ViewModels/
│   │   └── Components/
│   │
│   ├── Materials/               # 材料管理
│   ├── Documents/               # 合同文档
│   ├── Contacts/                # 通讯录
│   ├── Journal/                 # 装修日记
│   └── Settings/                # 设置
│
├── Core/                         # 核心层
│   ├── Database/                # 数据模型
│   │   ├── Models/
│   │   │   ├── Project.swift
│   │   │   ├── Budget.swift
│   │   │   ├── Expense.swift
│   │   │   ├── Phase.swift
│   │   │   ├── Task.swift
│   │   │   ├── Material.swift
│   │   │   ├── Document.swift
│   │   │   ├── Contact.swift
│   │   │   └── JournalEntry.swift
│   │   ├── Enums/
│   │   │   ├── ExpenseCategory.swift
│   │   │   ├── PhaseType.swift
│   │   │   ├── TaskStatus.swift
│   │   │   └── MaterialStatus.swift
│   │   └── ModelContainer+Extension.swift
│   │
│   ├── Repositories/            # 数据仓库
│   │   ├── ProjectRepository.swift
│   │   ├── BudgetRepository.swift
│   │   ├── ScheduleRepository.swift
│   │   └── BaseRepository.swift
│   │
│   ├── UseCases/                # 业务用例
│   │   ├── Budget/
│   │   │   ├── RecordExpenseUseCase.swift
│   │   │   ├── CalculateBudgetUseCase.swift
│   │   │   └── GetBudgetAnalyticsUseCase.swift
│   │   └── Schedule/
│   │       ├── UpdateTaskStatusUseCase.swift
│   │       └── GetProgressUseCase.swift
│   │
│   ├── Services/                # 服务层
│   │   ├── CloudSyncService.swift
│   │   ├── PhotoService.swift
│   │   ├── OCRService.swift
│   │   ├── NotificationService.swift
│   │   └── ExportService.swift
│   │
│   └── Extensions/              # 扩展
│       ├── Date+Extensions.swift
│       ├── Decimal+Extensions.swift
│       ├── Color+Extensions.swift
│       └── View+Extensions.swift
│
├── Shared/                       # 共享组件
│   ├── Components/              # 可复用 UI 组件
│   │   ├── Cards/
│   │   │   ├── StatCard.swift
│   │   │   └── InfoCard.swift
│   │   ├── Charts/
│   │   │   ├── PieChartView.swift
│   │   │   ├── BarChartView.swift
│   │   │   └── ProgressRingView.swift
│   │   ├── Forms/
│   │   │   ├── AmountInputField.swift
│   │   │   ├── CategoryPicker.swift
│   │   │   └── DatePickerField.swift
│   │   ├── Lists/
│   │   │   ├── SwipeableRow.swift
│   │   │   └── EmptyStateView.swift
│   │   └── Common/
│   │       ├── LoadingView.swift
│   │       ├── ErrorView.swift
│   │       └── PhotoPickerButton.swift
│   │
│   ├── Styles/                  # 设计系统
│   │   ├── Colors.swift
│   │   ├── Typography.swift
│   │   ├── Spacing.swift
│   │   └── ButtonStyles.swift
│   │
│   └── Utils/                   # 工具类
│       ├── Formatters.swift
│       ├── Validators.swift
│       ├── Calculator.swift
│       └── Constants.swift
│
├── Resources/                    # 资源文件
│   ├── Assets.xcassets/
│   │   ├── Colors/
│   │   ├── Images/
│   │   └── AppIcon.appiconset/
│   ├── Localization/
│   │   ├── zh-Hans.lproj/
│   │   │   └── Localizable.strings
│   │   └── en.lproj/
│   │       └── Localizable.strings
│   └── DefaultData/
│       ├── DefaultCategories.json
│       └── DefaultPhases.json
│
└── PandaTests/                   # 测试
    ├── UnitTests/
    │   ├── ViewModels/
    │   ├── UseCases/
    │   └── Repositories/
    ├── IntegrationTests/
    └── UITests/
```

### 2.3 依赖注入设计

```swift
// App/DependencyContainer.swift

import SwiftUI
import SwiftData

/// 依赖注入容器
@MainActor
final class DependencyContainer: ObservableObject {

    // MARK: - Shared Instance
    static let shared = DependencyContainer()

    // MARK: - Model Container
    let modelContainer: ModelContainer

    // MARK: - Services
    lazy var cloudSyncService: CloudSyncService = {
        CloudSyncService(modelContainer: modelContainer)
    }()

    lazy var photoService: PhotoService = {
        PhotoService()
    }()

    lazy var notificationService: NotificationService = {
        NotificationService()
    }()

    // MARK: - Repositories
    lazy var projectRepository: ProjectRepository = {
        ProjectRepository(modelContainer: modelContainer)
    }()

    lazy var budgetRepository: BudgetRepository = {
        BudgetRepository(modelContainer: modelContainer)
    }()

    lazy var scheduleRepository: ScheduleRepository = {
        ScheduleRepository(modelContainer: modelContainer)
    }()

    // MARK: - Use Cases
    func makeRecordExpenseUseCase() -> RecordExpenseUseCase {
        RecordExpenseUseCase(
            budgetRepository: budgetRepository,
            photoService: photoService
        )
    }

    func makeCalculateBudgetUseCase() -> CalculateBudgetUseCase {
        CalculateBudgetUseCase(budgetRepository: budgetRepository)
    }

    // MARK: - View Models
    func makeBudgetDashboardViewModel() -> BudgetDashboardViewModel {
        BudgetDashboardViewModel(
            budgetRepository: budgetRepository,
            calculateBudgetUseCase: makeCalculateBudgetUseCase()
        )
    }

    // MARK: - Initialization
    private init() {
        do {
            let schema = Schema([
                Project.self,
                Budget.self,
                Expense.self,
                Phase.self,
                Task.self,
                Material.self,
                Document.self,
                Contact.self,
                JournalEntry.self
            ])

            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .private("iCloud.com.yourcompany.panda")
            )

            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}

// MARK: - Environment Key
struct DependencyContainerKey: EnvironmentKey {
    static let defaultValue = DependencyContainer.shared
}

extension EnvironmentValues {
    var dependencies: DependencyContainer {
        get { self[DependencyContainerKey.self] }
        set { self[DependencyContainerKey.self] = newValue }
    }
}
```

---

## 3. 数据模型设计

### 3.1 ER 图

```
┌─────────────┐       ┌─────────────┐       ┌─────────────┐
│   Project   │───┬───│   Budget    │───────│  Expense    │
│             │   │   │             │       │             │
│ - id        │   │   │ - id        │       │ - id        │
│ - name      │   │   │ - total     │       │ - amount    │
│ - address   │   │   │ - spent     │       │ - category  │
│ - area      │   │   │ - categories│       │ - note      │
│ - startDate │   │   └─────────────┘       │ - date      │
│ - status    │   │                         │ - photos    │
└─────────────┘   │                         │ - paymentType│
                  │                         └─────────────┘
                  │
                  │   ┌─────────────┐       ┌─────────────┐
                  ├───│   Phase     │───────│    Task     │
                  │   │             │       │             │
                  │   │ - id        │       │ - id        │
                  │   │ - type      │       │ - title     │
                  │   │ - name      │       │ - status    │
                  │   │ - order     │       │ - assignee  │
                  │   │ - startDate │       │ - dueDate   │
                  │   │ - endDate   │       │ - notes     │
                  │   │ - status    │       └─────────────┘
                  │   └─────────────┘
                  │
                  │   ┌─────────────┐
                  ├───│  Material   │
                  │   │             │
                  │   │ - id        │
                  │   │ - name      │
                  │   │ - brand     │
                  │   │ - price     │
                  │   │ - quantity  │
                  │   │ - status    │
                  │   │ - room      │
                  │   └─────────────┘
                  │
                  │   ┌─────────────┐
                  ├───│  Document   │
                  │   │             │
                  │   │ - id        │
                  │   │ - type      │
                  │   │ - title     │
                  │   │ - fileData  │
                  │   │ - keyInfo   │
                  │   └─────────────┘
                  │
                  │   ┌─────────────┐
                  ├───│  Contact    │
                  │   │             │
                  │   │ - id        │
                  │   │ - name      │
                  │   │ - role      │
                  │   │ - phone     │
                  │   │ - rating    │
                  │   └─────────────┘
                  │
                  │   ┌─────────────┐
                  └───│JournalEntry │
                      │             │
                      │ - id        │
                      │ - date      │
                      │ - content   │
                      │ - photos    │
                      │ - phase     │
                      └─────────────┘
```

### 3.2 核心模型定义

```swift
// Core/Database/Models/Project.swift

import Foundation
import SwiftData

@Model
final class Project {
    // MARK: - Properties
    var id: UUID
    var name: String
    var address: String
    var area: Double  // 平方米
    var createdAt: Date
    var startDate: Date?
    var expectedEndDate: Date?
    var actualEndDate: Date?
    var status: ProjectStatus
    var notes: String

    // MARK: - Relationships
    @Relationship(deleteRule: .cascade, inverse: \Budget.project)
    var budget: Budget?

    @Relationship(deleteRule: .cascade, inverse: \Phase.project)
    var phases: [Phase] = []

    @Relationship(deleteRule: .cascade, inverse: \Material.project)
    var materials: [Material] = []

    @Relationship(deleteRule: .cascade, inverse: \Document.project)
    var documents: [Document] = []

    @Relationship(deleteRule: .cascade, inverse: \Contact.project)
    var contacts: [Contact] = []

    @Relationship(deleteRule: .cascade, inverse: \JournalEntry.project)
    var journalEntries: [JournalEntry] = []

    // MARK: - Computed Properties
    var progress: Double {
        guard !phases.isEmpty else { return 0 }
        let completedCount = phases.filter { $0.status == .completed }.count
        return Double(completedCount) / Double(phases.count)
    }

    var totalSpent: Decimal {
        budget?.totalSpent ?? 0
    }

    // MARK: - Initialization
    init(
        name: String,
        address: String = "",
        area: Double = 0,
        startDate: Date? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.address = address
        self.area = area
        self.createdAt = Date()
        self.startDate = startDate
        self.status = .planning
        self.notes = ""
    }
}

// MARK: - Project Status
enum ProjectStatus: String, Codable, CaseIterable {
    case planning = "planning"      // 规划中
    case inProgress = "in_progress" // 进行中
    case paused = "paused"          // 暂停
    case completed = "completed"    // 已完成

    var displayName: String {
        switch self {
        case .planning: return "规划中"
        case .inProgress: return "进行中"
        case .paused: return "已暂停"
        case .completed: return "已完成"
        }
    }
}
```

```swift
// Core/Database/Models/Budget.swift

import Foundation
import SwiftData

@Model
final class Budget {
    // MARK: - Properties
    var id: UUID
    var totalAmount: Decimal          // 总预算
    var warningThreshold: Double      // 预警阈值 (0.0 - 1.0)
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Category Budgets
    var categoryBudgets: [CategoryBudget]  // 分类预算

    // MARK: - Relationships
    var project: Project?

    @Relationship(deleteRule: .cascade, inverse: \Expense.budget)
    var expenses: [Expense] = []

    // MARK: - Computed Properties
    var totalSpent: Decimal {
        expenses.reduce(0) { $0 + $1.amount }
    }

    var remaining: Decimal {
        totalAmount - totalSpent
    }

    var usagePercentage: Double {
        guard totalAmount > 0 else { return 0 }
        return Double(truncating: (totalSpent / totalAmount) as NSNumber)
    }

    var isOverBudget: Bool {
        totalSpent > totalAmount
    }

    var isWarning: Bool {
        usagePercentage >= warningThreshold
    }

    // 按分类统计支出
    func spentByCategory(_ category: ExpenseCategory) -> Decimal {
        expenses
            .filter { $0.category == category }
            .reduce(0) { $0 + $1.amount }
    }

    // MARK: - Initialization
    init(totalAmount: Decimal, warningThreshold: Double = 0.8) {
        self.id = UUID()
        self.totalAmount = totalAmount
        self.warningThreshold = warningThreshold
        self.createdAt = Date()
        self.updatedAt = Date()
        self.categoryBudgets = ExpenseCategory.allCases.map { category in
            CategoryBudget(category: category, amount: 0)
        }
    }
}

// MARK: - Category Budget
struct CategoryBudget: Codable, Hashable {
    var category: ExpenseCategory
    var amount: Decimal

    var spent: Decimal = 0  // 由 Budget 计算后填充
}
```

```swift
// Core/Database/Models/Expense.swift

import Foundation
import SwiftData

@Model
final class Expense {
    // MARK: - Properties
    var id: UUID
    var amount: Decimal
    var category: ExpenseCategory
    var subcategory: String?
    var note: String
    var date: Date
    var paymentType: PaymentType
    var merchantName: String?
    var receiptData: [Data]           // 小票/发票照片
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Relationships
    var budget: Budget?
    var contact: Contact?             // 关联商家/供应商

    // MARK: - Initialization
    init(
        amount: Decimal,
        category: ExpenseCategory,
        note: String = "",
        date: Date = Date(),
        paymentType: PaymentType = .full
    ) {
        self.id = UUID()
        self.amount = amount
        self.category = category
        self.note = note
        self.date = date
        self.paymentType = paymentType
        self.receiptData = []
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Expense Category
enum ExpenseCategory: String, Codable, CaseIterable, Identifiable {
    // 设计
    case design = "design"

    // 硬装
    case demolition = "demolition"      // 拆改
    case hydropower = "hydropower"      // 水电
    case masonry = "masonry"            // 泥瓦
    case carpentry = "carpentry"        // 木工
    case painting = "painting"          // 油漆

    // 主材
    case flooring = "flooring"          // 地板/瓷砖
    case doors = "doors"                // 门窗
    case cabinets = "cabinets"          // 橱柜
    case bathroom = "bathroom"          // 卫浴
    case lighting = "lighting"          // 灯具

    // 软装
    case furniture = "furniture"        // 家具
    case appliances = "appliances"      // 家电
    case curtains = "curtains"          // 窗帘
    case decoration = "decoration"      // 装饰品

    // 其他
    case other = "other"                // 其他

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .design: return "设计费"
        case .demolition: return "拆改"
        case .hydropower: return "水电"
        case .masonry: return "泥瓦"
        case .carpentry: return "木工"
        case .painting: return "油漆"
        case .flooring: return "地板/瓷砖"
        case .doors: return "门窗"
        case .cabinets: return "橱柜"
        case .bathroom: return "卫浴"
        case .lighting: return "灯具"
        case .furniture: return "家具"
        case .appliances: return "家电"
        case .curtains: return "窗帘"
        case .decoration: return "装饰品"
        case .other: return "其他"
        }
    }

    var icon: String {
        switch self {
        case .design: return "pencil.and.ruler"
        case .demolition: return "hammer"
        case .hydropower: return "bolt"
        case .masonry: return "square.stack.3d.up"
        case .carpentry: return "cabinet"
        case .painting: return "paintbrush"
        case .flooring: return "square.grid.3x3"
        case .doors: return "door.left.hand.closed"
        case .cabinets: return "cabinet.fill"
        case .bathroom: return "shower"
        case .lighting: return "lightbulb"
        case .furniture: return "sofa"
        case .appliances: return "tv"
        case .curtains: return "curtains.closed"
        case .decoration: return "photo.artframe"
        case .other: return "ellipsis.circle"
        }
    }

    var group: CategoryGroup {
        switch self {
        case .design:
            return .design
        case .demolition, .hydropower, .masonry, .carpentry, .painting:
            return .hardDecoration
        case .flooring, .doors, .cabinets, .bathroom, .lighting:
            return .mainMaterials
        case .furniture, .appliances, .curtains, .decoration:
            return .softDecoration
        case .other:
            return .other
        }
    }
}

enum CategoryGroup: String, CaseIterable {
    case design = "设计"
    case hardDecoration = "硬装"
    case mainMaterials = "主材"
    case softDecoration = "软装"
    case other = "其他"
}

// MARK: - Payment Type
enum PaymentType: String, Codable, CaseIterable {
    case full = "full"          // 全款
    case deposit = "deposit"    // 定金
    case progress = "progress"  // 进度款
    case final = "final"        // 尾款

    var displayName: String {
        switch self {
        case .full: return "全款"
        case .deposit: return "定金"
        case .progress: return "进度款"
        case .final: return "尾款"
        }
    }
}
```

```swift
// Core/Database/Models/Phase.swift

import Foundation
import SwiftData

@Model
final class Phase {
    // MARK: - Properties
    var id: UUID
    var type: PhaseType
    var name: String
    var order: Int
    var plannedStartDate: Date?
    var plannedEndDate: Date?
    var actualStartDate: Date?
    var actualEndDate: Date?
    var status: PhaseStatus
    var notes: String

    // MARK: - Relationships
    var project: Project?

    @Relationship(deleteRule: .cascade, inverse: \Task.phase)
    var tasks: [Task] = []

    // MARK: - Computed Properties
    var progress: Double {
        guard !tasks.isEmpty else { return status == .completed ? 1.0 : 0.0 }
        let completedCount = tasks.filter { $0.status == .completed }.count
        return Double(completedCount) / Double(tasks.count)
    }

    var isDelayed: Bool {
        guard let planned = plannedEndDate else { return false }
        if status == .completed {
            guard let actual = actualEndDate else { return false }
            return actual > planned
        }
        return Date() > planned && status != .completed
    }

    // MARK: - Initialization
    init(type: PhaseType, order: Int) {
        self.id = UUID()
        self.type = type
        self.name = type.displayName
        self.order = order
        self.status = .notStarted
        self.notes = ""
    }
}

// MARK: - Phase Type
enum PhaseType: String, Codable, CaseIterable {
    case preparation = "preparation"    // 前期准备
    case demolition = "demolition"      // 拆改阶段
    case hydropower = "hydropower"      // 水电改造
    case masonry = "masonry"            // 泥瓦工程
    case carpentry = "carpentry"        // 木工工程
    case painting = "painting"          // 油漆工程
    case installation = "installation"  // 安装阶段
    case softDecoration = "soft"        // 软装入场
    case cleaning = "cleaning"          // 保洁验收
    case ventilation = "ventilation"    // 通风入住

    var displayName: String {
        switch self {
        case .preparation: return "前期准备"
        case .demolition: return "拆改阶段"
        case .hydropower: return "水电改造"
        case .masonry: return "泥瓦工程"
        case .carpentry: return "木工工程"
        case .painting: return "油漆工程"
        case .installation: return "安装阶段"
        case .softDecoration: return "软装入场"
        case .cleaning: return "保洁验收"
        case .ventilation: return "通风入住"
        }
    }

    var order: Int {
        switch self {
        case .preparation: return 1
        case .demolition: return 2
        case .hydropower: return 3
        case .masonry: return 4
        case .carpentry: return 5
        case .painting: return 6
        case .installation: return 7
        case .softDecoration: return 8
        case .cleaning: return 9
        case .ventilation: return 10
        }
    }

    // 默认任务模板
    var defaultTasks: [String] {
        switch self {
        case .preparation:
            return ["量房", "确定设计方案", "签订合同", "办理施工许可"]
        case .demolition:
            return ["拆除旧装修", "砸墙改造", "清理垃圾", "验收墙体"]
        case .hydropower:
            return ["水电定位", "开槽布管", "电线穿管", "水电验收", "拍照留档"]
        case .masonry:
            return ["防水施工", "防水验收", "贴瓷砖", "地面找平"]
        case .carpentry:
            return ["吊顶安装", "背景墙制作", "定制柜体安装"]
        case .painting:
            return ["墙面找平", "刮腻子", "刷底漆", "刷面漆"]
        case .installation:
            return ["橱柜安装", "木门安装", "地板安装", "开关面板安装", "灯具安装", "卫浴安装"]
        case .softDecoration:
            return ["家具进场", "家电进场", "窗帘安装", "软装布置"]
        case .cleaning:
            return ["开荒保洁", "全屋验收", "整理收纳"]
        case .ventilation:
            return ["通风散味", "空气检测", "正式入住"]
        }
    }
}

// MARK: - Phase Status
enum PhaseStatus: String, Codable {
    case notStarted = "not_started"
    case inProgress = "in_progress"
    case completed = "completed"
    case paused = "paused"

    var displayName: String {
        switch self {
        case .notStarted: return "未开始"
        case .inProgress: return "进行中"
        case .completed: return "已完成"
        case .paused: return "已暂停"
        }
    }
}
```

```swift
// Core/Database/Models/Task.swift

import Foundation
import SwiftData

@Model
final class Task {
    // MARK: - Properties
    var id: UUID
    var title: String
    var taskDescription: String
    var status: TaskStatus
    var priority: TaskPriority
    var dueDate: Date?
    var completedAt: Date?
    var assignee: String?
    var notes: String
    var photos: [Data]
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Relationships
    var phase: Phase?
    var contact: Contact?   // 负责人

    // MARK: - Initialization
    init(title: String, priority: TaskPriority = .medium) {
        self.id = UUID()
        self.title = title
        self.taskDescription = ""
        self.status = .pending
        self.priority = priority
        self.notes = ""
        self.photos = []
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Task Status
enum TaskStatus: String, Codable, CaseIterable {
    case pending = "pending"        // 待开始
    case inProgress = "in_progress" // 进行中
    case completed = "completed"    // 已完成
    case blocked = "blocked"        // 有问题

    var displayName: String {
        switch self {
        case .pending: return "待开始"
        case .inProgress: return "进行中"
        case .completed: return "已完成"
        case .blocked: return "有问题"
        }
    }

    var icon: String {
        switch self {
        case .pending: return "circle"
        case .inProgress: return "circle.lefthalf.filled"
        case .completed: return "checkmark.circle.fill"
        case .blocked: return "exclamationmark.circle.fill"
        }
    }
}

// MARK: - Task Priority
enum TaskPriority: String, Codable, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"

    var displayName: String {
        switch self {
        case .low: return "低"
        case .medium: return "中"
        case .high: return "高"
        }
    }
}
```

```swift
// Core/Database/Models/Material.swift

import Foundation
import SwiftData

@Model
final class Material {
    // MARK: - Properties
    var id: UUID
    var name: String
    var brand: String?
    var model: String?
    var specification: String?
    var unitPrice: Decimal
    var quantity: Double
    var unit: String                    // 单位：个、平米、米等
    var room: RoomType?
    var category: MaterialCategory
    var status: MaterialStatus
    var purchaseDate: Date?
    var deliveryDate: Date?
    var notes: String
    var photos: [Data]
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Relationships
    var project: Project?
    var supplier: Contact?

    // MARK: - Computed Properties
    var totalPrice: Decimal {
        unitPrice * Decimal(quantity)
    }

    // MARK: - Initialization
    init(
        name: String,
        category: MaterialCategory,
        unitPrice: Decimal = 0,
        quantity: Double = 1,
        unit: String = "个"
    ) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.unitPrice = unitPrice
        self.quantity = quantity
        self.unit = unit
        self.status = .toBuy
        self.notes = ""
        self.photos = []
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Material Category
enum MaterialCategory: String, Codable, CaseIterable {
    case tile = "tile"              // 瓷砖
    case flooring = "flooring"      // 地板
    case paint = "paint"            // 油漆涂料
    case door = "door"              // 门
    case window = "window"          // 窗
    case cabinet = "cabinet"        // 橱柜
    case bathroom = "bathroom"      // 卫浴
    case lighting = "lighting"      // 灯具
    case hardware = "hardware"      // 五金
    case pipe = "pipe"              // 水管
    case wire = "wire"              // 电线
    case other = "other"            // 其他

    var displayName: String {
        switch self {
        case .tile: return "瓷砖"
        case .flooring: return "地板"
        case .paint: return "油漆涂料"
        case .door: return "门"
        case .window: return "窗"
        case .cabinet: return "橱柜"
        case .bathroom: return "卫浴"
        case .lighting: return "灯具"
        case .hardware: return "五金"
        case .pipe: return "水管"
        case .wire: return "电线"
        case .other: return "其他"
        }
    }
}

// MARK: - Material Status
enum MaterialStatus: String, Codable, CaseIterable {
    case toBuy = "to_buy"           // 待购买
    case ordered = "ordered"        // 已下单
    case delivered = "delivered"    // 已到货
    case installed = "installed"    // 已安装

    var displayName: String {
        switch self {
        case .toBuy: return "待购买"
        case .ordered: return "已下单"
        case .delivered: return "已到货"
        case .installed: return "已安装"
        }
    }
}

// MARK: - Room Type
enum RoomType: String, Codable, CaseIterable {
    case livingRoom = "living_room"
    case bedroom = "bedroom"
    case kitchen = "kitchen"
    case bathroom = "bathroom"
    case balcony = "balcony"
    case study = "study"
    case diningRoom = "dining_room"
    case hallway = "hallway"
    case other = "other"

    var displayName: String {
        switch self {
        case .livingRoom: return "客厅"
        case .bedroom: return "卧室"
        case .kitchen: return "厨房"
        case .bathroom: return "卫生间"
        case .balcony: return "阳台"
        case .study: return "书房"
        case .diningRoom: return "餐厅"
        case .hallway: return "走廊"
        case .other: return "其他"
        }
    }
}
```

```swift
// Core/Database/Models/Contact.swift

import Foundation
import SwiftData

@Model
final class Contact {
    // MARK: - Properties
    var id: UUID
    var name: String
    var role: ContactRole
    var company: String?
    var phone: String?
    var wechat: String?
    var email: String?
    var address: String?
    var rating: Int?                    // 1-5 评分
    var notes: String
    var avatar: Data?
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Relationships
    var project: Project?

    @Relationship(inverse: \Expense.contact)
    var expenses: [Expense] = []

    @Relationship(inverse: \Material.supplier)
    var materials: [Material] = []

    // MARK: - Computed Properties
    var totalSpent: Decimal {
        expenses.reduce(0) { $0 + $1.amount }
    }

    // MARK: - Initialization
    init(name: String, role: ContactRole) {
        self.id = UUID()
        self.name = name
        self.role = role
        self.notes = ""
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Contact Role
enum ContactRole: String, Codable, CaseIterable {
    case company = "company"            // 装修公司
    case foreman = "foreman"            // 工长
    case designer = "designer"          // 设计师
    case electrician = "electrician"    // 电工
    case plumber = "plumber"            // 水工
    case tiler = "tiler"                // 瓦工
    case carpenter = "carpenter"        // 木工
    case painter = "painter"            // 油漆工
    case supplier = "supplier"          // 材料供应商
    case other = "other"                // 其他

    var displayName: String {
        switch self {
        case .company: return "装修公司"
        case .foreman: return "工长"
        case .designer: return "设计师"
        case .electrician: return "电工"
        case .plumber: return "水工"
        case .tiler: return "瓦工"
        case .carpenter: return "木工"
        case .painter: return "油漆工"
        case .supplier: return "供应商"
        case .other: return "其他"
        }
    }

    var icon: String {
        switch self {
        case .company: return "building.2"
        case .foreman: return "person.badge.key"
        case .designer: return "pencil.and.ruler"
        case .electrician: return "bolt"
        case .plumber: return "drop"
        case .tiler: return "square.grid.3x3"
        case .carpenter: return "hammer"
        case .painter: return "paintbrush"
        case .supplier: return "shippingbox"
        case .other: return "person"
        }
    }
}
```

```swift
// Core/Database/Models/JournalEntry.swift

import Foundation
import SwiftData

@Model
final class JournalEntry {
    // MARK: - Properties
    var id: UUID
    var date: Date
    var title: String
    var content: String
    var photos: [Data]
    var videos: [URL]?
    var mood: JournalMood?
    var weather: String?
    var phaseName: String?              // 记录时所处阶段
    var isHighlight: Bool               // 是否为重要节点
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Relationships
    var project: Project?

    // MARK: - Initialization
    init(title: String = "", content: String = "") {
        self.id = UUID()
        self.date = Date()
        self.title = title
        self.content = content
        self.photos = []
        self.isHighlight = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Journal Mood
enum JournalMood: String, Codable, CaseIterable {
    case happy = "happy"
    case neutral = "neutral"
    case worried = "worried"
    case frustrated = "frustrated"

    var displayName: String {
        switch self {
        case .happy: return "开心"
        case .neutral: return "平静"
        case .worried: return "担忧"
        case .frustrated: return "烦躁"
        }
    }

    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .neutral: return "😐"
        case .worried: return "😟"
        case .frustrated: return "😤"
        }
    }
}
```

```swift
// Core/Database/Models/Document.swift

import Foundation
import SwiftData

@Model
final class Document {
    // MARK: - Properties
    var id: UUID
    var type: DocumentType
    var title: String
    var fileData: Data?
    var fileURL: URL?
    var thumbnailData: Data?
    var keyInfo: DocumentKeyInfo?       // 提取的关键信息
    var notes: String
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Relationships
    var project: Project?
    var contact: Contact?               // 关联的商家

    // MARK: - Initialization
    init(type: DocumentType, title: String) {
        self.id = UUID()
        self.type = type
        self.title = title
        self.notes = ""
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Document Type
enum DocumentType: String, Codable, CaseIterable {
    case contract = "contract"          // 合同
    case quotation = "quotation"        // 报价单
    case floorPlan = "floor_plan"       // 户型图
    case designDraft = "design_draft"   // 设计图
    case receipt = "receipt"            // 收据
    case warranty = "warranty"          // 保修卡
    case other = "other"                // 其他

    var displayName: String {
        switch self {
        case .contract: return "合同"
        case .quotation: return "报价单"
        case .floorPlan: return "户型图"
        case .designDraft: return "设计图"
        case .receipt: return "收据"
        case .warranty: return "保修卡"
        case .other: return "其他"
        }
    }

    var icon: String {
        switch self {
        case .contract: return "doc.text.fill"
        case .quotation: return "list.clipboard.fill"
        case .floorPlan: return "square.split.2x2"
        case .designDraft: return "paintpalette.fill"
        case .receipt: return "receipt.fill"
        case .warranty: return "checkmark.seal.fill"
        case .other: return "doc.fill"
        }
    }
}

// MARK: - Document Key Info
struct DocumentKeyInfo: Codable {
    var totalAmount: Decimal?           // 合同金额
    var signDate: Date?                 // 签订日期
    var startDate: Date?                // 开工日期
    var endDate: Date?                  // 完工日期
    var paymentSchedule: [PaymentNode]? // 付款节点
    var partyA: String?                 // 甲方
    var partyB: String?                 // 乙方
}

struct PaymentNode: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String                    // 节点名称
    var percentage: Double              // 付款比例
    var amount: Decimal?                // 付款金额
    var dueDate: Date?                  // 应付日期
    var isPaid: Bool = false            // 是否已付
    var paidDate: Date?                 // 实付日期
}
```

---

## 4. 模块详细设计

### 4.1 预算管理模块

#### 4.1.1 功能流程图

```
┌─────────────────────────────────────────────────────────────────┐
│                      Budget Dashboard                            │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  总预算: ¥200,000    已支出: ¥85,000    剩余: ¥115,000    │  │
│  │  ████████████░░░░░░░░░░░░░░░░░░░░  42.5%                  │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐               │
│  │   硬装      │ │   主材      │ │   软装      │   [+ 记一笔]  │
│  │  ¥45,000   │ │  ¥25,000   │ │  ¥15,000   │               │
│  └─────────────┘ └─────────────┘ └─────────────┘               │
│                                                                  │
│  最近支出                                                        │
│  ├── 瓷砖定金 - ¥5,000 - 2024/01/15                            │
│  ├── 水电材料 - ¥3,200 - 2024/01/14                            │
│  └── 设计费   - ¥8,000 - 2024/01/10                            │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Add Expense Flow                            │
│                                                                  │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐     │
│  │ 输入金额 │───▶│ 选择分类 │───▶│ 添加备注 │───▶│ 拍照上传 │     │
│  └─────────┘    └─────────┘    └─────────┘    └─────────┘     │
│                                                      │          │
│                                                      ▼          │
│                                               ┌─────────┐       │
│                                               │   保存   │       │
│                                               └─────────┘       │
└─────────────────────────────────────────────────────────────────┘
```

#### 4.1.2 ViewModel 设计

```swift
// Features/Budget/ViewModels/BudgetDashboardViewModel.swift

import Foundation
import SwiftUI
import SwiftData

@MainActor
final class BudgetDashboardViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published private(set) var budget: Budget?
    @Published private(set) var recentExpenses: [Expense] = []
    @Published private(set) var categoryStats: [CategoryStat] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: AppError?

    // MARK: - Dependencies
    private let budgetRepository: BudgetRepository
    private let calculateBudgetUseCase: CalculateBudgetUseCase

    // MARK: - Computed Properties
    var totalBudget: Decimal {
        budget?.totalAmount ?? 0
    }

    var totalSpent: Decimal {
        budget?.totalSpent ?? 0
    }

    var remaining: Decimal {
        budget?.remaining ?? 0
    }

    var usagePercentage: Double {
        budget?.usagePercentage ?? 0
    }

    var isOverBudget: Bool {
        budget?.isOverBudget ?? false
    }

    var isWarning: Bool {
        budget?.isWarning ?? false
    }

    // MARK: - Initialization
    init(
        budgetRepository: BudgetRepository,
        calculateBudgetUseCase: CalculateBudgetUseCase
    ) {
        self.budgetRepository = budgetRepository
        self.calculateBudgetUseCase = calculateBudgetUseCase
    }

    // MARK: - Public Methods
    func loadData(for projectId: UUID) async {
        isLoading = true
        error = nil

        do {
            budget = try await budgetRepository.getBudget(for: projectId)
            recentExpenses = try await budgetRepository.getRecentExpenses(
                for: projectId,
                limit: 10
            )
            categoryStats = await calculateBudgetUseCase.getCategoryStats(
                for: projectId
            )
        } catch {
            self.error = AppError.dataLoadFailed(error)
        }

        isLoading = false
    }

    func deleteExpense(_ expense: Expense) async {
        do {
            try await budgetRepository.deleteExpense(expense)
            // 重新加载数据
            if let projectId = expense.budget?.project?.id {
                await loadData(for: projectId)
            }
        } catch {
            self.error = AppError.deleteFailed(error)
        }
    }
}

// MARK: - Category Stat
struct CategoryStat: Identifiable {
    let id = UUID()
    let category: ExpenseCategory
    let budgeted: Decimal
    let spent: Decimal

    var percentage: Double {
        guard budgeted > 0 else { return 0 }
        return Double(truncating: (spent / budgeted) as NSNumber)
    }

    var isOverBudget: Bool {
        spent > budgeted
    }
}
```

```swift
// Features/Budget/ViewModels/AddExpenseViewModel.swift

import Foundation
import SwiftUI
import PhotosUI

@MainActor
final class AddExpenseViewModel: ObservableObject {

    // MARK: - Form State
    @Published var amount: String = ""
    @Published var selectedCategory: ExpenseCategory = .other
    @Published var note: String = ""
    @Published var date: Date = Date()
    @Published var paymentType: PaymentType = .full
    @Published var merchantName: String = ""
    @Published var selectedPhotos: [PhotosPickerItem] = []
    @Published var photoData: [Data] = []

    // MARK: - UI State
    @Published var isLoading = false
    @Published var error: AppError?
    @Published var showSuccessAlert = false

    // MARK: - Dependencies
    private let recordExpenseUseCase: RecordExpenseUseCase
    private let projectId: UUID

    // MARK: - Validation
    var isValid: Bool {
        guard let amountDecimal = Decimal(string: amount),
              amountDecimal > 0 else {
            return false
        }
        return true
    }

    var amountDecimal: Decimal? {
        Decimal(string: amount)
    }

    // MARK: - Initialization
    init(projectId: UUID, recordExpenseUseCase: RecordExpenseUseCase) {
        self.projectId = projectId
        self.recordExpenseUseCase = recordExpenseUseCase
    }

    // MARK: - Actions
    func save() async -> Bool {
        guard isValid, let amount = amountDecimal else {
            error = .validationFailed("请输入有效金额")
            return false
        }

        isLoading = true
        error = nil

        do {
            // 处理照片
            await loadPhotos()

            // 创建支出记录
            let expense = Expense(
                amount: amount,
                category: selectedCategory,
                note: note,
                date: date,
                paymentType: paymentType
            )
            expense.merchantName = merchantName.isEmpty ? nil : merchantName
            expense.receiptData = photoData

            try await recordExpenseUseCase.execute(
                expense: expense,
                projectId: projectId
            )

            showSuccessAlert = true
            isLoading = false
            return true

        } catch {
            self.error = .saveFailed(error)
            isLoading = false
            return false
        }
    }

    func reset() {
        amount = ""
        selectedCategory = .other
        note = ""
        date = Date()
        paymentType = .full
        merchantName = ""
        selectedPhotos = []
        photoData = []
    }

    // MARK: - Private Methods
    private func loadPhotos() async {
        photoData = []
        for item in selectedPhotos {
            if let data = try? await item.loadTransferable(type: Data.self) {
                photoData.append(data)
            }
        }
    }
}
```

#### 4.1.3 View 设计

```swift
// Features/Budget/Views/BudgetDashboardView.swift

import SwiftUI
import SwiftData
import Charts

struct BudgetDashboardView: View {
    @Environment(\.dependencies) private var dependencies
    @StateObject private var viewModel: BudgetDashboardViewModel

    let projectId: UUID

    init(projectId: UUID) {
        self.projectId = projectId
        // ViewModel 初始化在 onAppear 中完成
        _viewModel = StateObject(wrappedValue: BudgetDashboardViewModel(
            budgetRepository: DependencyContainer.shared.budgetRepository,
            calculateBudgetUseCase: DependencyContainer.shared.makeCalculateBudgetUseCase()
        ))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 总预算卡片
                budgetOverviewCard

                // 分类预算
                categoryBudgetSection

                // 最近支出
                recentExpensesSection
            }
            .padding()
        }
        .navigationTitle("预算管理")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink {
                    AddExpenseView(projectId: projectId)
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
        .task {
            await viewModel.loadData(for: projectId)
        }
        .refreshable {
            await viewModel.loadData(for: projectId)
        }
    }

    // MARK: - Subviews

    private var budgetOverviewCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("总预算")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(viewModel.totalBudget.formatted(.currency(code: "CNY")))
                        .font(.title2.bold())
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("剩余")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(viewModel.remaining.formatted(.currency(code: "CNY")))
                        .font(.title2.bold())
                        .foregroundStyle(viewModel.isOverBudget ? .red : .primary)
                }
            }

            // 进度条
            ProgressView(value: min(viewModel.usagePercentage, 1.0)) {
                HStack {
                    Text("已支出: \(viewModel.totalSpent.formatted(.currency(code: "CNY")))")
                    Spacer()
                    Text("\(viewModel.usagePercentage * 100, specifier: "%.1f")%")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .tint(progressColor)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var categoryBudgetSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("分类预算")
                .font(.headline)

            // 饼图
            Chart(viewModel.categoryStats) { stat in
                SectorMark(
                    angle: .value("金额", stat.spent),
                    innerRadius: .ratio(0.6),
                    angularInset: 1
                )
                .foregroundStyle(by: .value("分类", stat.category.displayName))
            }
            .frame(height: 200)

            // 分类列表
            ForEach(viewModel.categoryStats) { stat in
                CategoryBudgetRow(stat: stat)
            }
        }
    }

    private var recentExpensesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("最近支出")
                    .font(.headline)
                Spacer()
                NavigationLink("查看全部") {
                    ExpenseListView(projectId: projectId)
                }
                .font(.subheadline)
            }

            if viewModel.recentExpenses.isEmpty {
                EmptyStateView(
                    icon: "creditcard",
                    message: "还没有支出记录"
                )
            } else {
                ForEach(viewModel.recentExpenses) { expense in
                    ExpenseRow(expense: expense)
                }
            }
        }
    }

    private var progressColor: Color {
        if viewModel.isOverBudget {
            return .red
        } else if viewModel.isWarning {
            return .orange
        }
        return .green
    }
}
```

### 4.2 进度管理模块

#### 4.2.1 甘特图组件设计

```swift
// Features/Schedule/Components/GanttChartView.swift

import SwiftUI

struct GanttChartView: View {
    let phases: [Phase]
    let startDate: Date
    let endDate: Date

    @State private var selectedPhase: Phase?

    private let rowHeight: CGFloat = 44
    private let dayWidth: CGFloat = 20

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            HStack(alignment: .top, spacing: 0) {
                // 左侧阶段名称列表
                phaseTitleColumn

                // 右侧甘特图区域
                ganttArea
            }
        }
    }

    private var phaseTitleColumn: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 表头
            Text("阶段")
                .font(.caption.bold())
                .frame(width: 100, height: 30)
                .background(Color(.systemGray6))

            // 阶段名称
            ForEach(phases.sorted(by: { $0.order < $1.order })) { phase in
                Text(phase.name)
                    .font(.subheadline)
                    .frame(width: 100, height: rowHeight, alignment: .leading)
                    .padding(.horizontal, 8)
                    .background(selectedPhase?.id == phase.id ? Color.accentColor.opacity(0.1) : .clear)
                    .onTapGesture {
                        selectedPhase = phase
                    }
            }
        }
        .background(Color(.systemBackground))
    }

    private var ganttArea: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 日期表头
            dateHeader

            // 甘特条
            ForEach(phases.sorted(by: { $0.order < $1.order })) { phase in
                ganttBar(for: phase)
            }
        }
    }

    private var dateHeader: some View {
        HStack(spacing: 0) {
            ForEach(dateRange, id: \.self) { date in
                VStack(spacing: 2) {
                    Text(date.formatted(.dateTime.day()))
                        .font(.caption2)
                    Text(date.formatted(.dateTime.month(.abbreviated)))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(width: dayWidth, height: 30)
                .background(isWeekend(date) ? Color(.systemGray6) : .clear)
            }
        }
    }

    private func ganttBar(for phase: Phase) -> some View {
        GeometryReader { geometry in
            if let start = phase.plannedStartDate,
               let end = phase.plannedEndDate {
                let startOffset = daysBetween(startDate, start) * dayWidth
                let duration = daysBetween(start, end) * dayWidth

                RoundedRectangle(cornerRadius: 4)
                    .fill(phaseColor(for: phase))
                    .frame(width: max(duration, dayWidth), height: rowHeight - 8)
                    .offset(x: startOffset, y: 4)
                    .overlay(alignment: .leading) {
                        // 实际进度
                        if phase.progress > 0 {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.green.opacity(0.7))
                                .frame(width: max(duration * phase.progress, 4), height: rowHeight - 8)
                                .offset(x: startOffset, y: 4)
                        }
                    }
            }
        }
        .frame(height: rowHeight)
    }

    // MARK: - Helper Methods

    private var dateRange: [Date] {
        var dates: [Date] = []
        var current = startDate
        while current <= endDate {
            dates.append(current)
            current = Calendar.current.date(byAdding: .day, value: 1, to: current)!
        }
        return dates
    }

    private func daysBetween(_ from: Date, _ to: Date) -> CGFloat {
        let days = Calendar.current.dateComponents([.day], from: from, to: to).day ?? 0
        return CGFloat(max(days, 0))
    }

    private func isWeekend(_ date: Date) -> Bool {
        let weekday = Calendar.current.component(.weekday, from: date)
        return weekday == 1 || weekday == 7
    }

    private func phaseColor(for phase: Phase) -> Color {
        switch phase.status {
        case .completed: return .green.opacity(0.3)
        case .inProgress: return .blue.opacity(0.3)
        case .paused: return .orange.opacity(0.3)
        case .notStarted: return .gray.opacity(0.3)
        }
    }
}
```

---

## 5. 数据存储方案

### 5.1 SwiftData 配置

```swift
// Core/Database/ModelContainer+Extension.swift

import SwiftData
import Foundation

extension ModelContainer {

    /// 创建生产环境的 ModelContainer
    static func createProductionContainer() throws -> ModelContainer {
        let schema = Schema([
            Project.self,
            Budget.self,
            Expense.self,
            Phase.self,
            Task.self,
            Material.self,
            Document.self,
            Contact.self,
            JournalEntry.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .private("iCloud.com.yourcompany.panda")
        )

        return try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
    }

    /// 创建测试环境的 ModelContainer（内存存储）
    static func createTestContainer() throws -> ModelContainer {
        let schema = Schema([
            Project.self,
            Budget.self,
            Expense.self,
            Phase.self,
            Task.self,
            Material.self,
            Document.self,
            Contact.self,
            JournalEntry.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        return try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
    }

    /// 创建预览环境的 ModelContainer
    @MainActor
    static var preview: ModelContainer = {
        do {
            let container = try createTestContainer()

            // 插入示例数据
            let context = container.mainContext

            let project = Project(name: "我的新家", address: "北京市朝阳区", area: 120)
            context.insert(project)

            let budget = Budget(totalAmount: 200000)
            budget.project = project
            context.insert(budget)

            // 添加示例支出
            let expenses = [
                Expense(amount: 8000, category: .design, note: "设计费"),
                Expense(amount: 15000, category: .demolition, note: "拆改工程"),
                Expense(amount: 12000, category: .hydropower, note: "水电改造"),
            ]
            expenses.forEach { expense in
                expense.budget = budget
                context.insert(expense)
            }

            try context.save()

            return container
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }()
}
```

### 5.2 Repository 模式

```swift
// Core/Repositories/BaseRepository.swift

import Foundation
import SwiftData

protocol Repository {
    associatedtype Entity: PersistentModel

    func getAll() async throws -> [Entity]
    func getById(_ id: UUID) async throws -> Entity?
    func save(_ entity: Entity) async throws
    func delete(_ entity: Entity) async throws
}

@MainActor
class BaseRepository<Entity: PersistentModel>: Repository {

    let modelContainer: ModelContainer

    var context: ModelContext {
        modelContainer.mainContext
    }

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    func getAll() async throws -> [Entity] {
        let descriptor = FetchDescriptor<Entity>()
        return try context.fetch(descriptor)
    }

    func getById(_ id: UUID) async throws -> Entity? {
        // 子类实现具体查询逻辑
        fatalError("Subclass must implement")
    }

    func save(_ entity: Entity) async throws {
        context.insert(entity)
        try context.save()
    }

    func delete(_ entity: Entity) async throws {
        context.delete(entity)
        try context.save()
    }
}
```

```swift
// Core/Repositories/BudgetRepository.swift

import Foundation
import SwiftData

@MainActor
final class BudgetRepository: BaseRepository<Budget> {

    func getBudget(for projectId: UUID) async throws -> Budget? {
        let descriptor = FetchDescriptor<Budget>(
            predicate: #Predicate { budget in
                budget.project?.id == projectId
            }
        )
        return try context.fetch(descriptor).first
    }

    func getRecentExpenses(for projectId: UUID, limit: Int) async throws -> [Expense] {
        var descriptor = FetchDescriptor<Expense>(
            predicate: #Predicate { expense in
                expense.budget?.project?.id == projectId
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return try context.fetch(descriptor)
    }

    func getExpenses(
        for projectId: UUID,
        category: ExpenseCategory? = nil,
        dateRange: ClosedRange<Date>? = nil
    ) async throws -> [Expense] {
        var descriptor = FetchDescriptor<Expense>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        // 构建谓词
        if let category = category, let range = dateRange {
            descriptor.predicate = #Predicate { expense in
                expense.budget?.project?.id == projectId &&
                expense.category == category &&
                expense.date >= range.lowerBound &&
                expense.date <= range.upperBound
            }
        } else if let category = category {
            descriptor.predicate = #Predicate { expense in
                expense.budget?.project?.id == projectId &&
                expense.category == category
            }
        } else if let range = dateRange {
            descriptor.predicate = #Predicate { expense in
                expense.budget?.project?.id == projectId &&
                expense.date >= range.lowerBound &&
                expense.date <= range.upperBound
            }
        } else {
            descriptor.predicate = #Predicate { expense in
                expense.budget?.project?.id == projectId
            }
        }

        return try context.fetch(descriptor)
    }

    func deleteExpense(_ expense: Expense) async throws {
        context.delete(expense)
        try context.save()
    }

    func updateBudget(_ budget: Budget, totalAmount: Decimal) async throws {
        budget.totalAmount = totalAmount
        budget.updatedAt = Date()
        try context.save()
    }
}
```

### 5.3 文件存储策略

```swift
// Core/Services/FileStorageService.swift

import Foundation
import UIKit

final class FileStorageService {

    static let shared = FileStorageService()

    private let fileManager = FileManager.default

    // MARK: - Directories

    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private var photosDirectory: URL {
        documentsDirectory.appendingPathComponent("Photos", isDirectory: true)
    }

    private var documentsStorageDirectory: URL {
        documentsDirectory.appendingPathComponent("Documents", isDirectory: true)
    }

    // MARK: - Initialization

    private init() {
        createDirectoriesIfNeeded()
    }

    private func createDirectoriesIfNeeded() {
        try? fileManager.createDirectory(at: photosDirectory, withIntermediateDirectories: true)
        try? fileManager.createDirectory(at: documentsStorageDirectory, withIntermediateDirectories: true)
    }

    // MARK: - Photo Storage

    /// 保存照片并返回文件名
    func savePhoto(_ imageData: Data, for entityId: UUID) throws -> String {
        let fileName = "\(entityId.uuidString)_\(Date().timeIntervalSince1970).jpg"
        let fileURL = photosDirectory.appendingPathComponent(fileName)

        // 压缩图片
        if let image = UIImage(data: imageData),
           let compressedData = image.jpegData(compressionQuality: 0.7) {
            try compressedData.write(to: fileURL)
        } else {
            try imageData.write(to: fileURL)
        }

        return fileName
    }

    /// 加载照片
    func loadPhoto(fileName: String) -> Data? {
        let fileURL = photosDirectory.appendingPathComponent(fileName)
        return try? Data(contentsOf: fileURL)
    }

    /// 删除照片
    func deletePhoto(fileName: String) throws {
        let fileURL = photosDirectory.appendingPathComponent(fileName)
        try fileManager.removeItem(at: fileURL)
    }

    // MARK: - Document Storage

    /// 保存文档
    func saveDocument(_ data: Data, originalFileName: String, for entityId: UUID) throws -> String {
        let fileExtension = (originalFileName as NSString).pathExtension
        let fileName = "\(entityId.uuidString).\(fileExtension)"
        let fileURL = documentsStorageDirectory.appendingPathComponent(fileName)

        try data.write(to: fileURL)
        return fileName
    }

    /// 加载文档
    func loadDocument(fileName: String) -> Data? {
        let fileURL = documentsStorageDirectory.appendingPathComponent(fileName)
        return try? Data(contentsOf: fileURL)
    }

    // MARK: - Cleanup

    /// 清理未使用的文件
    func cleanupOrphanedFiles(usedFileNames: Set<String>) throws {
        let photoFiles = try fileManager.contentsOfDirectory(at: photosDirectory, includingPropertiesForKeys: nil)

        for fileURL in photoFiles {
            let fileName = fileURL.lastPathComponent
            if !usedFileNames.contains(fileName) {
                try fileManager.removeItem(at: fileURL)
            }
        }
    }

    // MARK: - Storage Info

    var totalStorageUsed: Int64 {
        let photosSize = directorySize(photosDirectory)
        let docsSize = directorySize(documentsStorageDirectory)
        return photosSize + docsSize
    }

    private func directorySize(_ url: URL) -> Int64 {
        guard let files = try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }

        return files.reduce(0) { total, fileURL in
            let size = (try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
            return total + Int64(size)
        }
    }
}
```

---

## 6. 云同步策略

### 6.1 CloudKit 配置

```swift
// Core/Services/CloudSyncService.swift

import Foundation
import SwiftData
import CloudKit

@MainActor
final class CloudSyncService: ObservableObject {

    // MARK: - Published Properties
    @Published private(set) var syncStatus: SyncStatus = .idle
    @Published private(set) var lastSyncDate: Date?
    @Published private(set) var pendingChanges: Int = 0

    // MARK: - Properties
    private let modelContainer: ModelContainer
    private let cloudContainer: CKContainer

    // MARK: - Initialization
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.cloudContainer = CKContainer(identifier: "iCloud.com.yourcompany.panda")

        setupNotifications()
    }

    // MARK: - Public Methods

    /// 检查 iCloud 状态
    func checkAccountStatus() async -> CKAccountStatus {
        do {
            return try await cloudContainer.accountStatus()
        } catch {
            return .couldNotDetermine
        }
    }

    /// 手动触发同步
    func syncNow() async {
        syncStatus = .syncing

        do {
            // SwiftData 与 CloudKit 自动同步，这里只需触发保存
            try modelContainer.mainContext.save()
            lastSyncDate = Date()
            syncStatus = .idle
        } catch {
            syncStatus = .error(error.localizedDescription)
        }
    }

    /// 获取同步冲突
    func getConflicts() async -> [SyncConflict] {
        // CloudKit 冲突处理逻辑
        return []
    }

    /// 解决冲突
    func resolveConflict(_ conflict: SyncConflict, resolution: ConflictResolution) async {
        // 冲突解决逻辑
    }

    // MARK: - Private Methods

    private func setupNotifications() {
        // 监听数据变化
        NotificationCenter.default.addObserver(
            forName: ModelContext.didSave,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleDataChange()
        }
    }

    private func handleDataChange() {
        // 数据变化处理
        Task {
            await syncNow()
        }
    }
}

// MARK: - Supporting Types

enum SyncStatus: Equatable {
    case idle
    case syncing
    case error(String)

    var description: String {
        switch self {
        case .idle: return "已同步"
        case .syncing: return "同步中..."
        case .error(let message): return "同步失败: \(message)"
        }
    }
}

struct SyncConflict: Identifiable {
    let id: UUID
    let entityType: String
    let localVersion: Any
    let remoteVersion: Any
    let timestamp: Date
}

enum ConflictResolution {
    case keepLocal
    case keepRemote
    case merge
}
```

### 6.2 离线支持策略

```swift
// Core/Services/OfflineSupportService.swift

import Foundation
import Network

@MainActor
final class OfflineSupportService: ObservableObject {

    // MARK: - Published Properties
    @Published private(set) var isOnline = true
    @Published private(set) var pendingOperations: [PendingOperation] = []

    // MARK: - Properties
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    // MARK: - Initialization
    init() {
        startMonitoring()
        loadPendingOperations()
    }

    // MARK: - Network Monitoring

    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isOnline = path.status == .satisfied
                if path.status == .satisfied {
                    await self?.processPendingOperations()
                }
            }
        }
        monitor.start(queue: queue)
    }

    // MARK: - Pending Operations

    func addPendingOperation(_ operation: PendingOperation) {
        pendingOperations.append(operation)
        savePendingOperations()
    }

    private func processPendingOperations() async {
        guard isOnline else { return }

        for operation in pendingOperations {
            do {
                try await operation.execute()
                pendingOperations.removeAll { $0.id == operation.id }
            } catch {
                // 保留失败的操作，下次重试
                continue
            }
        }

        savePendingOperations()
    }

    private func loadPendingOperations() {
        // 从 UserDefaults 加载待处理操作
        if let data = UserDefaults.standard.data(forKey: "pendingOperations"),
           let operations = try? JSONDecoder().decode([PendingOperation].self, from: data) {
            pendingOperations = operations
        }
    }

    private func savePendingOperations() {
        if let data = try? JSONEncoder().encode(pendingOperations) {
            UserDefaults.standard.set(data, forKey: "pendingOperations")
        }
    }
}

// MARK: - Pending Operation

struct PendingOperation: Identifiable, Codable {
    let id: UUID
    let type: OperationType
    let entityId: UUID
    let data: Data
    let createdAt: Date

    func execute() async throws {
        // 执行操作逻辑
    }
}

enum OperationType: String, Codable {
    case create
    case update
    case delete
}
```

---

## 7. 安全性设计

### 7.1 数据加密

```swift
// Core/Services/SecurityService.swift

import Foundation
import CryptoKit
import Security

final class SecurityService {

    static let shared = SecurityService()

    private init() {}

    // MARK: - Keychain Operations

    /// 保存敏感数据到 Keychain
    func saveToKeychain(key: String, data: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        // 先删除旧数据
        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw SecurityError.keychainSaveFailed(status)
        }
    }

    /// 从 Keychain 读取数据
    func readFromKeychain(key: String) throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecItemNotFound {
            return nil
        }

        guard status == errSecSuccess else {
            throw SecurityError.keychainReadFailed(status)
        }

        return result as? Data
    }

    /// 从 Keychain 删除数据
    func deleteFromKeychain(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw SecurityError.keychainDeleteFailed(status)
        }
    }

    // MARK: - Data Encryption

    /// 使用对称密钥加密数据
    func encrypt(_ data: Data, with key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.seal(data, using: key)
        guard let combined = sealedBox.combined else {
            throw SecurityError.encryptionFailed
        }
        return combined
    }

    /// 解密数据
    func decrypt(_ encryptedData: Data, with key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
        return try AES.GCM.open(sealedBox, using: key)
    }

    /// 生成新的对称密钥
    func generateKey() -> SymmetricKey {
        SymmetricKey(size: .bits256)
    }

    // MARK: - Hash

    /// 计算数据的 SHA256 哈希
    func sha256(_ data: Data) -> String {
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Security Error

enum SecurityError: LocalizedError {
    case keychainSaveFailed(OSStatus)
    case keychainReadFailed(OSStatus)
    case keychainDeleteFailed(OSStatus)
    case encryptionFailed
    case decryptionFailed

    var errorDescription: String? {
        switch self {
        case .keychainSaveFailed(let status):
            return "Keychain 保存失败: \(status)"
        case .keychainReadFailed(let status):
            return "Keychain 读取失败: \(status)"
        case .keychainDeleteFailed(let status):
            return "Keychain 删除失败: \(status)"
        case .encryptionFailed:
            return "加密失败"
        case .decryptionFailed:
            return "解密失败"
        }
    }
}
```

### 7.2 隐私保护

```swift
// Core/Services/PrivacyService.swift

import Foundation
import LocalAuthentication

final class PrivacyService {

    static let shared = PrivacyService()

    private init() {}

    // MARK: - Biometric Authentication

    /// 检查生物识别是否可用
    func isBiometricAvailable() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    /// 生物识别类型
    var biometricType: BiometricType {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)

        switch context.biometryType {
        case .faceID: return .faceID
        case .touchID: return .touchID
        case .opticID: return .opticID
        default: return .none
        }
    }

    /// 验证生物识别
    func authenticateWithBiometrics(reason: String) async throws -> Bool {
        let context = LAContext()

        do {
            return try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
        } catch {
            throw PrivacyError.authenticationFailed(error)
        }
    }

    // MARK: - Data Export (脱敏)

    /// 导出时脱敏处理
    func sanitizeForExport<T: Encodable>(_ data: T) -> Data? {
        // 脱敏逻辑
        return try? JSONEncoder().encode(data)
    }

    /// 手机号脱敏
    func maskPhoneNumber(_ phone: String) -> String {
        guard phone.count >= 7 else { return phone }
        let prefix = phone.prefix(3)
        let suffix = phone.suffix(4)
        return "\(prefix)****\(suffix)"
    }
}

enum BiometricType {
    case faceID
    case touchID
    case opticID
    case none

    var displayName: String {
        switch self {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .opticID: return "Optic ID"
        case .none: return "无"
        }
    }
}

enum PrivacyError: LocalizedError {
    case authenticationFailed(Error)
    case biometricNotAvailable

    var errorDescription: String? {
        switch self {
        case .authenticationFailed(let error):
            return "认证失败: \(error.localizedDescription)"
        case .biometricNotAvailable:
            return "生物识别不可用"
        }
    }
}
```

---

## 8. 性能优化

### 8.1 图片加载优化

```swift
// Shared/Utils/ImageLoader.swift

import SwiftUI
import UIKit

actor ImageCache {
    static let shared = ImageCache()

    private var cache = NSCache<NSString, UIImage>()

    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }

    func image(for key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }

    func setImage(_ image: UIImage, for key: String) {
        cache.setObject(image, forKey: key as NSString)
    }

    func removeImage(for key: String) {
        cache.removeObject(forKey: key as NSString)
    }

    func clearCache() {
        cache.removeAllObjects()
    }
}

// MARK: - Thumbnail Generator

final class ThumbnailGenerator {

    static let shared = ThumbnailGenerator()

    private init() {}

    /// 生成缩略图
    func generateThumbnail(from imageData: Data, size: CGSize) async -> UIImage? {
        guard let image = UIImage(data: imageData) else { return nil }

        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let thumbnail = self.resizeImage(image, to: size)
                continuation.resume(returning: thumbnail)
            }
        }
    }

    private func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
```

### 8.2 列表性能优化

```swift
// Shared/Components/Lists/LazyExpenseList.swift

import SwiftUI
import SwiftData

struct LazyExpenseList: View {
    @Query private var expenses: [Expense]

    @State private var visibleRange: Range<Int> = 0..<20

    init(projectId: UUID) {
        _expenses = Query(
            filter: #Predicate<Expense> { expense in
                expense.budget?.project?.id == projectId
            },
            sort: [SortDescriptor(\Expense.date, order: .reverse)]
        )
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(expenses.enumerated()), id: \.element.id) { index, expense in
                    ExpenseRow(expense: expense)
                        .onAppear {
                            // 预加载
                            if index > visibleRange.upperBound - 5 {
                                loadMore()
                            }
                        }
                }
            }
        }
    }

    private func loadMore() {
        let newUpperBound = min(visibleRange.upperBound + 20, expenses.count)
        visibleRange = visibleRange.lowerBound..<newUpperBound
    }
}
```

### 8.3 内存管理

```swift
// Core/Utils/MemoryManager.swift

import Foundation
import os.log

final class MemoryManager {

    static let shared = MemoryManager()

    private let logger = Logger(subsystem: "com.panda", category: "Memory")

    private init() {
        setupMemoryWarningObserver()
    }

    private func setupMemoryWarningObserver() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleMemoryWarning()
        }
    }

    private func handleMemoryWarning() {
        logger.warning("Received memory warning, clearing caches")

        Task {
            // 清理图片缓存
            await ImageCache.shared.clearCache()

            // 清理其他缓存
            URLCache.shared.removeAllCachedResponses()
        }
    }

    /// 获取当前内存使用量
    var currentMemoryUsage: UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        return result == KERN_SUCCESS ? info.resident_size : 0
    }

    var formattedMemoryUsage: String {
        ByteCountFormatter.string(fromByteCount: Int64(currentMemoryUsage), countStyle: .memory)
    }
}
```

---

## 9. 测试策略

### 9.1 单元测试

```swift
// PandaTests/ViewModels/BudgetDashboardViewModelTests.swift

import XCTest
import SwiftData
@testable import Panda

@MainActor
final class BudgetDashboardViewModelTests: XCTestCase {

    var container: ModelContainer!
    var viewModel: BudgetDashboardViewModel!
    var testProject: Project!

    override func setUp() async throws {
        container = try ModelContainer.createTestContainer()

        // 创建测试数据
        testProject = Project(name: "测试项目")
        container.mainContext.insert(testProject)

        let budget = Budget(totalAmount: 100000)
        budget.project = testProject
        container.mainContext.insert(budget)

        try container.mainContext.save()

        // 初始化 ViewModel
        let repository = BudgetRepository(modelContainer: container)
        let useCase = CalculateBudgetUseCase(budgetRepository: repository)
        viewModel = BudgetDashboardViewModel(
            budgetRepository: repository,
            calculateBudgetUseCase: useCase
        )
    }

    override func tearDown() async throws {
        container = nil
        viewModel = nil
        testProject = nil
    }

    func testLoadData() async {
        // When
        await viewModel.loadData(for: testProject.id)

        // Then
        XCTAssertNotNil(viewModel.budget)
        XCTAssertEqual(viewModel.totalBudget, 100000)
        XCTAssertEqual(viewModel.totalSpent, 0)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testBudgetCalculation() async {
        // Given
        let expense = Expense(amount: 25000, category: .design)
        expense.budget = viewModel.budget
        container.mainContext.insert(expense)
        try? container.mainContext.save()

        // When
        await viewModel.loadData(for: testProject.id)

        // Then
        XCTAssertEqual(viewModel.totalSpent, 25000)
        XCTAssertEqual(viewModel.remaining, 75000)
        XCTAssertEqual(viewModel.usagePercentage, 0.25, accuracy: 0.01)
    }

    func testOverBudgetDetection() async {
        // Given
        let expense = Expense(amount: 120000, category: .design)
        expense.budget = viewModel.budget
        container.mainContext.insert(expense)
        try? container.mainContext.save()

        // When
        await viewModel.loadData(for: testProject.id)

        // Then
        XCTAssertTrue(viewModel.isOverBudget)
    }
}
```

### 9.2 集成测试

```swift
// PandaTests/IntegrationTests/ExpenseFlowTests.swift

import XCTest
import SwiftData
@testable import Panda

@MainActor
final class ExpenseFlowTests: XCTestCase {

    var container: ModelContainer!

    override func setUp() async throws {
        container = try ModelContainer.createTestContainer()
    }

    func testCompleteExpenseFlow() async throws {
        // 1. 创建项目
        let project = Project(name: "集成测试项目", area: 100)
        container.mainContext.insert(project)

        // 2. 创建预算
        let budget = Budget(totalAmount: 200000, warningThreshold: 0.8)
        budget.project = project
        container.mainContext.insert(budget)

        // 3. 记录多笔支出
        let expenses = [
            Expense(amount: 10000, category: .design, note: "设计费"),
            Expense(amount: 30000, category: .demolition, note: "拆改"),
            Expense(amount: 25000, category: .hydropower, note: "水电"),
        ]

        for expense in expenses {
            expense.budget = budget
            container.mainContext.insert(expense)
        }

        try container.mainContext.save()

        // 4. 验证预算状态
        XCTAssertEqual(budget.totalSpent, 65000)
        XCTAssertEqual(budget.remaining, 135000)
        XCTAssertFalse(budget.isOverBudget)
        XCTAssertFalse(budget.isWarning)

        // 5. 添加更多支出触发预警
        let largeExpense = Expense(amount: 100000, category: .cabinets)
        largeExpense.budget = budget
        container.mainContext.insert(largeExpense)
        try container.mainContext.save()

        XCTAssertTrue(budget.isWarning)
        XCTAssertEqual(budget.usagePercentage, 0.825, accuracy: 0.01)
    }
}
```

### 9.3 UI 测试

```swift
// PandaUITests/BudgetUITests.swift

import XCTest

final class BudgetUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    func testAddExpense() {
        // 导航到预算页面
        app.tabBars.buttons["预算"].tap()

        // 点击添加按钮
        app.navigationBars.buttons["plus.circle.fill"].tap()

        // 输入金额
        let amountField = app.textFields["金额"]
        amountField.tap()
        amountField.typeText("5000")

        // 选择分类
        app.buttons["选择分类"].tap()
        app.buttons["设计费"].tap()

        // 添加备注
        let noteField = app.textFields["备注"]
        noteField.tap()
        noteField.typeText("设计费首付")

        // 保存
        app.buttons["保存"].tap()

        // 验证
        XCTAssertTrue(app.staticTexts["¥5,000"].exists)
        XCTAssertTrue(app.staticTexts["设计费首付"].exists)
    }

    func testBudgetWarning() {
        // 设置预算为 10000
        // 添加支出 9000
        // 验证预警显示

        app.tabBars.buttons["预算"].tap()

        // 验证预警颜色/图标显示
        XCTAssertTrue(app.images["exclamationmark.triangle.fill"].exists)
    }
}
```

---

## 10. 开发规范

### 10.1 代码风格

```swift
// MARK: - 命名规范

// 类型命名：大驼峰
struct BudgetDashboardView { }
class ExpenseRepository { }
enum PaymentType { }

// 变量/函数命名：小驼峰
let totalAmount: Decimal
func calculateBudget() -> Budget

// 布尔值命名：使用 is/has/should 前缀
var isLoading: Bool
var hasChanges: Bool
var shouldRefresh: Bool

// 常量：大驼峰或静态属性
static let maxPhotos = 10
enum Constants {
    static let animationDuration = 0.3
}

// MARK: - 代码组织

// 使用 MARK 注释分隔代码块
// MARK: - Properties
// MARK: - Initialization
// MARK: - Public Methods
// MARK: - Private Methods
// MARK: - View Body (SwiftUI)

// MARK: - 访问控制

// 优先使用最严格的访问级别
private var internalState: Int
private(set) var readOnlyProperty: String
internal func helperMethod()
public func apiMethod()

// MARK: - 错误处理

// 使用 Result 类型或 throws
func loadData() async throws -> [Expense]
func loadData() async -> Result<[Expense], AppError>

// 避免强制解包，使用可选绑定
guard let value = optionalValue else {
    return
}

if let value = optionalValue {
    // use value
}
```

### 10.2 Git 工作流

```bash
# 分支命名
feature/budget-analytics      # 新功能
fix/expense-calculation       # Bug 修复
refactor/repository-pattern   # 重构
docs/api-documentation        # 文档

# Commit 消息格式
feat(budget): add expense analytics chart
fix(schedule): correct task status update logic
refactor(core): migrate to async/await pattern
docs(readme): update installation guide
test(budget): add unit tests for ViewModel
chore(deps): update Swift Charts to 2.0

# 提交前检查
1. 代码编译通过
2. 单元测试通过
3. SwiftLint 检查通过
4. 无敏感信息泄露
```

### 10.3 代码审查清单

```markdown
## Code Review Checklist

### 功能
- [ ] 代码实现了需求中描述的功能
- [ ] 边界情况已处理
- [ ] 错误处理完善

### 代码质量
- [ ] 代码简洁易读
- [ ] 没有重复代码
- [ ] 命名清晰准确
- [ ] 注释必要且有价值

### 架构
- [ ] 符合 MVVM 架构
- [ ] 关注点分离良好
- [ ] 依赖注入正确使用

### 性能
- [ ] 没有内存泄露风险
- [ ] 大数据量处理有分页/懒加载
- [ ] 图片有压缩和缓存

### 安全
- [ ] 敏感数据已加密
- [ ] 没有硬编码的密钥
- [ ] 用户输入已验证

### 测试
- [ ] 新功能有单元测试
- [ ] 测试覆盖核心逻辑
- [ ] 边界条件有测试

### 本地化
- [ ] 用户可见文本已本地化
- [ ] 日期/货币格式化正确
```

---

## 11. 部署与发布

### 11.1 构建配置

```swift
// 配置文件结构
Panda/
├── Configurations/
│   ├── Debug.xcconfig
│   ├── Release.xcconfig
│   └── Shared.xcconfig
```

```
// Shared.xcconfig
PRODUCT_BUNDLE_IDENTIFIER = com.yourcompany.panda
MARKETING_VERSION = 1.0.0
CURRENT_PROJECT_VERSION = 1
SWIFT_VERSION = 5.9
IPHONEOS_DEPLOYMENT_TARGET = 17.0

// Debug.xcconfig
#include "Shared.xcconfig"
SWIFT_OPTIMIZATION_LEVEL = -Onone
ENABLE_TESTABILITY = YES
DEBUG_INFORMATION_FORMAT = dwarf-with-dsym

// Release.xcconfig
#include "Shared.xcconfig"
SWIFT_OPTIMIZATION_LEVEL = -O
ENABLE_TESTABILITY = NO
DEBUG_INFORMATION_FORMAT = dwarf-with-dsym
VALIDATE_PRODUCT = YES
```

### 11.2 CI/CD 流程

```yaml
# .github/workflows/ci.yml (示例)
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build-and-test:
    runs-on: macos-14

    steps:
    - uses: actions/checkout@v4

    - name: Select Xcode
      run: sudo xcode-select -s /Applications/Xcode_15.2.app

    - name: Build
      run: |
        xcodebuild build \
          -scheme Panda \
          -destination 'platform=iOS Simulator,name=iPhone 15' \
          -configuration Debug

    - name: Test
      run: |
        xcodebuild test \
          -scheme Panda \
          -destination 'platform=iOS Simulator,name=iPhone 15' \
          -configuration Debug \
          -resultBundlePath TestResults.xcresult

    - name: Upload Test Results
      uses: actions/upload-artifact@v4
      if: always()
      with:
        name: test-results
        path: TestResults.xcresult
```

### 11.3 App Store 发布清单

```markdown
## 发布前检查清单

### 代码检查
- [ ] 所有测试通过
- [ ] 没有编译警告
- [ ] 移除所有调试代码
- [ ] 检查内存泄露

### 资源检查
- [ ] App 图标完整 (所有尺寸)
- [ ] 启动屏正确显示
- [ ] 本地化资源完整

### 隐私检查
- [ ] Info.plist 权限说明完整
- [ ] 隐私政策 URL 有效
- [ ] 隐私信息收集清单准确

### App Store 资料
- [ ] 应用描述 (中英文)
- [ ] 关键词优化
- [ ] 截图准备 (6.7", 6.5", 5.5")
- [ ] 预览视频 (可选)

### 版本信息
- [ ] 版本号更新
- [ ] 构建号递增
- [ ] 更新日志准备
```

---

## 附录

### A. 常用工具类

```swift
// Shared/Utils/Formatters.swift

import Foundation

enum Formatters {

    // MARK: - Currency

    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    static func formatCurrency(_ amount: Decimal) -> String {
        currency.string(from: amount as NSNumber) ?? "¥0.00"
    }

    // MARK: - Date

    static let dateShort: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }()

    static let dateMedium: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }()

    static let dateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }()

    // MARK: - Percentage

    static let percentage: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }()

    static func formatPercentage(_ value: Double) -> String {
        percentage.string(from: NSNumber(value: value)) ?? "0%"
    }
}
```

### B. 错误处理

```swift
// Core/Utils/AppError.swift

import Foundation

enum AppError: LocalizedError {
    case networkError(Error)
    case dataLoadFailed(Error)
    case saveFailed(Error)
    case deleteFailed(Error)
    case validationFailed(String)
    case notFound(String)
    case unauthorized
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        case .dataLoadFailed(let error):
            return "数据加载失败: \(error.localizedDescription)"
        case .saveFailed(let error):
            return "保存失败: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "删除失败: \(error.localizedDescription)"
        case .validationFailed(let message):
            return "验证失败: \(message)"
        case .notFound(let item):
            return "未找到: \(item)"
        case .unauthorized:
            return "未授权访问"
        case .unknown(let error):
            return "未知错误: \(error.localizedDescription)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .networkError:
            return "请检查网络连接后重试"
        case .dataLoadFailed, .saveFailed, .deleteFailed:
            return "请稍后重试"
        case .validationFailed:
            return "请检查输入内容"
        case .notFound:
            return "请刷新后重试"
        case .unauthorized:
            return "请重新登录"
        case .unknown:
            return "请联系客服"
        }
    }
}
```

---

*文档版本：v1.0*
*创建日期：2026-02-02*
*最后更新：2026-02-02*
