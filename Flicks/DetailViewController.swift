//
//  DetailViewController.swift
//  Flicks
//
//  Created by Jerry on 2/1/16.
//  Copyright © 2016 Jerry Lao. All rights reserved.
//

import UIKit
import JTProgressHUD
import AFNetworking

class DetailViewController: UIViewController, NSURLSessionDelegate {
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var overviewScrollView: UIScrollView!
    
    var movieObject:Movie?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navigationBar = navigationController?.navigationBar {
            navigationItem.title = (self.movieObject?.title)!
            navigationBar.tintColor = UIColor.whiteColor()
            navigationBar.barTintColor = UIColor(red: 109/255, green: 205/255, blue: 237/255, alpha: 0.8)
            
            navigationBar.titleTextAttributes = [
                NSFontAttributeName : UIFont.boldSystemFontOfSize(22),
                NSForegroundColorAttributeName : UIColor.whiteColor()
            ]
        }
        
        // Do any additional setup after loading the view.
        
        self.overviewScrollView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height)
        let contentWidth = self.overviewScrollView.bounds.width
        let labelHeight = CGFloat(35)
        let topOffset = self.view.frame.size.height * 0.65 - 49
        
        let frame = CGRectMake(0, topOffset, contentWidth, labelHeight * 15).insetBy(dx: 20, dy: 5)
        
        let subview = UIView(frame: frame)
        subview.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        let titleLabel = UILabel(frame: CGRectMake(0, 0, contentWidth, labelHeight).insetBy(dx: 10, dy: 0))
        titleLabel.text = self.movieObject?.title
        titleLabel.textColor = UIColor.whiteColor()
        subview.addSubview(titleLabel)
        
        if let date = self.movieObject?.releaseDate {
            let detailLabel = UILabel(frame: CGRectMake(0, labelHeight, contentWidth-30, labelHeight).insetBy(dx: 10, dy: 0))
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy"
            detailLabel.text = "Released "+dateFormatter.stringFromDate(date)
            detailLabel.textColor = UIColor.whiteColor()
            
            subview.addSubview(detailLabel)
        }
        
        let overviewLabel = UILabel(frame: CGRectMake(0, labelHeight * 2, contentWidth-30, labelHeight).insetBy(dx: 10, dy: 0))
        if let overview = self.movieObject?.overview {
            
            overviewLabel.text = overview
            overviewLabel.textColor = UIColor.whiteColor()
            overviewLabel.numberOfLines = 0
            overviewLabel.sizeToFit()
            
            subview.addSubview(overviewLabel)
        }
        
        let contentHeight = labelHeight * 2 + overviewLabel.frame.height + topOffset
        
        overviewScrollView.contentSize = CGSizeMake(contentWidth, contentHeight + 150)

        self.overviewScrollView.addSubview(subview)
    }
    
    override func viewWillAppear(animated: Bool) {
        if(!InternetConnection.isConnectedToNetwork()) {
            performSegueWithIdentifier("DetailToError", sender: nil)
        } else {
//            self.downloadThumbnailImage()
            if let largeImage = self.movieObject?.posterImageUrl {
                self.swapLowWithHighRes(largeImage, lowRes: (self.movieObject?.thumbnailUrl)!)
            } else {
                self.bgImageView.image = UIImage(named: "image")
            }
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func downloadThumbnailImage() {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 15.0
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        JTProgressHUD.show()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            if let object = self.movieObject {
                if let url = object.posterImageUrl {
                    let task = session.dataTaskWithURL(url) { (data, response, error) -> Void in
                        //
                    }
                    task.resume()
                }
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                if let image = self.movieObject?.posterImageUrl {
                    self.bgImageView.setImageWithURL(image)
                } else {
                    self.bgImageView.image = UIImage(named: "image")
                }
                
                self.bgImageView.clipsToBounds = true
                self.bgImageView.contentMode = UIViewContentMode.ScaleAspectFill
                JTProgressHUD.hide()
            }
            
        }
        
    }
    
    func swapLowWithHighRes(highRes: NSURL, lowRes: NSURL) {
        let smallImageRequest = NSURLRequest(URL: lowRes)
        let largeImageRequest = NSURLRequest(URL: highRes)
        self.bgImageView.setImageWithURLRequest(
            smallImageRequest,
            placeholderImage: nil,
            success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                
                // smallImageResponse will be nil if the smallImage is already available
                // in cache (might want to do something smarter in that case).
                self.bgImageView.alpha = 0.0
                self.bgImageView.image = smallImage;
                self.bgImageView.clipsToBounds = true
                self.bgImageView.contentMode = UIViewContentMode.ScaleAspectFill
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    
                    self.bgImageView.alpha = 1.0
                    
                    }, completion: { (sucess) -> Void in
                        
                        // The AFNetworking ImageView Category only allows one request to be sent at a time
                        // per ImageView. This code must be in the completion block.
                        self.bgImageView.setImageWithURLRequest(
                            largeImageRequest,
                            placeholderImage: smallImage,
                            success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                
                                self.bgImageView.image = largeImage;
                                self.bgImageView.clipsToBounds = true
                                self.bgImageView.contentMode = UIViewContentMode.ScaleAspectFill
                                
                            },
                            failure: { (request, response, error) -> Void in
                                // do something for the failure condition of the large image request
                                // possibly setting the ImageView's image to a default image
                                self.bgImageView.image = UIImage(named: "image")
                                self.bgImageView.clipsToBounds = true
                                self.bgImageView.contentMode = UIViewContentMode.ScaleAspectFill
                        })
                })
            },
            failure: { (request, response, error) -> Void in
                // do something for the failure condition
                // possibly try to get the large image
                self.bgImageView.image = UIImage(named: "image")
                self.bgImageView.clipsToBounds = true
                self.bgImageView.contentMode = UIViewContentMode.ScaleAspectFill
        })
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
