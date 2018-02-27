//
//  InnerCameraCell.swift
//  YLTService
//
//  Created by 刘旦 on 2017/8/31.
//  Copyright © 2017年 YLT. All rights reserved.
//

import UIKit

class InnerCameraCell: UICollectionViewCell {
    
    var selectedstyle = false{
        didSet{
            if selectedstyle{
                self.imageView.layer.borderColor = kOrangeColor().cgColor
            }else{
                self.imageView.layer.borderColor = UIColor.gray.cgColor
            }
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageView.layer.masksToBounds = true
        self.imageView.layer.cornerRadius = 4
        self.imageView.layer.borderWidth = 1.5
    }
    
    //MARK: 旋转角度  图片  是否选中
    open func reloadCell(angle : CGFloat , dict : Dictionary<String, Any>){
        self.rotationAngle(angle: angle)
        let image = dict["image"] as? UIImage
        if image?.size.width ?? 0 > CGFloat(0) , image?.size.height ?? 0 > CGFloat(0) {
            self.imageView.image = image
        }else{
            self.imageView.image = nil
        }
        if let reminder = dict["reminder"] as? String{
            self.titleLabel.text = reminder
            if reminder.count > 5{
                self.titleLabel.font = UIFont.systemFont(ofSize: 12)
            }else{
                self.titleLabel.font = UIFont.systemFont(ofSize: 14)
            }
        }else{
            self.titleLabel.text = "新增"
        }
    }
    
    fileprivate func rotationAngle(angle : CGFloat){
        UIView.animate(withDuration: 0.5) { 
            self.imageView.transform = CGAffineTransform(rotationAngle: angle)
            self.titleLabel.transform = CGAffineTransform(rotationAngle: angle)
        }
    }
}
