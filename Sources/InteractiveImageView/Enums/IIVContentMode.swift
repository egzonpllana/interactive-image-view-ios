//
//  IIVContentMode.swift
//  InteractiveImageView
//
//  Created by Egzon Pllana on 28.8.22.
//  Copyright © 2022 Egzon Pllana. All rights reserved.
//

import UIKit

/// Defines how the image fills the bounds of an `InteractiveImageView`.
public enum IIVContentMode: Equatable, Sendable {
    /// Scales the image to fill the view while maintaining aspect ratio; content may be clipped.
    case aspectFill
    /// Scales the image to fit entirely within the view while maintaining aspect ratio.
    case aspectFit
    /// Scales the image to fill the width of the view.
    case widthFill
    /// Scales the image to fill the height of the view.
    case heightFill
    /// Applies a custom scale offset multiplier to the width-based scale.
    case customOffset(offset: CGFloat)
}
