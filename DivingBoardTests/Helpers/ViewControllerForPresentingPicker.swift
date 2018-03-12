//
//  ViewControllerForPresentingPicker.swift
//  DivingBoardTests
//
//  Created by Jim Rhoades on 3/9/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import UIKit
import DivingBoard

// A subclass of UIViewController that conforms to UnsplashPickerDelegate
// is needed so we can test that the UnsplashPickerDelegate gets set
// when calling DivingBoard.unsplashPicker()
class ViewControllerForPresentingPicker: UIViewController, UnsplashPickerDelegate {
    func unsplashPickerDidCancel() {
        // do something
    }
    
    func unsplashPickerDidFinishPicking(photo: UnsplashPhoto) {
        // do something
    }
}
