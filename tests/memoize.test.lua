#!/usr/bin/lua

package.path = "../src/?.lua;" .. package.path
local memoize = require( "multikey.memoize" )
local unpack = unpack or table.unpack

local function args_table( ... )
  return { n = select( '#', ... ), ... }
end

local function func( nr, a, b, c, d )
  print( "test call nr.", nr )
  return a, b, c+d
end

local args = {
  args_table( 1, nil, 2, 3 ),
  args_table( 1, 2, 3, 4 ),
  args_table( "x", {}, 4, 7 ),
}

local test = memoize( func )

local function dotest( nr )
  print( "results = ", test( nr, unpack( args[ nr ], 1, args[ nr ].n ) ) )
end


dotest( 1 )
dotest( 1 )
dotest( 2 )
dotest( 2 )
dotest( 2 )
dotest( 2 )
dotest( 3 )
dotest( 3 )
dotest( 3 )

