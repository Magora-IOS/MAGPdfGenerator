#import "PDFOrderTableCell.h"

// Libraries
#import <ZXingObjC/ZXingObjC.h>


@interface PDFOrderTableCell ()
@property (weak, nonatomic) IBOutlet UIImageView *barcodeImageView;
@property (weak, nonatomic) IBOutlet UILabel *upcLabel;

@property (nonatomic) NSString *upc;
@end


@implementation PDFOrderTableCell

- (void)setupWithProduct {
    self.upc = @"762753483508";
    
    [self setupBarcodeImage];
    [self setupBarcodeCaption];
}

- (void)setupBarcodeImage {
    NSError *__autoreleasing error = nil;
    ZXMultiFormatWriter *writer = [ZXMultiFormatWriter writer];
    ZXBitMatrix *result = [writer encode:self.upc format:kBarcodeFormatUPCA width:80 height:20 error:&error];
    if (result) {
        CGImageRef imageRef = [ZXImage imageWithMatrix:result].cgimage;
        self.barcodeImageView.image = [UIImage imageWithCGImage:imageRef];
    } else {
        NSLog(@"Error: %@", error.localizedDescription);
    }
}

- (void)setupBarcodeCaption {
    self.upcLabel.text = self.upc;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.upcLabel.attributedText];
    [attributedString addAttribute:NSKernAttributeName value:@0.8 range:NSMakeRange(0, attributedString.length)];
    self.upcLabel.attributedText = attributedString;
}

@end
