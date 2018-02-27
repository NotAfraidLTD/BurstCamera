//
//  ViewController.swift
//  BurstCamera
//
//  Created by 刘旦 on 2018/2/27.
//  Copyright © 2018年 YLT. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cameraAction(_ sender: UIButton) {
        // 连拍相机
        let innerCamera = InnerCameraViewController()
        innerCamera.saveImages = true
        innerCamera.maxImages = 3
        innerCamera.delegate = self
        innerCamera.currentIndex =  0
        self.present(innerCamera, animated: true, completion: nil)
    }
    
}

//MARK: 连拍相机代理
extension ViewController : InnerCameraViewControllerDelegate{
    /**
     *   将相机存储的照片取出  刷新界面
     */
    func InnerCamera(_ picker: InnerCameraViewController, didFinishTakePicture pictures: Array<[String:Any]>) {
        print(pictures)
        picker.dismiss(animated: true, completion: nil)
    }
    /**
     *  原有的照片复制到相机数据源  设置提示文字
     */
    func InnerCameraCreateSource(_ picker: InnerCameraViewController) -> Array<[String : Any]> {
        var source = Array<[String:Any]>.init()
        for n in 0...2{
            var dict = [String:Any].init()
            dict["reminder"] = "空驶"
            source.append(dict)
        }
        return source
    }
}

