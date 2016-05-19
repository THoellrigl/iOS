//
//  FoodTrackerTests.swift
//  FoodTrackerTests
//
//  Created by Dr. Thorsten Hoellrigl on 06/05/16.
//  Copyright © 2016 Dr. Thorsten Hoellrigl. All rights reserved.
//

import UIKit
import XCTest
@testable import FoodTracker

class FoodTrackerTests: XCTestCase {
    
   //MARK: FoodTracker Tests
    
    //tests to confirm that the meal initializer works when no name or a negative rating is provided
    
    func testMealInitialization () {
        
        //success
        let successMeal = Meal(name: "Spaghetti", photo: nil, rating: 5)
        XCTAssertNotNil(successMeal)
        
        //failure case
        let noName = Meal(name: "", photo: nil, rating: 0)
        XCTAssertNil(noName, "Empty name is invalid!")
        
        let badRating = Meal(name: "Meal with really bad rating", photo: nil, rating: -1)
        XCTAssertNil(badRating, "negative rating is not allowed. Be positive!")
    }
    
}
