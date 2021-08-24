//
//  BarDataSource.swift
//  winelist
//
//  Created by cosima on 2020/5/18.
//  Copyright © 2020 cosima. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Bar :NSManagedObject{
    @NSManaged var barName : String
    @NSManaged var baraddress : String
    @NSManaged var win :String
    @NSManaged var pick : Int64
    @NSManaged var imageName : String?
    @NSManaged var date : Date?
    @NSManaged var barID : String
    
    static func == (lhs: Bar, rhs: Bar) -> Bool {
        return lhs.barName == rhs.barName
    }
    
    override func awakeFromInsert() {
        self.barID = UUID().uuidString
    }
    
    func image() -> UIImage? {
        if let fileName = self.imageName{
            let homeURL = URL(fileURLWithPath: NSHomeDirectory())
            let documents = homeURL.appendingPathComponent("Documents")
            let fileURL = documents.appendingPathComponent(fileName)
            return UIImage(contentsOfFile: fileURL.path)
        }
        return nil
    }
    
    func thumbnailImage() -> UIImage?{
        if let image =  self.image() {

            let thumbnailSize = CGSize(width:50, height: 50)
            let scale = UIScreen.main.scale
            UIGraphicsBeginImageContextWithOptions(thumbnailSize,false,scale)
            let widthRatio = thumbnailSize.width / image.size.width
            let heightRadio = thumbnailSize.height / image.size.height
            let ratio = max(widthRatio,heightRadio)
            let imageSize = CGSize(width:image.size.width*ratio,height: image.size.height*ratio)
            
            
            let circlePath = UIBezierPath(ovalIn: CGRect(x: 0,y: 0,width: thumbnailSize.width,height: thumbnailSize.height))
            circlePath.addClip()
            
            image.draw(in:CGRect(x: -(imageSize.width-thumbnailSize.width)/2.0,y: -(imageSize.height-thumbnailSize.height)/2.0,width: imageSize.width,height: imageSize.height))
            
            image.draw(in:CGRect(x: -(imageSize.width-thumbnailSize.width)/2.0,y: -(imageSize.height-thumbnailSize.height)/2.0,width: imageSize.width,height: imageSize.height))
            
            let smallImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            return smallImage
        }else{
            return nil;
        }
    }
}
