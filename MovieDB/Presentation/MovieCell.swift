//
//  Created by Ireneusz Sołek
//  

import UIKit
import SnapKit
import SDWebImage

struct MovieCellConfiguration {
  let title: String
  let imageURL: URL?
}

class MovieCell: UITableViewCell {
  struct Constants {
    static let spacing: CGFloat = 10
    static let imageSize: CGFloat = 50
  }
  let titleLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    return label
  }()
  let imageContainer: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupView() {
    let vStack = UIStackView()
    vStack.spacing = Constants.spacing
    imageContainer.snp.makeConstraints { (make) in
      make.width.equalTo(Constants.imageSize)
      make.height.equalTo(Constants.imageSize)
    }
    vStack.addArrangedSubview(imageContainer)
    vStack.addArrangedSubview(titleLabel)
    contentView.addSubview(vStack)
    vStack.snp.makeConstraints { (make) in
      make.edges.equalToSuperview().inset(Constants.spacing)
    }
  }
  
  func configure(with configuration: MovieCellConfiguration) {
    titleLabel.text = configuration.title
    imageContainer.sd_setImage(with: configuration.imageURL, placeholderImage: UIImage(systemName: "photo"))
  }
}
