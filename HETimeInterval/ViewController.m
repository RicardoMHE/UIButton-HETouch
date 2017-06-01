//
//  ViewController.m
//  HETimeInterval
//
//  Created by Ricardo_M_HE on 2017/6/1.
//  Copyright © 2017年 Ricardo_M_HE. All rights reserved.
//

#import "ViewController.h"
#import "UIButton+HETouch.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.btn.he_timeInterval = 2.0;
}

- (IBAction)btnAction:(id)sender {
    NSLog(@"%@", [NSDate date]);
}

@end
