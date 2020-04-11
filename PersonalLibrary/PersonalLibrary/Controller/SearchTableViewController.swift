//
//  SearchTableViewController.swift
//  PersonalLibrary
//
//  Created by macOSHighSierra on 03/04/2020.
//  Copyright © 2020 David R. Ferreira. All rights reserved.
//

import UIKit
import RealmSwift

class SearchTableViewController: BookListTableViewController
{

    @IBOutlet weak var searchBar: UISearchBar!
    
    
    //****************************************************************************
    //MARK: - UIView LifeCycle Methods
    //****************************************************************************
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        searchBarSetup()
    }
}



//****************************************************************************
//MARK: - SearchBar Methods
//****************************************************************************
extension SearchTableViewController: UISearchBarDelegate
{
    
    func searchBarSetup()
    {
        self.searchBar.sizeToFit()
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        
        if let textToSearch = searchBar.text,
            !textToSearch.isEmpty
        {
            filterTableView(ind: searchBar.selectedScopeButtonIndex, text: textToSearch)
            //books = realm.objects(Book.self).filter("bookTitle CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "bookTitle", ascending: true)
            
            DispatchQueue.main.async
                {
                    self.tableView.reloadData()
            }
        }
    }


    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if searchBar.text?.count == 0
        {
            DispatchQueue.main.async
            {
                searchBar.resignFirstResponder()
            }
        }
    }
    
    
    func filterTableView (ind: Int, text: String)
    {
        switch(ind)
        {
        case 0:
            books = realm.objects(Book.self).filter("bookTitle CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "bookTitle", ascending: true)
            break		
        case 1:
            books = realm.objects(Book.self).filter("ISBN == %@", Int(searchBar.text!)!).sorted(byKeyPath: "ISBN", ascending: true)
            break
        case 2:
            books = realm.objects(Book.self).filter("authorName CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "authorName", ascending: true)
            break
        default:
            print("Error")
            break
        }
    }
    
    
}

