#import "PDFOrderTableCell.h"

// Libraries
#import <ZXingObjC/ZXingObjC.h>


@interface PDFOrderTableCell ()
@property (nonatomic) IBOutlet UILabel *styleLabel;
@property (nonatomic) IBOutlet UIImageView *barcodeImageView;
@property (nonatomic) IBOutlet UILabel *upcLabel;
@property (nonatomic) IBOutlet UILabel *quantityLabel;
@property (nonatomic) IBOutlet UILabel *colorLabel;
@property (nonatomic) IBOutlet UILabel *sizeLabel;
@property (nonatomic) IBOutlet UILabel *priceLabel;
@property (nonatomic) IBOutlet UILabel *extenLabel;
@property (nonatomic) IBOutlet UILabel *commentsLabel;

@property (nonatomic) NSString *style;
@property (nonatomic) NSString *upc;
@property (nonatomic) NSString *color;
@property (nonatomic) NSString *size;
@property (nonatomic) NSInteger quantity;
@property (nonatomic) NSInteger price;
@end


@implementation PDFOrderTableCell

#pragma mark - Public methods

- (void)setupWithRandomProduct {
    [self generateRandomProductProperties];
    [self setupViews];
}

#pragma mark - Private methods

- (void)generateRandomProductProperties {
    self.style = [PDFOrderTableCell randomStyle];
    self.upc = [PDFOrderTableCell randomUPC];
    self.quantity = arc4random_uniform(5) + 1;
    self.color = [PDFOrderTableCell randomColor];
    self.size = [PDFOrderTableCell randomSize];
    self.price = arc4random_uniform(200) + 50;
}

- (void)setupViews {
    self.styleLabel.text = self.style;
    self.upcLabel.text = self.upc;
    self.quantityLabel.text = @(self.quantity).stringValue;
    self.colorLabel.text = self.color;
    self.sizeLabel.text = self.size;
    self.priceLabel.text = [NSString stringWithFormat:@"$%@.00", @(self.price)];
    self.extenLabel.text = [NSString stringWithFormat:@"$%@.00", @(self.price * self.quantity)];

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

#pragma mark - Auxiliaries

+ (NSString *)randomUPC {
    static NSArray *UPCs = nil;
    if (!UPCs) {
        UPCs = @[
                @"827886525256",
                @"762753194404",
                @"762753194411",
                @"762753194428",
                @"762753194671",
                @"762753053237",
                @"827886152469",
                @"762753483508",
            ];
    }
    NSUInteger randomIndex = arc4random() % UPCs.count;
    return UPCs[randomIndex];
}

+ (NSString *)randomColor {
    static NSArray *colors = nil;
    if (!colors) {
        colors = @[
                @"PINK GOLD",
                @"SILVER GRAY",
                @"SPACE GRAY",
                @"SILVER WHITE",
                @"SPACE BLACK",
                @"BLUE GOLD",
                @"BRONZE GREEN",
                @"BRONZE BLUE",
            ];
    }
    NSUInteger randomIndex = arc4random() % colors.count;
    return colors[randomIndex];
}

+ (NSString *)randomSize {
    NSNumber *randomSizeNumber = @(arc4random_uniform(50) + 10);
    NSString *randomSize = [NSString stringWithFormat:@"%@%C", randomSizeNumber, [self randomChar]];
    return randomSize;
}

+ (NSString *)randomStyle {
    NSString *randomStyle = [NSString stringWithFormat:@"%C%C%@%@%@%@",
            [self randomChar], [self randomChar], [self randomDigitNumber], [self randomDigitNumber], [self randomDigitNumber], [self randomDigitNumber]];
    return randomStyle;
}

+ (unichar)randomChar {
    NSString *letters = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    unichar randomChar = [letters characterAtIndex:arc4random_uniform((u_int32_t)letters.length)];
    return randomChar;
}

+ (NSNumber *)randomDigitNumber {
    return @(arc4random_uniform(10));
}

@end
