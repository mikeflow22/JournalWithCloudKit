//
//  DetailViewController.swift
//  JournalCloudKit
//
//  Created by Michael Flowers on 10/14/19.
//  Copyright © 2019 Michael Flowers. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var entry: Entry?  {
        didSet {
            loadViewIfNeeded()
            updateViews()
        }
    }
    
    @IBOutlet weak var titileTextField: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titileTextField.delegate = self
    }
    
    @IBAction func mainViewTapped(_ sender: UITapGestureRecognizer) {
        titileTextField.resignFirstResponder()
        bodyTextView.resignFirstResponder()
    }
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        guard let title = titileTextField.text, !title.isEmpty, let body = bodyTextView.text, !body.isEmpty else { return }
        
        EntryController.shared.addEntryWith(title: title, bodyText: body) { (success) in
            if  success {
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
    
    func updateViews(){
        guard let passedInEntry = entry else { return }
        titileTextField.text = passedInEntry.title
        bodyTextView.text =  passedInEntry.bodyText
        title = passedInEntry.title
    }
    
    
    
    
    
    
}

extension DetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titileTextField.resignFirstResponder()
        return true
    }
    
}











