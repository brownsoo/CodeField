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
    
    let codeField3 = CodeField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        codeField2.delegate = self
        codeField2.keyboardType = .alphabet
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 10
        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        stack.topAnchor.constraint(equalTo: lbTypedCode.bottomAnchor, constant: 30).isActive = true
        
        
        codeField3.codeFont = UIFont.systemFont(ofSize: 14, weight: .thin)
        codeField3.helper = "made by code"
        stack.addArrangedSubview(codeField3)
        
        let fillBt = UIButton(type: .roundedRect)
        fillBt.setTitle("fill code with 'abcdefghi'", for: .normal)
        stack.addArrangedSubview(fillBt)
        fillBt.addTarget(self, action: #selector(fillCodes), for: .touchUpInside)
        
        let clearBt = UIButton(type: .roundedRect)
        clearBt.setTitle("clear codes", for: .normal)
        stack.addArrangedSubview(clearBt)
        clearBt.addTarget(self, action: #selector(clearCodes), for: .touchUpInside)
        
        let changeLabelBt = UIButton(type: .roundedRect)
        changeLabelBt.setTitle("set labels with 'GOOD'", for: .normal)
        stack.addArrangedSubview(changeLabelBt)
        changeLabelBt.addTarget(self, action: #selector(updateLabels), for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc func updateLabels() {
        codeField1.label = "GOOD"
        codeField2.label = "GOOD"
        codeField3.label = "GOOD"
    }
    
    @objc func clearCodes() {
        codeField1.code = ""
        codeField2.code = ""
        codeField3.code = ""
    }
    
    @objc func fillCodes() {
        codeField1.code = "abcdefghi"
        codeField2.code = "abcdefghi"
        codeField3.code = "abcdefghi"
    }

}

extension ViewController: CodeFieldDelegate {
    func codeDidChanged(code: String) {
        lbTypedCode.text = code
    }
}
