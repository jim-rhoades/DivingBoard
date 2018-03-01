//
//  CollectionTypePickerView.swift
//  UnsplashPickerController
//
//  Created by Jim Rhoades on 2/16/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import UIKit

enum CollectionType: Int {
    case new = 0
    case curated
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
    
    @IBOutlet weak var newButton: UIButton!
    @IBOutlet weak var curatedButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    
    private var currentCollectionType: CollectionType = .new {
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
    
    @IBAction func newButtonPressed(_ sender: Any) {
        guard !transitionInProgress && currentCollectionType != .new else { return }
        setSelectedCollectionType(.new, animated: true)
        delegate?.collectionTypeChanged(.new)
    }
    
    @IBAction func curatedButtonPressed(_ sender: Any) {
        guard !transitionInProgress && currentCollectionType != .curated else { return }
        setSelectedCollectionType(.curated, animated: true)
        delegate?.collectionTypeChanged(.curated)
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        guard !transitionInProgress && currentCollectionType != .search else { return }
        setSelectedCollectionType(.search, animated: true)
        delegate?.collectionTypeChanged(.search)
    }
    
    private func updateButtonColors() {
        switch currentCollectionType {
        case .new:
            newButton.setTitleColor(selectedColor, for: .normal)
            curatedButton.setTitleColor(normalColor, for: .normal)
            searchButton.setTitleColor(normalColor, for: .normal)
        case .curated:
            newButton.setTitleColor(normalColor, for: .normal)
            curatedButton.setTitleColor(selectedColor, for: .normal)
            searchButton.setTitleColor(normalColor, for: .normal)
        case .search:
            newButton.setTitleColor(normalColor, for: .normal)
            curatedButton.setTitleColor(normalColor, for: .normal)
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
        let originY = newButton.frame.size.height
        var width: CGFloat = 0
        let height: CGFloat = 2.0
        let overlap: CGFloat = 6.0
        
        switch collectionType {
        case .new:
            originX = newButton.frame.origin.x - overlap
            width = newButton.frame.size.width + overlap * 2
        case .curated:
            originX = curatedButton.frame.origin.x - overlap
            width = curatedButton.frame.size.width + overlap * 2
        case .search:
            originX = searchButton.frame.origin.x - overlap
            width = searchButton.frame.size.width + overlap * 2
        }
        
        return CGRect(x: originX, y: originY, width: width, height: height)
    }
}
