//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by mac on 30/09/2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework


class CategoryTableViewController: SwipeTableViewController,UINavigationBarDelegate {

    let realm = try! Realm()
    
    var category : Results<Categories>?
    var isAlertPresented = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
        loadCategories()
        
    }
    
   
    
    func save(_ category:Categories) {
        do {
            try realm.write {
                realm.add(category)
            }
        }catch{
            print(print("couldnt save categories : \(error)"))
        }
        tableView.reloadData()
    }
    
    func loadCategories() {
    
        category = realm.objects(Categories.self)
        tableView.reloadData()
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { action in
            let newCategory = Categories()
            if textField.text?.count != 0 {
                newCategory.name = textField.text!
                newCategory.colour = UIColor.randomFlat().hexValue()
                self.save(newCategory)
            }else{
                alert.dismiss(animated: true)
            }
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(action)
        alert.addAction(cancelAction)
        alert.addTextField { field in
            textField = field
            textField.placeholder = "Add"
            
        }
        present(alert, animated: true)
        
    }
    
    //MARK: - delete data
    
    override func updateModel(at indexPath: IndexPath) {
        
       if let category = self.category?[indexPath.row] {
           do{
               try self.realm.write {
                   self.realm.delete(category)
               }
           }catch{
               print(error)
           }
       }
    }
    
    // MARK: - Table view delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = category?[indexPath.row]
            destinationVC.navigationItem.title = category?[indexPath.row].name
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if (editingStyle == .delete) {
//            if let category = category?[indexPath.row] {
//                do{
//                    try realm.write {
//                        realm.delete(category)
//                    }
//                }catch{
//                    print(error)
//                }
//            }
//            tableView.reloadData()
//        }
//        
//    }
    // MARK: - Table view data source

   

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return category?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        
        cell.textLabel?.text = category?[indexPath.row].name ?? "No categories added yet!"
        cell.backgroundColor = UIColor(hexString: category?[indexPath.row].colour ?? "#ADD8E6")
        return cell
    }

}




