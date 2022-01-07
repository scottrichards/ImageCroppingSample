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
    var cropRect = CGRect(x: 100, y: 20, width: 50, height: 50)
    let imageView = UIImageView()
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var croppedImageView: UIImageView!
    @IBOutlet weak var methodSwitch: UISwitch!
    @IBOutlet weak var xTextField: UITextField!
    @IBOutlet weak var yTextField: UITextField!
    @IBOutlet weak var widthTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    
    @IBOutlet weak var screenCoordinates: UILabel!
    @IBOutlet weak var imageCoordinates: UILabel!
    
    
    var useFirstCroppingMethod = true
    var imageViewHeightConstraint: NSLayoutConstraint?
    var selectedImage: UIImage?
    
    var useMethod1: Bool {
        return methodSwitch.isOn
    }
    
    var imageCoordinateString: String {
        if let selectedImage = selectedImage {
            return "\(Int(selectedImage.size.width)) x \(Int(selectedImage.size.height))"
        } else {
            return ""
        }
    }

    var screenCoordinateString: String {
        return "\(Int(imageView.frame.size.width)) x \(Int(imageView.frame.size.height))"
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .savedPhotosAlbum
        
        let viewWidth = view.frame.width
        let viewHeight = view.frame.height

        print("Original image view width: \(viewWidth * 3 / 5)")
        print("Original image view height: \(viewHeight * 2/5)")
        let imageViewHeight = viewWidth * cameraViewAspectRatio
        imageView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: imageViewHeight)
        imageView.layer.borderColor = UIColor.darkGray.cgColor
        imageView.layer.borderWidth = 1
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        imageView.makeConstraints(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, bottom: nil, topMargin: 0, leftMargin: 0, rightMargin: 0, bottomMargin: 0, width: viewWidth, height: imageViewHeight)
        imageViewHeightConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: imageViewHeight)
        imageView.addConstraints([imageViewHeightConstraint!])
        
//        croppedImageView.frame = CGRect(x:20, y: imageView.frame.origin.y + imageView.frame.size.height + 20, width: cropRect.width, height: cropRect.height)
        croppedImageView.layer.borderColor = UIColor.black.cgColor
        croppedImageView.layer.borderWidth = 1
        croppedImageView.contentMode = .scaleAspectFit
//        view.addSubview(croppedImageView)
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
    
    func updateUI() {
        screenCoordinates.text = screenCoordinateString
        imageCoordinates.text = imageCoordinateString
    }
    
    // Resize the image View to reflect the Aspect Ratio of the selected image
    func resizeImageView(image: UIImage) {
        imageView.image = image
        selectedImage = image
        print("image.size: \(image.size)")
        print("image.scale: \(image.scale)")
        // Resize Image View to the aspect ratio of the image
        let aspectRatio = (image.size.width / image.size.height)
        print("Image Aspect Ratio (width/height): \(aspectRatio)")
        let imageHeightDivWidth = image.size.height / image.size.width
        let adjustedImageHeightPixels = imageHeightDivWidth * view.frame.width
        print("imageHeightDivWidth: \(imageHeightDivWidth)")
        print("adjustedImageHeightPixels: \(imageHeightDivWidth)")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageViewHeightConstraint?.constant = adjustedImageHeightPixels
        updateUI()
    }
    
    func doCropImage(image: UIImage) {
        resizeImageView(image: image)
        // change this value as you want!
        print("cropRect: \(cropRect)")
        let croppedImage: UIImage
        print("croppedImage.size: \(image.size)")
        print("croppedImage.scale: \(image.scale)")
        print("imageView.frame: \(imageView.frame)")
        print("croppedImageView.frame: \(croppedImageView.frame)")
      
        if useMethod1 {
            let factor = view.frame.width/image.size.width
            let factorY = view.frame.height / image.size.height
            print("factorX: \(factor)")
            let rect = CGRect(x: cropRect.origin.x / factor, y: cropRect.origin.y / factor, width: cropRect.width / factor, height: cropRect.height / factor)
            print("adjusted Rect for Crop: \(rect)")
            croppedImage = cropImage1(image: image, rect: rect)
        } else {
            let scale = imageView.frame.width/image.size.width
            croppedImage = cropImage2(image: image, rect: cropRect, scale: scale)
        }
        
        
//        let croppedFrame = CGRect(x: imageView.frame.origin.x + cropRect.origin.x, y: imageView.frame.origin.y + cropRect.origin.y, width: cropRect.width, height: cropRect.height)
            
//            let factor = imageView.frame.width/image.size.width
        let adjustedCropRect = CGRect(x: cropRect.origin.x, y: cropRect.origin.y, width: cropRect.width , height: cropRect.height)
        // Disable Existing Constraints so we can programmatically adjust them after the fact
        
        print("adjustedCropRect: \(adjustedCropRect)")
        addCropRectangle(cropRect)
        self.croppedImageView.image = croppedImage
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
        dismiss(animated: true)
        doCropImage(image: image)
    }
}

