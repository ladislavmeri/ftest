module mod_ftest

  implicit none
  private
  
  !public procedures
  public:: fTest
  public:: assertTrue
  public:: expectTrue
  public:: printTestNumbers
  public:: getTestFailureNum
  public:: getTestSuccessNum
  
  !private module globals
  integer:: failureNum = 0
  integer:: successNum = 0
  integer, parameter :: time_kind = kind ( 1.0D+00 )
  
contains 

!publics

!--------------------------------------------------------------------------------------------------!
  subroutine fTest(testName, testFunc) 
    character(len=*), intent(in) :: testName
    interface 
      logical function testFunc()
      end function testFunc
    end interface
    real(kind=time_kind) :: tStart, tEnd
    logical :: result

#ifdef __WINDOWS__    
    call set_ansi
#endif
    
    write(*,*) ""
    write(*,"(A)") achar(27)//'[94m'//trim(testName)//achar(27)//'[0m'//' - running :'
    
    tStart = wtime()
    result = testFunc()
    tEnd = wtime()
    write(*,"(A,F8.3,A)") achar(27)//'[94m'//trim(testName)//achar(27)//'[0m'//' - elapsed : ', &
                          1000*(tEnd-tStart), "ms"
    write(*,"(A)") achar(27)//'[94m'//trim(testName)//achar(27)//'[0m'//' - done '
    write(*,*) ""
  end subroutine fTest
!--------------------------------------------------------------------------------------------------!

!--------------------------------------------------------------------------------------------------!
  subroutine assertTrue(testName, condition, srcFileName, lineNum)
    character(len=*), intent(in), optional :: testName
    logical,          intent(in)           :: condition
    character(len=*), intent(in), optional :: srcFileName
    integer,          intent(in), optional :: lineNum 
    logical, parameter :: isAssert = .true.
    
    call printTestStart(testName, srcFileName, lineNum, isAssert)

    if ( condition ) then
      call printTestSuccess()
      successNum = successNum + 1
    else
      call printTestFailure()
      failureNum = failureNum + 1
      call printTestNumbers()
      stop "ASSERT FAILED"
    endif 
  end subroutine assertTrue
!--------------------------------------------------------------------------------------------------!  
  
!--------------------------------------------------------------------------------------------------!  
  subroutine expectTrue(testName, condition, srcFileName, lineNum)
    character(len=*), intent(in), optional :: testName
    logical,          intent(in)           :: condition
    character(len=*), intent(in), optional :: srcFileName
    integer,          intent(in), optional :: lineNum 
    
    call printTestStart(testName, srcFileName, lineNum)
    
    if ( condition ) then
      call printTestSuccess()
      successNum = successNum + 1
    else
      call printTestFailure()
      failureNum = failureNum + 1
    endif 
  end subroutine expectTrue
!--------------------------------------------------------------------------------------------------!  
    
!--------------------------------------------------------------------------------------------------!    
  subroutine printTestNumbers()
#ifdef __WINDOWS__    
    call set_ansi
#endif
    write(*,"(A,I5,A)",advance="no") achar(27)//'[94m ', successNum+failureNum, " tests executed, "
    write(*,"(A)",advance="no") achar(27)//'[0m'
    write(*,"(A,I5,A)",advance="no") achar(27)//"[92m ", successNum, " successes,"//achar(27)//'[0m'
    if ( failureNum == 0 ) then
      write(*,"(A,I5,A)") achar(27)//"[92m ", failureNum, " failures"//achar(27)//'[0m'
    else 
      write(*,"(A,I5,A)") achar(27)//"[91m ", failureNum, " failures"//achar(27)//'[0m'
    endif  
  end subroutine printTestNumbers
!--------------------------------------------------------------------------------------------------!

!--------------------------------------------------------------------------------------------------!  
  function getTestFailureNum() result(res)
    integer :: res
    res = failureNum
  end function getTestFailureNum
!--------------------------------------------------------------------------------------------------!

!--------------------------------------------------------------------------------------------------!  
  function getTestSuccessNum() result(res)
    integer :: res
    res = successNum
  end function getTestSuccessNum
!--------------------------------------------------------------------------------------------------!  


!privates

!--------------------------------------------------------------------------------------------------!  
  subroutine printTestStart(testName, srcFileName, lineNum, isAssert)
    character(len=*), intent(in), optional :: testName
    character(len=*), intent(in), optional :: srcFileName
    integer,          intent(in), optional :: lineNum 
    logical,          intent(in), optional :: isAssert 

