//
//  RootViewController.swift
//  PageBasedSample
//
//  Created by Mayank Bhaskar on 3/22/19.
//  Copyright © 2019 InfoBeans. All rights reserved.
//

import UIKit

class RootViewController: UIViewController, UIPageViewControllerDelegate {

    private var layoutMargin = LayoutMargin.zero
    private var backgroundColor = UIColor.lightGray
    
    private weak var scrollView: UIScrollView!
    private var pageViewController: UIPageViewController?
    private weak var pageViewWidthConstraint: NSLayoutConstraint!
    private weak var pageViewHeightConstraint: NSLayoutConstraint!
    private weak var pageViewLeadingConstraint: NSLayoutConstraint!
    private weak var pageViewTrailingConstraint: NSLayoutConstraint!
    private weak var pageViewTopConstraint: NSLayoutConstraint!
    private weak var pageViewBottomConstraint: NSLayoutConstraint!
    
    private let zoomFactor: CGFloat = 2.0
    private var startTimeInSeconds: Double? = nil
    private var endTimeInSeconds: Double? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // START: Setup Scroll View
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.zoomScale = 1.0
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 8.0
        scrollView.decelerationRate = UIScrollView.DecelerationRate.fast
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        // Safe area insets are set to never automatically adjust
        scrollView.contentInsetAdjustmentBehavior = .never
        
