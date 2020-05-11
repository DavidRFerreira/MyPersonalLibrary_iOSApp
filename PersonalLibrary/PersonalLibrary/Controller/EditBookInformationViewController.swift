//
//  EditBookInformationViewController.swift
//  PersonalLibrary
//
//  Created by macOSHighSierra on 01/04/2020.
//  Copyright © 2020 David R. Ferreira. All rights reserved.
//

import UIKit
import RealmSwift
import AlamofireImage

class EditBookInformationViewController: UITableViewController
{

    @IBOutlet weak var textFieldBookTitle: UITextField!
    @IBOutlet weak var textFieldAuthorName: UITextField!
    @IBOutlet weak var textFieldISBN: UITextField!
    @IBOutlet weak var textFieldPublisher: UITextField!
    @IBOutlet weak var textViewPlotSummary: UITextView!
    @IBOutlet weak var textFieldNumberPages: UITextField!
    @IBOutlet weak var textFieldLanguage: UITextField!
    @IBOutlet weak var switchReadBook: UISwitch!
    @IBOutlet weak var switchOnLoan: UISwitch!
    @IBOutlet weak var textFieldLentToName: UITextField!
    @IBOutlet weak var bookCoverImage: UIImageView!
    
    
    let realm = try! Realm()
    
    
    /* This will not be nil if we are going to edit the information of an existing book.
    This happens when the user selects a book for this purpose.
    In this case, it will fill the fields with the existing book's information. */
    var selectedBookToEdit : Book?
    
    // This will hold the book's front cover.
    var imagePicker = UIImagePickerController()
    
    // The url of where the image will be saved in the file system.
    var urlImageFilePath : String = ""
    
    /* This will have any content only if the user searches for the information online,
     using the ISBN. In this case, it will fill the fields with the returned information.
     This dictionary will receive the content from the last view. */
    var onlineInformationPassedOver = [String : String]()
    
    
    