#ifdef __WINDOWS__    
    call set_ansi
#endif

    if ( present(isAssert) ) then 
      if ( isAssert ) then
        write(*,"(A)",advance="no") "Asserting - "
      else 
        write(*,"(A)",advance="no") "Expecting - "
      endif
    else 
      write(*,"(A)",advance="no") "Expecting - "
    endif
    
    if ( present(testName) ) then
      write(*,"(A)",advance="no") achar(27)//'[94m '//trim(testName)//achar(27)//'[0m'
    endif

    if ( present(srcFileName) ) then
      write(*,"(A)",advance="no") " - in file "//trim(srcFileName)
    endif

    if ( present(lineNum) ) then
      write(*,"(A,I5)",advance="no") ", line:", lineNum
    endif

    write(*,"(A)") " ... "
  end subroutine printTestStart
!--------------------------------------------------------------------------------------------------!  
  
  
!--------------------------------------------------------------------------------------------------!  
  subroutine printTestFailure()
    write(*,*) achar(27)//'[91m FAILURE '//achar(27)//'[0m'
  end subroutine printTestFailure
!--------------------------------------------------------------------------------------------------!  
  
  
!--------------------------------------------------------------------------------------------------!  
  subroutine printTestSuccess()
    write(*,*) achar(27)//'[92m SUCCESS '//achar(27)//'[0m'
  end subroutine printTestSuccess
!--------------------------------------------------------------------------------------------------!


