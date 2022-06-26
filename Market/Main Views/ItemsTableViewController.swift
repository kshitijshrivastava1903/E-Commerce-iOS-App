//
//  ItemsTableViewController.swift
//  Market
//
//  Created by Love Shrivastava on 6/17/22.
//

import UIKit

class ItemsTableViewController: UITableViewController {
    
    //MARK : Vars
    
    var category:Category?
    
    var itemArray:[Item] = []
    
    
    //MARK : View Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if category != nil{
            loadItems()
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        self.title = category?.name
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

 
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        showItemView(itemArray[indexPath.row])
    }
    
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemTableViewCell
        
        cell.generateCell(itemArray[indexPath.row])

        // Configure the cell...

        return cell
    }
    
    //MARK: TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        showItemView(itemArray[indexPath.row])
        
    }
     
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "itemToAddItemSeg"{
            
            let vc = segue.destination as! AddItemViewController
            
            vc.category = category!
        }
    }
    
    private func showItemView(_ item:Item){
        
        let itemVC = UIStoryboard.init(name:"Main",bundle: nil).instantiateViewController(withIdentifier: "itemView") as! ItemViewController
        
        itemVC.item = item
        
        self.navigationController?.pushViewController(itemVC, animated: true)
        
        
    }
    //MARK : Load Items
    private func loadItems(){
        
        downloadItemsFromFirebase(category!.id) { (allItems) in
            
            print("We have \(allItems.count) number of items.")
            self.itemArray = allItems
            print(self.itemArray)
            self.tableView.reloadData()
            
        }
        
        
    }
    

}
