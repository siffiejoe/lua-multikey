-- memoization with multiple arguments

local assert = assert
local select = assert( select )
local unpack = assert( unpack or table.unpack )

local multikey = require( "multikey" )


local function make_array( ... )
  return { n = select( '#', ... ), ... }
end


local function memoize( func )
  local store = multikey:new()
  return function( ... )
    local res = store:get( ... )
    if not res then
      res = make_array( func( ... ) )
      store:putv( res, ... )
    end
    return unpack( res, 1, res.n )
  end, store
end

return memoize

