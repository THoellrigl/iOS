//
//  ViewController.swift
//  FoodTracker
//
//  Created by Dr. Thorsten Hoellrigl on 06/05/16.
//  Copyright © 2016 Dr. Thorsten Hoellrigl. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var mealNameLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Handle the textfield's user input through delegate callbacks
        //The viewcontroller class is a delegate of the textfield. We refer to itself, as the texfield is defined within the ViewController class
        //A delegate is an object that acts on behalf of or in coordination with another object
        //The textfield is the delegating object, which sends a message to the ViewController
        //The ViewController can then act to the event, for example, by updating the View
        
        nameTextField.delegate = self
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        // hide the keyboard
        
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        // Take the input from the textfield and set the label to the value of the textfield
        
        mealNameLabel.text = textField.text
    }
    
    //MARK: UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        // dissmiss the imagePickerController if the user clicks cancel
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        // the info dictionary contains multiple presentations of the image and this takes the original
        
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // set photoImageView with the selected image
        
        photoImageView.image = selectedImage
        
        // dismiss the picker
        
        dismissViewControllerAnimated(true, completion: nil)
    }

    
    //MARK: Actions
    @IBAction func selectImageFromPhotoLibrary(sender: UITapGestureRecognizer) {
        
        // Hide the keyboard
        nameTextField.resignFirstResponder()
        
        //UIImagePickerController is a controller that allows the user to pick an image from a certain library
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.sourceType = .PhotoLibrary
        
        // the ViewController is the delegate of the imagePicker. We add that the ViewController is notified once the user picks an image via the imagePickerController
        
        imagePickerController.delegate = self
        
        presentViewController(imagePickerController, animated: true, completion: nil)
        
        
    }
}

