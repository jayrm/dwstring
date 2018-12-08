''  dwstring - Dynamic Wide Character String for FreeBASIC
''	Copyright (C) 2017-2018 Jeffery R. Marshall (coder[at]execulink[dot]com)
''
''  License: GNU Lesser General Public License 
''           version 2.1 (or any later version) plus
''           linking exception, see license.txt

'' COMPILING:
''	$ fbc -lib dwstring.bas
''
'' USAGE:
#include once "dwstring.bi"

#ifndef NULL
#define NULL 0
#endif

#if( __FB_DEBUG__ )
#define DLOG( msg_ ) print msg_
#else
#define DLOG( msg_ )
#endif

/'
	sizeof(code_unit) = sizeof(wstring)
	len(DWSTRING) = length of dwstring (in code units) not including null terminator

	_data
		pointer to the string data - if null, handle as
		zero length string

	_length
		number of code units (not bytes) in the string
		not including null terminator.  if == -1 then
		the actual length of the string is not known until
		length( data ) is computed.

	_size
		number of code units (not bytes) the buffer can 
		hold including the null terminator

	example:
		_data = ABCD\0\0\0\0\0\0
		_size = 10
		_length = 4
'/

''
private function WSTRING_ALLOC( byval n as uinteger ) as wstring ptr
	function = cast( wstring ptr, callocate( (n), sizeof(wstring) ))
end function

''
private sub WSTRING_COPYN( byval dst as wstring ptr, byval src as const wstring const ptr, byval nchars as uinteger )
	if( (dst <> NULL) andalso (src <> NULL) andalso (src <> dst) andalso (nchars>0) ) then
		for i as integer = 0 to nchars-1
			dst[i] = src[i]
		next
	end if
end sub

''
private sub WSTRING_MOVEN( byval dst as wstring ptr, byval src as const wstring const ptr, byval nchars as uinteger )

	if( (dst <> NULL) andalso (src <> NULL) andalso (src <> dst) andalso (nchars>0) ) then
		if( src > dst ) then
			for i as integer = 0 to nchars-1
				dst[i] = src[i]
			next
		else
			for i as integer = nchars-1 to 0 step -1
				dst[i] = src[i]
			next
		end if
	end if

end sub

''
private sub WSTRING_FREE( byval p as any ptr )
	deallocate p
end sub

#define WSTRING_LEN(s) len(s)
#define STRING_LEN(s) len(s)

'' --------------------------------------------------------
'' DWSTRING
'' --------------------------------------------------------

''
'' set null string descriptor
''
sub DWSTRING._initialize()
	_data = NULL
	_length = 0
	_size = 0
end sub

''
'' free string and set null descriptor
''
sub DWSTRING._clear()

	'' !!! possible options
	''       - [ ] keep buffer, zero length (faster)
	''       - [*] delete buffer (use less memory)

	if( _data ) then
		WSTRING_FREE( _data )
	end if
	_initialize()

end sub

''
'' set a new length (in code units) for the string buffer
'' - increase the size of the buffer if needed
'' - preserve contents if _length is >= 0
''
function DWSTRING._setsize( byval maxlength as const integer ) as boolean

	'' !!! possible options
	''       - [*] param is length (size is length + 1 )
	''       - [ ] param is size
	''       - [ ] enforce a minimum size

	'' unusable size, return a null string descriptor
	if( maxlength <= 0 ) then
		_clear()
		return TRUE	
	end if

	'' allocate data if does not exist
	if( _data = NULL ) then
		_data = WSTRING_ALLOC( maxlength + 1 )
		if( _data = NULL ) then
			return FALSE
		end if
		
		_data[0] = 0
		_size = maxlength + 1

		'' assume data will be loaded with zero-terminated string
		_length = -1 
		
		return TRUE

	end if

	'' less?
	if( maxlength < _size ) then

		'' set null terminator
		_data[maxlength] = 0

		return TRUE

	end if
	
	'' it's larger... resize the buffer
	dim as wstring ptr newdata = WSTRING_ALLOC( maxlength + 1 )

	if( newdata = NULL ) then
		return FALSE
	end if

	newdata[0] = 0
	if( _length >= 0 ) then
		WSTRING_COPYN( newdata, _data, _length + 1 )
	end if

	WSTRING_FREE( _data )
	_data = newdata

	_size = maxlength + 1

	return TRUE

