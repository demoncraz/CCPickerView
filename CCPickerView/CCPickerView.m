//
//  CCPickerView.m
//  qtec_app
//
//  Created by demoncraz on 2018/9/19.
//  Copyright © 2018 Steve. All rights reserved.
//

#import "CCPickerView.h"
#import "CCPickerViewFlowLayout.h"

static NSString * const kPickerCollectionCell = @"kPickerCollectionCell";

static const CGFloat kStandardItemHeight = 33.0f;
static const CGFloat kMinimumLineSpacing = -2.0f;

@interface CCPickerViewCell: UICollectionViewCell

@property (nonatomic, strong) UILabel *label;

@end
@implementation CCPickerViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *label = [[UILabel alloc] init];
        self.label = label;
        label.font = [UIFont systemFontOfSize:23];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:label];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.label.frame = self.contentView.bounds;
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
    [_collectionView registerClass:[CCPickerViewCell class] forCellWithReuseIdentifier:kPickerCollectionCell];
    [self addSubview:_collectionView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.collectionView.frame = self.bounds;
    if (_showSelectionIndicator) {
        _indicatorView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width + 2, 34);
        _indicatorView.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
    }
}

#pragma mark - Public property
- (void)setShowSelectionIndicator:(BOOL)showSelectionIndicator {
    _showSelectionIndicator = showSelectionIndicator;
    if (showSelectionIndicator) {
        [self addSubview:self.indicatorView];
    } else {
        [_indicatorView removeFromSuperview];
    }
}

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
    [self.feedbackGenerator selectionChanged];
}

- (void)setSelectedColor:(UIColor *)selectedColor {
    _selectedColor = selectedColor;
    [self.collectionView reloadData];
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
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(pickerView:titleForRow:)]) {
        NSString *title = [self.dataSource pickerView:self titleForRow:indexPath.item];
        cell.label.text = title;
        UIColor *selectedColor = self.selectedColor ? : [UIColor colorWithRed:33.0 / 255.0 green:150.0 / 255.0 blue:243.0 / 255.0 alpha:1.0];
        cell.label.textColor = indexPath.item == self.selectedIndex ? selectedColor : [UIColor blackColor];
    }
    
    return cell;
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
