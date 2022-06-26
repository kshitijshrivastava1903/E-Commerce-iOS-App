//
//  WelcomeViewController.swift
//  Market
//
//  Created by Love Shrivastava on 6/24/22.
//

import UIKit
import JGProgressHUD
import NVActivityIndicatorView

class WelcomeViewController: UIViewController {
    
    // MARK : IBOutlets
    
    
    @IBOutlet weak var emailTextField: UITextField!
    
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK : Vars
    
    let hud = JGProgressHUD(style:.dark)
    var activityIndicator: NVActivityIndicatorView?
    var currentUsid : String?
    
    weak var delegate: WelcomeViewDelegate?
    weak var delegate2: WelcomeViewDelegate2?
    // MARK : IBActions
    
 
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismissView()
        
        
    }
    
    

    @IBAction func loginButtonPressed(_ sender: Any) {
        
        if textFieldsHaveText(){
            loginUser()
        }
        
        else{
            
            hud.textLabel.text = "All fields are required"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in:self.view)
            hud.dismiss(afterDelay: 2.0)
            
        }
        
    }
    
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        
        if textFieldsHaveText(){
            
            registerUser()
            
        }
        
        else{
            hud.textLabel.text = "All fields are required"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in:self.view)
            hud.dismiss(afterDelay: 2.0)
        }
        
    }
    
    private func getUid() -> String?{
        return currentUsid
    }
    
    // MARK: Login User
    private func loginUser()->String?{
        
        showLoadingIndicator()
        MUser.loginUserWith(email: emailTextField.text as! String, password: passwordTextField.text as! String) { (error, isEmailVerified,currentUid) in
            if error == nil{
                
                if isEmailVerified{
                    //self.dismissView()
                    print("Email got verified")
                    
                    self.currentUsid = currentUid!
                    cuid = currentUid!
                    //print(self.currentUsid!)
                    self.delegate?.userIdWasReceived(self.currentUsid!)
                    self.delegate2?.userIdWasReceived(self.currentUsid!)
                    //print("Global cuid got val : \(cuid)")
                    self.dismissView()
                    
//                    downloadBasketFromFirestore(currentUid!){
//                        (basket) in
//
//                        if basket == nil{
//                            self.createNewBasket()
//                        }
//
//                        else{
//                            basket!.itemIds.append(self.item.id)
//                            self.updateBasket(basket!, withValues: [kITEMIDS:basket!.itemIds])
//                        }
//                    }
                    
                    
                    
                }
                
                else{
                    
                    //print("Please verify your email", error!.localizedDescription)
                    self.hud.textLabel.text = "Please verify your email"
                    self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                    self.hud.show(in:self.view)
                    self.hud.dismiss(afterDelay: 2.0)
                     
                }
                
            }
            
            else{
                print("Error logging in the user", error!.localizedDescription)
                self.hud.textLabel.text = error!.localizedDescription
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in:self.view)
                self.hud.dismiss(afterDelay: 2.0)
            }
            
            self.hideLoadingIndicator()
            
        }
        
        return self.currentUsid
    }
    
    // MARK : Register User
    private func registerUser(){
        
        
        showLoadingIndicator()
        
        MUser.registerUserWith(email: emailTextField!.text as! String, password: passwordTextField!.text as! String) { (error) in
            
            if error == nil{
                self.hud.textLabel.text = "Verification email sent!"
                self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                self.hud.show(in:self.view)
                self.hud.dismiss(afterDelay: 2.0)
            }
            
            else{
                print("error registering", error!.localizedDescription)
                self.hud.textLabel.text = error!.localizedDescription
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in:self.view)
                self.hud.dismiss(afterDelay: 2.0)
            }
            
            self.hideLoadingIndicator()
        }
        
         
    }
    
//    private func createNewBasket(){
//
//        let newBasket = Basket()
//        newBasket.id = UUID().uuidString
//        newBasket.ownerId = "12349"
//        newBasket.itemIds = [self.item.id]
//
//        saveBasketToFirestore(newBasket)
//
//        self.hud.textLabel.text = "Added to basket!"
//        self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
//        self.hud.show(in:self.view)
//        self.hud.dismiss(afterDelay: 2.0 )
//
//    }
    
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
    
    
     //MARK : Helpers
    
    private func dismissView(){
        self.dismiss(animated: true,completion: nil)
    }
    
    private func textFieldsHaveText()->Bool{
        
        return (emailTextField.text != "" && passwordTextField.text != "")
        
    }
    
    // MARK : Activity Indicator
    
    private func showLoadingIndicator(){
        if activityIndicator != nil{
            self.view.addSubview(activityIndicator!)
            activityIndicator!.startAnimating()
            
        }
        
    }
    
    private func hideLoadingIndicator(){
        
        if activityIndicator != nil{
            activityIndicator!.removeFromSuperview()
            activityIndicator!.stopAnimating()
        }
        
    }
    // MARK : View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x:self.view.frame.width / 2 - 30,y: self.view.frame.height / 2 - 30, width:60.0, height:60.0), type: .ballPulse, color: #colorLiteral
        (red:0.99984699949,green:0.4941213727, blue:0.4734867811,alpha:1.0), padding: nil)
    }
    


}
