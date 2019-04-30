//
//  UpdateViewController.swift
//  Cat Caller
//
//  Created by David Rafanan on 4/25/19.
//  Copyright © 2019 David Rafanan. All rights reserved.
//

import UIKit
import Parse

class UpdateViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var UserGenderSwitch: UISwitch!
    
    @IBOutlet weak var InterestedGenderSwitch: UISwitch!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        errorLabel.isHidden = true //inital default for user
        
        if let isFemale = PFUser.current()?["isFemale"] as? Bool {
            UserGenderSwitch.setOn(isFemale, animated: false)
        }
        
        if let isInterestedInWomen = PFUser.current()?["isInterestedInWomen"] as? Bool {
            InterestedGenderSwitch.setOn(isInterestedInWomen, animated: false)
        }
        
        if let photo = PFUser.current()?["photo"] as? PFFileObject {
            photo.getDataInBackground(block: {(data, error) in
                if let imageData = data {
                    if let image = UIImage(data: imageData) {
                        self.profileImageView.image = image
                    }
                }
            })
        }
        
        //createWomen()
    }
    
    
    @IBAction func logoutTapped(_ sender: Any) {
        PFUser.logOut()
        performSegue(withIdentifier: "logoutSegue", sender: nil)
    }
    
    @IBAction func updateImageTapped(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = [UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImageView.image = image
        }
        
        dismiss(animated: true, completion: nil)
    }
    func createWomen() {
        let imageUrls = ["https://vignette.wikia.nocookie.net/rickandmorty/images/5/58/Beth_Smith.png/revision/latest?cb=20151204220729","https://vignette.wikia.nocookie.net/rickandmorty/images/a/ad/Summer_is_cool.jpeg/revision/latest?cb=20160919183158"]
        
        var counter = 0
        
        for imageUrl in imageUrls {
            if let url = URL(string: imageUrl) {  //converts string to URL
                if let data = try? Data(contentsOf: url) {
                    
                    let imageFile = PFFileObject(name: "photo.png", data: data)
                    let user = PFUser()
                    user["photo"] = imageFile
                    user.username = String(counter)
                    user.password = "abc123"
                    
                    //default to women
                    user["isFemale"] = true
                    user["isInterestedInWomen"] = false
                    
                    user.signUpInBackground(block: { (success, error) in
                        if success {
                            print("Woman User Created!")
                        }
                    })
                }
            }
        }
        
    }
    @IBAction func updateTapped(_ sender: Any) {
        PFUser.current()?["isFemale"] = UserGenderSwitch.isOn
        PFUser.current()?["isInterestedInWomen"] = InterestedGenderSwitch.isOn
        
        if let image = profileImageView.image {
        
            if let imageData = image.pngData() {
            
                PFUser.current()?["photo"] = PFFileObject(name: "photo.png", data: imageData)
                
                PFUser.current()?.saveInBackground(block: {
                    (success, error) in
                    
                    if error != nil {
                        
                        var errorMessage = "Update Failed - Try Again"
                        
                        if let newError = error as? NSError {
                            
                            if let detailError = newError.userInfo["error"] as? String {
                                
                                errorMessage = detailError
                                
                            }
                        }
                        
                        self.errorLabel.isHidden = false
                        self.errorLabel.text = errorMessage
                    } else {
                        print("Update Successful")
                        
                        self.performSegue(withIdentifier: "updateToSwipeSegue", sender: nil)
                    }
                    
                })
            
            }
        }
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
