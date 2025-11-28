# Project Structure Documentation

## Overview

This document explains the directory structure of the PickleStoreApp repository and the relationships between different components.

## Directory Layout

```
/Users/vakula/repos/PickleStoreApp/
├── PickleStore/                    ← Main iOS App (SwiftUI + Firebase)
│   ├── Models/                     - Data models (Product, CartItem, Order, User)
│   ├── ViewModels/                 - Business logic (CartViewModel, OrderViewModel, etc.)
│   ├── Views/                      - UI components (ProductListView, CartView, OrderFormView, etc.)
│   ├── Services/                   - Services (PostcodeService, OrderStorageService)
│   ├── Resources/                  - Static assets (products.json, images)
│   ├── PickleStore/                - Main app files (ContentView, App entry point)
│   └── PickleStore.xcodeproj/      - Xcode project configuration
│
├── PickleStoreApp/                 ← Backend/Server Package (Swift)
│   ├── Package.swift               - Swift Package Manager configuration
│   └── Sources/
│       └── PickleStoreApp/
│           ├── main.swift          - Server entry point
│           ├── Product.swift       - Backend product model
│           ├── Order.swift         - Backend order model
│           └── User.swift          - Backend user model
│
├── docs/                           - Documentation files
│   ├── ADD_PRODUCTS.md             - Guide for adding products
│   ├── ADD_PRODUCT_IMAGES.md       - Guide for adding product images
│   ├── ADMIN_GUIDE.md              - Admin user guide
│   └── IMPLEMENTATION_DOCS.md      - Technical implementation details
│
├── docker/                         - Docker containerization
│   └── Dockerfile                  - Docker configuration for deployment
│
├── backups/                        - Backup files
│   ├── OrderFormView.backup.swift
│   ├── OrderFormView.old.swift
│   └── PostcodeService.backup.swift
│
├── plan/                           - Planning documents
│   ├── feature-iosapp-picklestore-1.md
│   └── infrastructure-docker-iosapp-1.md
│
├── prompts/                        - AI prompt templates
│   └── create-github-issues-feature-from-implementation-plan.prompt.md
│
├── .vscode/                        - VS Code editor settings
│   └── launch.json                 - Debug configurations for backend
│
├── .git/                           - Git version control
├── README.md                       - Project overview
└── Archive*.zip                    - Archived versions

```

## Component Descriptions

### 1. PickleStore/ (iOS Mobile App)

**Primary Component** - The main iOS application built with SwiftUI.

#### Architecture: MVVM (Model-View-ViewModel)

