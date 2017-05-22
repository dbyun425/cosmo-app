//
//  Modifications in this file
//
//  Added variables for user interaction with particles
//  Added string pathways and game pause boolean
//

#include "allvars.h"


 int    NumForceUpdate, NumSphUpdate, IndFirstUpdate;
 int    TimeTreeRoot;

 int    Num_nodeupdates, Num_nodeupdate_particles;

 int    RestartFlag;

 int    NumPart,        /* Note: these are the LOCAL process values */
              N_gas;


/* variables for input/output ,  usually only used on process 0 */

  char   ParameterFile[100];
  FILE  *FdInfo,
              *FdEnergy,
              *FdTimings,
              *FdCPU;


/* tabulated smoothing kernel */

 double  Kernel[KERNEL_TABLE+2],
               KernelDer[KERNEL_TABLE+2],
               KernelRad[KERNEL_TABLE+2];


 double  CPUThisRun;


 struct global_data_all_processes  /* this struct contains data which is the same for all tasks 
                                            (mostly code parameters read from the parameter file) */
 All;




/* The following structure holds all the information that is
 * stored for each particle of the simulation.
 */
 struct particle_data 
 *P,*P_data;



/* the following struture holds data that is stored for each SPH particle
 * in addition to the collisionless variables.
 */
 struct sph_particle_data
 *SphP,*SphP_data;



/* this structure holds nodes for the ordered binary tree of the timeline.
 */
 struct timetree_data
 *PTimeTree;   /* for ordered binary tree of max pred. times */



/* state of total system */

 struct state_of_system 
   SysState,SysStateAtStart,SysStateAtEnd;




/* Header for the standard file format.
 */
 struct io_header_1
 header1;

// MODIFICATION
// global variables for interactions with particles
int interaction;
float interactionFactor;
float touchLocation[3];
float accelerationFactor;

//Adding string for pathways
char* ewaldPath;
char* icsPath;

//Pausing
int gamePause;

//Choosing Levels
int level;
int playing;




