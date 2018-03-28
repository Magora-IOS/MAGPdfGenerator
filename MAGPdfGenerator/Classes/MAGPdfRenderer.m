#import "MAGPdfRenderer.h"

// Models
#import "MAGDrawContext.h"

// Utils
#import "UIColor+MAGPdfGenerator.h"

//default page size should not include margin area.  100 pixels resevered for left/right margins
static CGSize const _defaultPageSize = (CGSize){512, 792};
static UIEdgeInsets const _defaultPageInsets = (UIEdgeInsets){39, 45, 39, 55}; // Default printable frame = {45, 39, 512, 714}
static CGPoint const _defaultPointToDrawPageNumber = (CGPoint){580, 730};
static CGFloat const _defaultPageNumberFontSize = 12;


@interface MAGPdfRenderer ()
@property (nonatomic) MAGDrawContext *context;
@end


@implementation MAGPdfRenderer

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _pageSize = _defaultPageSize;
        _pageInsets = _defaultPageInsets;
        _printPageNumbers = NO;
        _pointToDrawPageNumber = _defaultPointToDrawPageNumber;
        _pageNumberFont = [UIFont systemFontOfSize:_defaultPageNumberFontSize];
    }
    return self;
}

#pragma mark - Public methods

- (NSURL *)drawView:(UIView *)view inPDFwithFileName:(NSString *)pdfName {
    @synchronized (self) {
        self.context = [self contextForNewDrawingWithView:view];
        
        NSURL *pdfURL = [self setupPDFDocumentNamed:pdfName];
        [self drawViewInPDF];
        [self finishPDF];
        
        return pdfURL;
    }
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

#pragma mark - Private methods

- (MAGDrawContext *)contextForNewDrawingWithView:(UIView *)view {
    MAGDrawContext *context = [[MAGDrawContext alloc] initWithMainView:view noWrapViews:[self.delegate noWrapViewsForPdfRenderer:self]];
    context.pageSize = self.pageSize;
    context.pageInsets = self.pageInsets;
    context.printPageNumbers = self.printPageNumbers;
    context.pointToDrawPageNumber = self.pointToDrawPageNumber;
    context.pageNumberFont = self.pageNumberFont;
    
    return context;
}

- (NSURL *)setupPDFDocumentNamed:(NSString *)pdfName {
    NSString *extendedPdfName = [pdfName stringByAppendingPathExtension:@"pdf"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths.firstObject;
    
    NSString *pdfPath = [documentsDirectory stringByAppendingPathComponent:extendedPdfName];
    UIGraphicsBeginPDFContextToFile(pdfPath, CGRectZero, nil);
    
    return [NSURL fileURLWithPath:pdfPath];
}

- (void)drawViewInPDF {
    [self checkPageWidthOverhead];
    [self layoutView:self.context.mainView];
    [self beginNewPDFPage];
    [self drawSubviewsOfView:self.context.mainView];
}

- (void)checkPageWidthOverhead {
    CGFloat printableWidth = self.context.pageSize.width - self.context.pageInsets.left - self.context.pageInsets.right;
    CGFloat mainViewWidth = self.context.mainView.frame.size.width;
    BOOL overheadByX = mainViewWidth > printableWidth;
    if (overheadByX) {
        NSLog(@"Warning: The view has width which is more than printable width. The width should be less then or equal to %@ (pageSize.width{%@} - pageInsets.left{%@} - self.pageInsets.right{%@}) but currently is %@. The PDF document may be drawn incorrectly.",
              @(printableWidth), @(self.context.pageSize.width), @(self.context.pageInsets.left), @(self.context.pageInsets.right), @(mainViewWidth));
    }
}

- (void)layoutView:(UIView *)view { // TODO: refactor
    void (^layoutBlock)() = ^void() {
        [view setNeedsLayout];
        [view layoutIfNeeded];
    };
    
    if ([NSThread isMainThread]) {
        layoutBlock();
    }
    else {
        dispatch_sync(dispatch_get_main_queue(), layoutBlock);
    }
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
    
    CGRect renderRect = [self adjustToVerticalAlignText:rectForDraw originalLabel:label];
    
    [MAGPdfRenderer drawText:label.text inFrame:renderRect withAttributes:attributes];
}

/**
 *  Recalculate the rendering area to be vertically centered in the label's frame.
 */
- (CGRect)adjustToVerticalAlignText:(CGRect)renderRect originalLabel:(UILabel*)label
{
    CGSize constraint = CGSizeMake(renderRect.size.width, CGFLOAT_MAX);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [label.text boundingRectWithSize:constraint
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:label.font}
                                                  context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    CGFloat textHeight = size.height;
    
    CGFloat adjustedY = renderRect.origin.y + ((renderRect.size.height - textHeight)/2.0);
    
    return CGRectMake(renderRect.origin.x, adjustedY, renderRect.size.width, textHeight);
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
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName: self.context.pageNumberFont,
                                 };
    [pageNumber drawAtPoint:self.context.pointToDrawPageNumber withAttributes:attributes];
}

- (CGRect)rectForDrawViewWithNewPageAllocationIfNeeded:(UIView *)view {
    [self allocateNewPageIfNeededForView:view];
    
    CGRect rectForDraw = [view convertRect:view.bounds toView:self.context.mainView];
    rectForDraw.origin.y = rectForDraw.origin.y - self.context.currentPageTopY + self.context.pageInsets.top;
    
    //overflow should not take margins into account as the screen size does not.
    CGFloat overFlowX = CGRectGetMaxX(rectForDraw) - self.context.pageSize.width;
    if (overFlowX > 0) {
        rectForDraw.size.width = rectForDraw.size.width - overFlowX;
    }
    
    return rectForDraw;
}

- (void)allocateNewPageIfNeededForView:(UIView *)view {
    CGRect viewFrameInMainView = [view convertRect:view.bounds toView:self.context.mainView];
    CGFloat printableHeight = self.context.pageSize.height - self.context.pageInsets.top - self.context.pageInsets.bottom;
    CGFloat overheadByY = CGRectGetMaxY(viewFrameInMainView) - self.context.currentPageTopY - printableHeight;
    if (overheadByY > 0) {
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
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, self.context.pageSize.width, self.context.pageSize.height), nil);
    if (self.context.printPageNumbers) {
        [self drawPageNumber];
    }
}

- (void)finishPDF {
    UIGraphicsEndPDFContext();
    self.context = nil;
}

@end

