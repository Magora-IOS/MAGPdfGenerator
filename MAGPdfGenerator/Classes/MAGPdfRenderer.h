#import <UIKit/UIKit.h>

@class MAGPdfRenderer;
@class MAGDrawContext;


@protocol MAGPdfRendererDelegate <NSObject>
- (NSArray<UIView *> *)noWrapViewsForPdfRenderer:(MAGPdfRenderer *)pdfRenderer;
@end


@interface MAGPdfRenderer : NSObject

@property (nonatomic, weak) id<MAGPdfRendererDelegate> delegate;
@property (nonatomic, readonly) MAGDrawContext *context;

/**
 * Draws all labels and images from the view to the pdf document with the specified name.
 * The method is not thread safe so you can not use it in different threads from the same class instance.
 * @return URL of the generated pdf document.
 */
- (NSURL *)drawView:(UIView *)view inPDFwithFileName:(NSString *)pdfName;

+ (void)drawImage:(UIImage *)image inRect:(CGRect)rect;
+ (void)drawText:(NSString *)textToDraw inFrame:(CGRect)frameRect;
+ (void)drawText:(NSString *)textToDraw inFrame:(CGRect)frameRect withAttributes:(NSDictionary<NSString *, id> *)attrs;

@end
