//
//  Constants.swift
//  Market
//
//  Created by Love Shrivastava on 6/15/22.
//

import Foundation

//IDS and Keys
public let kFILEREFERNCE = "gs://market-9a980.appspot.com"

//Firebase Headers
public let kUSER_PATH = "User"
public let kCATEGORY_PATH = "Category"
public let kITEMS_PATH = "Items"
public let kBASKET_PATH = "Basket"


//Category
public let kNAME = "name"
public let kIMAGENAME = "imageName"
public let kOBJECTID = "objectId"
 


//Item
public let kCATEGORYID = "categoryId"
public let kDESCRIPTION = "description"
public let kPRICE = "price"
public let kIMAGELINKS = "imageLinks"


//Basket
public let kOWNERID = "ownerId"
public let kITEMIDS = "itemIDs"


//User
public let kEMAIL = "email"
public let kFIRSTNAME = "firstName"
public let kLASTNAME = "lastName"
public let kFULLNAME = "fullName"
public let kCURRENTUSER = "currentUser"
public let kFULLADDRESS = "fullAddress"
public let kONBOARD = "onBoard"
public let kPURCHASEDITEMIDS = "purchasedItemIds"

public var cuid : String?

public var loggedIn : Bool?
