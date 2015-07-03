//
//  BaseKBBtn.m
//  MyInputMethod
//
//  Created by luowei on 15/7/1.
//  Copyright (c) 2015 luowei. All rights reserved.
//

#import "BaseKBBtn.h"
#import "KeyboardConfig.h"
#import "Defines.h"


@interface BaseKBBtn ()

@end

@implementation BaseKBBtn {
    CALayer *_shadowlayer;      //阴影
    CALayer *_innerGlow;        //内边框
    CALayer *_backgroundLayer, *_highlightBackgroundLayer;    //背景图层/高亮背景图层
//    CALayer *backgroundLayer, *highlightBackgroundLayer;
}

- (instancetype)init {
//    Log(@"--------%d:%s：", __LINE__, __func__);
    self = [super init];
    if (self) {
        [self setupSubViews];
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
//    Log(@"--------%d:%s：", __LINE__, __func__);
    self = [super initWithCoder:coder];
    if (self) {
        [self setupSubViews];
    }

    return self;
}


- (instancetype)initWithFrame:(CGRect)frame {
//    Log(@"--------%d:%s：", __LINE__, __func__);
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }

    return self;
}

- (void)awakeFromNib {
//    Log(@"--------%d:%s：", __LINE__, __func__);
    [super awakeFromNib];

    [self setupSubViews];
}

- (void)setHighlighted:(BOOL)highlighted {
    // Disable隐式动画
    [CATransaction begin];
    [CATransaction setDisableActions:YES];

    //隐藏/显示反转的背景图层
    _highlightBackgroundLayer.hidden = !highlighted;
    [CATransaction commit];

    [super setHighlighted:highlighted];
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    if (state & UIControlStateHighlighted || state & UIControlStateSelected) {
        _highlightBackgroundLayer.contents = (__bridge id) image.CGImage;
        _highlightBackgroundLayer.contentsScale = [[UIScreen mainScreen] scale];
        _highlightBackgroundLayer.contentsGravity = kCAGravityCenter;//kCAGravityResizeAspect;
    } else {
        _backgroundLayer.contents = (__bridge id) image.CGImage;
        _backgroundLayer.contentsScale = [[UIScreen mainScreen] scale];
        _backgroundLayer.contentsGravity = kCAGravityCenter;//kCAGravityResizeAspect;
    }
}

- (void)setupSubViews {
    self.backgroundColor = [UIColor clearColor];

    if (_contentView) {
        [_contentView removeFromSuperview];
        _contentView = nil;
    }
    
    _contentView = [[UIView alloc] initWithFrame:CGRectInset(self.bounds, 3, 5)];
    _contentView.userInteractionEnabled = NO;
    [self addSubview:_contentView];

    //当有主题设置
    NSString *themeName = [KeyboardConfig currentTheme];
    if (themeName) {
        UIImage *kbBtnImamge = [KeyboardConfig getBtnImageWithByName:themeName];
        _contentView.layer.contents = (__bridge id) kbBtnImamge.CGImage;
        _contentView.layer.contentsScale = [[UIScreen mainScreen] scale];

    } else {
        //当没有设置主题
        //设置背景图层
        //_contentView.layer.backgroundColor = COLOR_KBBTN_CONTENTVIEW_BG_A;
        [self setupBackgroundLayer];
        [self setupHighlightBackgroundLayer];
        _highlightBackgroundLayer.hidden = YES;

        //给contentView添加内外边框
        [self setupInnerGlow];
        [self setupBorder];

        //给contentView添加阴影
        [self setupShadowLayer];
    }
}

//按Normal状态时的背景色
- (void)setupBackgroundLayer {
    if (!_backgroundLayer) {

        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.colors = (@[
                (__bridge id) COLOR_KBBTN_CONTENTVIEW_BG_A,
                (__bridge id) COLOR_KBBTN_CONTENTVIEW_BG_B
        ]);
        gradientLayer.locations = (@[
                @0.0f,
                @1.0f
        ]);
        gradientLayer.opacity = 0.2;
        _backgroundLayer = gradientLayer;
        _backgroundLayer.frame = CGRectInset(_contentView.frame, 0, 0);
        _backgroundLayer.cornerRadius = RADIUS_KBBTN_CONTENTVIEW;
        [self.layer insertSublayer:_backgroundLayer atIndex:0];
    }
}

