//
//  ImagesPageView.swift
//  ParticleFoundation
//
//  Created by Rocco Del Priore on 10/7/18.
//  Copyright © 2018 Rocco Del Priore. All rights reserved.
//

import UIKit

open class ImagesPageView: UIScrollView {
    public var pages = [UIImageView]()
    open var currentPage: UIImageView? {
        set {}
        get {
            let index = Int(floor(self.contentOffset.x/self.contentSize.width))
            if index < pages.count {
                return pages[index]
            }
            return nil
        }
    }
    open var selected: ((_ image: UIImage?, _ index: Int) -> Void)?
    
    //MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        addPage()
        
        isPagingEnabled = true
        canCancelContentTouches = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override open func layoutSubviews() {
        super.layoutSubviews()
        contentSize = CGSize(width: frame.width*CGFloat(pages.count), height: frame.height)
    }
    
    //MARK: Helpers
    open func configuredImageView() -> UIImageView {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        return imageView
    }
    
    //MARK: Actions
    public func addPage() {
        let newPage = configuredImageView()
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(displayImage(gestureRecognizer:)))
        
        addSubview(newPage)
        newPage.addGestureRecognizer(gestureRecognizer)
        newPage.translatesAutoresizingMaskIntoConstraints = false
        
        if let lastPage = pages.last {
            newPage.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            newPage.leftAnchor.constraint(equalTo: lastPage.rightAnchor).isActive = true
            newPage.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
            newPage.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        }
        else {
            newPage.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            newPage.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
            newPage.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
            newPage.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        }
        
        pages.append(newPage)
    }
    @objc private func displayImage(gestureRecognizer: UIGestureRecognizer) {
        if let imageView = gestureRecognizer.view as? UIImageView {
            let index = Int(ceil(imageView.frame.origin.x/imageView.frame.size.width))
            self.selected?(imageView.image, index)
        }
    }
    
    //MARK: Modifiers
    public func setNumberOfPages(numberOfPages: Int) {
        while subviews.count > 0 { subviews.last?.removeFromSuperview() }
        pages.removeAll()
        for _ in 0...numberOfPages {
            addPage()
        }
        contentSize = CGSize(width: frame.width*CGFloat(pages.count), height: frame.height)
    }
    public func addImages(images: [UIImage?]) {
        for image in images {
            if let _ = pages.last?.image {
                addPage()
            }
            if let previousImageView = pages.last {
                previousImageView.image = image
            }
        }
        contentSize = CGSize(width: frame.width*CGFloat(pages.count), height: frame.height)
    }
    public func setImages(images: [UIImage?]) {
        for image in images {
            if let index = images.index(where: { (subimage) -> Bool in
                return subimage == image
            }), index < pages.count {
                pages[index].image = image
            }
            else {
                addPage()
                if let newImageView = pages.last {
                    newImageView.image = image
                }
            }
        }
    }
}
