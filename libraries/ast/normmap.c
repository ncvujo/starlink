/*
*class++
*  Name:
*     NormMap

*  Purpose:
*     Normalise coordinates using a supplied Frame.

*  Constructor Function:
c     astNormMap
f     AST_NORMMAP

*  Description:
*     The NormMap class implements a Mapping which normalises coordinate 
*     values using the 
c     astNorm function
f     AST_NORM routine
*     of a supplied Frame. The number of inputs and outputs of a NormMap
*     are both equal to the number of axes in the supplied Frame.
*
*     The forward and inverse transformation of a NormMap are both
*     defined but are identical (that is, they do not form a real inverse 
*     pair in that the inverse transformation does not undo the
*     normalisation, instead it reapplies it). However, the 
c     astSimplify
f     AST_SIMPLIFY
*     function will replace neighbouring pairs of forward and inverse 
*     NormMaps by a single UnitMap.

*  Inheritance:
*     The NormMap class inherits from the Mapping class.

*  Attributes:
*     The MatrixMap class does not define any new attributes beyond
*     those which are applicable to all Mappings.

*  Functions:
c     The NormMap class does not define any new functions beyond those
f     The NormMap class does not define any new routines beyond those
*     which are applicable to all Mappings.

*  Copyright:
*     <COPYRIGHT_STATEMENT>

*  Authors:
*     DSB: David S. Berry (Starlink)

*  History:
*     11-JUL-2005 (DSB):
*        Original version.
*class--
*/

/* Module Macros. */
/* ============== */
/* Set the name of the class we are implementing. This indicates to
   the header files that define class interfaces that they should make
   "protected" symbols available. */
#define astCLASS NormMap

/* Include files. */
/* ============== */
/* Interface definitions. */
/* ---------------------- */
#include "error.h"               /* Error reporting facilities */
#include "memory.h"              /* Memory allocation facilities */
#include "object.h"              /* Base Object class */
#include "pointset.h"            /* Sets of points/coordinates */
#include "mapping.h"             /* Coordinate mappings (parent class) */
#include "channel.h"             /* I/O channels */
#include "unitmap.h"             /* Unit Mappings */
#include "normmap.h"             /* Interface definition for this class */

/* Error code definitions. */
/* ----------------------- */
#include "ast_err.h"             /* AST error codes */

/* C header files. */
/* --------------- */
#include <float.h>
#include <math.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>

/* Module Variables. */
/* ================= */
/* Define the class virtual function table and its initialisation flag
   as static variables. */
static AstNormMapVtab class_vtab; /* Virtual function table */
static int class_init = 0;       /* Virtual function table initialised? */

/* Pointers to parent class methods which are extended by this class. */
static AstPointSet *(* parent_transform)( AstMapping *, AstPointSet *, int, AstPointSet * );
static int *(* parent_mapsplit)( AstMapping *, int, int *, AstMapping ** );

/* External Interface Function Prototypes. */
/* ======================================= */
/* The following functions have public prototypes only (i.e. no
   protected prototypes), so we must provide local prototypes for use
   within this module. */
AstNormMap *astNormMapId_( void *, const char *, ... );

/* Prototypes for Private Member Functions. */
/* ======================================== */
static AstPointSet *Transform( AstMapping *, AstPointSet *, int, AstPointSet * );
static double Rate( AstMapping *, double *, int, int);
static int MapMerge( AstMapping *, int, int, int *, AstMapping ***, int ** );
static void Copy( const AstObject *, AstObject * );
static void Delete( AstObject * );
static void Dump( AstObject *, AstChannel * );
static int *MapSplit( AstMapping *, int, int *, AstMapping ** );

/* Member functions. */
/* ================= */

void astInitNormMapVtab_(  AstNormMapVtab *vtab, const char *name ) {
/*
*+
*  Name:
*     astInitNormMapVtab

*  Purpose:
*     Initialise a virtual function table for a NormMap.

*  Type:
*     Protected function.

*  Synopsis:
*     #include "normmap.h"
*     void astInitNormMapVtab( AstNormMapVtab *vtab, const char *name )

*  Class Membership:
*     NormMap vtab initialiser.

*  Description:
*     This function initialises the component of a virtual function
*     table which is used by the NormMap class.

*  Parameters:
*     vtab
*        Pointer to the virtual function table. The components used by
*        all ancestral classes will be initialised if they have not already
*        been initialised.
*     name
*        Pointer to a constant null-terminated character string which contains
*        the name of the class to which the virtual function table belongs (it 
*        is this pointer value that will subsequently be returned by the Object
*        astClass function).
*-
*/

/* Local Variables: */
   AstObjectVtab *object;        /* Pointer to Object component of Vtab */
   AstMappingVtab *mapping;      /* Pointer to Mapping component of Vtab */

/* Check the local error status. */
   if ( !astOK ) return;

/* Initialize the component of the virtual function table used by the
   parent class. */
   astInitMappingVtab( (AstMappingVtab *) vtab, name );

/* Store a unique "magic" value in the virtual function table. This
   will be used (by astIsANormMap) to determine if an object belongs
   to this class.  We can conveniently use the address of the (static)
   class_init variable to generate this unique value. */
   vtab->check = &class_init;

/* Initialise member function pointers. */
/* ------------------------------------ */
/* Store pointers to the member functions (implemented here) that provide
   virtual methods for this class. */

/* Save the inherited pointers to methods that will be extended, and
   replace them with pointers to the new member functions. */
   object = (AstObjectVtab *) vtab;
   mapping = (AstMappingVtab *) vtab;

   parent_transform = mapping->Transform;
   mapping->Transform = Transform;

   parent_mapsplit = mapping->MapSplit;
   mapping->MapSplit = MapSplit;

/* Store replacement pointers for methods which will be over-ridden by
   new member functions implemented here. */
   mapping->MapMerge = MapMerge;
   mapping->MapSplit = MapSplit;
   mapping->Rate = Rate;

/* Declare the copy constructor, destructor and class dump function. */
   astSetDump( vtab, Dump, "NormMap", "Normalise axis values" );
   astSetCopy( vtab, Copy );
   astSetDelete( vtab, Delete );
}

