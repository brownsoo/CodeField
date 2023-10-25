// CodeField.swift
//
// Created by  brownsoo han

import UIKit

public protocol CodeFieldDelegate {
    func codeDidChanged(code: String) -> Void
}

@IBDesignable
public class CodeField: UIView, UITextFieldDelegate {
    
    static let defaultUnderlineFilledColor = UIColor(red: 74/255.0,
                                                     green: 144/255.0,
                                                     blue: 226/255.0,
                                                     alpha: 1.0)
    static let defaultUnderlineColor = UIColor(white: 0.95, alpha: 1)
    static let defaultUnderlineHeight: CGFloat = 3.0
    static let defaultUnderlineEditingColor = UIColor.black
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        onInit()
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        onInit()
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        debugPrint(klassName, "prepareForInterfaceBuilder")
        
    }
    
    /// 코드 묶음 갯수
    @IBInspectable
    public var codeCount: Int {
        get {
            return _codeCount
        }
        set {
            if newValue > 0 {
                _codeCount = newValue
                let new = newValue
                if _codeCount != new {
                    resetCodeViews()
                }
            }
        }
    }
    
    /// 한 코드의 문자 길이
    @IBInspectable
    public var oneCodeLength: Int = 1 {
        didSet {
            boxes.forEach { $0.maxLength = oneCodeLength }
        }
    }
    
    @IBInspectable
    public var oneCodePlaceHolder: String? = "0" {
        didSet {
            boxes.forEach { $0.placeholder = oneCodePlaceHolder }
        }
    }
    
    @IBInspectable
    public var codeBackgroundColor: UIColor = UIColor.yellow.withAlphaComponent(0.3) {
        didSet {
            boxes.forEach { $0.backgroundColor = codeBackgroundColor }
        }
    }
    