end function

''
'' assign (setsize+copy) string to buffer
''
function DWSTRING._assign _
	( _
		byval s as const wstring const ptr, _
		byval length as integer _
	) as boolean

	if( s = _data ) then
		return TRUE
	end if

	if( s = NULL ) then
		_clear()
		return TRUE
	end if

	if( length < 0 ) then
		length = WSTRING_LEN( *s )
	end if

	if( length <= 0 ) then
		_clear()
		return TRUE
	end if

	_length = -1

	if( _setsize( length ) ) then
		WSTRING_COPYN( _data, s, length + 1 )
		_length = length
		return TRUE
	end if
	
	return FALSE

end function

''
'' concat (setsize+append) string to buffer
''
function DWSTRING._concat( byval s as const wstring const ptr, byval length as integer ) as boolean

	DLOG( "_concat(" & hex(s) & ", " & length & ")" )

	if( s = NULL ) then
		return TRUE
	end if

	if( length < 0 ) then
		length = WSTRING_LEN( *s )
	end if

	if( length <= 0 ) then
		return TRUE
	end if

	if( _length < 0 ) then
		_length = WSTRING_LEN( *_data )
	end if

	'' Check if s points to data within _data 
	'' and if length+_length is greater than _size.  
	'' if it is then, _setsize() will destroy the buffer
	'' and the s will be corrupted.  Instead, allocate
	'' a buffer and concatenate the strings.

	if( s >= _data and s < _data+_size) then
		DLOG( "S is in _data" )
		if( _length + length + 1 > _size ) then
			DLOG( "growing" )
			dim as wstring ptr newdata = WSTRING_ALLOC( _length + length + 1 )
			if( newdata = NULL ) then
				return FALSE
			end if
			WSTRING_COPYN( newdata, _data, _length )
			WSTRING_COPYN( newdata+_length, s, length + 1 )
			_length = _length + length
			_size = _length + 1
			if( _data ) then
				WSTRING_FREE( _data )
			end if
			_data = newdata
			return TRUE
		end if
	end if

	if( _setsize( _length + length ) ) then
		WSTRING_COPYN( _data + _length, s, length + 1 )
		_length += length
		return TRUE

	end if

	return FALSE

end function

'' --------------------------------------------------------
'' DWSTRING ctor/dtor
'' --------------------------------------------------------

''
constructor DWSTRING()
	DLOG( "DWSTRING()" )
	_initialize()
end constructor

''
constructor DWSTRING( byval s as const wstring const ptr, byval initlength as const integer )
	DLOG( "DWSTRING(const wstring const ptr, const integer)" )
	_initialize()

	'' !!! options
	''       - [*] len(s) always computed
	''       - [ ] initlength is length of *s
	''       - [ ] 1 param for length of s, 1 param for size of buffer

	dim n as integer = 0

	_initialize()

	if( s ) then
		n = WSTRING_LEN(*s)
	end if

	if( initlength > n ) then
		n = initlength
	end if

	if( n > 0 ) then
		if( _setsize( n ) ) then
			if( s ) then
				if( n > 0 ) then	
					WSTRING_COPYN( _data, s, n )
				end if
				_data[n] = 0
				_length = n
			else
				_data[0] = 0
				_length = 0
			end if
		end if
	end if
end constructor

''
constructor DWSTRING( byval s as const wstring const ptr )
	DLOG( "DWSTRING(const wstring const ptr)" )
	_initialize()
	_assign( s, -1 )
end constructor

''
constructor DWSTRING( byref s as const DWSTRING )
	DLOG( "DWSTRING(DWSTRING&)" )
	_initialize()
	_assign( s._data, s._length)
end constructor

''
constructor DWSTRING( byref s as const string )
	DLOG( "DWSTRING(string)" )
	_initialize()
	dim n as integer = STRING_LEN(s)
	if( n > 0 ) then
		if( _setsize( n ) ) then
			*_data = wstr(s)
			_length = n
		end if
	end if
end constructor

