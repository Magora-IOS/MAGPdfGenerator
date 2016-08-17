#import "MAGPdfRenderer.h"

// Models
#import "MAGDrawContext.h"

// Utils
#import "UIColor+MAGPdfGenerator.h"


static CGSize const _defaultPageSize = (CGSize){612, 792};
static UIEdgeInsets const _defaultPageInsets = (UIEdgeInsets){39, 45, 39, 55}; // Default printable frame = {45, 39, 512, 714}
static CGPoint const _defaultPageNumberPointToDraw = (CGPoint){580, 730};


@interface MAGPdfRenderer ()
@property (nonatomic, readwrite) MAGDrawContext *context;
@end


@implementation MAGPdfRenderer

#pragma mark - Public methods

- (NSURL *)drawView:(UIView *)view inPDFwithFileName:(NSString *)pdfName {
    self.context = [[MAGDrawContext alloc] initWithMainView:view noWrapViews:[self.delegate noWrapViewsForPdfRenderer:self]];
    
    NSURL *pdfURL = [self setupPDFDocumentNamed:pdfName];
    [self drawViewInPDF];
    [self finishPDF];
    
    return pdfURL;
}

+ (void)drawImage:(UIImage *)image inRect:(CGRect)rect {
    [image drawInRect:rect];
}

+ (void)drawText:(NSString *)textToDraw inFrame:(CGRect)frameRect {
    [self drawText:textToDraw inFrame:frameRect withAttributes:nil];
}

+ (void)drawText:(NSString *)textToDraw inFrame:(CGRect)frameRect withAttributes:(NSDictionary<NSString *, id> *)attrs {
    [textToDraw drawInRect:frameRect withAttributes:attrs];
}

#pragma mark - Auxiliaries

- (NSURL *)setupPDFDocumentNamed:(NSString *)pdfName {
    NSString *extendedPdfName = [pdfName stringByAppendingPathExtension:@"pdf"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths.firstObject;
    
    NSString *pdfPath = [documentsDirectory stringByAppendingPathComponent:extendedPdfName];
    UIGraphicsBeginPDFContextToFile(pdfPath, CGRectZero, nil);
    
    return [NSURL fileURLWithPath:pdfPath];
}

- (void)drawViewInPDF {
    [self.context.mainView setNeedsLayout];
    [self.context.mainView layoutIfNeeded];
    
    [self beginNewPDFPage];
    
    [self drawSubviewsOfView:self.context.mainView];
}

- (void)drawSubviewsOfView:(UIView *)view {
    NSArray *sortedSubviews = [MAGPdfRenderer viewsSortedByLowestY:view.subviews];
    for (UIView *subview in sortedSubviews) {
        [self colorViewIfNeeded:subview];
        [self drawView:subview];
    }
}

+ (NSArray<UIView *> *)viewsSortedByLowestY:(NSArray<UIView *> *)views {
    return [views sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        UIView *view1 = (UIView *)obj1;
        UIView *view2 = (UIView *)obj2;
        if (CGRectGetMaxY(view1.frame) < CGRectGetMaxY(view2.frame)) {
            return NSOrderedAscending;
        }
        else if (CGRectGetMaxY(view1.frame) > CGRectGetMaxY(view2.frame)) {
            return NSOrderedDescending;
        }
        else {
            return NSOrderedSame;
        }
    }];
}

// Fills the view by the color if it's not white or scroll view.
- (void)colorViewIfNeeded:(UIView *)view {
    if (!view.backgroundColor) {
        return;
    }
    
    static UIColor *whiteColor;
    if (!whiteColor) {
        whiteColor = [UIColor whiteColor];
    }
    BOOL notWhite = ![view.backgroundColor mag_isEqualToColor:whiteColor];
    BOOL notStrollView = ![view isKindOfClass:[UIScrollView class]];
    
    if (notWhite && notStrollView) {
        CGRect rectForFill = [self rectForDrawViewWithNewPageAllocationIfNeeded:view];
        [view.backgroundColor setFill];
        UIRectFill(rectForFill);
    }
}

