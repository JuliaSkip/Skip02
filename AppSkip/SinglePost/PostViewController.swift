import UIKit
import Kingfisher

class PostViewController: UIViewController {
    
    @IBOutlet private weak var username: UILabel!
    @IBOutlet private weak var timePassed: UILabel!
    @IBOutlet private weak var domain: UILabel!
    @IBOutlet private weak var postTitle: UILabel!
    @IBOutlet private weak var rating: UILabel!
    @IBOutlet private weak var commentsCount: UILabel!
    @IBOutlet private weak var postImage: UIImageView!
    @IBOutlet private weak var bookmark: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            
            let dataFetcher = DataFetcher()
            guard let result = await dataFetcher.fetchPosts(subreddit:"ios", limit: 1, after: "t2_cnxc35oj") else {
                print("Помилка: не вдалося отримати пост")
                return
            }
            
            configurePost(result: result[0])
            
        }
    }
    
    func configurePost(result: DataFetcher.PostData) {
                        
            if let imageUrlString = result.imageUrl, let formattedUrl = URL(string: imageUrlString.replacingOccurrences(of: "&amp;", with: "&")) {
                postImage.kf.setImage(with: formattedUrl)
            } else {
                print("Image not found")
            }
            
            username.text = result.author
        timePassed.text = result.createdUTC
            domain.text = result.domain
            postTitle.text = result.title
            rating.text = String(result.ups + result.downs)
            commentsCount.text = String(result.numComments)
            
            let image = UIImage(systemName: result.isSaved ? "bookmark.fill" : "bookmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .bold))
            bookmark.setImage(image, for: .normal)
            bookmark.tintColor = .label
    }

}
