//
//  AddItemViewController.swift
//  Market
//
//  Created by Love Shrivastava on 6/17/22.
//

import UIKit
import Gallery
import JGProgressHUD
import NVActivityIndicatorView
class AddItemViewController: UIViewController {
    
    
    //MARK : IBOutlets
    
    
    @IBOutlet weak var titleTextField: UITextField!
    
    
    @IBOutlet weak var priceTextField: UITextField!
    
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    //MARK : Vars
    
    var category:Category!
    var gallery:GalleryController!
    let hud = JGProgressHUD(style: .dark)
    var activityIndicator:NVActivityIndicatorView?
    
    var itemImages : [UIImage?] = []
    
    //MARK : View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print(category.name)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x:self.view.frame.width/2 - 30,y:self.view.frame.height/2 - 30,width:60,height:60), type: .ballPulse, color: #colorLiteral(red:0.9998469949,green:-0.4941213727,blue:0.473486711,alpha:1), padding: nil)
        
    }
    
    
    //MARK : IBActions
    
    
    @IBAction func doneBarButtonItemPressed(_ sender: Any) {
        
        dismissKeyboard()
        
        //print("You entered title " + titleTextField.text ??)
        if fieldsAreCompleted(){
            
            saveToFirebase()
            
        }
        
        else{
            print("Error all fileds are required")
            //TODO: Show error to user
            self.hud.textLabel.text = "All fields are required !"
            self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
            self.hud.show(in:self.view)
            self.hud.dismiss(afterDelay: 2.0)
        }
        
    }
    

    @IBAction func cameraButtonPressed(_ sender: Any) {
        itemImages = []
        showImageGallery()
    }
    
    
    @IBAction func backgroundTapped(_ sender: Any) {
        dismissKeyboard()
        
    }
    
    
    //Mark : Helper functions
    
    private func dismissKeyboard(){
        self.view.endEditing(false)
    }
    
    private func fieldsAreCompleted()->Bool{
        return titleTextField.text != ""&&descriptionTextView.text != ""&&priceTextField.text != "";
    }
    
    private func popTheView(){
        self.navigationController?.popViewController(animated: true)
    }
    
    
}


extension AddItemViewController:GalleryControllerDelegate{
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        
        
        if images.count>0{
            Image.resolve(images: images) { (resolvedImages) in
                          self.itemImages = resolvedImages
            }
            
        }
        
        
        
        
        controller.dismiss(animated: true, completion: nil)
        
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Save Item
    
    private func saveToFirebase(){
        
        showLoadingIndicator()
        
        let item = Item()
        item.id = UUID().uuidString
        item.name = titleTextField.text!
        item.categoryId = category.id
        item.description = descriptionTextView.text
        item.price = Double(priceTextField.text!)
        
        if itemImages.count>0
        {
            uploadImages(images: itemImages, itemId: item.id) {
                (imageLinkArray) in
                
                item.imagesLinks = imageLinkArray
                
                saveItemToFirestore(item)
                self.hideLoadingIndicator()
                self.popTheView()
                
            }
            
        }
        
        else
        {
            saveItemToFirestore(item)
            popTheView()
            
            
            
        }
        
        
    }
    
    //MARK: Activity Indicator
    
    private func showLoadingIndicator(){
        
        if(activityIndicator != nil)
        {
            self.view.addSubview(activityIndicator!)
            activityIndicator!.startAnimating()
        }
        
    }
    
    private func hideLoadingIndicator(){
        
        if(activityIndicator != nil)
        {
            activityIndicator!.removeFromSuperview()
            activityIndicator!.stopAnimating()
        }
        
    }
    
    
    //MARK: Show Gallery
    
    private func showImageGallery(){
        
        self.gallery = GalleryController()
        self.gallery.delegate = self
        
        Config.tabsToShow = [.imageTab,.cameraTab]
        
        Config.Camera.imageLimit = 6
        
        self.present(self.gallery,animated: true,completion: nil)
        
    }
    
    
}