- (void)drawView:(UIView *)view {
    [self checkNoWrapAndAllocateNewPageIfNeededForView:view];
    
    if ([view isKindOfClass:[UILabel class]]) {
        [self drawLabel:(UILabel *)view];
    }
    else if ([view isKindOfClass:[UIImageView class]]) {
        [self drawImageView:(UIImageView *)view];
    }
    else {
        [self drawSubviewsOfView:view];
    }
}

// Allocates new page if the view is included in "no wrap views" collection.
- (void)checkNoWrapAndAllocateNewPageIfNeededForView:(UIView *)view {
    if ([self.context.noWrapViews containsObject:view]) {
        [self allocateNewPageIfNeededForView:view];
    }
}

- (void)drawLabel:(UILabel *)label {
    NSDictionary<NSString *, id> *attributes = label.attributedText.length > 0 ? [label.attributedText attributesAtIndex:0 effectiveRange:nil] : nil;
    CGRect rectForDraw = [self rectForDrawViewWithNewPageAllocationIfNeeded:label];
    
    [MAGPdfRenderer drawText:label.text inFrame:rectForDraw withAttributes:attributes];
}

- (void)drawImageView:(UIImageView *)imageView {
    if ([NSStringFromClass([imageView.image class]) isEqualToString:@"_UIResizableImage"]) { // Ignore scroll bars of a scroll view
        return;
    }
    
    CGRect rectForDraw = [self rectForDrawViewWithNewPageAllocationIfNeeded:imageView];
    [MAGPdfRenderer drawImage:imageView.image inRect:rectForDraw];
}

- (void)drawPageNumber {
    NSString *pageNumber = @(self.context.currentPageNumber.integerValue + 1).stringValue;
    UIFont *font = [UIFont systemFontOfSize:12];
    NSDictionary *attributes = @{
            NSFontAttributeName: font,
        };
    [pageNumber drawAtPoint:_defaultPageNumberPointToDraw withAttributes:attributes];
}

- (CGRect)rectForDrawViewWithNewPageAllocationIfNeeded:(UIView *)view {
    [self allocateNewPageIfNeededForView:view];
    
    CGRect rectForDraw = [view convertRect:view.bounds toView:self.context.mainView];
    CGFloat topInset = self.context.currentPageNumber.integerValue == 0 ? 0 : _defaultPageInsets.top;
    rectForDraw.origin.y = rectForDraw.origin.y - self.context.currentPageTopY + topInset;
    
    return rectForDraw;
}

- (void)allocateNewPageIfNeededForView:(UIView *)view {
    CGRect viewFrameInMainView = [view convertRect:view.bounds toView:self.context.mainView];
    
    CGFloat topInset = self.context.currentPageNumber.integerValue == 0 ? 0 : _defaultPageInsets.top;
    CGFloat printableHeight = _defaultPageSize.height - topInset - _defaultPageInsets.bottom;
    
    CGFloat viewLowestY = viewFrameInMainView.origin.y + viewFrameInMainView.size.height;
    CGFloat overhead = viewLowestY - self.context.currentPageTopY - printableHeight;
    
    if (overhead > 0) {
        self.context.currentPageTopY = viewFrameInMainView.origin.y;
        [self beginNewPDFPage];
    }
}

- (void)beginNewPDFPage {
    if (!self.context.currentPageNumber) {
        self.context.currentPageNumber = @0;
    }
    else {
        self.context.currentPageNumber = @(self.context.currentPageNumber.integerValue + 1);
    }
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, _defaultPageSize.width, _defaultPageSize.height), nil);
    [self drawPageNumber];
}

- (void)finishPDF {
    UIGraphicsEndPDFContext();
    self.context = nil;
}

@end
