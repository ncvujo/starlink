*  History:
*      1 Aug 2000 (ajc):
*        Change PRINT * to PRINT *
*        Unused J
*        Catch IERR=2 from GEN_PARSEOP and replace by IERR=1
*         (end of line)
*-----------------------------------------------------------------------

      SUBROUTINE gen_operator (string, ils, next, ierr)

*  Routine to scan the expression for the next operator. If an arithmetic
*  operator is encountered, then, depending on its precedence, either
*  execute the pending operation, or push the new operator onto the operator-
*  stack. If a closing bracket is found then finish any remaining calculations
*  and place final value on operand stack

      IMPLICIT none

*     Formal parameters:

      CHARACTER string*(*)
      INTEGER*4 ils
      INTEGER*4 next
      INTEGER*4 ierr

*     Operand and operator stacks

      INCLUDE  'eval_ae4.inc'

*     Local variables:

D      INTEGER*4 j
      INTEGER*4 st, ist, iend
      LOGICAL*4 rbracket

*  Make sure routine "falls through" in error not zero on entry

      IF (ierr.ne.0) RETURN

*  Ok, go..

D     Print *, '-- gen_operator --'

      st   = next

*     Check that there is something left in the string

      IF (st.gt.ils) THEN
        ierr = 1
        RETURN
      END IF

*     Then parse for next operator in the normal way -- if a right
*     bracket is encountered then evaluate the just completed term and
*     continue: repeat this recipe until an ordinary operator is found

      rbracket = .true.
      DO WHILE (rbracket)
        CALL gen_parseop (string, st,ist,iend, prio(ntopr+1),
     &                    rbracket, next,ierr)

        IF (ierr.eq.0) THEN
D         PRINT *, '    Parseop returned operator ', string(ist:iend)
        ELSE IF ( ierr.eq.2 ) THEN
          ierr = 1
          RETURN

        END IF

        IF (rbracket) THEN
D         Print *,'   ")" found: evaluate anything left at level', lev
          CALL gen_eval_all (ierr)
          IF (ierr.ne.0) RETURN
          lev = lev - 1
D         Print *,'    ...and pop stack, level =', lev
          st  = next
        END IF

      END DO

D     Print *, '     ---------------------------'
D     Print *, '        Operator stack summary'
D     Print *, '      total # operators: ', ntopr
D     Print *, '      operators: ', (oper(j),' ',j=1,ntopr)
D     Print *, '      priorities: ', (prio(j), j=1,ntopr)
D     Print *, '      at this level:',(oper(j),j=ntopr-nopr(lev)+1,ntopr)
D     Print *, '     ---------------------------'

      IF (ierr.eq.0) THEN         ! operator got.

        ntopr       = ntopr + 1
        nopr(lev)   = nopr(lev) + 1
        oper(ntopr) = string(ist:iend)

        DO WHILE (prio(ntopr-1).ge.prio(ntopr) .AND. nopr(lev).ge.2)

          CALL gen_do_op (oper(ntopr-1), ierr)
          IF (ierr.ne.0) RETURN

*         Decrement the operator stack, noting that the LAST operator
*         in fact hasn't been done yet, and must be saved

          oper(ntopr-1) = oper(ntopr)
          prio(ntopr-1) = prio(ntopr)
          nopr(lev)  = nopr(lev)  - 1
          ntopr      = ntopr      - 1

D         PRINT *,'    total # operators decremented by 1, now', ntopr

        END DO

      ELSE                        ! other error
        RETURN

      END IF

      RETURN
      END
