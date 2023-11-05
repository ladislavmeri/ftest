# ftest
Very minimalistic Fortran testing

## Build & Test

```
$ git clone https://github.com/ladislavmeri/ftest.git
$ cd ftest
$ make
$ make test
$ make install
```

You can find the library in the *./lib/libftest.a* and the .mod file in the *./mod/mod_ftest.mod* after the build. 
The make install command will try to copy the library to the *$HOME/.local/lib* directory and the .mod file to the *$HOME/.local/include* directory. You can change the install directories by editing the *INSTALL_PREFIX* variable in the makefile. 

