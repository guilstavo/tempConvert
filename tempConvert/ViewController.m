//
//  ViewController.m
//  tempConvert
//
//  Created by Gustavo on 28/09/15.
//  Copyright © 2015 Gustavo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController()
@property NSString *soapMessage;
@property NSString *currentElement;
@property NSMutableData *webResponseData;
@end

@implementation ViewController

@synthesize resultLabel;
@synthesize soapMessage, celciusText, webResponseData, currentElement;

-(void)viewDidLoad{
    [super viewDidLoad];
}
-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

-(IBAction)convertClicked:(id)sender{
    
    [celciusText resignFirstResponder];


    soapMessage = [NSString stringWithFormat:@"<?xml version='1.0' encoding='utf-8'?>"
        "<soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'>"
        "<soap:Body>"
        "<CelsiusToFahrenheit xmlns='http://www.w3schools.com/webservices/'>"
        "<Celsius>%@</Celsius>"
        "</CelsiusToFahrenheit>"
        "</soap:Body>"
        "</soap:Envelope>", celciusText.text];

    NSURL *url = [NSURL URLWithString:@"http://www.w3schools.com/webservices/tempconvert.asmx"];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLenght = [NSString stringWithFormat:@"%d", [soapMessage length]];

    [theRequest addValue:@"www.w3schools.com" forHTTPHeaderField:@"Host"];
    [theRequest addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue:@"http://www.w3schools.com/webservices/CelsiusToFahrenheit" forHTTPHeaderField:@"SOAPAction"];
    [theRequest addValue:msgLenght forHTTPHeaderField:@"Content-Lenght"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody:[soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    //initiate the request
    NSURLConnection *connection =
    [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if(connection){
        webResponseData = [NSMutableData data];
        NSLog(@"Conectou");
    }else{
        NSLog(@"Connection is NULL");
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.webResponseData  setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.webResponseData  appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Some error in your Connection. Please try again.");
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Received %d Bytes", [webResponseData length]);
    NSString *theXML = [[NSString alloc] initWithBytes:
                        [webResponseData mutableBytes] length:[webResponseData length] encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@",theXML);
    
    //now parsing the xml
    
    NSData *myData = [theXML dataUsingEncoding:NSUTF8StringEncoding];
    
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:myData];
    
    //setting delegate of XML parser to self
    xmlParser.delegate = self;
    
    // Run the parser
    @try{
        BOOL parsingResult = [xmlParser parse];
        NSLog(@"parsing result = %hhd",parsingResult);
    }
    @catch (NSException* exception)
    {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Server Error" message:[exception reason] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
}

//Implement the NSXmlParserDelegate methods
-(void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:
(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    currentElement = elementName;
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if ([currentElement isEqualToString:@"CelsiusToFahrenheitResult"]) {
        self.resultLabel.text = string;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSLog(@"Parsed Element : %@", currentElement);
}

@end
