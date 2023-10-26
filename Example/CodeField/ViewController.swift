//
//  ViewController.swift
//  CodeField
//
//  Created by brownsoo on 10/29/2018.
//  Copyright (c) 2018 brownsoo. All rights reserved.
//

import UIKit
import CodeField

class ViewController: UIViewController {

    @IBOutlet weak var codeField1: CodeField!
    @IBOutlet weak var codeField2: CodeField!
    @IBOutlet weak var lbTypedCode: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        codeField2.delegate = self
        codeField2.keyboardType = .alphabet
        
        let codeField3 = CodeField()
        codeField3.codeFont = UIFont.systemFont(ofSize: 14, weight: .thin)
        codeField3.helper = "made by code"
        view.addSubview(codeField3)
        codeField3.translatesAutoresizingMaskIntoConstraints = false
        codeField3.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        codeField3.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        codeField3.topAnchor.constraint(equalTo: lbTypedCode.bottomAnchor, constant: 30).isActive = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: CodeFieldDelegate {
    func codeDidChanged(code: String) {
        lbTypedCode.text = code
    }
}
