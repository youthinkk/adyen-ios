//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Adds helper functionality to any `UIView` instance through the `adyen` property.
/// :nodoc:
extension AdyenScope where Base: UIView {

    /// :nodoc:
    public func snapShot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(base.bounds.size, false, 0.0)
        base.drawHierarchy(in: base.bounds, afterScreenUpdates: true)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
    
    /// :nodoc:
    public func hide(animationKey: String,
                     hidden: Bool,
                     animated: Bool) {
        if animated {
            hideWithAnimation(animationKey: animationKey,
                              hidden)
        } else {
            hideWithoutAnimation(hidden)
        }
    }

    /// :nodoc:
    private func hideWithAnimation(animationKey: String,
                                   _ hidden: Bool) {
        let context = KeyFrameAnimationContext(animationKey: animationKey,
                                               duration: 0.35,
                                               delay: 0,
                                               options: [.calculationModeCubicPaced, .beginFromCurrentState],
                                               animations: {
                                                   UIView.addKeyframe(withRelativeStartTime: hidden ? 0.5 : 0, relativeDuration: 0.5) {
                                                       self.base.isHidden = hidden
                                                   }
                                                
                                                   UIView.addKeyframe(withRelativeStartTime: hidden ? 0 : 0.5, relativeDuration: 0.5) {
                                                       self.base.alpha = hidden ? 0 : 1
                                                   }
                                               }, completion: { _ in
                                                   self.base.isHidden = hidden
                                                   self.base.alpha = hidden ? 0 : 1
                                                   self.base.adyen.updatePreferredContentSize()
                                               })
        base.animateKeyframes(context: context)
    }
    
    /// :nodoc:
    private func hideWithoutAnimation(_ hidden: Bool) {
        guard base.isHidden != hidden else { return }
        
        base.isHidden = hidden
        base.alpha = hidden ? 0 : 1
        base.adyen.updatePreferredContentSize()
    }
}
