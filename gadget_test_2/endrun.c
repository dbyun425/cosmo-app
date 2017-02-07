#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>


#include "allvars.h"
#include "proto.h"



/*  This function aborts the simulations.
 */
void endrun(int ierr)
{
  if(ierr)
    {
      fprintf(stdout,"endrun called with an error level of %d\n\n\n", ierr);
      exit(1);
    }
  exit(0);
}
