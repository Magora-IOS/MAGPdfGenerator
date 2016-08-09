#import "UIView+MAGPdfGenerator.h"


@implementation UIView (MAGPdfGenerator)

- (CGFloat)lowestY {
    return self.frame.origin.y + self.frame.size.height;
}

@end
