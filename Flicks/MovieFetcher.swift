//
//  MovieFetcher.swift
//  Flicks
//
//  Created by Jerry on 2/2/16.
//  Copyright © 2016 Jerry Lao. All rights reserved.
//

import Foundation
import UIKit

class MovieFetcher {
    
    var movieArray = [Movie]()
    private var movie:Movie?
    
    func getMovieArray(url:String) -> [NSDictionary]? {
        let getUrl = NSURL(string: url)
        let jsonData = NSData(contentsOfURL: getUrl!)
        var movieDict:NSDictionary!
        do {
            movieDict = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions()) as! NSDictionary
            
        } catch {
            print(error)
            return nil
        }
        return movieDict.objectForKey("results") as? [NSDictionary]
    }
    
    func createMovie(movieArray: [NSDictionary]) -> [Movie] {
        var arrayOfMovies = [Movie]()
        for result in movieArray {
            let title = result.objectForKey("original_title") as? String
            let overview = result.objectForKey("overview") as? String
            let votes = result.objectForKey("vote_average") as? Int
            let popularity = result.objectForKey("popularity") as? Float
            let genre = result.objectForKey("genre_ids") as? [Int]
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-mm-dd"
            let releaseDate = (result.objectForKey("release_date") as? String)
            let formattedDate = formatter.dateFromString(releaseDate!)!
            
            self.movie = Movie(title: title!, overview: overview!, votes: votes!, popularity: popularity!, genre: genre!, releaseDate: formattedDate)
            
            if let backdropPath = result.objectForKey("backdrop_path") as? String {
                
                if let posterUrl = NSURL(string: "http://image.tmdb.org/t/p/w1000"+backdropPath) {
                    self.movie?.posterImageUrl = posterUrl
                }
                if let thumbUrl = NSURL(string: "http://image.tmdb.org/t/p/w300"+backdropPath) {
                    self.movie?.thumbnailUrl = thumbUrl
                }
            }
            
            arrayOfMovies.append(self.movie!)
        }
        return arrayOfMovies
    }
    
    
//    func downloadImage(url: NSURL){
//        getDataFromUrl(url) { (data, response, error)  in
//            dispatch_async(dispatch_get_main_queue()) { () -> Void in
//                guard let data = data where error == nil else { return }
//                if let poster = UIImage(data: data) {
//                    self.movie?.posterImage = poster as UIImage
//                }
//            }
//        }
//    }
//    
//    func downloadThumbnailImage(url: NSURL){
//        getDataFromUrl(url) { (data, response, error)  in
//            dispatch_async(dispatch_get_main_queue()) { () -> Void in
//                guard let data = data where error == nil else { return }
//                if let thumbnail = UIImage(data: data) {
//                    self.movie?.thumbnail = thumbnail as UIImage
//                }
//            }
//        }
//    }
//    
//    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
//        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
//            completion(data: data, response: response, error: error)
//            }.resume()
//    }
}