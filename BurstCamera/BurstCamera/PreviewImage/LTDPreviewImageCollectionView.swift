//
//  LTDPreviewImageCollectionView.swift
//  YLTService
//
//  Created by 刘旦 on 2017/7/20.
//  Copyright © 2017年 YLT. All rights reserved.
//

import UIKit

class LTDPreviewImageCollectionView: UICollectionView {

    // 图片数组，可以是网络图片（网络图片必须是http或https协议），也支持本地和网络图片混合
    open var images: [Any] = Array<Any>.init() {
        didSet {
            if images.count > 0 {
                (self.dataSource as! LTDPreviewImageDataSource).dataList = images
            }
        }
    }
    
    // 图片最大比例，默认2.0
    open var maxScale: CGFloat = 2.0
    
    // 图片最小比例，1.0
    var minScale: CGFloat = 1.0
    
    // 首次出现时显示的图片索引, 默认第一张
    open var displayIndex = 0
    
    // 显示预览
    final public func show(animation: Bool) {
        
        let window = UIApplication.shared.keyWindow
        if (window?.subviews.contains(self))! {
            return
        }
        window?.addSubview(self)
        window?.addSubview(self.source.number!)
        self.source.number?.snp.makeConstraints({ (make) in
            make.top.left.right.equalTo(window!)
            make.height.equalTo(64.0)
        })
        self.source.number?.text = "\(self.displayIndex+1)/\(self.images.count)"
        if animation {
            appearanceAnimation(view: self)
        } else {
            self.scrollToItem(at: IndexPath.init(row: self.displayIndex, section: 0), at: UICollectionViewScrollPosition.left, animated: false)
            self.source.number?.alpha = 1.0
            self.alpha = 1.0
        }
    }
    
    final func appearanceAnimation(view: UIView) {
        assert(self.displayIndex >= 0 && self.displayIndex < self.images.count, "YRImagePreviewer: 图片索引索引超出数组边界")
        self.scrollToItem(at: IndexPath.init(row: self.displayIndex, section: 0), at: UICollectionViewScrollPosition.left, animated: false)
        UIView.animate(withDuration: 0.2, animations: {
            view.alpha = 1.0
            self.source.number?.alpha = 1.0
        },completion: { result in
        })
    }
    
    fileprivate let source = LTDPreviewImageDataSource()
    
    // 携带占位图片的初始化方法
    convenience public init(placeholderImage: String , previewImageType: PreviewImageType) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = UIScreen.main.bounds.size
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        self.init(frame: UIScreen.main.bounds, collectionViewLayout: layout)
        self.isPagingEnabled = true
        self.dataSource = self.source
        self.delegate = self.source
        self.source.imagesType = previewImageType
        self.alpha = 0
        self.register(LTDPreviewImageCell.classForCoder(), forCellWithReuseIdentifier: kPreviewImageCell)
        let numberView = UILabel()
        numberView.textColor = .white
        numberView.textAlignment = .center
        numberView.backgroundColor = UIColor.init(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.1)
        numberView.text = "0/0"
        self.source.number = numberView
        if previewImageType == .Resource{
            self.source.placeholderImage = UIImage.init(named: placeholderImage)!
        }
    }
    
    override fileprivate init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
