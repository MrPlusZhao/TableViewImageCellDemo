//
//  ViewController.m
//  TableViewImageCellDemo
//
//  Created by MrPlus on 2021/7/20.
//

#import "ViewController.h"
#import "DemoVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.orangeColor;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.navigationController pushViewController:DemoVC.new animated:YES];
}

@end
