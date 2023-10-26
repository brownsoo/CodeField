//
//  NTextField.swift
//  CodeField
//
//  Created by hyonsoo on 10/25/23.
//

import UIKit

protocol DeleteBackwardDelegate: AnyObject {
    /// Called when nothing to delete with the back-key pressed
    /// 백 버튼을 눌렀을 때, 삭제될 문자가 없는 경우 호출된다.
    func didBackDeletingNothing() -> Void
}

class NTextField: UITextField {

    weak var backwardDelegate: DeleteBackwardDelegate?
    
    override func deleteBackward() {
        if self.text == nil || self.text!.isEmpty {
            backwardDelegate?.didBackDeletingNothing()
        }
        super.deleteBackward()
    }
}
