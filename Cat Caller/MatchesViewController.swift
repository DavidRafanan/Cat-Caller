//
//  MatchesViewController.swift
//  Cat Caller
//
//  Created by David Rafanan on 4/26/19.
//  Copyright © 2019 David Rafanan. All rights reserved.
//

import UIKit
import Parse

class MatchesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var images : [UIImage] = []
    var userIds : [String] = []
    var messages : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        if let query = PFUser.query() {
            query.whereKey("accepted", contains: PFUser.current()?.objectId)
            
            //people who accepted user
            if let acceptedPeople = PFUser.current()?["accepted"] as? [String] {
                
                query.whereKey("objectId", containedIn: acceptedPeople)
                
                query.findObjectsInBackground(block: { (objects, error) in
                    
                    if let unwrappedObjects = objects {
                        
                        for unwrappedObject in unwrappedObjects {
                            
                            if let theUser = unwrappedObject as? PFUser {
                                
                                if let imageFile = theUser["photo"] as? PFFileObject {
                                    
                                    imageFile.getDataInBackground(block: { (data, error) in
                                        
                                        if let imageData = data {
                                            
                                            if let image = UIImage(data: imageData) {
                                                
                                                if let objectId = theUser.objectId {
                                                    
                                                    let messagesQuery = PFQuery(className: "Message")
                                                    
                                                    
                                                    //sends messages between sender and recipient through ID
                                                    messagesQuery.whereKey("recipient", equalTo: PFUser.current()?.objectId as Any)
                                                    messagesQuery.whereKey("sender", equalTo: theUser.objectId as Any)
                                                    
                                                    //dissecting whether message or not
                                                    messagesQuery.findObjectsInBackground(block: { (objects, error) in
                                                        
                                                        //no message from person
                                                        var messageText = "No response from this person."
                                                        
                                                        //received message from person
                                                        if let objects = objects {
                                                            for message in objects {
                                                                if let content = message["content"] as? String {
                                                                    messageText = content
                                                                }
                                                            }
                                                        }
                                                        
                                                        //updates messages
                                                        self.messages.append(messageText)
                                                        self.userIds.append(objectId)
                                                        self.images.append(image)
                                                        self.tableView.reloadData()
                                                        
                                                        
                                                    })
                                                    
                                                 //self.tableView.reloadData()
                                                }
                                            }
                                            
                                            
                                        }
                                        
                                    })
                                }
                            }
                        }
                    }
                })
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        //returns specific table view cell
        if let cell = tableView.dequeueReusableCell(withIdentifier: "catcallCell", for: indexPath) as? MatchTableViewCell {
            cell.messageLabel.text = "You haven't received a response yet"
            cell.profileImageView.image = images[indexPath.row]
            cell.recipientObjectId = userIds[indexPath.row]
            cell.messageLabel.text = messages[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    //goes back to update view controller
    @IBAction func backTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
