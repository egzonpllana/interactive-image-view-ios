//
//  IIVCropHandler.swift
//  InteractiveImageView
//
//  Created by Egzon Pllana on 28.8.22.
//  Copyright © 2022 Egzon Pllana. All rights reserved.
//

// Inspired by:
// https://developer.apple.com/documentation/coregraphics/cgimage/1454683-cropping

import UIKit

/// Handles cropping operations for images displayed in an `InteractiveImageView`.
public struct IIVCropHandler {
    /// Crops an image to the specified rectangle, scaling the crop zone relative to the view dimensions.
    ///
    /// - Parameters:
    ///   - inputImage: The source image to crop.
    ///   - cropRect: The crop rectangle in view coordinates.
    ///   - viewWidth: The width of the view displaying the image.
    ///   - viewHeight: The height of the view displaying the image.
    /// - Returns: The cropped image, or `nil` if cropping fails.
    public static func cropImage(_ inputImage: UIImage, toRect cropRect: CGRect, viewWidth: CGFloat, viewHeight: CGFloat) -> UIImage? {
        let imageViewScale = max(inputImage.size.width / viewWidth,
                                 inputImage.size.height / viewHeight)

        // Scale cropRect to handle images larger than shown-on-screen size
        let cropZone = CGRect(x:cropRect.origin.x * imageViewScale,
                              y:cropRect.origin.y * imageViewScale,
                              width:cropRect.size.width * imageViewScale,
                              height:cropRect.size.height * imageViewScale)

        // Perform cropping in Core Graphics
        guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to:cropZone)
        else {
            return nil
        }

        // Return image to UIImage
        let croppedImage: UIImage = UIImage(cgImage: cutImageRef)
        return croppedImage
    }
}
