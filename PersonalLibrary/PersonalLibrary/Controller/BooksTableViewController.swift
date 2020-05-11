//
//  BooksTableViewController.swift
//  PersonalLibrary
//
//  Created by macOSHighSierra on 02/04/2020.
//  Copyright © 2020 David R. Ferreira. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import SwiftyJSON


class BooksTableViewController: BookListTableViewController
{
    
    // Base url to connect to the Google Books API.
    var baseURL : String = "https://www.googleapis.com/books/v1/volumes?"

    // This dictionary will contain the information returned from the Google Book API search.
    var bookInformationReturnedOnline = [String : String]()
    
   
    

    //****************************************************************************
    //MARK: - Update UI's Components Methods
    //****************************************************************************
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
            
        loadBooks()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        loadBooks()
    }

    
    //****************************************************************************
    //MARK: - TableView DataSource Methods
    //****************************************************************************
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return books?.count ?? 1
    }

    
    
    //****************************************************************************
    //MARK: - Alerts Methods
    //****************************************************************************
    
    @IBAction func addNewBookButtonPressed(_ sender: UIBarButtonItem)
    {
        // This function will be called when the user presses the add new book button.
        // It will display an alert that let's the user select the insertion method.
        
        let alertChooseInsertionMethod = UIAlertController(title: "Add a new book", message: "Insert book's information", preferredStyle: .actionSheet)

        // If the user selects the manual insertion.
        // The program will directly segue to the Add New Book View (with the fields blank).
        let manualInsertionAction = UIAlertAction (title: "Manually", style: .default) { UIAlertAction in
            self.performSegue(withIdentifier: "goToAddNewBookView", sender: self)
        }
        alertChooseInsertionMethod.addAction(manualInsertionAction)
        
        // If the user wants to search the information online.
        // This will trigger the networking calls.
        let apiInsertionAction = UIAlertAction(title: "Automatically search online", style: .default) { UIAlertAction in
            self.insertISBNForOnlineSearching()
        }
        alertChooseInsertionMethod.addAction(apiInsertionAction)
        
        // If the user selects the cancel button.
        // Nothing will happen.
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertChooseInsertionMethod.addAction(cancelAction)
        
        
        self.present(alertChooseInsertionMethod, animated: true, completion: nil)
    }
    
    
    
    func insertISBNForOnlineSearching()
    {
        // This function will be called when the user wants to search for the book's information online.
        // This will display an alert with a textField in order for the user to insert the ISBN of the book he wants to add.
        
        let alertInsertISBN = UIAlertController(title: "Search online onformation", message: "Insert the book's ISBN", preferredStyle: .alert)
        
        
        alertInsertISBN.addTextField(configurationHandler: {textField in
            textField.placeholder = "Book's ISBN"
        })
        
        // If the user confirms the entered ISBN.
        let confirmAction = UIAlertAction(title: "Search", style: .default) { UIAlertAction in
            
            if let ISBNToSearch = alertInsertISBN.textFields?.first?.text
            {
                self.getBookData(ISBNToSearch: ISBNToSearch)
            }
        }
        alertInsertISBN.addAction(confirmAction)
        
        // If the user selects the Cancel button nothing will happen.
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertInsertISBN.addAction(cancelAction)
        
        
        self.present(alertInsertISBN, animated: true, completion: nil)
    }
    
    
    
    
    //****************************************************************************
    //MARK: - Segues Methods
    //****************************************************************************
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "goToBookDetailsView")
        {
            let destinationVC = segue.destination as! BookDetailsTableViewController
            
            if let indexPath = tableView.indexPathForSelectedRow
            {
                destinationVC.selectedBook = books?[indexPath.row]
            }
        }
        else if (segue.identifier == "goToAddNewBookView")
        {
            // It will pass the searched book's information contained in the dictionary to the next view.
            
            let destinationVC = segue.destination as! EditBookInformationViewController
            
            destinationVC.onlineInformationPassedOver = bookInformationReturnedOnline
        }
    }
    
    
    
    
    /***************************************************************/
    //MARK: - Networking
    /***************************************************************/
    
    func getBookData(ISBNToSearch : String)
    {
        // Makes a request to API and if it is sucessful then it receives a JSON response.
        
        let finalURL : String = baseURL + "q=isbn:\(ISBNToSearch)"
  
        Alamofire.request(finalURL, method: .get).responseJSON
        {
            response in
            if (response.result.isSuccess)
            {
                let bookJSON : JSON = JSON(response.result.value!)
                
                self.updateNewsData(json: bookJSON)
            }
            else
            {
                print("Error \(String(describing: response.result.error))")
            }
        }
    }
    
    
    /***************************************************************/
    //MARK: - JSON Parsing
    /***************************************************************/
    
    func updateNewsData(json : JSON)
    {        
        bookInformationReturnedOnline = ["title" : json["items"][0]["volumeInfo"]["title"].stringValue,
                                         "authorName" : json["items"][0]["volumeInfo"]["authors"][0].stringValue,
                                         "ISBN" : json["items"][0]["volumeInfo"]["industryIdentifiers"][0]["identifier"].stringValue,
                                         "publisher" : json["items"][0]["volumeInfo"]["publisher"].stringValue,
                                         "plotSummary" : json["items"][0]["volumeInfo"]["description"].stringValue,
                                         "numberOfPages" : json["items"][0]["volumeInfo"]["pageCount"].stringValue,
                                         "language" : json["items"][0]["volumeInfo"]["language"].stringValue,
                                         "imageURL" : json["items"][0]["volumeInfo"]["imageLinks"]["thumbnail"].stringValue]

       
        self.performSegue(withIdentifier: "goToAddNewBookView", sender: self)
    }
}
    
    
    



