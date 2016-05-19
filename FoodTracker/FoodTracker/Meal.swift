//
//  Meal.swift
//  FoodTracker
//
//  Created by Dr. Thorsten Hoellrigl on 17/05/16.
//  Copyright © 2016 Dr. Thorsten Hoellrigl. All rights reserved.
//

import UIKit

class Meal {
    
    // MARK: Properties
    
    var name: String
    var photo: UIImage?
    var rating: Int
    
    init?(name: String, photo: UIImage?, rating: Int) {
        
        //Initialize stored properties of the meal class
        self.name = name
        self.photo = photo
        self.rating = rating
        
        //Initialization should fail if there is no name or a negative rating
        
        if name.isEmpty || rating < 0 {
            
            return nil
        }
    }
}
