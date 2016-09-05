//
//  OverlayView.swift
//  PassportOCR
//
//  Created by Михаил on 03.09.16.
//  Copyright © 2016 empatika. All rights reserved.
//

import UIKit

protocol OverlayViewDelegate{
    func didCancel(overlayView: OverlayView)
    func didShoot(overlayView: OverlayView)
}


class OverlayView: UIView {

    @IBOutlet weak var passportBorder: UIView!
    @IBOutlet weak var codeBorder: UIView!
    
    var delegate: OverlayViewDelegate!
    
    @IBAction func cancelButtonClicked(sender: UIButton) {
        delegate.didCancel(self)
    }
    
    @IBAction func scanButtonClicked(sender: UIButton) {
        delegate.didShoot(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.opaque = false
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
