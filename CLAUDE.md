# CLAUDE.md - AI Assistant Guide for Panda

This file provides guidance for AI assistants working with the Panda repository.

## Project Overview

**Panda 装修管家** is an iOS app for home renovation budget and progress management. It helps homeowners track expenses, manage project timelines, and organize renovation-related information.

**Repository**: ZhangXFeng/panda

**Key Documents**:
- [Product Requirements (PRD)](./docs/PRD.md) - Detailed product specifications

## Tech Stack

| Component | Technology |
|-----------|------------|
| Platform | iOS 17+ |
| Language | Swift 5.9+ |
| UI Framework | SwiftUI |
| Architecture | MVVM + Clean Architecture |
| Local Storage | SwiftData |
| Cloud Sync | CloudKit |
| Charts | Swift Charts |

## Quick Start

```bash
# Clone the repository
git clone <repository-url>
cd panda

# Open in Xcode
open Panda.xcodeproj
# or
open Panda.xcworkspace

# Build and run
# Use Xcode: Cmd + R
```

### Requirements
- macOS 14.0+
- Xcode 15.0+
- iOS 17.0+ (deployment target)

## Project Structure

```
Panda/
├── CLAUDE.md                 # AI assistant guidance
├── docs/
│   └── PRD.md               # Product requirements document
├── Panda/
│   ├── App/
│   │   └── PandaApp.swift   # App entry point
│   ├── Features/
│   │   ├── Budget/          # 预算管理
│   │   │   ├── Views/
│   │   │   ├── ViewModels/
│   │   │   └── Models/
│   │   ├── Schedule/        # 进度管理
│   │   ├── Materials/       # 材料管理
│   │   ├── Documents/       # 合同文档
│   │   ├── Contacts/        # 通讯录
│   │   └── Journal/         # 装修日记
│   ├── Core/
│   │   ├── Database/        # SwiftData models
│   │   ├── CloudSync/       # CloudKit integration
│   │   └── Extensions/      # Swift extensions
│   ├── Shared/
│   │   ├── Components/      # Reusable UI components
│   │   ├── Styles/          # Design system
│   │   └── Utils/           # Utilities
│   └── Resources/
│       ├── Assets.xcassets/ # Images, colors
│       └── Localization/    # zh-Hans, en
└── PandaTests/              # Unit tests
```

## Development Workflow

### Branch Naming Convention

- Feature branches: `feature/<description>`
- Bug fixes: `fix/<description>`
- Documentation: `docs/<description>`
- AI-assisted work: `claude/<description>-<session-id>`

### Commit Message Format

Use conventional commits:

```
<type>(<scope>): <description>

[optional body]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

Scopes: `budget`, `schedule`, `materials`, `documents`, `contacts`, `journal`, `core`, `ui`

Examples:
```
feat(budget): add expense recording view
fix(schedule): correct task completion status update
refactor(core): migrate to SwiftData
```

## Code Conventions

### Swift Style Guide

1. **Naming**: Use descriptive names, follow Swift API Design Guidelines
2. **SwiftUI Views**: One View per file, extract subviews for reusability
3. **MVVM Pattern**: Views observe ViewModels, ViewModels handle logic
4. **SwiftData**: Models in `Core/Database/`, use `@Model` macro

### File Organization

```swift
// MARK: - View Example
struct BudgetView: View {
    @StateObject private var viewModel: BudgetViewModel

    var body: some View {
        // View implementation
    }
}

// MARK: - Subviews
private extension BudgetView {
    var headerSection: some View { ... }
    var expenseList: some View { ... }
}

// MARK: - Preview
#Preview {
    BudgetView()
}
```

### Data Models

```swift
// Core/Database/Expense.swift
import SwiftData

@Model
final class Expense {
    var amount: Decimal
    var category: ExpenseCategory
    var note: String
    var date: Date
    var photos: [Data]

    init(amount: Decimal, category: ExpenseCategory, note: String = "") {
        self.amount = amount
        self.category = category
        self.note = note
        self.date = Date()
        self.photos = []
    }
}
```

## AI Assistant Guidelines

### Do

- Follow SwiftUI and Swift best practices
- Use SwiftData for persistence (not Core Data directly)
- Keep Views declarative and logic in ViewModels
- Use Swift's native types (Decimal for money, Date for times)
- Localize user-facing strings (Chinese primary, English secondary)
- Write unit tests for ViewModels and business logic
- Use SF Symbols for icons when possible

### Don't

- Use UIKit unless absolutely necessary
- Store sensitive data without encryption
- Add third-party dependencies without discussion
- Skip accessibility support
- Hardcode strings (use Localizable.strings)
- Create massive view files (extract subviews)

### Feature Implementation Pattern

1. **Model**: Create/update SwiftData model in `Core/Database/`
2. **ViewModel**: Business logic in `Features/<Feature>/ViewModels/`
3. **View**: UI in `Features/<Feature>/Views/`
4. **Tests**: Unit tests in `PandaTests/`

### Common Tasks

| Task | Location |
|------|----------|
| Add new expense category | `Core/Database/ExpenseCategory.swift` |
| Create new screen | `Features/<Feature>/Views/` |
| Add reusable component | `Shared/Components/` |
| Define colors/fonts | `Shared/Styles/` |
| Add localization | `Resources/Localization/` |

## Testing

```bash
# Run tests via Xcode
# Cmd + U

# Or via command line
xcodebuild test -scheme Panda -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Test Structure
- Unit tests for ViewModels
- UI tests for critical user flows
- Snapshot tests for UI consistency (optional)

## Localization

Primary: Simplified Chinese (zh-Hans)
Secondary: English (en)

```swift
// Usage
Text("budget_title", comment: "Budget screen title")

// Localizable.strings (zh-Hans)
"budget_title" = "预算管理";

// Localizable.strings (en)
"budget_title" = "Budget";
```

## Design System

### Colors (defined in Assets.xcassets)
- `AccentColor`: Primary brand color (warm wood tone)
- `SuccessColor`: Completion/progress (green)
- `WarningColor`: Alerts/over-budget (orange)
- `BackgroundPrimary`: Main background
- `BackgroundSecondary`: Card backgrounds

### Typography
Use system fonts with Dynamic Type support:
```swift
.font(.title)      // Screen titles
.font(.headline)   // Section headers
.font(.body)       // Content
.font(.caption)    // Secondary info
```

## Resources

- [Product Requirements](./docs/PRD.md)
- [Apple HIG](https://developer.apple.com/design/human-interface-guidelines/)
- [SwiftUI Docs](https://developer.apple.com/documentation/swiftui/)
- [SwiftData Docs](https://developer.apple.com/documentation/swiftdata/)
- [CloudKit Docs](https://developer.apple.com/documentation/cloudkit/)

---

*Last updated: 2026-02-02*
