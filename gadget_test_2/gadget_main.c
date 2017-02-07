//
//  Modifications in this file
//
//  The original main function was split into two parts: one part for setup,
//  the other part for running the main simulation loop. This was done mainly to
//  allow the main simulation loop to be run on a seperate thread while avoiding
//  the mixed use of Swift code in the original GADGET program. (and to avoid
//  duplicate symbols for main)
//


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "allvars.h"
#include "proto.h"


 
/*
 *  This function initializes the cpu-time counters to 0.
 *  Then begrun() is called, which sets up the simulation
 *  either from IC's or from restart files.
 *  Finally, run() is started, the main simulation loop,
 *  which iterates over the timesteps.
 */
int gadget_main_setup() {
    double t0, t1;
    
    //  if(argc<2) {
    //      fprintf(stdout,"Parameters are missing.\n");
    //      fprintf(stdout,"Call with <ParameterFile> [<RestartFlag>]\n");
    //      exit(1);
    //  }
    
    //  strcpy(ParameterFile,argv[1]);
    //
    //  if(argc>=3)
    //    RestartFlag= atoi(argv[2]);
    //  else
    //    RestartFlag=0;
    
    // MODIFICATION
    // temp, parameter file name not read from stdin
    // should find a way to use NSBundle method to fetch path of parameter file
    // in actual implementation on an iPad
    strcpy(ParameterFile, "");//"/Users/lukajelenak/Documents/gadget_test_2/gadget_test_2/parameterfiles/test.tex");
    RestartFlag = 0; // set RestartFlag = 2 to read from snapshot
    
    
    All.CPU_TreeConstruction=All.CPU_TreeWalk=All.CPU_Gravity=All.CPU_Potential=
    All.CPU_Snapshot=All.CPU_Total=All.CPU_Hydro=
    All.CPU_Predict= All.CPU_TimeLine= 0;
    
    CPUThisRun=0;
    
    t0 = second();
    
    begrun();     /* set-up run  */
    
    t1 = second();
    CPUThisRun += timediff(t0, t1);
    All.CPU_Total += timediff(t0, t1);
    
    return 0;
}

int gadget_main_run() {
    
    
    run();       /* main simulation loop */
    
    
    return 0;
}




