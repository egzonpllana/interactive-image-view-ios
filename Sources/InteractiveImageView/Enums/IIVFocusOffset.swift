//
//  IIVFocusOffset.swift
//  InteractiveImageView
//
//  Created by Egzon Pllana on 28.8.22.
//  Copyright © 2022 Egzon Pllana. All rights reserved.
//

import Foundation

/// Defines the initial scroll offset when configuring an `InteractiveImageView`.
public enum IIVFocusOffset: Int, Sendable {
    /// Positions the image at the top-left origin.
    case beginning
    /// Centers the image within the visible bounds.
    case center
}
