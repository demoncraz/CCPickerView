//
//  CCPickerView.h
//  qtec_app
//
//  Created by demoncraz on 2018/9/19.
//  Copyright © 2018 Steve. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CCPickerView;

@protocol CCPickerViewDataSource <NSObject>

- (NSInteger)numberOfRowsInPickerView:(CCPickerView *)pickerView;
- (NSString *)pickerView:(CCPickerView *)pickerView titleForRow:(NSInteger)row;

@end

@protocol CCPickerViewDelegate <NSObject>

- (void)pickerView:(CCPickerView *)pickerView didSelectRow:(NSInteger)row;

@end

NS_ASSUME_NONNULL_BEGIN

@interface CCPickerView : UIView

@property (nonatomic, weak) id<CCPickerViewDataSource> dataSource;
@property (nonatomic, weak) id<CCPickerViewDelegate> delegate;

@property (nonatomic, assign) BOOL showSelectionIndicator;
@property (nonatomic, strong) UIColor *selectedColor;
@property (readonly, nonatomic, assign) NSInteger selectedIndex;

- (void)selectRow:(NSInteger)row animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
