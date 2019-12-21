//
//  LifecycleEvents.swift
//  Stocks
//
//  Created by Bradley Hilton on 9/18/19.
//  Copyright © 2019 Brad Hilton. All rights reserved.
//

import SwiftUI

class LifecycleEventsController<Content : View> : UIHostingController<Content> {
    
    var didMoveToParent: (_ controller: UIViewController, _ parent: UIViewController?) -> () = { _, _ in }
    
    override func didMove(toParent parent: UIViewController?) {
        didMoveToParent(self, parent)
    }
    
}

struct LifecycleEvents<Content : View>: UIViewControllerRepresentable {
    
    let content: Content
    let didMoveToParent: (_ controller: UIViewController, _ parent: UIViewController?) -> ()
    
    init(content: Content, didMoveToParent: @escaping (_ controller: UIViewController, _ parent: UIViewController?) -> () = { _, _ in }) {
        self.content = content
        self.didMoveToParent = didMoveToParent
    }
    
    func makeUIViewController(context: Context) -> LifecycleEventsController<Content?> {
        LifecycleEventsController(rootView: content)
    }
    
    func updateUIViewController(_ controller: LifecycleEventsController<Content?>, context: Context) {
        controller.rootView = content
        controller.didMoveToParent = didMoveToParent
    }
    
}

extension View {
    
    func didMoveToParent(_ handler: @escaping (_ controller: UIViewController, _ parent: UIViewController?) -> ()) -> LifecycleEvents<Self> {
        LifecycleEvents(content: self, didMoveToParent: handler)
    }
    
}

struct HostingController_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Text("Hello").didMoveToParent { (controller, parent) in
                print(controller.navigationController?.viewControllers[0] as Any)
            }
        }
    }
}
