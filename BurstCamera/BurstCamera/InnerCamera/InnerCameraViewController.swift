//
//  InnerCameraViewController.swift
//  YLTService
//
//  Created by 刘旦 on 2017/8/31.
//  Copyright © 2017年 YLT. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMotion

protocol InnerCameraViewControllerDelegate : class {
    //pragma MARK:  完成代理方法
    func InnerCamera(_ picker: InnerCameraViewController, didFinishTakePicture pictures: Array<[String:Any]>)
    
    //pragma MARK:  代理生成数据
    func InnerCameraCreateSource(_ picker: InnerCameraViewController) -> Array<[String:Any]>
    
}

class InnerCameraViewController: UIViewController , AVCaptureMetadataOutputObjectsDelegate {
  
    weak var delegate : InnerCameraViewControllerDelegate?{
        didSet{
            if let data = self.delegate?.InnerCameraCreateSource(self){
                source = data
                self.collectionView.reloadData()
            }
        }
    }
    /// s是否保存相册
    var saveImages = false
    /// 最多照片数
    var maxImages = 10
    /// 存储展示数据源
    var source = Array<[String:Any]>.init()
    /// 当前图片索引
    var currentIndex = 0{
        didSet{
            let indexpath = IndexPath.init(row: currentIndex, section: 0)
            if  source.count > 0{
                let dict = source[currentIndex]
                let name = dict["reminder"] as? String
                self.choiceGuide(title: name ?? "")
                if name != nil , let image = UIImage.init(named: name!){
                    // 判断图片的尺寸 是否缩放
                    if image.size.width > kScreenWidth, image.size.height > 200{
                        self.guideImage.contentMode = .scaleToFill
                    }else{
                        self.guideImage.contentMode = .center
                    }
                    self.guideImage.image = image
                }else{
                    self.showButton.isHidden = true
                    self.guideImage.image = UIImage.init(named: "全景含车牌")
                }
                self.collectionView.reloadData()
                
                self.collectionView.selectItem(at: indexpath, animated: true, scrollPosition: UICollectionViewScrollPosition.centeredHorizontally)
            }
        }
    }
    /// 能否使用相机
    var canUser = false
    /// 硬件设备
    var device : AVCaptureDevice?
    /// 输出静态影像
    var imageOutput : AVCaptureStillImageOutput?
    /// 在输入、输出设备之间建立连接
    var session : AVCaptureSession?
    /// 图像预览层，显示捕获的图像
    var previewLayer : AVCaptureVideoPreviewLayer?
    /// 是否开启闪光灯
    var openFlash = false
    /// 缩放之前
    var beginGestureScale : CGFloat?
    /// 缩放之后
    var effectiveScale : CGFloat?
    /// 传感器(旋转)
    var motionManager : CMMotionManager?
    /// 竖屏
    var portraitFlag = false
    /// 倒屏
    var upsideDownFlag = false
    /// 左旋转
    var landscapeLeftFlag = false
    /// 右旋转
    var landscapeRightFlag = false
    /// 旋转角度
    var rotationAngle : CGFloat = 0.0
    /// cell间距
    let collectionViewEdge: CGFloat = LSize.adapt(10)
    /// cell边距
    let itemEdge: CGFloat = LSize.adapt(5)
    
    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startMotionManager()
        self.createSubview()
        canUser = self.canUserCamera()
        guard canUser else {
            return
        }
        self.customCamera()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isStatusBarHidden = false
        self.session?.stopRunning()
    }
    
    // 隐藏状态栏
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.addContraints()
        let indexpath = IndexPath.init(row: self.currentIndex, section: 0)
        collectionView.scrollToItem(at: indexpath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
    }
    //  pragma MARK:  设备开启相机
    func setAction(button : UIButton){
        if(UIApplication.shared.openURL(URL.init(string: UIApplicationOpenSettingsURLString)!)) {
            UIApplication.shared.openURL(URL.init(string: UIApplicationOpenSettingsURLString)!)
        }
    }
    //  pragma MARK:  设备初始化
    func customCamera(){
        effectiveScale = 1.0
        //使用AVMediaTypeVideo 指明self.device代表视频，默认使用后置摄像头进行初始化
        self.device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        //使用设备初始化输入
        let input : AVCaptureDeviceInput?
        do {
            input = try AVCaptureDeviceInput.init(device: self.device)
        } catch {
            input = nil
        }
        //生成照片输出对象
        self.imageOutput = AVCaptureStillImageOutput.init()
        
        //生成会话,连接输入输出
        self.session = AVCaptureSession.init()
        if let can = self.session?.canSetSessionPreset(AVCaptureSessionPreset1280x720){
            if can{
                self.session?.sessionPreset = AVCaptureSessionPreset1280x720
            }
        }
        if let can = self.session?.canAddInput(input){
            if can{
                self.session?.addInput(input)
            }
        }
        if let can = self.session?.canAddOutput(self.imageOutput){
            if can{
                self.session?.addOutput(self.imageOutput)
            }
        }
        //显示硬件捕捉的视图
        self.previewLayer = AVCaptureVideoPreviewLayer.init(session: self.session)
        self.previewLayer?.frame = CGRect.init(x:0, y:0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - LSize.adapt(190))
        self.previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.view.layer.insertSublayer(self.previewLayer!, at: 0)
        
        self.session?.startRunning()
        do {
            try self.device?.lockForConfiguration()
            //闪光灯
            if let flash = self.device?.isFlashModeSupported(AVCaptureFlashMode.auto){
                if flash{
                    self.device?.flashMode = .auto
                }
            }
            //自动白平衡
            if let balance = self.device?.isWhiteBalanceModeSupported(AVCaptureWhiteBalanceMode.autoWhiteBalance){
                if balance{
                    self.device?.whiteBalanceMode = .autoWhiteBalance
                }
            }
            // 自动聚焦
            if let can = self.device?.isFocusModeSupported(AVCaptureFocusMode.autoFocus){
                if can{
                    self.device?.focusMode = .autoFocus
                    self.device?.focusPointOfInterest = CGPoint.init(x: 0.5, y: 0.5)
                }
            }
            // 曝光调节
            if let exposure = self.device?.isExposureModeSupported(AVCaptureExposureMode.continuousAutoExposure){
                if exposure{
                    self.device?.exposureMode = .continuousAutoExposure
                    self.device?.exposurePointOfInterest = CGPoint.init(x: 0.5, y: 0.5)
                }
            }
            self.device?.unlockForConfiguration()
            
        } catch {
            return
        }
    }
    
    //pragma MARK: 获取使用权限
    func canUserCamera() -> Bool{
        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if authStatus == AVAuthorizationStatus.denied || authStatus == AVAuthorizationStatus.restricted{
            self.view.addSubview(setButton)
            setButton.snp.makeConstraints({ (maker) in
                maker.top.equalToSuperview().offset(LSize.adapt(180))
                maker.centerX.equalToSuperview()
                maker.width.equalToSuperview().dividedBy(2)
                maker.height.equalTo(LSize.adapt(200))
            })
            return false
        }else{
            setButton.removeFromSuperview()
            return true
        }
    }
    
    //pragma MARK: 聚焦手势
    func focusGesture(gesture : UITapGestureRecognizer){
        let point = gesture.location(in: gesture.view)
        if point.y < UIScreen.main.bounds.height - 200{
            self.focusAtPoint(point: point)
        }else{
            return
        }
    }
    //pragma MARK: 捏合手势
    func pinchGesture(gesture : UIPinchGestureRecognizer){
        var allTouchesAreOnThePreviewLayer = true
        let n = gesture.numberOfTouches
        for i in 0...n-1{
            let location = gesture.location(ofTouch: i, in: self.view)
            let convertedLocation = self.photoImage.convert(location, to: self.photoImage.superview)
            let contain = self.photoImage.layer.contains(convertedLocation)
            if !contain{
                allTouchesAreOnThePreviewLayer = false
                break
            }
        }
        if allTouchesAreOnThePreviewLayer{
            effectiveScale = (beginGestureScale ?? 1.0)*gesture.scale
            if effectiveScale! < CGFloat(1.0) {
                effectiveScale = 1.0
            }
            let maxScaleAndCropFactor = self.imageOutput?.connection(withMediaType: AVMediaTypeVideo).videoMaxScaleAndCropFactor ?? 45
            if effectiveScale! > maxScaleAndCropFactor{
                effectiveScale = maxScaleAndCropFactor
            }
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.025)
            previewLayer?.setAffineTransform(CGAffineTransform.init(scaleX: effectiveScale!, y: effectiveScale!))
            CATransaction.commit()
        }
    }
    
    func focusAtPoint (point : CGPoint){
        let size = self.view.bounds.size
        let focusPoint = CGPoint.init(x: point.y/size.height, y: 1 - point.x/size.width)
        do {
            try self.device?.lockForConfiguration()
            if let can = self.device?.isFocusModeSupported(AVCaptureFocusMode.autoFocus){
                if can{
                    self.device?.focusMode = .autoFocus
                    self.device?.focusPointOfInterest = focusPoint
                }
            }
            if let can = self.device?.isExposureModeSupported(AVCaptureExposureMode.autoExpose){
                if can{
                    self.device?.exposureMode = .autoExpose
                    self.device?.exposurePointOfInterest = focusPoint
                }
            }
            self.device?.unlockForConfiguration()
            self.focueView.center = point
            self.focueView.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.focueView.transform = CGAffineTransform.init(scaleX: 1.25, y: 1.25)
            }, completion: { (finished) in
                UIView.animate(withDuration: 0.5, animations: {
                    self.focueView.transform = CGAffineTransform.identity
                }, completion: { (finished) in
                    self.focueView.isHidden = true
                })
            })
        } catch {
            return
        }
    }
    //pragma MARK: 完成按钮
    func finishAction(button : UIButton){
        self.delegate?.InnerCamera(self, didFinishTakePicture: self.source)
    }
    //pragma MARK: 预览按钮
    func previewAction(button : UIButton){
        let preview = LTDPreviewImageCollectionView.init(placeholderImage: "defaultCar", previewImageType: .Memory)
        preview.backgroundColor = .white
        var images = Array<UIImage>.init()
        for n in 0...source.count-1{
            let imageDict = source[n]
            if imageDict["image"] != nil {
                images.append(imageDict["image"]! as! UIImage)
            }
        }
        if images.count <= 0 { return }
        preview.images = images
        preview.show(animation: false)
        
    }
    //pragma MARK: 拍照按钮 输出照片
    func shutterAction(button : UIButton){
        
        guard let captureConnection = self.imageOutput?.connection(withMediaType: AVMediaTypeVideo) else {
            return
        }
        captureConnection.videoScaleAndCropFactor = self.effectiveScale ?? 1.0
        self.imageOutput?.captureStillImageAsynchronously(from: captureConnection, completionHandler: {[weak self] (imageDataSampleBuffer, error) in
            
            if imageDataSampleBuffer == nil{
                return
            }
            
            if let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer){
                // 保存照片
                if let image = UIImage.init(data: imageData){
                    if self?.saveImages ?? false{
                        self?.saveImageToPhotosAlbum(image: image)
                    }
                    self?.saveImageToData(image: image, index: (self?.currentIndex ?? 0))
                }
                // 最后提示
                if (self?.currentIndex)! < (self?.maxImages ?? 10)-1{
                    self?.currentIndex += 1
                }else{
                    let alertController = UIAlertController(title: "提示",
                                                            message: "已经拍到最后一张了", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "确定", style: .cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    self?.present(alertController, animated: true, completion: nil)
                }
            }
        })
    }
    //pragma MARK: 数据源添加
    func saveImageToData(image:UIImage,index:Int){
        var dict = self.source[index]
        dict["image"] = image
        self.source[index] = dict
        self.collectionView.reloadData()
    }
    
    //pragma MARK: 保存照片
    func saveImageToPhotosAlbum(image : UIImage){
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(image:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    //pragma MARK: 保存照片回调
    func image(image:UIImage,didFinishSavingWithError error:NSError?,contextInfo:AnyObject) {
        if error?.userInfo != nil{
            // 有异常
        }else{
            // 无异常
        }
    }
    
    //pragma MARK: 显示全景
    func showAction(button : UIButton){
        if !button.isSelected{
            button.isSelected = true
            self.showButton.imageName = "openShow"
            self.guideImage.isHidden = true
        }else{
            button.isSelected = false
            self.showButton.imageName = "notShow"
            self.guideImage.isHidden = false
        }
    }
    //pragma MARK: 取消操作
    func cancelAction(button : UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    //pragma MARK: 开启闪光
    func flashAction(button : UIButton){
        do {
            try self.device?.lockForConfiguration()
            if openFlash{
                //关闭闪光灯
                if let flash = self.device?.isFlashModeSupported(AVCaptureFlashMode.off){
                    if flash{
                        self.device?.flashMode = .off
                        self.openFlash = false
                        self.flashButton.setImage(UIImage.init(named: "offFlash"), for: .normal)
                    }
                }
            }else{
                //开启闪光灯
                if let flash = self.device?.isFlashModeSupported(AVCaptureFlashMode.on){
                    if flash{
                        self.device?.flashMode = .on
                        self.openFlash = true
                        self.flashButton.setImage(UIImage.init(named: "openFlash"), for: .normal)
                    }
                }
            }
            self.device?.unlockForConfiguration()
        } catch {
            return
        }
    }
    
    func  createSubview(){
        self.view.addSubview(collectionView)
        self.view.addSubview(guideImage)
        self.view.addSubview(flashButton)
        self.view.addSubview(focueView)
        self.view.addSubview(photoImage)
        self.view.addSubview(bottomBar)
        self.view.addSubview(showButton)
        self.view.addSubview(guideLabel)
        self.bottomBar.addSubview(cancelButton)
        self.bottomBar.addSubview(previewButton)
        self.bottomBar.addSubview(shutterButton)
        self.bottomBar.addSubview(finishButton)
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(focusGesture(gesture:)))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        let pinch = UIPinchGestureRecognizer.init(target: self, action: #selector(pinchGesture(gesture:)))
        pinch.delegate = self
        self.view.addGestureRecognizer(pinch)
    }
    
    //pragma MARK: 界面布局
    func addContraints(){
        photoImage.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview()
            maker.top.equalToSuperview()
            maker.right.equalToSuperview()
            maker.bottom.equalToSuperview().offset(-LSize.adapt(200))
        }
        guideImage.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(self.photoImage.snp.centerY)
            maker.centerX.equalToSuperview()
            maker.width.equalToSuperview()
            maker.height.equalTo(220)
        }
        collectionView.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview()
            maker.width.equalToSuperview()
            maker.bottom.equalToSuperview().offset(-LSize.adapt(80))
            maker.height.equalTo(LSize.adapt(111))
        }
        bottomBar.snp.makeConstraints { (maker) in
            maker.left.right.equalToSuperview()
            maker.height.equalTo(LSize.adapt(80))
            maker.bottom.equalToSuperview()
        }
        shutterButton.snp.makeConstraints { (maker) in
            maker.centerX.equalToSuperview()
            maker.centerY.equalToSuperview()
            maker.width.height.equalTo(LSize.adapt(65))
        }
        finishButton.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(shutterButton.snp.centerY)
            maker.right.equalToSuperview().offset(-LSize.adapt(26))
            maker.width.equalTo(LSize.adapt(50))
            maker.height.equalTo(LSize.adapt(50))
        }
        flashButton.snp.makeConstraints { (maker) in
            maker.top.equalTo(LSize.adapt(15))
            maker.left.equalTo(LSize.adapt(10))
            maker.width.equalTo(LSize.adapt(80))
            maker.height.equalTo(LSize.adapt(30))
        }
        showButton.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview()
            maker.centerX.equalToSuperview()
            maker.width.equalTo(LSize.adapt(105))
            maker.height.equalTo(LSize.adapt(60))
        }
        previewButton.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(shutterButton.snp.centerY)
            maker.right.equalTo(self.finishButton.snp.left).offset(LSize.adapt(-18))
            maker.width.equalTo(LSize.adapt(50))
            maker.height.equalTo(LSize.adapt(50))
        }
        cancelButton.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(shutterButton.snp.centerY)
            maker.left.equalToSuperview().offset(LSize.adapt(26))
            maker.width.equalTo(LSize.adapt(50))
            maker.height.equalTo(LSize.adapt(50))
        }
    }
    
    //MARK: - setters and getters
    fileprivate lazy var  guideImage : UIImageView = {
        let pradoView = UIImageView.init()
        pradoView.contentMode = .center
        return pradoView
    }()
    fileprivate lazy var  photoImage : UIImageView = {
        let pradoView = UIImageView.init()
        pradoView.isHidden = true
        return pradoView
    }()
    fileprivate lazy var  shutterButton : UIButton = {
        let pradoView = UIButton.init(type: .custom)
        pradoView.setImage(UIImage.init(named: "photograph"), for: .normal)
        pradoView.addTarget(self, action: #selector(shutterAction(button:)), for: .touchUpInside)
        return pradoView
    }()
    fileprivate lazy var  flashButton : UIButton = {
        let pradoView = UIButton.init(type: .custom)
        pradoView.setImage(UIImage.init(named: "Aflash"), for: .normal)
        pradoView.addTarget(self, action: #selector(flashAction(button:)), for: .touchUpInside)
        return pradoView
    }()
    fileprivate lazy var  showButton : RotateButton = {
        let pradoView = RotateButton.init(frame: CGRect.zero)
        pradoView.rotationAngle = self.rotationAngle
        pradoView.addTarget(self, action: #selector(showAction(button:)), for: .touchUpInside)
        return pradoView
    }()
    fileprivate lazy var  focueView : UIView = {
        let pradoView = UIView.init()
        pradoView.bounds = CGRect.init(x: 0, y: 0, width: LSize.adapt(80), height: LSize.adapt(80))
        pradoView.layer.borderColor = UIColor.green.cgColor
        pradoView.layer.borderWidth = 1.0
        pradoView.isHidden = true
        pradoView.backgroundColor = UIColor.clear
        return pradoView
    }()
    fileprivate lazy var  cancelButton : UIButton = {
        let pradoView = UIButton.init(type: .custom)
        pradoView.setTitle("取消", for: .normal)
        pradoView.titleLabel?.font = UIFont.systemFont(ofSize: LSize.adapt(17))
        pradoView.addTarget(self, action: #selector(cancelAction(button:)), for: .touchUpInside)
        return pradoView
    }()
    fileprivate lazy var  finishButton : UIButton = {
        let pradoView = UIButton.init(type: .custom)
        pradoView.setTitle("完成", for: .normal)
        pradoView.titleLabel?.font = UIFont.systemFont(ofSize: LSize.adapt(17))
        pradoView.addTarget(self, action: #selector(finishAction(button:)), for: .touchUpInside)
        return pradoView
    }()
    fileprivate lazy var  previewButton : UIButton = {
        let pradoView = UIButton.init(type: .custom)
        pradoView.setTitle("预览", for: .normal)
        pradoView.titleLabel?.font = UIFont.systemFont(ofSize: LSize.adapt(17))
        pradoView.addTarget(self, action: #selector(previewAction(button:)), for: .touchUpInside)
        return pradoView
    }()
    fileprivate lazy var  setButton : UIButton = {
        let pradoView = UIButton.init(type: .custom)
        pradoView.setTitle("请设置开启相机", for: .normal)
        pradoView.titleLabel?.font = UIFont.systemFont(ofSize: LSize.adapt(17))
        pradoView.addTarget(self, action: #selector(setAction(button:)), for: .touchUpInside)
        return pradoView
    }()
    fileprivate lazy var  bottomBar : UIView = {
        let pradoView = UIView.init()
        pradoView.backgroundColor = UIColor.black
        return pradoView
    }()
    fileprivate lazy var  guideLabel : UILabel = {
        let pradoView = UILabel.init()
        pradoView.frame = CGRect.init(x: kScreenWidth/12, y: kScreenHeight, width: kScreenWidth/1.2, height: LSize.adapt(40))
        pradoView.textAlignment = NSTextAlignment.center
        pradoView.numberOfLines = 0
        pradoView.textColor = kBgWhiteColor()
        pradoView.font = UIFont.systemFont(ofSize: 17)
        pradoView.layer.shadowColor = UIColor.black.cgColor
        pradoView.layer.shadowRadius = 4.0
        pradoView.layer.shadowOpacity = 0.5
        pradoView.layer.shadowOffset = CGSize.init(width: 0, height: 4)
        return pradoView
    }()
    fileprivate lazy var  collectionView  : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width:LSize.adapt(100),height:LSize.adapt(100))
        //列间距,行间距
        layout.minimumInteritemSpacing = self.collectionViewEdge
        layout.minimumLineSpacing = self.collectionViewEdge
        layout.scrollDirection = .horizontal
        let pradoView = UICollectionView.init(frame:CGRect.zero, collectionViewLayout: layout)
        pradoView.backgroundColor = UIColor.black
        pradoView.showsHorizontalScrollIndicator = false
        pradoView.delegate = self
        pradoView.dataSource = self
        pradoView.register(UINib(nibName: "InnerCameraCell", bundle: nil), forCellWithReuseIdentifier: "InnerCameraCell")
        return pradoView
    }()
}

extension InnerCameraViewController : UIGestureRecognizerDelegate{
    //pragma MARK: 触及开始 将改变缩放之前的值
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let location = gestureRecognizer.location(in: self.view)
        // 点击到collectionView拦截
        if location.y > kScreenHeight-LSize.adapt(200){
            return false
        }
        if gestureRecognizer.isKind(of: UIPinchGestureRecognizer.classForCoder()){
            self.beginGestureScale = self.effectiveScale
        }
        return true
    }
    
    //pragma MARK: 横竖屏旋转的处理
    func startMotionManager(){
        if self.motionManager == nil{
            self.motionManager = CMMotionManager.init()
        }
        self.motionManager?.deviceMotionUpdateInterval = 1/15.0
        let available = self.motionManager?.isDeviceMotionAvailable ?? false
        if available {
            self.motionManager?.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: { [weak self](motion, error) in
                self?.performSelector(onMainThread: #selector(self?.handleDeviceMotion(deviceMotion:)), with: motion, waitUntilDone: true)
            })
        }else{
            self.motionManager = nil
        }
    }
    //pragma MARK: 判断旋转角度
    func handleDeviceMotion(deviceMotion : CMDeviceMotion){
        let x = deviceMotion.gravity.x
        let y = deviceMotion.gravity.y
        
        if (fabs(y) >= fabs(x)){
            if y < 0 {
                if portraitFlag{
                    return
                }
                portraitFlag = true
                upsideDownFlag = false
                landscapeLeftFlag = false
                landscapeRightFlag = false
                self.changeSubviewTransform(angle:0)
            }else{
                if upsideDownFlag{
                    return
                }
                portraitFlag = false
                upsideDownFlag = true
                landscapeLeftFlag = false
                landscapeRightFlag = false
                self.changeSubviewTransform(angle: CGFloat.pi)
            }
        }else{
            if x < 0 {
                if landscapeLeftFlag{
                    return
                }
                portraitFlag = false
                upsideDownFlag = false
                landscapeLeftFlag = true
                landscapeRightFlag = false
                self.changeSubviewTransform(angle: CGFloat.pi/2)
            }else{
                if landscapeRightFlag{
                    return
                }
                portraitFlag = false
                upsideDownFlag = false
                landscapeLeftFlag = false
                landscapeRightFlag = true
                self.changeSubviewTransform(angle: -CGFloat.pi/2)
            }
        }
    }
    //MARK: 传入旋转角度
    func changeSubviewTransform(angle : CGFloat){
        self.rotationAngle = angle
        UIView.animate(withDuration: 0.5) {
            self.guideImage.transform = CGAffineTransform(rotationAngle:angle)
            self.finishButton.transform = CGAffineTransform(rotationAngle:angle)
            self.flashButton.transform = CGAffineTransform(rotationAngle:angle)
            self.previewButton.transform = CGAffineTransform(rotationAngle:angle)
            self.cancelButton.transform = CGAffineTransform(rotationAngle:angle)
            self.guideLabel.transform = CGAffineTransform(rotationAngle:angle)
            self.showButton.rotationAngle = angle
            self.changeGuideLableFrame(angle: angle)
        }
        self.collectionView.reloadData()
    }
    //MARK: 提示文字改变
    fileprivate func choiceGuide(title : String){
        var guideString = title
        if title == "照片提示"{
            guideString = "拍照提示"
        }
        self.guideLabel.text = guideString
    }
    //MARK: 提示文字旋转
    fileprivate func changeGuideLableFrame(angle : CGFloat){
        if angle == CGFloat.pi/2{
            guideLabel.center.y = self.guideImage.center.y
            guideLabel.center.x = LSize.adapt(50)
        }else if angle == CGFloat.pi{
            guideLabel.center.y = LSize.adapt(80)
            guideLabel.center.x = self.guideImage.center.x
        }else if angle == -CGFloat.pi/2{
            guideLabel.center.y = self.guideImage.center.y
            guideLabel.center.x = kScreenWidth-LSize.adapt(50)
        }else{
            guideLabel.center.y = kScreenHeight-LSize.adapt(240)
            guideLabel.center.x = self.guideImage.center.x
        }
    }
}

extension InnerCameraViewController : UICollectionViewDelegate , UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.source.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InnerCameraCell", for: indexPath)
        if let circleCell = cell as? InnerCameraCell{
            circleCell.reloadCell(angle: self.rotationAngle, dict: self.source[indexPath.row])
            if self.currentIndex == indexPath.row{
                circleCell.selectedstyle = true
            }else{
                circleCell.selectedstyle = false
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.currentIndex = indexPath.row
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: itemEdge, left: itemEdge, bottom: itemEdge, right: itemEdge)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: LSize.adapt(100), height: LSize.adapt(100))
    }
}
