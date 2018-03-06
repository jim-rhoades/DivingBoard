//
//  ViewController.swift
//  PhotoViewer
//
//  Created by Jim Rhoades on 2/16/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import UIKit
import DivingBoard
import SafariServices

class ViewController: UIViewController {
    
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    var photoTapGesture: UITapGestureRecognizer?
    var userTapGesture: UITapGestureRecognizer?
    var currentPhoto: UnsplashPhoto?
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userImageView.layer.cornerRadius = userImageView.bounds.size.height / 2.0
        userImageView.clipsToBounds = true
        userImageView.isUserInteractionEnabled = true
        photoView.isUserInteractionEnabled = true
    }
    
    // MARK: - Interaction
    
    @IBAction func cameraRollButtonPressed(_ button: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.modalPresentationStyle = .popover
        
        let presentationController = imagePicker.popoverPresentationController
        presentationController?.barButtonItem = button
        presentationController?.permittedArrowDirections = .any
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func fullScreenButtonPressed(_ button: UIBarButtonItem) {
        // let unsplashAppID = "INSERT_YOUR_APPLICATION_ID_HERE"
        let unsplashPicker = DivingBoard.unsplashPicker(withClientID: unsplashAppID,
                                                                     presentingViewController: self,
                                                                     modalPresentationStyle: .overFullScreen)
        
        // .overFullScreen is used instead of .fullScreen
        // so that the status bar is properly hidden in landscape on certain devices
        
        present(unsplashPicker, animated: true, completion: nil)
    }
    
    @IBAction func popoverButtonPressed(_ button: UIBarButtonItem) {
        // let unsplashAppID = "INSERT_YOUR_APPLICATION_ID_HERE"
        let unsplashPicker = DivingBoard.unsplashPicker(withClientID: unsplashAppID,
                                                        presentingViewController: self,
                                                        modalPresentationStyle: .popover)
        
        let presentationController = unsplashPicker.popoverPresentationController
        presentationController?.barButtonItem = button
        presentationController?.permittedArrowDirections = .any
        
        present(unsplashPicker, animated: true, completion: nil)
    }
    
    func resetInterface() {
        photoView.image = nil
        userImageView.image = nil
        userLabel.text = nil
        currentPhoto = nil
        if let userTapGesture = userTapGesture {
            userImageView.removeGestureRecognizer(userTapGesture)
        }
        userTapGesture = nil
        if let photoTapGesture = photoTapGesture {
            photoView.removeGestureRecognizer(photoTapGesture)
        }
        photoTapGesture = nil
    }
    
    @objc func handleTapPhoto(_ gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.state == .ended,
            let currentPhoto = currentPhoto else {
            return
        }
        
        let photoURL = currentPhoto.links.html
        let url = urlWithReferral(baseURL: photoURL) ?? photoURL
        let safariVC = SFSafariViewController(url: url)
        safariVC.modalPresentationStyle = .overFullScreen
        present(safariVC, animated: true, completion: nil)
    }
    
    @objc func handleTapUser(_ gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.state == .ended,
            let currentPhoto = currentPhoto else {
                return
        }
        
        let photographerURL = currentPhoto.user.links.html
        let url = urlWithReferral(baseURL: photographerURL) ?? photographerURL
        let safariVC = SFSafariViewController(url: url)
        safariVC.modalPresentationStyle = .overFullScreen
        present(safariVC, animated: true, completion: nil)
    }
    
    func urlWithReferral(baseURL: URL) -> URL? {
        // add proper attribution to the URL as described in Unsplash guidelines
        // by adding 'utm_source=your_app_name&utm_medium=referral'
        // https://medium.com/unsplash/unsplash-api-guidelines-attribution-4d433941d777
        
        guard var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            return nil
        }
        
        // FIXME: replace with your app name
        let appName = "Diving Board"
        
        let sourceItem = URLQueryItem(name: "utm_source", value: appName)
        let mediumItem = URLQueryItem(name: "utm_medium", value: "referral")
        urlComponents.queryItems = [sourceItem, mediumItem]
        return urlComponents.url
    }
}

// MARK: - UnsplashPickerDelegate

extension ViewController: UnsplashPickerDelegate {
    
    func unsplashPickerDidFinishPicking(photo: UnsplashPhoto) {
        
        // reset
        resetInterface()
        
        // assign currentPhoto, will be used to retrieve URLs when tapping photo/avatar
        currentPhoto = photo
        
        // show a loading indicator
        let loadingView = LoadingView()
        photoView.addCenteredSubview(view: loadingView)
        
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
        
        // make the photo tappable
        photoTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapPhoto(_:)))
        photoView.addGestureRecognizer(photoTapGesture!)
        
        // show the user name
        userLabel.text = photo.user.name
        
        // load the user avatar
        let userImageURL = photo.user.profileImage.large
        userImageView.loadImageAsync(with: userImageURL, completion: nil)
        
        // make the avatar tappable
        userTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapUser(_:)))
        userImageView.addGestureRecognizer(userTapGesture!)
        
        // related color
        // photoView.backgroundColor = UIColor(hexString: photo.color)
        
        // dates
        // print("photo created on: \(photo.createdAt)")
        // print("photo updated on: \(photo.updatedAt)")
        
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
        
        resetInterface()
        photoView.image = image
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
