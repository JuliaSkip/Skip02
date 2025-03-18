//
//  PostDetailsViewContr5oller.swift
//  Skip02
//
//  Created by Скіп Юлія Ярославівна on 18.03.2025.
//

import UIKit

class PostDetailsViewController: UIViewController {
    
    
    @IBOutlet weak var postDetails: PostView!
    
    func config(with post: DataFetcher.PostData){
        self.postDetails.config(result: post)
    }
}
