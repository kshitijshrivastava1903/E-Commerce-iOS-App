//
//  ItemViewController.swift
//  Market
//
//  Created by Love Shrivastava on 6/20/22.
//

import UIKit
import FirebaseAuth
import JGProgressHUD
//import openssl_grpc
class ItemViewController: UIViewController, WelcomeViewDelegate {
    
    
    
    
    //MARK : IBOutlets
    
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    
    @IBOutlet weak var nameLabel: UILabel!
    
    
    @IBOutlet weak var priceLabel: UILabel!
    
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    //MARK : Vars
    
    var item : Item!
    var itemImages : [UIImage] = []
    let hud = JGProgressHUD(style: .dark)
    private let sectionInsets = UIEdgeInsets(top:0.0,left: 0.0,bottom: 0.0,right:0.0)
    private let cellHeight : CGFloat = 196.0
    private let itemsPerRow : CGFloat = 1
    var currentUid : String?
    
    
    
    
    //MARK : View Lifecycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        downloadPictures()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(self.backAction))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "addToBasket"), style: .plain, target: self, action: #selector(self.addToBasketButtonPressed))

        
    }
    
    func userIdWasReceived(_ cuserId: String) {
        currentUid = cuserId
        loggedIn = true
        print("In delegate : \(cuserId)")
        cuid = cuserId
        downloadBasketFromFirestore(currentUid!){
            (basket) in

            if basket == nil{
                self.createNewBasket()
            }

            else{
                basket!.itemIds.append(self.item.id)
                self.updateBasket(basket!, withValues: [kITEMIDS:basket!.itemIds])
            }
        }
    }
    
    //MARK : Download Images
    
    private func downloadPictures()
    {
        if(item != nil && item.imagesLinks != nil){
            
            downloadImages(imageUrls: item.imagesLinks){ (allImages) in
                
                if allImages.count>0{
                    self.itemImages = allImages as! [UIImage]
                    self.imageCollectionView.reloadData()
                }
                
                
                
            }
        }
    }
    
    
    
    
//    func setCurrentUID(_ currUid: String?) {
//          //override the label with the parameter received in this method
//            currentUid = currUid
//            print("setCurrentUID function called !!")
//            print(currUid)
//        }
    
    
    //MARK : Setup UI
    
    private func setupUI(){
        
        if item != nil{
//            if item.name != nil{
//            print("You selected item : " + item.name)
//            }
//            else{
//                print("Item name is nil for the selected")
//            }
            self.title = item.name
            nameLabel.text = item.name
            priceLabel.text = convertToCurrency(item.price)
            descriptionTextView.text = item.description
        }
        
    }
    
    //MARK : IBActions
    
    @objc func backAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func addToBasketButtonPressed(){
        
        
        //TODO : check if user is logged in or show login view
//        if(loggedIn == nil){
//            print("Current user ID when pressed addToBasket is nil")
//        }
//        else{
//        print("Current user ID when pressed addToBasket is "+currentUid!)
//        }
        
        if(cuid == nil){
          showLoginView()
        }
        
        else{
            downloadBasketFromFirestore(cuid!){
                (basket) in

                if basket == nil{
                    self.createNewBasket()
                }

                else{
                    basket!.itemIds.append(self.item.id)
                    self.updateBasket(basket!, withValues: [kITEMIDS:basket!.itemIds])
                }
            }

        }
        
        
        
        
//        if currentUid == nil{
//            print(" currentUid variable has value nil")
//        }
//        if currentUid != nil{
//
//            print(" currentUid variable has value \(currentUid)")
//
//
//
//        }
        
        
    }
    
    //MARK : Add to basket
    
    private func createNewBasket(){
        
        let newBasket = Basket()
        newBasket.id = UUID().uuidString
        newBasket.ownerId = currentUid!
        newBasket.itemIds = [self.item.id]
        
        saveBasketToFirestore(newBasket)
        
        self.hud.textLabel.text = "Added to basket!"
        self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        self.hud.show(in:self.view)
        self.hud.dismiss(afterDelay: 2.0 )
        
    }
    
    private func updateBasket(_ basket:Basket,withValues:[String:Any]){
        
        updateBasketInFirestore(basket, withValues: withValues){
            (error) in
            
            if error != nil{
                self.hud.textLabel.text = "Error:\(error!.localizedDescription)"
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in:self.view)
                self.hud.dismiss(afterDelay: 2.0 )
                print("Error updating basket", error!.localizedDescription)
            }
            
            
            else
            {
                self.hud.textLabel.text = "Added to basket!"
                self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                self.hud.show(in:self.view)
                self.hud.dismiss(afterDelay: 2.0 )
            }
            
        }
    }
    
    
    
}


extension ItemViewController:UICollectionViewDataSource,UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemImages.count == 0 ? 1:itemImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageCollectionViewCell
        
        if itemImages.count>0{
            cell.setupImageWith(itemImage: itemImages[indexPath.row])
            
        }
        
        
        return cell
    }
    
    
    // MARK : Show Login View
    
    private func showLoginView(){
        
        let loginView = storyboard?.instantiateViewController(withIdentifier: "loginView") as? WelcomeViewController
        
        loginView!.delegate = self
        
        self.present(loginView!,animated: true,completion: nil)
//        if cuid == nil{
//            print(" cuid variable has the value nil")
//        }
//        if cuid != nil{
//            print(cuid!)
//        }
    }
    
    
}

extension ItemViewController:UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //let noOfCellsInRow = 1

        let availableWidth = collectionView.frame.width -  sectionInsets.left
        
            return CGSize(width: availableWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    
    
}
 
protocol WelcomeViewDelegate: class {
    func userIdWasReceived(_ cuserId: String)
}
