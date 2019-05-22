//
//  WrapperImageZoomedView.swift
//  PageBasedSample
//
//  Created by Mayank Bhaskar on 4/18/19.
//  Copyright © 2019 InfoBeans. All rights reserved.
//

import Foundation
import UIKit

/*
 WrapperImageZoomedView shows the content when zoomed in using the CATiledLayer class.
 */
public class WrapperImageZoomedView: UIView {
    
    // MARK: - Property
    private var dataView: UIView? = nil
    private var imageSource: ImageSource!
    
    var alignment: PageAlignment = .center {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var fillColor = UIColor.white {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    // MARK: - Layer
    class CustomLayer: CATiledLayer {
        override class func fadeDuration() -> CFTimeInterval {
            return 0.0
        }
    }
    
    override public class var layerClass: AnyClass {
        return CustomLayer.self
    }
    
    // MARK: - Initializer
    convenience init(imageSource: ImageSource, dataView: UIView) {
        self.init()
        
        // Set Properties
        self.dataView = dataView
        self.imageSource = imageSource
        self.backgroundColor = UIColor.clear
        self.isUserInteractionEnabled = false
        self.contentMode = .redraw
        
        // Setup Layer
        let tiledLayer = self.layer as! CATiledLayer
        tiledLayer.levelsOfDetail = 4
        tiledLayer.levelsOfDetailBias = 3
        tiledLayer.tileSize = CGSize(width: 512.0, height: 512.0)
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Deinitializer
    deinit {
        self.layer.delegate = nil
        self.layer.removeFromSuperlayer()
    }
    
    // MARK: - Draw the content when zoomed in
    override public func draw(_ layer: CALayer, in ctx: CGContext) {
//        guard let page = self.page else {
//            return
//        }
        
        DispatchQueue.main.sync {
            
            // Draw only when zoomed-in
            if ctx.ctm.a != self.contentScaleFactor {
                // Fill Background
                ctx.setFillColor(self.fillColor.cgColor)
                ctx.fill(layer.bounds)
                
                
                // START: Draw the zoomed in image
                let imageRect = CGRect(origin: CGPoint.zero, size: (self.dataView?.frame.size)!)
                
                // save the context so that it can be undone later
                ctx.saveGState()
                
                // put the origin of the coordinate system at the top left
                ctx.translateBy(x: 0, y: (self.dataView?.frame.size.height)!)
                ctx.scaleBy(x: 1.0, y: -1.0)
                
                // draw the image in the context
                ctx.draw((self.imageSource.image?.cgImage)!, in: imageRect)
                
                // undo changes to the context
                ctx.restoreGState()
                
                // END: Draw the zoomed in image
            }
        }
    }
    
}
