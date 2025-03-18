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
    
    @IBOutlet weak var postTable: UITableView!
    
    private var posts:[DataFetcher.PostData] = []
    private var lastSelectedPost:DataFetcher.PostData?
    private var after: String?
    private var isFetchingData = false
    private let portionSize: Int = 20
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
    }
    
    func fetchData(){
        guard !isFetchingData else { return }
        isFetchingData = true
        let dataFetcher = DataFetcher()
        Task {
            if let result = await dataFetcher.fetchPosts(subreddit:"ios", limit: self.portionSize, after: self.after){
                self.posts.append(contentsOf: result)
                self.after = result.last?.after
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
