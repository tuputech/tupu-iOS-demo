//
//  TPLandmarkFilter.m
//  TUPUFaceDemo
//
//  Created by drakeDan on 11/01/2017.
//  Copyright © 2017 tupu. All rights reserved.
//

#import "TPLandmarkFilter.h"

NSString *const kTPLandmarkVertexShaderString = SHADER_STRING
(
    attribute vec4 position;
 
 void main()
 {
     gl_Position = position;
     gl_PointSize = 4.0;
 }
 );

NSString *const kTPLandmarkFragmentShaderString = SHADER_STRING
(
 precision mediump float;
 void main()
 {
     gl_FragColor = vec4(0.2039, 0.81, 0.63, 1.0);
 }
 );

@implementation TPLandmarkFilter

- (id) init {
    if (!(self = [super initWithVertexShaderFromString:kTPLandmarkVertexShaderString fragmentShaderFromString:kTPLandmarkFragmentShaderString])) {
        
    }
    return self;
}


- (void) newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    if (self.renderDelegate != nil) {
        runAsynchronouslyOnVideoProcessingQueue(^{
            glFinish();
            @synchronized (self) {
                [self.renderDelegate TPRendererWillBeginRender:firstInputFramebuffer];
            }
        });
    }
    
    GLfloat points[83 * 2] = {0.0};
    @synchronized (self) {
        
        for (int i = 0; i < self.faces.count; i++) {
            CGPoint p = [self.faces[i] CGPointValue];
            points[2*i]   = (p.x / firstInputFramebuffer.size.width)*2 - 1.0;
            points[2*i+1] = (p.y / firstInputFramebuffer.size.height)*2 - 1.0;
        }
    }
    
    [self renderToTextureWithVertices:points textureCoordinates:[[self class] textureCoordinatesForRotation:inputRotation]];
    [self informTargetsAboutNewFrameAtTime:frameTime];
}

- (void) renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates {
    if (self.preventRendering)
    {
        [firstInputFramebuffer unlock];
        return;
    }
    
    if (usingNextFrameForImageCapture)
    {
        [firstInputFramebuffer lock];
    }
    
    [firstInputFramebuffer activateFramebuffer];
    
    [GPUImageContext setActiveShaderProgram:filterProgram];
    if (self.faces.count > 0) {
        glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
        glDrawArrays(GL_POINTS, 0, (int)self.faces.count);
    }
    
    if (!CGRectIsNull(self.rect)) {
        GLfloat tempRect[] = {
            (self.rect.origin.x / firstInputFramebuffer.size.width)*2 - 1.0, (self.rect.origin.y / firstInputFramebuffer.size.height)*2 - 1.0,
            (self.rect.origin.x / firstInputFramebuffer.size.width)*2 - 1.0, (self.rect.size.height / firstInputFramebuffer.size.height)*2 - 1.0,
            (self.rect.size.width / firstInputFramebuffer.size.width)*2 - 1.0, (self.rect.size.height / firstInputFramebuffer.size.height)*2 - 1.0,
            (self.rect.size.width / firstInputFramebuffer.size.width)*2 - 1.0, (self.rect.origin.y / firstInputFramebuffer.size.height)*2 - 1.0
        };
        
        GLubyte indices[] = {
            0,1,1,2,2,3,3,0
        };
        
        glLineWidth(5);
        glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, tempRect);
        glDrawElements(GL_LINES, sizeof(indices)/sizeof(GLubyte), GL_UNSIGNED_BYTE, indices);
    }
    
    outputFramebuffer = firstInputFramebuffer;
    
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
    
    if (self.renderDelegate != nil && [self.renderDelegate respondsToSelector:@selector(TPRendererDidFinishRender:)]) {
        glFlush();
        [outputFramebuffer lock];
        runAsynchronouslyOnVideoProcessingQueue(^{
            [self.renderDelegate TPRendererDidFinishRender:outputFramebuffer];
            [outputFramebuffer unlock];
        });
    }
    
}

@end
