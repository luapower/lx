
--lx ffi binding.
--Written by Cosmin Apreutesei. Public Domain.

if not ... then require'lx_test'; return end

local ffi = require'ffi'
local C = ffi.load'lx'

--number parsing options
local STRSCAN_OPT_TOINT = 0x01
local STRSCAN_OPT_TONUM = 0x02
local STRSCAN_OPT_IMAG  = 0x04
local STRSCAN_OPT_LL    = 0x08
local STRSCAN_OPT_C     = 0x10

--returned format

ffi.cdef[[
/* Returned format. */
enum {
	STRSCAN_ERROR,
	STRSCAN_NUM,
	STRSCAN_IMAG,
	STRSCAN_INT,
	STRSCAN_U32,
	STRSCAN_I64,
	STRSCAN_U64,
};

/* Token types. */
enum {
	TK_EOF = -100, TK_ERROR,
	TK_NUMBER, TK_NAME, TK_STRING, TK_LABEL,
	TK_EQ, TK_LE, TK_GE, TK_NE, TK_DOTS, TK_CONCAT,
	TK_SHL, TK_SHR,
};

/* Error codes. */
enum {
	LX_ERR_NONE    ,
	LX_ERR_XLINES  , /* chunk has too many lines */
	LX_ERR_XNUMBER , /* malformed number */
	LX_ERR_XLCOM   , /* unfinished long comment */
	LX_ERR_XLSTR   , /* unfinished long string */
	LX_ERR_XSTR    , /* unfinished string */
	LX_ERR_XESC    , /* invalid escape sequence */
	LX_ERR_XLDELIM , /* invalid long string delimiter */
};

typedef int LX_Token;
typedef struct LX_State LX_State;

typedef const char* (*LX_Reader)  (void*, size_t*);

LX_State* lx_state_create            (LX_Reader, void*);
LX_State* lx_state_create_for_file   (struct FILE*);
LX_State* lx_state_create_for_string (const char*, size_t);
void      lx_state_free              (LX_State*);

LX_Token lx_next          (LX_State*);
char*    lx_string_value  (LX_State*, int*);
int      lx_number_type   (LX_State *ls);
double   lx_double_value  (LX_State*);
int32_t  lx_int32_value   (LX_State*);
uint64_t lx_uint64_value  (LX_State*);
int      lx_error         (LX_State *ls);
int      lx_line_number   (LX_State *ls);

void lx_set_number_format (LX_State*, int);
]]

local intbuf = ffi.new'int[1]'
local function to_str(ls)
	local s = C.lx_string_value(ls, intbuf)
	return ffi.string(s, intbuf[0])
end

local msg = {
	[C.LX_ERR_XLINES ] = 'chunk has too many lines';
	[C.LX_ERR_XNUMBER] = 'malformed number';
	[C.LX_ERR_XLCOM  ] = 'unfinished long comment';
	[C.LX_ERR_XLSTR  ] = 'unfinished long string';
	[C.LX_ERR_XSTR   ] = 'unfinished string';
	[C.LX_ERR_XESC   ] = 'invalid escape sequence';
	[C.LX_ERR_XLDELIM] = 'invalid long string delimiter';
}
local function errmsg(ls)
	return msg[ls:error()]
end

ffi.metatype('LX_State', {__index = {
	free     = C.lx_state_free;
	next     = C.lx_next;
	string   = to_str;
	numtype  = C.lx_number_type;
	num      = C.lx_double_value;
	int      = C.lx_int32_value;
	ulong    = C.lx_uint64_value;
	error    = C.lx_error;
	errmsg   = errmsg;
	line     = C.lx_line_number;
}})

return C
