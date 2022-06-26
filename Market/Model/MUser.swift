//
//  MUser.swift
//  Market
//
//  Created by Love Shrivastava on 6/24/22.
//

import Foundation
import FirebaseAuth

class MUser{
    
    let objectId : String
    var email : String
    var firstName : String
    var lastName : String
    var fullName : String
    var purchasedItemsIds : [String]
    
    var fullAddress : String?
    var onBoard : Bool
    
    //MARK : Initializers
    
    init(_objectId:String,_email: String,_firstName: String,_lastName: String){
        objectId = _objectId
        email = _email
        firstName = _firstName
        lastName = _lastName
        fullName = _firstName + " " + _lastName
        onBoard = false
        purchasedItemsIds = []
    }
        
    init(_dictionary: NSDictionary){
        
        objectId = _dictionary[kOBJECTID] as! String
        
        if let mail = _dictionary[kEMAIL]{
            email = mail as! String
        }
        
        else {
            email = ""
        }
        
        if let fname = _dictionary[kFIRSTNAME]{
            firstName = fname as! String
        }
        
        else {
            firstName = ""
        }
        
        if let lname = _dictionary[kLASTNAME]{
            lastName = lname as! String
        }
        
        else {
            lastName = ""
        }
        
        fullName = firstName + " " + lastName
        
        if let faddress = _dictionary[kFULLADDRESS]{
            fullAddress = faddress as! String
        }
        
        else {
            fullAddress = ""
        }
        
        
        if let onB = _dictionary[kONBOARD]{
            onBoard = onB as! Bool
        }
        
        else {
            onBoard = false
        }
        
        if let purchasedIds = _dictionary[kPURCHASEDITEMIDS]{
            purchasedItemsIds = purchasedIds as! [String]
        }
        
        else {
            purchasedItemsIds = []
        }
    }
    
    //MARK - Return current user
    
    class func currentId() -> String{
        return Auth.auth().currentUser!.uid
    }
    
    class func currentUser() -> MUser?{
        if Auth.auth().currentUser != nil {
            if let dictionary = UserDefaults.standard.object(forKey: kCURRENTUSER){
                return MUser.init(_dictionary: dictionary as! NSDictionary)
            }
        }
        
        return nil
    }
    
    // MARK - Login func
    
    class func loginUserWith(email:String,password:String, completion:@escaping(_ error: Error?, _ isEmailVerified:Bool,_ currentUserId:String?)->Void){
        
        Auth.auth().signIn(withEmail: email, password: password) { authDataResult, error in
            
            if error == nil{
                
                if authDataResult!.user.isEmailVerified{
                    
                    downloadUserFromFirestore(userId: authDataResult!.user.uid, email: email)
        
                    completion(error,true,authDataResult!.user.uid)
                }
                
                else{
                  print("Email not verified")
                  completion(error,false,"")
                }
                
            }
            
            else{
                completion(error,false,"")
            }
        }
    }
    
    // MARK : Register User
    
    class func registerUserWith(email:String,password:String,completion: @escaping ( _ error:Error?)->Void){
        
        Auth.auth().createUser(withEmail: email, password: password) { (authdataResult,error) in
            
            completion(error)
            
            if error == nil{
                // send email verification
                authdataResult!.user.sendEmailVerification { (error) in
                    print("auth email verification error : ",error?.localizedDescription)
                }
            }
            
        }
    }
}

// MARK : Download User
func downloadUserFromFirestore(userId:String,email:String){
    FirebaseReference(.User).document(userId).getDocument { (snapshot, error) in
        guard let snapshot = snapshot else{ return}
        
        if snapshot.exists{
            print("Download current user from firestore")
            //print("Current User's uid is : \(userId)")
            saveUserLocally(mUserDictionary: snapshot.data()! as NSDictionary)
        }
        
        else{
            // there is no user in firestore, save it
            
            let user = MUser(_objectId: userId, _email: email, _firstName: "", _lastName: "")
            
            saveUserLocally(mUserDictionary: userDictionaryFrom(user: user))
            saveUserToFirestore(mUser: user)
            
        }
    }
    
}

// MARK : Save User to firebase

func saveUserToFirestore(mUser:MUser){
    FirebaseReference(.User).document(mUser.objectId).setData(userDictionaryFrom(user: mUser) as! [String:Any]) { (error) in
        
        
        if error != nil{
            
            print("error saving user \(error!.localizedDescription)")
            
        }
    }
}

func saveUserLocally(mUserDictionary:NSDictionary){
    UserDefaults.standard.set(mUserDictionary, forKey: kCURRENTUSER)
    UserDefaults.standard.synchronize()
}

// MARK : Helper function

func userDictionaryFrom(user:MUser) -> NSDictionary{
    return NSDictionary(objects: [user.objectId,user.email,user.firstName,user.lastName,user.fullName,user.fullAddress ?? "",user.onBoard,user.purchasedItemsIds], forKeys: [kOBJECTID as NSCopying,kEMAIL as NSCopying,kFIRSTNAME as NSCopying,kLASTNAME as NSCopying,kFULLNAME as NSCopying,kFULLADDRESS as NSCopying,kONBOARD as NSCopying,kPURCHASEDITEMIDS as NSCopying])
    
}