    //****************************************************************************
    //MARK: - UIView LifeCycle Methods
    //****************************************************************************
    override func viewDidLoad()
    {
        super.viewDidLoad()

        imagePicker.delegate = self
        
        bookCoverImage.image = UIImage(named: "stock-book-cover")
        
        switchOnLoan.addTarget(self, action: #selector(switchOnLoanValueChanged), for: .valueChanged)
        
        // If we are changing the information of an already existing book.
        if selectedBookToEdit != nil
        {
            // Fill the fields with the existing information.
            displayInformationOfExistingBook()
        }
        // If we are going to display the information of an online search.
        else if (!onlineInformationPassedOver.values.isEmpty)
        {
            // Fill the fields with the retrieved information.
            fillFieldsWithOnlineInformation()
        }
    }
    
    
    
  

    
    //****************************************************************************
    //MARK: - Update UI's Components Methods
    //****************************************************************************
    
    
    @objc func switchOnLoanValueChanged(switchOnLoan: UISwitch)
    {
        /* The user is only alowed to write on the textField related to the Borrower's name,
         if the Switch OnLoan is on. */
        
        if (switchOnLoan.isOn == true)
        {
            textFieldLentToName.isEnabled = true
        }
        else
        {
            textFieldLentToName.isEnabled = false
        }
    }
    
    
    
    @IBAction func addPictureButtonPressed(_ sender: UIButton)
    {
        // Add an image as the book's front cover.
        // This function is called when the user presses the Add Picture Button.
        // In this case, it will open the Photo Library and after the user selects a photo.
        // The photo will be displayed on the imagePicker.
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    func fillFieldsWithOnlineInformation()
    {
        /* This function will be called in the case of the addition of a new book
        by searching for the information online throught the ISBN.
         This will fill all the fields with that returned information.*/
        
        textFieldBookTitle.text = onlineInformationPassedOver["title"]
        textFieldAuthorName.text = onlineInformationPassedOver["authorName"]
        textFieldISBN.text = onlineInformationPassedOver["ISBN"]
        
        textFieldPublisher.text = onlineInformationPassedOver["publisher"]
        textViewPlotSummary.text = onlineInformationPassedOver["plotSummary"]
        textFieldNumberPages.text = onlineInformationPassedOver["numberOfPages"]
        textFieldLanguage.text = onlineInformationPassedOver["language"]
        

        DispatchQueue.main.async
        {
            self.tableView.reloadData()
        }
    }
    
    
    
    func displayInformationOfExistingBook()
    {
        /* This function will be called when the user wants to edit the information
         of an existing book.
         This will fill all the fields with that returned information.*/
        
        textFieldBookTitle.text = selectedBookToEdit?.bookTitle
        textFieldAuthorName.text = selectedBookToEdit?.authorName
        textFieldISBN.text = String(selectedBookToEdit!.ISBN)
        
        textFieldPublisher.text = selectedBookToEdit?.publisherName
        textViewPlotSummary.text = selectedBookToEdit?.plotSummary
        textFieldNumberPages.text = String(selectedBookToEdit!.numberOfPages)
        textFieldLanguage.text = selectedBookToEdit?.language
        
        if (selectedBookToEdit?.bookWasRead == true)
        {
            switchReadBook.isOn = true
        }
        else
        {
            switchReadBook.isOn = false
        }

        if (selectedBookToEdit?.bookIsOnLoan == true)
        {
            switchOnLoan.isOn = true
            textFieldLentToName.isEnabled = true
            textFieldLentToName.text = selectedBookToEdit?.bookBorrowerName
        }
        else
        {
            switchOnLoan.isOn = false
            textFieldLentToName.isEnabled = false
            textFieldLentToName.text = ""
        }
        
    
        if let urlImagePath = selectedBookToEdit?.ISBN
        {
            displayImageFrontCoverExistingBook(imagePath: String(urlImagePath))
        }
        
        DispatchQueue.main.async
        {
                self.tableView.reloadData()
        }
    }
    
    
    
    func displayImageFrontCoverExistingBook(imagePath : String)
    {
        if let savedImage = self.retrieveImage(forKey: imagePath, inStorageType: .fileSystem)
        {
            self.bookCoverImage.image = savedImage
        }
    }
    
    
    
    //****************************************************************************
    //MARK: - Saving Book's Information Methods
    //****************************************************************************

    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem)
    {
        /* This function will be called when the the user presses the save
         button in order to save the book's information to the realm database. */
        
        /* If we are editing the information of an already existing book,
         we will just update the information on the database. */
        if (selectedBookToEdit != nil)
        {
            if let item = selectedBookToEdit
            {
                do
                {
                    try realm.write
                    {
                        if (!updateBookDetails(bookToSave: item))
                        {
                            showAlertIncompleteFields()
                        }
                        
                        navigationController?.popViewController(animated: true)
                        dismiss(animated: true, completion: nil)
                    }
                }
                catch
                {
                    print("Error saving new information, \(error)")
                }
            }
        }
        /* In the case we are adding a new book, we are going to
             save the information into the database. */
        else
        {
            let newBook = Book()
            
            if (updateBookDetails(bookToSave: newBook))
            {
                do
                {
                    try realm.write
                    {
                        realm.add(newBook)
                        
                        navigationController?.popViewController(animated: true)
                        dismiss(animated: true, completion: nil)
                    }
                }
                catch
                {
                    print("Error saving book \(error)")
                }
            }
            else
            {
                showAlertIncompleteFields()
            }
        }
    }
    
    
    func showAlertIncompleteFields()
    {
        // Displays a message if there is a single field not filled.
        
        let alertFieldsNotFilled = UIAlertController(title: "Incomplete Information", message: "Please fill in all fields.", preferredStyle: .alert)
        alertFieldsNotFilled .addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alertFieldsNotFilled, animated: true)
    }
    
    
    
//    func showAlertInformationSaved() -> Void
//    {
//        let alert = UIAlertController(title: "Changes Saved", message: "The book's information have been successfully saved", preferredStyle: .alert)
//
//        self.present(alert, animated: true, completion: nil)
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5)
//        {
//            alert.dismiss(animated: true, completion: nil)
//        }
//    }
    
    
    func updateBookDetails(bookToSave : Book) -> Bool
    {
        /* This function will return true only if all fields (except for textFieldLentToName)
        are completed.*/
        
        if let bookTitle = textFieldBookTitle.text, !bookTitle.isEmpty,
            let authorName = textFieldAuthorName.text, !authorName.isEmpty,
            let isbn = textFieldISBN.text, !isbn.isEmpty,
            let publisher = textFieldPublisher.text, !publisher.isEmpty,
            let plotSummary = textViewPlotSummary.text, !plotSummary.isEmpty,
            let numberOfPages = textFieldNumberPages.text, !numberOfPages.isEmpty,
            let language = textFieldLanguage.text, !language.isEmpty,
            let bookBorrowerName = textFieldLentToName.text
        {
            bookToSave.bookTitle = bookTitle
            bookToSave.authorName = authorName
            bookToSave.ISBN = Int(isbn) ?? 0
            bookToSave.publisherName = publisher
            bookToSave.plotSummary = plotSummary
            bookToSave.numberOfPages = Int(numberOfPages) ?? 0
            bookToSave.language = language
            
            if (switchReadBook.isOn == true)
            {
                bookToSave.bookWasRead = true
            }
            else
            {
                bookToSave.bookWasRead = false
            }
            
            
            if (switchOnLoan.isOn == true)
            {
                bookToSave.bookIsOnLoan = true
            }
            else
            {
                bookToSave.bookIsOnLoan = false
            }
            
            bookToSave.bookBorrowerName = bookBorrowerName
            
            saveImageToFileSystem(ISBNKey: isbn, imagePassed : bookCoverImage, urlImageFilePath: &urlImageFilePath)
                
            bookToSave.urlImageFrontCover = urlImageFilePath
            
            return true
        }
        
        return false
    }
}




//****************************************************************************
//MARK: - Image Cover Manipulation
//****************************************************************************
extension EditBookInformationViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    // Displays the selected photo from the library in the UI Image View.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            bookCoverImage.image = image
        }
        
        dismiss(animated: true, completion: nil)
    }
}


extension EditBookInformationViewController : ImagesFileSystemRealmManager
{}
