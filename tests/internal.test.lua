#!/usr/bin/lua

package.path = "../src/?.lua;../../microscope/src/?.lua;" .. package.path
local multikey = require( "multikey" )
local microscope = require( "microscope" )

local mt = multikey()
mt:put( "a", "a" )
mt:put( "a","b", "a,b" )
mt:put( "a","c", "a,c" )

microscope( "internal.dot", mt, "nometatables", "leaves" )

