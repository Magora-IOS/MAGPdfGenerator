#import <UIKit/UIKit.h>


@interface MAGDrawContext : NSObject

@property (nonatomic, readonly) UIView *mainView;
@property (nonatomic, readonly) NSSet<UIView *> *noWrapViews;
@property (nonatomic) NSNumber *currentPageNumber;
@property (nonatomic) CGFloat currentPageTopY;

- (instancetype)initWithMainView:(UIView *)view noWrapViews:(NSArray<UIView *> *)noWrapViews;
- (instancetype)init NS_UNAVAILABLE;

@end