static int MapMerge( AstMapping *this, int where, int series, int *nmap,
                     AstMapping ***map_list, int **invert_list ) {
/*
*  Name:
*     MapMerge

*  Purpose:
*     Simplify a sequence of Mappings containing a NormMap.

*  Type:
*     Private function.

*  Synopsis:
*     #include "mapping.h"
*     int MapMerge( AstMapping *this, int where, int series, int *nmap,
*                   AstMapping ***map_list, int **invert_list )

*  Class Membership:
*     NormMap method (over-rides the protected astMapMerge method
*     inherited from the Mapping class).

*  Description:
*     This function attempts to simplify a sequence of Mappings by
*     merging a nominated NormMap in the sequence with its neighbours,
*     so as to shorten the sequence if possible.
*
*     In many cases, simplification will not be possible and the
*     function will return -1 to indicate this, without further
*     action.
*
*     In most cases of interest, however, this function will either
*     attempt to replace the nominated NormMap with one which it
*     considers simpler, or to merge it with the Mappings which
*     immediately precede it or follow it in the sequence (both will
*     normally be considered). This is sufficient to ensure the
*     eventual simplification of most Mapping sequences by repeated
*     application of this function.
*
*     In some cases, the function may attempt more elaborate
*     simplification, involving any number of other Mappings in the
*     sequence. It is not restricted in the type or scope of
*     simplification it may perform, but will normally only attempt
*     elaborate simplification in cases where a more straightforward
*     approach is not adequate.

*  Parameters:
*     this
*        Pointer to the nominated NormMap which is to be merged with
*        its neighbours. This should be a cloned copy of the NormMap
*        pointer contained in the array element "(*map_list)[where]"
*        (see below). This pointer will not be annulled, and the
*        NormMap it identifies will not be modified by this function.
*     where
*        Index in the "*map_list" array (below) at which the pointer
*        to the nominated NormMap resides.
*     series
*        A non-zero value indicates that the sequence of Mappings to
*        be simplified will be applied in series (i.e. one after the
*        other), whereas a zero value indicates that they will be
*        applied in parallel (i.e. on successive sub-sets of the
*        input/output coordinates).
*     nmap
*        Address of an int which counts the number of Mappings in the
*        sequence. On entry this should be set to the initial number
*        of Mappings. On exit it will be updated to record the number
*        of Mappings remaining after simplification.
*     map_list
*        Address of a pointer to a dynamically allocated array of
*        Mapping pointers (produced, for example, by the astMapList
*        method) which identifies the sequence of Mappings. On entry,
*        the initial sequence of Mappings to be simplified should be
*        supplied.
*
*        On exit, the contents of this array will be modified to
*        reflect any simplification carried out. Any form of
*        simplification may be performed. This may involve any of: (a)
*        removing Mappings by annulling any of the pointers supplied,
*        (b) replacing them with pointers to new Mappings, (c)
*        inserting additional Mappings and (d) changing their order.
*
*        The intention is to reduce the number of Mappings in the
*        sequence, if possible, and any reduction will be reflected in
*        the value of "*nmap" returned. However, simplifications which
*        do not reduce the length of the sequence (but improve its
*        execution time, for example) may also be performed, and the
*        sequence might conceivably increase in length (but normally
*        only in order to split up a Mapping into pieces that can be
*        more easily merged with their neighbours on subsequent
*        invocations of this function).
*
*        If Mappings are removed from the sequence, any gaps that
*        remain will be closed up, by moving subsequent Mapping
*        pointers along in the array, so that vacated elements occur
*        at the end. If the sequence increases in length, the array
*        will be extended (and its pointer updated) if necessary to
*        accommodate any new elements.
*
*        Note that any (or all) of the Mapping pointers supplied in
*        this array may be annulled by this function, but the Mappings
*        to which they refer are not modified in any way (although
*        they may, of course, be deleted if the annulled pointer is
*        the final one).
*     invert_list
*        Address of a pointer to a dynamically allocated array which,
*        on entry, should contain values to be assigned to the Invert
*        attributes of the Mappings identified in the "*map_list"
*        array before they are applied (this array might have been
*        produced, for example, by the astMapList method). These
*        values will be used by this function instead of the actual
*        Invert attributes of the Mappings supplied, which are
*        ignored.
*
*        On exit, the contents of this array will be updated to
*        correspond with the possibly modified contents of the
*        "*map_list" array.  If the Mapping sequence increases in
*        length, the "*invert_list" array will be extended (and its
*        pointer updated) if necessary to accommodate any new
*        elements.

*  Returned Value:
*     If simplification was possible, the function returns the index
*     in the "map_list" array of the first element which was
*     modified. Otherwise, it returns -1 (and makes no changes to the
*     arrays supplied).

*  Notes:
*     - A value of -1 will be returned if this function is invoked
*     with the global error status set, or if it should fail for any
*     reason.
*/

/* Local Variables: */
   AstFrame *frm1;
   AstFrame *frm2;
   AstMapping *smap;
   AstNormMap *map;  
   AstNormMap *nmap1;  
   AstNormMap *nmap2;  
   int cancel;
   int map_inv;      
   int nax;           
   int result;       

/* Initialise. */
   result = -1;

/* Check the inherited status. */
   if ( !astOK ) return result;

/* Initialisation to avoid compiler warnings. */
   nax = 0;

/* Get a pointer to this NormMap. */
   map = (AstNormMap *) this;

/* Temporarily set its Invert flag to the requested value. */
   map_inv = astGetInvert( map );
   astSetInvert( map, ( *invert_list )[ where ] );

/* First try to simplify the NormMap by simplifying its encapsulated
   Frame. */
   smap = astSimplify( map->frame );

/* If any simplification took place, create a new NormMap with the
   simplified Frame. */
   if( smap != (AstMapping *) map->frame ) {
      (void) astAnnul( ( *map_list )[ where ] );
      ( *map_list )[ where ] = (AstMapping *) astNormMap( (AstFrame *) smap, "" );
      result = where;
    
/* The only other simplication which can be performed is to cancel a NormMap
   with its own inverse in series. */
   } else if( series ) {

/* Indicate we have nothing to cancel with as yet. */
      cancel = -1;

/* First consider the lower neighbour. */
      if( where > 0 && astIsANormMap( ( *map_list )[ where - 1 ] ) ) {

/* Check the Invert flags are opposite */
         if( ( *invert_list )[ where ] != ( *invert_list )[ where - 1 ] ) {
            nmap1 = map;
            nmap2 = (AstNormMap *) ( *map_list )[ where - 1 ];             

/* Check the encapsulated Frames are equal. */
            frm1 = nmap1->frame;
            frm2 = nmap2->frame;
            if( astEqual( frm1, frm2 ) ) cancel = where - 1;
            nax = astGetNout( nmap1 );
         }
      }

/* Likewise consider the upper neighbour. */
      if( cancel == -1 && where + 1 < *nmap && 
          astIsANormMap( ( *map_list )[ where + 1 ] ) ) {

         if( ( *invert_list )[ where ] != ( *invert_list )[ where + 1 ] ) {
            nmap1 = map;
            nmap2 = (AstNormMap *) ( *map_list )[ where + 1 ];
            frm1 = nmap1->frame;
            frm2 = nmap2->frame;
            if( astEqual( frm1, frm2 ) ) cancel = where + 1;
            nax = astGetNin( nmap1 );
         }
      }

/* If we can cancel with a neightbour, do so. */
      if( cancel != -1 ) {
         (void) astAnnul( ( *map_list )[ where ] );
         (void) astAnnul( ( *map_list )[ cancel ] );
         ( *map_list )[ where ] = (AstMapping *) astUnitMap( nax, "" );
         ( *invert_list )[ where ] = 0;
         ( *map_list )[ cancel ] = (AstMapping *) astUnitMap( nax, "" );
         ( *invert_list )[ cancel ] = 0;
          result = ( cancel < where ) ? cancel : where;
      }
   }

/* Free resources. */
   smap = astAnnul( smap );

/* Reset the original Invert attribute for the specified NormMap */
   astSetInvert( map, map_inv );

/* If an error occurred, clear the result value. */
   if ( !astOK ) result = -1;

/* Return the result. */
   return result;
}

