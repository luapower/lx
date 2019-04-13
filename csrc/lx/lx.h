/*
** LuaJIT lexer. C API. Public Domain.
*/

#ifndef _LX_H
#define _LX_H

#include <stdint.h>
#include <stdio.h>

/* number parsing options */
#define STRSCAN_OPT_TOINT  0x01  /* Convert to int32_t, if possible. */
#define STRSCAN_OPT_TONUM  0x02  /* Always convert to double. */
#define STRSCAN_OPT_IMAG   0x04
#define STRSCAN_OPT_LL     0x08
#define STRSCAN_OPT_C      0x10

/* Returned format. */
enum {
	STRSCAN_ERROR,
	STRSCAN_NUM,
	STRSCAN_IMAG,
	STRSCAN_INT,
	STRSCAN_U32,
	STRSCAN_I64,
	STRSCAN_U64
};

/* Token types. */
enum {
	TK_EOF = -100,
	TK_NUMBER, TK_NAME, TK_STRING, TK_LABEL,
	TK_EQ, TK_LE, TK_GE, TK_NE, TK_DOTS, TK_CONCAT,
	TK_SHL, TK_SHR
};

typedef int LX_Token;
typedef struct LX_State LX_State;

typedef const char* (*LX_Reader)  (void*, size_t*);

LX_State* lx_state_create            (LX_Reader, void*);
LX_State* lx_state_create_for_file   (FILE*);
LX_State* lx_state_create_for_string (const char*, size_t);
void      lx_state_free              (LX_State*);

LX_Token lx_next          (LX_State*);
LX_Token lx_lookahead     (LX_State*);
char*    lx_string_value  (LX_State*, int*);
uint32_t lx_number_format (LX_State *ls);
double   lx_double_value  (LX_State*);
int32_t  lx_int32_value   (LX_State*);
uint64_t lx_uint64_value  (LX_State*);

void lx_set_numbef_format (LX_State*, uint32_t);

#endif
