#import <UIKit/UIKit.h>


@interface MAGDrawContext : NSObject

@property (nonatomic, readonly) UIView *mainView;
@property (nonatomic, readonly) NSSet<UIView *> *noWrapViews;
@property (nonatomic) NSNumber *currentPageNumber;
@property (nonatomic) CGFloat currentPageTopY;

@property (nonatomic) CGSize pageSize;
@property (nonatomic) UIEdgeInsets pageInsets;
@property (nonatomic) BOOL printPageNumbers;
@property (nonatomic) CGPoint pointToDrawPageNumber;
@property (nonatomic, copy) UIFont *pageNumberFont;

- (instancetype)initWithMainView:(UIView *)view noWrapViews:(NSArray<UIView *> *)noWrapViews;
- (instancetype)init NS_UNAVAILABLE;

@end
