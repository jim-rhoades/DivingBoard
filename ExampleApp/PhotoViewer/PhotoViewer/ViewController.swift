//
//  ViewController.swift
//  PhotoViewer
//
//  Created by Jim Rhoades on 2/16/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import UIKit
import DivingBoard

class ViewController: UIViewController {
    
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var userContainerView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userImageView.layer.cornerRadius = userImageView.bounds.size.height / 2.0
        userImageView.clipsToBounds = true
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
        // let unsplashAppID = "INSERT_YOUR_APPLICATION_ID_HERE"
        let unsplashPicker = DivingBoard.unsplashPicker(withClientID: unsplashAppID,
                                                                     presentingViewController: self)
        unsplashPicker.modalPresentationStyle = .popover
        
        let presentationController = unsplashPicker.popoverPresentationController
        presentationController?.barButtonItem = button
        presentationController?.permittedArrowDirections = .any
        
        present(unsplashPicker, animated: true, completion: nil)
    }
    
    func resetInterface() {
        photoView.image = nil
        userImageView.image = nil
        userLabel.text = nil
        userContainerView.isHidden = false
    }
}

// MARK: - UnsplashPickerDelegate

extension ViewController: UnsplashPickerDelegate {
    
    func unsplashPickerDidFinishPicking(photo: UnsplashPhoto) {
        
        // reset
        resetInterface()
        
        // show a loading indicator
        let loadingView = LoadingView()
        photoView.addCenteredSubview(view: loadingView)
        
        // do something with the photo's related color
        // photoView.backgroundColor = UIColor(hexString: photo.color)
        
        // load the photo
        let photoURL = photo.urls.full
        photoView.loadImageAsync(with: photoURL) { success in
            
            // remove the loading indicator
            UIView.animate(withDuration: 0.15, animations: {
                loadingView.alpha = 0.0
            }, completion: { completed in
                loadingView.removeFromSuperview()
            })
        }
        
        // load the user avatar and name
        let userImageURL = photo.user.profileImage.large
        userImageView.loadImageAsync(with: userImageURL, completion: nil)
        userLabel.text = photo.user.name
        
        dismiss(animated: true, completion: nil)
    }
    
    func unsplashPickerDidCancel() {
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
        userContainerView.isHidden = true
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
