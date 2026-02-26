<p align="center">
    <img src="logo.png" width="300" max-width="50%" alt="InteractiveImageView" />
</p>

<p align="center">
    <img src="https://img.shields.io/badge/Swift-5.6-orange.svg" />
    <a href="https://swift.org/package-manager">
        <img src="https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" />
    </a>
    <img src="https://img.shields.io/badge/iOS-13%2B-blue.svg" />
</p>

A lightweight library for interactive image viewing — scroll, zoom, pinch, rotate, and crop — all inside a single `UIView`. Supports multiple content modes including custom aspect ratios (e.g. 2:3, 9:16). Works with both UIKit and SwiftUI.

## Features

- Crop image at current visible position (async via delegate or synchronous)
- Switch between content modes: aspect fill, aspect fit, width fill, height fill, or custom ratio
- Scroll on both axes
- Double-tap to zoom in/out with configurable zoom factor
- Pinch to zoom
- Rotate image by any degree with option to keep or discard changes
- Programmatic scroll offset and zoom scale control
- Delegate callbacks for crop, scroll, zoom, and failure events
- All delegate methods are optional

### Preview
<p align="left">
    <img src="example-preview.png" width="380" max-height="50%" alt="InteractiveImageView" />
</p>

## API Reference

### InteractiveImageView

The main view class. Subclass of `UIView`.

#### Properties

| Property | Type | Default | Description |
|---|---|---|---|
| `delegate` | `InteractiveImageViewDelegate?` | `nil` | Delegate for crop, scroll, zoom, and failure callbacks |
| `isScrollEnabled` | `Bool` | `true` | Enable or disable scrolling |
| `isPinchAllowed` | `Bool` | `true` | Enable or disable pinch-to-zoom |
| `isDoubleTapToZoomAllowed` | `Bool` | `true` | Enable or disable double-tap zoom |
| `doubleTapZoomFactor` | `CGFloat` | `2.0` | Zoom scale applied on double-tap (1.0–5.0) |

#### Methods

| Method | Description |
|---|---|
| `configure(withNextContentMode:withFocusOffset:withImage:)` | Configure with content mode, focus offset, and image |
| `configure(withNextContentMode:withFocusOffset:withImage:withIdentifier:)` | Configure with an additional identifier for tracking |
| `performCropImage()` | Crop visible area and deliver result via `didCropImage` delegate |
| `cropAndGetImage() -> UIImage?` | Crop and return image synchronously |
| `getOriginalImage() -> UIImage?` | Get the original unmodified image |
| `updateImageOnly(_ image: UIImage?)` | Replace image without reconfiguring layout |
| `updateImageView(withImage image: UIImage?)` | Update image in the image view |
| `toggleImageContentMode()` | Toggle between current and alternate content mode |
| `rotateImage(_ degrees: CGFloat, keepChanges: Bool)` | Rotate image by degrees; `keepChanges` preserves or discards rotation |
| `setContentOffset(_ offset: CGPoint, animated: Bool, zoomScale: CGFloat)` | Programmatically set scroll position and zoom scale |

### InteractiveImageViewDelegate

All methods are optional via default implementation.

```swift
protocol InteractiveImageViewDelegate: AnyObject {
    func didCropImage(image: UIImage, fromView: InteractiveImageView)
    func didScrollAt(offset: CGPoint, scale: CGFloat, fromView: InteractiveImageView)
    func didZoomAt(offset: CGPoint, scale: CGFloat, fromView: InteractiveImageView)
    func didFail(_ fail: IIVFailType)
}
```

### Enums

#### IIVContentMode

```swift
enum IIVContentMode: Equatable, Sendable {
    case aspectFill                    // 1:1 square fill
    case aspectFit                     // Fit within bounds
    case widthFill                     // Fill width, scroll vertically
    case heightFill                    // Fill height, scroll horizontally
    case customOffset(offset: CGFloat) // Custom ratio (e.g. 2.0/3.0 for 2:3)
}
```

#### IIVFocusOffset

```swift
enum IIVFocusOffset: Int, Sendable {
    case beginning  // Focus at the start of the image
    case center     // Focus at the center of the image
}
```

#### IIVFailType

```swift
enum IIVFailType: Sendable {
    case cropImageFailed
    case toggleContentModeFailed
    case adjustFramesWhenZoomingFailed
    case getImageViewFailed
    case getImageFailed
    case rotateImageFailed
}
```

### Helpers