//按Highlight状态时的背景色
- (void)setupHighlightBackgroundLayer {
    if (!_highlightBackgroundLayer) {

        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.colors = (@[
                (__bridge id) COLOR_KBBTN_CONTENTVIEW_BG_B,
                (__bridge id) COLOR_KBBTN_CONTENTVIEW_BG_A
        ]);
        gradientLayer.locations = (@[
                @0.0f,
                @1.0f
        ]);
        gradientLayer.opacity = 0.5;
        _highlightBackgroundLayer = gradientLayer;
        _highlightBackgroundLayer.frame = CGRectInset(_contentView.frame, 0, 0);
        _highlightBackgroundLayer.cornerRadius = RADIUS_KBBTN_CONTENTVIEW;
        [self.layer insertSublayer:_highlightBackgroundLayer atIndex:1];
    }
}


//给contentView添加外边框
- (void)setupBorder {
    CALayer *layer = self.contentView.layer;
    layer.cornerRadius = RADIUS_KBBTN_CONTENTVIEW;
    layer.borderWidth = WIDTH_KBBTN_CONTENTVIEW_BORDER;
    layer.borderColor = COLOR_KBBTN_CONTENTVIEW_BORDER;
}

//给contentView添加内边框
- (void)setupInnerGlow {
    if (!_innerGlow) {
        _innerGlow = [CALayer layer];
        _innerGlow.cornerRadius = RADIUS_KBBTN_CONTENTVIEW_INNERBORDER;
        _innerGlow.borderWidth = WIDTH_KBBTN_CONTENTVIEW_INNERBORDER;
        _innerGlow.borderColor = COLOR_KBBTN_CONTENTVIEW_INNERBORDER;
        _innerGlow.opacity = 0.5;

        [_contentView.layer insertSublayer:_innerGlow atIndex:2];
    }
}

//给contentView添加阴影
- (void)setupShadowLayer {

    if (_shadowlayer) {
        [_shadowlayer removeFromSuperlayer];
        _shadowlayer = nil;
    }
    // 给按钮添加阴影层
    _shadowlayer = [CALayer layer];
    _shadowlayer.contentsScale = self.layer.contentsScale;
    _shadowlayer.contentsScale = self.layer.contentsScale;
    _shadowlayer.backgroundColor = COLOR_SHADOWLAYER;
    _shadowlayer.cornerRadius = RADIUS_SHADOWLAYER;

    _shadowlayer.frame = CGRectMake(_contentView.frame.origin.x, (CGFloat) (_contentView.frame.origin.y + _contentView.frame.size.height - HEIGHT_SHADOWLAYER + OFFSET_SHADOWLAYER),
            _contentView.frame.size.width, HEIGHT_SHADOWLAYER);
    [self.layer insertSublayer:_shadowlayer below:_contentView.layer];
}

- (void)layoutSubviews {
    //当有主题设置
    NSString *themeName = [KeyboardConfig currentTheme];
    if (themeName) {
    } else {
        _contentView.frame = CGRectInset(self.bounds, SPACE_BTN_BG_HORIZON, SPACE_BTN_BG_VERTICAL);

        //重设阴影大小
        _shadowlayer.frame = CGRectOffset(_contentView.frame, 0, OFFSET_SHADOWLAYER);
        _shadowlayer.frame = CGRectMake(_contentView.frame.origin.x, (CGFloat) (_contentView.frame.origin.y + _contentView.frame.size.height - HEIGHT_SHADOWLAYER + OFFSET_SHADOWLAYER),
                _contentView.frame.size.width, HEIGHT_SHADOWLAYER);

        //重设置内边框、背景、高亮背景大小
        _innerGlow.frame = CGRectInset(self.bounds, 1, 1);
        _backgroundLayer.frame = CGRectInset(_contentView.frame, 0, 0);
        _highlightBackgroundLayer.frame = CGRectInset(_contentView.frame, 0, 0);
    }
    [super layoutSubviews];

}

@end