-- memoization with multiple arguments

local assert = assert
local select = assert( select )
local unpack = assert( unpack or table.unpack )

local multikey = require( "multikey" )
local get, putv = multikey.get, multikey.putv


local function make_array( ... )
  return { n = select( '#', ... ), ... }
end


local function memoize( func )
  local store = {}
  return function( ... )
    local res = get( store, ... )
    if not res then
      res = make_array( func( ... ) )
      putv( store, res, ... )
    end
    return unpack( res, 1, res.n )
  end, store
end

return memoize

