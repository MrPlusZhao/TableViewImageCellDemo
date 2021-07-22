//
//  DemoModel.h
//  TableViewImageCellDemo
//
//  Created by MrPlus on 2021/7/20.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface DemoModel : NSObject

@property (nonatomic, strong) NSString *avatar_large;
@property (nonatomic, strong) NSString *text;

@property (nonatomic, strong) UIImage *cell_Image;

@end

NS_ASSUME_NONNULL_END
