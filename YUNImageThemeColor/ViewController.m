//
//  ViewController.m
//  YUNImageThemeColor
//
//  Created by zhiyunyu on 2020/8/31.
//

#import "ViewController.h"
#import "UIView+Utils.h"
#import "UIImage+ThemeColor.h"

@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate,
UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) UIImageView *avatarImageView;
@property(nonatomic, strong) UIImageView *avatarImageView2;
@property(nonatomic, strong) UIView *mainColorView;
@property(nonatomic, strong) UILabel *mainColorLabel;
@property(nonatomic, strong) UITableView *colorTableView;

@property(nonatomic, strong) NSArray<QNColorItem *> *colorArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    self.colorTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 400, 350)
                                                              style:UITableViewStylePlain];
        
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView;
    });
    
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"pikaqiu" ofType:@"png" inDirectory:@"Image.bundle/home"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    
    self.avatarImageView = ({
        CGFloat imageViewSize = 150;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - imageViewSize) / 2, 60, imageViewSize, imageViewSize)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = image;
        imageView;
    });
    
    self.mainColorLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.text = @"上方图片的主题色是：";
        [label sizeToFit];
        label.qn_top = self.avatarImageView.qn_bottom + 5;
        label.qn_centerX = self.avatarImageView.qn_centerX;
        label;
    });

    self.mainColorView = ({
        CGFloat leftSpace = 50;
        UIView *view = [[UIView alloc] initWithFrame:
                        CGRectMake(leftSpace, 0, self.view.bounds.size.width - 2 * leftSpace, 30)];
        view.qn_top = self.mainColorLabel.qn_bottom + 5;
        view.backgroundColor = [UIColor blackColor];
        view;
    });
    
    self.colorTableView.qn_centerX = self.view.bounds.size.width / 2;
    self.colorTableView.qn_top = self.mainColorView.qn_bottom + 20;
    
    // weakify
    [self.avatarImageView.image getThemeColor:^(UIColor * _Nonnull themeColor, NSArray<QNColorItem *> * _Nonnull colorArray) {
        self.mainColorView.backgroundColor = themeColor;
        
        self.colorArray = [colorArray copy];
        [self.colorTableView reloadData];
    }];
    
    [self.view addSubview:self.avatarImageView];
    [self.view addSubview:self.mainColorLabel];
    [self.view addSubview:self.mainColorView];
    [self.view addSubview:self.colorTableView];
    
    //打开用户交互
    self.avatarImageView.userInteractionEnabled = YES;
    //初始化一个手势
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarDidTapped:)];
    //为图片添加手势
    [self.avatarImageView addGestureRecognizer:singleTap];

}

#pragma mark - Private


// 保存图片到相册的回调函数
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        NSLog(@"保存失败");
    } else {
        NSLog(@"保存成功");
    }
}


//头像点击事件
- (void)avatarDidTapped:(UIGestureRecognizer *) gestureRecognizer {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = YES;
    picker.delegate = self;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"修改头像" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"我的相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;//我的相片 （这种形式会把一张张照片罗列出来）
        picker.allowsEditing = NO;

        [self presentViewController:picker animated:YES completion:nil];
    }];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:nil];
    }];
    UIAlertAction *destructiveAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:cancelAction];
    [alertController addAction:sureAction];
    [alertController addAction:destructiveAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark UINavigationControllerDelegate, UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqual:@"public.image"]) {
        UIImage *originImage =
        [info objectForKey:UIImagePickerControllerOriginalImage];
        self.avatarImageView.image = originImage;
        
        // 这里拿到了UIImage ,开始解析图片获取颜色值
        [originImage getThemeColor:^(UIColor * _Nonnull themeColor, NSArray<QNColorItem *> * _Nonnull colorArray) {
            self.mainColorView.backgroundColor = themeColor;
            
            self.colorArray = [colorArray copy];
            [self.colorTableView reloadData];
        }];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([UIDevice currentDevice].systemVersion.floatValue < 11) {
        return;
    }
    if ([viewController isKindOfClass:NSClassFromString(@"PUPhotoPickerHostViewController")]) {
        [viewController.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.frame.size.width < 42) {
                [viewController.view sendSubviewToBack:obj];
                *stop = YES;
            }
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.colorArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = @"reuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    QNColorItem *colorItem = [self.colorArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"百分之%@', 像素点数量：%@",
                           @(colorItem.percent),
                           @(colorItem.pixelCount)];
    if (colorItem.isPureColor) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@  纯色", cell.textLabel.text];
    }
    [cell.textLabel sizeToFit];
    cell.contentView.backgroundColor = colorItem.color;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 20;
}

@end
