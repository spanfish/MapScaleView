//
//  MapScaleView.h
//
//  Created by xiangwei wang on 2016/11/25.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapScaleView : UIView

+(MapScaleView*)mapScaleViewForMapView:(MKMapView*)aMapView;

-(void)update;
@end
