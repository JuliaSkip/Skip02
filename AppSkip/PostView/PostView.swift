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
    private var currentPost:DataFetcher.PostData?
    private let fileName = "posts.json"
    private let dataFetcher = DataFetcher()

    @IBOutlet weak var saveMarkView: SaveMarkView!
    
    @IBAction func saveButton(_ sender: UIButton) {
        handleSave()
    }
    
    func handleSave () {
        guard var post = self.currentPost else { return }
        
        var loadedPosts = dataFetcher.loadPosts()
        
        if let index = loadedPosts.firstIndex(where: { $0 == post }) {
            loadedPosts.remove(at: index)
            post.isSaved = false
        } else {
            post.isSaved = true
            loadedPosts.append(post)
        }
                
        do {
            let data = try JSONEncoder().encode(loadedPosts)
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
                try data.write(to: fileURL)
            
            let image = UIImage(systemName: post.isSaved ? "bookmark.fill" : "bookmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .bold))
            self.saveButton.setImage(image, for: .normal)
            self.saveButton.tintColor = .label
            
            NotificationCenter.default.post(name: NSNotification.Name("PostUpdated"), object: nil, userInfo: ["post": post])

        } catch {
            print("Error saving JSON: \(error)")
        }
    }
    
    @IBAction func shareButton(_ sender: UIButton) {
        guard let viewController = self.findViewController() else { return }
        guard let post = self.currentPost else { return }
        let activityVC = UIActivityViewController(activityItems: [post.url], applicationActivities: nil)
        viewController.present(activityVC, animated: true, completion: nil)
    }
    
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
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        tapRecognizer.numberOfTapsRequired = 2
        self.postImage.isUserInteractionEnabled = true
        self.postImage.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func doubleTap() {
        handleSave()
        self.saveMarkView.isHidden = false
        self.saveMarkView.alpha = 1
        
        UIView.animate(withDuration: 1, animations: {
            self.saveMarkView.alpha = 0
        }) { done in
            if done {
                self.saveMarkView.isHidden = true
            }
        }
    }
    
    func prepare(){
        self.postImage.image = nil
    }
    
    func config(result: DataFetcher.PostData) {
        
        self.saveMarkView.isHidden = true
        self.currentPost = result
                        
        if let imageUrlString = result.imageUrl, let formattedUrl = URL(string: imageUrlString.replacingOccurrences(of: "&amp;", with: "&")) {
            self.postImage.kf.setImage(with: formattedUrl)
        }
            
        self.username.text = result.author
        self.timePassed.text = result.createdUTC
        self.domain.text = result.domain
        self.postTitle.text = result.title
        self.rating.text = String(result.ups + result.downs)
        self.commentsCount.text = String(result.numComments)
            
        let image = UIImage(systemName: result.isSaved ? "bookmark.fill" : "bookmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .bold))
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
extension UIView {
    func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
}
