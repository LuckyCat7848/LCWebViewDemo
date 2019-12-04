//
//  LCWKH5ViewController.m
//  LCWebViewDemo
//
//  Created by 张猫猫 on 2019/11/29.
//  Copyright © 2019 ehi. All rights reserved.
//

#import "LCWKWebViewController.h"
#import <WebKit/WebKit.h>

static NSString *const kJSNoneParameter = @"noneParameter";
static NSString *const kJSSingleParameter = @"singleParameter";
static NSString *const kJSMoreParameter = @"moreParameter";

@interface LCWKWebViewController ()<WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>

/** webview */
@property (nonatomic, strong) WKWebView *webView;
/** js回调的方法名 */
@property (nonatomic, copy) NSArray<NSString *> *scriptNameList;

@end

@implementation LCWKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"WKWebView";
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
    _webView.navigationDelegate = nil;
    
    NSLog(@"%s", __FUNCTION__);
}

#pragma mark - Action

/** 主动调用JS方法 */
- (void)callJSMethod {
    NSString *aString = @"客户端主动调用JS方法，也可用于JS🌹异步的🌹拿到客户端返回值";
    NSString *func = [NSString stringWithFormat:@"jsResponseClient('%@')", aString];
    [self.webView evaluateJavaScript:func completionHandler:^(id _Nullable object, NSError * _Nullable error) {
        NSLog(@"%@   %@", object, error);
    }];
}

#pragma mark - WKScriptMessageHandler ⚠️js回调方法接收

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    if ([message.name isEqualToString:kJSNoneParameter]) {
        // 无参数
        NSLog(@"%@", message.body);
    
    } else if ([message.name isEqualToString:kJSSingleParameter]) {
        // 1个参数
        NSLog(@"%@", message.body);
    
    } else if ([message.name isEqualToString:kJSMoreParameter]) {
        // 多个参数
        NSLog(@"%@", message.body);
    }
}

#pragma mark - WKUIDelegate ⚠️JS弹框的显示

/** 显示一个按钮。点击后调用completionHandler回调 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

/** 显示两个按钮。通过completionHandler回调判断用户点击的确定还是取消按钮 */
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

/** 显示一个带有输入框和一个确定按钮的。通过completionHandler回调用户输入的内容 */
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    
    // 拦截弹框,同步返回传值给JS
    NSError *err = nil;
    NSData *dataFromString = [prompt dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *payload = [NSJSONSerialization JSONObjectWithData:dataFromString options:NSJSONReadingMutableContainers error:&err];
    if (!err) {
        NSString *type = [payload objectForKey:@"type"];
        if (type && [type isEqualToString:@"JSbridge"]) {
            NSString *returnValue = @"";
            NSString *functionName = [payload objectForKey:@"functionName"];
            NSDictionary *args = [payload objectForKey:@"arguments"];
            
            SEL selector = NSSelectorFromString(functionName);
            if ([self respondsToSelector:selector]) {
                kSuppressPerformSelectorLeakWarning(returnValue = [self performSelector:selector withObject:args]);
            }
            completionHandler(returnValue);
            return ;
        }
    }
    
    // 显示弹框
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields.lastObject.text);
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - JS同步获取返回值

- (NSString *)getReturnValue:(NSDictionary *)args {
    NSLog(@"%@", args);
    return @"JS同步获取返回值";
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void(^)(WKNavigationActionPolicy))decisionHandler {
    
    NSLog(@"1-------在发送请求之前，决定是否跳转  -->%@", navigationAction.request);
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"2-------页面开始加载时调用");
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void(^)(WKNavigationResponsePolicy))decisionHandler {
    // 在收到服务器的响应头，根据response相关信息，决定是否跳转。decisionHandler必须调用，来决定是否跳转，参数WKNavigationActionPolicyCancel取消跳转，WKNavigationActionPolicyAllow允许跳转
    NSLog(@"3-------在收到响应后，决定是否跳转");
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    NSLog(@"4-------当内容开始返回时调用");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"5-------页面加载完成之后调用");
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"6-------页面加载失败时调用");
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"-------接收到服务器跳转请求之后调用");
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"-------数据加载发生错误时调用");
}

#pragma mark - Getter

- (WKWebView *)webView {
    if (!_webView) {
        // 创建UserContentController（提供JavaScript向webView发送消息的方法）
        WKUserContentController *userContent = [[WKUserContentController alloc] init];
        // JS回调方法的监听,这里要注意避免释放问题
        // (懒得引入YY或写一个了,写的时候别忘了哈)
        id handler = self;//[YYWeakProxy proxyWithTarget:self];
        for (NSString *name in self.scriptNameList) {
            [userContent addScriptMessageHandler:handler name:name];
        }
        
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        config.userContentController = userContent;
        
        WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
        webView.backgroundColor = [UIColor whiteColor];
        webView.navigationDelegate = self;
        webView.UIDelegate = self;
        webView.scrollView.showsVerticalScrollIndicator = NO;
        webView.scrollView.bounces = NO;
        webView.opaque = NO;
        
        [self.view addSubview:webView];
        _webView = webView;
    }
    return _webView;
}

- (NSArray<NSString *> *)scriptNameList {
    if (!_scriptNameList) {
        _scriptNameList = @[
                            kJSNoneParameter,
                            kJSSingleParameter,
                            kJSMoreParameter,
                            ];
    }
    return _scriptNameList;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
