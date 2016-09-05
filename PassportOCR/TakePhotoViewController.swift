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
    
    @IBOutlet weak var mrcTextView: UITextView!
    @IBOutlet weak var cameraImageView: UIImageView!
    
    @IBAction func takePhotoClicked(sender: UIButton) {
        if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
            picker = NonRotatingImagePickerController()
            picker.allowsEditing = false
            picker.sourceType = .Camera
            picker.cameraCaptureMode = .Photo
            picker.showsCameraControls = false
            
            //UIDevice.currentDevice().setValue(UIInterfaceOrientation.LandscapeRight.rawValue, forKey: "orientation")
            
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
                
                //self.picker.cameraOverlayView!.transform = CGAffineTransformRotate(CGAffineTransformIdentity, 117.81)
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
        cameraImageView.image = image
        
        let tesseract = G8Tesseract(language: "eng")
        tesseract.delegate = self
        
        tesseract.image = image
        //tesseract.charWhitelist = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890<>"
        
        
        
        dismissViewControllerAnimated(true, completion: {
            tesseract.recognize()

            if let recognizedText = tesseract.recognizedText {
                print("RECOGNIZED: \(recognizedText)")
                var lines = tesseract.recognizedText.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
                lines = lines.filter( { $0 != "" } )
                
                let lastLine = lines.popLast()
                self.mrcTextView.text = "\(lines.popLast()!)\n\(lastLine!)"
            }
            else {
                NSLog("RECOGNIZED: ERROR")
            }
        })
    }
    
    func progressImageRecognitionForTesseract(tesseract: G8Tesseract!) {
        NSLog("progress: \(tesseract.progress)")
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
