//
//  RotateButton.swift
//  YLTService
//
//  Created by 刘旦 on 2017/9/7.
//  Copyright © 2017年 YLT. All rights reserved.
//

import UIKit

class RotateButton: UIButton {
    
    enum rotateButtonType {
        case vertical
        case horizontal
    }
    
    var imageName : String = "notShow"{
        didSet{
            self.image.image = UIImage.init(named: imageName)
        }
    }
    
    var rotateType : rotateButtonType  = .vertical{
        didSet{
            UIView.animate(withDuration: 0.2) { 
                self.changeComposing()
            }
        }
    }
    
    /// 旋转角度
    var rotationAngle : CGFloat = 0.0{
        didSet{
            self.title.transform = CGAffineTransform(rotationAngle:0)
            self.image.transform = CGAffineTransform(rotationAngle:0)
            self.transform = CGAffineTransform(rotationAngle:0)
            if rotationAngle == CGFloat.pi/2{
                self.rotateType = .vertical
                self.title.transform = CGAffineTransform(rotationAngle:rotationAngle)
                self.image.transform = CGAffineTransform(rotationAngle:rotationAngle)
            }else if rotationAngle == CGFloat.pi{
                self.rotateType = .horizontal
                self.transform = CGAffineTransform(rotationAngle:rotationAngle)
            }else if rotationAngle == -CGFloat.pi/2{
                self.rotateType = .vertical
                self.title.transform = CGAffineTransform(rotationAngle:rotationAngle)
                self.image.transform = CGAffineTransform(rotationAngle:rotationAngle)
            }else{
                self.rotateType = .horizontal
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createSubview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func createSubview(){
        self.addSubview(title)
        self.addSubview(image)
    }
    
    func changeComposing(){
        if self.rotateType == .horizontal{
            self.title.frame = CGRect.init(x: self.frame.size.width/2-LSize.adapt(10), y: (self.frame.size.height - LSize.adapt(30))/2, width: LSize.adapt(60), height: LSize.adapt(30))
            self.image.frame = CGRect.init(x: self.frame.size.width/2-LSize.adapt(33), y: (self.frame.size.height - LSize.adapt(23))/2 , width:LSize.adapt(23) , height: LSize.adapt(23))
        
        }else{
            self.title.frame =  CGRect.init(x: self.frame.size.width/2-LSize.adapt(10), y:-LSize.adapt(20), width: LSize.adapt(20), height: LSize.adapt(90))
            self.image.frame = CGRect.init(x: (self.frame.size.width-LSize.adapt(23))/2, y:self.frame.size.height - LSize.adapt(23) , width:LSize.adapt(23) , height: LSize.adapt(23))
        }
    }
    
    fileprivate lazy var  title : UILabel = {
        let pradoView = UILabel.init()
        pradoView.layer.shadowColor = UIColor.black.cgColor
        pradoView.layer.shadowRadius = 4.0
        pradoView.layer.shadowOpacity = 0.5
        pradoView.layer.shadowOffset = CGSize.init(width: 0, height: 4)
        pradoView.textColor = kBgWhiteColor()
        pradoView.numberOfLines = 0
        pradoView.text = "示例图"
        pradoView.font = UIFont.systemFont(ofSize: LSize.adapt(17))
        return pradoView
    }()
    
    fileprivate lazy var  image : UIImageView = {
        let pradoView = UIImageView.init()
        pradoView.image = UIImage.init(named: "notShow")
        return pradoView
    }()

}
