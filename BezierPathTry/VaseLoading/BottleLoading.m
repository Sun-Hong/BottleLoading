//
//  BottleLoading.m
//  BezierPathTry
//
//  Created by SunHong on 2017/1/5.
//  Copyright © 2017年 sunhong. All rights reserved.
//

#import "BottleLoading.h"

//#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)

//发大倍数
static CGFloat bigScale = 1;
//线宽
static CGFloat bottleWidth = 5.f;
//水边宽
static CGFloat waterRoundWidth = 3.f;

static CGFloat marginSpace = 10.f;
//花瓶宽度
static CGFloat loadWidth = 200.f;
//花瓶高度
static CGFloat loadHeight = 220.f;

//瓶颈高度
#define neckHeight (loadHeight - 2*marginSpace) * 0.4
//瓶身高度
#define bodyHeight (loadHeight - 2*marginSpace) * 0.5
//瓶底宽度
#define bottomWidth (loadWidth * 0.5)
//瓶口宽度
#define topWidth (loadWidth * 0.3)
//花瓶颜色
#define BotttleColor [UIColor blackColor]
//水的颜色
#define WaterColor [UIColor greenColor]
//水与水瓶之间的颜色
#define SpaceColor [UIColor whiteColor]

@interface BottleLoading ()

//绘制瓶子的view
@property (nonatomic, weak) UIView *loadingView;

//瓶口
@property (nonatomic, weak) CAShapeLayer *topLayer;
//瓶颈
@property (nonatomic, weak) CAShapeLayer *neckLayer;
//瓶身
@property (nonatomic, weak) CAShapeLayer *bodyLayer;

//右侧
//瓶身
@property (nonatomic, weak) CAShapeLayer *otherBodyLayer;

//瓶底
@property (nonatomic, weak) CAShapeLayer *bottomLayer;

@end

@implementation BottleLoading

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        //绘制瓶子
        [self setupBottleView];
        //绘制水
        [self setupWaterView];
    }
    return self;
}

/**
 绘制瓶子
 */
- (void)setupBottleView
{
    CGRect showFrame = CGRectMake(0, 0, loadWidth, loadHeight);
    UIView *loadingView = [[UIView alloc] initWithFrame:showFrame];
    loadingView.center = self.center;
    loadingView.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:loadingView];
    
    self.loadingView = loadingView;
    
    //瓶口
    [self drawBottleTopLayer];
    
    //绘制靠近底部的静态的水
    [self drawStaticWaterLayer];
    
    //瓶颈 瓶身
    [self drawBottleBodyLayer];
    
    //翻转得到对面一半
    [self summaryRotateLayers];
    //瓶底
    [self drawBottleBottomLayer];
}

/**
 绘制水
 */
- (void)setupWaterView
{
    //绘制靠近底部的静态的水
//    [self drawStaticWaterLayer];
    //绘制水波
    [self drawWaterWaveLayer];
    //绘制水滴
    [self drawWaterDropLayer];
    
    //绘制水的边缘
    [self drawWaterRoundLayer];
}

/**
 绘制瓶口
 */