//    @available(*, unavailable)
//    public var codeHeight: CGFloat = 58 {
//        didSet {
//            boxes.forEach { $0.heightConstraint?.constant = codeHeight }
//        }
//    }
    
    @IBInspectable
    public var codeFont: UIFont = UIFont.systemFont(ofSize: 33, weight: .medium) {
        willSet {
            boxes.forEach { box in
                box.textField.font = codeFont
            }
        }
    }
    
    @IBInspectable
    public var codeDistribution: UIStackView.Distribution = .fillEqually {
        didSet {
            stack.distribution = codeDistribution
        }
    }
    
    @IBInspectable
    public var label: String? = nil {
        didSet {
            labelView.text = label
        }
    }
    
    @IBInspectable
    public var underlineDefaultColor: UIColor = CodeField.defaultUnderlineColor {
        didSet {
            boxes.forEach { $0.underlineDefaultColor = underlineDefaultColor }
        }
    }
    
    @IBInspectable
    public var underlineFilledColor: UIColor = CodeField.defaultUnderlineFilledColor {
        didSet {
            boxes.forEach { $0.underlineFilledColor = underlineFilledColor }
        }
    }
    
    @IBInspectable
    public var underlineEditingColor: UIColor = CodeField.defaultUnderlineEditingColor {
        didSet {
            boxes.forEach { $0.underlineEditingColor = underlineEditingColor }
        }
    }
    
    @IBInspectable
    public var underlineHeight: CGFloat = CodeField.defaultUnderlineHeight {
        didSet {
            boxes.forEach { $0.underlineHeight = underlineHeight }
        }
    }
    
    @IBInspectable
    public var code: String {
        set(new) {
            let count = new.count
            let boxCount = boxes.count
            for i in 0..<boxCount {
                if i < count {
                    let char = new.enumerated().first { offset, _ in offset == i }?.element
                    if char != nil {
                        boxes[i].textField.text = String(char!)
                        continue
                    }
                }
                boxes[i].textField.text = ""
            }
        }
        get {
            return codes.joined()
        }
    }
    
    public var allFilled: Bool {
        return codes.filter{ $0.isEmpty }.count == 0
    }
    
    @IBInspectable
    public var helper: String? = nil {
        didSet {
            helperLb.text = helper
            if helper == nil {
                helperBottomConstraint?.isActive = false
            } else {
                helperBottomConstraint?.isActive = true
            }
        }
    }
    
    @IBInspectable
    public var helperFont = UIFont.systemFont(ofSize: 13, weight: .regular) {
        didSet {
            helperLb.font = helperFont
        }
    }
    
    @IBInspectable
    public var helperTextColor = UIColor(red: 52/255.0, green: 58/255.0, blue: 64/255.0, alpha: 1.0) {
        didSet {
            helperLb.textColor = helperTextColor
        }
    }
    
    @IBInspectable
    public var isEnabled: Bool = true {
        didSet {
            boxes.forEach { $0.textField.isEnabled = isEnabled }
        }
    }
    
    @IBInspectable
    public var keyboardType: UIKeyboardType = .numberPad {
        didSet {
            boxes.forEach { $0.keyboardType = keyboardType }
        }
    }
    
    /// 코드 필드의 델리게이터
    public var delegate: CodeFieldDelegate?
    
    private var _codeCount: Int = 6
    private lazy var klassName = "CodeField@\(hash)"
    private let labelView = UILabel()
    private lazy var helperLb: UILabel = {
        let lb = UILabel()
        lb.font = helperFont
        lb.textColor = helperTextColor
        lb.setContentCompressionResistancePriority(.required, for: .vertical)
        lb.setContentHuggingPriority(.required, for: .vertical)
        return lb
    }()
    private var helperBottomConstraint: NSLayoutConstraint?
    private let stack = UIStackView()
    private var codes = [String]()
    private var boxes = [CharBox]()
    private var cursor: Int = 0 {
        didSet {
            let box = boxes.first { $0.tag == cursor }
            box?.textField.becomeFirstResponder()
            box?.updateFilled()
        }
    }
    
    @discardableResult
    public override func becomeFirstResponder() -> Bool {
        if let tf = boxes.first?.textField {
            return tf.becomeFirstResponder()
        }
        return false
    }
    
    public override func layoutSubviews() {
        debugPrint(klassName, "layoutSubviews")
        super.layoutSubviews()
    }
    
    private func onInit() {
        debugPrint(klassName, "onInit")
        
        addSubview(labelView)
        labelView.textColor = UIColor(red: 52/255.0, green:58/255.0, blue:64/255.0, alpha: 1.0)
        labelView.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        labelView.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor).isActive = true
        labelView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        addSubview(stack)
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .top
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        stack.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        stack.topAnchor.constraint(equalTo: labelView.bottomAnchor, constant: 8).isActive = true
        stack.setContentHuggingPriority(.defaultLow, for: .vertical)
        stack.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        let bottomConstraint = stack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        bottomConstraint.priority = .defaultLow
        bottomConstraint.isActive = true
        
        addSubview(helperLb)
        helperLb.translatesAutoresizingMaskIntoConstraints = false
        helperLb.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        helperLb.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        helperLb.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 8).isActive = true
        helperBottomConstraint = helperLb.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        
        DispatchQueue.main.async {
            self.resetCodeViews()
        }
    }
    
    private func resetCodeViews() {
        debugPrint(klassName, "resetCodeViews")
        
        if stack.superview != nil {
            for child in stack.subviews {
                stack.removeArrangedSubview(child)
                child.removeFromSuperview()
                for con in child.constraints {
                    child.removeConstraint(con)
                }
                (child as? CharBox)?.delegate = nil
            }
        }
        
        codes.removeAll(keepingCapacity: false)
        boxes.removeAll(keepingCapacity: false)
        for idx in 0..<codeCount {
            let charBox = CharBox(tag: idx)
            charBox.translatesAutoresizingMaskIntoConstraints = false
            charBox.heightConstraint = charBox.heightAnchor.constraint(equalToConstant: codeHeight)
            charBox.heightConstraint?.isActive = true
            charBox.keyboardType = keyboardType
            charBox.underlineFilledColor = underlineFilledColor
            charBox.underlineDefaultColor = underlineDefaultColor
            charBox.underlineEditingColor = underlineEditingColor
            charBox.maxLength = oneCodeLength
            charBox.placeholder = oneCodePlaceHolder
            charBox.backgroundColor = codeBackgroundColor
            stack.addArrangedSubview(charBox)
            charBox.delegate = self
            codes.append("")
            boxes.append(charBox)
        }
        
        if helper != nil {
            helperBottomConstraint?.isActive = true
        } else {
            helperBottomConstraint?.isActive = false
        }
    }
    
}

extension CodeField: CharBoxDelegate {
    func didDeleteNothing(tag: Int, of charBox: CharBox) {
        debugPrint(klassName, "didDeleteNothing \(tag)")
        cursor = max(0, tag - 1)
        if tag - 1 >= 0 {
            boxes[tag - 1].textField.text = nil
            codes[tag - 1] = ""
        }
        delegate?.codeDidChanged(code: self.code)
    }
    
    func didTextChanged(text: String?, of charBox: CharBox) {
        debugPrint(klassName, "didTextChanged \(oneCodeLength)")
        codes[tag] = text ?? ""
        if text != nil && !(text!.isEmpty) && text!.count == oneCodeLength {
            cursor = min(codeCount - 1, tag + 1)
        }
        delegate?.codeDidChanged(code: self.code)
    }
}






