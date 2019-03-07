#!/usr/bin/lua

package.path = "../src/?.lua;" .. package.path
local tuple = require( "multikey.tuple" )


do
  local t1 = tuple( 1, 2, 3 )
  print( t1[ 1 ], t1[ 2 ], t1[ 3 ], t1.n )
  local t2 = tuple( 1, 2, 3 )
  print( t2[ 1 ], t2[ 2 ], t2[ 3 ], t2.n )
  local t = { [ t1 ] = true }
  print( "ok?", t[ t2 ] )
  print( "addresses:", t1, t2 )
end

collectgarbage()
collectgarbage()

do
  local t1 = tuple( 1, 2, 3 )
  print( "address:", t1 )
end

