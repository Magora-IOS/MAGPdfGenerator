#import "ViewController.h"

// Views
#import "PDFOrderView.h"

// Libraries
#import <MAGPdfGenerator/MAGPdfGenerator-umbrella.h>


@interface ViewController () <UIDocumentInteractionControllerDelegate, MAGPdfRendererDelegate>
@property (nonatomic) PDFOrderView *pdfOrderView;
@end


@implementation ViewController

#pragma mark - Actions

- (IBAction)generatePDFButtonTapped:(id)sender {
    NSString *pdfName = @"myShinyPdf";
    self.pdfOrderView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([PDFOrderView class]) owner:nil options:nil].firstObject;
    
    MAGPdfRenderer *renderer = [[MAGPdfRenderer alloc] init];
    renderer.delegate = self;
    renderer.pageInsets = (UIEdgeInsets){30, 20, 55, 20};
    renderer.printPageNumbers = YES;

    NSURL *pdfURL = [renderer drawView:self.pdfOrderView inPDFwithFileName:pdfName];

    [self previewPDFDocumentWithURL:pdfURL];
}

#pragma mark - Auxiliaries

- (void)previewPDFDocumentWithURL:(NSURL *)pdfURL {
    UIDocumentInteractionController *documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:pdfURL];
    documentInteractionController.delegate = self;
    [documentInteractionController presentPreviewAnimated:YES];
}

#pragma mark - UIDocumentInteractionControllerDelegate implementation

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self;
}

#pragma mark - MAGPdfRendererDelegate implementation

- (NSArray<UIView *> *)noWrapViewsForPdfRenderer:(MAGPdfRenderer *)pdfRenderer {
    return self.pdfOrderView.noWrapViews;
}

@end
