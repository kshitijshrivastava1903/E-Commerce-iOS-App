//
//  BasketViewController.swift
//  Market
//
//  Created by Love Shrivastava on 6/23/22.
//

import UIKit
import JGProgressHUD

class BasketViewController: UIViewController, WelcomeViewDelegate2 {

    
    //MARK :- IBOutlets
    
    @IBOutlet weak var footerView: UIView!
    
    
    @IBOutlet weak var basketTotalPriceLabel: UILabel!
    
    
    @IBOutlet weak var totalItemsLabel: UILabel!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var checkOutButtonOutlet: UIButton!
    
    
    // MARK : - Vars
    
    var basket:Basket?
    var allItems:[Item] = []
    var purchasedItemsIds : [String] = []
    
    let hud = JGProgressHUD(style: .dark)
    
    
    
    
    //MARK : IBActions
    
    
    @IBAction func checkOutButtonPressed(_ sender: Any) {
        
        if cuid == nil{
        let loginView = storyboard?.instantiateViewController(withIdentifier: "loginView") as? WelcomeViewController
            loginView!.delegate2 = self
            self.present(loginView!,animated: true,completion: nil)
            //print(cuid)
            //loadBasketFromFirestore()
        }
        
        else{
        loggedIn = nil
        cuid = nil
        loadBasketFromFirestore()
        self.hud.textLabel.text = "Logged Out Successfuly!"
        self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        self.hud.show(in:self.view)
        self.hud.dismiss(afterDelay: 1.0 )
        
        allItems.removeAll()
        
        tableView.reloadData()
        }
        
//        let loginView = storyboard?.instantiateViewController(withIdentifier: "categoryView") as? CategoryCollectionViewController
//
//        //loginView!.delegate = self
//
//        self.present(loginView!,animated: true,completion: nil)
        
        
    }
    
    func userIdWasReceived(_ cuserId: String) {
        print("Basket View recevied user Id \(cuserId)")
        cuid = cuserId
        loadBasketFromFirestore()
        self.tableView.reloadData()
    }
    
    // MARK : View Lifecycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = footerView
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        loadBasketFromFirestore()
        
        
        
        
        
        
        
        
        
        //TODO : Check if user is logged in
        
        
    }
    
    
    // MARK : Download Basket
    
    private func loadBasketFromFirestore(){
        
        if(cuid == nil){
            
            self.updateTotalLabels(true)
            self.updateTotalPrice(true)
            self.checkoutButtonStatusUpdate()
            
        }
        
        else{
        downloadBasketFromFirestore(cuid!) { (basket) in
            
            //print("Downloading basket for user with user id \(cuid)")
            self.basket = basket
            self.getBasketItems()
            
        }
        }
        
    }
    
    private func getBasketItems(){
        
        if basket != nil {
            
            downloadItems(basket!.itemIds) { (allItems) in
                
                self.allItems = allItems
                if self.allItems.count>0{
                    self.updateTotalLabels(false)
                    self.updateTotalPrice(false)
                    self.checkoutButtonStatusUpdate()
                }
                else{
                    self.updateTotalLabels(true)
                    self.updateTotalPrice(true)
                    self.checkoutButtonStatusUpdate()
                }
                
                self.tableView.reloadData()
            }
        }
        
        else{
            
            //Create Basket for user is cuid
            let newBasket = Basket()
            newBasket.id = UUID().uuidString
            newBasket.ownerId = cuid!
            newBasket.itemIds = []
            checkoutButtonStatusUpdate()
            saveBasketToFirestore(newBasket)
            
        }
        
    }
    
    // MARK : Helper Functions
    
    private func updateTotalLabels(_ isEmpty:Bool){
        
        if isEmpty{
            totalItemsLabel.text = "0"
        }
        
        else
        {
            totalItemsLabel.text = "\(allItems.count)"
        }
        
        //Update Button Status
    }
    
    private func returnBasketTotalPrice() -> String{
        var tp : Double
        tp = 0
        for item in allItems{
            tp = tp + Double(item.price)
        }
        
        return String(convertToCurrency(tp))
    }
    
    // MARK : Navigation
    
    private func showItemView(withItem: Item){
        let itemVC = UIStoryboard.init(name:"Main",bundle: nil).instantiateViewController(withIdentifier: "itemView") as! ItemViewController
        
        itemVC.item = withItem
        
        self.navigationController?.pushViewController(itemVC, animated: true)
    }
     
    
    private func updateTotalPrice(_ isEmpty:Bool){
        
        if isEmpty
        {
            basketTotalPriceLabel.text = "Total Price : 0"
        }
        
        else
        {
            basketTotalPriceLabel.text = "Total Price : \(returnBasketTotalPrice())"
        }
        
    }
    
    // MARK : Control checkoutButton
    
    private func checkoutButtonStatusUpdate(){
        
        //checkOutButtonOutlet.isEnabled = cuid != nil
        
        if cuid != nil{
            checkOutButtonOutlet.setTitle("Log Out user ID : \(cuid!)", for: .normal)
            checkOutButtonOutlet.backgroundColor = UIColor.gray
            //checkOutButtonOutlet.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        }
        
        else
        {
            checkOutButtonOutlet.setTitle(" Log In", for: .normal)
            checkOutButtonOutlet.backgroundColor = UIColor.systemYellow
            
            
            //checkOutButtonOutlet.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            
        }
    }
    
    private func removeItemFromBasket(itemId:String)
    {
        for i in 0..<basket!.itemIds.count{
            if itemId == basket!.itemIds[i]{
                basket!.itemIds.remove(at: i)
                
                return
            }
        }
    }

   
}




extension BasketViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allItems.count;
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",for:indexPath) as! ItemTableViewCell
        
        cell.generateCell(allItems[indexPath.row])
        return cell
    }
    
    
    // MARK : UITableview Delegate
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            let itemToDelete = allItems[indexPath.row]
            
            allItems.remove(at:indexPath.row)
            
            tableView.reloadData()
            
            removeItemFromBasket(itemId: itemToDelete.id)
            
            updateBasketInFirestore(basket!, withValues: [kITEMIDS:basket!.itemIds]) { (error) in
                
                if error != nil{
                    print("Error updating the basket", error!.localizedDescription)
                }
                
                self.getBasketItems()
                
            }
            
            
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showItemView(withItem:allItems[indexPath.row])
    }
    
    
    
}

protocol WelcomeViewDelegate2: class {
    func userIdWasReceived(_ cuserId: String)
}
