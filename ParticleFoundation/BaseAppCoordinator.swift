//
//  BaseAppCoordinator.swift
//  ParticleFoundation
//
//  Created by Rocco Del Priore on 10/3/18.
//  Copyright © 2018 Rocco Del Priore. All rights reserved.
//

import MapKit
import MessageUI
import Foundation
import SafariServices

public enum MapOption: String {
    case appleMaps  = "AppleMaps"
    case googleMaps = "GoogleMaps"
    case waze       = "Waze"
}
public typealias CoordinatorNavigationDelegate = NSObject & UINavigationControllerDelegate & UIViewControllerTransitioningDelegate

open class BaseAppCoordinator: NSObject, MFMailComposeViewControllerDelegate {
    open var navigationController = UINavigationController() //I dont like that this is not publically facing to other classes
    open private(set) var navigationControllerDelegate: CoordinatorNavigationDelegate? = nil
    private var presentationStack: [UIViewController] = [UIViewController]()
    open var window: UIWindow {
        didSet {
            self.navigationController.delegate = navigationControllerDelegate
            self.window.rootViewController = self.navigationController
            self.window.makeKeyAndVisible()
        }
    }
    
    //MARK: Initializers
    override public init() {
        self.window = UIWindow()
    }
    
    //MARK: Accessors
    @objc open func presentedViewController() -> UIViewController {
        if let presentedViewController = self.presentationStack.last {
            return presentedViewController
        }
        return self.navigationController
    }
    @objc open func topViewController() -> UIViewController {
        if let presentedNavigationViewController = self.presentedViewController() as? UINavigationController {
            return presentedNavigationViewController.topViewController ?? presentedNavigationViewController
        }
        return self.presentedViewController()
    }
    
    //MARK: Actions
    public func pushViewController(viewController: UIViewController, animated: Bool = true) {
        if let subnavigationController = self.presentedViewController() as? UINavigationController {
            subnavigationController.pushViewController(viewController, animated: animated)
        }
    }
    open func present(viewController: UIViewController, animated: Bool = true, custom: Bool = false,
                      withNavigationController: Bool = false, completion: (() -> Swift.Void)? = nil) {
        if withNavigationController {
            let subNavigationController = UINavigationController(rootViewController: viewController)
            
            if custom {
                subNavigationController.delegate               = navigationControllerDelegate
                subNavigationController.transitioningDelegate  = navigationControllerDelegate
                subNavigationController.modalPresentationStyle = UIModalPresentationStyle.custom
            }
//            else if #available(iOS 13.0, *) {
//                viewController.modalPresentationStyle = .fullScreen
//            }
            
            self.presentedViewController().present(subNavigationController, animated: animated, completion: nil)
            self.presentationStack.append(subNavigationController)
        }
        else {
            if custom {
                viewController.transitioningDelegate  = navigationControllerDelegate
                viewController.modalPresentationStyle = UIModalPresentationStyle.custom
            }
//            else if #available(iOS 13.0, *) {
//                viewController.modalPresentationStyle = .fullScreen
//            }
            
            self.presentedViewController().present(viewController, animated: animated, completion: nil)
            self.presentationStack.append(viewController)
        }
    }
    open func presentAlert(title: String?, subtitle: String?, handler: ((UIAlertAction) -> Swift.Void)? = nil) {
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: handler))
        
        self.presentedViewController().present(alert, animated: true, completion: nil)
    }
    @objc open func navigateBack() {
        if let subnavigationController = self.presentedViewController() as? UINavigationController, subnavigationController.viewControllers.count > 1 {
            subnavigationController.popViewController(animated: true)
        }
        else {
            self.dismissTopViewController()
        }
    }
    @objc open func dismissTopViewController() {
        if self.presentationStack.count > 0 {
            self.presentationStack.last?.dismiss(animated: true, completion: nil)
            self.presentationStack.removeLast()
        }
    }
    @objc open func popToRootViewController() {
        self.navigationController.popToRootViewController(animated: true)
        self.presentationStack.removeAll()
    }
    public func transition(viewController: UIViewController, options: UIView.AnimationOptions) {
        //HACK: Some weird stuff happens if you transition viewControllers while a custom presented view controller exists
        self.window.rootViewController?.dismiss(animated: true, completion: nil)
        UIView.transition(with: self.window, duration: 0.5, options: options, animations: {
            self.window.rootViewController = viewController
        }) { (success) in
            self.window.makeKeyAndVisible()
        }
        
        self.presentationStack.removeAll()
    }
    
    //MARK: Navigators
    @objc open func navigateToWebsite(url: URL) {
        self.presentedViewController().present(SFSafariViewController(url: url), animated: true, completion: nil)
    }
    @objc public func navigateToDirections(coordinate: CLLocationCoordinate2D, title: String? = nil) {
        let alertViewController = UIAlertController(title: "Directions", message: nil, preferredStyle: .actionSheet)
        let cancelAlert = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        
        alertViewController.addAction(cancelAlert)
        
        var availableOptions = [MapOption.appleMaps]
        for mapType in [MapOption.googleMaps, MapOption.waze] {
            switch mapType {
            case .googleMaps:
                if let url = URL(string: "comgooglemaps://"), UIApplication.shared.canOpenURL(url) {
                    availableOptions.append(mapType)
                }
                break
            case .waze:
                if let url = URL(string: "waze://"), UIApplication.shared.canOpenURL(url) {
                    availableOptions.append(mapType)
                }
                break
            default:
                break
            }
        }
        
        if availableOptions.count > 1 {
            for option in availableOptions {
                var title = ""
                switch option {
                case .appleMaps:
                    title = "Apple Maps"
                    break
                case .googleMaps:
                    title = "Google Maps"
                    break
                case .waze:
                    title = "Waze"
                    break
                }
                
                let action = UIAlertAction(title: title, style: .default) { (actions) in
                    self.navigateToMapOption(option: option, coordinate: coordinate, title: title)
                }
                alertViewController.addAction(action)
            }
            
            self.presentedViewController().present(alertViewController, animated: true, completion: nil)
        }
        else if let option = availableOptions.first {
            self.navigateToMapOption(option: option, coordinate: coordinate, title: title)
        }
    }
    public func navigateToMapOption(option: MapOption, coordinate: CLLocationCoordinate2D, title: String? = nil) {
        //Apple Maps
        let placeMark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placeMark)
        mapItem.name = title
        
        //Google Maps
        let googleMapsString = String.init(format: "comgooglemaps://?center=%f,%f&q=%f,%f", coordinate.latitude, coordinate.longitude, coordinate.latitude, coordinate.longitude)
        let googleMapsURL = URL(string: googleMapsString)
        
        //Waze
        let wazeString = String.init(format: "waze://?ll=%f,%f&navigate=yes", coordinate.latitude, coordinate.longitude)
        let wazeURL = URL(string: wazeString)
        
        //Launch
        switch option {
        case .appleMaps:
            MKMapItem.openMaps(with: [mapItem, MKMapItem.forCurrentLocation()], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
            break
        case .googleMaps:
            if let url = googleMapsURL {
                UIApplication.shared.open(url, options: [UIApplication.OpenExternalURLOptionsKey: Any](), completionHandler: nil)
            }
            break
        case .waze:
            if let url = wazeURL {
                UIApplication.shared.open(url, options: [UIApplication.OpenExternalURLOptionsKey: Any](), completionHandler: nil)
            }
            break
        }
    }
    
    //MARK: MFMailComposeViewControllerDelegate
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
