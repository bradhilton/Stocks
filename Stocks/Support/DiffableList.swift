//
//  SimpleList.swift
//  Stocks
//
//  Created by Bradley Hilton on 9/13/19.
//  Copyright © 2019 Brad Hilton. All rights reserved.
//

import SwiftUI

struct DiffableList<Contents : DiffableCollection> : UIViewRepresentable
    where Contents.Value : View {
    
    let contents: Contents
    
    func makeUIView(context: Context) -> UITableView {
        let tableView = UITableView()
        tableView.dataSource = context.coordinator
        tableView.delegate = context.coordinator
        tableView.register(
            HostingCell<Contents.Value>.self,
            forCellReuseIdentifier: .hostingCellIdentifier
        )
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        return tableView
    }
    
    func updateUIView(
        _ tableView: UITableView,
        context: Context
    ) {
        let diff = contents.diff(from: context.coordinator.contents)
        
        guard diff.count < 1000 else {
            context.coordinator.contents = contents
            tableView.reloadData()
            return
        }
        
        var deletes = [Int]()
        var moves = [(Int, Int)]()
        var inserts = [Int]()
        
        for key in diff {
            switch (
                context.coordinator.contents.position(of: key),
                contents.position(of: key)
            ) {
            case let (delete?, nil):
                deletes.append(delete)
            case let (from?, to?):
                moves.append((from, to))
            case let (nil, insert?):
                inserts.append(insert)
            case (nil, nil):
                break
            }
        }
        
        for indexPath in tableView.indexPathsForVisibleRows ?? [] {
            if
                let content = contents[context.coordinator.contents[indexPath.row]],
                let cell = tableView.cellForRow(at: indexPath) as? HostingCell<Contents.Value>
            {
                cell.content = content
            }
        }
        
        context.coordinator.contents = contents
        
        tableView.beginUpdates()
        tableView.deleteRows(at: deletes.map { .init(row: $0, section: 0) }, with: .automatic)
        for (from, to) in moves {
            tableView.moveRow(
                at: .init(row: from, section: 0),
                to: .init(row: to, section: 0)
            )
        }
        tableView.insertRows(at: inserts.map { .init(row: $0, section: 0) }, with: .automatic)
        tableView.endUpdates()
        
    }
    
    func makeCoordinator() -> DiffableCoordinator<Contents> {
        DiffableCoordinator(contents)
    }

}

class DiffableCoordinator<Contents : DiffableCollection> : TableCoordinator
    where Contents.Value : View  {

    var contents: Contents

    init(_ contents: Contents) {
        self.contents = contents
    }
    
    // MARK: UITableViewDataSource Conformance
    
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
            withIdentifier: .hostingCellIdentifier,
            for: indexPath
        ) as! HostingCell<Contents.Value>
        
        cell.content = contents.values[
            contents.index(contents.startIndex, offsetBy: indexPath.row)
        ]
        
        return cell
    }
    
    // MARK: UITableViewDelegate Conformance
    
    func tableView(
        _ tableView: UITableView,
        shouldHighlightRowAt indexPath: IndexPath
    ) -> Bool {
        false
    }
    
    func tableView(
        _ tableView: UITableView,
        willSelectRowAt indexPath: IndexPath
    ) -> IndexPath? {
        nil
    }

}

struct DiffableList_Previews: PreviewProvider {
    static var previews: some View {
        SimpleList(contents: [Text("Hello")])
    }
}
