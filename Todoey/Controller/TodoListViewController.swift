//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController,UINavigationBarDelegate{
    
    let realm = try! Realm()
    var todoItems : Results<Item>?
    var selectedCategory : Categories? {
        didSet {
            loadItems()
        }
    }
    
    
    @IBOutlet var searchBar: UISearchBar!
    var dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("items.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
        
}

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.backgroundColor = UIColor(hexString: selectedCategory!.colour)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.backgroundColor = .systemBlue
    }
    
    @IBAction func addPressed(_ sender: Any) {
        
        var itemTextField = UITextField()
        
        let alert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
        alert.addTextField{ UITextField in
            UITextField.placeholder = "Add New Item!"
            itemTextField = UITextField
        }
        let action = UIAlertAction(title: "Add item", style: .default) {
            action in
            if itemTextField.text?.count != 0 {
                
                if let currentCategory = self.selectedCategory {
                    
                    do{
                        try self.realm.write {
                            let newItem = Item()
                            newItem.title = itemTextField.text ?? "NONE"
                            newItem.dateCreated = Date()
                            currentCategory.items.append(newItem)
                        }
                    }catch{
                        print("error saving items \(error)")
                    }
                    
                }
                
                self.tableView.reloadData()
                
            }else{
                
                alert.dismiss(animated: true)
            }
           
      
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert,animated: true,completion: nil)
        
    }

    override func updateModel(at indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            do{
                try realm.write {
                    realm.delete(item)
                }
            }catch{
                print(error)
            }
        }
    }
    
    
    //MARK: - Tableview DataSource Methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row]{
            
            if let colour = UIColor(hexString: selectedCategory!.colour)!.darken(byPercentage: (CGFloat(indexPath.row) / CGFloat(todoItems!.count))) {
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
            
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done == true ? .checkmark : .none
        }else{
            cell.textLabel?.text = "No items added!"
        }
        
        
        
        return cell
    }
    
    //MARK: - Tableview Delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(itemArray[indexPath.row])
        
        if let item = todoItems?[indexPath.row] {
            do{
                try realm.write {
                    item.done = !item.done
                }
            }catch{
                print(error)
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)

    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            if let item = todoItems?[indexPath.row] {
                do{
                    try realm.write {
                        realm.delete(item)
                    }
                }catch{
                    print(error)
                }
            }
            tableView.reloadData()
        }
        
    }
    
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title",ascending: true)
        tableView.reloadData()
    }
    
}

// MARK: - Search Bar Methods
extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        let request : NSFetchRequest<Item> = Item.fetchRequest()
        if searchBar.text?.count != 0 {
            todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text ?? "").sorted(byKeyPath: "dateCreated", ascending: true)
            tableView.reloadData()
        }else{
            view.endEditing(true)
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            view.endEditing(true)
        }
    }
}

// MARK: - Gesture Recognizer Delegate

extension TodoListViewController:UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }

}
