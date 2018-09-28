# CCPickerView
A customizable picker view just like UIPickerView

<p align="center"><img src ="https://github.com/demoncraz/CCPickerView/blob/master/demo.gif" width="300" /></p>

```objective-c
@property (nonatomic, assign) BOOL showSelectionIndicator;            //Shows a indicator box around the selected row, default is NO
@property (nonatomic, assign) BOOL allowSelectionFeedback;            //Defualt is True, there will be vibrate upon selection
@property (nonatomic, strong) UIColor *selectedColor;                 //Text color of the selected row, default is predifined BLUE
@property (nonatomic, assign) NSUInteger selectedFontSize;            //Font size of the selected row, default is 25
@property (nonatomic, assign) NSUInteger maxDisplayingRows;           //Max number of rows that can be displayed at the same time, should be a odd number, equal or larger than 3; Default is 5
@property (nonatomic, assign) CCPickerViewFadeOutLevel fadeOutLevel;  //The level of fade out effect, i.e. MAX means the unselected rows fades out faster. Default is CCPickerViewFadeOutLevelMiddle

@property (readonly, nonatomic, assign) NSInteger selectedIndex;      //The current selected index
```
