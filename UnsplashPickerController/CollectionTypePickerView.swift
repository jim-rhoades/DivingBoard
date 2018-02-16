//
//  CollectionTypePickerView.swift
//  UnsplashPickerController
//
//  Created by Jim Rhoades on 2/16/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import UIKit

enum CollectionType {
    case latest
    case popular
    case search
}

protocol CollectionTypePickerViewDelegate: class {
    func showLatest()
    func showPopular()
    func showSearch()
}

class CollectionTypePickerView: UIView {
    weak var delegate: CollectionTypePickerViewDelegate?
    private var selectionView: UIView!
    
    @IBOutlet weak var latestButton: UIButton!
    @IBOutlet weak var popularButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // set up the selectionView, defaulting to "Latest"
        selectionView = UIView(frame: frameForSelectionView(for: .latest))
        selectionView.layer.cornerRadius = 1.0
        selectionView.backgroundColor = .blue // TODO: pick a better color
    }
    
    @IBAction func latestButtonPressed(_ sender: Any) {
        print("show latest")
        
        UIView.animate(withDuration: 0.5) {
            self.selectionView.frame = self.frameForSelectionView(for: .latest)
        }
    }
    
    @IBAction func popularButtonPressed(_ sender: Any) {
        print("show popular")
        
        UIView.animate(withDuration: 0.5) {
            self.selectionView.frame = self.frameForSelectionView(for: .popular)
        }
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        print("show search")
        
        UIView.animate(withDuration: 0.5) {
            self.selectionView.frame = self.frameForSelectionView(for: .search)
        }
    }
    
    private func frameForSelectionView(for collectionType: CollectionType) -> CGRect {
        var originX: CGFloat = 0
        let originY = latestButton.frame.size.height
        var width: CGFloat = 0
        let height: CGFloat = 2.0
        let overlap: CGFloat = 6.0
        
        switch collectionType {
        case .latest:
            originX = latestButton.frame.origin.x - overlap
            width = latestButton.frame.size.width + overlap * 2
        case .popular:
            originX = popularButton.frame.origin.x - overlap
            width = popularButton.frame.size.width + overlap * 2
        case .search:
            originX = searchButton.frame.origin.x - overlap
            width = searchButton.frame.size.width + overlap * 2
        }
        
        return CGRect(x: originX, y: originY, width: width, height: height)
    }
}
