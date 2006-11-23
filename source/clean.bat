@echo off
rem  Remove all unnecessary files. Object files etc. Things that
rem  are generated by the build, and are not source files.

del *.o
del *.obj
del emake.bat
del objfiles.lnk
del icode.lst
del ex.err
del junk

rem DO NOT CREATE A FILE WITH ONE OF THESE NAMES:
rem USE BE_*.c for back end source files

del EMIT_0.C
del EMIT_1.C
del PARSER.C
del ERROR.C
del PARSER_1.C
del MAIN.C
del INT.C
del MAIN-0.C
del SCANNE_0.C
del SYMTAB.C
del PARSER_0.C
del SCANNER.C
del EMIT.C
del PATHOPEN.C
del FILE.C
del BACKEND.C
del COMPRESS.C
del MACHINE.C
del WILDCARD.C
del 0ACKEND.C
del MAIN-.C
del MAIN-.H
del INIT-.C