        self.view.addSubview(scrollView)
        var constraintsForScrollView = [NSLayoutConstraint]()
        constraintsForScrollView.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: ["view": scrollView]))
        constraintsForScrollView.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: ["view": scrollView]))
        NSLayoutConstraint.activate(constraintsForScrollView)
        self.scrollView = scrollView
        // END: Setup Scroll View
        
        
        // Array for a set of initial view controllers
        var viewControllers = [DataViewController]()

        let startingViewController: DataViewController = self.modelController.pageViewController(at: 1, self.storyboard!)!
        
        viewControllers = [startingViewController]
        
        // Configure the page view controller and add it as a child view controller.
        self.pageViewController = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
        self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: false, completion: {done in })
        self.pageViewController!.delegate = self
        self.pageViewController!.dataSource = self.modelController
        self.pageViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChild(self.pageViewController!)
        self.scrollView.addSubview(self.pageViewController!.view)
        self.pageViewController!.didMove(toParent: self)

        // Set constraints to Page View Controller
        let view = pageViewController?.view!
        let pageViewWidthConstraint = NSLayoutConstraint(item: view!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.view.frame.width)
        let pageViewHeightConstraint = NSLayoutConstraint(item: view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.view.frame.height)
        
        let pageViewLeadingConstraint = NSLayoutConstraint(item: view!, attribute: .leading, relatedBy: .equal, toItem: scrollView, attribute: .leading, multiplier: 1.0, constant: 0.0)
        let pageViewTrailingConstraint = NSLayoutConstraint(item: view!, attribute: .trailing, relatedBy: .equal, toItem: scrollView, attribute: .trailing, multiplier: 1.0, constant: 0.0)
        let pageViewTopConstraint = NSLayoutConstraint(item: view!, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1.0, constant: 0.0)
        let pageViewBottomConstraint = NSLayoutConstraint(item: view!, attribute: .bottom, relatedBy: .equal, toItem: scrollView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        
        NSLayoutConstraint.activate([pageViewWidthConstraint, pageViewHeightConstraint, pageViewLeadingConstraint, pageViewTrailingConstraint, pageViewTopConstraint, pageViewBottomConstraint])
        self.pageViewWidthConstraint = pageViewWidthConstraint
        self.pageViewHeightConstraint = pageViewHeightConstraint
        self.pageViewLeadingConstraint = pageViewLeadingConstraint
        self.pageViewTrailingConstraint = pageViewTrailingConstraint
        self.pageViewTopConstraint = pageViewTopConstraint
        self.pageViewBottomConstraint = pageViewBottomConstraint
        
        // Set Delegate to Scroll View
        self.scrollView.delegate = self
        
        // START: Gesture Recognizers setup
        // Add Gesture Recognizer to Hide or Show Navigation Bar
        let navigationBarGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleOneFingerSingleTap))
        navigationBarGestureRecognizer.numberOfTouchesRequired = 1
        navigationBarGestureRecognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(navigationBarGestureRecognizer)
        
        // Add Gesture Recognizer to Zoom-in
        let zoomInGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleOneFingerDoubleTap))
        zoomInGestureRecognizer.numberOfTouchesRequired = 1
        zoomInGestureRecognizer.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(zoomInGestureRecognizer)
        
        // Add Gesture Recognizer to Zoom-out
        let zoomOutGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTwoFingerSingleTap))
        zoomOutGestureRecognizer.numberOfTouchesRequired = 2
        zoomOutGestureRecognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(zoomOutGestureRecognizer)
        
        // Add Dependency to Gesture Recognizers
        self.pageViewController?.gestureRecognizers.forEach { zoomInGestureRecognizer.require(toFail: $0) }
        self.pageViewController?.gestureRecognizers.forEach { navigationBarGestureRecognizer.require(toFail: $0) }
        navigationBarGestureRecognizer.require(toFail: zoomInGestureRecognizer)
        // END: Gesture Recognizers setup
    }
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Update
        self.resetSize()
        self.updateMargin()
    }

    // MARK: - Layout
    private func resetSize() {
        // Get Max Image Size
        var maxImageSize = modelController.maxDataImageSize
        if self.pageViewController?.viewControllers?.count == 2 {
            maxImageSize.width *= 2.0
        }

        // Set Size Constraints
        var viewSize = self.view.frame.size
        viewSize.width -= self.layoutMargin.horizontal * 2.0
        viewSize.height -= self.layoutMargin.vertical * 2.0

        // DO NOT REMOVE: -
        // Commented to resize the view so it does not have a leading and trailing constraint in case of iPAD
//        let aspectFitSize = modelController.maxDataImageSize.aspectFitSize(within: viewSize)
//        self.pageViewWidthConstraint.constant = aspectFitSize.width
//        self.pageViewHeightConstraint.constant = aspectFitSize.height

        // Reset Zoom Scale
        self.scrollView.zoomScale = 1.0

        // Enable Gesture Recognizers of Page View Controller
        self.pageViewController?.gestureRecognizers.forEach { $0.isEnabled = true }

        // Update Layout
        self.view.layoutIfNeeded()
    }

    // Update margins so that the scroll view is not zoomed in from the top left corner
    private func updateMargin() {
        let xOffset = max(0, (self.view.frame.width - (self.pageViewController?.view.frame.width)!) / 2.0)
        self.pageViewLeadingConstraint.constant = xOffset
        self.pageViewTrailingConstraint.constant = xOffset

        let yOffset = max(0, (self.view.frame.height - (self.pageViewController?.view.frame.height)!) / 2.0)
        self.pageViewTopConstraint.constant = yOffset
        self.pageViewBottomConstraint.constant = yOffset

        self.view.layoutIfNeeded()
    }

    var modelController: ModelController {
        // Return the model controller object, creating it if necessary.
        // In more complex implementations, the model controller may be passed to the view controller.
        if _modelController == nil {
            _modelController = ModelController()
        }
        return _modelController!
    }

    var _modelController: ModelController? = nil

    // MARK: - UIPageViewController delegate methods
    func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewController.SpineLocation {
        
        // TODO: - isTransitioning flag has to be configured
        
        // Reset Flag
//        self.isTransitioning = false
        
        // Clear Cache
        // --- To handle UIPageViewController's bug
        if orientation != UIApplication.shared.statusBarOrientation {
            self.modelController.clearCache()
        }
        
        // Get current view controller
        let pageNumber = (self.pageViewController?.viewControllers?.first as? DataViewController)?.pageNumber ?? 1
        let currentViewController = self.modelController.pageViewController(at: pageNumber, self.storyboard!)!
        currentViewController.alignment = .center
        
        // Single Page
        if self.modelController.numberOfPages == 1 {
            let viewControllers = [currentViewController]
            self.pageViewController?.setViewControllers(viewControllers, direction: .forward, animated: false, completion: nil)
            return .min
        }
        
        // Portrait
        if orientation == .portrait && UIDevice.current.userInterfaceIdiom == .phone {
            let viewControllers = [currentViewController]
            self.pageViewController?.setViewControllers(viewControllers, direction: .forward, animated: false, completion: nil)
            self.pageViewController?.isDoubleSided = false
            return .min
        }
        
        // For iPad, there should be two viewControllers side-by-side
        var viewControllers = [UIViewController]()
        if UIDevice.current.userInterfaceIdiom == .pad {
            if pageNumber % 2 == 0 {
                currentViewController.alignment = .left
                let previousViewController = self.modelController.pageViewController(at: pageNumber - 1, self.storyboard!)!
                previousViewController.alignment = .right
                viewControllers = [previousViewController, currentViewController]
            } else {
                currentViewController.alignment = .left

                if let nextViewController = self.modelController.pageViewController(at: pageNumber + 1, self.storyboard!) {
                    nextViewController.alignment = .right
                    viewControllers = [currentViewController, nextViewController]
                }
            }
            
            self.pageViewController?.isDoubleSided = true
            self.pageViewController?.setViewControllers(viewControllers, direction: .forward, animated: false, completion: nil)
            
            return .mid
        }
        
        // By default, return to a the double view-controller state
        return .mid
    }
}