''
destructor DWSTRING()
	if( _data ) then
		WSTRING_FREE( _data )
	end if
end destructor

'' --------------------------------------------------------
'' DWSTRING methods/getters/setters
'' --------------------------------------------------------

''
sub DWSTRING.Clear()
	_clear()
end sub

''
'' returns the maximum number of code units including the 
'' null terminator that can be stored in the string buffer
''
function DWSTRING.GetSize() as integer
	return _size
end function

''
'' returns the number of bytes allocated for the string
'' buffer
''
function DWSTRING.GetByteSize() as integer
	return GetSize() * sizeof( wstring )
end function

''
'' returns the number of code units (not including the 
'' null terminator) of the string stored in the string 
'' buffer.  returns 0 if no buffer is allocated.
''
function DWSTRING.GetLength() as integer
	if( _length < 0 ) then
		if( _data ) then
			return WSTRING_LEN( *_data )
		end if
	end if
	return _length
end function

''
'' returns the number of bytes (not including the null
'' terminator) occuiped by the string stored in the
'' string buffer.  returns 0 if no buffer is allocated.
''
function DWSTRING.GetByteLength() as integer
	return GetLength() * sizeof( wstring )
end function

'' --------------------------------------------------------
'' DWSTRING conversion
'' --------------------------------------------------------

function DWSTRING.GetDataPtr() as wstring ptr
	function = _data
end function

''
operator DWSTRING.Cast() as string
	DLOG( "<<str>>"; )
	if( _data ) then
		'' use FB's conversion routine fb_WstrToStr()
		operator = str( *_data )
	else
		operator = ""
	end if
end operator

''
operator DWSTRING.Cast() as wstring ptr
	DLOG( "<<wstr_ptr>>"; )
	operator = _data
end operator

'' --------------------------------------------------------
'' DWSTRING assignment
'' --------------------------------------------------------

''
function DWSTRING.Assign( byref s as const DWSTRING ) as boolean
	DLOG( "Assign(DWSRING)" )
	return _assign( s._data, s._length )
end function

''
operator DWSTRING.Let( byref s as const DWSTRING )
	DLOG( "Let(DWSTRING)" )
	_assign( s._data, s._length )
end operator

''
operator DWSTRING.Let( byref s as const string )
	'' use constructor DWSTRING(string) to do the conversion
	DLOG( "Let(string)" )
	this = type<DWSTRING>( s )
end operator

''
operator DWSTRING.Let( byval s as const wstring const ptr )
	'' use constructor DWSTRING(const wstring const ptr) to do the conversion
	DLOG( "Let(const wstring const ptr)" )
	this = type<DWSTRING>( s )
end operator

''
function DWSTRING.Append( byref s as const DWSTRING ) as boolean
	DLOG( "Append(DWSTRING)" )
	return _concat( s._data, s._length )
end function

''
function DWSTRING.Append( byval s as const wstring const ptr ) as boolean
	DLOG( "Append(wstring ptr)" )
	return _concat( s, -1 )
end function

''
operator DWSTRING.&= ( byref s as const DWSTRING )
	DLOG( "&=(DWSTRING)" )
	Append( s )
end operator

''
operator DWSTRING.+= ( byref s as const DWSTRING )
	DLOG( "+=(DWSTRING)" )
	Append( s )
end operator

'' --------------------------------------------------------

operator Len( byref s as const DWSTRING ) as integer
	operator = s.GetLength()
end operator

operator + ( byref s1 as const DWSTRING, byref s2 as const DWSTRING ) as DWSTRING
	DLOG( "+(DWSTRING,DWSTRING)" )
	dim t as DWSTRING = DWSTRING( NULL, len(s1) + len(s2) )
	t.Append( s1 )
	t.Append( s2 )
	return t
end operator

operator + ( byval s1 as const wstring ptr, byref s2 as const DWSTRING ) as DWSTRING
	DLOG( "+(wstring ptr,DWSTRING)" )
	dim n as const integer = iif( s1, WSTRING_LEN(*s1), 0 )
	dim t as DWSTRING = DWSTRING( s1, n + len(s2) )
	t.Append( s2 )
	return t
end operator