- (void)drawBottleTopLayer
{
    //瓶口 左边点
    CGFloat topLeftX = (loadWidth - topWidth) * 0.5;
    //左侧瓶边中心
    CGFloat leftMidX = topLeftX;
    
    //创建path
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = 1.f;
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    
    /**<  绘制瓶口&&瓶颈  >**/
    
    CGFloat offsetLeftX = 2.f *bigScale;
    //瓶嘴外侧
    // 添加外圆到path
    CGFloat outRadius = 5.f *bigScale;
    CGPoint outArcCenter = CGPointMake(leftMidX-offsetLeftX, outRadius+marginSpace);
    CGFloat outStartAngle = M_PI_2;
    CGFloat outEndAngle = -M_PI_2;
    [path addArcWithCenter:outArcCenter
                    radius:outRadius
                startAngle:outStartAngle
                  endAngle:outEndAngle
                 clockwise:YES];
    
    //瓶嘴内侧 180°角
    CGFloat inRadius = 2.f *bigScale;
    CGPoint inArcCenter = CGPointMake(leftMidX-offsetLeftX, inRadius+marginSpace);
    CGFloat inStartAngle = -M_PI_2;
    CGFloat inEndAngle = M_PI_2;
    // 添加内圆到path
    [path addArcWithCenter:inArcCenter
                    radius:inRadius
                startAngle:inStartAngle
                  endAngle:inEndAngle
                 clockwise:YES];
    
    //缺口
    CGFloat lineRightX = leftMidX + bottleWidth*0.5;
    CGPoint lineRightTopPoint = CGPointMake(lineRightX, marginSpace+1.7*outRadius);
    
    //使拐角圆滑
    CGFloat lineRightTopY = outRadius + marginSpace;
    CGPoint controlPoint = CGPointMake(lineRightX, lineRightTopY);
    [path addQuadCurveToPoint:lineRightTopPoint controlPoint:controlPoint];
    
    [path closePath];
    
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.path = path.CGPath;
    circleLayer.lineWidth = 5;
    circleLayer.fillColor = BotttleColor.CGColor;
    circleLayer.strokeColor = [UIColor clearColor].CGColor;
    [self.loadingView.layer addSublayer:circleLayer];
    
    self.topLayer = circleLayer;
}

/**
 瓶颈 && 瓶身
 */
- (void)drawBottleBodyLayer
{
    //左侧瓶边中心
    CGFloat leftMidX = (loadWidth - topWidth) * 0.5;
    
    //创建path
    UIBezierPath *neckPath = [UIBezierPath bezierPath];
    neckPath.lineWidth = bottleWidth;
    // 终点处理：设置结束点曲线
    neckPath.lineCapStyle = kCGLineCapRound;
    // 拐角处理：设置两个连接点曲线
    neckPath.lineJoinStyle = kCGLineJoinRound;
    
    /**<  瓶颈  >**/
    CGFloat outRadius = 5.f *bigScale;
    CGFloat lineHeight = neckHeight;
    CGFloat lineRightTopY = marginSpace + 1.7*outRadius;
    CGFloat lineX = leftMidX;
    
    CGPoint lineTopPoint = CGPointMake(lineX, lineRightTopY);
    CGPoint lineBottomPoint = CGPointMake(lineX, (lineRightTopY+lineHeight));
    
    /**<  绘制瓶颈  >**/
    [neckPath moveToPoint:lineTopPoint];
    [neckPath addLineToPoint:lineBottomPoint];
    
    CAShapeLayer *neckLayer = [CAShapeLayer layer];
    neckLayer.path = neckPath.CGPath;
    neckLayer.lineWidth = bottleWidth;
    neckLayer.fillColor = [UIColor clearColor].CGColor;
    neckLayer.strokeColor = BotttleColor.CGColor;
    [self.loadingView.layer addSublayer:neckLayer];
    self.neckLayer = neckLayer;
    
    //创建path
    UIBezierPath *bodyPath = [UIBezierPath bezierPath];
    bodyPath.lineWidth = bottleWidth;
    // 终点处理：设置结束点曲线
    bodyPath.lineCapStyle = kCGLineCapRound;
    // 拐角处理：设置两个连接点曲线
    bodyPath.lineJoinStyle = kCGLineJoinRound;
    
    /**<  绘制瓶身  >**/
    CGFloat bodyMinY = 64.f;
    //瓶底左侧点 曲线结束点
    CGFloat bottomY = loadHeight - 10;
    CGFloat leftBottomX = (loadWidth - bottomWidth) * 0.5 + 5;
    CGPoint endPoint = CGPointMake(leftBottomX, bottomY);
    
    //二次贝塞尔曲线 一个控制点 一个终点
    CGPoint control1Point = CGPointMake(0, bodyMinY+bodyHeight*0.9);
    
    /**<  绘制瓶身  >**/
    CGPoint lineEndPoint = CGPointMake(lineX, (lineRightTopY+lineHeight-2));
    [bodyPath moveToPoint:lineEndPoint];
    [bodyPath addQuadCurveToPoint:endPoint controlPoint:control1Point];
    
    CAShapeLayer *bodyLayer = [CAShapeLayer layer];
    bodyLayer.path = bodyPath.CGPath;
    bodyLayer.lineWidth = bottleWidth;
    bodyLayer.fillColor = [UIColor clearColor].CGColor;
    bodyLayer.strokeColor = BotttleColor.CGColor;
    [self.loadingView.layer addSublayer:bodyLayer];
    
    self.bodyLayer = bodyLayer;
}

