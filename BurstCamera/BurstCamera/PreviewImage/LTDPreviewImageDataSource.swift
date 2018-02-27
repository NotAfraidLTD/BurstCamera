//
//  LTDPreviewImageDataSource.swift
//  YLTService
//
//  Created by 刘旦 on 2017/7/20.
//  Copyright © 2017年 YLT. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

let yc_screenWidth = UIScreen.main.bounds.size.width

let yc_screenHeight = UIScreen.main.bounds.size.height

public enum PreviewImageType {
    ///缓存的数据源
    case Memory
    ///文件或者网络资源
    case Resource
}

class LTDPreviewImageDataSource: NSObject , UICollectionViewDataSource , UICollectionViewDelegate{
    
    var number: UILabel?
    
    var placeholderImage = UIImage()
    
    // 是否支持点击手势
    var isEnableTap = true
    // 是否支持点击手势自动移除语言视图
    var autoRemove = true
    
    var imagesType : PreviewImageType = .Resource
    
    var dataList: [Any] = []
    
    fileprivate var myCollectionView: LTDPreviewImageCollectionView?
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.myCollectionView = collectionView as? LTDPreviewImageCollectionView
        return self.dataList.count
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 展示图片索引和数量
        self.myCollectionView?.displayIndex = Int((scrollView.contentOffset.x+yc_screenWidth/2.0)/yc_screenWidth)
        self.number?.text = "\((self.myCollectionView?.displayIndex)!+1)/\((self.myCollectionView?.images.count)!)"
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        // 切换图片是重置图片缩放和约束
        for cell in (self.myCollectionView?.visibleCells)! {
            if cell != self.myCollectionView?.cellForItem(at: IndexPath.init(item: (self.myCollectionView?.displayIndex)!, section: 0)) {
                let myCell = cell as! LTDPreviewImageCell
                myCell.scrollView.zoomScale = 1.0
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kPreviewImageCell, for: indexPath) as! LTDPreviewImageCell
        cell.scrollView.zoomScale = 1.0
        var height = yc_screenHeight
        var width = yc_screenWidth
        cell.imageButton.setBackgroundImage(nil, for: .normal)
        cell.scrollView.maximumZoomScale = 1.0
        cell.scrollView.minimumZoomScale = 1.0
        if !(cell.tap.isEnabled) && self.isEnableTap && self.autoRemove {
            cell.tap.isEnabled = true
            cell.tap.addTarget(self, action: #selector(self.removeSelf))
        }
        
        if self.imagesType == .Memory{
            
            let image = self.dataList[indexPath.item] as? UIImage
            if image != nil {
                cell.imageButton.setBackgroundImage(image, for: .normal)
                if (image?.size.height)!/(image?.size.width)! > yc_screenHeight/yc_screenWidth {
                    let width = yc_screenHeight*(image?.size.width)!/(image?.size.height)!
                    cell.imageButton.snp.updateConstraints({ (make) in
                        make.centerY.equalTo(cell.scrollView)
                        make.height.equalTo(yc_screenHeight)
                        make.width.equalTo(width)
                    })
                } else {
                    let height = yc_screenWidth*(image?.size.height)!/(image?.size.width)!
                    cell.imageButton.snp.updateConstraints({ (make) in
                        make.centerY.equalTo(cell.scrollView)
                        make.height.equalTo(height)
                        make.width.equalTo(yc_screenWidth)
                    })
                }
                cell.scrollView.contentSize = CGSize.init(width: 0, height: 0)
                cell.scrollView.maximumZoomScale = (self.myCollectionView?.maxScale)!
                cell.scrollView.minimumZoomScale = (self.myCollectionView?.minScale)!
            }
            
            return cell
        
        }
        
        let ImageUrl = self.dataList[indexPath.item] as? String
        if let _ = ImageUrl?.contains("http") {
            cell.imageButton.kf.setBackgroundImage(with: URL.init(string: ImageUrl!), for: .normal, placeholder: placeholderImage, options: [.backgroundDecode], progressBlock: nil) { (image, error, type, url) in
                if image != nil {
                    if (image?.size.height)!/(image?.size.width)! > yc_screenHeight/yc_screenWidth {
                        let width = yc_screenHeight*(image?.size.width)!/(image?.size.height)!
                        cell.imageButton.snp.updateConstraints({ (make) in
                            make.centerY.equalTo(cell.scrollView)
                            make.height.equalTo(yc_screenHeight)
                            make.width.equalTo(width)
                        })
                    } else {
                        let height = yc_screenWidth*(image?.size.height)!/(image?.size.width)!
                        cell.imageButton.snp.updateConstraints({ (make) in
                            make.centerY.equalTo(cell.scrollView)
                            make.height.equalTo(height)
                            make.width.equalTo(yc_screenWidth)
                        })
                    }
                    cell.scrollView.contentSize = CGSize.init(width: 0, height: 0)
                    cell.scrollView.maximumZoomScale = (self.myCollectionView?.maxScale)!
                    cell.scrollView.minimumZoomScale = (self.myCollectionView?.minScale)!
                }
            }
            let originImage = cell.imageButton.backgroundImage(for: .normal)
            if originImage != nil && originImage?.size != .zero {
                if originImage!.size.height/originImage!.size.width >= yc_screenHeight/yc_screenWidth {
                    width = yc_screenHeight * originImage!.size.width/originImage!.size.height
                } else {
                    height = yc_screenWidth * originImage!.size.height/originImage!.size.width
                }
                cell.imageButton.snp.updateConstraints({ (make) in
                    make.centerY.centerX.equalTo(cell.scrollView)
                    make.height.equalTo(height)
                    make.width.equalTo(width)
                })
            }
        } else {
            let imageUrl = self.dataList[indexPath.item] as? String ?? ""
            let image = UIImage.init(named: imageUrl)
            if image != nil {
                cell.imageButton.setBackgroundImage(image, for: .normal)
                if (image?.size.height)!/(image?.size.width)! > yc_screenHeight/yc_screenWidth {
                    let width = yc_screenHeight*(image?.size.width)!/(image?.size.height)!
                    cell.imageButton.snp.updateConstraints({ (make) in
                        make.centerY.equalTo(cell.scrollView)
                        make.height.equalTo(yc_screenHeight)
                        make.width.equalTo(width)
                    })
                } else {
                    let height = yc_screenWidth*(image?.size.height)!/(image?.size.width)!
                    cell.imageButton.snp.updateConstraints({ (make) in
                        make.centerY.equalTo(cell.scrollView)
                        make.height.equalTo(height)
                        make.width.equalTo(yc_screenWidth)
                    })
                }
                cell.scrollView.contentSize = CGSize.init(width: 0, height: 0)
                cell.scrollView.maximumZoomScale = (self.myCollectionView?.maxScale)!
                cell.scrollView.minimumZoomScale = (self.myCollectionView?.minScale)!
            }
        }
        
        return cell
    }
    
    // 从父视图移除
    func removeSelf() {
        UIView.animate(withDuration: 0.2, animations: {
            if self.myCollectionView != nil {
                self.number?.alpha = 0
                self.myCollectionView?.alpha = 0
            }
        }, completion: { success in
            self.number?.removeFromSuperview()
            self.myCollectionView?.removeFromSuperview()
        })
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.removeSelf()
    }
    

}
