//
//  LCSVideoController.m
//  44基本的http请求
//
//  Created by Mac OS X on 15/9/20.
//  Copyright (c) 2015年 Mac OS X. All rights reserved.
//

#import "LCSVideoController.h"
#import "MBProgressHUD+CZ.h"
#import "LCSVideo.h"
#import "UIImageView+WebCache.h"
#import <MediaPlayer/MediaPlayer.h>
#import "GDataXMLNode.h"

#define LCSUrl(path) [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:8080/MJServer/%@",path]]

@interface LCSVideoController () <NSXMLParserDelegate>

@property (nonatomic, strong) NSMutableArray *arrVideoM;

@end

@implementation LCSVideoController

- (NSMutableArray *)arrVideoM
{
    if (_arrVideoM == nil) {
        
        _arrVideoM = [[NSMutableArray alloc] init];
        
    }
    return _arrVideoM;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *url = LCSUrl(@"video?type=XML");
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (connectionError || data == nil) {
            [MBProgressHUD showError:@"网络繁忙，请稍候再试！"];
            return ;
        }
        
        //NSXMLParser解析xml
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
        
        //设置代理
        parser.delegate = self;
        
        //开始解析
        [parser parse];
        
        //刷新表格
        [self.tableView reloadData];
        
    }];
}

#pragma mark - NSXMLParser的代理方法


//解析到文档的开头
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    NSLog(@"parserDidStartDocument");
}

//解析到文档的结尾
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    NSLog(@"parserDidEndDocument");
}

//解析到一个元素的开始
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    NSLog(@"start %@", elementName);
    
    if ([elementName isEqualToString:@"videos"]) {
        return;
    }
    
    LCSVideo *model = [LCSVideo video:attributeDict];
    
    [self.arrVideoM addObject:model];
}
//解析到一个元素的结束
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSLog(@"end %@", elementName);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return self.arrVideoM.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LCSVideo *video = self.arrVideoM[indexPath.row];
    
    NSString *ID = @"video_cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    cell.textLabel.text = video.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"时长 : %d",video.length];
    
//    NSString *imageStr = [NSString stringWithFormat:@"http://localhost:8080/MJServer/%@",video.image];
//    NSURL *imageUrl = [NSURL URLWithString:imageStr];
    
    NSURL *imageUrl = LCSUrl(video.image);
    
    [cell.imageView sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"a_01"]];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LCSVideo *video = self.arrVideoM[indexPath.row];
    
//    NSString *videoStr = [NSString stringWithFormat:@"http://localhost:8080/MJServer/%@",video.url];
//    NSURL *videoUrl = [NSURL URLWithString:videoStr];
    
    NSURL *videoUrl = LCSUrl(video.url);
    
    MPMoviePlayerViewController *playerVc = [[MPMoviePlayerViewController alloc] initWithContentURL:videoUrl];
    
    [self presentViewController:playerVc animated:YES completion:nil];
}

@end
