//
//  DemoVC.m
//  TableViewImageCellDemo
//
//  Created by MrPlus on 2021/7/20.
//

#import "DemoVC.h"
#import "DemoCell.h"
#import "DemoModel.h"

// 性能检测
#import "SKFFPSLabel.h"

//加载图片
#import <SDWebImage/SDImageCache.h>
#import "UIImageView+WebCache.h"

//数据转模型
#import <MJExtension/MJExtension.h>

#define KNavBarHeight ([self ISIphoneXModel] ? 88 : 64)
typedef void(^successBlock)(NSArray *array);
@interface DemoVC ()<UITableViewDelegate,UITableViewDataSource>{
    BOOL scrollToToping;
}
@property (nonatomic, strong) UITableView    *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;

@end

@implementation DemoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self UI];
    [self data];
}
- (void)UI{
    self.view.backgroundColor = UIColor.greenColor;
    [self.view addSubview:self.tableView];
    [self FPS];
}
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, KNavBarHeight, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-KNavBarHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = UITableViewAutomaticDimension;
        [_tableView registerNib:[UINib nibWithNibName:@"DemoCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"DemoCell"];
    }
    return _tableView;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DemoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DemoCell"];
    if (!cell) {
        cell = [[NSBundle mainBundle]loadNibNamed:@"DemoCell" owner:self options:nil].lastObject;
    }
    DemoModel *model = self.dataArr[indexPath.row];
    
    cell.contentLab.text = model.text;
    if (model.cell_Image) {
        cell.imageV.image = model.cell_Image;
    }else{
        cell.imageV.image = [UIImage imageNamed:@"smallIcon"];
    }
    
    [self performSelector:@selector(p_loadImgeWithIndexPath:) withObject:indexPath afterDelay:0.1 inModes:@[NSDefaultRunLoopMode]];
    
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView{
    scrollToToping = YES;
    return YES;
}
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
    scrollToToping = NO;
}
- (void)p_loadImgeWithIndexPath:(NSIndexPath *)indexPath{
    if ( scrollToToping ) {
        return;
    }
    DemoModel *model = self.dataArr[indexPath.row];
    dispatch_async(dispatch_get_main_queue(), ^{
        DemoCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        NSArray *visibleCells = [self.tableView visibleCells];// 为了优化性能,每次只配置一屏的cell
        if ([visibleCells containsObject:cell]) {
            // 这里下载图片的方式 有很多种, 为了配合当前项目, 目前使用了SDWebimage的方法
            // 方法的目的是一样的, 无图片就去下载, 下载完就赋值给model
            UIImage *originalImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:model.avatar_large];
            if (originalImage) {
                model.cell_Image = originalImage;
                cell.imageV.image = originalImage;
            }
            else{
                [cell.imageV sd_setImageWithURL:[NSURL URLWithString:model.avatar_large] placeholderImage:[UIImage imageNamed:@"smallIcon"]];
            }
        }
    });
}

#pragma mark 以下方法 各自发挥

- (void)FPS{
    SKFFPSLabel *fpsLabel = [[SKFFPSLabel alloc]init];
    fpsLabel.frame = CGRectMake(0, KNavBarHeight+20, 100, 50);
    [self.view addSubview:fpsLabel];
}
- (void)data{
    self.dataArr = [NSMutableArray array];
    [self fetchDataSuccess:^(NSArray * _Nonnull array) {
        self.dataArr = [NSMutableArray arrayWithArray:array];
        [self.tableView reloadData];
    }];
}

- (BOOL)ISIphoneXModel
{
    BOOL iPhoneXSeries = NO;
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
        return iPhoneXSeries;
    }
    
    if (@available(iOS 11.0, *)) {
        if ([[[UIApplication sharedApplication] delegate] window].safeAreaInsets.bottom > 0.0) {
            iPhoneXSeries = YES;
        }
    }
    return iPhoneXSeries;
}
- (void)fetchDataSuccess:(successBlock)completion{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSDictionary *dict = [self jsonByLocalName:@"param"];
        NSArray *tempDatas = dict[@"statuses"];
        NSMutableArray *json = @[].mutableCopy;
        [json addObjectsFromArray:tempDatas];
        [json addObjectsFromArray:tempDatas];
        [json addObjectsFromArray:tempDatas];
        [json addObjectsFromArray:tempDatas];
        [json addObjectsFromArray:tempDatas];
        NSArray *datas = [DemoModel mj_objectArrayWithKeyValuesArray:json];
        completion(datas);
    });
}

/// 根据本地文件读取json(测试方法)
- (NSDictionary *)jsonByLocalName:(NSString *)name
{
    // 获取文件路径
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
    // 将文件数据化
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    
    return [NSJSONSerialization JSONObjectWithData:data
                                           options:kNilOptions
                                             error:nil];
}
@end
