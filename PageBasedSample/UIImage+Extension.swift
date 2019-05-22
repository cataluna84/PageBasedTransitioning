//
//  UIImage+AspectFit.swift
//  PageBasedSample
//
//  Created by Mayank Bhaskar on 4/8/19.
//  Copyright © 2019 InfoBeans. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    func tgr_aspectFitRectForSize(_ size: CGSize) -> CGRect {
        let targetAspect: CGFloat = size.width / size.height
        let sourceAspect: CGFloat = self.size.width / self.size.height
        var rect: CGRect = CGRect.zero
        
        if targetAspect > sourceAspect {
            rect.size.height = size.height
            rect.size.width = ceil(rect.size.height * sourceAspect)
            rect.origin.x = ceil((size.width - rect.size.width) * 0.5)
        } else {
            rect.size.width = size.width
            rect.size.height = ceil(rect.size.width / sourceAspect)
            rect.origin.y = ceil((size.height - rect.size.height) * 0.5)
        }
        
        return rect
    }
}
