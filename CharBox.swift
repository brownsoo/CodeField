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
        debugPrint("init(frame")
        setupLayout()
        observeUpdates()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        debugPrint("awakeFromNib")
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
        debugPrint("prepareForInterfaceBuilder")
        isInterfaceBuilding = true
        update()
    }
    
    weak var delegate: CharBoxDelegate?
    private var isInterfaceBuilding = false
    private let line = UIView()
    private var filled: Bool = false
    private var lineHeighConstraint: NSLayoutConstraint?
    private var observations: Set<NSKeyValueObservation> = []
    let textField: UITextField = NTextField()
    var heightConstraint: NSLayoutConstraint?
    
    @objc dynamic var underlineHeight: CGFloat = CodeField.defaultUnderlineHeight
    @objc dynamic var underlineDefaultColor = CodeField.defaultUnderlineColor
    @objc dynamic var underlineFilledColor = CodeField.defaultUnderlineFilledColor
    @objc dynamic var underlineEditingColor = CodeField.defaultUnderlineEditingColor
    
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
    
    private func updateUnderline() {
        if isEditing {
            line.backgroundColor = underlineEditingColor
        } else if filled {
            line.backgroundColor = underlineFilledColor
        } else {
            line.backgroundColor = underlineDefaultColor
        }
        lineHeighConstraint?.constant = underlineHeight
    }
    
    private var isEditing: Bool = false
    
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
    
    @objc
    private func update() {
        let filled = updateFilled()
        updateUnderline()
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
        update()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        isEditing = false
        update()
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
            self.observe(\.underlineHeight, options: [.initial, .new]) { obj, change in
                obj.update()
            }
        )
        observations.insert(
            self.observe(\.underlineDefaultColor, options: [.initial, .new]) { obj, change in
                obj.update()
            }
        )
        observations.insert(
            self.observe(\.underlineFilledColor, options: [.initial, .new]) { obj, change in
                obj.update()
            }
        )
        observations.insert(
            self.observe(\.underlineEditingColor, options: [.initial, .new]) { obj, change in
                obj.update()
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
        textField.textColor = UIColor.black
        textField.font = UIFont.systemFont(ofSize: 33, weight: .medium)
        textField.keyboardType = keyboardType
        textField.textAlignment = .center
        textField.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = textField.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor)
        topConstraint.priority = .defaultLow
        topConstraint.isActive = true
        textField.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
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
