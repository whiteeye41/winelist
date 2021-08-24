//
//  BarsUITextField.swift
//  winelist
//
//  Created by cosima on 2020/5/20.
//  Copyright © 2020 cosima. All rights reserved.
//

import UIKit

class BarsUITextField: UITextField {

    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.layer.cornerRadius = 5.0
        self.layer.masksToBounds = true
    }

}
