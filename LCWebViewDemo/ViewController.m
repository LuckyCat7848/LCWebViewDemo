//
//  ViewController.m
//  LCWebViewDemo
//
//  Created by 张猫猫 on 2019/11/29.
//  Copyright © 2019 ehi. All rights reserved.
//

#import "ViewController.h"
#import "LCWKWebViewController.h"
#import "LCUIWebViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Demo";
    
    [self configUI];
}

- (void)configUI {
    UIButton *wkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    wkButton.frame = CGRectMake(100, 200, 150, 80);
    wkButton.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
    wkButton.layer.borderColor = [UIColor blackColor].CGColor;
    [wkButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [wkButton setTitle:@"WKWebView" forState:UIControlStateNormal];
    [wkButton addTarget:self action:@selector(goWKWeb) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:wkButton];
    
    UIButton *uiButton = [UIButton buttonWithType:UIButtonTypeCustom];
    uiButton.frame = CGRectMake(100, 350, 150, 80);
    uiButton.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
    uiButton.layer.borderColor = [UIColor blackColor].CGColor;
    [uiButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [uiButton setTitle:@"UIWebView" forState:UIControlStateNormal];
    [uiButton addTarget:self action:@selector(goUIWeb) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:uiButton];
}

- (void)goWKWeb {
    LCWKWebViewController *webVC = [[LCWKWebViewController alloc] init];
    [self.navigationController pushViewController:webVC animated:YES];
}

- (void)goUIWeb {
    LCUIWebViewController *webVC = [[LCUIWebViewController alloc] init];
    [self.navigationController pushViewController:webVC animated:YES];
}

@end