/**
 翻转之前创建的layer 得到瓶子另一半
 */
- (void)summaryRotateLayers
{
    CGFloat tx = loadWidth;
    CGAffineTransform trans = CGAffineTransformMake(-1, 0, 0, 1, tx, 0);
    
    //瓶口
    CAShapeLayer *otherTopLayer = [CAShapeLayer layer];
    otherTopLayer.path = self.topLayer.path;
    otherTopLayer.affineTransform = trans;
    otherTopLayer.lineWidth = bottleWidth;
    otherTopLayer.fillColor = BotttleColor.CGColor;
    otherTopLayer.strokeColor = [UIColor clearColor].CGColor;
    [self.loadingView.layer addSublayer:otherTopLayer];
    
    //瓶颈
    CAShapeLayer *otherNeckLayer = [CAShapeLayer layer];
    otherNeckLayer.path = self.neckLayer.path;
    otherNeckLayer.affineTransform = trans;
    otherNeckLayer.lineWidth = bottleWidth;
    otherNeckLayer.fillColor = [UIColor clearColor].CGColor;
    otherNeckLayer.strokeColor = BotttleColor.CGColor;
    [self.loadingView.layer addSublayer:otherNeckLayer];
    
    //瓶身
    CAShapeLayer *otherBodyLayer = [CAShapeLayer layer];
    otherBodyLayer.path = self.bodyLayer.path;
    otherBodyLayer.affineTransform = trans;
    otherBodyLayer.lineWidth = bottleWidth;
    otherBodyLayer.fillColor = [UIColor clearColor].CGColor;
    otherBodyLayer.strokeColor = BotttleColor.CGColor;
    [self.loadingView.layer addSublayer:otherBodyLayer];
    self.otherBodyLayer = otherBodyLayer;
}

/**
 绘制瓶底
 */
- (void)drawBottleBottomLayer
{
    //创建path
    UIBezierPath *bottomPath = [UIBezierPath bezierPath];
    bottomPath.lineWidth = bottleWidth;
    // 终点处理：设置结束点曲线
    bottomPath.lineCapStyle = kCGLineCapRound;
    // 拐角处理：设置两个连接点曲线
    bottomPath.lineJoinStyle = kCGLineJoinRound;
    
    //瓶底左侧点 曲线结束点
    CGFloat bottomY = loadHeight - marginSpace;
    CGFloat leftBottomX = (loadWidth - bottomWidth) * 0.5 + 4;
    CGFloat rightBottomX = leftBottomX + bottomWidth - 8;
    CGPoint leftBeginPoint = CGPointMake(leftBottomX, bottomY);
    CGPoint rightEndPoint = CGPointMake(rightBottomX, bottomY);
    
    /**<  绘制瓶底  >**/
    [bottomPath moveToPoint:leftBeginPoint];
    [bottomPath addLineToPoint:rightEndPoint];
    
    CAShapeLayer *bottomLayer = [CAShapeLayer layer];
    bottomLayer.path = bottomPath.CGPath;
    bottomLayer.lineWidth = bottleWidth;
    bottomLayer.fillColor = [UIColor clearColor].CGColor;
    bottomLayer.strokeColor = BotttleColor.CGColor;
    [self.loadingView.layer addSublayer:bottomLayer];
    self.bottomLayer = bottomLayer;
}

/**
 绘制水的边缘
 */
