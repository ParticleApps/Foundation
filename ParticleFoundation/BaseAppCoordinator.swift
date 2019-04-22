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
    case appleMaps = "AppleMaps"
    case googleMaps = "GoogleMaps"
    case waze = "Waze"
}
public typealias CoordinatorNavigationDelegate = NSObject & UINavigationControllerDelegate & UIViewControllerTransitioningDelegate

open class BaseAppCoordinator: NSObject, MFMailComposeViewControllerDelegate {
    open var navigationController = UINavigationController() //I dont like that this is not publically facing to other classes
    open private(set) var navigationControllerDelegate: CoordinatorNavigationDelegate? = nil
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
    @objc open func presentingViewController() -> UIViewController {
        return self.navigationController
    }
    
    //MARK: Actions
    open func present(viewController: UIViewController, animated: Bool = true, custom: Bool = false,
                      withNavigationController: Bool = false, completion: (() -> Swift.Void)? = nil) {
        //HACK: Clean this up
        if withNavigationController {
            let subNavigationController = UINavigationController(rootViewController: viewController)
            if custom {
                subNavigationController.delegate = navigationControllerDelegate
                subNavigationController.transitioningDelegate = navigationControllerDelegate
                subNavigationController.modalPresentationStyle = UIModalPresentationStyle.custom
            }
            self.presentingViewController().present(viewController, animated: animated, completion: nil)
        }
        else if custom {
            viewController.transitioningDelegate = navigationControllerDelegate
            viewController.modalPresentationStyle = UIModalPresentationStyle.custom
        }
        if !withNavigationController {
            self.presentingViewController().present(viewController, animated: animated, completion: nil)
        }
    }
    open func presentAlert(title: String?, subtitle: String?, handler: ((UIAlertAction) -> Swift.Void)? = nil) {
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: handler))
        
        self.presentingViewController().present(alert, animated: true, completion: nil)
    }
    @objc open func navigateBack() {
        let topViewController = self.presentingViewController()
        if let presentedNavigationController = topViewController as? UINavigationController {
            if presentedNavigationController.viewControllers.count > 1 {
                presentedNavigationController.popViewController(animated: true)
            }
            else {
                presentedNavigationController.dismiss(animated: true, completion: nil)
            }
        }
        else {
            topViewController.dismiss(animated: true, completion: nil)
        }
    }
    public func transition(viewController: UIViewController, options: UIView.AnimationOptions) {
        //HACK: Some weird stuff happens if you transition viewControllers while a custom presented view controller exists
        self.window.rootViewController?.dismiss(animated: true, completion: nil)
        UIView.transition(with: self.window, duration: 0.5, options: options, animations: {
            self.window.rootViewController = viewController
        }) { (success) in
            self.window.makeKeyAndVisible()
        }
    }
    
    //MARK: Navigators
    @objc open func navigateToWebsite(url: URL) {
        self.present(viewController: SFSafariViewController(url: url), custom: true)
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
            
            self.present(viewController: alertViewController)
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
