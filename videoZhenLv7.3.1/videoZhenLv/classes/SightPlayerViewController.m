//
//  sightPlayerViewController.m
//  videoZhenLv
//
//  Created by shingwai chan on 16/7/22.
//  Copyright © 2016年 ShingWai帅威. All rights reserved.
//

#import "SightPlayerViewController.h"
#import "MBProgressHUD+MJ.h"
#import "Masonry.h"
#import "UIImage+videoTool.h"
#import <AVFoundation/AVFoundation.h>


@interface SightPlayerViewController () <UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic)IBOutlet UIButton *cleanBtn;
@property (strong, nonatomic)IBOutlet UILabel *cleanLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, copy) NSString *tempPatch;

@property (nonatomic, strong) NSMutableArray *fileArray;

@end

@implementation SightPlayerViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.cleanBtn.layer.cornerRadius = self.cleanBtn.frame.size.width/2;
    self.title = @"清除自动备份";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"fileCell"];
    self.fileArray = [self getTempFlies];
    NSLog(@"\n 文件数组 = %@",self.fileArray);
    if (self.fileArray.count <= 0) {
        [self.cleanBtn setTitle:@"temp没视频" forState:UIControlStateNormal];
    }
    self.tableView.estimatedRowHeight = 100;
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
}


- (IBAction)cleanTempCaChe:(UIButton *)sender {
    [sender setTitle:@"正在删除..." forState:UIControlStateNormal];
    MBProgressHUD *mb = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    mb.labelText = @"正在删除...";
    [mb showAnimated:YES whileExecutingBlock:^{

        NSString *tempPatch = NSTemporaryDirectory();
        if (self.fileArray.count > 1) {//temp里面有文件
            for (NSString *filePatch in self.fileArray) {
                NSLog(@"文件：%@",filePatch);
                //系统自动生成的文件夹
                if (![filePatch isEqualToString:@"MediaCache"]) {//这个MediaCache文件夹不用删除
                    BOOL isRemove = [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@",tempPatch,filePatch] error:nil];
                    NSLog(@"%@",isRemove ? @"删除成功":@"删除失败");
                }
            }
            [sender setTitle:@"删除完成" forState:UIControlStateNormal];
        }else
        {
            [sender setTitle:@"temp没视频" forState:UIControlStateNormal];
        }
    } completionBlock:^{
        self.fileArray = [NSMutableArray arrayWithObject:self.fileArray[0]];
        [mb removeFromSuperViewOnHide];
        if ([sender.titleLabel.text isEqualToString:@"temp没视频"]) {
            [MBProgressHUD showSuccess:@"temp没视频"];
        }else
        {
            [MBProgressHUD showSuccess:@"删除完成"];
        }
        
        [self.tableView reloadData];
    }];
    
}

#pragma mark - TableVeiwDataSoure
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fileArray.count > 0 ? self.fileArray.count : 0;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fileCell" forIndexPath:indexPath];
    cell.textLabel.numberOfLines = 0;
    NSString *patch = [NSString stringWithFormat:@"%@/%@",self.tempPatch,self.fileArray[indexPath.row]];
    CGFloat size = [self fileSizeAtPath:patch];
    
    NSURL *videoUrl = [[NSURL alloc]initFileURLWithPath:patch];
    //获取视频截图
    cell.imageView.image = [UIImage firstFrameWithVideoURL:videoUrl size:CGSizeMake(100, 100)];
    
    cell.textLabel.text = [NSString stringWithFormat:@"文件 ： %@ \n大小 ： %.2fMB",self.fileArray[indexPath.row],size];
    
    
    
    return cell;
}


/**
 *  获取temp中的文件
 *
 *  @return temp所有文件
 */
-(NSMutableArray *)getTempFlies {
    
    NSString *tempPatch = NSTemporaryDirectory();
    self.tempPatch = tempPatch;//temp完整路径
    NSFileManager *fliemanager = [NSFileManager defaultManager];
    BOOL isHave = [fliemanager fileExistsAtPath:tempPatch];
    if (isHave) {
        NSArray *flieArr = [fliemanager contentsOfDirectoryAtPath:tempPatch error:nil];
        return [flieArr copy];
    }else
    {
        NSLog(@"没有temp");
        return nil;
    }
}

/**
 *  获取单个文件的大小
 */
- (CGFloat) fileSizeAtPath:(NSString*) filePath{
    
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:filePath]){
        
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize]/(1024.0*1024.0);//mb
    }
    return 0;
}

#pragma mark - dealloc
-(void)dealloc
{
    if (self.deallocBlock) {
        NSLog(@"deallocBlock执行");
        self.deallocBlock();
    }
    NSLog(@"SightPlayerViewControllerGG");
}

@end
