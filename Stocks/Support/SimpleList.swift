//
//  SimpleList.swift
//  Stocks
//
//  Created by Bradley Hilton on 9/13/19.
//  Copyright © 2019 Brad Hilton. All rights reserved.
//

import SwiftUI

extension String {
    fileprivate static let cellIdentifier = "cellIdentifier"
}

struct SimpleList<Contents : RandomAccessCollection> : UIViewRepresentable where Contents.Element : View {
    
    let contents: Contents
    
    func makeUIView(context: Context) -> UITableView {
        let tableView = UITableView()
        tableView.dataSource = context.coordinator
        tableView.delegate = context.coordinator
        tableView.register(
            HostingCell<Contents.Element>.self,
            forCellReuseIdentifier: .cellIdentifier
        )
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        return tableView
    }
    
    func updateUIView(
        _ tableView: UITableView,
        context: Context
    ) {
        context.coordinator.contents = contents
        tableView.reloadData()
    }
    
    func makeCoordinator() -> SimpleCoordinator<Contents> {
        SimpleCoordinator(contents)
    }

}

class SimpleCoordinator<Contents : RandomAccessCollection> : NSObject, UITableViewDataSource, UITableViewDelegate where Contents.Element : View  {

    var contents: Contents

    init(_ contents: Contents) {
        self.contents = contents
    }
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        contents.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: .cellIdentifier,
            for: indexPath
        ) as! HostingCell<Contents.Element>
        cell.content = contents[
            contents.index(contents.startIndex, offsetBy: indexPath.row)
        ]
        return cell
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        false
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        nil
    }

}

struct SimpleList_Previews: PreviewProvider {
    static var previews: some View {
        SimpleList(contents: [Text("Hello")])
    }
}
