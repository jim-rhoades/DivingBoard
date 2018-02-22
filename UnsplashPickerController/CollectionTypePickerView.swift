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
    private let normalColor = UIView().tintColor! // default iOS blue color
    private let selectedColor = UIColor.black
    
    @IBOutlet weak var latestButton: UIButton!
    @IBOutlet weak var popularButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    
    private var currentCollectionType: CollectionType = .latest {
        // when the currentCollectionType changes, update the button colors
        didSet {
            updateButtonColors()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionView = UIView(frame: CGRect.zero)
        addSubview(selectionView)
        selectionView.layer.cornerRadius = 1.0
        selectionView.backgroundColor = selectedColor
        updateButtonColors()
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
    
    private func updateButtonColors() {
        switch currentCollectionType {
        case .latest:
            latestButton.setTitleColor(selectedColor, for: .normal)
            popularButton.setTitleColor(normalColor, for: .normal)
            searchButton.setTitleColor(normalColor, for: .normal)
        case .popular:
            latestButton.setTitleColor(normalColor, for: .normal)
            popularButton.setTitleColor(selectedColor, for: .normal)
            searchButton.setTitleColor(normalColor, for: .normal)
        case .search:
            latestButton.setTitleColor(normalColor, for: .normal)
            popularButton.setTitleColor(normalColor, for: .normal)
            searchButton.setTitleColor(selectedColor, for: .normal)
        }
    }
    
    private func setSelectedCollectionType(_ collectionType: CollectionType, animated: Bool) {
        currentCollectionType = collectionType
        
        if animated {
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
