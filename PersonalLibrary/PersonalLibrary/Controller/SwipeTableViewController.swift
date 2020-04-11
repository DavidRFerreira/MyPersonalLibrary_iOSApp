//
//  SwipeTableViewController.swift
//  PersonalLibrary
//
//  Created by macOSHighSierra on 07/04/2020.
//  Copyright © 2020 David R. Ferreira. All rights reserved.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate
{

    var cell: UITableViewCell?
    
    
    //****************************************************************************
    //MARK: - UIView LifeCycle Methods
    //****************************************************************************
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableView.rowHeight = 165.0
        
    }
    


    //****************************************************************************
    //MARK: - TableView Datasource Methods
    //****************************************************************************
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BookCell
        
        cell.delegate = self

        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]?
    {
        
        guard orientation == .right else { return nil }
        

        //Swipe option to mark book as onLoan/returned.
        let lendAction = SwipeAction(style: .default, title: "Returned") { action, indexPath in

            self.markLoanAlert(indexPath: indexPath)
        }
        
        if (returnBookIsOnLoanState(indexPath: indexPath) == false)
        {
            lendAction.title = "Lend"
        }
        
        lendAction.backgroundColor = UIColor.init(hexString: "#5188A3")
        
        
        
        //Swipe option to mark book as read/unread.
        let readAction = SwipeAction(style: .default, title: "Read") { action, indexPath in

            self.markReadAlert(indexPath: indexPath)
            
        }
        
        readAction.backgroundColor = UIColor.yellow
        
        if (returnBookIsRead(indexPath: indexPath) == false)
        {
            readAction.title = "Read"
        }
        
        readAction.backgroundColor = UIColor.init(hexString: "#5B99B7")
        
        //Swipe option to delete book.
        let deleteAction = SwipeAction(style: .default, title: "Delete") { action, indexPath in
           
            let alertDeleteBook = UIAlertController(title: "Delete Book", message: "Are you sure you want to delete the book?", preferredStyle: .alert)
            
            alertDeleteBook.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alertDeleteBook, animated: true)
            
            alertDeleteBook.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            
                self.deleteBookFromModel(indexPath: indexPath)
            }))
        }
        
        deleteAction.backgroundColor = UIColor.init(hexString: "#E50000")
        
        return [deleteAction, lendAction, readAction]
    }
    
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions
    {
        var options = SwipeTableOptions()
        options.transitionStyle = .drag
        
        return options
    }
    
    
    
    //The implementation for this methods are provived on the derived class.
    func markLoanAlert(indexPath : IndexPath)
    {
    }
    
    func returnBookIsOnLoanState(indexPath : IndexPath) -> Bool
    {
        return false
    }
    
    func markReadAlert(indexPath : IndexPath)
    {
    }
    
    func returnBookIsRead(indexPath: IndexPath) -> Bool
    {
        return false
    }
    
    func deleteBookFromModel(indexPath: IndexPath)
    {
    }
}

extension UIColor
{
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
