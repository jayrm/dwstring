''  dwstring - Dynamic Wide Character String for FreeBASIC
''	Copyright (C) 2017-2018 Jeffery R. Marshall (coder[at]execulink[dot]com)
''
''  License: GNU Lesser General Public License 
''           version 2.1 (or any later version) plus
''           linking exception, see license.txt

#ifndef __DWSTRING_BI_INCLUDE__
#define __DWSTRING_BI_INCLUDE__

'' --------------------------------------------------------
'' DWSTRING
'' --------------------------------------------------------

#inclib "dwstring"

type DWSTRING

	private:
		_data as wstring ptr
		_length as integer
		_size as integer

		declare sub _initialize()
		declare sub _clear()
		declare function _setsize( byval newsize as const integer ) as boolean
		declare function _assign( byval s as const wstring const ptr, byval length as integer ) as boolean
		declare function _concat( byval s as const wstring const ptr, byval length as integer ) as boolean
		declare operator Cast() byref as wstring

	public:
		declare constructor()
		declare constructor( byval rhs as const wstring const ptr, byval initlength as const integer )
		declare constructor( byval rhs as const wstring const ptr )
		declare constructor( byref rhs as const DWSTRING )
		declare constructor( byref rhs as const string )
		declare destructor()

		declare sub Clear()
		declare const function GetSize() as integer
		declare const function GetByteSize() as integer
		declare const function GetLength() as integer
		declare const function GetByteLength() as integer

		declare const function GetDataPtr() as wstring ptr
		declare operator Cast() as string
		declare operator Cast() as wstring ptr
		

		declare function Assign( byref rhs as const DWSTRING ) as boolean
		declare function Append( byref rhs as const DWSTRING ) as boolean
		declare function Append( byval rhs as const wstring const ptr ) as boolean

		declare operator Let( byref rhs as const DWSTRING )
		declare operator Let( byref rhs as const string )
		declare operator Let( byval rhs as const wstring const ptr )

		declare operator &= ( byref rhs as const DWSTRING )
		declare operator += ( byref rhs as const DWSTRING )

		declare const operator[]( byval index as const uinteger ) as integer

		declare const function Compare( byref rhs as const DWSTRING ) as integer
		declare const function Compare( byval rhs as const wstring ptr ) as integer
		
end type

declare operator Len( byref s as const DWSTRING ) as integer

declare operator + ( byref s1 as const DWSTRING, byref s2 as const DWSTRING ) as DWSTRING
declare operator + ( byval lhs as const wstring ptr, byref s2 as const DWSTRING ) as DWSTRING
declare operator + ( byref s1 as const DWSTRING, byval s2 as const wstring ptr ) as DWSTRING

declare operator & ( byref s1 as const DWSTRING, byref s2 as const DWSTRING ) as DWSTRING

declare operator = ( byref s1 as const DWSTRING, byref s2 as const DWSTRING ) as integer
declare operator <> ( byref s1 as const DWSTRING, byref s2 as const DWSTRING ) as integer
declare operator < ( byref s1 as const DWSTRING, byref s2 as const DWSTRING ) as integer
declare operator > ( byref s1 as const DWSTRING, byref s2 as const DWSTRING ) as integer
declare operator <= ( byref s1 as const DWSTRING, byref s2 as const DWSTRING ) as integer
declare operator >= ( byref s1 as const DWSTRING, byref s2 as const DWSTRING ) as integer

declare operator = ( byref s1 as const DWSTRING, byval s2 as const wstring ptr ) as integer
declare operator <> ( byref s1 as const DWSTRING, byval s2 as const wstring ptr ) as integer
declare operator < ( byref s1 as const DWSTRING, byval s2 as const wstring ptr ) as integer
declare operator > ( byref s1 as const DWSTRING, byval s2 as const wstring ptr ) as integer
declare operator <= ( byref s1 as const DWSTRING, byval s2 as const wstring ptr ) as integer
declare operator >= ( byref s1 as const DWSTRING, byval s2 as const wstring ptr ) as integer

#endif
