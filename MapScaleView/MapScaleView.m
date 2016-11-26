//
//  MapScaleView.m
//
//  Created by xiangwei wang on 2016/11/25.
//

#import "MapScaleView.h"
#import <Masonry.h>

#define kDefaultViewRect CGRectMake(0, 0, 160, 30)
#define kZeroLabelRect CGRectMake(0, 0, 8, 10)
#define kTextColor [UIColor blackColor]
#define kBarColor [UIColor blackColor]
#define kAlterBarColor [UIColor whiteColor]

@interface MapScaleView() {
    MKMapView* mapView;
    UILabel* zeroLabel;
    UILabel* maxLabel;
    //比例尺实际宽度
    double scaleWidthInPixels;
}

@end

@implementation MapScaleView

+ (MapScaleView*)mapScaleViewForMapView:(MKMapView*)aMapView {
    if(!aMapView) {
        return nil;
    }
    
    for(UIView* subview in aMapView.subviews) {
        if([subview isKindOfClass:[MapScaleView class]]) {
            return (MapScaleView*)subview;
        }
    }
    
    return [[MapScaleView alloc] initWithMapView:aMapView];
}

-(id)initWithMapView:(MKMapView*)aMapView {
    if((self = [super initWithFrame:kDefaultViewRect])) {
        self.opaque = NO;
        self.clipsToBounds = NO;
        self.userInteractionEnabled = NO;
        mapView = aMapView;
        
        [self constructViews];
    }
    
    return self;
}

-(void)constructViews {
    UIFont* font = [UIFont systemFontOfSize:12.0f];
    zeroLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    zeroLabel.backgroundColor = [UIColor clearColor];
    zeroLabel.textColor = kTextColor;
    zeroLabel.shadowColor = [UIColor blackColor];
    zeroLabel.shadowOffset = CGSizeMake(1, 1);
    zeroLabel.text = @"0";
    zeroLabel.font = font;
    [self addSubview:zeroLabel];
    
    maxLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    maxLabel.backgroundColor = [UIColor clearColor];
    maxLabel.textColor = kTextColor;
    maxLabel.shadowColor = [UIColor blackColor];
    maxLabel.shadowOffset = CGSizeMake(1, 1);
    maxLabel.text = @"1 m";
    maxLabel.font = font;
    maxLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:maxLabel];

    [mapView addSubview:self];
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(CGRectGetWidth(kDefaultViewRect));
        make.height.mas_equalTo(CGRectGetHeight(kDefaultViewRect));
    }];
    
    [zeroLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(CGRectGetWidth(kZeroLabelRect));
        make.height.mas_equalTo(CGRectGetHeight(kZeroLabelRect));
    }];
    
    [maxLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.equalTo(self);
        make.height.mas_equalTo(zeroLabel.mas_height);
    }];
}

- (void)update {
    if(!mapView || !mapView.bounds.size.width) {
        return;
    }
    //比例尺默认大小时，左边和右边点的地理坐标
    CLLocationCoordinate2D west = [mapView convertPoint:CGPointMake(CGRectGetMinX(kDefaultViewRect), CGRectGetMinY(kDefaultViewRect))
                                   toCoordinateFromView:mapView];
    CLLocationCoordinate2D east = [mapView convertPoint:CGPointMake(CGRectGetMaxX(kDefaultViewRect), CGRectGetMinY(kDefaultViewRect))
                                   toCoordinateFromView:mapView];
    //左边到右边的距离，米
    CLLocationDistance horizontalDistance = MKMetersBetweenMapPoints(MKMapPointForCoordinate(west), MKMapPointForCoordinate(east));
    //屏幕上每个点代表的米数
    double metersPerPixel = horizontalDistance / CGRectGetWidth(kDefaultViewRect);

    NSUInteger maxValue = 0;
    NSString* unit = @"";

    static const NSUInteger kMeterScale[] = {1, 2, 5, 10, 20, 50, 100, 200, 500, 1000, 2000,
    5000, 10000, 20000, 50000, 100000, 200000, 500000, 1000000, 2000000, 5000000, 10000000, 20000000, 50000000};
    
    int i = sizeof(kMeterScale)/sizeof(NSUInteger);

    while(i > 0 && kMeterScale[--i] / metersPerPixel > CGRectGetWidth(kDefaultViewRect)) {

    }
    if(i >= 0) {
        maxValue = kMeterScale[i];
        //比例尺实际宽度
        scaleWidthInPixels = maxValue / metersPerPixel;
        if(kMeterScale[i] >= 1000) {
            unit = @"km";
            maxValue /= 1000;
        } else {
            unit = @"m";
        }
    }
    
    maxLabel.text = [NSString stringWithFormat:@"%ld %@", (unsigned long)maxValue, unit];
    [self setNeedsUpdateConstraints];
    [self setNeedsDisplay];
}

-(void) updateConstraints {
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(scaleWidthInPixels);
        make.height.mas_equalTo(CGRectGetHeight(kDefaultViewRect));
    }];
    
    [super updateConstraints];
}

- (void)drawRect:(CGRect)aRect {
    if(!mapView) {
        return;
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect scaleRect = CGRectMake(0, 12, scaleWidthInPixels, 3);
    
    [kBarColor setFill];
    CGContextFillRect(ctx, CGRectInset(scaleRect, -1, -1));
    
    [kAlterBarColor setFill];
    CGRect unitRect = scaleRect;
    unitRect.size.width = scaleWidthInPixels / 5.0f;
    
    for(int i = 0; i < 5; i+=2) {
        unitRect.origin.x = scaleRect.origin.x + unitRect.size.width*i;
        CGContextFillRect(ctx, unitRect);
    }
}
@end