operator + ( byref s1 as const DWSTRING, byval s2 as const wstring ptr ) as DWSTRING
	DLOG( "+(DWSTRING,wstring ptr)" )
	dim n as const integer = iif( s2, WSTRING_LEN(*s2), 0 )
	dim t as DWSTRING = DWSTRING( NULL, len(s1) + n )
	t.Append( s1 )
	t.Append( s2 )
	return t
end operator

operator & ( byref s1 as const DWSTRING, byref s2 as const DWSTRING ) as DWSTRING
	DLOG( !"&(DWSTRING,DWSTRING)" )
	return s1 + s2
end operator

'' --------------------------------------------------------
''
'' compare this to other dwstring and returns a result( this - other )
''

''
const function DWSTRING.Compare( byref other as const DWSTRING ) as integer
	
	dim i as integer = 0
	dim this_n as integer = this.GetLength()
	dim other_n as integer = other.GetLength()
	dim n as integer = iif( other_n < this_n, other_n, this_n )

	while( i < n )
		dim d as integer = int(this._data[i]) - int(other._data[i])
		if( d <> 0 ) then
			return (i+1) * sgn(d)
		end if
		i += 1
	wend

	if( this_n > other_n ) then
		return other_n + 1
	elseif( this_n < other_n ) then
		return -(this_n + 1)
	end if

	return 0
	
end function

''
operator = ( byref s1 as const DWSTRING, byref s2 as const DWSTRING ) as integer
	return s1.Compare( s2 ) = 0
end operator

''
operator <> ( byref s1 as const DWSTRING, byref s2 as const DWSTRING ) as integer
	return s1.Compare( s2 ) <> 0
end operator

''
operator < ( byref s1 as const DWSTRING, byref s2 as const DWSTRING ) as integer
	return s1.Compare( s2 ) < 0
end operator

''
operator > ( byref s1 as const DWSTRING, byref s2 as const DWSTRING ) as integer
	return s1.Compare( s2 ) > 0
end operator

''
operator <= ( byref s1 as const DWSTRING, byref s2 as const DWSTRING ) as integer
	return s1.Compare( s2 ) <= 0
end operator

''
operator >= ( byref s1 as const DWSTRING, byref s2 as const DWSTRING ) as integer
	return s1.Compare( s2 ) >= 0
end operator

'' --------------------------------------------------------
''
'' compare this to other wstring ptr and returns a result( this - other )
''

''
const function DWSTRING.Compare( byval other as const wstring ptr ) as integer
	
	dim i as integer = 0
	dim this_n as integer = this.GetLength()
	dim other_n as integer = len(*other)
	dim n as integer = iif( other_n < this_n, other_n, this_n )

	while( i < n )
		dim d as integer = int(this._data[i]) - int(other[i])
		if( d <> 0 ) then
			return (i+1) * sgn(d)
		end if
		i += 1
	wend

	if( this_n > other_n ) then
		return other_n + 1
	elseif( this_n < other_n ) then
		return -(this_n + 1)
	end if

	return 0
	
end function

''
operator = ( byref s1 as const DWSTRING, byval s2 as const wstring ptr ) as integer
	return s1.Compare( s2 ) = 0
end operator

''
operator <> ( byref s1 as const DWSTRING, byval s2 as const wstring ptr ) as integer
	return s1.Compare( s2 ) <> 0
end operator

''
operator < ( byref s1 as const DWSTRING, byval s2 as const wstring ptr ) as integer
	return s1.Compare( s2 ) < 0
end operator

''
operator > ( byref s1 as const DWSTRING, byval s2 as const wstring ptr ) as integer
	return s1.Compare( s2 ) > 0
end operator

''
operator <= ( byref s1 as const DWSTRING, byval s2 as const wstring ptr ) as integer
	return s1.Compare( s2 ) <= 0
end operator

''
operator >= ( byref s1 as const DWSTRING, byval s2 as const wstring ptr ) as integer
	return s1.Compare( s2 ) >= 0
end operator

'' --------------------------------------------------------
'' DWSTRING sub-strings
'' --------------------------------------------------------

const operator DWSTRING.[]( byval index as const uinteger ) as integer
	if( index < this.GetLength() ) then
		operator = _data[index]
	else
		operator = 0
	end if
end operator
