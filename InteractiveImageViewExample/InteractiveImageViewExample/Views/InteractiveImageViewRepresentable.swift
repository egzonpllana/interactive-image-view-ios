//
//  InteractiveImageViewRepresentable.swift
//  InteractiveImageViewExample
//
//  Created by Egzon Pllana on 26.2.26.
//

import SwiftUI
import InteractiveImageView

// MARK: - Actions Bridge -

/// Bridges imperative SDK calls from SwiftUI to the underlying `InteractiveImageView`.
final class InteractiveImageViewActions {
    fileprivate weak var view: InteractiveImageView?

    func crop() {
        view?.performCropImage()
    }

    func toggleContentMode() {
        view?.toggleImageContentMode()
    }

    func rotate(degrees: CGFloat, keepChanges: Bool) {
        view?.rotateImage(degrees, keepChanges: keepChanges)
    }

    func reset(
        image: UIImage?,
        nextContentMode: IIVContentMode,
        focusOffset: IIVFocusOffset
    ) {
        view?.configure(
            withNextContentMode: nextContentMode,
            withFocusOffset: focusOffset,
            withImage: image
        )
    }
}

// MARK: - UIViewRepresentable -

/// A SwiftUI wrapper around `InteractiveImageView` that exposes the full SDK surface.
struct InteractiveImageViewRepresentable: UIViewRepresentable {

    // MARK: - Properties

    let image: UIImage?
    let nextContentMode: IIVContentMode
    let focusOffset: IIVFocusOffset
    var isPinchAllowed: Bool = true
    var isScrollEnabled: Bool = true
    var isDoubleTapToZoomAllowed: Bool = true
    var doubleTapZoomFactor: CGFloat = 2.0

    var actions: InteractiveImageViewActions
    var onCrop: (UIImage) -> Void = { _ in }
    var onScroll: (CGPoint, CGFloat) -> Void = { _, _ in }
    var onZoom: (CGPoint, CGFloat) -> Void = { _, _ in }
    var onFail: (IIVFailType) -> Void = { _ in }

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> InteractiveImageView {
        let interactiveView = InteractiveImageView(frame: .zero)
        interactiveView.delegate = context.coordinator
        actions.view = interactiveView

        interactiveView.isPinchAllowed = isPinchAllowed
        interactiveView.isScrollEnabled = isScrollEnabled
        interactiveView.isDoubleTapToZoomAllowed = isDoubleTapToZoomAllowed
        interactiveView.doubleTapZoomFactor = doubleTapZoomFactor

        interactiveView.configure(
            withNextContentMode: nextContentMode,
            withFocusOffset: focusOffset,
            withImage: image
        )
        return interactiveView
    }

    func updateUIView(_ uiView: InteractiveImageView, context: Context) {
        uiView.isPinchAllowed = isPinchAllowed
        uiView.isScrollEnabled = isScrollEnabled
        uiView.isDoubleTapToZoomAllowed = isDoubleTapToZoomAllowed
        uiView.doubleTapZoomFactor = doubleTapZoomFactor

        context.coordinator.onCrop = onCrop
        context.coordinator.onScroll = onScroll
        context.coordinator.onZoom = onZoom
        context.coordinator.onFail = onFail
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
            onCrop: onCrop,
            onScroll: onScroll,
            onZoom: onZoom,
            onFail: onFail
        )
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, InteractiveImageViewDelegate {
        var onCrop: (UIImage) -> Void
        var onScroll: (CGPoint, CGFloat) -> Void
        var onZoom: (CGPoint, CGFloat) -> Void
        var onFail: (IIVFailType) -> Void

        init(
            onCrop: @escaping (UIImage) -> Void,
            onScroll: @escaping (CGPoint, CGFloat) -> Void,
            onZoom: @escaping (CGPoint, CGFloat) -> Void,
            onFail: @escaping (IIVFailType) -> Void
        ) {
            self.onCrop = onCrop
            self.onScroll = onScroll
            self.onZoom = onZoom
            self.onFail = onFail
        }

        func didCropImage(image: UIImage, fromView: InteractiveImageView) {
            onCrop(image)
        }

        func didScrollAt(offset: CGPoint, scale: CGFloat, fromView: InteractiveImageView) {
            onScroll(offset, scale)
        }

        func didZoomAt(offset: CGPoint, scale: CGFloat, fromView: InteractiveImageView) {
            onZoom(offset, scale)
        }

        func didFail(_ fail: IIVFailType) {
            onFail(fail)
        }
    }
}
