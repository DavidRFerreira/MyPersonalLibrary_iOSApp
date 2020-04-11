//
//  BookListTableViewController.swift
//  PersonalLibrary
//
//  Created by macOSHighSierra on 09/04/2020.
//  Copyright © 2020 David R. Ferreira. All rights reserved.
//

import UIKit
import RealmSwift

class BookListTableViewController:  SwipeTableViewController
{
    let realm = try! Realm()
    
    var books : Results<Book>!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()


    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! BookCell
        
        
        var urlImagePath : String = ""
            

        if let book = books?[indexPath.row]
        {
            cell.labelBookTitle.isHidden = false
            cell.labelImageCover.isHidden = false
            cell.labelAuthorName.frame.origin = CGPoint(x: 130, y: 69)

            cell.labelBookTitle.text = book.bookTitle
            cell.labelAuthorName.text = book.authorName
            
            urlImagePath = String(book.ISBN)
            
            if let image = self.retrieveImage(forKey: urlImagePath, inStorageType: .fileSystem)
            {
                cell.labelImageCover.image = image
            }
            
            cell.accessoryType = .disclosureIndicator
            
        }
        else
        {
            cell.labelBookTitle.isHidden = true
            cell.labelImageCover.isHidden = true
            cell.labelAuthorName.text = "No Items Found"
            cell.labelAuthorName.frame.origin = CGPoint(x: 20, y: 11)
        }
        
        return cell
        
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return books?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 165
    }
    
    override func markLoanAlert(indexPath : IndexPath)
    {
        if (self.books?[indexPath.row].bookIsOnLoan == true)
        {
            let alertReturnedBook = UIAlertController(title: "Return Book", message: "The book was marked as returned.", preferredStyle: .alert)
            
            alertReturnedBook.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alertReturnedBook, animated: true)
            
            if let book = self.books?[indexPath.row]
            {
                do
                {
                    try self.realm.write
                    {
                        book.bookIsOnLoan = false
                        book.bookBorrowerName = ""
                    }
                }
                catch
                {
                    print("Error saving done status, \(error)")
                }
            }
        }
        else
        {
            let alertLendBook = UIAlertController(title: "Lend the Book", message: "The book was marked as on loan.", preferredStyle: .alert)
            
            alertLendBook.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            alertLendBook.addTextField(configurationHandler: {textField in
                textField.placeholder = "Borrower's Name"
            })
            
            self.present(alertLendBook, animated: true)
            
            alertLendBook.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                
                if let name = alertLendBook.textFields?.first?.text
                {
                    if let book = self.books?[indexPath.row]
                    {
                        do
                        {
                            try self.realm.write
                            {
                                book.bookIsOnLoan = true
                                book.bookBorrowerName = name
                            }
                        }
                        catch
                        {
                            print("Error saving done status, \(error)")
                        }
                    }
                }
            }))
        }
    }
    
    override func returnBookIsOnLoanState(indexPath : IndexPath) -> Bool
    {
        return books[indexPath.row].bookIsOnLoan
    }
    
    
    
    
    override func markReadAlert(indexPath : IndexPath)
    {
        if (self.books?[indexPath.row].bookWasRead == false)
        {
            let alertReadBook = UIAlertController(title: "Read Book", message: "The book was marked as read.", preferredStyle: .alert)
            
            alertReadBook.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alertReadBook, animated: true)
            
            if let book = self.books?[indexPath.row]
            {
                do
                {
                    try self.realm.write
                    {
                        book.bookWasRead = true
                    }
                }
                catch
                {
                    print("Error saving done status, \(error)")
                }
            }
        }
        else
        {
            let alertUnreadBook = UIAlertController(title: "Unread the Book", message: "The book was marked as not read.", preferredStyle: .alert)
            
            alertUnreadBook.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            
            self.present(alertUnreadBook, animated: true)
            
            if let book = self.books?[indexPath.row]
            {
                do
                {
                    try self.realm.write
                    {
                        book.bookWasRead = false
                    }
                }
                catch
                {
                    print("Error saving done status, \(error)")
                }
            }
        }
    }
    
    override func returnBookIsRead(indexPath: IndexPath) -> Bool
    {
        return books[indexPath.row].bookWasRead
    }
    
    
    
    override func deleteBookFromModel(indexPath: IndexPath)
    {
        // Update our data model.
        if let item = books?[indexPath.row]
        {
            do {
                try self.realm.write {
                    self.realm.delete(item)
                }
            } catch {
                print("Error deleting Item, \(error)")
            }
        }
        
        tableView.reloadData()
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        performSegue(withIdentifier: "goToBookDetailsView", sender: self)
    }
    
    
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
    }
    
    
    func loadBooks()
    {
        books = realm.objects(Book.self)
        
        DispatchQueue.main.async
            {
                self.tableView.reloadData()
        }
    }
    
}


extension SwipeTableViewController : ImagesFileSystemRealmManager
{
    
}
