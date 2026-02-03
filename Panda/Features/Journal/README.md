# Journal Module（装修日记模块）

## Overview

装修日记模块用于记录装修过程中的点点滴滴，支持图文混排、标签管理和时间线展示，帮助用户完整保存装修历程。

## Features

### ✅ Implemented

- **日记列表** (JournalListView)
  - 时间线展示（按月份分组）
  - 搜索功能（标题、内容、标签）
  - 标签筛选器
  - 照片预览（最多显示4张缩略图）
  - 相对时间显示（今天、昨天、N天前）
  - 滑动删除

- **写日记/编辑** (AddJournalEntryView)
  - 标题和内容输入
  - 日期选择器
  - 多图上传（最多9张，使用PhotosPicker）
  - 标签管理（添加/删除）
  - 预设常用标签快捷选择
  - 照片预览和删除
  - 自动布局的FlowLayout标签展示

- **日记详情** (JournalDetailView)
  - 完整内容展示
  - 照片网格浏览
  - 点击查看大图（支持左右滑动）
  - 标签列表
  - 编辑和删除功能
  - 元数据显示（创建和更新时间）

- **业务逻辑** (ViewModels)
  - JournalListViewModel: 列表管理、搜索、筛选、日期格式化
  - AddJournalEntryViewModel: 表单验证、照片管理、标签管理

## File Structure

```
Features/Journal/
├── ViewModels/
│   ├── JournalListViewModel.swift
│   └── AddJournalEntryViewModel.swift
├── Views/
│   ├── JournalListView.swift
│   ├── AddJournalEntryView.swift
│   └── JournalDetailView.swift
└── README.md
```

## Data Model

使用 `JournalEntry` 模型（定义在 `Core/Database/Models/JournalEntry.swift`）：

```swift
@Model
final class JournalEntry {
    var title: String             // 标题
    var content: String           // 内容
    var photoData: [Data]         // 照片数据数组
    var tags: [String]            // 标签数组
    var date: Date                // 日记日期
    var project: Project?         // 关联项目

    // Helper methods
    func addPhoto(_ data: Data)
    func removePhoto(at index: Int)
    func addTag(_ tag: String)
    func removeTag(_ tag: String)
}
```

### Predefined Tags（预设标签）

提供13个常用标签快捷选择：
- 拆除、水电、泥瓦、木工、油漆
- 安装、验收、问题、进展、材料
- 设计、效果、前后对比

## Integration

装修日记模块已集成到：

- **ProfileDashboardView**: 装修日记入口
- **HomeDashboardView**: 可通过快捷操作访问（TODO）

## Usage

### 从 Profile 页面进入

```swift
NavigationLink {
    JournalListView(modelContext: modelContext)
} label: {
    Label("装修日记", systemImage: "photo")
}
```

### 写日记

```swift
AddJournalEntryView(modelContext: modelContext)
```

### 编辑日记

```swift
AddJournalEntryView(modelContext: modelContext, entry: existingEntry)
```

### 查看详情

```swift
JournalDetailView(entry: entry, modelContext: modelContext)
```

## Key Components

### FlowLayout

自定义布局组件，用于自适应标签排列：

```swift
FlowLayout(spacing: Spacing.sm) {
    ForEach(tags, id: \.self) { tag in
        Text("#\(tag)")
    }
}
```

### PhotoDetailView

全屏照片查看器，支持：
- TabView 滑动切换
- 页码指示器（1 / 9）
- 缩放手势（通过 SwiftUI 自带的 .scaledToFit()）

### TagChip

可删除的标签芯片组件：

```swift
TagChip(tag: "拆除") {
    // Remove action
}
```

## Photo Management

### 照片上传流程

1. 使用 `PhotosPicker` 选择照片（最多9张）
2. 异步加载照片数据：`await item.loadTransferable(type: Data.self)`
3. 存储为 `Data` 数组
4. 显示缩略图预览
5. 支持删除（点击 X 按钮）

### 照片展示

- **列表页**：最多显示4张缩略图（80x80），超过显示 "+N" 提示
- **详情页**：网格布局（3列），点击查看大图
- **大图查看**：TabView 全屏浏览，支持滑动切换

## Search & Filter

### 搜索功能

支持搜索：
- 标题（title）
- 内容（content）
- 标签（tags）

### 筛选功能

- 按标签筛选
- 显示所有已使用的标签
- FilterChip 交互式筛选器

### 时间线展示

- 按月份分组（yyyy年MM月）
- 每组内按日期降序排列
- 相对时间显示：
  - 今天
  - 昨天
  - N 天前（7天内）
  - MM月dd日（7天以上）

## Testing

使用 Xcode Previews 测试各个视图：

- JournalListView: 包含3条示例日记的时间线预览
- AddJournalEntryView: 添加和编辑模式预览
- JournalDetailView: 完整日记详情预览（带长文本和标签）

## Future Enhancements

- [ ] 视频支持
- [ ] 语音记录
- [ ] Markdown 富文本编辑
- [ ] 导出为 PDF
- [ ] 分享到社交媒体
- [ ] 前后对比功能（双图展示）
- [ ] 装修进度关联（链接到Phase/Task）
- [ ] 天气记录（记录当天天气）
- [ ] 位置记录（GPS定位）
- [ ] 日记模板（开工、验收等）

## Dependencies

- SwiftUI
- SwiftData
- PhotosUI (PhotosPicker for photo selection)
- ProjectManager (当前项目管理)
- Shared Components (CardView, FilterChip)
- Shared Styles (Colors, Fonts, Spacing)

## Design Patterns

### MVVM Architecture

- **Model**: JournalEntry (SwiftData)
- **View**: JournalListView, AddJournalEntryView, JournalDetailView
- **ViewModel**: JournalListViewModel, AddJournalEntryViewModel

### Composition

- FlowLayout: 自定义布局
- TagChip: 可复用标签组件
- PhotoDetailView: 独立的照片查看器

### Reactive Programming

使用 `@Published` 和 `@StateObject` 实现响应式数据流：

```swift
@Published var entries: [JournalEntry] = []
@Published var searchText: String = ""
@Published var selectedTag: String?

var filteredEntries: [JournalEntry] {
    // Auto-updates when published properties change
}
```

---

**Created**: 2026-02-03
**Status**: ✅ Complete and ready for use
