//
//  FSCalendarWeekdayView.m
//  FSCalendar
//
//  Created by dingwenchao on 03/11/2016.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//

#import "FSCalendarWeekdayView.h"
#import "FSCalendar.h"
#import "FSCalendarDynamicHeader.h"
#import "FSCalendarExtensions.h"

@interface FSCalendarWeekdayItem : UIStackView

@property (weak  , nonatomic) FSCalendar *calendar;

- (UILabel *)label;
- (void)commonInit;
- (void) setButtonHidden:(BOOL)hidden;
- (void) setButtonTitle:(NSString *)title;
- (void) setButtonIndex:(NSInteger)index;
- (void)configureAppearance;

@end

@interface FSCalendarWeekdayView()

@property (strong, nonatomic) NSPointerArray *weekdayPointers;
@property (strong, nonatomic) NSArray<NSString *> *buttonTitles;
@property (weak  , nonatomic) UIView *contentView;
@property (weak  , nonatomic) FSCalendar *calendar;

- (void)commonInit;

@end

@implementation FSCalendarWeekdayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithButtonTitles:(NSArray<NSString *>*)buttonTitles frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.buttonTitles = buttonTitles;
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:contentView];
    _contentView = contentView;
    
    _weekdayPointers = [NSPointerArray weakObjectsPointerArray];
    
    for (int i = 0; i < 7; i++) {
        FSCalendarWeekdayItem *item = [[FSCalendarWeekdayItem alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:item];
        [_weekdayPointers addPointer:(__bridge void * _Nullable)(item)];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.contentView.frame = self.bounds;
    
    // Position Calculation
    NSInteger count = self.weekdayPointers.count;
    size_t size = sizeof(CGFloat)*count;
    CGFloat *widths = malloc(size);
    CGFloat contentWidth = self.contentView.fs_width;
    FSCalendarSliceCake(contentWidth, count, widths);
    
    BOOL opposite = NO;
    if (@available(iOS 9.0, *)) {
        UIUserInterfaceLayoutDirection direction = [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:self.calendar.semanticContentAttribute];
        opposite = (direction == UIUserInterfaceLayoutDirectionRightToLeft);
    }
    CGFloat x = 0;
    for (NSInteger i = 0; i < count; i++) {
        CGFloat width = widths[i];
        NSInteger labelIndex = opposite ? count-1-i : i;
        UILabel *label = [self.weekdayPointers pointerAtIndex:labelIndex];
        label.frame = CGRectMake(x, 0, width, self.contentView.fs_height);
        x = CGRectGetMaxX(label.frame);
    }
    free(widths);
}

- (void)setCalendar:(FSCalendar *)calendar
{
    _calendar = calendar;
    [self configureAppearance];
}

- (NSArray<UILabel *> *)weekdayLabels
{
    NSMutableArray *result = [NSMutableArray new];
    for (FSCalendarWeekdayItem *item in self.weekdayPointers.allObjects) {
        [result addObject:item];
    }
    return result;
}

- (void)configureAppearance
{
    BOOL useVeryShortWeekdaySymbols = (self.calendar.appearance.caseOptions & (15<<4) ) == FSCalendarCaseOptionsWeekdayUsesSingleUpperCase;
    NSArray *weekdaySymbols = useVeryShortWeekdaySymbols ? self.calendar.gregorian.veryShortStandaloneWeekdaySymbols : self.calendar.gregorian.shortStandaloneWeekdaySymbols;
    BOOL useDefaultWeekdayCase = (self.calendar.appearance.caseOptions & (15<<4) ) == FSCalendarCaseOptionsWeekdayUsesDefaultCase;
    
    for (NSInteger i = 0; i < self.weekdayPointers.count; i++) {
        NSInteger index = (i + self.calendar.firstWeekday-1) % 7;
        FSCalendarWeekdayItem *item = [self.weekdayPointers pointerAtIndex:i];
        item.calendar = self.calendar;
        item.label.font = self.calendar.appearance.weekdayFont;
        item.label.textColor = self.calendar.appearance.weekdayTextColor;
        item.label.text = useDefaultWeekdayCase ? weekdaySymbols[index] : [weekdaySymbols[index] uppercaseString];
        if (self.calendar.appearance.weekdayHeaderButtonAlwaysVisible) {
            [item setButtonHidden:FALSE];
        }
        else {
            [item setButtonHidden:self.buttonTitles.count != 7];
        }
        
        NSString *buttonTitle = [self.buttonTitles objectAtIndex:i];
        if (buttonTitle != nil) {
            [item setButtonTitle:buttonTitle];
        }
        [item setButtonIndex:i];
        [item configureAppearance];
    }
}

@end


NSInteger const FSCalendarWeekdayItemLabelTag = -99;
NSInteger const FSCalendarWeekdayItemButtonTag = -98;
NSInteger const FSCalendarWeekdayItemButtonContainerTag = -97;

@implementation FSCalendarWeekdayItem

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (UILabel *)label {
    return [self viewWithTag:FSCalendarWeekdayItemLabelTag];
}

- (FSCalendarWeekdayButton *)button {
    return [self viewWithTag:FSCalendarWeekdayItemButtonTag];
}

- (void)commonInit
{
    self.axis = UILayoutConstraintAxisVertical;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.tag = FSCalendarWeekdayItemLabelTag;
    label.textAlignment = NSTextAlignmentCenter;
    
    FSCalendarWeekdayButton *button = [[FSCalendarWeekdayButton alloc] initWithFrame:CGRectZero];
    [button setTitle:@"" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:11];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    button.backgroundColor = UIColor.blueColor;
    button.tag = FSCalendarWeekdayItemButtonTag;
    
    UIView *buttonContainer = [[UIView alloc] initWithFrame:CGRectZero];
    buttonContainer.tag = FSCalendarWeekdayItemButtonContainerTag;
    [buttonContainer addSubview:button];
    
    [self addArrangedSubview:buttonContainer];
    [self addArrangedSubview:label];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIButton *button = self.button;
    UIView *container = button.superview;
    CGFloat shortEdge = MIN(button.superview.frame.size.width, button.superview.frame.size.height);
    CGFloat buttonPadding = 2;
    CGFloat buttonSize = shortEdge - (buttonPadding * 2);
    CGRect buttonFrame = CGRectMake(0, 0, buttonSize, buttonSize);
    buttonFrame.origin.x = ((container.frame.size.width - buttonSize) / 2);
    buttonFrame.origin.y = ((container.frame.size.height - buttonSize) / 2);
    [button setFrame:buttonFrame];
    
    button.layer.cornerRadius = buttonSize / 2;
    
}

- (void) setButtonHidden:(BOOL)hidden
{
    [[self viewWithTag:FSCalendarWeekdayItemButtonContainerTag] setHidden:hidden];
}

- (void) setButtonTitle:(NSString *)title
{
    NSString *actualTitle = (title == nil || title.length == 0) ? self.calendar.appearance.weekdayHeaderButtonDisabledText : title;
    [self.button setTitle:actualTitle forState:UIControlStateNormal];
}

- (void) setButtonIndex:(NSInteger)index
{
    self.button.index = index;
}

- (void)configureAppearance {
    self.button.backgroundColor = self.calendar.appearance.weekdayHeaderButtonBackgroundColor;
    self.button.titleLabel.font = self.calendar.appearance.weekdayButtonFont;
    [self.button setTitleColor:self.calendar.appearance.weekdayHeaderButtonTitleColor forState:UIControlStateNormal];
    
    [self.button removeTarget:self.calendar action:nil forControlEvents:UIControlEventTouchUpInside];
    [self.button addTarget:self.calendar action:@selector(didTapWeekdayButton:) forControlEvents:UIControlEventTouchUpInside];
    
    BOOL isEnabled = [self.button titleForState:UIControlStateNormal].length > 0;
    if (isEnabled && self.calendar.appearance.weekdayHeaderButtonDisabledText != nil) {
        isEnabled = ![[self.button titleForState:UIControlStateNormal] isEqualToString:self.calendar.appearance.weekdayHeaderButtonDisabledText];
    }
    [self.button setEnabled:isEnabled];
    self.button.alpha = isEnabled ? 1 : self.calendar.appearance.weekdayHeaderButtonDisabledAlpha;
}

@end


@implementation FSCalendarWeekdayButton

@end