static int *MapSplit( AstMapping *this_map, int nin, int *in, AstMapping **map ){
/*
*  Name:
*     MapSplit

*  Purpose:
*     Create a Mapping representing a subset of the inputs of an existing
*     NormMap.

*  Type:
*     Private function.

*  Synopsis:
*     #include "normmap.h"
*     int *MapSplit( AstMapping *this, int nin, int *in, AstMapping **map )

*  Class Membership:
*     NormMap method (over-rides the protected astMapSplit method
*     inherited from the Mapping class).

*  Description:
*     This function creates a new Mapping by picking specified inputs from 
*     an existing NormMap. This is only possible if the specified inputs
*     correspond to some subset of the NormMap outputs. That is, there
*     must exist a subset of the NormMap outputs for which each output
*     depends only on the selected NormMap inputs, and not on any of the
*     inputs which have not been selected. If this condition is not met
*     by the supplied NormMap, then a NULL Mapping is returned.

*  Parameters:
*     this
*        Pointer to the NormMap to be split (the NormMap is not actually 
*        modified by this function).
*     nin
*        The number of inputs to pick from "this".
*     in
*        Pointer to an array of indices (zero based) for the inputs which
*        are to be picked. This array should have "nin" elements. If "Nin"
*        is the number of inputs of the supplied NormMap, then each element 
*        should have a value in the range zero to Nin-1.
*     map
*        Address of a location at which to return a pointer to the new
*        Mapping. This Mapping will have "nin" inputs (the number of
*        outputs may be different to "nin"). A NULL pointer will be
*        returned if the supplied NormMap has no subset of outputs which 
*        depend only on the selected inputs.

*  Returned Value:
*     A pointer to a dynamically allocated array of ints. The number of
*     elements in this array will equal the number of outputs for the 
*     returned Mapping. Each element will hold the index of the
*     corresponding output in the supplied NormMap. The array should be
*     freed using astFree when no longer needed. A NULL pointer will
*     be returned if no output Mapping can be created.

*  Notes:
*     - If this function is invoked with the global error status set,
*     or if it should fail for any reason, then NULL values will be
*     returned as the function value and for the "map" pointer.
*/

/* Local Variables: */
   AstFrame *frm2;            /* Pointer to new Frame */
   AstNormMap *this;          /* Pointer to NormMap structure */
   int *result;               /* Pointer to returned array */

/* Initialise */
   result = NULL;
   *map = NULL;

/* Check the global error status. */
   if ( !astOK ) return result;

/* Invoke the parent astMapSplit method to see if it can do the job. */
   result = (*parent_mapsplit)( this_map, nin, in, map );

/* If not, we provide a special implementation here. */
   if( !result ) {

/* Get a pointer to the NormMap structure. */
      this = (AstNormMap *) this_map;

/* Pick the requried axes from the encapsulated Frame. */
      frm2 = astPickAxes( this->frame, nin, in, NULL );

/* Create a new NormMap from this. */
      *map = (AstMapping *) astNormMap( frm2, "" );

/* The returned list of output axes is a copy the supplied list of input 
   axes. */
      result = astStore( NULL, in, sizeof( int )*(size_t) nin );

/* Free resources. */
      frm2 = astAnnul( frm2 );
   }

/* Free returned resources if an error has occurred. */
   if( !astOK ) {
      result = astFree( result );
      *map = astAnnul( *map );
   }

/* Return the list of output indices. */
   return result;
}

