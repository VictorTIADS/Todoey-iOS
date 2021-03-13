//
//  ViewController.swift
//  TodoeyCoreData
//
//  Created by Victor Batista on 07/03/21.
//  Copyright © 2021 Victor Batista. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var items:Results<Item>?
    var selectedCategory:Category? {
        didSet {
            loadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
        
      
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewWillAppear(_ animated: Bool) {
        if let colorHex = selectedCategory?.color {
            
            title = selectedCategory!.name
            
            guard let navBar = navigationController?.navigationBar else { fatalError() }
            
            if let navBarColor = UIColor(hexString: colorHex){
                navBar.backgroundColor = navBarColor
                navBar.tintColor = ContrastColorOf(navBarColor,returnFlat: true)
                searchBar.barTintColor = navBarColor
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor:ContrastColorOf(navBarColor,returnFlat: true)]
            }
            
        }
        
    }
    
    @IBAction func addItemButtonPressed(_ sender: UIBarButtonItem) {
        showAlert()
    }
    
    func showAlert(){
        var alertTextField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .cancel) { (action) in
            if alertTextField.text != "" && alertTextField.text != nil{
                self.addItem(alertTextField.text!)
            }
        }
        alert.addAction(action)
        alert.addTextField { (textField) in
            textField.placeholder = "Create new item"
            alertTextField = textField
        }
        present(alert, animated: true, completion: nil)
    }
    
    func addItem(_ text: String){
        if let category = selectedCategory {
            do {
                try realm.write {
                    let item = Item()
                    item.title = text
                    item.dateCreated = Date()
                    category.items.append(item)
                }
            } catch {
                print(error)
            }
        }
        reloadTable()
    }
    
    func loadData(){
        items = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        reloadTable()
    }
    
    func reloadTable(){
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = items?[indexPath.row] {
            do {
                try realm.write{
                    realm.delete(item)
                }
            } catch {
                print(error)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = items?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            
            if let color = UIColor(hexString: selectedCategory!.color!)?.darken(byPercentage:(CGFloat(indexPath.row) / CGFloat(items!.count))) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
                
            }
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = items?[indexPath.row] {
            do {
                try realm.write{
                    item.done = !item.done
                }
            } catch {
                print(error)
            }
        }
        
        reloadTable()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}


//MARK: - Search Delegate
extension TodoViewController: UISearchBarDelegate {
    
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            items = items?.filter("title CONTAINS[cd] %@",searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
            reloadTable()
    
        }
    
    
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            if searchBar.text?.count == 0 {
                loadData()
                
                DispatchQueue.main.async {
                    searchBar.resignFirstResponder()
                }
            }
        }
    
}
