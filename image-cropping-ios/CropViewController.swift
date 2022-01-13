//
//  ViewController.swift
//  croppingImage
//
//  Created by 服部穣 on 2019/02/09.
//  Copyright © 2019 服部穣. All rights reserved.
//

import UIKit

enum ToolType {
    case crop
    case colorPicker
}

class CropViewController: UIViewController, UINavigationControllerDelegate {
    let cameraViewAspectRatio: CGFloat = 1.367      // The aspect ratio of the camera preview
    let defaultCropToolImageViewSize = CGSize(width: 200.0, height: 200.0)    // default size of cropped Image View when croping
    let defaultColorPickerImageViewSize = CGSize(width: 200.0, height: 200.0)   // default size of cropped Image when color picker is active
    var cropRect = CGRect(x: 100, y: 20, width: 50, height: 50)
//    let imageView = UIImageView()
    let imagePicker = UIImagePickerController()
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var croppedImageView: UIImageView!
    
    @IBOutlet weak var screenCoordinates: UILabel!
    @IBOutlet weak var imageCoordinates: UILabel!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var croppedImageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var croppedImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var croppedImageCoordinateLabel: UILabel!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    
    var croppedImageViewSize: CGSize = CGSize(width: 50.0, height: 50.0) {
        didSet {
            croppedImageViewWidth.constant = croppedImageViewSize.width
            croppedImageViewHeight.constant = croppedImageViewSize.height
        }
    }

    // Can not rely in the imageView.frame to update correctly so we update it here
    var imageViewSize = CGSize()
    
    var useFirstCroppingMethod = true

    var selectedImage: UIImage?
    var pinching: Bool = false
    var pinchingStartDimension: CGFloat?
    @IBOutlet weak var toolTypeControl: UISegmentedControl!
    
    var toolType: ToolType = .crop {
        didSet {
            switch toolType {
            case .crop:
                croppedImageViewWidth.constant = defaultCropToolImageViewSize.width
                croppedImageViewHeight.constant = defaultCropToolImageViewSize.height
                cropRect = CGRect(x: cropRect.origin.x, y: cropRect.origin.y, width: 50, height: 50)
            case .colorPicker:
                croppedImageViewWidth.constant = defaultColorPickerImageViewSize.width
                croppedImageViewHeight.constant = defaultColorPickerImageViewSize.height
                cropRect = CGRect(x: cropRect.origin.x, y: cropRect.origin.y, width: 50, height: 50)
            }
        }
    }
    
    var imageCoordinateString: String {
        if let selectedImage = selectedImage {
            // For some reason the Frame does not get updated correctly have to use Height Constraints
            return "\(Int(selectedImage.size.width)) x \(Int(selectedImage.size.height))"
        } else {
            return ""
        }
    }

    var screenCoordinateString: String {
        return "\(Int(imageViewSize.width)) x \(Int(imageViewSize.height))"
    }
    
    var cropViewRectString: String {
        return "\(String(format: "%d", Int(cropRect.origin.x))), \(String(format: "%d", Int(cropRect.origin.y))), \(String(format: "%d", Int(cropRect.size.width))), \(String(format: "%d", Int(cropRect.size.height)))"
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .savedPhotosAlbum
        
        let viewWidth = view.frame.width
        let viewHeight = view.frame.height

        let onTapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        self.imageView.addGestureRecognizer(onTapGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(onPinch(_:)))
        self.imageView.addGestureRecognizer(pinchGesture)
        
        print("Original image view width: \(viewWidth * 3 / 5)")
        print("Original image view height: \(viewHeight * 2/5)")
//        let imageViewHeight = viewWidth * cameraViewAspectRatio
//        imageView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: imageViewHeight)
        imageView.layer.borderColor = UIColor.darkGray.cgColor
        imageView.layer.borderWidth = 1
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
//        imageView.makeConstraints(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, bottom: nil, topMargin: 0, leftMargin: 0, rightMargin: 0, bottomMargin: 0, width: viewWidth, height: imageViewHeight)
//        imageViewHeightConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: imageViewHeight)
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.addConstraints([imageViewHeightConstraint!])
        
        croppedImageView.layer.borderColor = UIColor.black.cgColor
        croppedImageView.layer.borderWidth = 1
        croppedImageView.contentMode = .scaleAspectFit
        self.selectedImage = self.imageView.image
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let selectedImage = selectedImage else {
            return
        }
        doCropImage(image: selectedImage)
    }
    