static double Rate( AstMapping *this, double *at, int ax1, int ax2 ){
/*
*  Name:
*     Rate

*  Purpose:
*     Calculate the rate of change of a Mapping output.

*  Type:
*     Private function.

*  Synopsis:
*     #include "normmap.h"
*     result = Rate( AstMapping *this, double *at, int ax1, int ax2 )

*  Class Membership:
*     NormMap member function (overrides the astRate method inherited
*     from the Mapping class ).

*  Description:
*     This function returns the rate of change of a specified output of 
*     the supplied Mapping with respect to a specified input, at a 
*     specified input position. 

*  Parameters:
*     this
*        Pointer to the Mapping to be applied.
*     at
*        The address of an array holding the axis values at the position 
*        at which the rate of change is to be evaluated. The number of 
*        elements in this array should equal the number of inputs to the 
*        Mapping.
*     ax1
*        The index of the Mapping output for which the rate of change is to 
*        be found (output numbering starts at 0 for the first output).
*     ax2
*        The index of the Mapping input which is to be varied in order to
*        find the rate of change (input numbering starts at 0 for the first 
*        input).

*  Returned Value:
*     The rate of change of Mapping output "ax1" with respect to input 
*     "ax2", evaluated at "at", or AST__BAD if the value cannot be 
*     calculated.

*/

   return ( ax1 == ax2 ) ? 1.0 : 0.0;
}

