//
//  Created by Ireneusz Sołek
//  

import UIKit
import SnapKit

class MovieDetailsViewController: UIViewController {
  struct Constants {
    static let spacing: CGFloat = 10
  }
  
  let movie: Movie
  let imageView: UIImageView = {
    let container = UIImageView()
    container.contentMode = .scaleAspectFill
    return container
  }()
  let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .boldSystemFont(ofSize: 16)
    return label
  }()
  let overviewLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 10
    return label
  }()
  let releaseDateLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 10)
    return label
  }()
  
  init(movie: Movie) {
    self.movie = movie
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    setupData()
  }
  
  lazy var detailsContainer: UIView = {
    let container = UIView()
    let color: UIColor = .systemBackground
    container.backgroundColor = color.withAlphaComponent(0.75)
    return container
  }()
  
  lazy var detailsStack: UIView = {
    let vStack = UIStackView(arrangedSubviews: [titleLabel, overviewLabel, releaseDateLabel])
    vStack.axis = .vertical
    vStack.spacing = Constants.spacing
    return vStack
  }()
  
  private func setupView() {
    view.addSubview(imageView)
    view.addSubview(detailsContainer)
    detailsContainer.addSubview(detailsStack)
    
    imageView.snp.makeConstraints { (make) in
      make.edges.equalTo(view.safeAreaLayoutGuide)
    }
    detailsStack.snp.makeConstraints { (make) in
      make.leading.trailing.top.bottom.equalToSuperview().inset(Constants.spacing)
    }
    detailsContainer.snp.makeConstraints { (make) in
      make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
    }
  }
  
  private func setupData() {
    titleLabel.text = movie.title
    overviewLabel.text = movie.overview
    if let releaseDate = movie.releaseDate {
      releaseDateLabel.text = dateFormatter.string(from: releaseDate)
    }
    imageView.sd_setImage(with: movie.imageUrl)
  }
  
  private var dateFormatter: DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = .current
    dateFormatter.setLocalizedDateFormatFromTemplate("dd MMM yyyy")
    return dateFormatter
  }
}
