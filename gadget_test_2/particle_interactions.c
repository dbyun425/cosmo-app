//
//  particle_interactions.c
//  gadget_test_2
//
//  Created by Peter Lee on 8/5/15.
//  Copyright (c) 2015 Peter Lee. All rights reserved.
//
//  A routine that modifies the acceleration of all particles with respect to
//  a specified touch location on the graphical interface
//
//  This routine no longer modifies acceleration, or any parameters used to calculate
//  time steps, it now uses an "added velocity" parameter so that the particles can
//  be moved without changing their velocity while giving the ability to break apart
//  galaxies
//

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "allvars.h"

void modify_accel() {
    //for (int i = 1; i <= NumPart; i++) P[i].Vel[2] = 0;
    
    if (interaction == 0){
        for(int i = 1; i <= NumPart; i++) {
            P[i].addedVel[0] = P[i].Vel[0];
            P[i].addedVel[1] = P[i].Vel[1];
        }
        // no current interactions
        return;
    }
    
    // > 0 for attractive, < 0 for repulsive
    float attractionFactor = 10000.0 * interactionFactor;
    accelerationFactor = attractionFactor;
    
    float touchX = touchLocation[0];
    float touchY = touchLocation[1];
    float touchZ = touchLocation[2];
    P[1].Pos[0] = touchX;
    P[1].Pos[1] = touchY;
    P[1].Mass = attractionFactor;
    
    //printf("touch: %f %f %f\n", touchX, touchY, touchZ);
    /*
    // update the acceleration for each particle
    // Note: particle indexing is [1, n] in origianl GADGET code for some weird reason
    for (int i = 1; i <= NumPart; i++) {
        float partX = P[i].Pos[0];
        float partY = P[i].Pos[1];
        //float partZ = P[i].Pos[2];
        
        // distance from touch to particle
        float softening = 500.0; // to avoid infinite acceleration
        float deltaX = (touchX - partX);
        float deltaY = (touchY - partY);
        //float deltaZ = (touchZ - partZ);
        //float dist = sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ) + softening;
        float dist = sqrt(deltaX * deltaX + deltaY * deltaY) + softening;
        
        float accelMag = attractionFactor / (dist * dist);
        float accelX = accelMag * (deltaX / dist);
        float accelY = accelMag * (deltaY / dist);
        //float accelZ = accelMag * (deltaZ / dist);
        
        P[i].addedVel[0] += accelX;
        P[i].addedVel[1] += accelY;
        
        P[i].Pos[0] += P[i].addedVel[0] * 0.000001;
        P[i].Pos[1] += P[i].addedVel[1] * 0.000001;
        P[i].Accel[2] = 0;
    }
    */
    /*
     } else {
    
        for (int i = 1; i <= NumPart; i++) {
            float range = 10000.0;
            float partX = P[i].Pos[0];
            float partY = P[i].Pos[1];
            
            float dist = sqrt((partX-touchX)*(partX-touchX)+(partY-touchY)*(partY-touchY));
            if(range - dist >= 0.0) {
                P[i].Pos[0] += 100.0 * (partX-touchX) / dist;
                P[i].Pos[1] += 100.0 * (partY-touchY) / dist;
            }
        } */
    
}
