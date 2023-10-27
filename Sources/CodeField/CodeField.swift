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
        print(klassName, "init(frame)")
        setupLayout()
        resetCodeViews()
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        print(klassName, "awakeFromNib()")
        setupLayout()
        resetCodeViews()
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        print(klassName, "prepareForInterfaceBuilder")
        isInterfaceBuilding = true
        setupLayout()
        updateUI()
    }
    
    
    deinit {
        clearObservingUpdates()
    }
    
    struct UIState: Equatable {
        var codeCount: Int = 6
        var oneCodeLength: Int = 1
        var oneCodePlaceHolder: String? = "0"
        var codeBackgroundColor: UIColor = UIColor.yellow.withAlphaComponent(0.3)
        var codeFont: UIFont = CodeField.codeFont
        var label: String? = nil
        var underlineDefaultColor: UIColor = CodeField.underlineColor
        var underlineFilledColor: UIColor = CodeField.underlineFilledColor
        var underlineEditingColor: UIColor = CodeField.underlineEditingColor
        var underlineHeight: CGFloat = CodeField.underlineHeight
        var helper: String? = nil
        var helperFont = UIFont.systemFont(ofSize: 13, weight: .regular)
        var helperTextColor = UIColor(red: 52/255.0, green: 58/255.0, blue: 64/255.0, alpha: 1.0)
        var isEnabled: Bool = true
        var keyboardType: UIKeyboardType = .numberPad
    }
    
    private var _uiState = UIState()
    private var uiState: UIState {
        get {
            _uiState
        }
        set {
            if _uiState != newValue {
                _uiState = newValue
                updateUI()
            }
        }
    }
    
    /// 코드 묶음 갯수
    @IBInspectable
    @objc dynamic public var codeLength: Int {
        get {
            return _codeLength
        }
        set {
            if newValue > 0 {
                _codeLength = newValue
                let new = newValue
                if _codeLength != new {
                    resetCodeViews()
                }
            }
        }
    }
    
    /// 한 코드의 문자 길이
    @IBInspectable
    public var oneCodeLength: Int{
        get {
            uiState.oneCodeLength
        }
        set {
            var newState = uiState
            newState.oneCodeLength = newValue
            uiState = newState
        }
    }
    
    @IBInspectable
    public var oneCodePlaceHolder: String?{
        get {
            uiState.oneCodePlaceHolder
        }
        set {
            var newState = uiState
            newState.oneCodePlaceHolder = newValue
            uiState = newState
        }
    }
    
    @IBInspectable
    public var codeBackgroundColor: UIColor {
        get {
            uiState.codeBackgroundColor
        }
        set {
            var newState = uiState
            newState.codeBackgroundColor = newValue
            uiState = newState
        }
    }
    
    @IBInspectable
    public var codeFont: UIFont {
        get {
            uiState.codeFont
        }
        set {
            var newState = uiState
            newState.codeFont = newValue
            uiState = newState
        }
    }
    @IBInspectable
    public var label: String? {
        get {
            uiState.label
        }
        set {
            var newState = uiState
            newState.label = newValue
            uiState = newState
        }
    }
    
    @IBInspectable
    public var underlineDefaultColor: UIColor {
        get {
            uiState.underlineDefaultColor
        }
        set {
            var newState = uiState
            newState.underlineDefaultColor = newValue
            uiState = newState
        }
    }
    
    @IBInspectable
    public var underlineFilledColor: UIColor {
        get {
            uiState.underlineFilledColor
        }
        set {
            var newState = uiState
            newState.underlineFilledColor = newValue
            uiState = newState
        }
    }
    
    @IBInspectable
    public var underlineEditingColor: UIColor {
        get {
            uiState.underlineEditingColor
        }
        set {
            var newState = uiState
            newState.underlineEditingColor = newValue
            uiState = newState
        }
    }
    
    @IBInspectable
    public var underlineHeight: CGFloat {
        get {
            uiState.underlineHeight
        }
        set {
            var newState = uiState
            newState.underlineHeight = newValue
            uiState = newState
        }
    }
    
    @IBInspectable
    public var helper: String? {
        get {
            uiState.helper
        }
        set {
            var newState = uiState
            newState.helper = newValue
            uiState = newState
        }
    }
    @IBInspectable
    public var helperFont: UIFont {
        get {
            uiState.helperFont
        }
        set {
            var newState = uiState
            newState.helperFont = newValue
            uiState = newState
        }
    }
    
    @IBInspectable
    public var helperTextColor: UIColor {
        get {
            uiState.helperTextColor
        }
        set {
            var newState = uiState
            newState.helperTextColor = newValue
            uiState = newState
        }
    }
    
    @IBInspectable
    public var isEnabled: Bool {
        get {
            uiState.isEnabled
        }
        set {
            var newState = uiState
            newState.isEnabled = newValue
            uiState = newState
        }
    }
    
    @IBInspectable
    public var keyboardType: UIKeyboardType {
        get {
            uiState.keyboardType
        }
        set {
            var newState = uiState
            newState.keyboardType = newValue
            uiState = newState
        }
    }
    
    @IBInspectable
    public var code: String {
        set {
            let length = codeLength * oneCodeLength
            let newLength = newValue.count
            var news = Array(newValue.map({ String($0) }))
            if newLength <= length {
                let empties = Array(repeating: "", count: length - newLength)
                codes = news + empties
            } else {
                news.removeSubrange(length..<newLength)
                codes = news
            }
            fillCodeWith(codes, dispatching: true)
        }
        get {
            return codes.joined()
        }
    }
    
    public var codeDistribution: UIStackView.Distribution = .fillEqually {
        willSet {
            stvCode.distribution = newValue
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
    private var _codeLength = 6
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
                cursor = min(codeLength - 1, charBox.tag + 1)
            }
        }
        delegate?.codeDidChanged(code: self.code)
    }
}

