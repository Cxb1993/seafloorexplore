//
//  BenthosGLView.h
//  SeafloorExplore
//
//  Modified from Brad Larson's Molecules Project in 2011-2012 for use in The SeafloorExplore Project
//
//  Copyright (C) 2012 Matthew Johnson-Roberson
//
//  See COPYING for license details
//  
//  Molecules
//
//  The source code for Molecules is available under a BSD license.  See COPYING for details.
//
//  Created by Brad Larson on 5/18/2008.
//
//  This view manages the OpenGL scene, with setup and rendering methods.  Multitouch events are also handled
//  here, although it might be best to refactor some of the code up to a controller.

#import <UIKit/UIKit.h>

@class BenthosOpenGLESRenderer;

@interface BenthosGLView : UIView
{
    BenthosOpenGLESRenderer *openGLESRenderer;
    CGSize previousSize;
}

@property(readonly) BenthosOpenGLESRenderer *openGLESRenderer;

@end
