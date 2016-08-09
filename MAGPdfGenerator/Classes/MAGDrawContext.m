#import "MAGDrawContext.h"


@implementation MAGDrawContext

#pragma mark - Initialization

- (instancetype)initWithMainView:(UIView *)view noWrapViews:(NSArray<UIView *> *)noWrapViews {
    self = [super init];
    if (self) {
        _mainView = view;
        _noWrapViews = [NSSet setWithArray:noWrapViews];
    }
    return self;
}

@end