    @IBAction func onSelectImage(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func onCropImage(_ sender: Any) {
        guard let selectedImage = selectedImage else {
            return
        }
        doCropImage(image: selectedImage)
    }

    // When a user pinches in the imageView resize the cropped image to reflect the change in size
    @objc func onPinch(_ pinchGesture: UIPinchGestureRecognizer) {
        if pinchGesture.state == .began {
            pinching = true
            pinchingStartDimension = cropRect.width
        }
        if pinchGesture.state == .changed {
            print("Pinched old cropRect: \(cropRect)")
            print("pinchGesture.scale: \(pinchGesture.scale)")
            guard let pinchingStartDimension = pinchingStartDimension else {
                return
            }
            let insetByWidth = pinchingStartDimension * pinchGesture.scale
            print("insetByWidth: \(insetByWidth)")
            let newCropRect = CGRect(x: cropRect.origin.x, y: cropRect.origin.y, width: insetByWidth, height: insetByWidth)
//            let newCropRect = cropRect.insetBy(dx: (cropRect.width * pinchGesture.scale)/2, dy: (cropRect.height * pinchGesture.scale)/2)
//            print("Pinched new cropRect: \(newCropRect)")
            cropRect = newCropRect
            guard let selectedImage = selectedImage else {
                return
            }
            doCropImage(image: selectedImage)
        }
        if pinchGesture.state == .cancelled || pinchGesture.state == .ended || pinchGesture.state == .failed {
            pinching = false
            pinchingStartDimension = nil
        }
    }
    
    // When a user taps in the imageView redo the cropped image section and update the rectangle selection
    @objc func onTap(_ tapGesture: UITapGestureRecognizer) {
        let pointTapped : CGPoint = tapGesture.location(in: self.imageView)
        print("Tapped in View at : \(pointTapped)")
        print("old crop rect: \(cropRect)")
        // Adjust the origin so that the rectangle is centered around where the user tapped
        let adjustedOrigin = CGPoint(x: pointTapped.x - (cropRect.width / 2), y: pointTapped.y - (cropRect.height / 2))
        let newCropRect = CGRect(origin: adjustedOrigin, size: cropRect.size)
        cropRect = newCropRect
        print("New crop rect: \(cropRect)")
        guard let selectedImage = selectedImage else {
            return
        }
        doCropImage(image: selectedImage)
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
    
    // Add an overlay rectangle to indicate the cropped section at the specified rect
    private func addCropRectangle(_ rect: CGRect) {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        let shapeLayer = self.createSampleRectLayerWithBounds(rect)
        self.imageView.layer.addSublayer(shapeLayer)
        CATransaction.commit()
    }
    
    func removeAllRectangles() {
        if let sublayers = imageView.layer.sublayers {
            for subView in sublayers {
                subView.removeFromSuperlayer()
            }
        }
    }
    
    
    // Crop an image at the specified rect, using CGImage Crop
//    func cgImageCrop(image: UIImage, rect: CGRect) -> UIImage? {
//        let cgImage = image.cgImage!
//        if let croppedCGImage = cgImage.cropping(to: rect) {
//            debugPrint("imageOrientation: \(image.debugPrintOrientation())")
//            return UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)
//        } else {
//            return nil
//        }
//
//    }
    
    // Crop an image at the specified rect, using ImageContext cropping
    func imageContextCrop(image: UIImage, rect: CGRect, scale: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: rect.size.width / scale, height: rect.size.height / scale), true, 0.0)
        image.draw(at: CGPoint(x: -rect.origin.x / scale, y: -rect.origin.y / scale))
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return croppedImage
    }
    
    func updateUI() {
        screenCoordinates.text = screenCoordinateString
        imageCoordinates.text = imageCoordinateString
        croppedImageCoordinateLabel.text = cropViewRectString
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
        var adjustedImageViewHeightPixels = imageHeightDivWidth * view.frame.width
        let maxHeight = Int((view.frame.height - 200) / 2)
        // If the view is taller than half of the screen - the navigation bar (80) then constrain the height and adjust the width to maintain the aspect ratio so we have enough room to layout the controls below the cropped image
        if Int(adjustedImageViewHeightPixels) > maxHeight {
            print("newHeight > maxHeight")
            adjustedImageViewHeightPixels = CGFloat(maxHeight)
            let adjustedWidth = CGFloat(maxHeight) * aspectRatio
            print("adjustedWidth: \(adjustedWidth)")
            let padding = (view.frame.size.width - adjustedWidth) / 2
            imageViewLeadingConstraint.constant = padding
            imageViewTrailingConstraint.constant = -padding
            imageViewSize = CGSize(width: adjustedWidth, height: CGFloat(maxHeight))
        } else {
            imageViewLeadingConstraint.constant = 0
            imageViewTrailingConstraint.constant = 0
            imageViewSize = CGSize(width: view.frame.width, height: adjustedImageViewHeightPixels)
        }
        print("imageHeightDivWidth: \(imageHeightDivWidth)")
        print("adjustedImageViewHeightPixels: \(adjustedImageViewHeightPixels)")
        print("imageView.frame.size: \(imageView.frame.size)")
        imageViewHeightConstraint?.constant = adjustedImageViewHeightPixels
        view.layoutIfNeeded()   // call this to force the imageView to update which we rely on in doCropImage to figure out the aspect Ratio
    }
    
    
    // Crops the image by the specified cropRect and displays it in the croppedImageView also calles resizeImageView to resize the image View to maintain the images aspect ratio
    func doCropImage(image: UIImage) {
        removeAllRectangles()
        resizeImageView(image: image)
        // change this value as you want!
        print("cropRect: \(cropRect)")
        let croppedImage: UIImage?
        print("croppedImage.size: \(image.size)")
        print("croppedImage.scale: \(image.scale)")
        print("imageView.frame: \(imageView.frame)")
        print("croppedImageView.frame: \(croppedImageView.frame)")
      
        let scale = imageView.frame.width / image.size.width
        print("imageView.frame.width: \(imageView.frame.width)")
        print("cropImage scale: \(scale)")
        croppedImage = imageContextCrop(image: image, rect: cropRect, scale: scale)
        addCropRectangle(cropRect)
        self.croppedImageView.image = croppedImage
        updateUI()
    }
    
    // Override touchesBegan in the textfields parent UIViewController to dismiss the keyboard when tapping outside of any textfield
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    
    @IBAction func onToolChange(_ sender: Any) {
        if toolTypeControl.selectedSegmentIndex == 0 {
            toolType = .crop
        }
        if toolTypeControl.selectedSegmentIndex == 1 {
            toolType = .colorPicker
        }
    }
    
}


extension CropViewController: UIImagePickerControllerDelegate {
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

extension CropViewController: UITextFieldDelegate {
    // Handle Return dismiss keyboard by resignFirstResponder on the textfield
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
                return true
    }
}
