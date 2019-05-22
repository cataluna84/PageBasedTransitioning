//
//  UIView+Extension.swift
//  PageBasedSample
//
//  Created by Mayank Bhaskar on 4/18/19.
//  Copyright © 2019 InfoBeans. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func drawImage(for scrollView: UIScrollView, imageRect: CGRect, alignment: PageAlignment, in ctx: CGContext) {
        ctx.saveGState()
        
        let scrollViewSize = scrollView.frame.size
        let displaySize = scrollViewSize.aspectFitSize(within: imageRect.size)
        var offsetX: CGFloat = imageRect.origin.x
        
        switch alignment {
        case .center:
            offsetX += (imageRect.width - displaySize.width) / 2.0
        case .left:
            offsetX += 0.0
        case .right:
            offsetX += imageRect.width - displaySize.width
        }
        let offsetY: CGFloat = imageRect.origin.y + (imageRect.height - displaySize.height) / 2.0
        ctx.translateBy(x: offsetX, y: offsetY)
        
        // scale by
        let scale = scrollViewSize.width != 0.0 ? displaySize.width / scrollViewSize.width : 1.0
        ctx.scaleBy(x: scale, y: scale)
        
//        let mediaBoxRect = scrollView.getBoxRect(.mediaBox)
//        let currentBoxRect = scrollView.getBoxRect(box)
//        let boxRect = mediaBoxRect.intersection(currentBoxRect)
        
        // Get the current rotation angle in the UIView
        let radians = atan2(scrollView.transform.b, scrollView.transform.a)
        let degrees = radians * 180 / .pi
        
        var rotationAngle = degrees.truncatingRemainder(dividingBy: 360)
        if rotationAngle < 0 {
            rotationAngle += 360
        }
        
        switch rotationAngle {
        case 90:
            ctx.scaleBy(x: 1.0, y: -1.0)
            ctx.rotate(by: -.pi / 2.0)
        case 180:
            ctx.scaleBy(x: 1.0, y: -1.0)
            ctx.translateBy(x: scrollViewSize.width, y: 0.0)
            ctx.rotate(by: .pi)
        case 270:
            ctx.translateBy(x: scrollViewSize.height, y: scrollViewSize.width)
            ctx.rotate(by: .pi / 2.0)
            ctx.scaleBy(x: -1.0, y: 1.0)
        default:
            ctx.translateBy(x: 0.0, y: scrollViewSize.height)
            ctx.scaleBy(x: 1.0, y: -1.0)
        }
        
        let clipRect = CGRect(origin: CGPoint.zero, size: scrollViewSize)
        ctx.clip(to: clipRect)
        ctx.translateBy(x: -scrollView.frame.origin.x, y: -scrollView.frame.origin.y)
        
        ctx.interpolationQuality = .high
        ctx.setRenderingIntent(.defaultIntent)
//        ctx.draw(, in: )
        ctx.restoreGState()
    }
}