- (void)drawWaterRoundLayer
{
    //左侧边缘
    CGAffineTransform scaleTrans = CGAffineTransformMakeScale(1.1, 0.99);
    CAShapeLayer *waterLeftLayer = [CAShapeLayer layer];
    waterLeftLayer.path = self.bodyLayer.path;
    waterLeftLayer.affineTransform = scaleTrans;
    waterLeftLayer.lineWidth = waterRoundWidth;
    waterLeftLayer.fillColor = [UIColor clearColor].CGColor;
    waterLeftLayer.strokeColor = SpaceColor.CGColor;
    [self.loadingView.layer addSublayer:waterLeftLayer];
    
    //右侧边缘
    CGFloat tx = loadWidth;
    CGAffineTransform rotateTrans = CGAffineTransformMake(-1, 0, 0, 1, tx, 0);
    CGAffineTransform concat1Trans = CGAffineTransformConcat(scaleTrans, rotateTrans);
    CAShapeLayer *waterRightLayer = [CAShapeLayer layer];
    waterRightLayer.path = waterLeftLayer.path;
    waterRightLayer.affineTransform = concat1Trans;
    waterRightLayer.lineWidth = waterRoundWidth;
    waterRightLayer.fillColor = [UIColor clearColor].CGColor;
    waterRightLayer.strokeColor = SpaceColor.CGColor;
    [self.loadingView.layer addSublayer:waterRightLayer];
    
    //底边
    CGAffineTransform bScaleTrans = CGAffineTransformMakeScale(0.99, 1.0);
    CGAffineTransform bMoveTrans = CGAffineTransformMakeTranslation(0, -bottleWidth+2);
    CGAffineTransform bEndTrans = CGAffineTransformConcat(bScaleTrans, bMoveTrans);
    CAShapeLayer *otherBottomLayer = [CAShapeLayer layer];
    otherBottomLayer.path = self.bottomLayer.path;
    otherBottomLayer.affineTransform = bEndTrans;
    otherBottomLayer.lineWidth = waterRoundWidth;
    otherBottomLayer.fillColor = [UIColor clearColor].CGColor;
    otherBottomLayer.strokeColor = SpaceColor.CGColor;
    [self.loadingView.layer addSublayer:otherBottomLayer];
}

/**
 绘制靠近底部的静态的水
 */
- (void)drawStaticWaterLayer
{
    CGFloat waterHeight = bodyHeight * 0.5;
    //静态水
    CGFloat waterMinY = loadHeight - marginSpace - waterHeight;
    CGFloat leftMinX = (loadWidth - bottomWidth) * 0.5 - bottomWidth*0.2;
    CGFloat rightMaxX = loadWidth - leftMinX;
    CGPoint startPoint = CGPointMake(leftMinX, waterMinY);
    CGPoint endPoint = CGPointMake(rightMaxX, waterMinY);
    
    CGFloat leftTurnX = (loadWidth - bottomWidth) * 0.5;
    CGFloat rightTurnX = loadWidth - leftTurnX;
    CGFloat turnY = loadHeight - marginSpace - 2;
    CGPoint leftTurnPoint = CGPointMake(leftTurnX, turnY);
    CGPoint rightTurnPoint = CGPointMake(rightTurnX, turnY);
    
    UIBezierPath *waterPath = [UIBezierPath bezierPath];
    [waterPath moveToPoint:startPoint];
    [waterPath addLineToPoint:leftTurnPoint];
    [waterPath addLineToPoint:rightTurnPoint];
    [waterPath addLineToPoint:endPoint];
    [waterPath closePath];
    
    CAShapeLayer *waterLayer = [CAShapeLayer layer];
    waterLayer.path = waterPath.CGPath;
    waterLayer.lineWidth = 0.1;
    waterLayer.fillColor = WaterColor.CGColor;
    waterLayer.strokeColor = [UIColor clearColor].CGColor;
    [self.loadingView.layer insertSublayer:waterLayer below:self.bottomLayer];
    
}


/**
 绘制水波
 */
- (void)drawWaterWaveLayer
{
    
}

/**
 绘制水滴
 */
- (void)drawWaterDropLayer
{
    
}

@end
