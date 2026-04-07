## ✨ Features

- 🔍 Auto Zoom (smart scaling)
- 🤏 Pinch to Zoom
- 🎯 Tap to Focus
- 🔦 Flash / Torch Control
- 🧠 State Machine Driven
- 🎨 Scan Overlay with Animation
- 📐 Custom Scan Area
- 🔄 Lifecycle Handling
- 📦 Swift Package Manager Support

---

## 📦 Installation

### Swift Package Manager

Add this package via Xcode:
https://github.com/rahulDSharma98/RSBarcodeScanner.git

---

## 🚀 Usage

```swift
import BarcodeScanner

let scanner = BarcodeScannerViewController()
scanner.delegate = self
present(scanner, animated: true)
```

---

## ⚙️ Configuration
```swift
var config = ScannerConfiguration()
config.isFlashEnabled = true

let scanner = BarcodeScannerViewController(configuration: config)
```

---

## 🔦 Torch Control
```swift
scanner.toggleTorch()
scanner.setTorch(enabled: true)
```

---

## 🔍 Zoom Control
```swift
scanner.setZoom(level: 2.0)
scanner.setZoomSmooth(to: 3.0)
```

---

## 📐 Scan Area
```swift
scanner.setScanArea(CGRect(x: 100, y: 200, width: 200, height: 200))
```

---

## 📱 Demo App
A working demo is included in:
```
Examples/RSBarcodeScannerDemo
```

---

## 🔐 Permissions
Add to your Info.plist:
```swift
<key>NSCameraUsageDescription</key>
<string>Camera is required to scan barcodes</string>
```

---

## 🧱 Requirements
iOS 13.0+
Swift 5.7+
---

## 📄 License
MIT License
