//
//  SWHttpTool.m
//  新浪微博
//
//  Created by xc on 15/3/10.
//  Copyright (c) 2015年 xc. All rights reserved.
//

#import "SWHttpTool.h"
#import "AFNetworkActivityIndicatorManager.h"



@interface SWHttpTool()


@property (nonatomic,strong) AFHTTPRequestSerializer *httpOperation;

@end

@implementation SWHttpTool

HMSingletonM(SWHttpTool)

+ (void)get:(NSString *)url parameters:(NSDictionary *)parameters success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    // 1.获得请求管理者
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    
    // 2.发送GET请求
   [mgr GET:url parameters:parameters
     success:^(AFHTTPRequestOperation *operation, id responseObj) {
         if (success) {
            
             success(responseObj);
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         if (failure) {
             
             failure(error);
         }
     }];
}


+ (NSString*)dictionaryToJson:(NSDictionary *)dic

{

    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}

- (void)post:(NSString *)url parameters:(NSDictionary *)parameters success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
//   [WSProgressHUD showWithMaskType:WSProgressHUDMaskTypeClear maskWithout:WSProgressHUDMaskWithoutDefault];
   
    
    // 1.获得请求管理者
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
     mgr.securityPolicy.allowInvalidCertificates = YES;
//    
//
//    [mgr.requestSerializer setValue:csrfttoken forHTTPHeaderField:@"X-CSRFToken"];
//    [mgr.requestSerializer setValue:sessionid forHTTPHeaderField:@"sessionid"];
//
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript",@"text/plain", nil];
   
    mgr.securityPolicy.allowInvalidCertificates = YES;

    
    
    [mgr POST:url parameters:parameters
      success:^(AFHTTPRequestOperation *operation, id responseObj) {
          if (success) {
//              [WSProgressHUD dismiss];
              success(responseObj);
          }
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          if (failure) {
//              [WSProgressHUD dismiss];
              failure(error);
          }
      }];



}
- (void)inithttps{
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    [AFHTTPRequestOperationManager manager].securityPolicy = securityPolicy;}

- (AFSecurityPolicy*)customSecurityPolicy
{
    // /先导入证书
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"hgcang" ofType:@"cer"];//证书的路径
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
    
    // AFSSLPinningModeCertificate 使用证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    
    // allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    // 如果是需要验证自建证书，需要设置为YES
    securityPolicy.allowInvalidCertificates = NO;
    
    //validatesDomainName 是否需要验证域名，默认为YES；
    //假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
    //置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
    //如置为NO，建议自己添加对应域名的校验逻辑。
    securityPolicy.validatesDomainName = NO;
    
    securityPolicy.pinnedCertificates = @[certData];
    
    return securityPolicy;
}

- (NSString *)CSRFTokenFromURL:(NSString *)url
{
    // Pass in any url with a CSRF protected form
    NSURL *baseURL = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:baseURL];
    [request setHTTPMethod:@"GET"];
    NSURLResponse *response;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:baseURL];
    
    for (NSHTTPCookie *cookie in cookies)
    {
        
        if ([[cookie name] isEqualToString:@"csrftoken"])
            
            return [cookie value];
    }
    return nil;
}
- (NSString *)sesondTokenFromURL:(NSString *)url
{
    // Pass in any url with a CSRF protected form
    NSURL *baseURL = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:baseURL];
    [request setHTTPMethod:@"GET"];
    NSURLResponse *response;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:baseURL];
    
    for (NSHTTPCookie *cookie in cookies)
    {
        
        if ([[cookie name] isEqualToString:@"sessionid"])
            
            return [cookie value];
    }
    return nil;
}

+ (void)monitoringReachabilityStatus:(void (^)(AFNetworkReachabilityStatus))statusBlock
{
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    // 当网络状态改变了，就会调用
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status) {
            statusBlock(status);

        }
    }];
    // 开始监控
    [mgr startMonitoring];

}



+ (void)showNetworkActivityIndicator
{
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
}
@end
