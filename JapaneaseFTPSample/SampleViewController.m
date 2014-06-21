//
//  SampleViewController.m
//  JapaneaseFTPSample
//
//  Created by Tatsuya Ogi on 2014/06/21.
//  Copyright (c) 2014年 personal. All rights reserved.
//

#import "SampleViewController.h"

@interface SampleViewController ()
@property(nonatomic, strong) NSString *ftpFileName;
@property (nonatomic, strong) GRRequestsManager *requestsManager;
@property(nonatomic, strong) NSMutableArray *fileLists;
@end

@implementation SampleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)_setupManager
{
    NSString *hostName = self.hostNameField.text;
    self.requestsManager = [[GRRequestsManager alloc] initWithHostname:hostName
                                                                  user:@"anonymous"
                                                              password:@"anonymous"];
    self.requestsManager.delegate = self;
}

- (IBAction)getFile:(id)sender {
    [self _setupManager];
    
    if (self.ftpFileName == nil) {
        return;
    }

    NSData *nameData = [self.ftpFileName dataUsingEncoding:NSShiftJISStringEncoding];
    if (nameData == nil) {
        return;
    }
    
    NSString *newName = [[NSString alloc] initWithData:nameData encoding:NSMacOSRomanStringEncoding];
    NSString* encodedFileName = [newName stringByAddingPercentEscapesUsingEncoding:NSMacOSRomanStringEncoding];

    [self.requestsManager addRequestForDownloadFileAtRemotePath:encodedFileName toLocalPath:[NSTemporaryDirectory() stringByAppendingPathComponent:self.ftpFileName]];
    [self.requestsManager startProcessingRequests];
}

- (IBAction)getList:(id)sender {
    [self _setupManager];

    [self.requestsManager addRequestForListDirectoryAtPath:@"/"];
    [self.requestsManager startProcessingRequests];
}

- (IBAction)putFile:(id)sender {
    [self _setupManager];

    NSData *nameData = [self.ftpFileName dataUsingEncoding:NSShiftJISStringEncoding];
    if (nameData == nil) {
        return;
    }
    
    NSString *newName = [[NSString alloc] initWithData:nameData encoding:NSMacOSRomanStringEncoding];
    NSString* encodedFileName = [newName stringByAddingPercentEscapesUsingEncoding:NSMacOSRomanStringEncoding];
    
    [self.requestsManager addRequestForUploadFileAtLocalPath:[NSTemporaryDirectory() stringByAppendingPathComponent:self.ftpFileName] toRemotePath:encodedFileName];
    [self.requestsManager startProcessingRequests];
}

- (IBAction)cancel:(id)sender {
    [self _setupManager];

    [self.requestsManager stopAndCancelAllRequests];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (NSInteger) [self.fileLists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"listIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:identifier];
    }
    
    cell.textLabel.text = self.fileLists[((NSUInteger) indexPath.row)];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.ftpFileName = [self.fileLists objectAtIndex:((NSUInteger) indexPath.row)];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.hostNameField resignFirstResponder];
    return YES;
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didScheduleRequest:(id<GRRequestProtocol>)request
{
    NSLog(@"requestsManager:didScheduleRequest:");
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompleteDownloadRequest:(id<GRDataExchangeRequestProtocol>)request
{
    NSLog(@"requestsManager:didCompleteDownloadRequest:");
    self.putButton.enabled = YES;
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompleteListingRequest:(id<GRRequestProtocol>)request listing:(NSArray *)listing
{
    NSLog(@"requestsManager:didCompleteListingRequest:listing: \n%@", listing);
    
    self.fileLists = nil;
    self.fileLists = [[NSMutableArray alloc] init];
    
    // 日本語ファイル名の変換
    NSString *name;
    NSData *nameData;
    NSString *newName;
    for (int i = 0; i<[listing count]; i++) {
        name = listing[i];
        nameData = [name dataUsingEncoding:NSMacOSRomanStringEncoding];
        if (nameData != nil) {
            newName = [[NSString alloc] initWithData:nameData encoding:NSShiftJISStringEncoding];
            [self.fileLists addObject:newName];
        }
    }
    
    self.getButton.enabled = YES;
    [self.fileListView reloadData];
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompleteUploadRequest:(id<GRDataExchangeRequestProtocol>)request
{
    
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didFailWritingFileAtPath:(NSString *)path forRequest:(id<GRDataExchangeRequestProtocol>)request error:(NSError *)error
{
    NSLog(@"requestsManager:didFailWritingFileAtPath:forRequest:error: \n %@", error);
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didFailRequest:(id<GRRequestProtocol>)request withError:(NSError *)error
{
    NSLog(@"requestsManager:didFailRequest:withError: \n %@", error);
}

@end
