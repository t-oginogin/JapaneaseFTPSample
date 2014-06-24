//
//  SampleViewController.h
//  JapaneaseFTPSample
//
//  Created by Tatsuya Ogi on 2014/06/21.
//  Copyright (c) 2014年 personal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoldRaccoon/GRRequestsManager.h"

@interface SampleViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, GRRequestsManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *hostNameField;
@property (weak, nonatomic) IBOutlet UITableView *fileListView;
@property (weak, nonatomic) IBOutlet UIButton *listButton;
@property (weak, nonatomic) IBOutlet UIButton *getButton;
@property (weak, nonatomic) IBOutlet UIButton *putButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end
