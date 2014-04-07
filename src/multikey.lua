-- simple table adaptor for using multiple keys in a lookup table

-- cache some global functions/tables for faster access
local assert = assert
local select = assert( select )
local next = assert( next )
local setmetatable = assert( setmetatable )

-- sentinel values for the key tree, nil keys, and nan keys
local KEYS, NIL, NAN = {}, {}, {}


local M = {}
local M_meta = {
  __index = M
}


function M.new()
  return setmetatable( { [ KEYS ] = {} }, M_meta )
end
setmetatable( M, { __call = M.new } )


function M.clear( t )
  for k in next, t do
    t[ k ] = nil
  end
  return t
end


-- local helper function to map a vararg of keys to the real key
local function get_key( key, ... )
  for i = 1, select( '#', ... ) do
    if key == nil then break end
    local e = select( i, ... )
    if e == nil then
      e = NIL
    elseif e ~= e then -- can only happen for NaNs
      e = NAN
    end
    key = key[ e ]
  end
  return key
end


function M.get( t, ... )
  local key = get_key( t[ KEYS ], ... )
  if key ~= nil then
    return t[ key ]
  end
  return nil
end


-- local helper function for both put variants below
local function put( t, idx, val, n, ... )
  for i = 1, n do
    local e = select( i, ... )
    if e == nil then
      e = NIL
    elseif e ~= e then -- can only happen for NaNs
      e = NAN
    end
    local nextidx = idx[ e ]
    if not nextidx then
      nextidx = {}
      idx[ e ] = nextidx
    end
    idx = nextidx
  end
  t[ idx ] = val
end


-- returns true if tab can be removed from the parent table
local function del( t, idx, n, ... )
  if n > 0 then
    local e = ...
    if e == nil then
      e = NIL
    elseif e ~= e then -- can only happen for NaNs
      e = NAN
    end
    local nextidx = idx[ e ]
    if nextidx and del( t, nextidx, n-1, select( 2, ... ) ) then
      idx[ e ] = nil
      return t[ idx ] == nil and next( idx ) == nil
    end
    return false
  else
    t[ idx ] = nil
    return next( idx ) == nil
  end
end


function M.put( t, ... )
  local n, keys, val = select( '#', ... ), t[ KEYS ], nil
  if n > 0 then
    val = select( n, ... )
    n = n - 1
  end
  if val == nil then
    if keys ~= nil then
      del( t, keys, n, ... )
    end
  else
    if keys == nil then
      keys = {}
      t[ KEYS ] = keys
    end
    put( t, keys, val, n, ... )
  end
  return t
end


-- same as M.put, but value comes first not last
function M.putv( t, val, ... )
  local keys = t[ KEYS ]
  if val == nil then
    if keys ~= nil then
      del( t, keys, select( '#', ... ), ... )
    end
  else
    if keys == nil then
      keys = {}
      t[ KEYS ] = keys
    end
    put( t, keys, val, select( '#', ... ), ... )
  end
  return t
end


-- iteration is only available with coroutine support
if coroutine ~= nil then
  local unpack = assert( unpack or table.unpack )
  local pairs = assert( pairs )
  local ipairs = assert( ipairs )
  local co_yield = assert( coroutine.yield )
  local co_wrap = assert( coroutine.wrap )


  -- internal iterator function
  local function iterate( iter, t, key, keystack, n )
    if t[ key ] ~= nil then
      keystack[ n+1 ] = t[ key ]
      co_yield( unpack( keystack, 1, n+1 ) )
    end
    for k,v in iter( key ) do
      if k == NIL then
        k = nil
      elseif k == NAN then
        k = 0/0
      end
      keystack[ n+1 ] = k
      iterate( iter, t, v, keystack, n+1 )
    end
    return nil
  end


  -- iterator similar to pairs, but since we have multiple keys ...
  function M.tuples( t, ... )
    local vals, n = { true, ... }, select( '#', ... )+1
    return co_wrap( function()
        local key = get_key( t[ KEYS ], unpack( vals, 2, n ) )
        if key ~= nil then
          return iterate( pairs, t, key, vals, n )
        end
      end )
  end


  function M.ituples( t, ... )
    local vals, n = { ... }, select( '#', ... )
    return co_wrap( function()
        local key = get_key( t[ KEYS ], unpack( vals, 1, n ) )
        if key ~= nil then
          return iterate( ipairs, t, key, vals, n )
        end
      end )
  end


  -- Lua 5.2 metamethods for iteration
  M_meta.__pairs = M.tuples
  M_meta.__ipairs = M.ituples
end


-- return module table
return M

