//
//  MealViewController.swift
//  FoodTracker
//
//  Created by Dr. Thorsten Hoellrigl on 06/05/16.
//  Copyright © 2016 Dr. Thorsten Hoellrigl. All rights reserved.
//

import UIKit

class MealViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    /*
     This value is either passed by `MealTableViewController` in `prepareForSegue(_:sender:)`
     or constructed as part of adding a new meal.
     */
    var meal: Meal?
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Handle the textfield's user input through delegate callbacks
        //The viewcontroller class is a delegate of the textfield. We refer to itself, as the texfield is defined within the ViewController class
        //A delegate is an object that acts on behalf of or in coordination with another object
        //The textfield is the delegating object, which sends a message to the ViewController
        //The ViewController can then act to the event, for example, by updating the View
        
        nameTextField.delegate = self
        
        if let meal = meal {
            navigationItem.title = meal.name
            nameTextField.text = meal.name
            photoImageView.image = meal.photo
            ratingControl.rating = meal.rating
        }
        
        //Disable the save button while no name for the meal has been added
        checkValidName()
        

    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        // hide the keyboard
        
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        //disable the edit button while typing a name
        
        let text = textField.text ?? ""
        
        if text.isEmpty {
        
        saveButton.enabled = false
            
        }
        
    }
    
    func checkValidName() {
        
        //disable the save button if the textfield is empty
        let text = nameTextField.text ?? ""
        saveButton.enabled = !text.isEmpty
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        //check if the textfield is empty
        checkValidName()
        
        //set Sequelname to the name of the meal that should be added
        navigationItem.title = textField.text
        
        
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
    
    
    //MARK: Navigation
    
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        
        if isPresentingInAddMealMode {
            dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            navigationController!.popViewControllerAnimated(true)
        }
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

