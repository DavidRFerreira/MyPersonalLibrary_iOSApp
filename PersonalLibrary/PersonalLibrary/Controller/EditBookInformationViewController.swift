//
//  EditBookInformationViewController.swift
//  PersonalLibrary
//
//  Created by macOSHighSierra on 01/04/2020.
//  Copyright © 2020 David R. Ferreira. All rights reserved.
//

import UIKit
import RealmSwift

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
    
    var selectedBookToEdit : Book?
    
    var imagePicker = UIImagePickerController()
    
    var urlImageFilePath : String = ""
    
    
    
    //****************************************************************************
    //MARK: - UIView LifeCycle Methods
    //****************************************************************************
    override func viewDidLoad()
    {
        super.viewDidLoad()

        imagePicker.delegate = self
        
        switchOnLoan.addTarget(self, action: #selector(switchOnLoanValueChanged), for: .valueChanged)
        
        // If we are changing the information of an already existing book.
        if selectedBookToEdit != nil
        {
            displayInformationOfExistingBook()
        }
    }
    
    
    
  

    
    //****************************************************************************
    //MARK: - Update UI's Components Methods
    //****************************************************************************
    
    
    @objc func switchOnLoanValueChanged(switchOnLoan: UISwitch)
    {
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
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    func displayInformationOfExistingBook()
    {
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
    //MARK: - Realm Saving Book's Information Methods
    //****************************************************************************

    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem)
    {
        
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
                        
                        //showAlertInformationSaved(title: "Changes Saved", message: "The book's information have been successfully saved")
        
                    }
                }
                catch
                {
                    print("Error saving new information, \(error)")
                }
            }
        }
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
                        
                        //showAlertInformationSaved(title: "Changes Saved", message: "The book's information have been successfully saved")
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
        let alertFieldsNotFilled = UIAlertController(title: "Incomplete Information", message: "Please fill in all fields.", preferredStyle: .alert)
        alertFieldsNotFilled .addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alertFieldsNotFilled, animated: true)
    }
    
    func showAlertInformationSaved() -> Void
    {
        let alert = UIAlertController(title: "Changes Saved", message: "The book's information have been successfully saved", preferredStyle: .alert)
        
        self.present(alert, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5)
        {
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    
    func updateBookDetails(bookToSave : Book) -> Bool
    {
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
    //Displays the selected photo from the library in the UI Image View.
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
