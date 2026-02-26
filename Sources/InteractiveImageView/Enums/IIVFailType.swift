//
//  IIVFailType.swift
//  InteractiveImageView
//
//  Created by Egzon Pllana on 11.09.22.
//  Copyright © 2022 Egzon Pllana. All rights reserved.
//

import Foundation

/// Enumerates failure types that can occur during interactions with an `InteractiveImageView`.
public enum IIVFailType: Sendable {
    /// The image cropping operation failed.
    case cropImageFailed
    /// Toggling the content mode failed due to a missing configured image.
    case toggleContentModeFailed
    /// Adjusting frames during zooming failed due to a missing image view.
    case adjustFramesWhenZoomingFailed
    /// The image view reference could not be retrieved.
    case getImageViewFailed
    /// The image could not be retrieved from the image view.
    case getImageFailed
    /// The image rotation operation failed.
    case rotateImageFailed
}