// MARK: - Extension for UIScrollViewDelegate
extension RootViewController: UIScrollViewDelegate {
    
    // MARK: - Utility
    private func hideNavigationBarIfRequired() {
        if let navigationController = self.navigationController {
            if !navigationController.isNavigationBarHidden {
                navigationController.setNavigationBarHidden(true, animated: true)
                navigationController.setToolbarHidden(true, animated: true)
            }
        }
    }
    
    // MARK: - Scroll View Delegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.pageViewController?.view
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        // Set Flag
        startTimeInSeconds = Date().timeIntervalSince1970
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // Update margins so that the scroll view is not zoomed in from the top left corner
        self.updateMargin()
        
        // Enable or Disable Gesture Recognizers of Page View Controller
        let isEnabled = scrollView.zoomScale == 1.0
        // Disables the gesture recognizers in the zoomed in state
        self.pageViewController?.gestureRecognizers.forEach{ $0.isEnabled = isEnabled }
    }
    
    // For paging in a zoomed state in the UIScrollView
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        var elapsedTime:Double = 0
        endTimeInSeconds = Date().timeIntervalSince1970
        
        if let startTimeInSeconds = startTimeInSeconds {
            elapsedTime = endTimeInSeconds! - startTimeInSeconds
        }
        
        let position = scrollView.contentOffset.x - scrollView.frame.origin.x
        
        // If the elapsed zoomed timer is greater than 2 seconds. Here, it is used to stop an edge-case, implementing the zoomed and panned behaviour which may sometimes result in the next or the previous page being scrolled to.
        if elapsedTime > 2 {
            
            // Get Current View Controller
            let pageNumber = (self.pageViewController?.viewControllers?.first as? DataViewController)?.pageNumber ?? 1
            
            // Edge-case for the last page zoomed dragging state, for iPad
            if UIDevice.current.userInterfaceIdiom == .pad {
                if pageNumber+1 == modelController.numberOfPages {
                    return
                }
            }
            
            // Zoomed panning from to the right edge and adding 50 points to the right edge of the screen
            if (position >= ((scrollView.contentSize.width - scrollView.frame.size.width) + CGFloat(50))) {
                
                // Array for a set of dataViewControllers
                var viewControllers = [DataViewController]()
                
                // Set the next dataViewController and call it at the end of the if block
                if let nextViewController = self.modelController.pageViewController(at: pageNumber + 1, self.storyboard!) {
                    // Set alignment
                    nextViewController.alignment = .center
                    viewControllers = [nextViewController]
                    
                    // If there is a two-viewed layout on iPAD, request the +2 and +3 page from the view controllers, because in a two-viewed layout, always the first view controller is returned
                    if self.pageViewController?.viewControllers?.count == 2 {

                        if let nextViewController = self.modelController.pageViewController(at: pageNumber + 2, self.storyboard!) {
                        
                            if let secondNextViewController = self.modelController.pageViewController(at: pageNumber + 3, self.storyboard!) {
                                
                                if ((pageNumber+2) % 2 == 1) {
                                    secondNextViewController.alignment = .left
                                } else {
                                    secondNextViewController.alignment = .right
                                }
                                
                                viewControllers = [nextViewController, secondNextViewController]
                            }
                            
                            if ((pageNumber+1) % 2 == 1) {
                                nextViewController.alignment = .left
                            } else {
                                nextViewController.alignment = .right
                            }
                        }
                    }
                }
                
                if viewControllers.count != 0 {
                    // Method to call the next view controller in the array of DataViewControllers
                    self.pageViewController?.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
                }
            } // Zoomed panning from the left and substracting 50 points from the left edge of the screen
            else if position < (scrollView.frame.origin.x - CGFloat(50)) {
                
                // Array for a set of dataViewControllers
                var viewControllers = [DataViewController]()
                
                // Set the previous dataViewController and call it at the end of the elseif block
                if let previousViewController = self.modelController.pageViewController(at: pageNumber - 1, self.storyboard!) {
                    previousViewController.alignment = .center
                    viewControllers = [previousViewController]
                
                    if self.pageViewController?.viewControllers?.count == 2 {
                        
                        if let secondPreviousViewController = self.modelController.pageViewController(at: pageNumber - 2, self.storyboard!) {

                            // Set alignment of view controllers
                            if ((pageNumber-2) % 2 == 0) {
                                secondPreviousViewController.alignment = .left
                            } else {
                                secondPreviousViewController.alignment = .right
                            }

                            if ((pageNumber-1) % 2 == 1) {
                                previousViewController.alignment = .right
                            } else {
                                previousViewController.alignment = .left
                            }
                            
                            viewControllers = [secondPreviousViewController, previousViewController]
                        }
                    }
                }
                
                if viewControllers.count != 0 {
                    // Method to call the previous view controller in the array of DataViewControllers
                    self.pageViewController?.setViewControllers(viewControllers, direction: .reverse, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    // MARK: - Gesture Recognizer
    @objc func handleOneFingerSingleTap(sender: UIGestureRecognizer) {
        // Hide or Show Navigation Controller
        if sender.state == .ended {
            if let navigationController = self.navigationController {
                navigationController.setNavigationBarHidden(!navigationController.isNavigationBarHidden, animated: true)
                navigationController.setToolbarHidden(!navigationController.isToolbarHidden, animated: true)
            }
        }
    }
    
    @objc func handleOneFingerDoubleTap(sender: UIGestureRecognizer) {
        // Zoom-in & check that zoomScale is completely zoomed out, then hide Navigation Bar
        if sender.state == .ended && self.scrollView.zoomScale == 1.0 {
            var zoomInScale = self.scrollView.zoomScale * self.zoomFactor
            if zoomInScale > self.scrollView.maximumZoomScale {
                zoomInScale = self.scrollView.maximumZoomScale
            }
            
            self.scrollView.setZoomScale(zoomInScale, animated: true)
            self.hideNavigationBarIfRequired()
        } else {        // Zoom-out & reset the zoomScale back to 1.0, then show Navigation bar
            var zoomOutScale = self.scrollView.zoomScale / self.zoomFactor
            if zoomOutScale < self.scrollView.minimumZoomScale {
                zoomOutScale = self.scrollView.minimumZoomScale
            }
            
            self.scrollView.setZoomScale(zoomOutScale, animated: true)
            
            // Hide or show navigation controller
            if let navigationController = self.navigationController {
                navigationController.setNavigationBarHidden(!navigationController.isNavigationBarHidden, animated: true)
                navigationController.setToolbarHidden(!navigationController.isToolbarHidden, animated: true)
            }
        }
    }
    
    @objc func handleTwoFingerSingleTap(sender: UIGestureRecognizer) {
        // Zoom-out & Hide Navigation Bar
        if sender.state == .ended {
            var zoomOutScale = self.scrollView.zoomScale / self.zoomFactor
            if zoomOutScale < self.scrollView.minimumZoomScale {
                zoomOutScale = self.scrollView.minimumZoomScale
            }
            
            self.scrollView.setZoomScale(zoomOutScale, animated: true)
            self.hideNavigationBarIfRequired()
        }
    }
    
}
