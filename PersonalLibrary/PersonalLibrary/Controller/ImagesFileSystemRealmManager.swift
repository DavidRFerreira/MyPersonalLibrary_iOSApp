//
//  ImagesFileSystem-RealmManager.swift
//  PersonalLibrary
//
//  Created by macOSHighSierra on 07/04/2020.
//  Copyright © 2020 David R. Ferreira. All rights reserved.
//

import Foundation
import UIKit

//Mixin
protocol ImagesFileSystemRealmManager
{
    func retrieveImage(forKey key: String, inStorageType storageType: StorageType) -> UIImage?
    
    func filePath(forKey key: String) ->URL?
}


enum StorageType
{
    case fileSystem
    case userDefaults
}

extension ImagesFileSystemRealmManager
{
    
    
     func retrieveImage(forKey key: String, inStorageType storageType: StorageType) -> UIImage?
    {
        
        switch storageType
        {
        case .fileSystem:
            
            if let filePath = self.filePath(forKey: key),
                let fileData = FileManager.default.contents(atPath: filePath.path),
                let image = UIImage(data: fileData)
            {
                return image
            }
        default:
            print("The specified storageType is not available.")
        }
        
        return nil
    }
    
    func saveImageToFileSystem(ISBNKey : String, imagePassed : UIImageView, urlImageFilePath: inout String)
    {
        if let image = imagePassed.image
        {
            self.store(image: image,
                       forKey: ISBNKey,
                       withStorageType: .fileSystem, urlImageFilePath: &urlImageFilePath)
        }
    }
    
    
    func filePath(forKey key: String) ->URL?
    {
        let fileManager = FileManager.default
        
        guard let documentURL = fileManager.urls(for: .documentDirectory,
                                                 in: FileManager.SearchPathDomainMask.userDomainMask).first else {return nil}
        
        return documentURL.appendingPathComponent(key + ".png")
    }
    
    
    private func store(image: UIImage, forKey key: String, withStorageType storageType: StorageType, urlImageFilePath: inout String)
    {
        if let pngRepresentation = image.pngData()
        {
            switch storageType
            {
            case .fileSystem:
                if let filePath = filePath(forKey: key)
                {
                    do
                    {
                        try pngRepresentation.write(to: filePath, options: .atomic)
                        urlImageFilePath = filePath.absoluteString
                    }
                    catch
                    {
                        print("Saving file resulted in error: \(error)")
                    }
                }
            default:
                print("The specified storageType is not available.")
            }
        }
    }
}
