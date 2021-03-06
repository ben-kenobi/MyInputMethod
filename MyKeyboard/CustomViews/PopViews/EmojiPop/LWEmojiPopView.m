//
//  LWEmojiPopView.m
//  MyInputMethod
//
//  Created by luowei on 16/2/18.
//  Copyright © 2016年 luowei. All rights reserved.
//

#import "LWEmojiPopView.h"
#import "LWDefines.h"
#import "LWBottomNavBar.h"
#import "Categories.h"
#import "UIImage+Color.h"
#import "MyKeyboardViewController.h"
#import "LWDataConfig.h"

static NSString *const EmojiCell = @"EmojiCell";

@implementation LWEmojiPopView{
    NSDictionary *_emojiDict;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [LWDataConfig getPopViewBackGroundColor];
    
        NSDictionary *iniDict = [LWDataConfig getEmojiDictionary];
        NSArray *bottomNavItems = [LWDataConfig getArrByKey:Key_BottomNavEmojiItems withDefaultArr:iniDict.allKeys];
        _bottomNavBar = [[LWBottomNavBar alloc]initWithFrame:CGRectMake(0, (CGFloat) (frame.size.height-Toolbar_H),frame.size.width,Toolbar_H)
                                                     andNavItems:bottomNavItems andShowAdd:NO];
        _bottomNavBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_bottomNavBar];


        CGFloat cellSideLenght = (frame.size.height-Toolbar_H)/4;
        //创建layout
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);

        //layout.headerReferenceSize = CGSizeMake(0,self.frame.size.height);

        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        //设置cell的大小
        layout.itemSize = CGSizeMake(cellSideLenght, cellSideLenght);

        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,0,frame.size.width,frame.size.height-Toolbar_H)
                                                 collectionViewLayout:layout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        _collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.alwaysBounceHorizontal = YES;
//        _collectionView.alwaysBounceVertical = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
    
        [_collectionView registerClass:[LWEmojiCell class] forCellWithReuseIdentifier:EmojiCell];
        [_collectionView registerClass:[LWEmojiCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header"];
        [self addSubview:_collectionView];

        _collectionView.backgroundColor = [LWDataConfig getPopViewBackGroundColor];

        //初始数据源
        _emojiDict = [LWDataConfig getEmojiDictionary];
    
        __weak typeof(self) weakSelf = self;
        self.bottomNavBar.bottomNavScrollview.updateTableDatasouce=^(){
            [weakSelf reloadCollection];
        };
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _bottomNavBar.frame = CGRectMake(0, (CGFloat) (self.frame.size.height-Toolbar_H),self.frame.size.width,Toolbar_H);
    _collectionView.frame = CGRectMake(0,0,self.frame.size.width, (CGFloat) (self.frame.size.height-Toolbar_H));
    CGFloat cellSideLenght = (CGFloat) ((self.frame.size.height-Toolbar_H)/4);
    ((UICollectionViewFlowLayout *)_collectionView.collectionViewLayout).itemSize = CGSizeMake(cellSideLenght, cellSideLenght);
}


-(void)reloadCollection{
    _emojiDict = [LWDataConfig getEmojiDictionary];
    [_collectionView setContentOffset:CGPointMake(0,0) animated:NO];
    [_collectionView reloadData];
}

#pragma mark UICollectionDataSource Implementation

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    //两个section,一个选择颜色,一个选择图片
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSUInteger idx = (NSUInteger) (_bottomNavBar.bottomNavScrollview->currentBtn.tag - Tag_First_NavItem);
    
    NSString *key = _emojiDict.allKeys[idx];
    return ((NSDictionary *)_emojiDict[key]).count;
}

- (LWEmojiCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LWEmojiCell *cell = (LWEmojiCell *) [collectionView dequeueReusableCellWithReuseIdentifier:EmojiCell forIndexPath:indexPath];

    NSUInteger idx = (NSUInteger) (_bottomNavBar.bottomNavScrollview->currentBtn.tag - Tag_First_NavItem);
    NSString *key = _emojiDict.allKeys[idx];
    NSString *text = _emojiDict[key][(NSUInteger) indexPath.item];

    NSString *fontName = StringValueFromThemeKey(@"font.name");
    CGFloat fontSize = FloatValueFromThemeKey(@"btn.mainLabel.fontSize");
    NSDictionary *attributes = @{NSFontAttributeName : [UIFont fontWithName:fontName size:fontSize]};
    UIImage *textImg = [UIImage imageFromString:text attributes:attributes size:[text sizeWithAttributes:attributes]];

    [cell.emojiBtn setImage:textImg forState:UIControlStateNormal];

    return cell;
}


#pragma mark - UICollectionDelegate Implementation

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    LWEmojiCell *cell = (LWEmojiCell *) [collectionView cellForItemAtIndexPath:indexPath];

    NSUInteger idx = (NSUInteger) (_bottomNavBar.bottomNavScrollview->currentBtn.tag - Tag_First_NavItem);
    NSString *key = _emojiDict.allKeys[idx];
    NSString *text = _emojiDict[key][(NSUInteger) indexPath.item];
    MyKeyboardViewController *kbVC = [self responderKBViewController];
    if(kbVC){
        [kbVC insertText:text];
    }
}


@end


@implementation LWEmojiCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _emojiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _emojiBtn.frame = CGRectMake(0,0,frame.size.width,frame.size.height);
        _emojiBtn.userInteractionEnabled = NO;
        _emojiBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_emojiBtn];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _emojiBtn.frame = CGRectMake(0,0,self.frame.size.width,self.frame.size.height);
}


@end