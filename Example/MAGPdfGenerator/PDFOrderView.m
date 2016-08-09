#import "PDFOrderView.h"

// Views
#import "PDFOrderTableCell.h"
#import "PDFOrderTableHeader.h"

// Libraries
#import <ORStackView/ORStackView.h>
#import <Masonry/Masonry.h>


@interface PDFOrderView ()
@property (weak, nonatomic) IBOutlet UIView *orderTableContainer;
@property (nonatomic) IBOutletCollection(UIView) NSArray *containers;
@property (nonatomic) IBOutletCollection(UIView) NSArray *noWrapOutletCollection;
@property (nonatomic) ORStackView *stackView;
@end


@implementation PDFOrderView

#pragma mark - Awakening

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self configureContainerColors];
    [self configureStackView];
    [self configureNoWrapViews];
}

#pragma mark - Configuration

- (void)configureContainerColors {
    for (UIView *container in self.containers) {
        container.backgroundColor = [UIColor whiteColor];
    }
}

- (void)configureStackView {
    self.stackView = [[ORStackView alloc] init];
    self.stackView.backgroundColor = [UIColor whiteColor];
    [self.orderTableContainer addSubview:self.stackView];
    [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.orderTableContainer);
    }];
    
    [self configureOrderTableHeader];
    [self configureOrderTableCells];
}

- (void)configureOrderTableHeader {
    PDFOrderTableHeader *header = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([PDFOrderTableHeader class]) owner:nil options:nil].firstObject;
    [self.stackView addSubview:header withPrecedingMargin:0 sideMargin:0];
}

- (void)configureOrderTableCells {
    for (NSInteger i = 0; i < 123; i++) {
        PDFOrderTableCell *cell = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([PDFOrderTableCell class]) owner:nil options:nil].firstObject;
        [cell setupWithProduct];
        [self.stackView addSubview:cell withPrecedingMargin:0 sideMargin:0];
        if (i % 2 == 1) {
            cell.backgroundColor = [UIColor colorWithRed:240./255 green:240./255 blue:240./255 alpha:1.0];
        }
    }
}

- (void)configureNoWrapViews {
    self.noWrapViews = [self.noWrapOutletCollection arrayByAddingObjectsFromArray:self.stackView.subviews];
}

@end
