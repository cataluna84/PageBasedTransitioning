//
//  DataViewController.swift
//  PageBasedSample
//
//  Created by Mayank Bhaskar on 3/22/19.
//  Copyright © 2019 InfoBeans. All rights reserved.
//

import UIKit

class DataViewController: UIViewController, UIScrollViewDelegate {
    
//    var dataObject: String = ""
    var imageFromDataSource: ImageSource? = nil
    var pageNumber: Int?
    
    private let zoomFactor: CGFloat = 2.0

    private var wrapperImageView: WrapperImageView?
    private var wrapperImageZoomedView: WrapperImageZoomedView?
    
    var alignment: PageAlignment = .center {
        didSet {
            self.wrapperImageView?.alignment = self.alignment
            self.wrapperImageZoomedView?.alignment = self.alignment
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // START: Setup wrapper for ImageView and Zoomed image view
        let wrapperImageView = WrapperImageView(imageSource: imageFromDataSource, dataView: (self.view!))
        wrapperImageView.alignment = self.alignment
        wrapperImageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(wrapperImageView)
        self.wrapperImageView = wrapperImageView
        
        let wrapperImageZoomedView = WrapperImageZoomedView(imageSource: imageFromDataSource!, dataView: (self.view!))
        wrapperImageZoomedView.alignment = self.alignment
        wrapperImageZoomedView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(wrapperImageZoomedView)
        self.wrapperImageZoomedView = wrapperImageZoomedView
        // END: Setup wrappers for ImageView and Zoomed image view
        
        // Add constraints
        var constraints = [NSLayoutConstraint]()
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: ["view": self.wrapperImageView!]))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: ["view": self.wrapperImageView!]))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: ["view": self.wrapperImageZoomedView!]))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: ["view": self.wrapperImageZoomedView!]))
        NSLayoutConstraint.activate(constraints)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }


}

