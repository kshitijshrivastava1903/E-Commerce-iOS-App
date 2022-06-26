//
//  FirebaseCollectionReference.swift
//  Market
//
//  Created by Love Shrivastava on 6/15/22.
//

import Foundation
import FirebaseFirestore
import UIKit

enum FCollectionReference:String {
    case User
    case Category
    case Items
    case Basket
}


func FirebaseReference(_ collectionReference:FCollectionReference)->

CollectionReference{
    
    return Firestore.firestore().collection(collectionReference.rawValue)
    
}
