//
//  SegueHandlerType.swift
//  DivingBoard
//
//  Created by Jim Rhoades on 2/16/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import UIKit

// enable the use of enums for segue identifiers
// via WWDC 2015 session 411 "Swift In Practice"

protocol SegueHandlerType {
    associatedtype SegueIdentifier: RawRepresentable
}

extension SegueHandlerType where Self: UIViewController, SegueIdentifier.RawValue == String {
    
    func performSegue(withIdentifier segueIdentifier: SegueIdentifier, sender: AnyObject?) {
        performSegue(withIdentifier: segueIdentifier.rawValue, sender: sender)
    }
    
    func segueIdentifierForSegue(_ segue: UIStoryboardSegue) -> SegueIdentifier {
        guard let identifier = segue.identifier,
            let segueIdentifier = SegueIdentifier(rawValue: identifier)
            else {
                fatalError("SegueHandleType | invalid segue identifier")
        }
        
        return segueIdentifier
    }
}
