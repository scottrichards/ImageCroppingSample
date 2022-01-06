//
//  ViewController.swift
//  croppingImage
//
//  Created by 服部穣 on 2019/02/09.
//  Copyright © 2019 服部穣. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate {
    let cameraViewAspectRatio: CGFloat = 1.367      // The aspect ratio of the camera preview
    let cropRect = CGRect(x: 200, y: 0, width: 50, height: 50)
    let imageView = UIImageView()
    let croppedImageView = UIImageView()
    let imagePicker = UIImagePickerController()
    @IBOutlet weak var methodSwitch: UISwitch!
    //    let selectImageButton1 = UIButton()
//    let selectImageButton2 = UIButton()
    
    // change this value as you want!
    var useFirstCroppingMethod = true
    var imageViewHeightConstraint: NSLayoutConstraint?
    var selectedImage: UIImage?
    
    var useMethod1: Bool {
        return methodSwitch.isOn
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .savedPhotosAlbum
        
        let viewWidth = view.frame.width
        let viewHeight = view.frame.height
        
//        selectImageButton1.frame = CGRect(x: viewWidth / 5, y: viewHeight * 3/5, width: viewWidth * 3/5, height: viewHeight / 8)
//        selectImageButton1.setTitle("select image and crop with method 1", for: .normal)
//        selectImageButton1.layer.borderColor = UIColor.black.cgColor
//        selectImageButton1.backgroundColor = .blue
//        selectImageButton1.addTarget(self, action: #selector(selectImage1), for: .touchUpInside)
//        selectImageButton1.titleLabel?.numberOfLines = 0
//        view.addSubview(selectImageButton1)
//
//        selectImageButton2.frame = CGRect(x: viewWidth / 5, y: viewHeight * 4/5, width: viewWidth * 3/5, height: viewHeight / 8)
//        selectImageButton2.setTitle("select image and crop with method 2", for: .normal)
//        selectImageButton2.layer.borderColor = UIColor.black.cgColor
//        selectImageButton2.backgroundColor = .blue
//        selectImageButton2.addTarget(self, action: #selector(selectImage2), for: .touchUpInside)
//        selectImageButton2.titleLabel?.numberOfLines = 0
//        view.addSubview(selectImageButton2)

        print("Original image view width: \(viewWidth * 3 / 5)")
        print("Original image view height: \(viewHeight * 2/5)")
        let imageViewHeight = viewWidth * cameraViewAspectRatio
        imageView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: imageViewHeight)
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.borderWidth = 2
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        imageView.makeConstraints(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, bottom: nil, topMargin: 0, leftMargin: 0, rightMargin: 0, bottomMargin: 0, width: viewWidth, height: imageViewHeight)
        imageViewHeightConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: imageViewHeight)
        imageView.addConstraints([imageViewHeightConstraint!])
        
        croppedImageView.frame = CGRect(x:20, y: imageView.frame.origin.y + imageView.frame.size.height + 20, width: cropRect.width, height: cropRect.height)
        croppedImageView.layer.borderColor = UIColor.black.cgColor
        croppedImageView.layer.borderWidth = 1
        croppedImageView.contentMode = .scaleAspectFit
        view.addSubview(croppedImageView)
    }
    
    @IBAction func onSelectImage(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
        
    
    
    /// Returns the Gold Bounding Rectangle to indicate a selection
    func createSampleRectLayerWithBounds(_ bounds: CGRect) -> CALayer {
        let shapeLayer = CALayer()
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        shapeLayer.name = "Found Object"
        shapeLayer.borderColor = UIColor.systemYellow.cgColor
        shapeLayer.borderWidth = 2
//      Don't have the rectangle filled in
//        shapeLayer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 0.2, 0.4])
        shapeLayer.cornerRadius = 2
        return shapeLayer
    }
    
    private func addCropRectangle(_ rect: CGRect) {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        let shapeLayer = self.createSampleRectLayerWithBounds(rect)
        self.imageView.layer.addSublayer(shapeLayer)
        CATransaction.commit()
    }
    
    
    func cropImage1(image: UIImage, rect: CGRect) -> UIImage {
        let cgImage = image.cgImage!
        let croppedCGImage = cgImage.cropping(to: rect)
        return UIImage(cgImage: croppedCGImage!, scale: image.scale, orientation: image.imageOrientation)
    }
    
    func cropImage2(image: UIImage, rect: CGRect, scale: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: rect.size.width / scale, height: rect.size.height / scale), true, 0.0)
        image.draw(at: CGPoint(x: -rect.origin.x / scale, y: -rect.origin.y / scale))
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return croppedImage!
    }
    
    func doCropImage(image: UIImage) {
        
        print("image.size: \(image.size)")
        print("image.scale: \(image.scale)")
        // change this value as you want!
        print("cropRect: \(cropRect)")
        let croppedImage: UIImage
        print("croppedImage.size: \(image.size)")
        print("croppedImage.scale: \(image.scale)")
        print("imageView.frame: \(imageView.frame)")
        print("croppedImageView.frame: \(croppedImageView.frame)")
        
        if useMethod1 {
            let factor = imageView.frame.width/image.size.width
            print("factorX: \(factor)")
            let rect = CGRect(x: cropRect.origin.x / factor, y: cropRect.origin.y / factor, width: cropRect.width / factor, height: cropRect.height / factor)
            print("adjusted Rect for Crop: \(rect)")
            croppedImage = cropImage1(image: image, rect: rect)
        } else {
            let scale = imageView.frame.width/image.size.width
            croppedImage = cropImage2(image: image, rect: cropRect, scale: scale)
        }
        
        // Resize Image View to the aspect ratio of the image
        let aspectRatio = (image.size.width / image.size.height)
        print("Image Aspect Ratio (width/height): \(aspectRatio)")
        let factorY = imageView.frame.height/image.size.height
        print("factorY: \(factorY)")
        let heightDivWidth = image.size.height / image.size.width
        print("heightDivWidth: \(heightDivWidth)")
        let adjustedImageHeightPixels = heightDivWidth * imageView.frame.width
        print("adjustedImageHeightPixels: \(adjustedImageHeightPixels)")
        let adjustedImageHeightPoints = adjustedImageHeightPixels * factorY
        print("adjustedImageHeightPoints: \(adjustedImageHeightPoints)")

        
        imageView.image = image
        let originalFrame = imageView.frame
        let croppedFrame = CGRect(x: originalFrame.origin.x + cropRect.origin.x, y: originalFrame.origin.y + cropRect.origin.y, width: cropRect.width, height: cropRect.height)
        
        dismiss(animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: { [unowned self] in
            let factor = imageView.frame.width/image.size.width
            let adjustedCropRect = CGRect(x: cropRect.origin.x, y: cropRect.origin.y, width: cropRect.width , height: cropRect.height)
            // Disable Existing Constraints so we can programmatically adjust them after the fact
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageViewHeightConstraint?.constant = adjustedImageHeightPoints
            print("adjustedCropRect: \(adjustedCropRect)")
            addCropRectangle(adjustedCropRect)
            self.croppedImageView.image = croppedImage
//            self.croppedImageView.frame = croppedFrame
//            UIView.animate(withDuration: 1.0) { [unowned self] in
//                self.imageView.frame = originalFrame
//            }
        })
    }
}


extension ViewController: UIImagePickerControllerDelegate {
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var image: UIImage
        
        if let possibleImage = info[.editedImage] as? UIImage {
            image = possibleImage
        } else if let possibleImage = info[.originalImage] as? UIImage {
            image = possibleImage
        } else {
            return
        }
        doCropImage(image: image)
    }
}

