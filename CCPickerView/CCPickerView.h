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

@optional
- (NSString *)pickerView:(CCPickerView *)pickerView titleForRow:(NSInteger)row;
- (UIView *)pickerView:(CCPickerView *)pickerView viewForRow:(NSInteger)row;   //if view is provided, titleForRow will be ignored.

@end

@protocol CCPickerViewDelegate <NSObject>

- (void)pickerView:(CCPickerView *)pickerView didSelectRow:(NSInteger)row;

@end

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CCPickerViewFadeOutLevel) {
    CCPickerViewFadeOutLevelMinimum,
    CCPickerViewFadeOutLevelMiddle,
    CCPickerViewFadeOutLevelMax,
};

@interface CCPickerView : UIView

@property (nonatomic, weak) id<CCPickerViewDataSource> dataSource;
@property (nonatomic, weak) id<CCPickerViewDelegate> delegate;

@property (nonatomic, assign) BOOL showSelectionIndicator;            //Shows a indicator box around the selected row, default is NO
@property (nonatomic, assign) BOOL allowSelectionFeedback;            //Defualt is True, there will be vibrate upon selection
@property (nonatomic, strong) UIColor *selectedColor;                 //Text color of the selected row, default is predifined BLUE
@property (nonatomic, assign) NSUInteger selectedFontSize;            //Font size of the selected row, default is 25
@property (nonatomic, assign) NSUInteger maxDisplayingRows;           //Max number of rows that can be displayed at the same time, should be a odd number, equal or larger than 3; Default is 5
@property (nonatomic, assign) CCPickerViewFadeOutLevel fadeOutLevel;  //The level of fade out effect, i.e. MAX means the unselected rows fades out faster. Default is CCPickerViewFadeOutLevelMiddle

@property (readonly, nonatomic, assign) NSInteger selectedIndex;      //The current selected index

/**
 Select a row with(out) animation

 @param row the desitination row
 @param animated if animated
 */
- (void)selectRow:(NSInteger)row animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
