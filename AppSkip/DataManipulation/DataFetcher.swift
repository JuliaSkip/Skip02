//
//  DataFetcher.swift
//  Skip02
//
//  Created by Скіп Юлія Ярославівна on 15.03.2025.
//

import Kingfisher
import Foundation

class DataFetcher {
    
    private let fileName = "posts.json"
    
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
        let after: String?
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
        let permalink: String
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
    
    private func fetchUrl(from: String, params: Parameters) async throws -> (posts: [RedditData?], after: String?){
        let fullUrl = from + "?" + params.getParams()
        guard let url = URL(string: fullUrl) else { return ([], nil)}
        let (data, _) = try await URLSession.shared.data(from: url)
        let decodedResponse = try JSONDecoder().decode(RedditResponse.self, from: data)
        let posts = decodedResponse.data.children.map { $0.data }
        return (posts, decodedResponse.data.after)
    }

    func getPost(subreddit: String, limit: Int, after: String?) async throws -> (posts: [RedditData?], after: String?) {
        var parameters = Parameters()
        parameters.add(key: "limit", value: "\(limit)")
        if let after = after {
            parameters.add(key: "after", value: after)
        }
        let urlString = "https://www.reddit.com/r/\(subreddit)/top.json"
        
        return try await fetchUrl(from: urlString, params: parameters)
    }
    
    struct PostData:Codable, Equatable{
      let author: String
      let title: String
      let numComments: Int
      let ups: Int
      let downs: Int
      let createdUTC: String
      let imageUrl: String?
      let domain: String
      var isSaved: Bool
      let after: String?
      let url: String
        
        static func == (lhs: PostData, rhs: PostData) -> Bool {
            lhs.url == rhs.url
        }
    }
    
    
    
    func fetchPosts(subreddit:String, limit: Int, after: String?) async -> [PostData]? {
        
        do {
            let (result, afterToken) = try await getPost(subreddit: subreddit, limit: limit, after: after)
            
            let posts = result
            
            let filteredPosts = posts.compactMap { post -> PostData? in
                guard let post = post else { return nil }
                let formattedDate = formatDate(post.created_utc)
                
                let imageUrl = post.preview?.images.first?.source.url
                return PostData (
                    author: post.author_fullname,
                    title: post.title,
                    numComments: post.num_comments,
                    ups: post.ups,
                    downs: post.downs,
                    createdUTC: formattedDate,
                    imageUrl: imageUrl,
                    domain: post.domain,
                    isSaved: false,
                    after: afterToken,
                    url: "https://www.reddit.com" + post.permalink
                )
            }
            
            return filteredPosts
            
        } catch {
            print("Failed to fetch data: \(error)")
        }
        
        return nil
    }
    
    func loadPosts() -> [DataFetcher.PostData] {
        guard let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName),
        let data = try? Data(contentsOf: filePath) else { return [] }
            
        do {
            return try JSONDecoder().decode([DataFetcher.PostData].self, from: data)
        } catch {
            print("Error decoding JSON: \(error)")
            return []
        }
    }
    
    
    
    private func formatDate(_ date: Double) -> String {
        
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
