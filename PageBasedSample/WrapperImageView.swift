//
//  WrapperImageView.swift
//  PageBasedSample
//
//  Created by Mayank Bhaskar on 4/8/19.
//  Copyright © 2019 InfoBeans. All rights reserved.
//

import Foundation
import UIKit

public class WrapperImageView: UIView {
    
    // MARK: - Property
    static var countImages: Int = 0

    private var dataView: UIView? = nil
    private weak var imageView: UIImageView!
    private var imageViewConstraints = [NSLayoutConstraint]()
    private var imageSource: ImageSource!

    var alignment: PageAlignment = .center {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    var fillColor = UIColor.white {
        didSet {
            self.imageView.backgroundColor = self.fillColor
        }
    }

    // MARK: - Initializer
    convenience init(imageSource: ImageSource?, dataView: UIView) {
        self.init(frame: dataView.frame)
        
        // Set Properties
        self.backgroundColor = UIColor.clear
        self.isUserInteractionEnabled = false
        self.dataView = dataView
        self.imageSource = imageSource!
        
        // Setup Image View
        let imageView = UIImageView()
        imageView.backgroundColor = self.fillColor
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)
        self.imageView = imageView
        
        // Generate Image
        self.generateImage()
    }

    private override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        guard let image = self.imageView.image else {
            return
        }
        
        // Update Image View Constraints
        NSLayoutConstraint.deactivate(self.imageViewConstraints)
        var constraints = [NSLayoutConstraint]()
        
        // START: Image AspectFit changes

        // image size according to aspectFit
//        let displaySize = self.frame.size
        
        let displaySize = image.size.aspectFitSize(within: self.frame.size)
        // END: Image AspectFit changes

        
        switch self.alignment {
        case .center:
            constraints.append(NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: self.imageView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        case .left:
            constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]", options: [], metrics: nil, views: ["view": self.imageView!]))
        case .right:
            constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:[view]|", options: [], metrics: nil, views: ["view": self.imageView!]))
        }
        constraints.append(NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: self.imageView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        constraints.append(NSLayoutConstraint(item: self.imageView!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: displaySize.width))
        constraints.append(NSLayoutConstraint(item: self.imageView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: displaySize.height))
        
        NSLayoutConstraint.activate(constraints)
        self.imageViewConstraints = constraints
    }
    
    private func generateImage() {
        let size = dataView?.frame.size

        if size?.width == 0.0 || size?.height == 0.0 {
            return
        }

//        guard let page = self.page else {
//            return
//        }

        // Generate Image on Concurrent Queue
        let pageSize = dataView?.frame.size
        
        // START: Image AspectFit changes
        // image size according to aspectFit
//        let imageSize = (pageSize?.aspectFitSize(within: size!))!
        
        // image size to scaleFit along the page
        let imageSize = CGSize(width: pageSize!.width, height: pageSize!.height)
        // END: Image AspectFit changes
        
        
        let imageRect = CGRect(origin: CGPoint.zero, size: pageSize!)
        

        let queue = DispatchQueue(label: "Image Generation Queue for page: \(WrapperImageView.countImages)", attributes: .concurrent)
        WrapperImageView.countImages = WrapperImageView.countImages + 1

        queue.async {
            UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
            let ctx = UIGraphicsGetCurrentContext()!
            
            // save the context so that it can be undone later
            ctx.saveGState()
            
            // put the origin of the coordinate system at the top left
            ctx.translateBy(x: 0, y: imageSize.height)
            ctx.scaleBy(x: 1.0, y: -1.0)
            
            // draw the image in the context
            ctx.draw((self.imageSource.image?.cgImage)!, in: imageRect)
//            self.drawImage(for: dataScrollView, imageRect: imageRect, alignment: .left, in: ctx)

            // undo changes to the context
            ctx.restoreGState()
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            DispatchQueue.main.async { [weak self] in
                self?.imageView.image = image
                self?.setNeedsLayout()
            }
        }
    }
}
