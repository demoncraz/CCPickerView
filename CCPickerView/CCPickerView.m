//
//  CCPickerView.m
//  qtec_app
//
//  Created by demoncraz on 2018/9/19.
//  Copyright © 2018 Steve. All rights reserved.
//

#import "CCPickerView.h"

static NSString * const kPickerCollectionCell = @"kPickerCollectionCell";

static const CGFloat kStandardItemHeight = 33.0f;
static const CGFloat kMinimumLineSpacing = -2.0f;

@interface CCPickerViewCell: UICollectionViewCell

@property (nonatomic, strong) UIView    *view;
@property (nonatomic, strong) UILabel   *label;

@end


@implementation CCPickerViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *label = [[UILabel alloc] init];
        self.label = label;
        label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:label];
    }
    return self;
}

- (void)setView:(UIView *)view {
    if (_view && _view.superview) {
        [_view removeFromSuperview];
    }
    _view = view;
    view.frame = self.contentView.bounds;
    [self.contentView addSubview:view];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.label.frame = self.contentView.bounds;
    self.view.center = CGPointMake(self.contentView.bounds.size.width * 0.5, self.contentView.bounds.size.height * 0.5);
}

@end

@interface CCPickerViewFlowLayout: UICollectionViewFlowLayout

@property (nonatomic, assign) CCPickerViewFadeOutLevel fadeOutLevel;

@property (nonatomic, assign) NSUInteger maxDisplayingRows;

@property (nonatomic, assign) BOOL isSetup;

@end

@implementation CCPickerViewFlowLayout

- (instancetype)init {
    if (self = [super init]) {
        self.fadeOutLevel = CCPickerViewFadeOutLevelMiddle;
        self.maxDisplayingRows = 5;
    }
    return self;
}

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
    
    //计算跟中间行的行差
    NSUInteger rowDiff = floor(ABS(collectionCenter - normalizedCenter) / kStandardItemHeight);
    NSUInteger maxRowDiff = self.maxDisplayingRows / 2;
    
    CGFloat ratio = (maxDistance - distance) / maxDistance;
    
    CGFloat standardItemAlpha = 0.5;
    CGFloat standardItemScale = 0.5;
    switch (self.fadeOutLevel) {
        case CCPickerViewFadeOutLevelMiddle:
            break;
        case CCPickerViewFadeOutLevelMinimum:
            standardItemAlpha = 0.75;
            standardItemScale = 0.75;
            break;
        case CCPickerViewFadeOutLevelMax:
            standardItemAlpha = 0.25;
            standardItemScale = 0.25;
            break;
    }
    
    CGFloat alpha = ratio * (1 - standardItemAlpha) + standardItemAlpha;
    CGFloat scale = ratio * (1 - standardItemScale) + standardItemScale;
    
    if (rowDiff >= maxRowDiff) {
        alpha = 0.0;
        scale = 0.0;
    }
    
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


@interface CCPickerView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIView *indicatorView;

@property (nonatomic, strong) UISelectionFeedbackGenerator *feedbackGenerator;

@end

@implementation CCPickerView

- (UIView *)indicatorView {
    if (_indicatorView == nil) {
        _indicatorView = [[UIView alloc] init];
        _indicatorView.backgroundColor = [UIColor clearColor];
        _indicatorView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _indicatorView.layer.borderWidth = 0.5f;
        _indicatorView.userInteractionEnabled = NO;
    }
    return _indicatorView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        self.allowSelectionFeedback = YES;
        self.feedbackGenerator = [[UISelectionFeedbackGenerator alloc] init];
        [self.feedbackGenerator prepare];
    }
    return self;
}

- (void)setupUI {
    //默认选中颜色
    
    self.backgroundColor = [UIColor whiteColor];
    CCPickerViewFlowLayout *layout = [[CCPickerViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, kStandardItemHeight);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = kMinimumLineSpacing;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.bounces = NO;
    [_collectionView registerClass:[CCPickerViewCell class] forCellWithReuseIdentifier:kPickerCollectionCell];
    [self addSubview:_collectionView];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    self.collectionView.backgroundColor = backgroundColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.collectionView.frame = self.bounds;
    if (_showSelectionIndicator) {
        _indicatorView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width + 2, kStandardItemHeight + 1);
        _indicatorView.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
    }
}

