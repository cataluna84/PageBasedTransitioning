//
//  ModelController.swift
//  PageBasedSample
//
//  Created by Mayank Bhaskar on 3/22/19.
//  Copyright © 2019 InfoBeans. All rights reserved.
//

import UIKit

/*
 A controller object that manages a simple model -- a collection of month names.
 
 The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
 It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.
 
 There is no need to actually create view controllers for each page in advance -- indeed doing so incurs unnecessary overhead. Given the data model, these methods create, configure, and return a new view controller on demand.
 */


class ModelController: NSObject, UIPageViewControllerDataSource {

    var pageData: [ImageSource] = []
    
    let localImageDataSource = [ImageSource(imageString: "1")!, ImageSource(imageString: "2")!, ImageSource(imageString: "3")!, ImageSource(imageString: "4")!, ImageSource(imageString: "5")!, ImageSource(imageString: "6")!, ImageSource(imageString: "7")!, ImageSource(imageString: "8")!, ImageSource(imageString: "9")!, ImageSource(imageString: "10")!, ImageSource(imageString: "11")!, ImageSource(imageString: "12")!, ImageSource(imageString: "13")!, ImageSource(imageString: "14")!, ImageSource(imageString: "15")!, ImageSource(imageString: "16")!, ImageSource(imageString: "17")!, ImageSource(imageString: "18")!, ImageSource(imageString: "19")!, ImageSource(imageString: "20")!, ImageSource(imageString: "21")!, ImageSource(imageString: "22")!, ImageSource(imageString: "23")!, ImageSource(imageString: "24")!, ImageSource(imageString: "25")!, ImageSource(imageString: "26")!, ImageSource(imageString: "27")!, ImageSource(imageString: "28")!, ImageSource(imageString: "29")!, ImageSource(imageString: "30")!, ImageSource(imageString: "31")!, ImageSource(imageString: "32")!, ImageSource(imageString: "33")!, ImageSource(imageString: "34")!, ImageSource(imageString: "35")!, ImageSource(imageString: "36")!, ImageSource(imageString: "37")!, ImageSource(imageString: "38")!]
    
    private var viewControllerCache = [Int : DataViewController]()

    private(set) var numberOfPages = 0

    // MARK: - Image Size
    public var maxDataImageSize: CGSize {
        var maxImageSize = CGSize.zero
        for imageSource in self.localImageDataSource {
            if let image = imageSource.image {
                let imageSize = image.size
                maxImageSize.width = max(maxImageSize.width, imageSize.width)
                maxImageSize.height = max(maxImageSize.height, imageSize.height)
            }
        }
        
        return maxImageSize
    }

    override init() {
        super.init()
        // Create the data model.
        pageData = localImageDataSource
        numberOfPages = localImageDataSource.count
    }

    private func viewControllerAtIndex(index: Int, storyboard: UIStoryboard) -> DataViewController? {
        // Return the data view controller for the given index.
        if (self.pageData.count == 0) || (index >= self.pageData.count) || (index < 0) {
            return nil
        }

        // Create a new view controller and pass suitable data.
        let dataViewController = storyboard.instantiateViewController(withIdentifier: "DataViewController") as! DataViewController
        
        dataViewController.imageFromDataSource = self.localImageDataSource[index]
        dataViewController.pageNumber = index + 1
        
        return dataViewController
    }

    private func indexOfViewController(_ viewController: DataViewController) -> Int {
        // Return the index of the given data view controller.
        // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
        return pageData.firstIndex(of: viewController.imageFromDataSource!) ?? NSNotFound
    }
    
    public func pageNumberOfViewController(_ viewController: DataViewController) -> Int {
        return (indexOfViewController(viewController) + 1)
    }

    // MARK: - Get DataViewController and create caches for the pageViewControllers
    public func pageViewController(at pageNumber: Int, _ storyboard: UIStoryboard) -> DataViewController? {
        
        // Manage Cache
        let numberOfCachesInOneDirection = 4
        let numberOfCachesInOneDirectionToCreate = numberOfCachesInOneDirection - 1
        let minCachePageNumber = pageNumber - numberOfCachesInOneDirection > 1 ? pageNumber - numberOfCachesInOneDirection : 1
        let maxCachePageNumber = pageNumber + numberOfCachesInOneDirection < self.numberOfPages ? pageNumber + numberOfCachesInOneDirection : self.numberOfPages
        var newViewControllerCache = [Int: DataViewController]()
        for cache in self.viewControllerCache {
            if cache.key >= minCachePageNumber && cache.key <= maxCachePageNumber {
                newViewControllerCache[cache.key] = cache.value
            }
        }
        
        // Instantiate uncached dataViewControllers
        let minCachePageNumberToCreate = pageNumber - numberOfCachesInOneDirectionToCreate > 1 ? pageNumber - numberOfCachesInOneDirectionToCreate : 1
        let maxCachePageNumberToCreate = pageNumber + numberOfCachesInOneDirectionToCreate < self.numberOfPages ? pageNumber + numberOfCachesInOneDirectionToCreate : self.numberOfPages
        let pageNumbers = Array(minCachePageNumberToCreate ... maxCachePageNumberToCreate).sorted { abs($0 - pageNumber) < abs($1 - pageNumber) }
        for pageNumber in pageNumbers {
            if newViewControllerCache[pageNumber] == nil {
                newViewControllerCache[pageNumber] = viewControllerAtIndex(index: pageNumber - 1, storyboard: storyboard)
            }
        }
        
        // Set new cache
        self.viewControllerCache = newViewControllerCache
        
        // Return dataViewController
        return self.viewControllerCache[pageNumber]
    }
    
    // MARK: - Clear cache
    func clearCache() {
        self.viewControllerCache = [:]
    }
    
    // TODO: - Check for the case in which there are odd number of pages and have to return an empty view controller at the end as a placeholder
    var emptyPageViewController: DataViewController {
        return DataViewController(nibName: nil, bundle: nil)
    }
    
    // MARK: - Page View Controller Data Source
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        // Return previous dataViewController
        if let pageNumber = (viewController as! DataViewController).pageNumber {
            if let previousViewController = self.pageViewController(at: pageNumber - 1, viewController.storyboard!) {
                previousViewController.alignment = .center
                if pageViewController.viewControllers?.count == 2 {
                    if (pageNumber % 2 == 1)  {
                        previousViewController.alignment = .left
                    } else {
                        previousViewController.alignment = .right
                    }
                }
                return previousViewController
            }
            else if pageViewController.viewControllers?.count == 2 {
                if pageNumber == 1 {
                    return self.emptyPageViewController
                }
            }
        }
        
        return nil

    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        // Return next dataViewController
        if let pageNumber = (viewController as! DataViewController).pageNumber {
            if let nextViewController = self.pageViewController(at: pageNumber + 1, viewController.storyboard!) {
                nextViewController.alignment = .center
                if pageViewController.viewControllers?.count == 2 {
                    if (nextViewController.pageNumber! % 2 == 1)  {
                        nextViewController.alignment = .left
                    }
                    else {
                        nextViewController.alignment = .right
                    }
                }
                return nextViewController
            }
        }
        
        return nil
    }

}