| Type | Method | Description |
|---|---|---|
| `IIVCropHandler` | `cropImage(_:toRect:viewWidth:viewHeight:) -> UIImage?` | Crop a `UIImage` to a given rect |
| `IIVImageRect` | `getImageRect(fromImageView:) -> CGRect` | Get the displayed image rect within a `UIImageView` |
| `UIImage` | `rotated(by degrees: CGFloat) -> UIImage?` | Return a rotated copy of the image |

## UIKit Usage

```swift
import InteractiveImageView

class ViewController: UIViewController, InteractiveImageViewDelegate {
    @IBOutlet weak var interactiveImageView: InteractiveImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        interactiveImageView.delegate = self
        interactiveImageView.doubleTapZoomFactor = 3.0

        if let image = UIImage(named: "photo") {
            interactiveImageView.configure(
                withNextContentMode: .heightFill,
                withFocusOffset: .center,
                withImage: image
            )
        }
    }

    func didCropImage(image: UIImage, fromView: InteractiveImageView) {
        // Handle cropped image
    }

    func didFail(_ fail: IIVFailType) {
        // Handle failure
    }
}
```

## SwiftUI Usage

Wrap `InteractiveImageView` in a `UIViewRepresentable`. Use a bridge class for imperative actions.

```swift
import SwiftUI
import InteractiveImageView

final class ImageViewActions {
    fileprivate weak var view: InteractiveImageView?

    func crop() { view?.performCropImage() }
    func toggleContentMode() { view?.toggleImageContentMode() }
    func rotate(degrees: CGFloat) { view?.rotateImage(degrees, keepChanges: true) }
}

struct InteractiveImageViewWrapper: UIViewRepresentable {
    let image: UIImage?
    let contentMode: IIVContentMode
    let actions: ImageViewActions
    var onCrop: (UIImage) -> Void = { _ in }

    func makeUIView(context: Context) -> InteractiveImageView {
        let view = InteractiveImageView(frame: .zero)
        view.delegate = context.coordinator
        actions.view = view
        view.configure(
            withNextContentMode: contentMode,
            withFocusOffset: .center,
            withImage: image
        )
        return view
    }

    func updateUIView(_ uiView: InteractiveImageView, context: Context) {
        context.coordinator.onCrop = onCrop
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onCrop: onCrop)
    }

    final class Coordinator: NSObject, InteractiveImageViewDelegate {
        var onCrop: (UIImage) -> Void

        init(onCrop: @escaping (UIImage) -> Void) {
            self.onCrop = onCrop
        }

        func didCropImage(image: UIImage, fromView: InteractiveImageView) {
            onCrop(image)
        }
    }
}
```

Then use it in any SwiftUI view:

```swift
struct ContentView: View {
    private let actions = ImageViewActions()
    @State private var croppedImage: UIImage?

    var body: some View {
        VStack {
            InteractiveImageViewWrapper(
                image: UIImage(named: "photo"),
                contentMode: .aspectFill,
                actions: actions,
                onCrop: { croppedImage = $0 }
            )
            .frame(height: 400)

            HStack {
                Button("Crop") { actions.crop() }
                Button("Rotate") { actions.rotate(degrees: 90) }
                Button("Toggle") { actions.toggleContentMode() }
            }

            if let croppedImage {
                Image(uiImage: croppedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
            }
        }
    }
}
```

## Example Project

Run `InteractiveImageViewExample` for a full SwiftUI demo showcasing all SDK features including content mode switching, focus offset, gesture toggles, zoom factor, crop, and rotation.

## Installation

### Swift Package Manager (Recommended)

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/egzonpllana/InteractiveImageView.git", from: "2.0.0")
]
```

Or in Xcode: File > Add Package Dependencies and enter:
```
https://github.com/egzonpllana/InteractiveImageView.git
```

### CocoaPods (Deprecated)

> **Note:** As of v2.0.0, CocoaPods is no longer supported. Please migrate to Swift Package Manager, which is Apple's official dependency management solution. The last CocoaPods-compatible version is 1.1.2.

### Carthage (Deprecated)

> **Note:** As of v2.0.0, Carthage is no longer supported. Please migrate to Swift Package Manager. The last Carthage-compatible version is 1.1.2.

## Why InteractiveImageView?

A window is just glass until someone opens it. InteractiveImageView turns a static `UIImageView` into a living surface — one that responds to touch, yields to gestures, and frames exactly what the user intends. Scroll, zoom, pinch, rotate, crop — all orchestrated inside a single `UIView`, no view controller ceremony required. Drop it into any layout, any aspect ratio, any composition, and let the image breathe.

## Questions or feedback?

Feel free to [open an issue](https://github.com/egzonpllana/InteractiveImageView/issues/new), or find me [@egzonpllana on LinkedIn](https://www.linkedin.com/in/egzon-pllana/).
