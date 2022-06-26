//
//  CategoryCollectionViewController.swift
//  Market
//
//  Created by Love Shrivastava on 6/14/22.
//

import UIKit


class CategoryCollectionViewController: UICollectionViewController {

    //MARK : Vars
    var categoryArray:[Category] = []
    
    
    private let sectionInsets = UIEdgeInsets(top:20.0,left: 10.0,bottom: 20.0,right:10.0)
    private let itemsPerRow : CGFloat = 3
    //MARK : View Lifecyle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadCategories()
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
        return categoryArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CategoryCollectionViewCell
        
        cell.generateCell(categoryArray[indexPath.row])
        return cell
    }
    
    //MARK : UICollectionViewDelegate
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "categoryToItemsSeg", sender: categoryArray[indexPath.row])
    }
    
    
    //MARK : Download categories
    
    private func loadCategories(){
        downloadCategoriesFromFirebase { (allCategories) in
            //print("we have", allCategories.count)
            self.categoryArray = allCategories
            self.collectionView.reloadData()
        }
    }
    
    //MARK : Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "categoryToItemsSeg"{
            
            let vc = segue.destination as! ItemsTableViewController
            
            vc.category = sender as! Category
        }
    }


}


extension CategoryCollectionViewController:UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let noOfCellsInRow = 3

            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout

            let totalSpace = flowLayout.sectionInset.left
                + flowLayout.sectionInset.right
                + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))

            let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))

            return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
}