static AstPointSet *Transform( AstMapping *this, AstPointSet *in,
                               int forward, AstPointSet *out ) {
/*
*  Name:
*     Transform

*  Purpose:
*     Apply a NormMap to transform a set of points.

*  Type:
*     Private function.

*  Synopsis:
*     #include "normmap.h"
*     AstPointSet *Transform( AstMapping *this, AstPointSet *in,
*                             int forward, AstPointSet *out )

*  Class Membership:
*     NormMap member function (over-rides the astTransform protected
*     method inherited from the Mapping class).

*  Description:
*     This function takes a NormMap and a set of points encapsulated in a
*     PointSet and transforms the points so as to apply the required zoom
*     factor.

*  Parameters:
*     this
*        Pointer to the NormMap.
*     in
*        Pointer to the PointSet holding the input coordinate data.
*     forward
*        A non-zero value indicates that the forward coordinate transformation
*        should be applied, while a zero value requests the inverse
*        transformation.
*     out
*        Pointer to a PointSet which will hold the transformed (output)
*        coordinate values. A NULL value may also be given, in which case a
*        new PointSet will be created by this function.

*  Returned Value:
*     Pointer to the output (possibly new) PointSet.

*  Notes:
*     -  A null pointer will be returned if this function is invoked with the
*     global error status set, or if it should fail for any reason.
*     -  The number of coordinate values per point in the input PointSet must
*     match the number of coordinates for the NormMap being applied.
*     -  If an output PointSet is supplied, it must have space for sufficient
*     number of points and coordinate values per point to accommodate the
*     result. Any excess space will be ignored.
*/

/* Local Variables: */
   AstPointSet *result;          /* Pointer to output PointSet */
   AstNormMap *map;              /* Pointer to NormMap to be applied */
   double **ptr_in;              /* Pointer to input coordinate data */
   double **ptr_out;             /* Pointer to output coordinate data */
   double *work;                 /* Work space for a single point */
   int coord;                    /* Loop counter for coordinates */
   int ncoord_in;                /* Number of coordinates per input point */
   int npoint;                   /* Number of points */
   int point;                    /* Loop counter for points */

/* Check the global error status. */
   if ( !astOK ) return NULL;

/* Obtain a pointer to the NormMap. */
   map = (AstNormMap *) this;

/* Apply the parent mapping using the stored pointer to the Transform member
   function inherited from the parent Mapping class. This function validates
   all arguments and generates an output PointSet if necessary, but does not
   actually transform any coordinate values. */
   result = (*parent_transform)( this, in, forward, out );

/* We will now extend the parent astTransform method by performing the
   calculations needed to generate the output coordinate values. */

/* Determine the numbers of points and coordinates per point from the input
   PointSet and obtain pointers for accessing the input and output coordinate
   values. */
   ncoord_in = astGetNcoord( in );
   npoint = astGetNpoint( in );
   ptr_in = astGetPoints( in );      
   ptr_out = astGetPoints( result );
   work = astMalloc( sizeof( double )* ncoord_in );

/* Perform coordinate arithmetic. */
/* ------------------------------ */
   if ( astOK ) {
      for ( point = 0; point < npoint; point++ ) {
         for ( coord = 0; coord < ncoord_in; coord++ ) {
            work[ coord ] = ptr_in[ coord ][ point ];
         }
         astNorm( map->frame, work );
         for ( coord = 0; coord < ncoord_in; coord++ ) {
            ptr_out[ coord ][ point ] = work[ coord ];
         }
      }
   }

/* Free resources */
   work = astFree( work );

/* Return a pointer to the output PointSet. */
   return result;
}

/* Functions which access class attributes. */
/* ---------------------------------------- */
/* Implement member functions to access the attributes associated with
   this class using the macros defined for this purpose in the
   "object.h" file. For a description of each attribute, see the class
   interface (in the associated .h file). */

/* Copy constructor. */
/* ----------------- */
static void Copy( const AstObject *objin, AstObject *objout ) {
/*
*  Name:
*     Copy

*  Purpose:
*     Copy constructor for NormMap objects.

*  Type:
*     Private function.

*  Synopsis:
*     void Copy( const AstObject *objin, AstObject *objout )

*  Description:
*     This function implements the copy constructor for NormMap objects.

*  Parameters:
*     objin
*        Pointer to the object to be copied.
*     objout
*        Pointer to the object being constructed.

*  Returned Value:
*     void

*  Notes:
*     -  This constructor makes a deep copy, including a copy of the 
*     Frame within the NormMap.
*/

/* Local Variables: */
   AstNormMap *in;                /* Pointer to input NormMap */
   AstNormMap *out;               /* Pointer to output NormMap */

/* Check the global error status. */
   if ( !astOK ) return;

   in = (AstNormMap *) objin;
   out = (AstNormMap *) objout;
   out->frame = astCopy( in->frame );
}

/* Destructor. */
/* ----------- */
static void Delete( AstObject *obj ) {
/*
*  Name:
*     Delete

*  Purpose:
*     Destructor for NormMap objects.

*  Type:
*     Private function.

*  Synopsis:
*     void Delete( AstObject *obj )

*  Description:
*     This function implements the destructor for NormMap objects.

*  Parameters:
*     obj
*        Pointer to the object to be deleted.

*  Returned Value:
*     void

*  Notes:
*     This function attempts to execute even if the global error status is
*     set.
*/

/* Local Variables: */
   AstNormMap *this;              /* Pointer to NormMap */

   this = (AstNormMap *) obj;
   this->frame = astAnnul( this->frame );

}

