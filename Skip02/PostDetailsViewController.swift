//
//  PostDetailsViewContr5oller.swift
//  Skip02
//
//  Created by Скіп Юлія Ярославівна on 18.03.2025.
//

import UIKit

class PostDetailsViewController: UIViewController {
    
    @IBOutlet weak var postView: PostView!
    
    func config(with post: DataFetcher.PostData){
        if let postView {
            postView.config(result: post)
            return
        }
    }
}
