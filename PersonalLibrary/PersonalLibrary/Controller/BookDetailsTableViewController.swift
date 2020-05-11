//
//  BookDetailsTableViewController.swift
//  PersonalLibrary
//
//  Created by macOSHighSierra on 02/04/2020.
//  Copyright © 2020 David R. Ferreira. All rights reserved.
//

import UIKit
import RealmSwift

class BookDetailsTableViewController: UITableViewController
{

    @IBOutlet weak var labelBookTitle: UILabel!
    @IBOutlet weak var labelAuthorName: UILabel!
    @IBOutlet weak var labelISBN: UILabel!
    @IBOutlet weak var labelPublisherName: UILabel!
    @IBOutlet weak var textViewPlotSummary: UITextView!
    @IBOutlet weak var labelNumberPages: UILabel!
    @IBOutlet weak var labelLanguage: UILabel!
    @IBOutlet weak var labelReadingStatus: UILabel!
    @IBOutlet weak var labelLendingStatus: UILabel!
    @IBOutlet weak var labelBorrowerName: UILabel!
    @IBOutlet weak var imageFrontCoverBook: UIImageView!
    
    let realm = try! Realm()

    var selectedBook : Book?
    
    
    
    //****************************************************************************
    //MARK: - UIView LifeCycle Methods
    //****************************************************************************
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        loadBookDetails()
    }

    
    override func viewWillAppear(_ animated: Bool)
    {
        title = selectedBook?.bookTitle
        
        loadBookDetails()
        
        DispatchQueue.main.async
        {
                self.tableView.reloadData()
        }
    }
    
    
    
    //****************************************************************************
    //MARK: - Update the UI Components
    //****************************************************************************
    
    func loadBookDetails()
    {
        // Displays the selected book's information.
        
        var urlImagePath : String = ""
        
        labelBookTitle.text = selectedBook?.bookTitle
        labelAuthorName.text = selectedBook?.authorName
        labelISBN.text = String(selectedBook!.ISBN)
        
        labelPublisherName.text = selectedBook?.publisherName
        textViewPlotSummary.text = selectedBook?.plotSummary
        labelNumberPages.text = String(selectedBook!.numberOfPages)
        labelLanguage.text = selectedBook?.language
    
        if (selectedBook?.bookWasRead == true)
        {
             labelReadingStatus.text = "Already Read"
        }
        else
        {
            labelReadingStatus.text = "Not Read"
        }
        
    
        if (selectedBook?.bookIsOnLoan == true)
        {
            labelLendingStatus.text = "On loan"
            labelBorrowerName.text = selectedBook?.bookBorrowerName
        }
        else
        {
            labelLendingStatus.text = "Not On Loan"
            labelBorrowerName.text = ""
        }
        
        urlImagePath = String(selectedBook!.ISBN)
        
        if let image = self.retrieveImage(forKey: urlImagePath, inStorageType: .fileSystem)
        {
            imageFrontCoverBook.image = image
        }


        DispatchQueue.main.async
        {
            self.tableView.reloadData()
        }
    }
    
    
    
    //****************************************************************************
    //MARK: - Image Retrieving from FileSystem Methods
    //****************************************************************************
    
    enum StorageType
    {
        case fileSystem
    }


    private func retrieveImage(forKey key: String, inStorageType storageType: StorageType) -> UIImage?
    {
        // Retrieves and returns the image of the book.

        switch storageType
        {
        case .fileSystem:

            if let filePath = self.filePath(forKey: key),
                let fileData = FileManager.default.contents(atPath: filePath.path),
                let image = UIImage(data: fileData)
            {
                return image
            }
        }

        return nil
    }


    private func filePath(forKey key: String) ->URL?
    {
        // Builds the image url from where we are going to grab the front cover image.

        let fileManager = FileManager.default

        guard let documentURL = fileManager.urls(for: .documentDirectory,
                                                 in: FileManager.SearchPathDomainMask.userDomainMask).first else {return nil}

        return documentURL.appendingPathComponent(key + ".png")
    }
 
    
    
    //****************************************************************************
    //MARK: - Segue Methods.
    //****************************************************************************
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem)
    {
        // This function is called the user presses the edit button.
        
        performSegue(withIdentifier: "goToEditBookView", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "goToEditBookView")
        {
            let destinationVC = segue.destination as! EditBookInformationViewController
            
            destinationVC.selectedBookToEdit = selectedBook
        }
    }
    
}

//extension BookDetailsTableViewController : ImagesFileSystemRealmManager
//{
//}
