//
//  ViewController.m
//  MapScaleView
//
//  Created by xiangwei wang on 11/26/16.
//  Copyright © 2016 xiangwei wang. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import <Masonry.h>
#import "MapScaleView.h"

@interface ViewController () {
    NSTimer *elevationTimer;
}

@property(nonatomic, strong) NSLayoutConstraint *mapScaleViewLeftConstraint;
@property(nonatomic, weak) IBOutlet MKMapView *mapView;
@property(nonatomic, strong) MapScaleView *mapScaleView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.showsScale = YES;
    // Do any additional setup after loading the view, typically from a nib.
    
    self.mapScaleView = [MapScaleView mapScaleViewForMapView: self.mapView];
    
    [self.mapScaleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(100);
        make.left.mas_equalTo(10);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    
    elevationTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                      target:self
                                                    selector:@selector(updateElevationLabel)
                                                    userInfo:Nil
                                                     repeats:YES];
    [elevationTimer fire];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    // enforce maximum zoom level
    
    [elevationTimer invalidate];
    [self.mapScaleView update];
}

-(void)updateElevationLabel {
    [self.mapScaleView update];
}


@end
