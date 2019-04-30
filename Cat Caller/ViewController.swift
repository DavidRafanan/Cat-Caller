//
//  ViewController.swift
//  Cat Caller
//
//  Created by David Rafanan on 4/24/19.
//  Copyright © 2019 David Rafanan. All rights reserved.
//

import UIKit
import Parse
class ViewController: UIViewController {

    var displayUserID = ""
    
    @IBOutlet weak var matchImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged(gestureRecognizer:)))
        
        matchImageView.addGestureRecognizer(gesture)
        
        //retrieving image
        updateImage()
        
        //getting location of user
        PFGeoPoint.geoPointForCurrentLocation { (geoPoint, error) in
            if let point = geoPoint {
                PFUser.current()?["location"] = point
                PFUser.current()?.saveInBackground()
            }
            
        }
    }
    
    @objc func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        let labelPoint = gestureRecognizer.translation(in: view)
        
        matchImageView.center = CGPoint(x: view.bounds.width / 2 + labelPoint.x, y: view.bounds.height / 2 + labelPoint.y)
        
        let xFromCenter = view.bounds.width / 2 - matchImageView.center.x
        
        var rotation = CGAffineTransform(rotationAngle: xFromCenter / 200)
        
        let scale = min(100 / abs(xFromCenter), 1)
        
        
        var scaledAndRotated = rotation.scaledBy(x: scale, y: scale)
        
        matchImageView.transform = scaledAndRotated
        
        if gestureRecognizer.state == .ended {
            
            var acceptedOrRejected = ""
            
            if matchImageView.center.x < (view.bounds.width / 2 - 100) {
                print("Ignore")
                acceptedOrRejected = "rejected"
            }
            if matchImageView.center.x > (view.bounds.width / 2 + 100) {
                print("Accept")
                acceptedOrRejected = "accepted"
            }
            
            if acceptedOrRejected != "" && displayUserID != "" {
                PFUser.current()?.addUniqueObject(displayUserID, forKey: acceptedOrRejected)
                PFUser.current()?.saveInBackground(block: { (success, error) in
                    if success {
                        self.updateImage()
                    }
                })
            }
            
            rotation = CGAffineTransform(rotationAngle: 0)
            
            scaledAndRotated = rotation.scaledBy(x: 1, y: 1)
            
            matchImageView.transform = scaledAndRotated
            
            matchImageView.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        }
    }
    
    func updateImage() {
        if let query = PFUser.query() {
        
            if let isInterestedInWomen = PFUser.current()?["isInterestedInWomen"] {
                query.whereKey("isFemale", equalTo: isInterestedInWomen)
            }
            
            if let isFemale = PFUser.current()?["isFemale"] {
                query.whereKey("isInterestedInWomen", equalTo: isFemale)
            }
            
            var ignoredUsers : [String] = []
            
            if let acceptedUsers = PFUser.current()?["accepted"] as? [String] {   //adds accepted users to database
                ignoredUsers += acceptedUsers
            }
            
            if let rejectedUsers = PFUser.current()?["rejected"] as? [String] {  //adds rejected users to database
                ignoredUsers += rejectedUsers
            }
            
            query.whereKey("objectId", notContainedIn: ignoredUsers)
            
            if let geoPoint = PFUser.current()?["location"] as? PFGeoPoint {
                
                //ensure you get matches within location
                query.whereKey("location", withinGeoBoxFromSouthwest: PFGeoPoint(latitude: geoPoint.latitude - 1 , longitude: geoPoint.longitude - 1), toNortheast: PFGeoPoint(latitude: geoPoint.latitude + 1 , longitude: geoPoint.longitude + 1))
            }
            
            query.limit = 1  //one person per screen
            query.findObjectsInBackground { (objects, error) in
                
                if let users = objects {
                    
                    for object in users {
                        
                        if let user = object as? PFUser {
                            
                            if let imageFile = user["photo"] as? PFFileObject {
                                
                                imageFile.getDataInBackground(block: { (data, error) in
                                    if let imageData = data {
                                        
                                        self.matchImageView.image = UIImage(data: imageData)   //retrieves photo of women
                                        if let objectID = object.objectId {
                                            self.displayUserID = objectID
                                        }
                                    }
                                })
                            }
                        }
                    }
                }
                
            }
        }
    }


}

