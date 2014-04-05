#!/usr/bin/lua

package.path = "../src/?.lua;" .. package.path
local multikey = require( "multikey" )

local t1 = multikey()

print( "nil ==", t1:get( 1,"x",3,4 ) )
t1:put( 1,"x",3,4,  "bla" )
print( "bla ==", t1:get( 1,"x",3,4 ) )
print( "nil ==", t1:get( 1,"x",3 ) )
t1:putv( "blub",  1,"x",3 )
print( "blub ==", t1:get( 1,"x",3 ) )
print( "bla ==", t1:get( 1,"x",3,4 ) )
t1:put( "val0" )
print( "val0 ==", t1:get() )
t1:put( 1,"x",nil,4,  "foo" )
print( "foo ==", t1:get( 1,"x",nil,4 ) )
t1:put( 1,"x",0/0,"a",  "baz" )
print( "baz ==", t1:get( 1,"x",0/0,"a" ) )
t1:put( 1,1,1,  "first" )
t1:put( 1,1,2,  "second" )
t1:put( 1,2,1,  "third" )
t1:put( 2,      "fourth" )

print( "pairs-like with 1,'x' prefix" )
for _, a, b, c, d, e in t1:tuples( 1,"x" ) do
  print( a, b, c, d, e )
end

print( "ipairs-like with 1,1 prefix" )
for a, b, c, d in t1:ituples( 1,1 ) do
  print( a, b, c, d )
end

t1:put()
t1:put( 1,"x",3,  nil )
print( "bla ==", t1:get( 1,"x",3,4 ) )
t1:put( 1,"x",3,4,  nil )
t1:put( 1,"x",nil,4,  nil )
t1:put( 1,"x",0/0,"a",  nil )
t1:put( 1,1,1,  nil )
t1:put( 1,1,2,  nil )
t1:put( 1,2,1,  nil )
t1:put( 2,      nil )
print( next( t1._keys ), next( t1._values ) )

t1:put( 1,  1 )
print( "1 ==", t1:get( 1 ) )
t1:clear()
print( next( t1._keys ), next( t1._values ) )

t1:put( 1, 2, nil, nil,  2 )
t1:put( 1, 2, nil, nil, 3,  nil )
t1:put( 1, 2, nil, nil, nil,  nil )
print( "2 ==", t1:get( 1, 2, nil, nil ) )
print( "nil ==", t1:get( 1, 2, nil, nil, 3 ) )
print( "nil ==", t1:get( 1, 2, nil, nil, nil ) )
t1:put( 1, 2, nil, nil,  nil )
print( next( t1._keys ), next( t1._values ) )

