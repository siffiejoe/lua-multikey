-- simple table adaptor for using multiple keys in a lookup table

-- cache some global functions/tables for faster access
local assert = assert
local select = assert( select )
local next = assert( next )
local type = assert( type )
local setmetatable = assert( setmetatable )

-- sentinel values for nil keys or nan keys
local NIL, NAN = {}, {}


local multikey = {}
local multikey_meta = {
  __index = multikey
}


function multikey:new()
  local t = {
    -- every element in _keys is a table that holds sub-keys and
    -- is used as an index into the _values table below
    _keys = {},
    -- holds the actual values indexed by the values from _keys
    _values = {},
  }
  setmetatable( t, multikey_meta )
  return t
end
setmetatable( multikey, { __call = multikey.new } )


function multikey:clear()
  self._keys, self._values = {}, {}
  return self
end


-- local helper function to get an index for the _values table
local function get_index( self, ... )
  local key = self._keys
  for i = 1, select( '#', ... ) do
    local e = select( i, ... )
    if e == nil then
      e = NIL
    elseif e ~= e then -- can only happen for NaNs
      e = NAN
    end
    key = key[ e ]
    if key == nil then return nil end
  end
  return key
end


function multikey:get( ... )
  local key = get_index( self, ... )
  if key ~= nil then
    return self._values[ key ]
  end
  return nil
end


-- local helper function for both put variants below
-- returns true if tab can be removed from the parent table
local function put( values, tab, val, n_keys, ... )
  if n_keys > 0 then
    local key = ...
    if key == nil then
      key = NIL
    elseif key ~= key then -- can only happen for NaNs
      key = NAN
    end
    local nextt = tab[ key ]
    if val ~= nil and nextt == nil then
      nextt = {}
      tab[ key ] = nextt
    end
    if nextt and put( values, nextt, val, n_keys-1, select( 2, ... ) ) then
      -- nextt is empty and doesn't reference a value, so remove it ...
      tab[ key ] = nil
      return values[ tab ] == nil and next( tab ) == nil
    end
    return false
  else
    values[ tab ] = val
    return val == nil and next( tab ) == nil
  end
end


function multikey:put( ... )
  local n = select( '#', ... )
  local val = nil
  if n > 0 then
    val = select( n, ... )
    n = n - 1
  end
  put( self._values, self._keys, val, n, ... )
  return self
end


-- same as multikey:put, but value comes first not last
function multikey:putv( val, ... )
  put( self._values, self._keys, val, select( '#', ... ), ... )
  return self
end


-- iteration is only available with coroutine support
if coroutine ~= nil then
  local unpack = assert( unpack or table.unpack )
  local pairs = assert( pairs )
  local ipairs = assert( ipairs )
  local co_yield = assert( coroutine.yield )
  local co_wrap = assert( coroutine.wrap )
  local iterate -- forward declaration for internal iterator function

  local function pack( ... )
    return { ... }, select( '#', ... )
  end

  -- iterator similar to pairs, but since we have multiple keys...
  function multikey:tuples( ... )
    local t, n = pack( true, ... )
    return co_wrap( function()
        local key = get_index( self, unpack( t, 2, n ) )
        if key ~= nil then
          return iterate( pairs, self, key, t, n )
        end
      end )
  end

  function multikey:ituples( ... )
    local t, n = pack( ... )
    return co_wrap( function()
        local key = get_index( self, unpack( t, 1, n ) )
        if key ~= nil then
          return iterate( ipairs, self, key, t, n )
        end
      end )
  end


  -- internal iterator function
  function iterate( iter, obj, key, keystack, n )
    if obj._values[ key ] ~= nil then
      keystack[ n+1 ] = obj._values[ key ]
      co_yield( unpack( keystack, 1, n+1 ) )
    end
    for k,v in iter( key ) do
      local myk = k
      if myk == NIL then
        myk = nil
      elseif myk == NAN then
        myk = 0/0
      end
      keystack[ n+1 ] = myk
      iterate( iter, obj, v, keystack, n+1 )
    end
    return nil
  end

  -- new Lua 5.2 metamethods for iteration
  multikey_meta.__pairs = multikey.tuples
  multikey_meta.__ipairs = multikey.ituples
end

-- return module table
return multikey

