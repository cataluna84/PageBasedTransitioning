//
//  LayoutMargin.swift
//  PageBasedSample
//
//  Created by Mayank Bhaskar on 4/19/19.
//  Copyright © 2019 InfoBeans. All rights reserved.
//

import Foundation
import UIKit

public struct LayoutMargin {
    
    var horizontal: CGFloat
    var vertical: CGFloat
    
    static var zero: LayoutMargin {
        return LayoutMargin(horizontal: 0.0, vertical: 0.0)
    }
    
}

extension LayoutMargin {
    
    init(margin: CGFloat) {
        self.horizontal = margin
        self.vertical = margin
    }
    
}
