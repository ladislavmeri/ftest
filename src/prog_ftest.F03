program prog_ftest
    
    use mod_ftest
  
    implicit none
    
    call assertTrue("true test", 1>0, __FILE__, __LINE__)
    call assertTrue("true test", 1>0)
    call expectTrue("true test", 1>0, __FILE__, __LINE__)
    call printTestNumbers()
    
    call expectTrue("false test", 0>1, __FILE__, __LINE__)
    call expectTrue("false test", 0>1, __FILE__, __LINE__)
    call printTestNumbers()
    
    call assertTrue("failure and success numbers are OK", &
                   & getTestFailureNum()==2 .and. &
                   & getTestSuccessNum()==3, __FILE__, __LINE__)
  
  
  
    call fTest("test01", test01)
  
    call printTestNumbers()
  
    stop  
    
contains
  
    logical function test01() 
      call assertTrue("true test", 1>0, __FILE__, __LINE__)
      test01 = .true.
    end function test01
    
end program prog_ftest
  
