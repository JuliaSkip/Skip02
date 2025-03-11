import UIKit
import Kingfisher


class DataFetcher {
    
    private struct Parameters {
        private var parameters: [String: String] = [:]
        
        mutating func add(key: String, value: String) {
            parameters[key] = value
        }
        
        func getParams() -> String {
            guard !parameters.isEmpty else { return "" }
            return parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        }
    }
    
    struct RedditResponse: Decodable {
        let data: RedditDataList
    }
    struct RedditDataList: Decodable {
        let children: [RedditChildren]
    }
    struct RedditChildren: Decodable {
        let data: RedditData
    }
    struct RedditData: Decodable {
        let author_fullname: String
        let title: String
        let preview: Preview?
        let num_comments: Int
        let ups: Int
        let downs: Int
        let created_utc: Double
        let domain: String
    }
    struct Preview: Decodable {
        let images: [Image]
    }
    struct Image: Decodable {
        let source: ImageSource
    }
    struct ImageSource: Decodable {
        let url: String?
    }
    
    private func fetchUrl(from: String, params: Parameters) async throws -> RedditData? {
        let fullUrl = from + "?" + params.getParams()
        
        guard let url = URL(string: fullUrl) else { return nil }
        
        let (data, _) = try await URLSession.shared.data(from: url)
    
        let decodedResponse = try JSONDecoder().decode(RedditResponse.self, from: data)
        
        guard let firstPost = decodedResponse.data.children.first?.data else { return nil }
        
        return firstPost
    }

    func getPost(subreddit: String, limit: Int, after: String?) async throws -> RedditData? {
        var parameters = Parameters()
        parameters.add(key: "limit", value: "\(limit)")
        parameters.add(key: "subreddit", value: subreddit)
        if let after = after {
            parameters.add(key: "after", value: after)
        }
        
        let urlString = "https://www.reddit.com/r/\(subreddit)/top.json"
        
        return try await fetchUrl(from: urlString, params: parameters)
    }
}

class PostViewController: UIViewController {
    
    @IBOutlet weak private var username: UILabel!
    @IBOutlet weak private var timePassed: UILabel!
    @IBOutlet weak private var domain: UILabel!
    @IBOutlet weak private var postTitle: UILabel!
    @IBOutlet weak private var rating: UILabel!
    @IBOutlet weak private var commentsCount: UILabel!
    @IBOutlet weak private var postImage: UIImageView!
    @IBOutlet weak private var bookmark: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            guard let result = await fetchPost() else {
                print("Помилка: не вдалося отримати пост")
                return
            }
            let formattedDate = formatDate(result.createdUTC)
            
            if let imageUrlString = result.imageUrl, let formattedUrl = URL(string: imageUrlString.replacingOccurrences(of: "&amp;", with: "&")) {
                postImage.kf.setImage(with: formattedUrl)
            } else {
               print("Image not found")
            }
            
            username.text = result.author
            timePassed.text = formattedDate
            domain.text = result.domain
            postTitle.text = result.title
            rating.text = String(result.ups + result.downs)
            commentsCount.text = String(result.numComments)
            
            let image = UIImage(systemName: result.saved ? "bookmark.fill" : "bookmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .bold))

            bookmark.setImage(image, for: .normal)
            bookmark.tintColor = .label
            
        }
    }

    func fetchPost() async -> (author: String, title: String, numComments: Int, ups: Int, downs: Int, createdUTC: Double, imageUrl: String?, domain:String, saved:Bool)? {
        let dataFetcher = DataFetcher()
        
        do {
            if let post = try await dataFetcher.getPost(subreddit: "ios", limit: 1, after: nil) {
                let imageUrl = post.preview?.images.first?.source.url
                
                return (
                    author: post.author_fullname,
                    title: post.title,
                    numComments: post.num_comments,
                    ups: post.ups,
                    downs: post.downs,
                    createdUTC: post.created_utc,
                    imageUrl: imageUrl,
                    domain: post.domain,
                    saved: Bool.random()
                )
            }
        } catch {
            print("Failed to fetch data: \(error)")
        }
        
        return nil
    }
    
    
    func formatDate(_ date: Double) -> String {
        
        let timePassed = Date().timeIntervalSince(Date(timeIntervalSince1970: date))
        
        let days = Int(timePassed) / 86400
        let hours = (Int(timePassed) % 86400) / 3600
        let minutes = (Int(timePassed) % 3600) / 60
        
        if(days > 0){
            return "\(days) d"
        }else if(hours > 0){
            return "\(hours) h"
        }else if (minutes > 0){
            return "\(minutes) m"
        }else{
            return "now"
        }
    }

}