extension CodeField {
    
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
        for idx in 0..<codeLength {
            let charBox = CharBox(tag: idx)
            charBox.translatesAutoresizingMaskIntoConstraints = false
            charBox.setContentHuggingPriority(.required, for: .vertical)
            charBox.setContentCompressionResistancePriority(.required, for: .vertical)
            stvCode.addArrangedSubview(charBox)
            charBox.delegate = self
            codes.append(originCodes.getAt(idx) ?? "")
            boxes.append(charBox)
        }
        
        updateUI()
        if !isInterfaceBuilding {
            fillCodeWith(codes, dispatching: false)
        }
    }
    
    
    private func updateUI() {
        debugPrint(klassName, "updateUI()")
        // TODO: 변경 속성을 상태값 하나로 처리.
        boxes.forEach {
            $0.maxLength = oneCodeLength
            $0.placeholder = oneCodePlaceHolder
            $0.backgroundColor = codeBackgroundColor
            $0.textField.font = codeFont
            $0.textField.isEnabled = isEnabled
            $0.underlineDefaultColor = underlineDefaultColor
            $0.underlineFilledColor = underlineFilledColor
            $0.underlineEditingColor = underlineEditingColor
            $0.underlineHeight = underlineHeight
            $0.keyboardType = keyboardType
        }
        lbLabel.text = label
        lbHelper.text = helper
        if helper == nil {
            helperBottomConstraint?.isActive = false
        } else {
            helperBottomConstraint?.isActive = true
        }
        lbHelper.font = helperFont
        lbHelper.textColor = helperTextColor
        
        if isInterfaceBuilding {
            fillCodeWith(codes, dispatching: false)
        }
    }
    
    private func fillCodeWith(_ news: [String], dispatching: Bool) {
        let boxCount = boxes.count
        let oneCount = oneCodeLength
        
        news.enumerated().forEach { it in
            let boxIndex = it.offset / oneCount
            if boxIndex < boxCount {
                let offsetInBox = it.offset % oneCount
                if offsetInBox == 0 {
                    boxes[boxIndex].textField.text = String(it.element)
                } else {
                    var text = boxes[boxIndex].textField.text
                    text?.append(String(it.element))
                    boxes[boxIndex].textField.text = text
                }
            }
        }
        if dispatching {
            delegate?.codeDidChanged(code: self.code)
        }
    }
    
    private func clearObservingUpdates() {
        observations.removeAll()
    }
    
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




