//
//  ViewController.swift
//  PhotoViewer
//
//  Created by Jim Rhoades on 2/16/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import UIKit
import UnsplashPickerController

class ViewController: UIViewController {
    
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var userView: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func imagePickerButtonPressed(_ button: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.modalPresentationStyle = .popover
        
        let presentationController = imagePicker.popoverPresentationController
        presentationController?.barButtonItem = button
        presentationController?.permittedArrowDirections = .any
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func unsplashPickerButtonPressed(_ button: UIBarButtonItem) {
        let unsplashPicker = UnsplashPickerController.viewControllerToPresent(from: self)
        
        let presentationController = unsplashPicker.popoverPresentationController
        presentationController?.barButtonItem = button
        presentationController?.permittedArrowDirections = .any
        
        present(unsplashPicker, animated: true, completion: nil)
    }
}

// MARK: - UnsplashPickerControllerDelegate

extension ViewController: UnsplashPickerControllerDelegate {
    func unsplashPickerController(didFinishPickingPhoto: UIImage) {
        
        // TODO: display the photo
        
        userView.isHidden = false
        userLabel.isHidden = false
        
        dismiss(animated: true, completion: nil)
    }
    
    func unsplashPickerControllerDidCancel() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIImagePickerControllerDelegate

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        
        photoView.image = image
        
        userView.isHidden = true
        userLabel.isHidden = true
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
