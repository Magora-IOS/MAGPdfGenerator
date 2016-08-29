# MAGPdfGenerator

`MAGPdfGenerator` is an utility which provides the ability to convert UIView's representation to a PDF document. The UIView may be created from XIB file and use Autolayouts that makes a convenient way to draw the PDF's content. The PDF document will automatically be divided by pages so you can create a long table view and draw it in the PDF document without additional preparation. The generator can also automatically print page numbers in the bottom of each of the pages.

![](http://i.imgur.com/YRjvBwf.png)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

`MAGPdfGenerator` works on iOS 8+.

## Installation

MAGPdfGenerator is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile and run `pod install`:

```ruby
pod 'MAGPdfGenerator'
```

## Usage

Before you can use the generator you should create an instance of UIView containing the layout for the future PDF document. The default pdf page size is {612, 792}, and the printable area has a size {580, 730}, so you should locate internal views in the size equal to the size of the printable area to avoid elements out of the page. You can use XIB file for that purposes and then instantiate the view with something like this:
```ruby
YourPdfViewClass *yourPdfViewInstance = [[NSBundle mainBundle] loadNibNamed:
    NSStringFromClass([YourPdfViewClass class]) owner:nil options:nil].firstObject;
```
After it is instantiated you can create and use an instance of `MAGPdfRenderer`
```ruby
MAGPdfRenderer *renderer = [[MAGPdfRenderer alloc] init];
NSURL *pdfURL = [renderer drawView:yourPdfViewInstance inPDFwithFileName:pdfName];
```
pdfURL will contain the URL of the pdf file that was rendered by the utility. 

To be sure that some of your blocks in the pdf will not be wrapped to the next page you can specify them with the method `noWrapViewsForPdfRenderer:` of MAGPdfRendererDelegate
```ruby
- (IBAction)generatePDFbuttonTapped:(id)sender {
    MAGPdfRenderer *renderer = [[MAGPdfRenderer alloc] init];
    renderer.delegate = self;
    NSURL *pdfURL = [renderer drawView:self.yourPdfViewInstance inPDFwithFileName:pdfName];
}

- (NSArray<UIView *> *)noWrapViewsForPdfRenderer:(MAGPdfRenderer *)pdfRenderer {
    return self.yourPdfViewInstance.noWrapViews;
}
```

## Author

Konstantin Mamaev, mamaev@magora-systems.com

## License

MAGPdfGenerator is available under the MIT license. See the LICENSE file for more info.
