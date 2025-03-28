//
//  SaveMarkView.swift
//  AppSkip
//
//  Created by Скіп Юлія Ярославівна on 28.03.2025.
//

import UIKit

class SaveMarkView: UIView {
    
    let kCONTENT_XIB_NAME = "SaveMarkView"
    @IBOutlet var saveMarkView: UIView!
    
    override func draw(_ rect: CGRect) {

        let width: CGFloat = 50
        let height: CGFloat = 60
        
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: saveMarkView.frame.midX - width,
                              y: saveMarkView.frame.midY - height))
        path.addLine(to: CGPoint(x: saveMarkView.frame.midX - width,
                                 y: saveMarkView.frame.midY + height))
        path.addLine(to: CGPoint(x: saveMarkView.frame.midX,
                                 y: saveMarkView.frame.midY + height/2))
        path.addLine(to: CGPoint(x: saveMarkView.frame.midX + width - 2,
                                 y: saveMarkView.frame.midY - height))
        path.close()
        
        let path2 = UIBezierPath()
        
        path2.move(to: CGPoint(x: saveMarkView.frame.midX + width,
                              y: saveMarkView.frame.midY - height + 5))
        path2.addLine(to: CGPoint(x: saveMarkView.frame.midX + width,
                                 y: saveMarkView.frame.midY + height ))
        path2.addLine(to: CGPoint(x: saveMarkView.frame.midX,
                                 y: saveMarkView.frame.midY + height/2))
        path2.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.fillColor = UIColor.black.cgColor
        shapeLayer.lineWidth = 5
        
        let shapeLayer2 = CAShapeLayer()
        shapeLayer2.path = path2.cgPath
        shapeLayer2.strokeColor = UIColor.black.cgColor
        shapeLayer2.fillColor = UIColor.black.cgColor
        shapeLayer2.lineWidth = 5
        
        
        saveMarkView.layer.addSublayer(shapeLayer)
        saveMarkView.layer.addSublayer(shapeLayer2)

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
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        saveMarkView.fixInView(self)
    }
}
