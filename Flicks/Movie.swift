//
//  Movie.swift
//  Flicks
//
//  Created by Jerry on 2/2/16.
//  Copyright © 2016 Jerry Lao. All rights reserved.
//

import UIKit
import AFNetworking

class Movie:NSObject {
    var posterImageUrl:NSURL?
    var thumbnailUrl:NSURL?
    var title:String
    var overview:String
    var votes:Int
    var popularity:Float
    var genre:[Int]
    var releaseDate:NSDate
    
    init(title: String, overview: String, votes: Int, popularity: Float, genre:[Int], releaseDate: NSDate) {
        self.title = title
        self.overview = overview
        self.votes = votes
        self.popularity = popularity
        self.genre = genre
        self.releaseDate = releaseDate
    }
}