//
//  Created by Ireneusz Sołek
//  

import UIKit

extension UIView {
  func pinToSafeArea(of other: UIView, offsets: UIEdgeInsets = .zero, edges: UIRectEdge = .all) {
    self.translatesAutoresizingMaskIntoConstraints = false
    if edges.contains(.left) || edges.contains(.all) {
      let constraint = leadingAnchor.constraint(equalTo: other.safeAreaLayoutGuide.leadingAnchor)
      constraint.constant = offsets.left
      constraint.isActive = true
    }
    if edges.contains(.right) || edges.contains(.all) {
      let constraint = trailingAnchor.constraint(equalTo: other.safeAreaLayoutGuide.trailingAnchor)
      constraint.constant = offsets.right
      constraint.isActive = true
    }
    if edges.contains(.top) || edges.contains(.all) {
      let constraint = topAnchor.constraint(equalTo: other.safeAreaLayoutGuide.topAnchor)
      constraint.constant = offsets.top
      constraint.isActive = true
    }
    if edges.contains(.bottom) || edges.contains(.all) {
      let constraint = bottomAnchor.constraint(equalTo: other.safeAreaLayoutGuide.bottomAnchor)
      constraint.constant = offsets.bottom
      constraint.isActive = true
    }
  }
}
