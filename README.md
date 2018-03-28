# DivingBoard
An iOS framework that provides an interface for browsing and searching for photos from Unsplash.com.

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

![DivingBoard](http://crushapps.com/divingboard/img/divingboard.jpg)

## Trying out DivingBoard

This repository includes an example app named "PhotoViewer" that uses the DivingBoard framework:
![PhotoViewer](http://crushapps.com/divingboard/img/photoviewer@0.65x.jpg)

In order to run it, you'll first need to sign up for an [Unsplash app ID](https://unsplash.com/developers).

Once you have an Unsplash app ID, open the file `ExampleApp/PhotoViewer/ViewController.swift` and insert it in the two places this appears:\
`// let unsplashAppID = "INSERT_YOUR_APPLICATION_ID_HERE"`

Then you'll be able to run PhotoViewer to see how DivingBoard works.

If you plan on contributing to DivingBoard, see "[Contributing to DivingBoard](#contributing-to-divingboard)" below for a better way to do this that will keep your Unsplash app ID out of commits.

## Setting up your Xcode project to use DivingBoard
1. [Install Carthage](https://github.com/Carthage/Carthage#installing-carthage) if you don't already have it.
2. In the base directory of your project, create a file named "Cartfile" containing `github "jim-rhoades/DivingBoard"`
3. Run `carthage update` in the terminal (in the same directory that you created the Cartfile). This will compile the framework and place it inside of your project folder at `Carthage/Build/iOS/DivingBoard.framework`.
4. Open your project in Xcode, view your application target's "General" settings tab and scroll down to the "Embedded Binaries" section. Drag and drop the `DivingBoard.framework` file onto the "Embedded Binaries" section, and click "Finish" when prompted to.

![DivingBoard Xcode setup 1](http://crushapps.com/divingboard/img/setup1.png)

5. On your application target's "Build Phases" tab, click the "+" button to add a new build phase and choose "New Run Script Phase".
6. Add the following to the script area below the shell:
`/usr/local/bin/carthage copy-frameworks`
7. Under "Input Files" add:
`$(SRCROOT)/Carthage/Build/iOS/DivingBoard.framework`
8. Under "Output Files" add:
`$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/DivingBoard.framework`

![DivingBoard Xcode setup 2](http://crushapps.com/divingboard/img/setup2.png)

## Launching DivingBoard in your app
To launch DivingBoard in your own app you'll need to get an instance of `UnsplashPickerViewController` and present it. The following code shows how you would do that to present it full screen:
```swift
let unsplashAppID = "INSERT_YOUR_APPLICATION_ID_HERE"
let unsplashPicker = DivingBoard.unsplashPicker(withClientID: unsplashAppID,
                                                              presentingViewController: self,
                                                              modalPresentationStyle: .fullScreen)

present(unsplashPicker, animated: true, completion: nil)
```
In PhotoViewer's `ViewController.swift` you'll also find an example for presenting it as a popover where appropriate.

## Conforming to UnsplashPickerDelegate
The view controller that you're presenting DivingBoard from also needs to conform to the `UnsplashPickerDelegate` protocol, which consists of two methods:
```swift
func unsplashPickerDidCancel()
func unsplashPickerDidFinishPicking(photo: UnsplashPhoto)
```
See PhotoViewer's `ViewController.swift` file for examples.

## Adhering to the Unsplash API guidelines
It is up to you to "play nicely" and adhere to the [Unsplash API Guidelines](https://medium.com/unsplash/unsplash-api-guidelines-28e0216e6daa). DivingBoard includes a couple of methods that make this easy:

* Call `DivingBoard.incrementUnsplashPhotoDownloadCount` if you do something like save a photo to the camera roll. This method will call the Unsplash API's `download_location` endpoint to increment the download count for the photo on Unsplash.com. I highly recommend reading [Unsplash API Guidelines: Triggering a Download](https://medium.com/unsplash/unsplash-api-guidelines-triggering-a-download-c39b24e99e02) for recommendations on when to do this. (PhotoViewer uses this when saving a photo to the camera roll.)

* When linking to a photo or user on Unsplash.com, call `DivingBoard.unsplashWebsiteURLWithReferral` to get a URL with the proper attribution as described in [Unsplash API Guidelines: Attribution](https://medium.com/unsplash/unsplash-api-guidelines-attribution-4d433941d777).  (PhotoViewer uses this when tapping on a photo or user avatar to view the photo/user on the Unsplash website.)

## Helpful utilities
DivingBoard includes an extension on UIImageView to add the method `loadImageAsync`, which will load an image asynchronously and cache it to memory/disk.

Also included is the class `LoadingView`, which is a nice looking loading indicator.

You may want use either or both of these in your own app's implementation of `unsplashPickerDidFinishPicking`, for example:

```swift
func unsplashPickerDidFinishPicking(photo: UnsplashPhoto) {
    // show a loading indicator
    let loadingView = LoadingView()
    photoView.addCenteredSubview(loadingView)
        
    // load the photo
    let photoURL = photo.urls.full
    photoView.loadImageAsync(with: photoURL) { success in
        // remove the loading indicator
        loadingView.removeFromSuperview()
    }

    dismiss(animated: true, completion: nil)
}
```

## Contributing to DivingBoard
If you want to contribute to DivingBoard, I recommend that you create a file named "ClientID.swift" in the PhotoViewer Xcode project with the following content (replacing "YOUR_UNSPLASH_APP_ID" with your actual Unsplash app ID):
```swift
import Foundation

// Note that this file is in .gitignore and will NOT be added to the repository.
// (to prevent the app ID from leaking onto GitHub!)
let unsplashAppID = "YOUR_UNSPLASH_APP_ID"
```

Since "ClientID.swift" is included in .gitignore, that will enable you to run and test changes to DivingBoard and PhotoViewer without risk of accidentally including your Unsplash app ID in a commit.

## ToDo
- [ ] change from a square grid layout to a waterfall layout that shows uncropped photos instead of square crops:
![DivingBoard](http://crushapps.com/divingboard/img/divingboard_waterfall@0.65x.jpg)
- [ ] improve the unit tests - in particular, there should be tests for UnsplashClient's `requestPhotosFor` method using a stub / fake data (the project includes files containing real JSON data from the Unsplash API… `test_data_photos.json` and `test_data_search.json`, but they aren't currently being used)
- [ ] add support for CocoaPods?
- [ ] add support for Swift Package Manager?
