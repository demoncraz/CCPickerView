//
//  CCPickerViewFlowLayout.m
//  qtec_app
//
//  Created by demoncraz on 2018/9/19.
//  Copyright © 2018 Steve. All rights reserved.
//

#import "CCPickerViewFlowLayout.h"

static const CGFloat standardItemAlpha = 0.5;
static const CGFloat standardItemScale = 0.5;

@interface CCPickerViewFlowLayout ()

@property (nonatomic, assign) BOOL isSetup;

@end

@implementation CCPickerViewFlowLayout

- (void)prepareLayout {
    [super prepareLayout];
    if (self.isSetup == NO) {
        [self setupCollectionView];
        self.isSetup = YES;
    }
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray<UICollectionViewLayoutAttributes *> *attributes = [super layoutAttributesForElementsInRect:rect];
    
    NSMutableArray<UICollectionViewLayoutAttributes *> *attributesCopy = [NSMutableArray array];
    
    for (UICollectionViewLayoutAttributes *itemAttributes in attributes) {
        UICollectionViewLayoutAttributes *itemAttributesCopy = [itemAttributes copy];
        [self changeLayoutAttributes:itemAttributesCopy];
        [attributesCopy addObject:itemAttributesCopy];
    }
    return attributesCopy;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (void)changeLayoutAttributes:(UICollectionViewLayoutAttributes *)attributes {
    CGFloat collectionCenter = self.collectionView.frame.size.height * 0.5;
    CGFloat offset = self.collectionView.contentOffset.y;
    CGFloat normalizedCenter = attributes.center.y - offset;
    
    CGFloat maxDistance = 2 * (self.itemSize.height + self.minimumLineSpacing);
    CGFloat distance = MIN(ABS(collectionCenter - normalizedCenter), maxDistance);
    CGFloat ratio = (maxDistance - distance) / maxDistance;
    
    CGFloat alpha = ratio * (1 - standardItemAlpha) + standardItemAlpha;
    CGFloat scale = ratio * (1 - standardItemScale) + standardItemScale;
    attributes.alpha = alpha;

    attributes.transform3D = CATransform3DScale(CATransform3DIdentity, scale, scale, 1);
    
    attributes.zIndex = (NSInteger)alpha * 10;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    NSArray *layoutAttributes = [self layoutAttributesForElementsInRect:self.collectionView.bounds];
    CGFloat center = self.collectionView.bounds.size.height * 0.5;
    CGFloat proposedConetentOffsetCenterOrigin = proposedContentOffset.y + center;
    NSArray *sorted = [layoutAttributes sortedArrayUsingComparator:^NSComparisonResult(UICollectionViewLayoutAttributes * _Nonnull obj1, UICollectionViewLayoutAttributes *  _Nonnull obj2) {
        if (ABS(obj1.center.y - proposedConetentOffsetCenterOrigin) <= ABS(obj2.center.y - proposedConetentOffsetCenterOrigin)) {
            return NSOrderedAscending;
        }
        return NSOrderedDescending;
    }];
    UICollectionViewLayoutAttributes * closest = sorted.firstObject ? : [[UICollectionViewLayoutAttributes alloc] init];
    CGPoint targetContentOffset = CGPointMake(proposedContentOffset.x, floor(closest.center.y - center));
    return targetContentOffset;
}

- (void)setupCollectionView {
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    CGSize collectionSize = self.collectionView.bounds.size;
    CGFloat yInset = (collectionSize.height - self.itemSize.height) * 0.5;
    CGFloat xInset = (collectionSize.width - self.itemSize.width) * 0.5;
    self.sectionInset = UIEdgeInsetsMake(yInset, xInset, yInset, xInset);
}

@end
