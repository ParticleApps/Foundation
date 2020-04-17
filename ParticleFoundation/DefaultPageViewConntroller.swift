//
//  DefaultPageViewConntroller.swift
//  ParticleFoundation
//
//  Created by Rocco Del Priore on 4/16/20.
//  Copyright © 2020 Rocco Del Priore. All rights reserved.
//

import Foundation
import UIKit

public class DefaultPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    public var pageControl: UIPageControl? = nil
    
    public var managedViewControllers: [UIViewController] {
        didSet {
            if let viewController = managedViewControllers.first {
                self.setViewControllers([viewController],
                                            direction: .forward,
                                            animated: false,
                                            completion: nil)
            }
            else {
                self.setViewControllers(nil,
                                        direction: .forward,
                                        animated: false,
                                        completion: nil)
            }
            
            self.updatePageControl()
        }
    }
    
    public var currentPageIndex: Int {
        guard let viewController = self.viewControllers?.first else {
            return -1
        }
        return managedViewControllers.firstIndex(of: viewController) ?? -1
    }
    
    public var pageControlAttached: Bool = false {
        didSet {
            if (pageControl == nil || self.view.subviews.contains(pageControl ?? UIView())) && pageControlAttached {
                self.pageControl = UIPageControl()
                
                self.pageControl?.pageIndicatorTintColor = .darkGray
                self.pageControl?.currentPageIndicatorTintColor = .lightGray
                self.pageControl?.autoresizingMask = .flexibleWidth
                self.updatePageControl()
                
                self.view.addSubview(self.pageControl!)
                self.pageControl?.addConstraints([
                    NSLayoutConstraint.init(item: self.view,
                                            attribute: NSLayoutConstraint.Attribute.bottom,
                                            relatedBy: NSLayoutConstraint.Relation.equal,
                                            toItem: self.pageControl,
                                            attribute: NSLayoutConstraint.Attribute.bottom,
                                            multiplier: 1.0, constant: -15),
                    NSLayoutConstraint.init(item: self.view,
                                            attribute: NSLayoutConstraint.Attribute.centerX,
                                            relatedBy: NSLayoutConstraint.Relation.equal,
                                            toItem: self.pageControl,
                                            attribute: NSLayoutConstraint.Attribute.centerX,
                                            multiplier: 1.0, constant: 0),
                    NSLayoutConstraint.init(item: self.view,
                                            attribute: NSLayoutConstraint.Attribute.width,
                                            relatedBy: NSLayoutConstraint.Relation.lessThanOrEqual,
                                            toItem: self.pageControl,
                                            attribute: NSLayoutConstraint.Attribute.centerX,
                                            multiplier: 1.0, constant: -30),
                    NSLayoutConstraint.init(item: self.pageControl!,
                                            attribute: NSLayoutConstraint.Attribute.height,
                                            relatedBy: NSLayoutConstraint.Relation.equal,
                                            toItem: nil,
                                            attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                            multiplier: 1.0, constant: 30)
                ])
            }
            else {
                self.pageControl?.removeFromSuperview()
                self.pageControl = nil
            }
        }
    }
    
    public init(viewControllers: [UIViewController],
         style: UIPageViewController.TransitionStyle = .scroll,
         navigationOrientation: UIPageViewController.NavigationOrientation = .horizontal,
         options: [UIPageViewController.OptionsKey : Any]? = nil) {
        self.managedViewControllers = viewControllers
        super.init(transitionStyle: style,
                   navigationOrientation: navigationOrientation,
                   options: options)
        self.dataSource = self
        self.delegate = self
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Actions
    @objc private func updatePageControl() {
        self.pageControl?.numberOfPages = self.managedViewControllers.count
        self.pageControl?.currentPage = self.currentPageIndex
    }
    
    @objc public func changePage(viewController: UIViewController, direction: UIPageViewController.NavigationDirection, animated: Bool = true) {
        DispatchQueue.main.async {
            self.setViewControllers([viewController], direction: direction, animated: animated, completion: nil)
            self.updatePageControl()
        }
    }
    
    @objc public func slideToNextPage(wrapAround: Bool = false) {
        guard   let currentViewController = self.viewControllers?.first,
                let viewController = self.pageViewController(self, viewControllerAfter: currentViewController)
        else {
            if wrapAround, let viewController = self.viewControllers?.first {
                self.changePage(viewController: viewController, direction: .forward)
            }
            return
        }
        
        self.changePage(viewController: viewController, direction: .forward)
    }
    
    @objc public func slideToPreviousPage(wrapAround: Bool = false) {
        guard   let currentViewController = self.viewControllers?.first,
                let viewController = self.pageViewController(self, viewControllerBefore: currentViewController)
        else {
            if wrapAround, let viewController = self.viewControllers?.last {
                self.changePage(viewController: viewController, direction: .reverse)
            }
            return
        }
        
        self.changePage(viewController: viewController, direction: .reverse)
    }
    
    //MARK: UIPageViewControllerDelegate
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        self.updatePageControl()
    }
    
    //MARK: UIPageController DataSource
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = managedViewControllers.firstIndex(of: viewController), index+1 < managedViewControllers.count else {
            return nil
        }
        return managedViewControllers[index+1]
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = managedViewControllers.firstIndex(of: viewController), index-1 >= 0 else {
                return nil
        }
        return managedViewControllers[index-1]
    }
}
