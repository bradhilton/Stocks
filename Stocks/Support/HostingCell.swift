//
//  HostingCell.swift
//  Stocks
//
//  Created by Bradley Hilton on 9/14/19.
//  Copyright © 2019 Brad Hilton. All rights reserved.
//

import SwiftUI

class HostingCell<Content : View> : UITableViewCell {
    
    var hostingController: UIHostingController<Content>?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var content: Content? {
        get {
            hostingController?.rootView
        }
        set {
            guard let content = newValue else { return }
            if let hostingController = hostingController {
                hostingController.rootView = content
            } else {
                hostingController = UIHostingController(rootView: content)
                let view = hostingController!.view!
                view.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview(view)
                let margins = contentView.layoutMarginsGuide
                NSLayoutConstraint.activate(
                    [
                        view.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
                        view.topAnchor.constraint(equalTo: margins.topAnchor),
                        view.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
                        view.bottomAnchor.constraint(equalTo: margins.bottomAnchor)
                    ]
                )
            }
        }
    }
    
}

