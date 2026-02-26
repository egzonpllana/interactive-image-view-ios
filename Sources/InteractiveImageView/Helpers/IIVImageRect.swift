//
//  IIVImageRect.swift
//  InteractiveImageView
//
//  Created by Egzon Pllana on 28.8.22.
//  Copyright © 2022 Egzon Pllana. All rights reserved.
//

// Inspired by:
// https://github.com/BasselEzzeddine/PhotoCrop

import UIKit

/// Computes the display rectangle of an image within its image view, accounting for aspect ratio.
public struct IIVImageRect {
    /// Calculates the actual display rectangle of the image inside the given image view.
    ///
    /// - Parameter imageView: The image view containing the image.
    /// - Returns: The rectangle representing the image's visible area in the image view's coordinate space.
    public static func getImageRect(fromImageView imageView: UIImageView) -> CGRect {
        let imageViewSize = imageView.frame.size
        let imgSize = imageView.image?.size

        guard let imageSize = imgSize else {
            return CGRect.zero
        }

        let scaleWidth = imageViewSize.width / imageSize.width
        let scaleHeight = imageViewSize.height / imageSize.height
        let aspect = fmin(scaleWidth, scaleHeight)

        var imageRect = CGRect(x: 0, y: 0, width: imageSize.width * aspect, height: imageSize.height * aspect)

        // Center image
        imageRect.origin.x = (imageViewSize.width - imageRect.size.width) / 2
        imageRect.origin.y = (imageViewSize.height - imageRect.size.height) / 2

        // Add imageView offset
        imageRect.origin.x += imageView.frame.origin.x
        imageRect.origin.y += imageView.frame.origin.y

        return imageRect
    }
}
