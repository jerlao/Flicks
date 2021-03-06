//
//  NetworkErrorViewController.swift
//  Flicks
//
//  Created by Jerry on 2/5/16.
//  Copyright © 2016 Jerry Lao. All rights reserved.
//

import UIKit

class NetworkErrorViewController: UIViewController {
    
    var movieObject:Movie?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onReloadButtonTapped(sender: UIButton) {
        sender.imageView!.alpha = 0
        UIView.animateWithDuration(1.0) {
            sender.imageView!.alpha = 1
        }
        if(InternetConnection.isConnectedToNetwork()) {
            self.dismissViewControllerAnimated(true) { () -> Void in
                //
            }
        }
    
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
