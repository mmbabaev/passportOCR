//
//  TakePhotoViewController.swift
//  PassportOCR
//
//  Created by Михаил on 03.09.16.
//  Copyright © 2016 empatika. All rights reserved.
//

import UIKit
import Darwin
import TesseractOCR

class TakePhotoViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, OverlayViewDelegate, G8TesseractDelegate {

    var picker: UIImagePickerController!
    
    @IBOutlet weak var codeTextView: UITextView!
    @IBOutlet weak var mrcTextView: UITextView!
    @IBOutlet weak var cameraImageView: UIImageView!
    
    @IBAction func takePhotoClicked(sender: UIButton) {
        if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
            picker = UIImagePickerController()
            picker.allowsEditing = false
            picker.sourceType = .Camera
            picker.cameraCaptureMode = .Photo
            picker.showsCameraControls = false
            
            picker.delegate = self
            
            let cameraVC = CameraOverlayViewController(nibName: NibNames.cameraOverlayViewController, bundle: nil)
            let overlayView = cameraVC.view as! OverlayView
            let width = self.picker.view.frame.width
            let height = self.picker.view.frame.height
            let frame = CGRect(x: 0, y: 0, width: width, height: height)
            overlayView.frame = frame
            
            picker.modalPresentationStyle = .FullScreen
            presentViewController(picker, animated: true, completion: {
                
                overlayView.passportBorder.layer.borderWidth = 2.0
                overlayView.passportBorder.layer.borderColor = UIColor.blackColor().CGColor
                
                overlayView.codeBorder.layer.borderWidth = 5.0
                overlayView.codeBorder.layer.borderColor = UIColor.redColor().CGColor
                
                overlayView.delegate = self
                
                self.picker.cameraOverlayView = overlayView
            })
        }
        else {
            let alertVC = UIAlertController(title: "Ошибка", message: "Камера не найдена", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            
            alertVC.addAction(okAction)
            presentViewController(alertVC, animated: true, completion: nil)
        }
    }
    
    func didShoot(overlayView: OverlayView) {
        picker.takePicture()
    }
    
    func didCancel(overlayView: OverlayView) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        
        dismissViewControllerAnimated(true, completion: {
            self.recognizeImage(image)
            //self.recognizeImage(UIImage(named: "passport-2")!)
        })
    }
    
    func recognizeImage(image: UIImage) {
        self.cameraImageView.image = image
        
        let tesseract = G8Tesseract(language: "eng")
        tesseract.delegate = self
        
        tesseract.image = image
        tesseract.charWhitelist = Constants.alphabet.uppercaseString
        tesseract.charWhitelist.append("<>1234567890")
        
        tesseract.recognize()
        
        if let recognizedText = tesseract.recognizedText {
            print("RECOGNIZED: \(recognizedText)")
            
            let mrCode = tesseract.recognizedText.stringByReplacingOccurrencesOfString(" ", withString: "")
            
            if let info = PassportInfo(machineReadableCode: mrCode) {
                self.mrcTextView.text = String(info)
            }
            else {
                self.mrcTextView.text = "Error"
                self.codeTextView.text = mrCode
            }
        }
        else {
            NSLog("RECOGNIZED: ERROR")
        }
    }
    
    func progressImageRecognitionForTesseract(tesseract: G8Tesseract!) {
        NSLog("progress: \(tesseract.progress)")
    }
}













