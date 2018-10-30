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
    @IBOutlet weak var typedCodeLb: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        codeField2.delegate = self
        codeField2.keyboardType = .alphabet
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: CodeFieldDelegate {
    func codeDidChanged(code: String) {
        typedCodeLb.text = code
    }
}