#pragma mark - Public properties
- (void)setShowSelectionIndicator:(BOOL)showSelectionIndicator {
    _showSelectionIndicator = showSelectionIndicator;
    if (showSelectionIndicator) {
        [self addSubview:self.indicatorView];
    } else {
        [_indicatorView removeFromSuperview];
    }
}

- (void)setSelectedColor:(UIColor *)selectedColor {
    _selectedColor = selectedColor;
    [self.collectionView reloadData];
}

- (void)setSelectedFontSize:(NSUInteger)selectedFontSize {
    _selectedFontSize = selectedFontSize;
    [self.collectionView reloadData];
}

- (void)setFadeOutLevel:(CCPickerViewFadeOutLevel)fadeOutLevel {
    _fadeOutLevel = fadeOutLevel;
    CCPickerViewFlowLayout *layout = (CCPickerViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.fadeOutLevel = fadeOutLevel;
}

- (void)setMaxDisplayingRows:(NSUInteger)maxDisplayingRows {
    _maxDisplayingRows = maxDisplayingRows;
    NSAssert(maxDisplayingRows % 2 == 1 && maxDisplayingRows >= 3, @"Max displaying row number should be Odd and >= 3");
    CCPickerViewFlowLayout *layout = (CCPickerViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.maxDisplayingRows = maxDisplayingRows;
}

#pragma mark - Public functions
- (void)selectRow:(NSInteger)row animated:(BOOL)animated {
    [self.collectionView setContentOffset:CGPointMake(0, (kMinimumLineSpacing + kStandardItemHeight) * row) animated:animated];
    self.selectedIndex = row;
}


- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    if (self.delegate && [self.delegate respondsToSelector:@selector(pickerView:didSelectRow:)]) {
        [self.delegate pickerView:self didSelectRow:selectedIndex];
    }
    [self.collectionView reloadData];
    if (self.allowSelectionFeedback) {
        [self.feedbackGenerator selectionChanged];
    }
}


#pragma mark - UICollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfRowsInPickerView:)]) {
        return [self.dataSource numberOfRowsInPickerView:self];
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CCPickerViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPickerCollectionCell forIndexPath:indexPath];
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(pickerView:viewForRow:)]) {
        UIView *view = [self.dataSource pickerView:self viewForRow:indexPath.item];
        cell.view = view;
        return cell;
    } else {
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(pickerView:titleForRow:)]) {
            NSString *title = [self.dataSource pickerView:self titleForRow:indexPath.item];
            cell.label.text = title;
            UIColor *selectedColor = self.selectedColor ? : [UIColor colorWithRed:33.0 / 255.0 green:150.0 / 255.0 blue:243.0 / 255.0 alpha:1.0];
            if (indexPath.item == self.selectedIndex) {
                cell.label.textColor = selectedColor;
            } else {
                cell.label.textColor = [UIColor blackColor];
            }
            //            cell.label.textColor = indexPath.item == self.selectedIndex ? selectedColor : [UIColor blackColor];
            NSUInteger fontSize = self.selectedFontSize == 0 ? 25 : self.selectedFontSize;
            cell.label.font = [UIFont systemFontOfSize:fontSize];
        }
    }
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y <= 0) {
        self.selectedIndex = 0;
    }
    NSInteger total = [self.collectionView numberOfItemsInSection:0];
    if (scrollView.contentOffset.y >= (kStandardItemHeight + kMinimumLineSpacing) * (total - 1)) {
        self.selectedIndex = total - 1;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CCPickerViewFlowLayout *layout = (CCPickerViewFlowLayout *)self.collectionView.collectionViewLayout;
    
    CGFloat cardSize = layout.itemSize.height + layout.minimumLineSpacing;
    CGFloat offset = scrollView.contentOffset.y;
    
    NSInteger current = (NSInteger)(floor((offset - cardSize / 2) / cardSize) + 1);
    self.selectedIndex = current;
}

- (void)didMoveToSuperview {
    [self.collectionView setContentOffset:CGPointMake(0, (kStandardItemHeight + kMinimumLineSpacing) * self.selectedIndex) animated:NO];
}

@end

