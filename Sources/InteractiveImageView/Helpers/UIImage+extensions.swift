//
//  UIImage+extensions.swift
//  InteractiveImageView
//
//  Created by Egzon Pllana on 7.2.24.
//  Copyright © 2024 Egzon Pllana. All rights reserved.
//

import UIKit

// MARK: - Rotate image -
public extension UIImage {
    /// Rotates the image by the specified number of degrees around its center.
    ///
    /// - Parameter degrees: The rotation angle in degrees (positive is clockwise).
    /// - Returns: A new rotated image, or `nil` if rendering fails.
    func rotated(by degrees: CGFloat) -> UIImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = self.scale
        let renderer = UIGraphicsImageRenderer(size: self.size, format: format)
        let rotatedImage = renderer.image { context in
            let cgContext = context.cgContext
            cgContext.translateBy(x: self.size.width / 2, y: self.size.height / 2)
            cgContext.rotate(by: degrees * CGFloat.pi / 180.0)
            self.draw(at: CGPoint(x: -self.size.width / 2, y: -self.size.height / 2))
        }
        return rotatedImage
    }
}
