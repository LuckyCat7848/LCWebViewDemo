//
//  LCUIWebViewController.m
//  LCWebViewDemo
//
//  Created by 张猫猫 on 2019/11/29.
//  Copyright © 2019 ehi. All rights reserved.
//

#import "LCUIWebViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface LCUIWebViewController ()<UIWebViewDelegate>

/** webview */
@property (nonatomic, strong) UIWebView *webView;

@end

@implementation LCUIWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"UIWebView";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightButton setTitle:@"调用JS" forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(callJSMethod) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"TestH5" ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url] ;
    [self.webView loadRequest:request];
}

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

#pragma mark - Action

/** 主动调用JS方法 */
- (void)callJSMethod {
    NSString *aString = @"客户端主动调用JS方法，也可用于JS🌹异步的🌹拿到客户端返回值";
    NSString *func = [NSString stringWithFormat:@"jsResponseClient('%@')", aString];
    [self.webView stringByEvaluatingJavaScriptFromString:func];
}

#pragma mark - ⚠️js回调方法接收

- (void)loadLocalMethod:(UIWebView *)webView {
    JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    // 无参数
    context[@"noneParameter"] = ^() {
        NSLog(@"null");
    };
    
    // 1个参数
    context[@"singleParameter"] = ^(NSString *aString) {
        NSLog(@"%@", aString);
    };
    
    // 多个参数
    context[@"moreParameter"] = ^(NSString *aString1, NSString *aString2, NSString *aString3) {
        NSLog(@"%@  %@  %@", aString1, aString2, aString3);
    };
    
    // 有返回值
    __block JSContext *blockContext = context;
    context[@"getReturnValue"] = ^JSValue *() {
        NSString *aString = @"一个返回值";
        return [JSValue valueWithObject:aString inContext:blockContext];
    };
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSLog(@"1-------开始加载加载url: %@", [request.URL.absoluteString stringByRemovingPercentEncoding]);
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"2-------页面开始加载时调用");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"3-------页面加载完成之后调用");
    
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];

    [self loadLocalMethod:webView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"4-------页面加载失败时调用");
}

#pragma mark - Getter

- (UIWebView *)webView {
    if (!_webView) {
        UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        webView.backgroundColor = [UIColor whiteColor];
        webView.scrollView.showsVerticalScrollIndicator = NO;
        webView.delegate = self;
        webView.opaque = NO;
        
        [self.view addSubview:webView];
        _webView = webView;
    }
    return _webView;
}

@end
