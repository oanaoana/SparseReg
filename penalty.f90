#include "fintrf.h"
!
		SUBROUTINE MEXFUNCTION(NLHS, PLHS, NRHS, PRHS)
!
!     This is the gateway subroutine for LSQSPARSE mex function
!
		USE SPARSEREG
		IMPLICIT NONE
!
!     MEXFUNCTION ARGUMENTS
!
		MWPOINTER :: PLHS(*), PRHS(*)
		INTEGER :: NLHS, NRHS
!
!     FUNCTION DECLARATIONS
!
		INTEGER :: MXISCHAR,MXISLOGICAL,MXISNUMERIC
		INTEGER*4 :: MEXPRINTF
		MWPOINTER :: MXCREATEDOUBLEMATRIX,MXGETPR,MXGETSTRING
		MWSIZE :: MXGETM, MXGETN
!
!     SOME LOCAL VARIABLES
!		
      INTEGER :: MAXITERS,STATUS
      MWSIZE :: N,N1,N2,PENNAMELEN,PENPARAMS
      REAL(KIND=DBLE_PREC) :: LAMBDA
      CHARACTER(LEN=10) :: PENTYPE
      REAL(KIND=DBLE_PREC), ALLOCATABLE, DIMENSION(:) :: BETA,PEN,D1PEN,D2PEN,DPENDLAMBDA,PENPARAM
!
!     CHECK FOR INPUT/OUTPUT ARGUMENT TYPES
!
      IF (NRHS.NE.4) THEN
         CALL MEXERRMSGIDANDTXT('MATLAB:penalty:nInput','Four input requried.')
      ELSEIF (NLHS>4) THEN
         CALL MEXERRMSGIDANDTXT('MATLAB:penalty:nOutput','At most four output requried.')
      ELSEIF (MXISNUMERIC(PRHS(1))/=1) THEN
         CALL MEXERRMSGIDANDTXT('MATLAB:penalty:Input1','Input 1 must be a numerical array.')
      ELSEIF (MXISNUMERIC(PRHS(2))/=1.OR.MXGETM(PRHS(2))*MXGETN(PRHS(2))>1) THEN
         CALL MEXERRMSGIDANDTXT('MATLAB:penalty:Input2','Input 2 must be a scalar.')
      ELSEIF (MXISCHAR(PRHS(3))/=1) THEN
         CALL MEXERRMSGIDANDTXT('MATLAB:penalty:Input3','Input 3 must be a string.')
      ELSEIF (MXISNUMERIC(PRHS(4))/=1) THEN
         CALL MEXERRMSGIDANDTXT('MATLAB:penalty:Input4','Input 4 must be a numerical array.')
      END IF
!
!     PREPARE INPUTS FOR COMPUTATIONAL ROUTINE
!
      N1 = MXGETM(PRHS(1))
      N2 = MXGETN(PRHS(1)) 
      N = N1*N2
      ALLOCATE(BETA(N))
      CALL MXCOPYPTRTOREAL8(MXGETPR(PRHS(1)),BETA,N)
      CALL MXCOPYPTRTOREAL8(MXGETPR(PRHS(2)),LAMBDA,1)
      PENNAMELEN = MXGETM(PRHS(3))*MXGETN(PRHS(3))
      STATUS = MXGETSTRING(PRHS(3), PENTYPE, PENNAMELEN)
      IF (STATUS/=0) THEN
         CALL MEXERRMSGIDANDTXT('MATLAB:penalty:readError','Error reading string.')
      END IF
      PENPARAMS = MXGETM(PRHS(4))*MXGETN(PRHS(4))
      ALLOCATE(PENPARAM(PENPARAMS))
      CALL MXCOPYPTRTOREAL8(MXGETPR(PRHS(4)),PENPARAM,PENPARAMS)      