**Models/**
- `Product.swift` - Product data model with variant support (different weights/prices)
- `CartItem.swift` - Shopping cart item model
- `Order.swift` - Order data model
- `User.swift` - User authentication model

**ViewModels/**
- `ProductListViewModel.swift` - Manages product list data
- `CartViewModel.swift` - Shopping cart logic and operations
- `OrderViewModel.swift` - Order placement and management
- `AuthViewModel.swift` - User authentication logic

**Views/**
- `ProductListView.swift` - Product catalog display
- `CartView.swift` - Shopping cart interface
- `OrderFormView.swift` - Individual order placement form
- `OrderHistoryView.swift` - Past orders display
- `LoginView.swift` - User login screen
- `RegisterView.swift` - User registration screen

**Services/**
- `OrderStorageService.swift` - Order persistence (UserDefaults/Firebase)
- `PostcodeService.swift` - UK postcode validation and lookup

**Resources/**
- `products.json` - Product database (JSON format)
- `Assets.xcassets/` - Images and app icons

**Dependencies:**
- Firebase Auth (v12.5.0) - User authentication
- SwiftUI - UI framework
- Combine - Reactive programming

**iOS Compatibility:** iOS 15.0+
- Supports iPhone 6s and newer (2015-2025)
- Also compatible with iPad

### 2. PickleStoreApp/ (Backend Server Package)

**Status: Not Currently Used**

This is a Swift backend server package that appears to have been planned but not integrated with the iOS app.

**Current State:**
- ❌ Not referenced by the iOS app
- ❌ Not actively used
- ❌ Contains duplicate model files
- ❌ No integration with `/PickleStore/`

**Purpose (Original Intent):**
- Potential future backend API
- Swift-based server implementation
- Could handle product management, orders, user data

**Note:** The iOS app currently works completely independently using Firebase for backend services. This package can be safely ignored or deleted without affecting the iOS app functionality.

### 3. docs/ (Documentation)

Documentation files for developers and admins:

- **ADD_PRODUCTS.md** - How to add new products to the app
- **ADD_PRODUCT_IMAGES.md** - Guide for adding product images
- **ADMIN_GUIDE.md** - Administrator user guide
- **IMPLEMENTATION_DOCS.md** - Technical implementation details
- **PROJECT_STRUCTURE.md** (this file) - Project structure documentation

### 4. docker/ (Containerization)

Contains Docker configuration for potential server deployment:
- `Dockerfile` - Container image definition
- Currently not used for iOS app deployment

### 5. Supporting Directories

**backups/** - Backup copies of files during development
**plan/** - Project planning and feature documentation
**prompts/** - AI assistant prompt templates
**.vscode/** - Visual Studio Code settings (only for backend development)
**.git/** - Git version control data

## Dependency Relationships

### iOS App Dependencies

```
iOS App (PickleStore/)
    ↓
Firebase (Authentication)
    ↓
No backend server needed
```

**Key Points:**
- iOS app is **completely self-contained**
- Uses Firebase for user authentication
- Stores orders locally in UserDefaults
- Can optionally migrate to Firebase Firestore for cloud storage

### Independence

- **PickleStore/** (iOS App) ← **Independent** → **PickleStoreApp/** (Backend)
- They share NO dependencies
- Backend package is not compiled or linked to iOS app
- iOS app does not import or use backend package

## Development Workflow

### iOS App Development

**Tools Required:**
- Xcode 15.0+
- macOS with iOS Simulator
- Firebase account (for authentication)

**Build Command:**
```bash
cd /Users/vakula/repos/PickleStoreApp/PickleStore
xcodebuild -project PickleStore.xcodeproj -scheme PickleStore -destination 'platform=iOS Simulator,name=iPhone 15' build
```

**Run in Simulator:**
```bash
xcrun simctl install booted <path-to-app>
xcrun simctl launch booted com.b3.B3StoreApp
```

### Backend Development (If Needed)

**Tools Required:**
- Swift 5.9+
- Visual Studio Code (optional)
- Swift Package Manager

**Build Command:**
```bash
cd /Users/vakula/repos/PickleStoreApp/PickleStoreApp
swift build
```

**Note:** Backend is currently not integrated with iOS app.

## File Locations Reference

### Key Configuration Files

| File | Location | Purpose |
|------|----------|---------|
| Xcode Project | `/PickleStore/PickleStore.xcodeproj/` | iOS app configuration |
| Products Database | `/PickleStore/Resources/products.json` | Product data |
| Firebase Config | `/PickleStore/PickleStore/GoogleService-Info.plist` | Firebase setup |
| Swift Package | `/PickleStoreApp/Package.swift` | Backend package config |
| Docker Config | `/docker/Dockerfile` | Container definition |

### Source Code Locations

| Component | Location |
|-----------|----------|
| iOS Models | `/PickleStore/Models/` |
| iOS ViewModels | `/PickleStore/ViewModels/` |
| iOS Views | `/PickleStore/Views/` |
| iOS Services | `/PickleStore/Services/` |
| Backend Server | `/PickleStoreApp/Sources/PickleStoreApp/` |

## Questions & Answers

### Q: Is the backend package required for the iOS app?
**A:** No. The iOS app (`/PickleStore/`) is fully functional without the backend package (`/PickleStoreApp/`).

### Q: Can I delete the PickleStoreApp directory?
**A:** Yes, it won't affect the iOS app. Keep it only if you plan to develop a custom backend server.

### Q: What is .vscode used for?
**A:** VS Code editor settings for backend development. Not needed if you only use Xcode for iOS development.

### Q: Where are the actual product images stored?
**A:** In `/PickleStore/PickleStore/Assets.xcassets/` as image sets referenced by name in products.json.

### Q: How do I add new products?
**A:** Edit `/PickleStore/Resources/products.json` and add images to Assets.xcassets. See `docs/ADD_PRODUCTS.md` for detailed steps.

## Maintenance Notes

### Regular Updates

1. **Products** - Edit `Resources/products.json`
2. **Images** - Add to `Assets.xcassets/`
3. **Firebase Config** - Update `GoogleService-Info.plist` if changing Firebase project

### Deployment Checklist

- [ ] Update version in Xcode project settings
- [ ] Test on iOS 15+ devices
- [ ] Verify Firebase configuration
- [ ] Check products.json for valid data
- [ ] Test all product images load correctly
- [ ] Validate delivery charge calculations
- [ ] Test cart operations (+/-, delete, clear)
- [ ] Verify order placement and storage
- [ ] Test authentication flow

## Version Information

- **iOS Deployment Target:** iOS 15.0
- **Swift Version:** 5.9+
- **Xcode Version:** 15.0+
- **Firebase SDK:** v12.5.0

---

**Last Updated:** November 28, 2025
**Project:** PickleStoreApp (B3 Stores)
**Repository:** github.com/veeraadevops/PickleStoreApp