#ifdef __WINDOWS__   
!--------------------------------------------------------------------------------------------------!
! Source : https://stackoverflow.com/questions/58926245/how-to-enable-ansi-escape-sequences-in-command-prompt-on-windows-10-by-fortran-c
!--------------------------------------------------------------------------------------------------!
  SUBROUTINE set_ansi
    USE, INTRINSIC :: ISO_C_BINDING, ONLY:  &
        DWORD => C_LONG,  &    ! C_INT32_T really, but this is per the docs
        HANDLE => C_INTPTR_T,  &
        BOOL => C_INT

    INTEGER(HANDLE), PARAMETER :: INVALID_HANDLE_VALUE = -1_HANDLE

    INTERFACE
      FUNCTION GetStdHandle(nStdHandle) BIND(C, NAME='GetStdHandle')
        IMPORT :: DWORD
        IMPORT :: HANDLE
        IMPLICIT NONE
        INTEGER(DWORD), INTENT(IN), VALUE :: nStdHandle
        INTEGER(HANDLE) :: GetStdHandle
        !DEC$ ATTRIBUTES STDCALL :: GetStdHandle
        !GCC$ ATTRIBUTES STDCALL :: GetStdHandle
      END FUNCTION GetStdHandle
    END INTERFACE
    INTEGER(DWORD), PARAMETER :: STD_INPUT_HANDLE = -10_DWORD
    INTEGER(DWORD), PARAMETER :: STD_OUTPUT_HANDLE = -11_DWORD
    INTEGER(DWORD), PARAMETER :: STD_ERROR_HANDLE = -12_DWORD

    INTERFACE
      FUNCTION GetConsoleMode(hConsoleHandle, lpMode) BIND(C, NAME='GetConsoleMode')
        IMPORT :: HANDLE
        IMPORT :: DWORD
        IMPORT :: BOOL
        IMPLICIT NONE
        INTEGER(HANDLE), INTENT(IN), VALUE :: hConsoleHandle
        INTEGER(DWORD), INTENT(OUT) :: lpMode
        !DEC$ ATTRIBUTES REFERENCE :: lpMode
        INTEGER(BOOL) :: GetConsoleMode
        !DEC$ ATTRIBUTES STDCALL :: GetConsoleMode
        !GCC$ ATTRIBUTES STDCALL :: GetConsoleMode
      END FUNCTION GetConsoleMode
    END INTERFACE
    INTEGER(DWORD), PARAMETER :: ENABLE_ECHO_INPUT = INT(Z'0004', DWORD)
    INTEGER(DWORD), PARAMETER :: ENABLE_INSERT_MODE = INT(Z'0020', DWORD)
    INTEGER(DWORD), PARAMETER :: ENABLE_LINE_INPUT = INT(Z'0002', DWORD)
    INTEGER(DWORD), PARAMETER :: ENABLE_MOUSE_INPUT = INT(Z'0010', DWORD)
    INTEGER(DWORD), PARAMETER :: ENABLE_PROCESSED_INPUT = INT(Z'0001', DWORD)
    INTEGER(DWORD), PARAMETER :: ENABLE_QUICK_EDIT_MODE = INT(Z'0040', DWORD)
    INTEGER(DWORD), PARAMETER :: ENABLE_WINDOW_INPUT = INT(Z'0008', DWORD)
    INTEGER(DWORD), PARAMETER :: ENABLE_VIRTUAL_TERMINAL_INPUT = INT(Z'0200', DWORD)
    INTEGER(DWORD), PARAMETER :: ENABLE_PROCESSED_OUTPUT = INT(Z'0001', DWORD)
    INTEGER(DWORD), PARAMETER :: ENABLE_WRAP_AT_EOL_OUTPUT = INT(Z'0002', DWORD)
    INTEGER(DWORD), PARAMETER :: ENABLE_VIRTUAL_TERMINAL_PROCESSING = INT(Z'0004', DWORD)
    INTEGER(DWORD), PARAMETER :: DISABLE_NEWLINE_AUTO_RETURN = INT(Z'00008', DWORD)
    INTEGER(DWORD), PARAMETER :: ENABLE_LVB_GRID_WORLDWIDE = INT(Z'0010', DWORD)

    INTERFACE
      FUNCTION SetConsoleMode(hConsoleHandle, dwMode) BIND(C, NAME='SetConsoleMode')
        IMPORT :: HANDLE
        IMPORT :: DWORD
        IMPORT :: BOOL
        IMPLICIT NONE
        INTEGER(HANDLE), INTENT(IN), VALUE :: hConsoleHandle
        INTEGER(DWORD), INTENT(IN), VALUE :: dwMode
        INTEGER(BOOL) :: SetConsoleMode
        !DEC$ ATTRIBUTES STDCALL :: SetConsoleMode
        !GCC$ ATTRIBUTES STDCALL :: SetConsoleMode
      END FUNCTION SetConsoleMode
    END INTERFACE
    INTEGER(DWORD), PARAMETER :: ENABLE_EXTENDED_FLAGS = INT(Z'0080', DWORD)

    INTEGER(HANDLE) :: output_handle
    INTEGER(BOOL) :: api_result
    INTEGER(DWORD) :: mode

    output_handle = GetStdHandle(STD_OUTPUT_HANDLE)
    IF (output_handle == INVALID_HANDLE_VALUE) THEN
      ERROR STOP 'GetStdHandle failed'
    END IF

    api_result = GetConsoleMode(output_handle, mode)
    IF (api_result == 0_BOOL) THEN
      ERROR STOP 'GetConsoleMode failed'
    END IF

    api_result = SetConsoleMode(  &
        output_handle,  &
        IOR(mode, ENABLE_VIRTUAL_TERMINAL_PROCESSING) )
    IF (api_result == 0_BOOL) THEN
      ERROR STOP 'SetConsoleMode failed'
    END IF

  END SUBROUTINE set_ansi
!--------------------------------------------------------------------------------------------------!
#endif

!--------------------------------------------------------------------------------------------------!
! Source : https://people.sc.fsu.edu/~jburkardt/f_src/wtime/wtime.f90
!--------------------------------------------------------------------------------------------------!
function wtime ( )

  !*****************************************************************************80
  !
  !! WTIME returns a reading of the wall clock time.
  !
  !  Discussion:
  !
  !    To get the elapsed wall clock time, call WTIME before and after a given
  !    operation, and subtract the first reading from the second.
  !
  !    This function is meant to suggest the similar routines:
  !
  !      "omp_get_wtime ( )" in OpenMP,
  !      "MPI_Wtime ( )" in MPI,
  !      and "tic" and "toc" in MATLAB.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license. 
  !
  !  Modified:
  !
  !    27 April 2009
  !
  !  Author:
  !
  !    John Burkardt
  !
  !  Parameters:
  !
  !    Output, real ( kind = rk ) WTIME, the wall clock reading, in seconds.
  !
    implicit none
  
    
    integer clock_max
    integer clock_rate
    integer clock_reading
    real ( kind = time_kind ) wtime
  
    call system_clock ( clock_reading, clock_rate, clock_max )
  
    wtime = real ( clock_reading, kind = time_kind ) &
          / real ( clock_rate, kind = time_kind )
  
    return
  end function wtime

end module mod_ftest