/* Dump function. */
/* -------------- */
static void Dump( AstObject *this_object, AstChannel *channel ) {
/*
*  Name:
*     Dump

*  Purpose:
*     Dump function for NormMap objects.

*  Type:
*     Private function.

*  Synopsis:
*     void Dump( AstObject *this, AstChannel *channel )

*  Description:
*     This function implements the Dump function which writes out data
*     for the NormMap class to an output Channel.

*  Parameters:
*     this
*        Pointer to the NormMap whose data are being written.
*     channel
*        Pointer to the Channel to which the data are being written.
*/

/* Local Variables: */
   AstNormMap *this;             /* Pointer to the NormMap structure */

/* Check the global error status. */
   if ( !astOK ) return;

/* Obtain a pointer to the NormMap structure. */
   this = (AstNormMap *) this_object;

/* Write out values representing the instance variables for the
   NormMap class.  Accompany these with appropriate comment strings,
   possibly depending on the values being written.*/

/* Frame. */ 
/* ------ */
   astWriteObject( channel, "Frame", 1, 1, this->frame, 
                   "Frame defining the normalisation" );
}

/* Standard class functions. */
/* ========================= */
/* Implement the astIsANormMap and astCheckNormMap functions using the macros
   defined for this purpose in the "object.h" header file. */
astMAKE_ISA(NormMap,Mapping,check,&class_init)
astMAKE_CHECK(NormMap)

AstNormMap *astNormMap_( void *frame_void, const char *options, ... ) {
/*
*++
*  Name:
c     astNormMap
f     AST_NORMMAP

*  Purpose:
*     Create a NormMap.

*  Type:
*     Public function.

*  Synopsis:
c     #include "normmap.h"
c     AstNormMap *astNormMap( AstFrame *frame, const char *options, ... )
f     RESULT = AST_NORMMAP( FRAME, OPTIONS, STATUS )

*  Class Membership:
*     NormMap constructor.

*  Description:
*     This function creates a new NormMap and optionally initialises its
*     attributes.
*
*     A NormMap is a Mapping which normalises coordinate values using the 
c     astNorm function
f     AST_NORM routine
*     of the supplied Frame. The number of inputs and outputs of a NormMap
*     are both equal to the number of axes in the supplied Frame.
*
*     The forward and inverse transformation of a NormMap are both
*     defined but are identical (that is, they do not form a real inverse 
*     pair in that the inverse transformation does not undo the
*     normalisation, instead it reapplies it). However, the 
c     astSimplify
f     AST_SIMPLIFY
*     function will replace neighbouring pairs of forward and inverse 
*     NormMaps by a single UnitMap.

*  Parameters:
c     frame
f     FRAME = INTEGER (Given)
*        A pointer to the Frame which is to be used to normalise the
*        supplied axis values. 
c     options
f     OPTIONS = CHARACTER * ( * ) (Given)
c        Pointer to a null-terminated string containing an optional
c        comma-separated list of attribute assignments to be used for
c        initialising the new NormMap. The syntax used is identical to
c        that for the astSet function and may include "printf" format
c        specifiers identified by "%" symbols in the normal way.
f        A character string containing an optional comma-separated
f        list of attribute assignments to be used for initialising the
f        new NormMap. The syntax used is identical to that for the
f        AST_SET routine.
c     ...
c        If the "options" string contains "%" format specifiers, then
c        an optional list of additional arguments may follow it in
c        order to supply values to be substituted for these
c        specifiers. The rules for supplying these are identical to
c        those for the astSet function (and for the C "printf"
c        function).
f     STATUS = INTEGER (Given and Returned)
f        The global status.

*  Returned Value:
c     astNormMap()
f     AST_NORMMAP = INTEGER
*        A pointer to the new NormMap.

*  Notes:
*     - A null Object pointer (AST__NULL) will be returned if this
c     function is invoked with the AST error status set, or if it
f     function is invoked with STATUS set to an error value, or if it
*     should fail for any reason.
*--
*/

/* Local Variables: */
   AstFrame *frame;              /* The Frame pointer */
   AstNormMap *new;              /* Pointer to new NormMap */
   va_list args;                 /* Variable argument list */

/* Check the global status. */
   if ( !astOK ) return NULL;

/* Obtain and validate pointers to the Frame structures provided. */
   frame = astCheckFrame( frame_void );

/* Initialise the NormMap, allocating memory and initialising the
   virtual function table as well if necessary. */
   new = astInitNormMap( NULL, sizeof( AstNormMap ), !class_init, &class_vtab,
                         "NormMap", frame );
   if( astOK ) {

/* If successful, note that the virtual function table has been
   initialised. */
      if ( astOK ) {
         class_init = 1;

/* Obtain the variable argument list and pass it along with the options string
   to the astVSet method to initialise the new NormMap's attributes. */
         va_start( args, options );
         astVSet( new, options, args );
         va_end( args );

/* If an error occurred, clean up by deleting the new object. */
         if ( !astOK ) new = astDelete( new );
      }
   }

/* Return a pointer to the new NormMap. */
   return new;
}

