//
//  CollectionTypePickerView.swift
//  UnsplashPickerController
//
//  Created by Jim Rhoades on 2/16/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import UIKit

enum CollectionType: Int {
    case latest = 0
    case popular
    case search
}

protocol CollectionTypePickerViewDelegate: class {
    func collectionTypeChanged(_ collectionType: CollectionType)
}

class CollectionTypePickerView: UIView {
    weak var delegate: CollectionTypePickerViewDelegate?
    private var transitionInProgress = false
    private var selectionView: UIView!
    private var currentCollectionType: CollectionType = .latest
    @IBOutlet weak var latestButton: UIButton!
    @IBOutlet weak var popularButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        selectionView = UIView(frame: CGRect.zero)
        addSubview(selectionView)
        selectionView.layer.cornerRadius = 1.0
        selectionView.backgroundColor = UIColor.lightGray // TODO: pick a better color
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        selectionView.frame = frameForSelectionView(for: currentCollectionType)
    }
    
    @IBAction func latestButtonPressed(_ sender: Any) {
        guard !transitionInProgress && currentCollectionType != .latest else { return }
        setSelectedCollectionType(.latest, animated: true)
        delegate?.collectionTypeChanged(.latest)
    }
    
    @IBAction func popularButtonPressed(_ sender: Any) {
        guard !transitionInProgress && currentCollectionType != .popular else { return }
        setSelectedCollectionType(.popular, animated: true)
        delegate?.collectionTypeChanged(.popular)
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        guard !transitionInProgress && currentCollectionType != .search else { return }
        setSelectedCollectionType(.search, animated: true)
        delegate?.collectionTypeChanged(.search)
    }
    
    private func setSelectedCollectionType(_ collectionType: CollectionType, animated: Bool) {
        currentCollectionType = collectionType
        
        if animated {
            /*
            UIView.animate(withDuration: 0.25) {
                self.selectionView.frame = self.frameForSelectionView(for: collectionType)
            }
            */
            transitionInProgress = true
            
            UIView.animate(withDuration: 0.25, animations: {
                self.selectionView.frame = self.frameForSelectionView(for: collectionType)
            }) { completed in
                self.transitionInProgress = false
            }
        } else {
            selectionView.frame = frameForSelectionView(for: collectionType)
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
