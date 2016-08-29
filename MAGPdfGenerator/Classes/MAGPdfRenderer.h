#import <UIKit/UIKit.h>

@class MAGPdfRenderer;
@class MAGDrawContext;


@protocol MAGPdfRendererDelegate <NSObject>
- (NSArray<UIView *> *)noWrapViewsForPdfRenderer:(MAGPdfRenderer *)pdfRenderer;
@end


@interface MAGPdfRenderer : NSObject

@property (nonatomic, weak) id<MAGPdfRendererDelegate> delegate;

@property (nonatomic) CGSize pageSize; // Default value {612, 792}.
@property (nonatomic) UIEdgeInsets pageInsets; // Default value {39, 45, 39, 55} (default printable frame = {45, 39, 512, 714}). Note that each of the pages will contain the specified insets.
@property (nonatomic) BOOL printPageNumbers; // Default value NO.
@property (nonatomic) CGPoint pointToDrawPageNumber; // Default value {580, 730}. Set printPageNumbers to YES to be able to specify the point to draw the page number.
@property (nonatomic) UIFont *pageNumberFont; // Default is systemFontOfSize:12.

/**
 * Draws all labels and images from the view to the PDF document with the specified name.
 * The colored subviews will also be drawn colored in the PDF.
 * The view will be automatically divided by pages in according to the specified page size.
 * Be noted that the view should has the size equal to the printable size of the page.
 * @return URL of the generated pdf document.
 */
- (NSURL *)drawView:(UIView *)view inPDFwithFileName:(NSString *)pdfName;

+ (void)drawImage:(UIImage *)image inRect:(CGRect)rect;
+ (void)drawText:(NSString *)textToDraw inFrame:(CGRect)frameRect;
+ (void)drawText:(NSString *)textToDraw inFrame:(CGRect)frameRect withAttributes:(NSDictionary<NSString *, id> *)attrs;

@end
