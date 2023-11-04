program prog_ftest
    
    use mod_ftest
  
    implicit none
    
    ! assert with file & line info printed
    call assertTrue("true test", 1>0, __FILE__, __LINE__)

    ! assert without file or line info printed
    call assertTrue("true test", 1>0)

    ! non-terminating assert with file & line info printed
    call expectTrue("true test", 1>0, __FILE__, __LINE__)

    ! extra printing the number of successful and failed tests - just to check
    call printTestNumbers()
    
    ! expectTrue does not terminate the program on failure
    call expectTrue("false test", 0>1, __FILE__, __LINE__)
    call expectTrue("false test", 0>1, __FILE__, __LINE__)

    ! extra printing the number of successful and failed tests - just to check
    call printTestNumbers()
    
    ! testing the number of OK and NOK tests
    call assertTrue("failure and success numbers are OK", &
                   & getTestFailureNum()==2 .and. &
                   & getTestSuccessNum()==3, __FILE__, __LINE__)
  
    ! can test isolated test-cases by a logical function
    call fTest("test01", test01)

    ! can test isolated test-cases by the block ... end block Fortran feature
    isolatedTestCase : block 
      integer :: array(5) = [1,2,3,4,5]
      call assertTrue("Isolated test of a local array in a block", &
                      SUM(array) == 15,  __FILE__, __LINE__)
    end block isolatedTestCase
  
    ! extra printing the number of successful and failed tests - just to check
    call printTestNumbers()

    ! terminating on a failed assert
    call assertTrue("false test", 0>1, __FILE__, __LINE__)

contains
  
    logical function test01() 
      integer :: a = 10
      call assertTrue("Isolated test of a local variable in a logical function", &
                      a <= 10, __FILE__, __LINE__)
      test01 = .true.
    end function test01
    
end program prog_ftest
  
