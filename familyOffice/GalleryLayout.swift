//
//  GalleryLayout.swift
//  familyOffice
//
//  Created by Nan Montaño on 01/ago/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

protocol GalleryLayoutDelegate {
    
    func collectionView(collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:NSIndexPath,
                        withWidth:CGFloat) -> CGFloat
}

class GalleryLayout: UICollectionViewLayout {
    // This keeps a reference to the delegate.
    var delegate: GalleryLayoutDelegate!
    
    // These are two public properties for configuring the layout: the number of columns and the cell padding.
    var numberOfColumns = 3
    var cellPadding: CGFloat = 5.0
    
    // This is an array to cache the calculated attributes. When you call prepareLayout(), you’ll calculate the attributes for all
    // items and add them to the cache. When the collection view later requests the layout attributes, you can be efficient and
    // query the cache instead of recalculating them every time.
    private var cache = [UICollectionViewLayoutAttributes]()
    
    // This declares two properties to store the content size. contentHeight is incremented as photos are added, and contentWidth 
    // is calculated based on the collection view width and its content inset.
    private var contentHeight: CGFloat  = 0.0
    private var contentWidth: CGFloat {
        let insets = collectionView!.contentInset
        return collectionView!.bounds.width - (insets.left + insets.right)
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        // You only calculate the layout attributes if cache is empty.
        if cache.isEmpty {
            // This declares and fills the xOffset array with the x-coordinate for every column based on the column widths. 
            // The yOffset array tracks the y-position for every column. You initialize each value in yOffset to 0, since 
            // this is the offset of the first item in each column.
            let columnWidth = contentWidth / CGFloat(numberOfColumns)
            var xOffset = [CGFloat]()
            for column in 0 ..< numberOfColumns {
                xOffset.append(CGFloat(column) * columnWidth )
            }
            var column = 0
            var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
            
            // This loops through all the items in the first section, as this particular layout has only one section.
            for item in 0 ..< collectionView!.numberOfItems(inSection: 0) {
                
                let indexPath = NSIndexPath(item: item, section: 0)
                
                // This is where you perform the frame calculation. width is the previously calculated cellWidth, with the padding 
                // between cells removed. You ask the delegate for the height of the image and the annotation, and calculate the 
                // frame height based on those heights and the predefined cellPadding for the top and bottom. You then combine this
                // with the x and y offsets of the current column to create the insetFrame used by the attribute.
                let width = columnWidth - cellPadding * 2
                let photoHeight = delegate.collectionView(collectionView: collectionView!, heightForPhotoAtIndexPath: indexPath,
                                                          withWidth:width)
                let height = cellPadding +  photoHeight + cellPadding
                let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
                let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
                
                // This creates an instance of UICollectionViewLayoutAttribute, sets its frame using insetFrame and appends the
                // attributes to cache.
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath as IndexPath)
                attributes.frame = insetFrame
                cache.append(attributes)
                
                // This expands contentHeight to account for the frame of the newly calculated item. It then advances the yOffset 
                // for the current column based on the frame. Finally, it advances the column so that the next item will be placed 
                // in the next column.
                contentHeight = max(contentHeight, frame.maxY)
                yOffset[column] = yOffset[column] + height
                
                column = column >= (numberOfColumns - 1) ? 0 : (column+1)
            }
        }
    }
    
//    override func contentSize() -> CGSize {
//        return CGSize(width: contentWidth, height: contentHeight)
//    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
}
