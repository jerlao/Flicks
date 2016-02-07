//
//  TopRatedTableViewController.swift
//  Flicks
//
//  Created by Jerry on 2/1/16.
//  Copyright © 2016 Jerry Lao. All rights reserved.
//

import UIKit
import JTProgressHUD
import AFNetworking

class TopRatedTableViewController: UITableViewController, NSURLSessionDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    private let url = NSURL(string: "https://api.themoviedb.org/3/movie/top_rated?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")
    private var allMovies = [Movie]()
    private var filteredMovies = [Movie]()
    private var searchActive = false
    private let refreshController = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.barTintColor = UIColor(red: 109/255, green: 205/255, blue: 237/255, alpha: 0.8)
            
            navigationBar.titleTextAttributes = [
                NSFontAttributeName : UIFont.boldSystemFontOfSize(22),
                NSForegroundColorAttributeName : UIColor.whiteColor()
            ]
        }
        
        self.tableView.rowHeight = self.view.frame.height/3
        
        refreshController.addTarget(self, action: "refreshTable:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.insertSubview(refreshController, atIndex: 0)
    }
    
    override func viewWillAppear(animated: Bool) {
        if(!InternetConnection.isConnectedToNetwork()) {
            performSegueWithIdentifier("TopToError", sender: nil)
        } else {
            if self.allMovies.count == 0 {
                self.refreshTable(self.refreshController)
            } else {
                self.tableView.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if searchActive {
            return self.filteredMovies.count
        } else {
            return self.allMovies.count
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TopRatedCell", forIndexPath: indexPath) as! TopRatedTableViewCell
        
        // Configure the cell...
        if searchActive {
            let getMovie = self.filteredMovies[indexPath.section]
            if let image = getMovie.thumbnailUrl {
                // cell.largeView.setImageWithURL(image, placeholderImage: UIImage(named: "image"))
                self.fadeInImage(image, cell: cell)
            } else {
                cell.largeView.image = UIImage(named: "image")
            }
            cell.descriptionLabel.text = getMovie.overview
        } else {
            let getMovie = self.allMovies[indexPath.section]
            if let image = getMovie.thumbnailUrl {
                // cell.largeView.setImageWithURL(image, placeholderImage: UIImage(named: "image"))
                self.fadeInImage(image, cell: cell)
            } else {
                cell.largeView.image = UIImage(named: "image")
            }
            cell.descriptionLabel.text = getMovie.overview
        }
        cell.selectionStyle = .None
        return cell
    }
    
    func refreshTable(refreshControl:UIRefreshControl) {
        JTProgressHUD.show()
        let request = NSURLRequest(URL: self.url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                self.allMovies.removeAll()
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            if let resultsArray = responseDictionary["results"] {
                                let results = resultsArray as! [NSDictionary]
                                for result in results {
                                    let title = result["original_title"] as! String
                                    let overview = result["overview"] as! String
                                    let votes = result["vote_count"] as! Int
                                    let popularity = result["popularity"] as! Float
                                    let genre = result["genre_ids"] as! [Int]
                                    
                                    let formatter = NSDateFormatter()
                                    formatter.dateFormat = "yyyy-mm-dd"
                                    let releaseDate = formatter.dateFromString((result["release_date"] as? String)!)
                                    
                                    let movie = Movie(title: title, overview: overview, votes: votes, popularity: popularity, genre: genre, releaseDate: releaseDate!)
                                    
                                    if let backdropPath = result["backdrop_path"] as? String {
                                        
                                        if let posterUrl = NSURL(string: "http://image.tmdb.org/t/p/w1000"+backdropPath) {
                                            movie.posterImageUrl = posterUrl
                                        }
                                        if let thumbUrl = NSURL(string: "http://image.tmdb.org/t/p/w300"+backdropPath) {
                                            movie.thumbnailUrl = thumbUrl
                                        }
                                    }
                                    self.allMovies.append(movie)
                                }
                            }
                    }
                }
                self.tableView.reloadData()
                JTProgressHUD.hide()
                refreshControl.endRefreshing()
        });
        task.resume()
    }
    
    func fadeInImage(imageUrl: NSURL, cell: TopRatedTableViewCell)-> TopRatedTableViewCell {
        let imageRequest = NSURLRequest(URL: imageUrl)
        cell.largeView.setImageWithURLRequest(
            imageRequest,
            placeholderImage: UIImage(named: "image"),
            success: { (imageRequest, imageResponse, image) -> Void in
                
                // imageResponse will be nil if the image is cached
                if imageResponse != nil {
                    // print("Image was NOT cached, fade in image")
                    cell.largeView.alpha = 0.0
                    cell.largeView.image = image
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        cell.largeView.alpha = 1.0
                    })
                } else {
                    // print("Image was cached so just update the image")
                    cell.largeView.image = image
                }
            },
            failure: { (imageRequest, imageResponse, error) -> Void in
                // do something for the failure condition
        })
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        headerView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        
        let profileView = UIImageView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        profileView.clipsToBounds = true
        profileView.layer.cornerRadius = 15;
        profileView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).CGColor
        profileView.layer.borderWidth = 1;
        
        // Use the section number to get the right URL
        if searchActive {
            if let image = self.filteredMovies[section].thumbnailUrl {
                profileView.setImageWithURL(image, placeholderImage: UIImage(named: "image"))
            } else {
                profileView.image = UIImage(named: "image")
            }
        } else {
            if let image = self.allMovies[section].thumbnailUrl {
                profileView.setImageWithURL(image, placeholderImage: UIImage(named: "image"))
            } else {
                profileView.image = UIImage(named: "image")
            }
        }
        
        headerView.addSubview(profileView)
        
        // Add a UILabel for the username here
        let label = UILabel(frame: CGRect(x:50, y:10, width: self.view.frame.width - 30, height: 30))
        label.font.fontWithSize(CGFloat(10))
        if searchActive {
            label.text = self.filteredMovies[section].title
        } else {
            label.text = self.allMovies[section].title
        }
        headerView.addSubview(label)
        
        return headerView
        
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.filteredMovies = self.allMovies.filter({ (text) -> Bool in
            let tmp: NSString = text.title
            let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return range.location != NSNotFound
        })
        if(self.filteredMovies.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.tableView.reloadData()
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        self.searchBar.resignFirstResponder()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier != "TopToError" {
            let indexPath = self.tableView.indexPathForSelectedRow
            let destination = segue.destinationViewController as! DetailViewController
            if searchActive {
                destination.movieObject = self.filteredMovies[indexPath!.section]
            } else {
                destination.movieObject = self.allMovies[indexPath!.section]
            }
        }
    }
}
