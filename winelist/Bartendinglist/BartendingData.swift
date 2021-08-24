//
//  BartendingData.swift
//  winelist
//
//  Created by cosima on 2020/6/1.
//  Copyright © 2020 cosima. All rights reserved.
//
import UIKit
import Foundation
import CoreData

class BartendingData: NSManagedObject{


    static func == (lhs: BartendingData, rhs: BartendingData) -> Bool {
        return lhs.barTendingWinName == rhs.barTendingWinName
    }
    @NSManaged var barTendingImage : String?
    @NSManaged var barTendingWinName : String
    @NSManaged var barTendingWinType : String?
    @NSManaged var dataWinList : String?
    @NSManaged var winIDD : String
    @NSManaged var baseWineArray :[String]?
    @NSManaged var princeImages:[UIImage]?
    
    override func awakeFromInsert(){
        self.winIDD = UUID().uuidString
    }
    
    func image() -> UIImage? {
    if let fileName = self.barTendingImage{
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
