/*****************************************************************************/
/*                                                                           */
/*                              GLOBAL DEFINES                               */
/*                                                                           */
/*****************************************************************************/

#if defined(EUNIX) || defined(DJGPP)
/* use glibc 64bit variants */
#define _LARGEFILE_SOURCE
#define _LARGEFILE64_SOURCE
#include <sys/types.h>
#include <unistd.h>
#include <errno.h>
#define IFILE FILE*
#define IOFF long long
#define iopen fopen64
#define igets fgets
#define igetc fgetc
#define iputs fputs
#define iputc fputc
#define iread fread64
#define iwrite fwrite
// these don't seem to exist???
//#define iseek fseek64
//#define itell ftell64
// these seem to be only 32 bit???
//#define iseek(f,o,w) lseek64(fileno(f),(o),(w))
//#define itell(f) lseek64(fileno(f), (long long)0, SEEK_CUR)
long long llseek(int,long long,int);
#define iseek(f,o,w) llseek(fileno(f),(o),(w))
#define itell(f) llseek(fileno(f), (long long)0, SEEK_CUR)
#define iiseek fseek
#define iitell ftell
#define iflush fflush
#define iclose fclose
#define ifileno fileno
#define iprintf fprintf
#else
/* no 64bit support */
#define IFILE FILE*
#define IOFF long
#define iopen fopen
#define igets fgets
#define igetc fgetc
#define iputs fputs
#define iputc fputc
#define iread fread
#define iwrite fwrite
#define iseek fseek
#define itell ftell
#define iflush fflush
#define iclose fclose
#define ifileno fileno
#define iprintf fprintf
#endif

#undef TRUE
#undef FALSE
#define TRUE  1
#define FALSE 0

/* screens */
#define MAIN_SCREEN 1
#define DEBUG_SCREEN 2

#define MAX_LONG 0x7fffffffL /* largest positive long integer */
#define LMAX 200             /* maximum input line length */

#if defined(EBORLAND) || defined(ELCC) || defined(EDJGPP)
#define PATH_MAX 512
#endif

struct time_info {
	char *name;
	long start_ticks;
	long num_events;
	long tot_ticks;
};

#if defined(EUNIX) || defined(EDJGPP) || defined(ELCC) || defined(EBORLAND)
#define KEYBUFF_SIZE 50
#define __far
#ifndef EBORLAND
#define FAR
#endif
#if defined(ELCC)
void show_console();
#else
#ifndef EBORLAND
typedef int (*FARPROC)();
#define CALLBACK
#define WINAPI
#endif
#endif
#define __interrupt
#define LRESULT long
#if !defined(EBORLAND) && !defined(ELCC) && !defined(EDJGPP)
#define O_TEXT 0
#define HINSTANCE int
#endif
struct videoconfig {
	int monitor;
#define _MONO 1
#define _ANALOGMONO 2
#define _COLOR 3
	int mode;
	int numcolors;
	int numxpixels;
	int numypixels;
	int numtextrows;
	int numtextcols;
	int numvideopages;
#ifdef EDJGPP
	int mask; // mask pixel values for compatibility
	int x;    // pixel coordinate for text in graphics modes
	int y;    // pixel coordinate for text in graphics modes
#endif
};
#define _WHITE 7
#define _BLACK 0
#define _BLUE 4
#define _BROWN 3
#define _CYAN 6
#define _YELLOW 11
struct rccoord {
	int row;
	int col;
};
#endif

#ifdef EUNIX
#define PATH_SEPARATOR ':'
#define SLASH '/'
#else
#define PATH_SEPARATOR ';'
#define SLASH '\\'
#endif

#if defined(EUNIX) || defined(EDJGPP)
#define WORD unsigned short
#define __stdcall
#define __cdecl
#else
/* So WATCOM debugger will work better: */
#ifndef EXTRA_CHECK
#pragma aux RTFatal aborts;
#pragma aux CompileErr aborts;
#pragma aux SafeErr aborts;
#pragma aux RTInternal aborts;
#pragma aux InternalErr aborts;
#pragma aux SpaceMessage aborts;
#pragma aux Cleanup aborts;
#endif
#endif

#ifdef EWINDOWS
// Use Heap functions for everything.
// Avoid using strdup() or other functions that return malloc'd blocks
#define malloc(n) HeapAlloc((void *)default_heap, 0, n)
#define free(p) HeapFree((void *)default_heap, 0, p)
#define realloc(p, n) HeapReAlloc((void *)default_heap, 0, p, n)
#endif

