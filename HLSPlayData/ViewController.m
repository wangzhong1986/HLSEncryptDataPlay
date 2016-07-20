//
//  ViewController.m
//  HLSPlayData
//
//  Created by wangzhong on 16/7/20.
//  Copyright © 2016年 wangzhong. All rights reserved.
//

#import "ViewController.h"
#import "HTTPServer.h"
#import "WZPlayer.h"

@interface ViewController ()

/** 本地服务器对象 */
@property (nonatomic, strong) HTTPServer * httpServer;
@property (nonatomic, strong) WZPlayer *player;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self openHttpServer];
    
    NSString *DocumentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSLog(@"\n[Function]:%s\n" "[line]:%d\n" "[value]:%@\n",__FUNCTION__, __LINE__, DocumentPath);
}

- (void)openHttpServer
{
    
    self.httpServer = [[HTTPServer alloc] init];
    [self.httpServer setType:@"_http._tcp."];  // 设置服务类型
    [self.httpServer setPort:12345]; // 设置服务器端口
    
    // 获取本地Library/Cache路径下downloads路径
    NSString *WebBasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"hls-ecb-test"];
    
    NSLog(@"-------------\nSetting document root: %@\n", WebBasePath);
    // 设置服务器路径
    [self.httpServer setDocumentRoot:WebBasePath];
    NSError *error;
    if(![self.httpServer start:&error])
    {
        NSLog(@"-------------\nError starting HTTP Server: %@\n", error);
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSURL *url = [NSURL URLWithString:@"cplp://127.0.0.1:12345/outRun.m3u8"];
    [[WZPlayer sharedInstance] playWithUrl:url showView:self.view];
}

@end
