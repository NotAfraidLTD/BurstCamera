//
//  LTDPreviewImageCell.swift
//  YLTService
//
//  Created by 刘旦 on 2017/7/20.
//  Copyright © 2017年 YLT. All rights reserved.
//

import UIKit

let kPreviewImageCell = "previewImageCell"

class LTDPreviewImageCell: UICollectionViewCell , UIScrollViewDelegate{
  
    let tap: UITapGestureRecognizer = UITapGestureRecognizer()
    
    lazy var imageButton: UIButton = {
        let button = UIButton.init(type: .custom)
        button.backgroundColor = .clear
        button.adjustsImageWhenHighlighted = false
        button.isUserInteractionEnabled = false
        return button
    }()
    
    var oldOffset = CGPoint.init(x: 0, y: 0)
    
    let scrollView = UIScrollView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.scrollView.addGestureRecognizer(self.tap)
        self.tap.isEnabled = false
        self.scrollView.backgroundColor = .black
        self.scrollView.delegate = self
        self.scrollView.maximumZoomScale = 2.0
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.alwaysBounceHorizontal = false
        self.scrollView.alwaysBounceVertical = true
        self.contentView.addSubview(self.scrollView)
        self.scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.contentView)
        }
        self.scrollView.addSubview(self.imageButton)
        self.imageButton.snp.makeConstraints { (make) in
            make.centerY.centerX.equalTo(self.scrollView)
            make.height.equalTo(yc_screenHeight)
            make.width.equalTo(yc_screenWidth)
        }
        // 监听contentOffset的改变
        self.scrollView.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
    }
    
    // 监听contentOffset的改变
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if self.imageButton.bounds.size.width <= yc_screenWidth && self.imageButton.bounds.size.height <= yc_screenHeight && self.scrollView.isZoomBouncing && self.scrollView.contentOffset == CGPoint.init(x: 0, y: 0) && self.scrollView.zoomScale <= 1.0 {
            // 图片比min小并回弹时通过约束动画保持图片在中心位置
            self.imageButton.snp.updateConstraints({ (make) in
                make.centerX.equalTo(self.scrollView)
                make.centerY.equalTo(self.scrollView)
            })
            self.scrollView.setNeedsUpdateConstraints()
            UIView.animate(withDuration: 0.29, animations: {
                self.scrollView.layoutIfNeeded()
            })
        }
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageButton
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        //计算图片高宽比
        let imageRatio = (self.imageButton.backgroundImage(for: .normal)?.size.height)!/(self.imageButton.backgroundImage(for: .normal)?.size.width)!
        let height = scrollView.zoomScale * yc_screenWidth*imageRatio
        // 约束缩放图片中心位置
        // 高宽比大于屏幕
        if imageRatio >= yc_screenHeight/yc_screenWidth {
            let width = scrollView.zoomScale * yc_screenHeight/imageRatio
            if width <= yc_screenWidth {
                self.imageButton.snp.updateConstraints({ (make) in
                    if scrollView.zoomScale <= 1.0 {
                        make.centerX.equalTo(self.scrollView).offset(width/2*(1-scrollView.zoomScale)/scrollView.zoomScale)
                        make.centerY.equalTo(self.scrollView).offset(yc_screenHeight*(1-scrollView.zoomScale)/2.0)
                    } else {
                        make.centerX.equalTo(self.scrollView).offset((yc_screenHeight/imageRatio-width)/2.0)
                    }
                })
            } else {
                self.imageButton.snp.updateConstraints({ (make) in
                    make.centerY.equalTo(self.scrollView)
                    make.centerX.equalTo(self.scrollView).offset((yc_screenHeight/imageRatio-yc_screenWidth)/2.0)
                })
            }
            return
        }
        // 高宽比小于于屏幕
        self.imageButton.snp.updateConstraints({ (make) in
            if scrollView.zoomScale <= 1.0 {
                make.centerX.equalTo(self.scrollView).offset(yc_screenWidth*(1-scrollView.zoomScale)/2.0)
                make.centerY.equalTo(self.scrollView).offset(height/2*(1-scrollView.zoomScale)/scrollView.zoomScale)
            } else {
                make.centerY.equalTo(self.scrollView).offset((yc_screenWidth*imageRatio-height)/2.0)
            }
        })
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        let imageRatio = (self.imageButton.backgroundImage(for: .normal)?.size.height)!/(self.imageButton.backgroundImage(for: .normal)?.size.width)!
        if yc_screenWidth*imageRatio >= yc_screenHeight {
            return
        }
        let height = scale * yc_screenWidth*imageRatio
        if scale <= 1.0 {
            self.imageButton.snp.updateConstraints({ (make) in
                make.centerY.equalTo(self.scrollView).offset((yc_screenWidth*imageRatio-height)/2.0)
            })
        } else {
            self.imageButton.snp.updateConstraints({ (make) in
                make.centerY.equalTo(self.scrollView).offset((yc_screenWidth*imageRatio-height)/2.0)
            })
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        //移除监听
        self.scrollView.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    
}
