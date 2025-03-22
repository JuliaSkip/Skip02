//
//  PostListViewController.swift
//  Skip02
//
//  Created by Скіп Юлія Ярославівна on 15.03.2025.
//

import Foundation
import UIKit

class PostListViewController: UIViewController {
    
    struct Const {
        static let cellReuseIdentifier = "post_cell"
        static let goToPostDetailsIdentifier = "go_to_post_details"
    }
    
    @IBOutlet private weak var postTable: UITableView!
    @IBOutlet private weak var subreddit: UILabel!
    
    private var posts:[DataFetcher.PostData] = []
    private var lastSelectedPost:DataFetcher.PostData?
    private var after: String?
    private var isFetchingData = false
    private let portionSize: Int = 20
    private let subRedditText = "ios"
    private let dataFetcher = DataFetcher()

        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updateSavedPost(_:)), name: NSNotification.Name("PostUpdated"), object: nil)

        fetchData()
        subreddit.text = "/r/\(subRedditText)"
    }
    
    @objc
    func updateSavedPost(_ notification: Notification) {
        guard let updatedPost = notification.userInfo?["post"] as? DataFetcher.PostData else { return }
        
        if let index = posts.firstIndex(where: { $0.url == updatedPost.url }) {
            posts[index].isSaved = updatedPost.isSaved
            postTable.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }

    
    func fetchData(){
        guard !isFetchingData else { return }
        isFetchingData = true
        let loadedPosts = dataFetcher.loadPosts()
        
        Task {
            if let result = await dataFetcher.fetchPosts(subreddit:subRedditText, limit: self.portionSize, after: self.after){
                let resultToSave = result.map { post -> DataFetcher.PostData in
                    let isAlreadySaved = loadedPosts.contains { $0 == post }
                    return DataFetcher.PostData(
                        author: post.author,
                        title: post.title,
                        numComments: post.numComments,
                        ups: post.ups,
                        downs: post.downs,
                        createdUTC: post.createdUTC,
                        imageUrl: post.imageUrl,
                        domain: post.domain,
                        isSaved: isAlreadySaved,
                        after: post.after,
                        url: post.url
                    )
                }
                
                self.posts.append(contentsOf: resultToSave)
                self.after = resultToSave.last?.after
                self.postTable.reloadData()
            }
            
            self.isFetchingData = false
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier{
        case Const.goToPostDetailsIdentifier:
            let nextVC = segue.destination as! PostDetailsViewController
            DispatchQueue.main.async {
                nextVC.config(with: self.lastSelectedPost!)
            }
        default: break
        }
    }
}


extension PostListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Const.cellReuseIdentifier, for: indexPath) as! PostCell
        let currentPost = self.posts[indexPath.row]
        cell.config(with: currentPost)
        
        return cell
    }
    
}

extension PostListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.lastSelectedPost = self.posts[indexPath.row]
        self.performSegue(withIdentifier: Const.goToPostDetailsIdentifier, sender: nil)
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard self.after != nil else { return }
        let offset = scrollView.contentOffset.y
        let frameHeight = scrollView.frame.size.height
        let contentSize = scrollView.contentSize.height - 1500
        let bottom = offset + frameHeight
        
        if bottom >= contentSize {
            fetchData()
        }
    }
}
