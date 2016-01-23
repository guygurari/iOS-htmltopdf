//
//  NDViewController.m
//  HTMLtoPDF-Demo
//
//  Created by Clément Wehrung on 12/11/12.
//  Copyright (c) 2012 Nurves. All rights reserved.
//

#import "NDViewController.h"

@interface NDViewController ()

@end

@implementation NDViewController

@synthesize PDFCreator;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

#pragma mark Button Actions

- (IBAction)generatePDFUsingDelegate:(id)sender
{
    self.resultLabel.text = @"loading...";
    
    self.PDFCreator = [NDHTMLtoPDF createPDFWithURL:[NSURL URLWithString:@"http://edition.cnn.com/2012/11/12/business/china-consumer-economy/index.html?hpt=hp_c1"]
                                         pathForPDF:[@"~/Documents/delegateDemo.pdf" stringByExpandingTildeInPath]
                                           delegate:self
                                           pageSize:kPaperSizeA4
                                            margins:UIEdgeInsetsMake(10, 5, 10, 5)];
}

- (IBAction)generatePDFUsingBlocks:(id)sender
{
    self.resultLabel.text = @"loading...";

    // Download an image into a UIImage*
    NSURL *imageURL = [NSURL URLWithString:@"http://thumbs.media.smithsonianmag.com//filer/b9/d2/b9d271f3-7f66-4132-b5af-7d33844505b7/goat.jpg__800x600_q85_crop.jpg"];
    NSLog(@"Image URL: %@",imageURL);
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    //NSLog(@"Image data: %@",imageData);
    UIImage *image = [UIImage imageWithData:imageData];
    NSLog(@"Image object: %@",image);
    
    // Save the image to a file
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Image.png"];
    [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
    NSLog(@"Image saved to file: %@",filePath);
    
    NSURL* localImageURL = [NSURL fileURLWithPath:filePath];
    NSLog(@"Local image URL: %@",localImageURL);
    
    // Prepare the HTML
    NSMutableString* html =  [NSMutableString stringWithCapacity:512];
    [html appendString:@"<!DOCTYPE html><html><head><style>body { font-family: 'Helvetica', 'Arial', sans-serif; } table, th, td { border: 1px solid black; border-collapse: collapse; } th, td { padding: 5px; } </style></head>"];
    [html appendString:@"<body><H1>A List of Things</H1>"];
    [html appendString:@"<table style='width:100%'>"];
    
    // Add table items
    [html appendString:@"<tr> <th>First</td> <th>Last</td> <th>Type</td> <th>Image</th> </tr>"];
    
    [html appendString:[NSString stringWithFormat:@"<tr> <td>foo</td> <td>bar</td> <td>xyz</td> <td align='center'><img src='%@' height='42' width='42'></td> </tr>",localImageURL]];
    [html appendString:[NSString stringWithFormat:@"<tr> <td>123</td> <td>abc</td> <td>def</td> <td align='center'><img src='%@' height='42' width='42'></td> </tr>",localImageURL]];
    
    [html appendString:@"</table>"];
    [html appendString:@"</body></html>"];

    self.PDFCreator = [NDHTMLtoPDF createPDFWithHTML:html pathForPDF:[@"~/Documents/blocksDemo.pdf" stringByExpandingTildeInPath] pageSize:kPaperSizeA4 margins:UIEdgeInsetsMake(10, 5, 10, 5) successBlock:^(NDHTMLtoPDF *htmlToPDF) {
        NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did succeed (%@ / %@)", htmlToPDF, htmlToPDF.PDFpath];
        NSLog(@"%@",result);
        self.resultLabel.text = result;

        // Delete the image file
        NSError* error;
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    } errorBlock:^(NDHTMLtoPDF *htmlToPDF) {
        NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did fail (%@)", htmlToPDF];
        NSLog(@"%@",result);
        self.resultLabel.text = result;
    }];
    
    /*
    self.PDFCreator = [NDHTMLtoPDF createPDFWithURL:[NSURL URLWithString:@"http://edition.cnn.com/2013/09/19/opinion/rushkoff-apple-ios-baby-steps/index.html"] pathForPDF:[@"~/Documents/blocksDemo.pdf" stringByExpandingTildeInPath] pageSize:kPaperSizeA4 margins:UIEdgeInsetsMake(10, 5, 10, 5) successBlock:^(NDHTMLtoPDF *htmlToPDF) {
        NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did succeed (%@ / %@)", htmlToPDF, htmlToPDF.PDFpath];
        NSLog(@"%@",result);
        self.resultLabel.text = result;
    } errorBlock:^(NDHTMLtoPDF *htmlToPDF) {
        NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did fail (%@)", htmlToPDF];
        NSLog(@"%@",result);
        self.resultLabel.text = result;
    }];
     */
}

#pragma mark NDHTMLtoPDFDelegate

- (void)HTMLtoPDFDidSucceed:(NDHTMLtoPDF*)htmlToPDF
{
    NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did succeed (%@ / %@)", htmlToPDF, htmlToPDF.PDFpath];
    NSLog(@"%@",result);
    self.resultLabel.text = result;
}

- (void)HTMLtoPDFDidFail:(NDHTMLtoPDF*)htmlToPDF
{
    NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did fail (%@)", htmlToPDF];
    NSLog(@"%@",result);
    self.resultLabel.text = result;
}

@end
