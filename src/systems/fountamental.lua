-- src/systems/fountamental.lua
-- Fundamental root finder without ezgcd (multiplicative rational GCD over just intonation approximations)

local M = {}

-- Just-intonation-like rational approximations for semitone steps 0..11.
local rat_table = {
  [0] = {1,1},
  [1] = {17,16},
  [2] = {9,8},
  [3] = {6,5},
  [4] = {5,4},
  [5] = {4,3},
  [6] = {17,12},
  [7] = {3,2},
  [8] = {8,5},
  [9] = {5,3},
  [10] = {16,9},
  [11] = {15,8},
}

-- Factor a positive integer into prime exponents
local function factor_int(n)
  local exps = {}
  local function bump(p,e) exps[p] = (exps[p] or 0) + e end
  local function pull(p)
    local c=0
    while n % p == 0 do
      c = c + 1
      n = math.floor(n / p)
    end
    if c>0 then bump(p,c) end
  end
  pull(2); pull(3); pull(5); pull(7); pull(11)
  if n~=1 then bump(n,1) end
  return exps
end

-- Build exponent map for a rational num/den
local function rat_exp_map(num,den)
  local mnum=factor_int(math.abs(num))
  local mden=factor_int(math.abs(den))
  local m={}
  for p,e in pairs(mnum) do m[p]=(m[p] or 0)+e end
  for p,e in pairs(mden) do m[p]=(m[p] or 0)-e end
  return m
end

-- Multiplicative GCD across a list of rationals
local function rat_mgcd(rats)
  local maps={}
  for i=1,#rats do maps[i]=rat_exp_map(rats[i][1],rats[i][2]) end
  local primes={}
  for _,m in ipairs(maps) do for p,_ in pairs(m) do primes[p]=true end end
  local minexp={}
  for p,_ in pairs(primes) do minexp[p]=math.huge end
  for _,m in ipairs(maps) do
    for p,_ in pairs(primes) do
      local e=m[p] or 0
      if e<minexp[p] then minexp[p]=e end
    end
  end
  local num,den=1,1
  for p,e in pairs(minexp) do
    if e>0 then for _=1,e do num=num*p end
    elseif e<0 then for _=1,-e do den=den*p end
    end
  end
  return num/den
end

-- Normalize MIDI notes to semitone classes mod 12
local function classes12(notes)
  local c={}
  for i=1,#notes do c[i]=notes[i]%12 end
  return c
end

-- Round to nearest integer
local function round(x) return math.floor(x+0.5) end

-- Public API: compute fundamental from MIDI note list with audibility guard
function M.G_noez_from_midi(midi_notes)
  if #midi_notes==0 then
    return {y=1,chord={},fundamental=nil,has_fundamental=false}
  end

  -- normalize relative to bass
  local marg=classes12(midi_notes)
  local minmarg=marg[1]
  for i=1,#marg do marg[i]=(marg[i]-minmarg)%12 end

  -- collect rationals
  local rats={}
  for i=1,#marg do rats[i]=rat_table[marg[i]] end

  -- multiplicative GCD
  local y=rat_mgcd(rats)

  -- rescale y*2^i into [1,2)
  local i=0
  while y*2^i<1 do i=i+1 end

  -- solve for missing fundamental
  local sol=round(12*(math.log(y*2^i)/math.log(2)))
  local fundamental=(sol+minmarg)%12

  -- Guard: reject if fundamental would fall below C0 (MIDI 12)
  local bass_midi = midi_notes[1]
  local octaves_down = math.floor(math.log(1/y)/math.log(2))
  local fundamental_midi = bass_midi - octaves_down*12
  local has_fundamental = fundamental_midi >= 12

  return {
    y=y,
    chord=midi_notes,
    fundamental=has_fundamental and fundamental or nil,
    has_fundamental=has_fundamental
  }
end

return M