!
!     CALL THE COMPUTATION ROUTINE AND COPY RESULT TO MATLAB ARRAYS
!
      IF (NLHS==1) THEN
         ALLOCATE(PEN(N))
         CALL PENALTY_FUN(BETA,LAMBDA,PENPARAM(1),PENTYPE(1:PENNAMELEN),PEN)
         PLHS(1) = MXCREATEDOUBLEMATRIX(N1,N2,0)
         CALL MXCOPYREAL8TOPTR(PEN,MXGETPR(PLHS(1)),N)
      ELSEIF (NLHS==2) THEN
         ALLOCATE(PEN(N),D1PEN(N))
         CALL PENALTY_FUN(BETA,LAMBDA,PENPARAM(1),PENTYPE(1:PENNAMELEN),PEN,D1PEN)
         PLHS(1) = MXCREATEDOUBLEMATRIX(N1,N2,0)
         CALL MXCOPYREAL8TOPTR(PEN,MXGETPR(PLHS(1)),N)
         PLHS(2) = MXCREATEDOUBLEMATRIX(N1,N2,0)
         CALL MXCOPYREAL8TOPTR(D1PEN,MXGETPR(PLHS(2)),N)
      ELSEIF (NLHS==3) THEN
         ALLOCATE(PEN(N),D1PEN(N),D2PEN(N))
         CALL PENALTY_FUN(BETA,LAMBDA,PENPARAM(1),PENTYPE(1:PENNAMELEN),PEN,D1PEN,D2PEN)
         PLHS(1) = MXCREATEDOUBLEMATRIX(N1,N2,0)
         CALL MXCOPYREAL8TOPTR(PEN,MXGETPR(PLHS(1)),N)
         PLHS(2) = MXCREATEDOUBLEMATRIX(N1,N2,0)
         CALL MXCOPYREAL8TOPTR(D1PEN,MXGETPR(PLHS(2)),N)
         PLHS(3) = MXCREATEDOUBLEMATRIX(N1,N2,0)
         CALL MXCOPYREAL8TOPTR(D2PEN,MXGETPR(PLHS(3)),N)
      ELSEIF (NLHS==4) THEN
         ALLOCATE(PEN(N),D1PEN(N),D2PEN(N),DPENDLAMBDA(N))
         CALL PENALTY_FUN(BETA,LAMBDA,PENPARAM(1),PENTYPE(1:PENNAMELEN),PEN,D1PEN,D2PEN,DPENDLAMBDA)
         PLHS(1) = MXCREATEDOUBLEMATRIX(N1,N2,0)
         CALL MXCOPYREAL8TOPTR(PEN,MXGETPR(PLHS(1)),N)
         PLHS(2) = MXCREATEDOUBLEMATRIX(N1,N2,0)
         CALL MXCOPYREAL8TOPTR(D1PEN,MXGETPR(PLHS(2)),N)
         PLHS(3) = MXCREATEDOUBLEMATRIX(N1,N2,0)
         CALL MXCOPYREAL8TOPTR(D2PEN,MXGETPR(PLHS(3)),N)
         PLHS(4) = MXCREATEDOUBLEMATRIX(N1,N2,0)
         CALL MXCOPYREAL8TOPTR(DPENDLAMBDA,MXGETPR(PLHS(4)),N)         
      END IF
!
!     FREE MEMORY
!
      DEALLOCATE (BETA,PENPARAM)
      IF(ALLOCATED(PEN)) DEALLOCATE(PEN)
      IF(ALLOCATED(D1PEN)) DEALLOCATE(D1PEN)
      IF(ALLOCATED(D2PEN)) DEALLOCATE(D2PEN)
      IF(ALLOCATED(DPENDLAMBDA)) DEALLOCATE(DPENDLAMBDA)
      RETURN
		END SUBROUTINE MEXFUNCTION

      SUBROUTINE MXCOPYPTRTOLOGICAL( PTR, FORTRAN, N )
      IMPLICIT NONE
!-ARG
      MWSIZE, INTENT(IN) :: N
      MWPOINTER, INTENT(IN) :: PTR
      LOGICAL, INTENT(OUT) :: FORTRAN(N)
!-----
      CALL MXCOPYINTEGER1TOLOGICAL( %VAL(PTR), FORTRAN, N )
      RETURN
      END SUBROUTINE

      SUBROUTINE MXCOPYINTEGER1TOLOGICAL( LOGICALDATA, FORTRAN, N)
      IMPLICIT NONE
!-ARG
      MWSIZE, INTENT(IN) :: N
      INTEGER*1, INTENT(IN) :: LOGICALDATA(N)
      LOGICAL, INTENT(OUT) :: FORTRAN(N)
!-----
      FORTRAN = (LOGICALDATA /= 0)
      RETURN
      END SUBROUTINE