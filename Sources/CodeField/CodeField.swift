// CodeField.swift
//
// Created by  brownsoo han

import UIKit

public protocol CodeFieldDelegate {
    func codeDidChanged(code: String) -> Void
}

@IBDesignable
public class CodeField: UIView, UITextFieldDelegate {
    /// underline color of the text filled
    static let underlineFilledColor = UIColor(red: 74/255.0, green: 144/255.0, blue: 226/255.0, alpha: 1.0)
    /// default underline color of the empty text
    static let underlineColor = UIColor(white: 0.95, alpha: 1)
    /// default underline color when editing text
    static let underlineEditingColor = UIColor.black
    /// default underline height
    static let underlineHeight: CGFloat = 3.0
    /// default code font
    static let codeFont = UIFont.systemFont(ofSize: 33, weight: .medium)
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        debugPrint(klassName, "init(frame)")
        setupLayout()
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        debugPrint(klassName, "awakeFromNib()")
        setupLayout()
        
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        debugPrint(klassName, "prepareForInterfaceBuilder")
        isInterfaceBuilding = true
        updateUI()
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
    
    @IBInspectable
    public var codeFont: UIFont = CodeField.codeFont {
        willSet {
            boxes.forEach { box in
                box.textField.font = codeFont
            }
        }
    }
    
    @IBInspectable
    public var codeDistribution: UIStackView.Distribution = .fillEqually {
        willSet {
            stvCode.distribution = codeDistribution
        }
    }
    
    @IBInspectable
    public var label: String? = nil {
        willSet {
            lbLabel.text = label
        }
    }
    
    @IBInspectable
    public var underlineDefaultColor: UIColor = CodeField.underlineColor {
        willSet {
            boxes.forEach { $0.underlineDefaultColor = underlineDefaultColor }
        }
    }
    
    @IBInspectable
    public var underlineFilledColor: UIColor = CodeField.underlineFilledColor {
        willSet {
            boxes.forEach { $0.underlineFilledColor = underlineFilledColor }
        }
    }
    
    @IBInspectable
    public var underlineEditingColor: UIColor = CodeField.underlineEditingColor {
        willSet {
            boxes.forEach { $0.underlineEditingColor = underlineEditingColor }
        }
    }
    
    @IBInspectable
    public var underlineHeight: CGFloat = CodeField.underlineHeight {
        willSet {
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
    
    @IBInspectable
    public var helper: String? = nil {
        didSet {
            lbHelper.text = helper
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
            lbHelper.font = helperFont
        }
    }
    
    @IBInspectable
    public var helperTextColor = UIColor(red: 52/255.0, green: 58/255.0, blue: 64/255.0, alpha: 1.0) {
        didSet {
            lbHelper.textColor = helperTextColor
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
    
    
    public var allFilled: Bool {
        return codes.filter{ $0.isEmpty }.count == 0
    }
    
    /// 코드 필드의 델리게이터
    public var delegate: CodeFieldDelegate?
    
    private lazy var klassName = "CodeField@\(String(format: "%02X", hash))"
    private var observations: Set<NSKeyValueObservation> = []
    private var isInterfaceBuilding = false
    private var _codeCount: Int = 6
    private let lbLabel = UILabel()
    private lazy var lbHelper: UILabel = {
        let lb = UILabel()
        lb.font = helperFont
        lb.textColor = helperTextColor
        lb.setContentCompressionResistancePriority(.required, for: .vertical)
        lb.setContentHuggingPriority(.required, for: .vertical)
        return lb
    }()
    private var helperBottomConstraint: NSLayoutConstraint?
    private let stvCode = UIStackView()
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
        if !isInterfaceBuilding {
            resetCodeViews()
        }
    }
    
    private func updateUI() {
        // TODO: 변경 속성을 상태값 하나로 처리.
    }
    
    
    
    private func resetCodeViews() {
        debugPrint(klassName, "resetCodeViews")
        
        if stvCode.superview != nil {
            for child in stvCode.subviews {
                stvCode.removeArrangedSubview(child)
                child.removeFromSuperview()
                for con in child.constraints {
                    child.removeConstraint(con)
                }
                (child as? CharBox)?.delegate = nil
            }
        }
        let originCodes = codes
        codes.removeAll(keepingCapacity: false)
        boxes.removeAll(keepingCapacity: false)
        for idx in 0..<codeCount {
            let charBox = CharBox(tag: idx)
            charBox.translatesAutoresizingMaskIntoConstraints = false
            charBox.setContentHuggingPriority(.required, for: .vertical)
            charBox.setContentCompressionResistancePriority(.required, for: .vertical)
            charBox.textField.font = self.codeFont
            charBox.keyboardType = self.keyboardType
            charBox.underlineFilledColor = underlineFilledColor
            charBox.underlineDefaultColor = underlineDefaultColor
            charBox.underlineEditingColor = underlineEditingColor
            charBox.maxLength = oneCodeLength
            charBox.placeholder = oneCodePlaceHolder
            charBox.backgroundColor = codeBackgroundColor
            stvCode.addArrangedSubview(charBox)
            charBox.delegate = self
            codes.append(originCodes.getAt(idx) ?? "")
            boxes.append(charBox)
        }
        
        if helper != nil {
            helperBottomConstraint?.isActive = true
        } else {
            helperBottomConstraint?.isActive = false
        }
    }
}

extension Array {
    func getAt(_ offset: Int) -> Element? {
        guard offset < self.count else  {
            return nil
        }
        return self[offset]
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
        debugPrint(klassName, "tag: \(charBox.tag)", "didTextChanged \(oneCodeLength)")
        codes[charBox.tag] = text ?? ""
        if let typed = text {
            if !typed.isEmpty && typed.count == oneCodeLength {
                cursor = min(codeCount - 1, charBox.tag + 1)
            }
        }
        delegate?.codeDidChanged(code: self.code)
    }
}

extension CodeField {
    private func setupLayout() {
        debugPrint(klassName, "setupLayout")
        
        addSubview(lbLabel)
        lbLabel.textColor = UIColor(red: 52/255.0, green:58/255.0, blue:64/255.0, alpha: 1.0)
        lbLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbLabel.translatesAutoresizingMaskIntoConstraints = false
        lbLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        lbLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor).isActive = true
        lbLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        lbLabel.setContentHuggingPriority(.required, for: .vertical)
        lbLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        addSubview(stvCode)
        stvCode.axis = .horizontal
        stvCode.distribution = .fillEqually
        stvCode.alignment = .top
        stvCode.spacing = 6
        stvCode.translatesAutoresizingMaskIntoConstraints = false
        stvCode.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        stvCode.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        stvCode.topAnchor.constraint(equalTo: lbLabel.bottomAnchor, constant: 8).isActive = true
        stvCode.setContentHuggingPriority(.defaultLow, for: .vertical)
        stvCode.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        let bottomConstraint = stvCode.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        bottomConstraint.priority = .defaultLow
        bottomConstraint.isActive = true
        
        addSubview(lbHelper)
        lbHelper.translatesAutoresizingMaskIntoConstraints = false
        lbHelper.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        lbHelper.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        lbHelper.topAnchor.constraint(equalTo: stvCode.bottomAnchor, constant: 8).isActive = true
        lbHelper.setContentHuggingPriority(.required, for: .vertical)
        lbHelper.setContentCompressionResistancePriority(.required, for: .vertical)
        helperBottomConstraint = lbHelper.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        
    }
}




