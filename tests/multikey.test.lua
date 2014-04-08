#!/usr/bin/lua

package.path = "../src/?.lua;" .. package.path
local mk = require( "multikey" )
local get, put, putv = mk.get, mk.put, mk.putv

local t1 = {}


assert( get( t1, 1,"x",3,4 ) == nil )
put( t1, 1,"x",3,4,  "bla" )
assert( get( t1, 1,"x",3,4 ) == "bla" )
assert( get( t1, 1,"x",3 ) == nil )
putv( t1, "blub", 1,"x",3 )
assert( get( t1, 1,"x",3 ) == "blub" )
assert( get( t1, 1,"x",3,4 ) == "bla" )
put( t1, "val0" )
assert( get( t1 ) == "val0" )
put( t1, 1,"x",nil,4,  "foo" )
assert( get( t1, 1,"x",nil,4 ) == "foo" )
put( t1, 1,"x",0/0,"a",  "baz" )
assert( get( t1, 1,"x",0/0,"a" ) == "baz" )
put( t1, 1,1,1,  1 )
put( t1, 1,1,2,  2 )
put( t1, 1,2,1,  3 )
put( t1, 2,      4 )

local count = 0
print( "pairs-like with 1,'x' prefix" )
for _, a, b, c, d, e in mk.tuples( t1, 1,"x" ) do
  count = count + 1
  assert( a == 1 and b == "x" )
  print( a, b, c, d, e )
end
assert( count == 4 )

count = 0
print( "ipairs-like with 1,1 prefix" )
for a, b, c, d in mk.ituples( t1, 1,1 ) do
  count = count + 1
  assert( a == 1 and b == 1 and d == count )
  print( a, b, c, d )
end
assert( count == 2 )

put( t1 )
put( t1, 1,"x",3,  nil )
assert( get( t1, 1,"x",3,4 ) == "bla" )
put( t1, 1,"x",3,4,  nil )
put( t1, 1,"x",nil,4,  nil )
put( t1, 1,"x",0/0,"a",  nil )
put( t1, 1,1,1,  nil )
put( t1, 1,1,2,  nil )
put( t1, 1,2,1,  nil )
put( t1, 2,      nil )

count = 0
for k,v in next, t1 do
  count = count + 1
  assert( type( k ) == "table" and type( v ) == "table" )
  print( "t1:", k, v )
end
assert( count == 1 )

t2 = mk.new()
t2:put( 1,  1 )
assert( t2:get( 1 ) == 1 )
t2:clear()

count = 0
for k,v in next, t2 do
  count = count + 1
  assert( type( k ) == "table" and type( v ) == "table" )
  print( "t2:", k, v )
end
assert( count <= 1 )

t2:put( 1, 2, nil, nil,  2 )
t2:put( 1, 2, nil, nil, 3,  nil )
t2:put( 1, 2, nil, nil, nil,  nil )
assert( t2:get( 1,2,nil,nil ) == 2 )
assert( t2:get( 1,2,nil,nil,3 ) == nil )
assert( t2:get( 1,2,nil,nil,nil ) == nil )
t2:put( 1, 2, nil, nil,  nil )

count = 0
for k,v in next, t2 do
  count = count + 1
  assert( type( k ) == "table" and type( v ) == "table" )
  print( "t2:", k, v )
end
assert( count == 1 )
print( "ok" )

