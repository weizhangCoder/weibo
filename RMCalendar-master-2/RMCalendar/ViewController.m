//
//  ViewController.m
//  RMCalendar
//
//  Created by 迟浩东 on 15/7/1.
//  Copyright (c) 2016年 迟浩东. All rights reserved.
//

#import "ViewController.h"
#import "RMCalendarController.h"
#import "MJExtension.h"
#import "TicketModel.h"
#import "DSToast.h"
#import "SWHttpTool.h"

//弹出的提示
#define SWToast(titlemessage)\

#define ZWTime @"ZWTime"//日历时间
#define ZWTitle @"ZWTitle"//展示标题

#define ZWDay 2




@interface ViewController ()
@property (nonatomic , strong) NSMutableArray * groups;
@property (nonatomic , strong) NSMutableArray * tmpgroups;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[SWHttpTool sharedSWHttpTool]post:@"https://182.92.156.49/api/getProductDateDatas/"
      parameters:nil success:^(id reponseObject) {
          
          if ([reponseObject[@"resCode"] isEqualToString:@"0000"]) {
              

              //放款
              for (NSDictionary *dict in reponseObject[@"info"]) {
                  
                  NSString *fangkuan = dict[@"fangkuan_dt"];
                  NSString *name = dict[@"name"];
                  
                  NSDictionary *smallDict = [NSDictionary dictionaryWithObjectsAndKeys:name,@"name",fangkuan,@"time", nil];
                  [self.tmpgroups addObject:smallDict];
                  
              }
              //满标
              for (NSDictionary *dict in reponseObject[@"info"]) {
                  NSString *fangkuan = dict[@"publish_dt"];
                  NSString *name = dict[@"name"];
                  NSDictionary *publishDict = [NSDictionary dictionaryWithObjectsAndKeys:name,@"name",fangkuan,@"time", nil];
                  [self.tmpgroups addObject:publishDict];
                  
              }
              //第一期
              for (NSDictionary *dict in reponseObject[@"info"]) {
                  NSString *fangkuan = dict[@"repay_dt_1"];
                  NSString *name = dict[@"name"];
                  NSDictionary *publishDict = [NSDictionary dictionaryWithObjectsAndKeys:name,@"name",fangkuan,@"time", nil];
                  [self.tmpgroups addObject:publishDict];
                  
              }
              //第二期
              for (NSDictionary *dict in reponseObject[@"info"]) {
                  NSString *fangkuan = dict[@"repay_dt_2"];
                  NSString *name = dict[@"name"];
                  NSDictionary *publishDict = [NSDictionary dictionaryWithObjectsAndKeys:name,@"name",fangkuan,@"time", nil];
                  [self.tmpgroups addObject:publishDict];
                  
              }
              //第三期
              for (NSDictionary *dict in reponseObject[@"info"]) {
                  NSString *fangkuan = dict[@"repay_dt_3"];
                  NSString *name = dict[@"name"];
                  NSDictionary *publishDict = [NSDictionary dictionaryWithObjectsAndKeys:name,@"name",fangkuan,@"time", nil];
                  [self.tmpgroups addObject:publishDict];
                  
              }
              
              
          }
          
        
    } failure:^(NSError *error) {
        
    }];
    
}
//{
//    "fangkuan_dt" = "2016-01-15";
//    id = 1;
//    name = wangwc2016011501;
//    "publish_dt" = "2016-01-15";
//    "repay_dt_1" = "2016-02-16";
//    "repay_dt_2" = "2016-03-16";
//    "repay_dt_3" = "2016-04-16";
//}

- (NSMutableArray *)groups
{
    if (_groups == nil) {
        _groups = [NSMutableArray array];
    }
    return _groups;
}
- (NSMutableArray *)tmpgroups
{
    if (_tmpgroups == nil) {
        _tmpgroups = [NSMutableArray array];
    }
    return _tmpgroups;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSString *)shijianzhuanhuanshijianchuo:(long long)shijianchuo is_seconds:(BOOL)is_seconds{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    if (is_seconds) {
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    }else{
        [formatter setDateFormat:@"YYYY-MM-dd"];
    }
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/beijing"];
    [formatter setTimeZone:timeZone];
    //这里判断要不要除以1000
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:shijianchuo];
    NSLog(@"1296035591  = %@",confromTimesp);
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    NSLog(@"confromTimespStr =  %@",confromTimespStr);
    
    return confromTimespStr;
}

