-- simple interning tuple implementation

local assert = assert
local next = assert( next )
local select = assert( select )
local error = assert( error )
local setmetatable = assert( setmetatable )
local getmetatable = assert( getmetatable )
local unpack = assert( unpack or table.unpack )
local newproxy = newproxy

local multikey = require( "multikey" )
local get, putv = multikey.get, multikey.putv


local cache = {}
-- hack to create the internal data structures in the cache:
putv( cache, 1, 1 )
putv( cache, nil, 1 )
-- hack to get a reference to the internal index data structure,
-- to protect it, because we want to make the cache weak:
local _, INDEX = next( cache )
setmetatable( cache, { __mode="v", INDEX = INDEX } )


local function make_array( ... )
  return { n = select( '#', ... ), ... }
end


local function read_only( t )
  error( "tuple is read-only data structure" )
end


local function remove_self( t )
  putv( cache, nil, unpack( getmetatable( t ).__index, 1, t.n ) )
end


local function tuple( ... )
  local v = get( cache, ... )
  if not v then
    v = newproxy and newproxy( true )
                 or setmetatable( {}, { __gc = true } )
    local m = getmetatable( v )
    m.__index = make_array( ... )
    m.__newindex = read_only
    m.__gc = remove_self
    putv( cache, v, ... )
  end
  return v
end

return tuple

