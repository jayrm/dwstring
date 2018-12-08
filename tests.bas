#include once "dwstring.bi"

#macro hCheckString( x, s )
	scope
		if( len(x) <> len(s) ) then
			print "failed: length " & len(x) & " <> " & len(s) & " @ line " & __LINE__
		else
			for i as integer = 0 to len(x)
				if( x[i] <> s[i] ) then
					print "failed: strings not equal @ line " & __LINE__
					exit for
				end if
			next
		end if
	end scope
#endmacro


'' initialization

print "Initialization"

scope

	'' declare constructor()
	scope
		dim x as dwstring
		dim z as wstring * 50
		hCheckString( x, z )
	end scope

	'' declare constructor( byref rhs as const DWSTRING )
	scope
		dim w as wstring * 50 = !"wstring\u4644"
		dim x as dwstring = w
		dim y as dwstring = x
		hCheckString( x, y )
	end scope

	'' declare constructor( byref rhs as const string )
	scope
		dim s as string = "ansi"
		dim w as wstring * 1000 = s
		dim x as dwstring = s
		hCheckString( x, w )
	end scope

	'' declare constructor( byval rhs as const wstring const ptr )
	scope
		dim w as wstring * 50 = !"wstring\u4644"
		dim x as dwstring = @w
		hCheckString( x, w )
	end scope

	'' declare constructor( byval rhs as const wstring const ptr, byval initlength as const integer )
	scope
		dim w as string * 4 = !"\u0000\u0000\u0000\u0000"
		dim x as dwstring = dwstring( w, 4 )
		'' This will fail, dwstring class can create a string
		'' filled with NULL characters, but fbc's WSTRING only
		'' treats it as NULL terminated, so lengths won't match
		hCheckString( x, w )
	end scope

end scope

print "RTL functions"

scope
	
	'' wchr
	scope
		dim w as wstring * 50 = wchr( 1234 )
		dim x as dwstring = wchr( 1234 )
		hCheckString( x, w )
	end scope
	
	'' wspace
	scope
		dim w as wstring * 50 = wspace( 10 )
		dim x as dwstring = wspace( 10 )
		hCheckString( x, w )
	end scope

	'' wstring
	scope
		dim w as wstring * 50 = wstring( 10, 1234 )
		dim x as dwstring = wstring( 10, 1234 )
		hCheckString( x, w )
	end scope

	'' left
	scope
		dim w as wstring * 50 = !"wstring\u4644" & wspace(5)
		dim x as dwstring = w
		w = "'" & left( w, 3 ) & "'"
		'' !!! fail, ambiguous call to overloaded function
		'' x = "'" & left( x, 3 ) & "'"
		hCheckString( x, w )
	end scope

	'' ltrim
	scope
		dim w as wstring * 50 = wspace(5) & !"wstring\u4644" & wspace(5)
		dim x as dwstring = w
		w = "'" & ltrim( w ) & "'"
		x = "'" & ltrim( x ) & "'"
		'' !!! fail, implicit cast to STRING instead of WSTRING PTR
		hCheckString( x, w )
	end scope

end scope
