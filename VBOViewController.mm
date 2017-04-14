//
//  Copyright © 2017 Tomasz Slanina. All rights reserved.
//

#import "VBOViewController.h"
#include "shellTRI.h"

static const NSInteger playfieldWidth   = 480;
static const NSInteger playfieldHeight  = 640;

@interface VBOViewController(){
    
    // GL
    EAGLContext *_context;
    CGFloat     _modelScale;
    CGSize      _sceneSize;
    CGVector    _displace;
  
    // Test object params
    CGPoint     _center;
    NSInteger   _i;
    CGFloat     _angle;
    CGFloat     _scale;
}
@end

@implementation VBOViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    if (!_context) {
        NSLog(@"Failed to create ES context");
    }
    GLKView *view = (GLKView *)self.view;
    view.context = _context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormatNone;
    view.enableSetNeedsDisplay = NO;
    [EAGLContext setCurrentContext:_context];
    self.preferredFramesPerSecond = 30;
    
    [self setupGLwithSize:[[UIScreen mainScreen] bounds].size
               nativeSize:[[UIScreen mainScreen] nativeBounds].size];
    _center = CGPointZero;
    _i = 0;
    _angle = 0.0;
    _scale = 1.0;
}

-(void)dealloc{
   [EAGLContext setCurrentContext:_context];
    
    if ([EAGLContext currentContext] == _context) {
        [EAGLContext setCurrentContext:nil];
    }
}

#pragma mark - GLKView and GLKViewController delegate methods

-(void)update{
    _i = (_i+1)%360;
    _center = CGPointMake(playfieldWidth/2+100.0 * sin( 3.14 * _i / 30.0),
                          playfieldHeight/2+200.0 * cos( 3.14 * _i / 60.0));
    _angle = 60.0 * sin( 3.14 * _i / 90.0);
    _scale = 2+1.8 * sin( 3.14 * _i / 45.0);
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    glTranslatef(_displace.dx, _displace.dy, 0);
    glScalef(_modelScale, _modelScale, 1);
    
    glClearColor(0,0,0,0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glTranslatef(_center.x, _center.y,0);
    glRotatef(_angle, 0, 0, 1);
    glScalef(_scale, _scale, 1);
    
    
    /* draw VBO */

    glVertexPointer(	2, GL_SHORT,			sizeof(GLData2D), &shellTRIData[0].x);
    glColorPointer(	4, GL_UNSIGNED_BYTE,	sizeof(GLData2D), &shellTRIData[0].r);
    
    /*
     For GLfloat vertex format, use:
     
     glVertexPointer(	2, GL_FLOAT,			sizeof(GLData2Df), &shellTRIData[0].x);
     glColorPointer(    4, GL_UNSIGNED_BYTE,	sizeof(GLData2Df), &shellTRIData[0].r);
     
    */
    
    glDrawElements(GL_TRIANGLES, shellTRINumTriangles, GL_UNSIGNED_SHORT, shellTRIIdx);
}

#pragma mark - GL setup

-(void) setupGLwithSize:(CGSize)size
             nativeSize:(CGSize)nativeSize {

    if(nativeSize.width > nativeSize.height ){
        nativeSize = CGSizeMake(nativeSize.height,
                                nativeSize.width);
    }
    
    _sceneSize = CGSizeMake(playfieldWidth, playfieldHeight);
    _modelScale = MIN((nativeSize.width/_sceneSize.width),
                      (nativeSize.height/_sceneSize.height));
    _displace = CGVectorMake( (nativeSize.width - _sceneSize.width*_modelScale) /2,
                             (nativeSize.height - _sceneSize.height*_modelScale) /2);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrthof(0, nativeSize.width, nativeSize.height, 0, -1.0f, 1.0f);
    glViewport(0, 0, nativeSize.width, nativeSize.height);
}


@end
