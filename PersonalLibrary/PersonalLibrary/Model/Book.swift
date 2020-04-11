//
//  Book.swift
//  PersonalLibrary
//
//  Created by macOSHighSierra on 01/04/2020.
//  Copyright © 2020 David R. Ferreira. All rights reserved.
//

import Foundation
import RealmSwift


class Book : Object
{
    @objc dynamic var bookTitle : String = ""
    @objc dynamic var authorName : String = ""
    @objc dynamic var ISBN : Int = 0
    
    @objc dynamic var publisherName : String = ""
   
    @objc dynamic var plotSummary : String = ""
    
    @objc dynamic var numberOfPages : Int = 0
    @objc dynamic var language : String = ""
    
    @objc dynamic var bookWasRead : Bool = false
    @objc dynamic var bookIsOnLoan: Bool = false
    @objc dynamic var bookBorrowerName : String = ""
    
    @objc dynamic var urlImageFrontCover : String = ""
}