- (IBAction)btnClick {
    NSMutableArray * muArray = [NSMutableArray array];
    
    for (NSDictionary *dict in self.tmpgroups) {
        [muArray addObject:dict[@"time"]];
    }
//去重
    NSSet *set = [NSSet setWithArray:muArray];
    NSLog(@"%lu",(unsigned long)[set allObjects].count);
    
    for (int i = 0; i < [set allObjects].count; i++) {
        NSString *settime =[set allObjects][i];
        
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *dict in self.tmpgroups) {
            if (settime == dict[@"time"]) {
                [array addObject:dict[@"name"]];
            }
            
        }
        NSString *zwtitle = [array componentsJoinedByString:@" , "];
        
        NSString *zwtime = [self shijianzhuanhuanshijianchuo:[settime longLongValue]-3600*24*ZWDay is_seconds:NO];
        
        NSDictionary *bigDict = [NSDictionary dictionaryWithObjectsAndKeys:zwtime,ZWTime,zwtitle,ZWTitle, nil];
        
        [self.groups addObject:bigDict];
        
    }
    
    
    NSMutableArray *newArray = [[NSMutableArray alloc]init];
    for (NSDictionary *dict in self.groups) {
        NSString *time = dict[ZWTime];
        if (time.length > 0) {
            NSArray *array = [time componentsSeparatedByString:@"-"];
            
            NSDictionary *dataDict = @{@"year":@([array[0] integerValue]),
                                       @"month":@([array[1] integerValue]),
                                       @"day":@([array[2] integerValue]),
                                       @"ticketCount":@194,
                                       @"ticketPrice":dict[ZWTitle]};
            [newArray addObject:dataDict];


           
            
        }
       
    }
    
    RMCalendarController *c = [RMCalendarController calendarWithDays:365 showType:CalendarShowTypeMultiple];
    c.modelArr = [TicketModel objectArrayWithKeyValuesArray:newArray];
    
//     此处用到MJ大神开发的框架，根据自己需求调整是否需要
//    c.modelArr = [TicketModel objectArrayWithKeyValuesArray:@[@{@"year":@2016, @"month":@1, @"day":@6,
//                                                                @"ticketCount":@194, @"ticketPrice":@283},
//                                                              @{@"year":@2016, @"month":@1, @"day":@7,
//                                                             @"ticketCount":@91, @"ticketPrice":@223},
//                                                              @{@"year":@2016, @"month":@1, @"day":@4,
//                                                                @"ticketCount":@91, @"ticketPrice":@23},
//                                                              @{@"year":@2016, @"month":@7, @"day":@8,
//                                                                @"ticketCount":@2, @"ticketPrice":@203},
//                                                              @{@"year":@2016, @"month":@7, @"day":@28,
//                                                                @"ticketCount":@2, @"ticketPrice":@103},
//                                                              @{@"year":@2016, @"month":@7, @"day":@18,
//                                                                @"ticketCount":@234, @"ticketPrice":@153}]]; //最后一条数据ticketCount 为0时不显示
    
//    c.modelArr = [TicketModel objectArrayWithKeyValuesArray:@[
//                                                              @{@"year":@2016, @"month":@1, @"day":@8,
//                                                                @"ticketCount":@2, @"ticketPrice":@203},
//                                                              @{@"year":@2016, @"month":@1, @"day":@28,
//                                                                @"ticketCount":@2, @"ticketPrice":@103},
//                                                              @{@"year":@2016, @"month":@1, @"day":@18,
//                                                                @"ticketCount":@0, @"ticketPrice":@153},
//                                                              
//                                                              @{@"year":@2016, @"month":@6, @"day":@18,
//                                                                @"ticketCount":@234, @"ticketPrice":@153},
//                                                              @{@"year":@2016, @"month":@6, @"day":@20,
//                                                                @"ticketCount":@234, @"ticketPrice":@153}
//                                                              ]]; //最后一条数据ticketCount 为0时不显示
    
    c.isEnable = NO;
    c.title = [NSString stringWithFormat:@"提前%d天查询日历",ZWDay];
    c.calendarBlock = ^(RMCalendarModel *model) {
        if (model.ticketModel) {
            NSLog(@"%lu-%lu-%lu-票价%@",(unsigned long)model.year,(unsigned long)model.month,(unsigned long)model.day, model.ticketModel.ticketPrice);
           
        } else {
            NSLog(@"%lu-%lu-%lu",(unsigned long)model.year,(unsigned long)model.month,(unsigned long)model.day);
        }
    };
    [self.navigationController pushViewController:c animated:YES];
}

@end
