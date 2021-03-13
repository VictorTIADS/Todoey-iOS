//
//  CategoryViewController.swift
//  TodoeyCoreData
//
//  Created by Victor Batista on 10/03/21.
//  Copyright © 2021 Victor Batista. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categoryList:Results<Category>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems()
        
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {fatalError()}
        navBar.backgroundColor = UIColor(hexString: "1D9BBF6")
    }

    
    func showAlert(){
        var alertTextField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .cancel) { (action) in
            if alertTextField.text != "" && alertTextField.text != nil{
                self.addItem(alertTextField.text!)
            }
        }
        alert.addAction(action)
        alert.addTextField { (textField) in
            textField.placeholder = "Create new category"
            alertTextField = textField
        }
        present(alert, animated: true, completion: nil)
    }
    
    func addItem(_ text: String){
        let item = Category()
        item.name = text
        item.color = UIColor.randomFlat().hexValue()
        save(category: item)
    }
   
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        showAlert()
    }
 
    func save(category: Category){
        do {
            try realm.write {
                realm.add(category)
            }
            loadItems()
        } catch {
            print(error)
        }
    }
    
    
    func loadItems() {
        categoryList = realm.objects(Category.self)
        reloadTable()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let category = categoryList?[indexPath.row] {
            do {
                try self.realm.write{
                    self.realm.delete(category)
                }
            } catch {
                print(error)
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        cell.textLabel?.text = categoryList?[indexPath.row].name ?? "No Categories added yet"
        
        cell.backgroundColor = UIColor(hexString: categoryList?[indexPath.row].color ?? "#FFFFFF")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryList?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigateToItems()
    }
    
    func navigateToItems(){
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as? TodoViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destination?.selectedCategory = categoryList?[indexPath.row]
        }
    }
    
    
    func reloadTable(){
        tableView.reloadData()
    }

}

