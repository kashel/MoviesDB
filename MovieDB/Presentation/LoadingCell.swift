//
//  Created by Ireneusz Sołek
//  

import UIKit
import SnapKit

class LoadingCell: UITableViewCell {
  
  public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupView() {
    let activityIndicator = UIActivityIndicatorView()
    addSubview(activityIndicator)
    activityIndicator.snp.makeConstraints { (make) in
      make.center.equalToSuperview()
    }
    activityIndicator.startAnimating()
  }
}
