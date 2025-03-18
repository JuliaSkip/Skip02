import UIKit

class PostView: UIView {
    
    struct Const {
        static let contentXibName = "PostView"
    }

    @IBOutlet private weak var postView: UIView!
    @IBOutlet private weak var postTitle: UILabel!
    @IBOutlet private weak var timePassed: UILabel!
    @IBOutlet private weak var domain: UILabel!
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet private weak var rating: UILabel!
    @IBOutlet private weak var commentsCount: UILabel!
    @IBOutlet private weak var postImage: UIImageView!
    @IBOutlet private weak var username: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
        
    func commonInit() {
        Bundle.main.loadNibNamed(Const.contentXibName, owner: self, options: nil)
        postView.fixInView(self)
    }
    
    func prepare(){
        self.postImage.image = nil
    }
    
    func config(result: DataFetcher.PostData) {
                        
        if let imageUrlString = result.imageUrl, let formattedUrl = URL(string: imageUrlString.replacingOccurrences(of: "&amp;", with: "&")) {
            self.postImage.kf.setImage(with: formattedUrl)
        }
            
        self.username.text = result.author
        self.timePassed.text = result.createdUTC
        self.domain.text = result.domain
        self.postTitle.text = result.title
        self.rating.text = String(result.ups + result.downs)
        self.commentsCount.text = String(result.numComments)
            
        let image = UIImage(systemName: result.saved ? "bookmark.fill" : "bookmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .bold))
        self.saveButton.setImage(image, for: .normal)
        self.saveButton.tintColor = .label
    }

}
extension UIView
{
    func fixInView(_ container: UIView!) -> Void{
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.frame = container.frame;
        container.addSubview(self);
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}