AstNormMap *astNormMapId_( void *frame_void, const char *options, ... ) {
/*
*  Name:
*     astNormMapId_

*  Purpose:
*     Create a NormMap.

*  Type:
*     Private function.

*  Synopsis:
*     #include "normmap.h"
*     AstNormMap *astNormMapId_( int ncoord, double zoom,
*                                const char *options, ... )

*  Class Membership:
*     NormMap constructor.

*  Description:
*     This function implements the external (public) interface to the
*     astNormMap constructor function. It returns an ID value (instead
*     of a true C pointer) to external users, and must be provided
*     because astNormMap_ has a variable argument list which cannot be
*     encapsulated in a macro (where this conversion would otherwise
*     occur).
*
*     The variable argument list also prevents this function from
*     invoking astNormMap_ directly, so it must be a re-implementation
*     of it in all respects, except for the final conversion of the
*     result to an ID value.

*  Parameters:
*     As for astNormMap_.

*  Returned Value:
*     The ID value associated with the new NormMap.
*/

/* Local Variables: */
   AstFrame *frame;              /* The Frame pointer */
   AstNormMap *new;              /* Pointer to new NormMap */
   va_list args;                 /* Variable argument list */

/* Check the global status. */
   if ( !astOK ) return NULL;

/* Obtain and validate pointers to the Frame structures provided. */
   frame = astCheckFrame( astMakePointer( frame_void ) );

/* Initialise the NormMap, allocating memory and initialising the
   virtual function table as well if necessary. */
   new = astInitNormMap( NULL, sizeof( AstNormMap ), !class_init, &class_vtab,
                         "NormMap", frame );

/* If successful, note that the virtual function table has been
   initialised. */
   if ( astOK ) {
      class_init = 1;

/* Obtain the variable argument list and pass it along with the options string
   to the astVSet method to initialise the new NormMap's attributes. */
      va_start( args, options );
      astVSet( new, options, args );
      va_end( args );

/* If an error occurred, clean up by deleting the new object. */
      if ( !astOK ) new = astDelete( new );
   }

/* Return an ID value for the new NormMap. */
   return astMakeId( new );
}

AstNormMap *astInitNormMap_( void *mem, size_t size, int init,
                             AstNormMapVtab *vtab, const char *name,
                             AstFrame *frame ) {
/*
*+
*  Name:
*     astInitNormMap

*  Purpose:
*     Initialise a NormMap.

*  Type:
*     Protected function.

*  Synopsis:
*     #include "normmap.h"
*     AstNormMap *astInitNormMap( void *mem, size_t size, int init,
*                                 AstNormMapVtab *vtab, const char *name,
*                                 AstFrame *frame )

*  Class Membership:
*     NormMap initialiser.

*  Description:
*     This function is provided for use by class implementations to initialise
*     a new NormMap object. It allocates memory (if necessary) to accommodate
*     the NormMap plus any additional data associated with the derived class.
*     It then initialises a NormMap structure at the start of this memory. If
*     the "init" flag is set, it also initialises the contents of a virtual
*     function table for a NormMap at the start of the memory passed via the
*     "vtab" parameter.

*  Parameters:
*     mem
*        A pointer to the memory in which the NormMap is to be initialised.
*        This must be of sufficient size to accommodate the NormMap data
*        (sizeof(NormMap)) plus any data used by the derived class. If a value
*        of NULL is given, this function will allocate the memory itself using
*        the "size" parameter to determine its size.
*     size
*        The amount of memory used by the NormMap (plus derived class data).
*        This will be used to allocate memory if a value of NULL is given for
*        the "mem" parameter. This value is also stored in the NormMap
*        structure, so a valid value must be supplied even if not required for
*        allocating memory.
*     init
*        A logical flag indicating if the NormMap's virtual function table is
*        to be initialised. If this value is non-zero, the virtual function
*        table will be initialised by this function.
*     vtab
*        Pointer to the start of the virtual function table to be associated
*        with the new NormMap.
*     name
*        Pointer to a constant null-terminated character string which contains
*        the name of the class to which the new object belongs (it is this
*        pointer value that will subsequently be returned by the astGetClass
*        method).
*     frame
*        The Frame to use to do the normalisations.

*  Returned Value:
*     A pointer to the new NormMap.

*  Notes:
*     -  A null pointer will be returned if this function is invoked with the
*     global error status set, or if it should fail for any reason.
*-
*/

/* Local Variables: */
   AstNormMap *new;              /* Pointer to new NormMap */
   int ncoord;                   /* Number of input and output coords */

/* Check the global status. */
   if ( !astOK ) return NULL;

/* If necessary, initialise the virtual function table. */
   if ( init ) astInitNormMapVtab( vtab, name );

/* Initialise. */
   new = NULL;

/* Get the number of axes in the Frame. */
   ncoord = astGetNaxes( frame );

/* Initialise a Mapping structure (the parent class) as the first component
   within the NormMap structure, allocating memory if necessary. Specify that
   the Mapping should be defined in both the forward and inverse directions. */
   new = (AstNormMap *) astInitMapping( mem, size, 0,
                                        (AstMappingVtab *) vtab, name,
                                        ncoord, ncoord, 1, 1 );

   if ( astOK ) {

/* Initialise the NormMap data. */
/* ---------------------------- */
/* Store a pointer to the Frame. */
      new->frame = astClone( frame );

/* If an error occurred, clean up by deleting the new NormMap. */
      if ( !astOK ) new = astDelete( new );
   }

/* Return a pointer to the new NormMap. */
   return new;
}

