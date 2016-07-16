//
//  LoginViewController.m
//  (lesson45)APITest
//
//  Created by Илья Егоров on 27.06.16.
//  Copyright © 2016 Илья Егоров. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "AccessToken.h"

@interface LoginViewController () <UIWebViewDelegate>

@property (copy, nonatomic) LoginCompletionBlock completionBlock;
@property (strong, nonatomic) UIWebView* webView;

@end


@implementation LoginViewController

-(id) initWithCompletionBlock:(LoginCompletionBlock)completionBlock;
{
    self = [super init];
    if (self) {
        self.completionBlock = completionBlock;
    }
    return self;
}


-(void)viewDidLoad {
    
    [super viewDidLoad];
    
    CGRect r = self.view.bounds;
    r.origin = CGPointZero;
    
    UIWebView* webView = [[UIWebView alloc] initWithFrame:r];
    
    webView.delegate = self;
    
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:webView];
    
    self.webView = webView;
    
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                          target:self
                                                                          action:@selector(actionCancel:)];
    
    [self.navigationItem setRightBarButtonItem:item animated:NO];

    [self.navigationItem setTitle:@"Login"];
    
    NSString* urlString =
    @"https://oauth.vk.com/authorize?"
    "client_id=4835516&"
    "scope=143382&" // + 2 + 4 + 16 + 131072 + 8192 + 4096
    "redirect_uri=https://oauth.vk.com/blank.html&"
    "display=mobile&"
    "v=5.52&"
    "response_type=token";
    
    NSURL* url = [NSURL URLWithString:urlString];
    
    NSURLRequest* urlRequest = [NSURLRequest requestWithURL:url];
    
    [webView loadRequest:urlRequest];
}

- (void)dealloc
{
    self.webView.delegate = nil;
}

#pragma mark - Actions

- (void) actionCancel:(UIBarButtonItem*)item {
    
    if (self.completionBlock) {
        self.completionBlock(nil);
    }
    [self dismissViewControllerAnimated:YES
                             completion:nil];
    
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if ([[[request URL] description] rangeOfString:@"#access_token="].location != NSNotFound) {
        
        AccessToken* token = [[AccessToken alloc] init];
        
        NSString* query = [[request URL] description];
        
        NSArray* array = [query componentsSeparatedByString:@"#"];
        
        if (array.count > 1) {
            query = [array lastObject];
        }
        
        NSArray* pairs = [query componentsSeparatedByString:@"&"];
        for (NSString* pair in pairs) {
            NSArray* values = [pair componentsSeparatedByString:@"="];
            if (values.count == 2) {
                
                NSString* key = [values firstObject];
                
                if ([key isEqualToString:@"access_token"]) {
                    token.token = [values lastObject];
                } else if ([key isEqualToString:@"expires_in"]) {
                    NSTimeInterval interval = [[values lastObject] doubleValue];
                    
                    token.expirationDate = [NSDate dateWithTimeIntervalSinceNow:interval];
                } else if ([key isEqualToString:@"user_id"]) {
                    
                    token.userID = [values lastObject];
                }
            }
        }
        
        [self.webView setDelegate:nil];
        
        if (self.completionBlock) {
            self.completionBlock(token);
        }
        [self dismissViewControllerAnimated:YES
                                 completion:nil];
        
        return NO;
    }

    NSLog(@"%@", request.URL);
    
    return YES;
}












@end
