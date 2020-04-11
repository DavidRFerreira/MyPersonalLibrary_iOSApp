//
//  BooksTableViewController.swift
//  PersonalLibrary
//
//  Created by macOSHighSierra on 02/04/2020.
//  Copyright © 2020 David R. Ferreira. All rights reserved.
//

import UIKit
import RealmSwift

class BooksTableViewController: BookListTableViewController
{
    

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        loadBooks()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        loadBooks()
    }

    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return books?.count ?? 1
    }

    
    
    @IBAction func addNewBookButtonPressed(_ sender: UIBarButtonItem)
    {
        performSegue(withIdentifier: "goToAddNewBookView", sender: self)
    }
    
}