AstNormMap *astLoadNormMap_( void *mem, size_t size,
                             AstNormMapVtab *vtab, const char *name,
                             AstChannel *channel ) {
/*
*+
*  Name:
*     astLoadNormMap

*  Purpose:
*     Load a NormMap.

*  Type:
*     Protected function.

*  Synopsis:
*     #include "normmap.h"
*     AstNormMap *astLoadNormMap( void *mem, size_t size,
*                                 AstNormMapVtab *vtab, const char *name,
*                                 AstChannel *channel )

*  Class Membership:
*     NormMap loader.

*  Description:
*     This function is provided to load a new NormMap using data read
*     from a Channel. It first loads the data used by the parent class
*     (which allocates memory if necessary) and then initialises a
*     NormMap structure in this memory, using data read from the input
*     Channel.
*
*     If the "init" flag is set, it also initialises the contents of a
*     virtual function table for a NormMap at the start of the memory
*     passed via the "vtab" parameter.


*  Parameters:
*     mem
*        A pointer to the memory into which the NormMap is to be
*        loaded.  This must be of sufficient size to accommodate the
*        NormMap data (sizeof(NormMap)) plus any data used by derived
*        classes. If a value of NULL is given, this function will
*        allocate the memory itself using the "size" parameter to
*        determine its size.
*     size
*        The amount of memory used by the NormMap (plus derived class
*        data).  This will be used to allocate memory if a value of
*        NULL is given for the "mem" parameter. This value is also
*        stored in the NormMap structure, so a valid value must be
*        supplied even if not required for allocating memory.
*
*        If the "vtab" parameter is NULL, the "size" value is ignored
*        and sizeof(AstNormMap) is used instead.
*     vtab
*        Pointer to the start of the virtual function table to be
*        associated with the new NormMap. If this is NULL, a pointer
*        to the (static) virtual function table for the NormMap class
*        is used instead.
*     name
*        Pointer to a constant null-terminated character string which
*        contains the name of the class to which the new object
*        belongs (it is this pointer value that will subsequently be
*        returned by the astGetClass method).
*
*        If the "vtab" parameter is NULL, the "name" value is ignored
*        and a pointer to the string "NormMap" is used instead.

*  Returned Value:
*     A pointer to the new NormMap.

*  Notes:
*     - A null pointer will be returned if this function is invoked
*     with the global error status set, or if it should fail for any
*     reason.
*-
*/

/* Local Variables: */
   AstNormMap *new;              /* Pointer to the new NormMap */

/* Initialise. */
   new = NULL;

/* Check the global error status. */
   if ( !astOK ) return new;

/* If a NULL virtual function table has been supplied, then this is
   the first loader to be invoked for this NormMap. In this case the
   NormMap belongs to this class, so supply appropriate values to be
   passed to the parent class loader (and its parent, etc.). */
   if ( !vtab ) {
      size = sizeof( AstNormMap );
      vtab = &class_vtab;
      name = "NormMap";

/* If required, initialise the virtual function table for this class. */
      if ( !class_init ) {
         astInitNormMapVtab( vtab, name );
         class_init = 1;
      }
   }

/* Invoke the parent class loader to load data for all the ancestral
   classes of the current one, returning a pointer to the resulting
   partly-built NormMap. */
   new = astLoadMapping( mem, size, (AstMappingVtab *) vtab, name,
                         channel );

   if ( astOK ) {

/* Read input data. */
/* ================ */
/* Request the input Channel to read all the input data appropriate to
   this class into the internal "values list". */
      astReadClassData( channel, "NormMap" );

/* Now read each individual data item from this list and use it to
   initialise the appropriate instance variable(s) for this class. */

/* In the case of attributes, we first read the "raw" input value,
   supplying the "unset" value as the default. If a "set" value is
   obtained, we then use the appropriate (private) Set... member
   function to validate and set the value properly. */

/* Frame. */
/* ------ */
      new->frame = astReadObject( channel, "frame", NULL );

/* If an error occurred, clean up by deleting the new NormMap. */
      if ( !astOK ) new = astDelete( new );
   }

/* Return the new NormMap pointer. */
   return new;
}

/* Virtual function interfaces. */
/* ============================ */
/* These provide the external interface to the virtual functions defined by
   this class. Each simply checks the global error status and then locates and
   executes the appropriate member function, using the function pointer stored
   in the object's virtual function table (this pointer is located using the
   astMEMBER macro defined in "object.h").

   Note that the member function may not be the one defined here, as it may
   have been over-ridden by a derived class. However, it should still have the
   same interface. */
