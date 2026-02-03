# Contacts Module（联系人模块）

## Overview

联系人模块用于管理装修项目相关的所有联系人，包括装修公司、设计师、工长、工人、材料商家等。

## Features

### ✅ Implemented

- **联系人列表** (ContactListView)
  - 按角色分组显示
  - 支持搜索（姓名、公司、电话）
  - 角色筛选器
  - 推荐联系人专区
  - 快捷拨号和微信按钮
  - 滑动删除

- **添加/编辑联系人** (AddContactView)
  - 基本信息：姓名、角色、电话、微信
  - 公司信息：公司名称、地址
  - 评价系统：1-5星评分
  - 推荐标记
  - 备注字段
  - 表单验证

- **联系人详情** (ContactDetailView)
  - 完整信息展示
  - 快捷操作：拨打电话、微信、导航
  - 编辑和删除功能
  - 元数据显示（创建和更新时间）

- **业务逻辑** (ViewModels)
  - ContactListViewModel: 列表管理、搜索、筛选
  - AddContactViewModel: 表单验证、保存逻辑

## File Structure

```
Features/Contacts/
├── ViewModels/
│   ├── ContactListViewModel.swift
│   └── AddContactViewModel.swift
├── Views/
│   ├── ContactListView.swift
│   ├── AddContactView.swift
│   └── ContactDetailView.swift
└── README.md
```

## Data Model

使用 `Contact` 模型（定义在 `Core/Database/Models/Contact.swift`）：

```swift
@Model
final class Contact {
    var name: String              // 姓名
    var role: ContactRole         // 角色
    var phoneNumber: String       // 电话
    var wechatID: String          // 微信号
    var company: String           // 公司
    var address: String           // 地址
    var rating: Int               // 评分 (0-5)
    var notes: String             // 备注
    var isRecommended: Bool       // 是否推荐
    var project: Project?         // 关联项目
}
```

### Contact Roles

- 装修公司 (company)
- 设计师 (designer)
- 工长 (foreman)
- 水电工 (electrician)
- 泥瓦工 (mason)
- 木工 (carpenter)
- 油漆工 (painter)
- 材料商家 (vendor)
- 其他 (other)

## Integration

联系人模块已集成到：

- **ProfileDashboardView**: 通讯录入口
- **HomeDashboardView**: 可通过快捷操作访问（TODO）

## Usage

### 从 Profile 页面进入

```swift
NavigationLink {
    ContactListView(modelContext: modelContext)
} label: {
    Label("通讯录", systemImage: "person.crop.circle")
}
```

### 添加联系人

```swift
AddContactView(modelContext: modelContext)
```

### 编辑联系人

```swift
AddContactView(modelContext: modelContext, contact: existingContact)
```

### 查看详情

```swift
ContactDetailView(contact: contact, modelContext: modelContext)
```

## Testing

使用 Xcode Previews 测试各个视图：

- ContactListView: 包含示例数据的列表预览
- AddContactView: 添加和编辑模式预览
- ContactDetailView: 完整联系人详情预览

## Future Enhancements

- [ ] 联系人头像/照片
- [ ] 联系历史记录
- [ ] 批量导入/导出
- [ ] 联系人分享
- [ ] 通话记录集成
- [ ] 标签管理
- [ ] 联系人分组自定义

## Dependencies

- SwiftUI
- SwiftData
- ProjectManager (当前项目管理)
- Shared Components (CardView, FilterChip, ProgressBar等)
- Shared Styles (Colors, Fonts, Spacing)

---

**Created**: 2026-02-03
**Status**: ✅ Complete and ready for use
