//
//  CharBox.swift
//  CodeField
//
//  Created by hyonsoo on 10/25/23.
//

import UIKit

protocol CharBoxDelegate: AnyObject {
    func didDeleteNothing(tag: Int, of charBox: CharBox) -> Void
    func didTextChanged(text: String?, of charBox: CharBox) -> Void
}


class CharBox: UIView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        observeUpdates()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
        observeUpdates()
    }
    
    convenience init(tag: Int = 0) {
        self.init(frame: CGRect())
        self.tag = tag
    }
    
    deinit {
        clearObservingUpdates()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        debugPrint(klassName, "prepareForInterfaceBuilder")
        isInterfaceBuilding = true
        updateUI()
    }
    
    
    weak var delegate: CharBoxDelegate?
    
    private lazy var klassName = "CharBox@\(String(format: "%02X", hash))"
    private var isInterfaceBuilding = false
    private let line = UIView()
    private var filled: Bool = false
    private var isEditing: Bool = false
    private var lineHeighConstraint: NSLayoutConstraint?
    private var observations: Set<NSKeyValueObservation> = []
    
    let textField: UITextField = NTextField()
    
    @objc dynamic var underlineHeight = CodeField.underlineHeight
    @objc dynamic var underlineDefaultColor = CodeField.underlineColor
    @objc dynamic var underlineFilledColor = CodeField.underlineFilledColor
    @objc dynamic var underlineEditingColor = CodeField.underlineEditingColor
   
    var maxLength: Int = 1
    
    var keyboardType: UIKeyboardType = .numberPad {
        didSet {
            textField.keyboardType = keyboardType
        }
    }
    var placeholder: String? = nil {
        didSet {
            textField.placeholder = placeholder
        }
    }
    
    private func updateUnderline(_ isEditing: Bool, isFilled: Bool) {
        if isEditing {
            line.backgroundColor = underlineEditingColor
        } else if isFilled {
            line.backgroundColor = underlineFilledColor
        } else {
            line.backgroundColor = underlineDefaultColor
        }
        lineHeighConstraint?.constant = underlineHeight
    }
    
    @discardableResult
    func updateFilled() -> Bool {
        let t = textField.text
        let filled = t != nil && !(t!.isEmpty)
        self.filled = filled
        return filled
    }
    
    @objc
    private func textFieldDidChange() {
        let t = textField.text
        delegate?.didTextChanged(text: t, of: self)
    }
    
    // TODO: 큐로 한번만 업데이트 되도록 수정
    private func updateUI() {
        // debugPrint(klassName, "updateUI")
        let filled = self.updateFilled()
        self.updateUnderline(isEditing, isFilled: filled)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // debugPrint(klassName, "layoutSubviews()")
        updateUI()
    }
    
}

extension CharBox: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= maxLength
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        isEditing = true
        updateUI()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        isEditing = false
        updateUI()
    }
}

extension CharBox: DeleteBackwardDelegate {
    func didBackDeletingNothing() {
        delegate?.didDeleteNothing(tag: self.tag, of: self)
    }
}

extension CharBox {
    
    private func observeUpdates() {
        guard !isInterfaceBuilding else { return }
        
        observations.insert(
            self.observe(\.underlineHeight, options: [.new]) { obj, change in
                if self.superview != nil {
                    obj.updateUI()
                }
            }
        )
        observations.insert(
            self.observe(\.underlineDefaultColor, options: [.new]) { obj, change in
                if self.superview != nil {
                    obj.updateUI()
                }
            }
        )
        observations.insert(
            self.observe(\.underlineFilledColor, options: [.new]) { obj, change in
                if self.superview != nil {
                    obj.updateUI()
                }
            }
        )
        observations.insert(
            self.observe(\.underlineEditingColor, options: [.new]) { obj, change in
                if self.superview != nil {
                    obj.updateUI()
                }
            }
        )
        
    }
    
    private func clearObservingUpdates() {
        observations.removeAll()
    }
    
    private func setupLayout() {
        self.addSubview(textField)
        textField.placeholder = placeholder
        textField.textAlignment = .center
        textField.keyboardType = keyboardType
        // auto layout
        textField.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = textField.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor)
        topConstraint.priority = .defaultHigh
        topConstraint.isActive = true
        let bottomConstraint = textField.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)
        bottomConstraint.priority = .defaultHigh
        bottomConstraint.isActive = true
        textField.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        textField.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        textField.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        (textField as! NTextField).backwardDelegate = self
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        self.addSubview(line)
        line.backgroundColor = underlineDefaultColor
        line.translatesAutoresizingMaskIntoConstraints = false
        lineHeighConstraint = line.heightAnchor.constraint(equalToConstant: underlineHeight)
        lineHeighConstraint?.isActive = true
        line.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        line.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        line.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
    }
}
