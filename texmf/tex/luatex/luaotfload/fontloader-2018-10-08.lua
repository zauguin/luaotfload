--[[info-----------------------------------------------------------------------
  Luaotfload fontloader package
  build 2018-10-08 20:14:20 by fischer@troubleshooting-tex.de
-------------------------------------------------------------------------------

  © 2018 PRAGMA ADE / ConTeXt Development Team

  The code in this file is provided under the GPL v2.0 license. See the
  file COPYING in the Luaotfload repository for details.

  Report bugs to github.com/lualatex/luaotfload

  This file has been assembled from components taken from Context. See
  the Luaotfload documentation for details:

      $ texdoc luaotfload
      $ man 1 luaotfload-tool
      $ man 5 luaotfload.conf

  Included files:

    · fontloader-data-con.lua
    · fontloader-basics-nod.lua
    · fontloader-font-ini.lua
    · fontloader-fonts-mis.lua
    · fontloader-font-con.lua
    · fontloader-fonts-enc.lua
    · fontloader-font-cid.lua
    · fontloader-font-map.lua
    · fontloader-font-vfc.lua
    · fontloader-font-otr.lua
    · fontloader-font-oti.lua
    · fontloader-font-ott.lua
    · fontloader-font-cff.lua
    · fontloader-font-ttf.lua
    · fontloader-font-dsp.lua
    · fontloader-font-oup.lua
    · fontloader-font-otl.lua
    · fontloader-font-oto.lua
    · fontloader-font-otj.lua
    · fontloader-font-ota.lua
    · fontloader-font-ots.lua
    · fontloader-font-osd.lua
    · fontloader-font-ocl.lua
    · fontloader-font-otc.lua
    · fontloader-font-onr.lua
    · fontloader-font-one.lua
    · fontloader-font-afk.lua
    · fontloader-font-tfm.lua
    · fontloader-font-lua.lua
    · fontloader-font-def.lua
    · fontloader-fonts-def.lua
    · fontloader-fonts-ext.lua
    · fontloader-font-imp-tex.lua
    · fontloader-font-imp-ligatures.lua
    · fontloader-font-imp-italics.lua
    · fontloader-font-imp-effects.lua
    · fontloader-fonts-lig.lua
    · fontloader-fonts-gbn.lua

--info]]-----------------------------------------------------------------------


do  --- [luaotfload, fontloader-2018-10-08.lua scope for “data-con” d8982c834ed9acc6193eee23067b9d5d] ---

if not modules then modules={} end modules ['data-con']={
  version=1.100,
  comment="companion to luat-lib.mkiv",
  author="Hans Hagen, PRAGMA-ADE, Hasselt NL",
  copyright="PRAGMA ADE / ConTeXt Development Team",
  license="see context related readme files"
}
local format,lower,gsub=string.format,string.lower,string.gsub
local trace_cache=false trackers.register("resolvers.cache",function(v) trace_cache=v end)
local trace_containers=false trackers.register("resolvers.containers",function(v) trace_containers=v end)
local trace_storage=false trackers.register("resolvers.storage",function(v) trace_storage=v end)
containers=containers or {}
local containers=containers
containers.usecache=true
local report_containers=logs.reporter("resolvers","containers")
local allocated={}
local mt={
  __index=function(t,k)
    if k=="writable" then
      local writable=caches.getwritablepath(t.category,t.subcategory) or { "." }
      t.writable=writable
      return writable
    elseif k=="readables" then
      local readables=caches.getreadablepaths(t.category,t.subcategory) or { "." }
      t.readables=readables
      return readables
    end
  end,
  __storage__=true
}
function containers.define(category,subcategory,version,enabled)
  if category and subcategory then
    local c=allocated[category]
    if not c then
      c={}
      allocated[category]=c
    end
    local s=c[subcategory]
    if not s then
      s={
        category=category,
        subcategory=subcategory,
        storage={},
        enabled=enabled,
        version=version or math.pi,
        trace=false,
      }
      setmetatable(s,mt)
      c[subcategory]=s
    end
    return s
  end
end
function containers.is_usable(container,name)
  return container.enabled and caches and caches.is_writable(container.writable,name)
end
function containers.is_valid(container,name)
  if name and name~="" then
    local storage=container.storage[name]
    return storage and storage.cache_version==container.version
  else
    return false
  end
end
function containers.read(container,name)
  local storage=container.storage
  local stored=storage[name]
  if not stored and container.enabled and caches and containers.usecache then
    stored=caches.loaddata(container.readables,name,container.writable)
    if stored and stored.cache_version==container.version then
      if trace_cache or trace_containers then
        report_containers("action %a, category %a, name %a","load",container.subcategory,name)
      end
    else
      stored=nil
    end
    storage[name]=stored
  elseif stored then
    if trace_cache or trace_containers then
      report_containers("action %a, category %a, name %a","reuse",container.subcategory,name)
    end
  end
  return stored
end
function containers.write(container,name,data)
  if data then
    data.cache_version=container.version
    if container.enabled and caches then
      local unique,shared=data.unique,data.shared
      data.unique,data.shared=nil,nil
      caches.savedata(container.writable,name,data)
      if trace_cache or trace_containers then
        report_containers("action %a, category %a, name %a","save",container.subcategory,name)
      end
      data.unique,data.shared=unique,shared
    end
    if trace_cache or trace_containers then
      report_containers("action %a, category %a, name %a","store",container.subcategory,name)
    end
    container.storage[name]=data
  end
  return data
end
function containers.content(container,name)
  return container.storage[name]
end
function containers.cleanname(name)
  return (gsub(lower(name),"[^%w\128-\255]+","-")) 
end

end --- [luaotfload, fontloader-2018-10-08.lua scope for “data-con”] ---


do  --- [luaotfload, fontloader-2018-10-08.lua scope for “basics-nod” 78f56219685f3145b9393c2b688aad94] ---

if not modules then modules={} end modules ['luatex-fonts-nod']={
  version=1.001,
  comment="companion to luatex-fonts.lua",
  author="Hans Hagen, PRAGMA-ADE, Hasselt NL",
  copyright="PRAGMA ADE / ConTeXt Development Team",
  license="see context related readme files"
}
if context then
  os.exit()
end
if tex.attribute[0]~=0 then
  texio.write_nl("log","!")
  texio.write_nl("log","! Attribute 0 is reserved for ConTeXt's font feature management and has to be")
  texio.write_nl("log","! set to zero. Also, some attributes in the range 1-255 are used for special")
  texio.write_nl("log","! purposes so setting them at the TeX end might break the font handler.")
  texio.write_nl("log","!")
  tex.attribute[0]=0 
end
attributes=attributes or {}
attributes.unsetvalue=-0x7FFFFFFF
local numbers,last={},127
attributes.private=attributes.private or function(name)
  local number=numbers[name]
  if not number then
    if last<255 then
      last=last+1
    end
    number=last
    numbers[name]=number
  end
  return number
end
nodes={}
nodes.handlers={}
local nodecodes={}
local glyphcodes=node.subtypes("glyph")
local disccodes=node.subtypes("disc")
for k,v in next,node.types() do
  v=string.gsub(v,"_","")
  nodecodes[k]=v
  nodecodes[v]=k
end
for k,v in next,glyphcodes do
  glyphcodes[v]=k
end
for k,v in next,glyphcodes do
  disccodes[v]=k
end
nodes.nodecodes=nodecodes
nodes.glyphcodes=glyphcodes
nodes.disccodes=disccodes
local flush_node=node.flush_node
local remove_node=node.remove
local traverse_id=node.traverse_id
nodes.handlers.protectglyphs=node.protect_glyphs  
nodes.handlers.unprotectglyphs=node.unprotect_glyphs 
local math_code=nodecodes.math
local end_of_math=node.end_of_math
function node.end_of_math(n)
  if n.id==math_code and n.subtype==1 then
    return n
  else
    return end_of_math(n)
  end
end
function nodes.remove(head,current,free_too)
  local t=current
  head,current=remove_node(head,current)
  if t then
    if free_too then
      flush_node(t)
      t=nil
    else
      t.next,t.prev=nil,nil
    end
  end
  return head,current,t
end
function nodes.delete(head,current)
  return nodes.remove(head,current,true)
end
local getfield=node.getfield
local setfield=node.setfield
nodes.getfield=getfield
nodes.setfield=setfield
nodes.getattr=getfield
nodes.setattr=setfield
nodes.tostring=node.tostring or tostring
nodes.copy=node.copy
nodes.copy_node=node.copy
nodes.copy_list=node.copy_list
nodes.delete=node.delete
nodes.dimensions=node.dimensions
nodes.end_of_math=node.end_of_math
nodes.flush_list=node.flush_list
nodes.flush_node=node.flush_node
nodes.flush=node.flush_node
nodes.free=node.free
nodes.insert_after=node.insert_after
nodes.insert_before=node.insert_before
nodes.hpack=node.hpack
nodes.new=node.new
nodes.tail=node.tail
nodes.traverse=node.traverse
nodes.traverse_id=node.traverse_id
nodes.slide=node.slide
nodes.vpack=node.vpack
nodes.first_glyph=node.first_glyph
nodes.has_glyph=node.has_glyph or node.first_glyph
nodes.current_attr=node.current_attr
nodes.has_field=node.has_field
nodes.last_node=node.last_node
nodes.usedlist=node.usedlist
nodes.protrusion_skippable=node.protrusion_skippable
nodes.write=node.write
nodes.has_attribute=node.has_attribute
nodes.set_attribute=node.set_attribute
nodes.unset_attribute=node.unset_attribute
nodes.protect_glyphs=node.protect_glyphs
nodes.unprotect_glyphs=node.unprotect_glyphs
nodes.mlist_to_hlist=node.mlist_to_hlist
local direct=node.direct
local nuts={}
nodes.nuts=nuts
local tonode=direct.tonode
local tonut=direct.todirect
nodes.tonode=tonode
nodes.tonut=tonut
nuts.tonode=tonode
nuts.tonut=tonut
local getfield=direct.getfield
local setfield=direct.setfield
nuts.getfield=getfield
nuts.setfield=setfield
nuts.getnext=direct.getnext
nuts.setnext=direct.setnext
nuts.getprev=direct.getprev
nuts.setprev=direct.setprev
nuts.getboth=direct.getboth
nuts.setboth=direct.setboth
nuts.getid=direct.getid
nuts.getattr=direct.get_attribute or direct.has_attribute or getfield
nuts.setattr=setfield
nuts.getfont=direct.getfont
nuts.setfont=direct.setfont
nuts.getsubtype=direct.getsubtype
nuts.setsubtype=direct.setsubtype
nuts.getchar=direct.getchar
nuts.setchar=direct.setchar
nuts.getdisc=direct.getdisc
nuts.setdisc=direct.setdisc
nuts.setlink=direct.setlink
nuts.setsplit=direct.setsplit
nuts.getlist=direct.getlist
nuts.setlist=direct.setlist
nuts.getoffsets=direct.getoffsets or
  function(n)
    return getfield(n,"xoffset"),getfield(n,"yoffset")
  end
nuts.setoffsets=direct.setoffsets or
  function(n,x,y)
    if x then setfield(n,"xoffset",x) end
    if y then setfield(n,"xoffset",y) end
  end
nuts.getleader=direct.getleader   or function(n)  return getfield(n,"leader")    end
nuts.setleader=direct.setleader   or function(n,l)    setfield(n,"leader",l)   end
nuts.getcomponents=direct.getcomponents or function(n)  return getfield(n,"components")  end
nuts.setcomponents=direct.setcomponents or function(n,c)    setfield(n,"components",c) end
nuts.getkern=direct.getkern    or function(n)  return getfield(n,"kern")     end
nuts.setkern=direct.setkern    or function(n,k)    setfield(n,"kern",k)    end
nuts.getdir=direct.getdir    or function(n)  return getfield(n,"dir")     end
nuts.setdir=direct.setdir    or function(n,d)    setfield(n,"dir",d)    end
nuts.getwidth=direct.getwidth   or function(n)  return getfield(n,"width")    end
nuts.setwidth=direct.setwidth   or function(n,w) return setfield(n,"width",w)   end
nuts.getheight=direct.getheight   or function(n)  return getfield(n,"height")    end
nuts.setheight=direct.setheight   or function(n,h) return setfield(n,"height",h)   end
nuts.getdepth=direct.getdepth   or function(n)  return getfield(n,"depth")    end
nuts.setdepth=direct.setdepth   or function(n,d) return setfield(n,"depth",d)   end
if not direct.is_glyph then
  local getchar=direct.getchar
  local getid=direct.getid
  local getfont=direct.getfont
  local glyph_code=nodes.nodecodes.glyph
  function direct.is_glyph(n,f)
    local id=getid(n)
    if id==glyph_code then
      if f and getfont(n)==f then
        return getchar(n)
      else
        return false
      end
    else
      return nil,id
    end
  end
  function direct.is_char(n,f)
    local id=getid(n)
    if id==glyph_code then
      if getsubtype(n)>=256 then
        return false
      elseif f and getfont(n)==f then
        return getchar(n)
      else
        return false
      end
    else
      return nil,id
    end
  end
end
nuts.ischar=direct.is_char
nuts.is_char=direct.is_char
nuts.isglyph=direct.is_glyph
nuts.is_glyph=direct.is_glyph
nuts.insert_before=direct.insert_before
nuts.insert_after=direct.insert_after
nuts.delete=direct.delete
nuts.copy=direct.copy
nuts.copy_node=direct.copy
nuts.copy_list=direct.copy_list
nuts.tail=direct.tail
nuts.flush_list=direct.flush_list
nuts.flush_node=direct.flush_node
nuts.flush=direct.flush
nuts.free=direct.free
nuts.remove=direct.remove
nuts.is_node=direct.is_node
nuts.end_of_math=direct.end_of_math
nuts.traverse=direct.traverse
nuts.traverse_id=direct.traverse_id
nuts.traverse_char=direct.traverse_char
nuts.traverse_glyph=direct.traverse_glyph
nuts.ligaturing=direct.ligaturing
nuts.kerning=direct.kerning
nuts.new=direct.new
nuts.getprop=nuts.getattr
nuts.setprop=nuts.setattr
local propertydata=direct.get_properties_table()
nodes.properties={ data=propertydata }
direct.set_properties_mode(true,true)   
function direct.set_properties_mode() end 
nuts.getprop=function(n,k)
  local p=propertydata[n]
  if p then
    return p[k]
  end
end
nuts.setprop=function(n,k,v)
  if v then
    local p=propertydata[n]
    if p then
      p[k]=v
    else
      propertydata[n]={ [k]=v }
    end
  end
end
nodes.setprop=nodes.setproperty
nodes.getprop=nodes.getproperty
local setprev=nuts.setprev
local setnext=nuts.setnext
local getnext=nuts.getnext
local setlink=nuts.setlink
local getfield=nuts.getfield
local setfield=nuts.setfield
local getcomponents=nuts.getcomponents
local setcomponents=nuts.setcomponents
local find_tail=nuts.tail
local flush_list=nuts.flush_list
local flush_node=nuts.flush_node
local traverse_id=nuts.traverse_id
local copy_node=nuts.copy_node
local glyph_code=nodes.nodecodes.glyph
function nuts.set_components(target,start,stop)
  local head=getcomponents(target)
  if head then
    flush_list(head)
    head=nil
  end
  if start then
    setprev(start)
  else
    return nil
  end
  if stop then
    setnext(stop)
  end
  local tail=nil
  while start do
    local c=getcomponents(start)
    local n=getnext(start)
    if c then
      if head then
        setlink(tail,c)
      else
        head=c
      end
      tail=find_tail(c)
      setcomponents(start)
      flush_node(start)
    else
      if head then
        setlink(tail,start)
      else
        head=start
      end
      tail=start
    end
    start=n
  end
  setcomponents(target,head)
  return head
end
nuts.get_components=nuts.getcomponents
function nuts.take_components(target)
  local c=getcomponents(target)
  setcomponents(target)
  return c
end
function nuts.count_components(n,marks)
  local components=getcomponents(n)
  if components then
    if marks then
      local i=0
      for g in traverse_id(glyph_code,components) do
        if not marks[getchar(g)] then
          i=i+1
        end
      end
      return i
    else
      return count(glyph_code,components)
    end
  else
    return 0
  end
end
function nuts.copy_no_components(g,copyinjection)
  local components=getcomponents(g)
  if components then
    setcomponents(g)
    local n=copy_node(g)
    if copyinjection then
      copyinjection(n,g)
    end
    setcomponents(g,components)
    return n
  else
    local n=copy_node(g)
    if copyinjection then
      copyinjection(n,g)
    end
    return n
  end
end
function nuts.copy_only_glyphs(current)
  local head=nil
  local previous=nil
  for n in traverse_id(glyph_code,current) do
    n=copy_node(n)
    if head then
      setlink(previous,n)
    else
      head=n
    end
    previous=n
  end
  return head
end
nuts.uses_font=direct.uses_font
if not nuts.uses_font then
  local getdisc=nuts.getdisc
  local getfont=nuts.getfont
  function nuts.uses_font(n,font)
    local pre,post,replace=getdisc(n)
    if pre then
      for n in traverse_id(glyph_code,pre) do
        if getfont(n)==font then
          return true
        end
      end
    end
    if post then
      for n in traverse_id(glyph_code,post) do
        if getfont(n)==font then
          return true
        end
      end
    end
    if replace then
      for n in traverse_id(glyph_code,replace) do
        if getfont(n)==font then
          return true
        end
      end
    end
    return false
  end
end
do
  local dummy=tonut(node.new("glyph"))
  nuts.traversers={
    glyph=nuts.traverse_id(nodecodes.glyph,dummy),
    glue=nuts.traverse_id(nodecodes.glue,dummy),
    disc=nuts.traverse_id(nodecodes.disc,dummy),
    boundary=nuts.traverse_id(nodecodes.boundary,dummy),
    char=nuts.traverse_char(dummy),
    node=nuts.traverse(dummy),
  }
end

end --- [luaotfload, fontloader-2018-10-08.lua scope for “basics-nod”] ---


do  --- [luaotfload, fontloader-2018-10-08.lua scope for “font-ini” dd3ff5febc73c79b23e16d713a1282fb] ---

if not modules then modules={} end modules ['font-ini']={
  version=1.001,
  comment="companion to font-ini.mkiv",
  author="Hans Hagen, PRAGMA-ADE, Hasselt NL",
  copyright="PRAGMA ADE / ConTeXt Development Team",
  license="see context related readme files"
}
local allocate=utilities.storage.allocate
local sortedhash=table.sortedhash
fonts=fonts or {}
local fonts=fonts
local identifiers=allocate()
fonts.hashes=fonts.hashes   or { identifiers=identifiers }
fonts.tables=fonts.tables   or {}
fonts.helpers=fonts.helpers  or {}
fonts.tracers=fonts.tracers  or {} 
fonts.specifiers=fonts.specifiers or {} 
fonts.analyzers={} 
fonts.readers={}
fonts.definers={ methods={} }
fonts.loggers={ register=function() end }
if context then
  font.originaleach=font.each
  function font.each()
    return sortedhash(identifiers)
  end
  fontloader=nil
end
fonts.privateoffsets={
  textbase=0xF0000,
  textextrabase=0xFD000,
  mathextrabase=0xFE000,
  mathbase=0xFF000,
  keepnames=false,
}

end --- [luaotfload, fontloader-2018-10-08.lua scope for “font-ini”] ---


do  --- [luaotfload, fontloader-2018-10-08.lua scope for “fonts-mis” 17e967c9ec4d001deefd43ddf25e98f7] ---

if not modules then modules={} end modules ['luatex-font-mis']={
  version=1.001,
  comment="companion to luatex-*.tex",
  author="Hans Hagen, PRAGMA-ADE, Hasselt NL",
  copyright="PRAGMA ADE / ConTeXt Development Team",
  license="see context related readme files"
}
if context then
  os.exit()
end
local currentfont=font.current
local hashes=fonts.hashes
local identifiers=hashes.identifiers or {}
local marks=hashes.marks    or {}
hashes.identifiers=identifiers
hashes.marks=marks
table.setmetatableindex(marks,function(t,k)
  if k==true then
    return marks[currentfont()]
  else
    local resources=identifiers[k].resources or {}
    local marks=resources.marks or {}
    t[k]=marks
    return marks
  end
end)
function font.each()
  return table.sortedhash(fonts.hashes.identifiers)
end

end --- [luaotfload, fontloader-2018-10-08.lua scope for “fonts-mis”] ---


do  --- [luaotfload, fontloader-2018-10-08.lua scope for “font-con” eff77b4c54c2d26eacb29de59e94e2f9] ---

if not modules then modules={} end modules ['font-con']={
  version=1.001,
  comment="companion to font-ini.mkiv",
  author="Hans Hagen, PRAGMA-ADE, Hasselt NL",
  copyright="PRAGMA ADE / ConTeXt Development Team",
  license="see context related readme files"
}
local next,tostring,tonumber,rawget=next,tostring,tonumber,rawget
local format,match,lower,gsub,find=string.format,string.match,string.lower,string.gsub,string.find
local sort,insert,concat=table.sort,table.insert,table.concat
local sortedkeys,sortedhash,serialize,fastcopy=table.sortedkeys,table.sortedhash,table.serialize,table.fastcopy
local derivetable=table.derive
local ioflush=io.flush
local round=math.round
local setmetatable,getmetatable,rawget,rawset=setmetatable,getmetatable,rawget,rawset
local trace_defining=false trackers.register("fonts.defining",function(v) trace_defining=v end)
local trace_scaling=false trackers.register("fonts.scaling",function(v) trace_scaling=v end)
local report_defining=logs.reporter("fonts","defining")
local fonts=fonts
local constructors=fonts.constructors or {}
fonts.constructors=constructors
local handlers=fonts.handlers or {} 
fonts.handlers=handlers
local allocate=utilities.storage.allocate
local setmetatableindex=table.setmetatableindex
constructors.dontembed=allocate()
constructors.autocleanup=true
constructors.namemode="fullpath" 
constructors.version=1.01
constructors.cache=containers.define("fonts","constructors",constructors.version,false)
constructors.privateoffset=fonts.privateoffsets.textbase or 0xF0000
constructors.cacheintex=true
local designsizes=allocate()
constructors.designsizes=designsizes
local loadedfonts=allocate()
constructors.loadedfonts=loadedfonts
local factors={
  pt=65536.0,
  bp=65781.8,
}
function constructors.setfactor(f)
  constructors.factor=factors[f or 'pt'] or factors.pt
end
constructors.setfactor()
function constructors.scaled(scaledpoints,designsize) 
  if scaledpoints<0 then
    local factor=constructors.factor
    if designsize then
      if designsize>factor then 
        return (- scaledpoints/1000)*designsize 
      else
        return (- scaledpoints/1000)*designsize*factor
      end
    else
      return (- scaledpoints/1000)*10*factor
    end
  else
    return scaledpoints
  end
end
function constructors.getprivate(tfmdata)
  local properties=tfmdata.properties
  local private=properties.private
  properties.private=private+1
  return private
end
function constructors.setmathparameter(tfmdata,name,value)
  local m=tfmdata.mathparameters
  local c=tfmdata.MathConstants
  if m then
    m[name]=value
  end
  if c and c~=m then
    c[name]=value
  end
end
function constructors.getmathparameter(tfmdata,name)
  local p=tfmdata.mathparameters or tfmdata.MathConstants
  if p then
    return p[name]
  end
end
function constructors.cleanuptable(tfmdata)
  if constructors.autocleanup and tfmdata.properties.virtualized then
    for k,v in next,tfmdata.characters do
      if v.commands then v.commands=nil end
    end
  end
end
function constructors.calculatescale(tfmdata,scaledpoints)
  local parameters=tfmdata.parameters
  if scaledpoints<0 then
    scaledpoints=(- scaledpoints/1000)*(tfmdata.designsize or parameters.designsize) 
  end
  return scaledpoints,scaledpoints/(parameters.units or 1000) 
end
local unscaled={
  ScriptPercentScaleDown=true,
  ScriptScriptPercentScaleDown=true,
  RadicalDegreeBottomRaisePercent=true,
  NoLimitSupFactor=true,
  NoLimitSubFactor=true,
}
function constructors.assignmathparameters(target,original)
  local mathparameters=original.mathparameters
  if mathparameters and next(mathparameters) then
    local targetparameters=target.parameters
    local targetproperties=target.properties
    local targetmathparameters={}
    local factor=targetproperties.math_is_scaled and 1 or targetparameters.factor
    for name,value in next,mathparameters do
      if unscaled[name] then
        targetmathparameters[name]=value
      else
        targetmathparameters[name]=value*factor
      end
    end
    if not targetmathparameters.FractionDelimiterSize then
      targetmathparameters.FractionDelimiterSize=1.01*targetparameters.size
    end
    if not mathparameters.FractionDelimiterDisplayStyleSize then
      targetmathparameters.FractionDelimiterDisplayStyleSize=2.40*targetparameters.size
    end
    target.mathparameters=targetmathparameters
  end
end
function constructors.beforecopyingcharacters(target,original)
end
function constructors.aftercopyingcharacters(target,original)
end
constructors.sharefonts=false
constructors.nofsharedfonts=0
local sharednames={}
function constructors.trytosharefont(target,tfmdata)
  if constructors.sharefonts then 
    local characters=target.characters
    local n=1
    local t={ target.psname }
    local u=sortedkeys(characters)
    for i=1,#u do
      local k=u[i]
      n=n+1;t[n]=k
      n=n+1;t[n]=characters[k].index or k
    end
    local h=md5.HEX(concat(t," "))
    local s=sharednames[h]
    if s then
      if trace_defining then
        report_defining("font %a uses backend resources of font %a",target.fullname,s)
      end
      target.fullname=s
      constructors.nofsharedfonts=constructors.nofsharedfonts+1
      target.properties.sharedwith=s
    else
      sharednames[h]=target.fullname
    end
  end
end
local synonyms={
  exheight="x_height",
  xheight="x_height",
  ex="x_height",
  emwidth="quad",
  em="quad",
  spacestretch="space_stretch",
  stretch="space_stretch",
  spaceshrink="space_shrink",
  shrink="space_shrink",
  extraspace="extra_space",
  xspace="extra_space",
  slantperpoint="slant",
}
function constructors.enhanceparameters(parameters)
  local mt=getmetatable(parameters)
  local getter=function(t,k)
    if not k then
      return nil
    end
    local s=synonyms[k]
    if s then
      return rawget(t,s) or (mt and mt[s]) or nil
    end
    if k=="spacing" then
      return {
        width=t.space,
        stretch=t.space_stretch,
        shrink=t.space_shrink,
        extra=t.extra_space,
      }
    end
    return mt and mt[k] or nil
  end
  local setter=function(t,k,v)
    if not k then
      return 0
    end
    local s=synonyms[k]
    if s then
      rawset(t,s,v)
    elseif k=="spacing" then
      if type(v)=="table" then
        rawset(t,"space",v.width or 0)
        rawset(t,"space_stretch",v.stretch or 0)
        rawset(t,"space_shrink",v.shrink or 0)
        rawset(t,"extra_space",v.extra or 0)
      end
    else
      rawset(t,k,v)
    end
  end
  setmetatable(parameters,{
    __index=getter,
    __newindex=setter,
  })
end
local function mathkerns(v,vdelta)
  local k={}
  for i=1,#v do
    local entry=v[i]
    local height=entry.height
    local kern=entry.kern
    k[i]={
      height=height and vdelta*height or 0,
      kern=kern  and vdelta*kern  or 0,
    }
  end
  return k
end
local psfake=0
local function fixedpsname(psname,fallback)
  local usedname=psname
  if psname and psname~="" then
    if find(psname," ",1,true) then
      usedname=gsub(psname,"[%s]+","-")
    else
    end
  elseif not fallback or fallback=="" then
    psfake=psfake+1
    psname="fakename-"..psfake
  else
    psname=fallback
    usedname=gsub(psname,"[^a-zA-Z0-9]+","-")
  end
  return usedname,psname~=usedname
end
function constructors.scale(tfmdata,specification)
  local target={}
  if tonumber(specification) then
    specification={ size=specification }
  end
  target.specification=specification
  local scaledpoints=specification.size
  local relativeid=specification.relativeid
  local properties=tfmdata.properties   or {}
  local goodies=tfmdata.goodies    or {}
  local resources=tfmdata.resources   or {}
  local descriptions=tfmdata.descriptions  or {} 
  local characters=tfmdata.characters   or {} 
  local changed=tfmdata.changed    or {} 
  local shared=tfmdata.shared     or {}
  local parameters=tfmdata.parameters   or {}
  local mathparameters=tfmdata.mathparameters or {}
  local targetcharacters={}
  local targetdescriptions=derivetable(descriptions)
  local targetparameters=derivetable(parameters)
  local targetproperties=derivetable(properties)
  local targetgoodies=goodies            
  target.characters=targetcharacters
  target.descriptions=targetdescriptions
  target.parameters=targetparameters
  target.properties=targetproperties
  target.goodies=targetgoodies
  target.shared=shared
  target.resources=resources
  target.unscaled=tfmdata
  local mathsize=tonumber(specification.mathsize) or 0
  local textsize=tonumber(specification.textsize) or scaledpoints
  local forcedsize=tonumber(parameters.mathsize  ) or 0 
  local extrafactor=tonumber(specification.factor ) or 1
  if (mathsize==2 or forcedsize==2) and parameters.scriptpercentage then
    scaledpoints=parameters.scriptpercentage*textsize/100
  elseif (mathsize==3 or forcedsize==3) and parameters.scriptscriptpercentage then
    scaledpoints=parameters.scriptscriptpercentage*textsize/100
  elseif forcedsize>1000 then 
    scaledpoints=forcedsize
  else
  end
  targetparameters.mathsize=mathsize  
  targetparameters.textsize=textsize  
  targetparameters.forcedsize=forcedsize 
  targetparameters.extrafactor=extrafactor
  local tounicode=fonts.mappings.tounicode
  local defaultwidth=resources.defaultwidth or 0
  local defaultheight=resources.defaultheight or 0
  local defaultdepth=resources.defaultdepth or 0
  local units=parameters.units or 1000
  targetproperties.language=properties.language or "dflt" 
  targetproperties.script=properties.script  or "dflt" 
  targetproperties.mode=properties.mode   or "base"
  local askedscaledpoints=scaledpoints
  local scaledpoints,delta=constructors.calculatescale(tfmdata,scaledpoints,nil,specification)
  local hdelta=delta
  local vdelta=delta
  target.designsize=parameters.designsize 
  target.units=units
  target.units_per_em=units
  local direction=properties.direction or tfmdata.direction or 0 
  target.direction=direction
  properties.direction=direction
  target.size=scaledpoints
  target.encodingbytes=properties.encodingbytes or 1
  target.embedding=properties.embedding or "subset"
  target.tounicode=1
  target.cidinfo=properties.cidinfo
  target.format=properties.format
  target.cache=constructors.cacheintex and "yes" or "renew"
  local fontname=properties.fontname or tfmdata.fontname
  local fullname=properties.fullname or tfmdata.fullname
  local filename=properties.filename or tfmdata.filename
  local psname=properties.psname  or tfmdata.psname
  local name=properties.name   or tfmdata.name
  local psname,psfixed=fixedpsname(psname,fontname or fullname or file.nameonly(filename))
  target.fontname=fontname
  target.fullname=fullname
  target.filename=filename
  target.psname=psname
  target.name=name
  properties.fontname=fontname
  properties.fullname=fullname
  properties.filename=filename
  properties.psname=psname
  properties.name=name
  local expansion=parameters.expansion
  if expansion then
    target.stretch=expansion.stretch
    target.shrink=expansion.shrink
    target.step=expansion.step
  end
  local slantfactor=parameters.slantfactor or 0
  if slantfactor~=0 then
    target.slant=slantfactor*1000
  else
    target.slant=0
  end
  local extendfactor=parameters.extendfactor or 0
  if extendfactor~=0 and extendfactor~=1 then
    hdelta=hdelta*extendfactor
    target.extend=extendfactor*1000
  else
    target.extend=1000 
  end
  local squeezefactor=parameters.squeezefactor or 0
  if squeezefactor~=0 and squeezefactor~=1 then
    vdelta=vdelta*squeezefactor
    target.squeeze=squeezefactor*1000
  else
    target.squeeze=1000 
  end
  local mode=parameters.mode or 0
  if mode~=0 then
    target.mode=mode
  end
  local width=parameters.width or 0
  if width~=0 then
    target.width=width*delta*1000/655360
  end
  targetparameters.factor=delta
  targetparameters.hfactor=hdelta
  targetparameters.vfactor=vdelta
  targetparameters.size=scaledpoints
  targetparameters.units=units
  targetparameters.scaledpoints=askedscaledpoints
  targetparameters.mode=mode
  targetparameters.width=width
  local isvirtual=properties.virtualized or tfmdata.type=="virtual"
  local hasquality=parameters.expansion or parameters.protrusion
  local hasitalics=properties.hasitalics
  local autoitalicamount=properties.autoitalicamount
  local stackmath=not properties.nostackmath
  local nonames=properties.noglyphnames
  local haskerns=properties.haskerns   or properties.mode=="base" 
  local hasligatures=properties.hasligatures or properties.mode=="base" 
  local realdimensions=properties.realdimensions
  local writingmode=properties.writingmode or "horizontal"
  local identity=properties.identity or "horizontal"
  local vfonts=target.fonts
  if vfonts and #vfonts>0 then
    target.fonts=fastcopy(vfonts) 
  elseif isvirtual then
    target.fonts={ { id=0 } } 
  end
  if changed and not next(changed) then
    changed=false
  end
  target.type=isvirtual and "virtual" or "real"
  target.writingmode=writingmode=="vertical" and "vertical" or "horizontal"
  target.identity=identity=="vertical" and "vertical" or "horizontal"
  target.postprocessors=tfmdata.postprocessors
  local targetslant=(parameters.slant     or parameters[1] or 0)*factors.pt 
  local targetspace=(parameters.space     or parameters[2] or 0)*hdelta
  local targetspace_stretch=(parameters.space_stretch or parameters[3] or 0)*hdelta
  local targetspace_shrink=(parameters.space_shrink or parameters[4] or 0)*hdelta
  local targetx_height=(parameters.x_height   or parameters[5] or 0)*vdelta
  local targetquad=(parameters.quad     or parameters[6] or 0)*hdelta
  local targetextra_space=(parameters.extra_space  or parameters[7] or 0)*hdelta
  targetparameters.slant=targetslant 
  targetparameters.space=targetspace
  targetparameters.space_stretch=targetspace_stretch
  targetparameters.space_shrink=targetspace_shrink
  targetparameters.x_height=targetx_height
  targetparameters.quad=targetquad
  targetparameters.extra_space=targetextra_space
  local ascender=parameters.ascender
  if ascender then
    targetparameters.ascender=delta*ascender
  end
  local descender=parameters.descender
  if descender then
    targetparameters.descender=delta*descender
  end
  constructors.enhanceparameters(targetparameters)
  local protrusionfactor=(targetquad~=0 and 1000/targetquad) or 0
  local scaledwidth=defaultwidth*hdelta
  local scaledheight=defaultheight*vdelta
  local scaleddepth=defaultdepth*vdelta
  local hasmath=(properties.hasmath or next(mathparameters)) and true
  if hasmath then
    constructors.assignmathparameters(target,tfmdata) 
    properties.hasmath=true
    target.nomath=false
    target.MathConstants=target.mathparameters
  else
    properties.hasmath=false
    target.nomath=true
    target.mathparameters=nil 
  end
  if hasmath then
    local mathitalics=properties.mathitalics
    if mathitalics==false then
      if trace_defining then
        report_defining("%s italics %s for font %a, fullname %a, filename %a","math",hasitalics and "ignored" or "disabled",name,fullname,filename)
      end
      hasitalics=false
      autoitalicamount=false
    end
  else
    local textitalics=properties.textitalics
    if textitalics==false then
      if trace_defining then
        report_defining("%s italics %s for font %a, fullname %a, filename %a","text",hasitalics and "ignored" or "disabled",name,fullname,filename)
      end
      hasitalics=false
      autoitalicamount=false
    end
  end
  if trace_defining then
    report_defining("defining tfm, name %a, fullname %a, filename %a, %spsname %a, hscale %a, vscale %a, math %a, italics %a",
      name,fullname,filename,psfixed and "(fixed) " or "",psname,hdelta,vdelta,
      hasmath and "enabled" or "disabled",hasitalics and "enabled" or "disabled")
  end
  constructors.beforecopyingcharacters(target,tfmdata)
  local sharedkerns={}
  for unicode,character in next,characters do
    local chr,description,index
    if changed then
      local c=changed[unicode]
      if c and c~=unicode then
        if c then
          description=descriptions[c] or descriptions[unicode] or character
          character=characters[c] or character
          index=description.index or c
        else
          description=descriptions[unicode] or character
          index=description.index or unicode
        end
      else
        description=descriptions[unicode] or character
        index=description.index or unicode
      end
    else
      description=descriptions[unicode] or character
      index=description.index or unicode
    end
    local width=description.width
    local height=description.height
    local depth=description.depth
    if realdimensions then
      if not height or height==0 then
        local bb=description.boundingbox
        local ht=bb[4]
        if ht~=0 then
          height=ht
        end
        if not depth or depth==0 then
          local dp=-bb[2]
          if dp~=0 then
            depth=dp
          end
        end
      elseif not depth or depth==0 then
        local dp=-description.boundingbox[2]
        if dp~=0 then
          depth=dp
        end
      end
    end
    if width then width=hdelta*width else width=scaledwidth end
    if height then height=vdelta*height else height=scaledheight end
    if depth and depth~=0 then
      depth=delta*depth
      if nonames then
        chr={
          index=index,
          height=height,
          depth=depth,
          width=width,
        }
      else
        chr={
          name=description.name,
          index=index,
          height=height,
          depth=depth,
          width=width,
        }
      end
    else
      if nonames then
        chr={
          index=index,
          height=height,
          width=width,
        }
      else
        chr={
          name=description.name,
          index=index,
          height=height,
          width=width,
        }
      end
    end
    local isunicode=description.unicode
    if isunicode then
      chr.unicode=isunicode
      chr.tounicode=tounicode(isunicode)
    end
    if hasquality then
      local ve=character.expansion_factor
      if ve then
        chr.expansion_factor=ve*1000 
      end
      local vl=character.left_protruding
      if vl then
        chr.left_protruding=protrusionfactor*width*vl
      end
      local vr=character.right_protruding
      if vr then
        chr.right_protruding=protrusionfactor*width*vr
      end
    end
    if hasmath then
      local vn=character.next
      if vn then
        chr.next=vn
      else
        local vv=character.vert_variants
        if vv then
          local t={}
          for i=1,#vv do
            local vvi=vv[i]
            local s=vvi["start"]  or 0
            local e=vvi["end"]   or 0
            local a=vvi["advance"] or 0
            t[i]={ 
              ["start"]=s==0 and 0 or s*vdelta,
              ["end"]=e==0 and 0 or e*vdelta,
              ["advance"]=a==0 and 0 or a*vdelta,
              ["extender"]=vvi["extender"],
              ["glyph"]=vvi["glyph"],
            }
          end
          chr.vert_variants=t
        else
          local hv=character.horiz_variants
          if hv then
            local t={}
            for i=1,#hv do
              local hvi=hv[i]
              local s=hvi["start"]  or 0
              local e=hvi["end"]   or 0
              local a=hvi["advance"] or 0
              t[i]={ 
                ["start"]=s==0 and 0 or s*hdelta,
                ["end"]=e==0 and 0 or e*hdelta,
                ["advance"]=a==0 and 0 or a*hdelta,
                ["extender"]=hvi["extender"],
                ["glyph"]=hvi["glyph"],
              }
            end
            chr.horiz_variants=t
          end
        end
      end
      local vi=character.vert_italic
      if vi and vi~=0 then
        chr.vert_italic=vi*hdelta
      end
      local va=character.accent
      if va then
        chr.top_accent=vdelta*va
      end
      if stackmath then
        local mk=character.mathkerns
        if mk then
          local tr,tl,br,bl=mk.topright,mk.topleft,mk.bottomright,mk.bottomleft
          chr.mathkern={ 
            top_right=tr and mathkerns(tr,vdelta) or nil,
            top_left=tl and mathkerns(tl,vdelta) or nil,
            bottom_right=br and mathkerns(br,vdelta) or nil,
            bottom_left=bl and mathkerns(bl,vdelta) or nil,
          }
        end
      end
      if hasitalics then
        local vi=character.italic
        if vi and vi~=0 then
          chr.italic=vi*hdelta
        end
      end
    elseif autoitalicamount then 
      local vi=description.italic
      if not vi then
        local bb=description.boundingbox
        if bb then
          local vi=bb[3]-description.width+autoitalicamount
          if vi>0 then 
            chr.italic=vi*hdelta
          end
        else
        end
      elseif vi~=0 then
        chr.italic=vi*hdelta
      end
    elseif hasitalics then 
      local vi=character.italic
      if vi and vi~=0 then
        chr.italic=vi*hdelta
      end
    end
    if haskerns then
      local vk=character.kerns
      if vk then
        local s=sharedkerns[vk]
        if not s then
          s={}
          for k,v in next,vk do s[k]=v*hdelta end
          sharedkerns[vk]=s
        end
        chr.kerns=s
      end
    end
    if hasligatures then
      local vl=character.ligatures
      if vl then
        if true then
          chr.ligatures=vl 
        else
          local tt={}
          for i,l in next,vl do
            tt[i]=l
          end
          chr.ligatures=tt
        end
      end
    end
    if isvirtual then
      local vc=character.commands
      if vc then
        local ok=false
        for i=1,#vc do
          local key=vc[i][1]
          if key=="right" or key=="down" or key=="rule" then
            ok=true
            break
          end
        end
        if ok then
          local tt={}
          for i=1,#vc do
            local ivc=vc[i]
            local key=ivc[1]
            if key=="right" then
              tt[i]={ key,ivc[2]*hdelta }
            elseif key=="down" then
              tt[i]={ key,ivc[2]*vdelta }
            elseif key=="rule" then
              tt[i]={ key,ivc[2]*vdelta,ivc[3]*hdelta }
            else 
              tt[i]=ivc 
            end
          end
          chr.commands=tt
        else
          chr.commands=vc
        end
      end
    end
    targetcharacters[unicode]=chr
  end
  properties.setitalics=hasitalics
  constructors.aftercopyingcharacters(target,tfmdata)
  constructors.trytosharefont(target,tfmdata)
  local vfonts=target.fonts
if isvirtual or target.type=="virtual" or properties.virtualized then
    properties.virtualized=true
target.type="virtual"
    if not vfonts or #vfonts==0 then
      target.fonts={ { id=0 } }
    end
  elseif vfonts then
    properties.virtualized=true
    target.type="virtual"
    if #vfonts==0 then
      target.fonts={ { id=0 } }
    end
  end
  return target
end
function constructors.finalize(tfmdata)
  if tfmdata.properties and tfmdata.properties.finalized then
    return
  end
  if not tfmdata.characters then
    return nil
  end
  if not tfmdata.goodies then
    tfmdata.goodies={} 
  end
  local parameters=tfmdata.parameters
  if not parameters then
    return nil
  end
  if not parameters.expansion then
    parameters.expansion={
      stretch=tfmdata.stretch or 0,
      shrink=tfmdata.shrink or 0,
      step=tfmdata.step  or 0,
    }
  end
  if not parameters.size then
    parameters.size=tfmdata.size
  end
  if not parameters.mode then
    parameters.mode=0
  end
  if not parameters.width then
    parameters.width=0
  end
  if not parameters.slantfactor then
    parameters.slantfactor=tfmdata.slant or 0
  end
  if not parameters.extendfactor then
    parameters.extendfactor=tfmdata.extend or 0
  end
  if not parameters.squeezefactor then
    parameters.squeezefactor=tfmdata.squeeze or 0
  end
  local designsize=parameters.designsize
  if designsize then
    parameters.minsize=tfmdata.minsize or designsize
    parameters.maxsize=tfmdata.maxsize or designsize
  else
    designsize=factors.pt*10
    parameters.designsize=designsize
    parameters.minsize=designsize
    parameters.maxsize=designsize
  end
  parameters.minsize=tfmdata.minsize or parameters.designsize
  parameters.maxsize=tfmdata.maxsize or parameters.designsize
  if not parameters.units then
    parameters.units=tfmdata.units or tfmdata.units_per_em or 1000
  end
  if not tfmdata.descriptions then
    local descriptions={} 
    setmetatableindex(descriptions,function(t,k) local v={} t[k]=v return v end)
    tfmdata.descriptions=descriptions
  end
  local properties=tfmdata.properties
  if not properties then
    properties={}
    tfmdata.properties=properties
  end
  if not properties.virtualized then
    properties.virtualized=tfmdata.type=="virtual"
  end
  if not tfmdata.properties then
    tfmdata.properties={
      fontname=tfmdata.fontname,
      filename=tfmdata.filename,
      fullname=tfmdata.fullname,
      name=tfmdata.name,
      psname=tfmdata.psname,
      encodingbytes=tfmdata.encodingbytes or 1,
      embedding=tfmdata.embedding   or "subset",
      tounicode=tfmdata.tounicode   or 1,
      cidinfo=tfmdata.cidinfo    or nil,
      format=tfmdata.format    or "type1",
      direction=tfmdata.direction   or 0,
      writingmode=tfmdata.writingmode  or "horizontal",
      identity=tfmdata.identity   or "horizontal",
    }
  end
  if not tfmdata.resources then
    tfmdata.resources={}
  end
  if not tfmdata.shared then
    tfmdata.shared={}
  end
  if not properties.hasmath then
    properties.hasmath=not tfmdata.nomath
  end
  tfmdata.MathConstants=nil
  tfmdata.postprocessors=nil
  tfmdata.fontname=nil
  tfmdata.filename=nil
  tfmdata.fullname=nil
  tfmdata.name=nil 
  tfmdata.psname=nil
  tfmdata.encodingbytes=nil
  tfmdata.embedding=nil
  tfmdata.tounicode=nil
  tfmdata.cidinfo=nil
  tfmdata.format=nil
  tfmdata.direction=nil
  tfmdata.type=nil
  tfmdata.nomath=nil
  tfmdata.designsize=nil
  tfmdata.size=nil
  tfmdata.stretch=nil
  tfmdata.shrink=nil
  tfmdata.step=nil
  tfmdata.slant=nil
  tfmdata.extend=nil
  tfmdata.squeeze=nil
  tfmdata.mode=nil
  tfmdata.width=nil
  tfmdata.units=nil
  tfmdata.units_per_em=nil
  tfmdata.cache=nil
  properties.finalized=true
  return tfmdata
end
local hashmethods={}
constructors.hashmethods=hashmethods
function constructors.hashfeatures(specification) 
  local features=specification.features
  if features then
    local t,n={},0
    for category,list in sortedhash(features) do
      if next(list) then
        local hasher=hashmethods[category]
        if hasher then
          local hash=hasher(list)
          if hash then
            n=n+1
            t[n]=category..":"..hash
          end
        end
      end
    end
    if n>0 then
      return concat(t," & ")
    end
  end
  return "unknown"
end
hashmethods.normal=function(list)
  local s={}
  local n=0
  for k,v in next,list do
    if not k then
    elseif k=="number" or k=="features" then
    else
      n=n+1
      if type(v)=="table" then
        local t={}
        local m=0
        for k,v in next,v do
          m=m+1
          t[m]=k..'='..tostring(v)
        end
        s[n]=k..'={'..concat(t,",").."}"
      else
        s[n]=k..'='..tostring(v)
      end
    end
  end
  if n>0 then
    sort(s)
    return concat(s,"+")
  end
end
function constructors.hashinstance(specification,force)
  local hash,size,fallbacks=specification.hash,specification.size,specification.fallbacks
  if force or not hash then
    hash=constructors.hashfeatures(specification)
    specification.hash=hash
  end
  if size<1000 and designsizes[hash] then
    size=round(constructors.scaled(size,designsizes[hash]))
  else
    size=round(size)
  end
  specification.size=size
  if fallbacks then
    return hash..' @ '..size..' @ '..fallbacks
  else
    return hash..' @ '..size
  end
end
function constructors.setname(tfmdata,specification) 
  if constructors.namemode=="specification" then
    local specname=specification.specification
    if specname then
      tfmdata.properties.name=specname
      if trace_defining then
        report_otf("overloaded fontname %a",specname)
      end
    end
  end
end
function constructors.checkedfilename(data)
  local foundfilename=data.foundfilename
  if not foundfilename then
    local askedfilename=data.filename or ""
    if askedfilename~="" then
      askedfilename=resolvers.resolve(askedfilename) 
      foundfilename=resolvers.findbinfile(askedfilename,"") or ""
      if foundfilename=="" then
        report_defining("source file %a is not found",askedfilename)
        foundfilename=resolvers.findbinfile(file.basename(askedfilename),"") or ""
        if foundfilename~="" then
          report_defining("using source file %a due to cache mismatch",foundfilename)
        end
      end
    end
    data.foundfilename=foundfilename
  end
  return foundfilename
end
local formats=allocate()
fonts.formats=formats
setmetatableindex(formats,function(t,k)
  local l=lower(k)
  if rawget(t,k) then
    t[k]=l
    return l
  end
  return rawget(t,file.suffix(l))
end)
do
  local function setindeed(mode,source,target,group,name,position)
    local action=source[mode]
    if not action then
      return
    end
    local t=target[mode]
    if not t then
      report_defining("fatal error in setting feature %a, group %a, mode %a",name,group,mode)
      os.exit()
    elseif position then
      insert(t,position,{ name=name,action=action })
    else
      for i=1,#t do
        local ti=t[i]
        if ti.name==name then
          ti.action=action
          return
        end
      end
      insert(t,{ name=name,action=action })
    end
  end
  local function set(group,name,target,source)
    target=target[group]
    if not target then
      report_defining("fatal target error in setting feature %a, group %a",name,group)
      os.exit()
    end
    local source=source[group]
    if not source then
      report_defining("fatal source error in setting feature %a, group %a",name,group)
      os.exit()
    end
    local position=source.position
    setindeed("node",source,target,group,name,position)
    setindeed("base",source,target,group,name,position)
    setindeed("plug",source,target,group,name,position)
  end
  local function register(where,specification)
    local name=specification.name
    if name and name~="" then
      local default=specification.default
      local description=specification.description
      local initializers=specification.initializers
      local processors=specification.processors
      local manipulators=specification.manipulators
      local modechecker=specification.modechecker
      if default then
        where.defaults[name]=default
      end
      if description and description~="" then
        where.descriptions[name]=description
      end
      if initializers then
        set('initializers',name,where,specification)
      end
      if processors then
        set('processors',name,where,specification)
      end
      if manipulators then
        set('manipulators',name,where,specification)
      end
      if modechecker then
        where.modechecker=modechecker
      end
    end
  end
  constructors.registerfeature=register
  function constructors.getfeatureaction(what,where,mode,name)
    what=handlers[what].features
    if what then
      where=what[where]
      if where then
        mode=where[mode]
        if mode then
          for i=1,#mode do
            local m=mode[i]
            if m.name==name then
              return m.action
            end
          end
        end
      end
    end
  end
  local newfeatures={}
  constructors.newfeatures=newfeatures 
  constructors.features=newfeatures
  local function setnewfeatures(what)
    local handler=handlers[what]
    local features=handler.features
    if not features then
      local tables=handler.tables   
      local statistics=handler.statistics 
      features=allocate {
        defaults={},
        descriptions=tables and tables.features or {},
        used=statistics and statistics.usedfeatures or {},
        initializers={ base={},node={},plug={} },
        processors={ base={},node={},plug={} },
        manipulators={ base={},node={},plug={} },
      }
      features.register=function(specification) return register(features,specification) end
      handler.features=features 
    end
    return features
  end
  setmetatable(newfeatures,{
    __call=function(t,k) local v=t[k] return v end,
    __index=function(t,k) local v=setnewfeatures(k) t[k]=v return v end,
  })
end
do
  local newhandler={}
  constructors.handlers=newhandler 
  constructors.newhandler=newhandler
  local function setnewhandler(what) 
    local handler=handlers[what]
    if not handler then
      handler={}
      handlers[what]=handler
    end
    return handler
  end
  setmetatable(newhandler,{
    __call=function(t,k) local v=t[k] return v end,
    __index=function(t,k) local v=setnewhandler(k) t[k]=v return v end,
  })
end
do
  local newenhancer={}
  constructors.enhancers=newenhancer
  constructors.newenhancer=newenhancer
  local function setnewenhancer(format)
    local handler=handlers[format]
    local enhancers=handler.enhancers
    if not enhancers then
      local actions=allocate() 
      local before=allocate()
      local after=allocate()
      local order=allocate()
      local known={}
      local nofsteps=0
      local patches={ before=before,after=after }
      local trace=false
      local report=logs.reporter("fonts",format.." enhancing")
      trackers.register(format..".loading",function(v) trace=v end)
      local function enhance(name,data,filename,raw)
        local enhancer=actions[name]
        if enhancer then
          if trace then
            report("apply enhancement %a to file %a",name,filename)
            ioflush()
          end
          enhancer(data,filename,raw)
        else
        end
      end
      local function apply(data,filename,raw)
        local basename=file.basename(lower(filename))
        if trace then
          report("%s enhancing file %a","start",filename)
        end
        ioflush() 
        for e=1,nofsteps do
          local enhancer=order[e]
          local b=before[enhancer]
          if b then
            for pattern,action in next,b do
              if find(basename,pattern) then
                action(data,filename,raw)
              end
            end
          end
          enhance(enhancer,data,filename,raw) 
          local a=after[enhancer]
          if a then
            for pattern,action in next,a do
              if find(basename,pattern) then
                action(data,filename,raw)
              end
            end
          end
          ioflush() 
        end
        if trace then
          report("%s enhancing file %a","stop",filename)
        end
        ioflush() 
      end
      local function register(what,action)
        if action then
          if actions[what] then
          else
            nofsteps=nofsteps+1
            order[nofsteps]=what
            known[what]=nofsteps
          end
          actions[what]=action
        else
          report("bad enhancer %a",what)
        end
      end
      local function patch(what,where,pattern,action)
        local pw=patches[what]
        if pw then
          local ww=pw[where]
          if ww then
            ww[pattern]=action
          else
            pw[where]={ [pattern]=action }
            if not known[where] then
              nofsteps=nofsteps+1
              order[nofsteps]=where
              known[where]=nofsteps
            end
          end
        end
      end
      enhancers={
        register=register,
        apply=apply,
        patch=patch,
        report=report,
        patches={
          register=patch,
          report=report,
        },
      }
      handler.enhancers=enhancers
    end
    return enhancers
  end
  setmetatable(newenhancer,{
    __call=function(t,k) local v=t[k] return v end,
    __index=function(t,k) local v=setnewenhancer(k) t[k]=v return v end,
  })
end
function constructors.checkedfeatures(what,features)
  local defaults=handlers[what].features.defaults
  if features and next(features) then
    features=fastcopy(features) 
    for key,value in next,defaults do
      if features[key]==nil then
        features[key]=value
      end
    end
    return features
  else
    return fastcopy(defaults) 
  end
end
function constructors.initializefeatures(what,tfmdata,features,trace,report)
  if features and next(features) then
    local properties=tfmdata.properties or {} 
    local whathandler=handlers[what]
    local whatfeatures=whathandler.features
    local whatmodechecker=whatfeatures.modechecker
    local mode=properties.mode or (whatmodechecker and whatmodechecker(tfmdata,features,features.mode)) or features.mode or "base"
    properties.mode=mode 
    features.mode=mode
    local done={}
    while true do
      local redo=false
      local initializers=whatfeatures.initializers[mode]
      if initializers then
        for i=1,#initializers do
          local step=initializers[i]
          local feature=step.name
          local value=features[feature]
          if not value then
          elseif done[feature] then
          else
            local action=step.action
            if trace then
              report("initializing feature %a to %a for mode %a for font %a",feature,
                value,mode,tfmdata.properties.fullname)
            end
            action(tfmdata,value,features) 
            if mode~=properties.mode or mode~=features.mode then
              if whatmodechecker then
                properties.mode=whatmodechecker(tfmdata,features,properties.mode) 
                features.mode=properties.mode
              end
              if mode~=properties.mode then
                mode=properties.mode
                redo=true
              end
            end
            done[feature]=true
          end
          if redo then
            break
          end
        end
        if not redo then
          break
        end
      else
        break
      end
    end
    properties.mode=mode 
    return true
  else
    return false
  end
end
function constructors.collectprocessors(what,tfmdata,features,trace,report)
  local processes,nofprocesses={},0
  if features and next(features) then
    local properties=tfmdata.properties
    local whathandler=handlers[what]
    local whatfeatures=whathandler.features
    local whatprocessors=whatfeatures.processors
    local mode=properties.mode
    local processors=whatprocessors[mode]
    if processors then
      for i=1,#processors do
        local step=processors[i]
        local feature=step.name
        if features[feature] then
          local action=step.action
          if trace then
            report("installing feature processor %a for mode %a for font %a",feature,mode,tfmdata.properties.fullname)
          end
          if action then
            nofprocesses=nofprocesses+1
            processes[nofprocesses]=action
          end
        end
      end
    elseif trace then
      report("no feature processors for mode %a for font %a",mode,properties.fullname)
    end
  end
  return processes
end
function constructors.applymanipulators(what,tfmdata,features,trace,report)
  if features and next(features) then
    local properties=tfmdata.properties
    local whathandler=handlers[what]
    local whatfeatures=whathandler.features
    local whatmanipulators=whatfeatures.manipulators
    local mode=properties.mode
    local manipulators=whatmanipulators[mode]
    if manipulators then
      for i=1,#manipulators do
        local step=manipulators[i]
        local feature=step.name
        local value=features[feature]
        if value then
          local action=step.action
          if trace then
            report("applying feature manipulator %a for mode %a for font %a",feature,mode,properties.fullname)
          end
          if action then
            action(tfmdata,feature,value)
          end
        end
      end
    end
  end
end
function constructors.addcoreunicodes(unicodes) 
  if not unicodes then
    unicodes={}
  end
  unicodes.space=0x0020
  unicodes.hyphen=0x002D
  unicodes.zwj=0x200D
  unicodes.zwnj=0x200C
  return unicodes
end

end --- [luaotfload, fontloader-2018-10-08.lua scope for “font-con”] ---


do  --- [luaotfload, fontloader-2018-10-08.lua scope for “fonts-enc” 5ff4ca50493d7c4ecea0e15c203099f0] ---

if not modules then modules={} end modules ['luatex-font-enc']={
  version=1.001,
  comment="companion to luatex-*.tex",
  author="Hans Hagen, PRAGMA-ADE, Hasselt NL",
  copyright="PRAGMA ADE / ConTeXt Development Team",
  license="see context related readme files"
}
if context then
  os.exit()
end
local fonts=fonts
local encodings={}
fonts.encodings=encodings
encodings.agl={}
encodings.known={}
setmetatable(encodings.agl,{ __index=function(t,k)
  if k=="unicodes" then
    logs.report("fonts","loading (extended) adobe glyph list")
    local unicodes=dofile(resolvers.findfile("font-age.lua"))
    encodings.agl={ unicodes=unicodes }
    return unicodes
  else
    return nil
  end
end })
encodings.cache=containers.define("fonts","enc",encodings.version,true)
function encodings.load(filename)
  local name=file.removesuffix(filename)
  local data=containers.read(encodings.cache,name)
  if data then
    return data
  end
  local vector,tag,hash,unicodes={},"",{},{}
  local foundname=resolvers.findfile(filename,'enc')
  if foundname and foundname~="" then
    local ok,encoding,size=resolvers.loadbinfile(foundname)
    if ok and encoding then
      encoding=string.gsub(encoding,"%%(.-)\n","")
      local unicoding=encodings.agl.unicodes
      local tag,vec=string.match(encoding,"/(%w+)%s*%[(.*)%]%s*def")
      local i=0
      for ch in string.gmatch(vec,"/([%a%d%.]+)") do
        if ch~=".notdef" then
          vector[i]=ch
          if not hash[ch] then
            hash[ch]=i
          else
          end
          local u=unicoding[ch]
          if u then
            unicodes[u]=i
          end
        end
        i=i+1
      end
    end
  end
  local data={
    name=name,
    tag=tag,
    vector=vector,
    hash=hash,
    unicodes=unicodes
  }
  return containers.write(encodings.cache,name,data)
end

end --- [luaotfload, fontloader-2018-10-08.lua scope for “fonts-enc”] ---


do  --- [luaotfload, fontloader-2018-10-08.lua scope for “font-cid” 22b0367742fb253deef84ef7ccf5e8de] ---

if not modules then modules={} end modules ['font-cid']={
  version=1.001,
  comment="companion to font-ini.mkiv",
  author="Hans Hagen, PRAGMA-ADE, Hasselt NL",
  copyright="PRAGMA ADE / ConTeXt Development Team",
  license="see context related readme files"
}
local format,match,lower=string.format,string.match,string.lower
local tonumber=tonumber
local P,S,R,C,V,lpegmatch=lpeg.P,lpeg.S,lpeg.R,lpeg.C,lpeg.V,lpeg.match
local fonts,logs,trackers=fonts,logs,trackers
local trace_loading=false trackers.register("otf.loading",function(v) trace_loading=v end)
local report_otf=logs.reporter("fonts","otf loading")
local cid={}
fonts.cid=cid
local cidmap={}
local cidmax=10
local number=C(R("09","af","AF")^1)
local space=S(" \n\r\t")
local spaces=space^0
local period=P(".")
local periods=period*period
local name=P("/")*C((1-space)^1)
local unicodes,names={},{} 
local function do_one(a,b)
  unicodes[tonumber(a)]=tonumber(b,16)
end
local function do_range(a,b,c)
  c=tonumber(c,16)
  for i=tonumber(a),tonumber(b) do
    unicodes[i]=c
    c=c+1
  end
end
local function do_name(a,b)
  names[tonumber(a)]=b
end
local grammar=P { "start",
  start=number*spaces*number*V("series"),
  series=(spaces*(V("one")+V("range")+V("named")))^1,
  one=(number*spaces*number)/do_one,
  range=(number*periods*number*spaces*number)/do_range,
  named=(number*spaces*name)/do_name
}
local function loadcidfile(filename)
  local data=io.loaddata(filename)
  if data then
    unicodes,names={},{}
    lpegmatch(grammar,data)
    local supplement,registry,ordering=match(filename,"^(.-)%-(.-)%-()%.(.-)$")
    return {
      supplement=supplement,
      registry=registry,
      ordering=ordering,
      filename=filename,
      unicodes=unicodes,
      names=names,
    }
  end
end
cid.loadfile=loadcidfile 
local template="%s-%s-%s.cidmap"
local function locate(registry,ordering,supplement)
  local filename=format(template,registry,ordering,supplement)
  local hashname=lower(filename)
  local found=cidmap[hashname]
  if not found then
    if trace_loading then
      report_otf("checking cidmap, registry %a, ordering %a, supplement %a, filename %a",registry,ordering,supplement,filename)
    end
    local fullname=resolvers.findfile(filename,'cid') or ""
    if fullname~="" then
      found=loadcidfile(fullname)
      if found then
        if trace_loading then
          report_otf("using cidmap file %a",filename)
        end
        cidmap[hashname]=found
        found.usedname=file.basename(filename)
      end
    end
  end
  return found
end
function cid.getmap(specification)
  if not specification then
    report_otf("invalid cidinfo specification, table expected")
    return
  end
  local registry=specification.registry
  local ordering=specification.ordering
  local supplement=specification.supplement
  local filename=format(registry,ordering,supplement)
  local lowername=lower(filename)
  local found=cidmap[lowername]
  if found then
    return found
  end
  if ordering=="Identity" then
    local found={
      supplement=supplement,
      registry=registry,
      ordering=ordering,
      filename=filename,
      unicodes={},
      names={},
    }
    cidmap[lowername]=found
    return found
  end
  if trace_loading then
    report_otf("cidmap needed, registry %a, ordering %a, supplement %a",registry,ordering,supplement)
  end
  found=locate(registry,ordering,supplement)
  if not found then
    local supnum=tonumber(supplement)
    local cidnum=nil
    if supnum<cidmax then
      for s=supnum+1,cidmax do
        local c=locate(registry,ordering,s)
        if c then
          found,cidnum=c,s
          break
        end
      end
    end
    if not found and supnum>0 then
      for s=supnum-1,0,-1 do
        local c=locate(registry,ordering,s)
        if c then
          found,cidnum=c,s
          break
        end
      end
    end
    registry=lower(registry)
    ordering=lower(ordering)
    if found and cidnum>0 then
      for s=0,cidnum-1 do
        local filename=format(template,registry,ordering,s)
        if not cidmap[filename] then
          cidmap[filename]=found
        end
      end
    end
  end
  return found
end

end --- [luaotfload, fontloader-2018-10-08.lua scope for “font-cid”] ---


do  --- [luaotfload, fontloader-2018-10-08.lua scope for “font-map” f57b80596cf5096c3505c0f3ef4285a8] ---

if not modules then modules={} end modules ['font-map']={
  version=1.001,
  comment="companion to font-ini.mkiv",
  author="Hans Hagen, PRAGMA-ADE, Hasselt NL",
  copyright="PRAGMA ADE / ConTeXt Development Team",
  license="see context related readme files"
}
local tonumber,next,type=tonumber,next,type
local match,format,find,concat,gsub,lower=string.match,string.format,string.find,table.concat,string.gsub,string.lower
local P,R,S,C,Ct,Cc,lpegmatch=lpeg.P,lpeg.R,lpeg.S,lpeg.C,lpeg.Ct,lpeg.Cc,lpeg.match
local formatters=string.formatters
local sortedhash,sortedkeys=table.sortedhash,table.sortedkeys
local rshift=bit32.rshift
local trace_loading=false trackers.register("fonts.loading",function(v) trace_loading=v end)
local trace_mapping=false trackers.register("fonts.mapping",function(v) trace_mapping=v end)
local report_fonts=logs.reporter("fonts","loading")
local force_ligatures=false directives.register("fonts.mapping.forceligatures",function(v) force_ligatures=v end)
local fonts=fonts or {}
local mappings=fonts.mappings or {}
fonts.mappings=mappings
local allocate=utilities.storage.allocate
local hex=R("AF","af","09")
local hexfour=(hex*hex*hex^-2)/function(s) return tonumber(s,16) end
local hexsix=(hex*hex*hex^-4)/function(s) return tonumber(s,16) end
local dec=(R("09")^1)/tonumber
local period=P(".")
local unicode=(P("uni")+P("UNI"))*(hexfour*(period+P(-1))*Cc(false)+Ct(hexfour^1)*Cc(true)) 
local ucode=(P("u")+P("U") )*(hexsix*(period+P(-1))*Cc(false)+Ct(hexsix^1)*Cc(true)) 
local index=P("index")*dec*Cc(false)
local parser=unicode+ucode+index
local parsers={}
local function makenameparser(str)
  if not str or str=="" then
    return parser
  else
    local p=parsers[str]
    if not p then
      p=P(str)*period*dec*Cc(false)
      parsers[str]=p
    end
    return p
  end
end
local f_single=formatters["%04X"]
local f_double=formatters["%04X%04X"]
local function tounicode16(unicode)
  if unicode<0xD7FF or (unicode>0xDFFF and unicode<=0xFFFF) then
    return f_single(unicode)
  else
    unicode=unicode-0x10000
    return f_double(rshift(unicode,10)+0xD800,unicode%1024+0xDC00)
  end
end
local function tounicode16sequence(unicodes)
  local t={}
  for l=1,#unicodes do
    local u=unicodes[l]
    if u<0xD7FF or (u>0xDFFF and u<=0xFFFF) then
      t[l]=f_single(u)
    else
      u=u-0x10000
      t[l]=f_double(rshift(u,10)+0xD800,u%1024+0xDC00)
    end
  end
  return concat(t)
end
local unknown=f_single(0xFFFD)
local hash={}
local conc={}
table.setmetatableindex(hash,function(t,k)
  if type(k)=="table" then
    local n=#k
    for l=1,n do
      conc[l]=hash[k[l]]
    end
    return concat(conc,"",1,n)
  end
  local v
  if k>=0x00E000 and k<=0x00F8FF then
    v=unknown
  elseif k>=0x0F0000 and k<=0x0FFFFF then
    v=unknown
  elseif k>=0x100000 and k<=0x10FFFF then
    v=unknown
  elseif k<0xD7FF or (k>0xDFFF and k<=0xFFFF) then
    v=f_single(k)
  else
    k=k-0x10000
    v=f_double(rshift(k,10)+0xD800,k%1024+0xDC00)
  end
  t[k]=v
  return v
end)
local function tounicode(unicode)
  return hash[unicode]
end
local function fromunicode16(str)
  if #str==4 then
    return tonumber(str,16)
  else
    local l,r=match(str,"(....)(....)")
    return 0x10000+(tonumber(l,16)-0xD800)*0x400+tonumber(r,16)-0xDC00
  end
end
mappings.makenameparser=makenameparser
mappings.tounicode=tounicode
mappings.tounicode16=tounicode16
mappings.tounicode16sequence=tounicode16sequence
mappings.fromunicode16=fromunicode16
local ligseparator=P("_")
local varseparator=P(".")
local namesplitter=Ct(C((1-ligseparator-varseparator)^1)*(ligseparator*C((1-ligseparator-varseparator)^1))^0)
do
  local overloads={
    IJ={ name="I_J",unicode={ 0x49,0x4A },mess=0x0132 },
    ij={ name="i_j",unicode={ 0x69,0x6A },mess=0x0133 },
    ff={ name="f_f",unicode={ 0x66,0x66 },mess=0xFB00 },
    fi={ name="f_i",unicode={ 0x66,0x69 },mess=0xFB01 },
    fl={ name="f_l",unicode={ 0x66,0x6C },mess=0xFB02 },
    ffi={ name="f_f_i",unicode={ 0x66,0x66,0x69 },mess=0xFB03 },
    ffl={ name="f_f_l",unicode={ 0x66,0x66,0x6C },mess=0xFB04 },
    fj={ name="f_j",unicode={ 0x66,0x6A } },
    fk={ name="f_k",unicode={ 0x66,0x6B } },
  }
  local o=allocate {}
  for k,v in next,overloads do
    local name=v.name
    local mess=v.mess
    if name then
      o[name]=v
    end
    if mess then
      o[mess]=v
    end
    o[k]=v
  end
  mappings.overloads=o
end
function mappings.addtounicode(data,filename,checklookups,forceligatures)
  local resources=data.resources
  local unicodes=resources.unicodes
  if not unicodes then
    if trace_mapping then
      report_fonts("no unicode list, quitting tounicode for %a",filename)
    end
    return
  end
  local properties=data.properties
  local descriptions=data.descriptions
  local overloads=mappings.overloads
  unicodes['space']=unicodes['space'] or 32
  unicodes['hyphen']=unicodes['hyphen'] or 45
  unicodes['zwj']=unicodes['zwj']  or 0x200D
  unicodes['zwnj']=unicodes['zwnj']  or 0x200C
  local private=fonts.constructors and fonts.constructors.privateoffset or 0xF0000 
  local unicodevector=fonts.encodings.agl.unicodes or {} 
  local contextvector=fonts.encodings.agl.ctxcodes or {} 
  local missing={}
  local nofmissing=0
  local oparser=nil
  local cidnames=nil
  local cidcodes=nil
  local cidinfo=properties.cidinfo
  local usedmap=cidinfo and fonts.cid.getmap(cidinfo)
  local uparser=makenameparser() 
  if usedmap then
     oparser=usedmap and makenameparser(cidinfo.ordering)
     cidnames=usedmap.names
     cidcodes=usedmap.unicodes
  end
  local ns=0
  local nl=0
  local dlist=sortedkeys(descriptions)
  for i=1,#dlist do
    local du=dlist[i]
    local glyph=descriptions[du]
    local name=glyph.name
    if name then
      local overload=overloads[name] or overloads[du]
      if overload then
        glyph.unicode=overload.unicode
      else
        local gu=glyph.unicode 
        if not gu or gu==-1 or du>=private or (du>=0xE000 and du<=0xF8FF) or du==0xFFFE or du==0xFFFF then
          local unicode=unicodevector[name] or contextvector[name]
          if unicode then
            glyph.unicode=unicode
            ns=ns+1
          end
          if (not unicode) and usedmap then
            local foundindex=lpegmatch(oparser,name)
            if foundindex then
              unicode=cidcodes[foundindex] 
              if unicode then
                glyph.unicode=unicode
                ns=ns+1
              else
                local reference=cidnames[foundindex] 
                if reference then
                  local foundindex=lpegmatch(oparser,reference)
                  if foundindex then
                    unicode=cidcodes[foundindex]
                    if unicode then
                      glyph.unicode=unicode
                      ns=ns+1
                    end
                  end
                  if not unicode or unicode=="" then
                    local foundcodes,multiple=lpegmatch(uparser,reference)
                    if foundcodes then
                      glyph.unicode=foundcodes
                      if multiple then
                        nl=nl+1
                        unicode=true
                      else
                        ns=ns+1
                        unicode=foundcodes
                      end
                    end
                  end
                end
              end
            end
          end
          if not unicode or unicode=="" then
            local split=lpegmatch(namesplitter,name)
            local nsplit=split and #split or 0 
            if nsplit==0 then
            elseif nsplit==1 then
              local base=split[1]
              local u=unicodes[base] or unicodevector[base] or contextvector[name]
              if not u then
              elseif type(u)=="table" then
                if u[1]<private then
                  unicode=u
                  glyph.unicode=unicode
                end
              elseif u<private then
                unicode=u
                glyph.unicode=unicode
              end
            else
              local t,n={},0
              for l=1,nsplit do
                local base=split[l]
                local u=unicodes[base] or unicodevector[base] or contextvector[name]
                if not u then
                  break
                elseif type(u)=="table" then
                  if u[1]>=private then
                    break
                  end
                  n=n+1
                  t[n]=u[1]
                else
                  if u>=private then
                    break
                  end
                  n=n+1
                  t[n]=u
                end
              end
              if n>0 then
                if n==1 then
                  unicode=t[1]
                else
                  unicode=t
                end
                glyph.unicode=unicode
              end
            end
            nl=nl+1
          end
          if not unicode or unicode=="" then
            local foundcodes,multiple=lpegmatch(uparser,name)
            if foundcodes then
              glyph.unicode=foundcodes
              if multiple then
                nl=nl+1
                unicode=true
              else
                ns=ns+1
                unicode=foundcodes
              end
            end
          end
          local r=overloads[unicode]
          if r then
            unicode=r.unicode
            glyph.unicode=unicode
          end
          if not unicode then
            missing[du]=true
            nofmissing=nofmissing+1
          end
        else
        end
      end
    else
      local overload=overloads[du]
      if overload then
        glyph.unicode=overload.unicode
      elseif not glyph.unicode then
        missing[du]=true
        nofmissing=nofmissing+1
      end
    end
  end
  if type(checklookups)=="function" then
    checklookups(data,missing,nofmissing)
  end
  local unicoded=0
  local collected=fonts.handlers.otf.readers.getcomponents(data) 
  local function resolve(glyph,u)
    local n=#u
    for i=1,n do
      if u[i]>private then
        n=0
        break
      end
    end
    if n>0 then
      if n>1 then
        glyph.unicode=u
      else
        glyph.unicode=u[1]
      end
      unicoded=unicoded+1
    end
  end
  if not collected then
  elseif forceligatures or force_ligatures then
    for i=1,#dlist do
      local du=dlist[i]
      if du>=private or (du>=0xE000 and du<=0xF8FF) then
        local u=collected[du] 
        if u then
          resolve(descriptions[du],u)
        end
      end
    end
  else
    for i=1,#dlist do
      local du=dlist[i]
      if du>=private or (du>=0xE000 and du<=0xF8FF) then
        local glyph=descriptions[du]
        if glyph.class=="ligature" and not glyph.unicode then
          local u=collected[du] 
          if u then
             resolve(glyph,u)
          end
        end
      end
    end
  end
  if trace_mapping and unicoded>0 then
    report_fonts("%n ligature tounicode mappings deduced from gsub ligature features",unicoded)
  end
  if trace_mapping then
    for i=1,#dlist do
      local du=dlist[i]
      local glyph=descriptions[du]
      local name=glyph.name or "-"
      local index=glyph.index or 0
      local unicode=glyph.unicode
      if unicode then
        if type(unicode)=="table" then
          local unicodes={}
          for i=1,#unicode do
            unicodes[i]=formatters("%U",unicode[i])
          end
          report_fonts("internal slot %U, name %a, unicode %U, tounicode % t",index,name,du,unicodes)
        else
          report_fonts("internal slot %U, name %a, unicode %U, tounicode %U",index,name,du,unicode)
        end
      else
        report_fonts("internal slot %U, name %a, unicode %U",index,name,du)
      end
    end
  end
  if trace_loading and (ns>0 or nl>0) then
    report_fonts("%s tounicode entries added, ligatures %s",nl+ns,ns)
  end
end

end --- [luaotfload, fontloader-2018-10-08.lua scope for “font-map”] ---


do  --- [luaotfload, fontloader-2018-10-08.lua scope for “font-vfc” 237aff1862009b7850653c2098473bd4] ---

if not modules then modules={} end modules ['font-vfc']={
  version=1.001,
  comment="companion to font-ini.mkiv and hand-ini.mkiv",
  author="Hans Hagen, PRAGMA-ADE, Hasselt NL",
  copyright="PRAGMA ADE / ConTeXt Development Team",
  license="see context related readme files"
}
local select=select
local insert=table.insert
local fonts=fonts
local helpers=fonts.helpers
local setmetatableindex=table.setmetatableindex
local makeweak=table.makeweak
local push={ "push" }
local pop={ "pop" }
local dummy={ "comment" }
function helpers.prependcommands(commands,...)
  insert(commands,1,push)
  for i=select("#",...),1,-1 do
    local s=select(i,...)
    if s then
      insert(commands,1,s)
    end
  end
  insert(commands,pop)
  return commands
end
function helpers.appendcommands(commands,...)
  insert(commands,1,push)
  insert(commands,pop)
  for i=1,select("#",...) do
    local s=select(i,...)
    if s then
      insert(commands,s)
    end
  end
  return commands
end
local char=setmetatableindex(function(t,k)
  local v={ "slot",0,k }
  t[k]=v
  return v
end)
local right=setmetatableindex(function(t,k)
  local v={ "right",k }
  t[k]=v
  return v
end)
local left=setmetatableindex(function(t,k)
  local v={ "right",-k }
  t[k]=v
  return v
end)
local down=setmetatableindex(function(t,k)
  local v={ "down",k }
  t[k]=v
  return v
end)
local up=setmetatableindex(function(t,k)
  local v={ "down",-k }
  t[k]=v
  return v
end)
helpers.commands=utilities.storage.allocate {
  char=char,
  right=right,
  left=left,
  down=down,
  up=up,
  push=push,
  pop=pop,
  dummy=dummy,
}

end --- [luaotfload, fontloader-2018-10-08.lua scope for “font-vfc”] ---


do  --- [luaotfload, fontloader-2018-10-08.lua scope for “font-otr” 4a1dae571a43d7cb8afce7e906df89c6] ---

if not modules then modules={} end modules ['font-otr']={
  version=1.001,
  comment="companion to font-ini.mkiv",
  author="Hans Hagen, PRAGMA-ADE, Hasselt NL",
  copyright="PRAGMA ADE / ConTeXt Development Team",
  license="see context related readme files"
}
local next,type,tonumber=next,type,tonumber
local byte,lower,char,gsub=string.byte,string.lower,string.char,string.gsub
local floor,round=math.floor,math.round
local P,R,S,C,Cs,Cc,Ct,Carg,Cmt=lpeg.P,lpeg.R,lpeg.S,lpeg.C,lpeg.Cs,lpeg.Cc,lpeg.Ct,lpeg.Carg,lpeg.Cmt
local lpegmatch=lpeg.match
local rshift=bit32.rshift
local setmetatableindex=table.setmetatableindex
local formatters=string.formatters
local sortedkeys=table.sortedkeys
local sortedhash=table.sortedhash
local stripstring=string.nospaces
local utf16_to_utf8_be=utf.utf16_to_utf8_be
local report=logs.reporter("otf reader")
local trace_cmap=false 
local trace_cmap_detail=false
fonts=fonts or {}
local handlers=fonts.handlers or {}
fonts.handlers=handlers
local otf=handlers.otf or {}
handlers.otf=otf
local readers=otf.readers or {}
otf.readers=readers
local streamreader=utilities.files  
local streamwriter=utilities.files
readers.streamreader=streamreader
readers.streamwriter=streamwriter
local openfile=streamreader.open
local closefile=streamreader.close
local setposition=streamreader.setposition
local skipshort=streamreader.skipshort
local readbytes=streamreader.readbytes
local readstring=streamreader.readstring
local readbyte=streamreader.readcardinal1 
local readushort=streamreader.readcardinal2 
local readuint=streamreader.readcardinal3 
local readulong=streamreader.readcardinal4
local readshort=streamreader.readinteger2  
local readlong=streamreader.readinteger4  
local readfixed=streamreader.readfixed4
local read2dot14=streamreader.read2dot14   
local readfword=readshort          
local readufword=readushort         
local readoffset=readushort
local readcardinaltable=streamreader.readcardinaltable
local readintegertable=streamreader.readintegertable
function streamreader.readtag(f)
  return lower(stripstring(readstring(f,4)))
end
local short=2
local ushort=2
local ulong=4
directives.register("fonts.streamreader",function()
  streamreader=utilities.streams
  openfile=streamreader.open
  closefile=streamreader.close
  setposition=streamreader.setposition
  skipshort=streamreader.skipshort
  readbytes=streamreader.readbytes
  readstring=streamreader.readstring
  readbyte=streamreader.readcardinal1
  readushort=streamreader.readcardinal2
  readuint=streamreader.readcardinal3
  readulong=streamreader.readcardinal4
  readshort=streamreader.readinteger2
  readlong=streamreader.readinteger4
  readfixed=streamreader.readfixed4
  read2dot14=streamreader.read2dot14
  readfword=readshort
  readufword=readushort
  readoffset=readushort
  readcardinaltable=streamreader.readcardinaltable
  readintegertable=streamreader.readintegertable
  function streamreader.readtag(f)
    return lower(stripstring(readstring(f,4)))
  end
end)
local function readlongdatetime(f)
  local a,b,c,d,e,f,g,h=readbytes(f,8)
  return 0x100000000*d+0x1000000*e+0x10000*f+0x100*g+h
end
local tableversion=0.004
readers.tableversion=tableversion
local privateoffset=fonts.constructors and fonts.constructors.privateoffset or 0xF0000
local reservednames={ [0]="copyright",
  "family",
  "subfamily",
  "uniqueid",
  "fullname",
  "version",
  "postscriptname",
  "trademark",
  "manufacturer",
  "designer",
  "description",
  "vendorurl",
  "designerurl",
  "license",
  "licenseurl",
  "reserved",
  "typographicfamily",
  "typographicsubfamily",
  "compatiblefullname",
  "sampletext",
  "cidfindfontname",
  "wwsfamily",
  "wwssubfamily",
  "lightbackgroundpalette",
  "darkbackgroundpalette",
  "variationspostscriptnameprefix",
}
local platforms={ [0]="unicode",
  "macintosh",
  "iso",
  "windows",
  "custom",
}
local encodings={
  unicode={ [0]="unicode 1.0 semantics",
    "unicode 1.1 semantics",
    "iso/iec 10646",
    "unicode 2.0 bmp",
    "unicode 2.0 full",
    "unicode variation sequences",
    "unicode full repertoire",
  },
  macintosh={ [0]="roman","japanese","chinese (traditional)","korean","arabic","hebrew","greek","russian",
    "rsymbol","devanagari","gurmukhi","gujarati","oriya","bengali","tamil","telugu","kannada",
    "malayalam","sinhalese","burmese","khmer","thai","laotian","georgian","armenian",
    "chinese (simplified)","tibetan","mongolian","geez","slavic","vietnamese","sindhi",
    "uninterpreted",
  },
  iso={ [0]="7-bit ascii",
    "iso 10646",
    "iso 8859-1",
  },
  windows={ [0]="symbol",
    "unicode bmp",
    "shiftjis",
    "prc",
    "big5",
    "wansung",
    "johab",
    "reserved 7",
    "reserved 8",
    "reserved 9",
    "unicode ucs-4",
  },
  custom={
  }
}
local decoders={
  unicode={},
  macintosh={},
  iso={},
  windows={
    ["unicode semantics"]=utf16_to_utf8_be,
    ["unicode bmp"]=utf16_to_utf8_be,
    ["unicode full"]=utf16_to_utf8_be,
    ["unicode 1.0 semantics"]=utf16_to_utf8_be,
    ["unicode 1.1 semantics"]=utf16_to_utf8_be,
    ["unicode 2.0 bmp"]=utf16_to_utf8_be,
    ["unicode 2.0 full"]=utf16_to_utf8_be,
    ["unicode variation sequences"]=utf16_to_utf8_be,
    ["unicode full repertoire"]=utf16_to_utf8_be,
  },
  custom={},
}
local languages={
  unicode={
    [ 0]="english",
  },
  macintosh={
    [ 0]="english",
  },
  iso={},
  windows={
    [0x0409]="english - united states",
  },
  custom={},
}
local standardromanencoding={ [0]=
  "notdef",".null","nonmarkingreturn","space","exclam","quotedbl",
  "numbersign","dollar","percent","ampersand","quotesingle","parenleft",
  "parenright","asterisk","plus","comma","hyphen","period","slash",
  "zero","one","two","three","four","five","six","seven","eight",
  "nine","colon","semicolon","less","equal","greater","question","at",
  "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O",
  "P","Q","R","S","T","U","V","W","X","Y","Z","bracketleft",
  "backslash","bracketright","asciicircum","underscore","grave","a","b",
  "c","d","e","f","g","h","i","j","k","l","m","n","o","p","q",
  "r","s","t","u","v","w","x","y","z","braceleft","bar",
  "braceright","asciitilde","Adieresis","Aring","Ccedilla","Eacute",
  "Ntilde","Odieresis","Udieresis","aacute","agrave","acircumflex",
  "adieresis","atilde","aring","ccedilla","eacute","egrave",
  "ecircumflex","edieresis","iacute","igrave","icircumflex","idieresis",
  "ntilde","oacute","ograve","ocircumflex","odieresis","otilde","uacute",
  "ugrave","ucircumflex","udieresis","dagger","degree","cent","sterling",
  "section","bullet","paragraph","germandbls","registered","copyright",
  "trademark","acute","dieresis","notequal","AE","Oslash","infinity",
  "plusminus","lessequal","greaterequal","yen","mu","partialdiff",
  "summation","product","pi","integral","ordfeminine","ordmasculine",
  "Omega","ae","oslash","questiondown","exclamdown","logicalnot",
  "radical","florin","approxequal","Delta","guillemotleft",
  "guillemotright","ellipsis","nonbreakingspace","Agrave","Atilde",
  "Otilde","OE","oe","endash","emdash","quotedblleft","quotedblright",
  "quoteleft","quoteright","divide","lozenge","ydieresis","Ydieresis",
  "fraction","currency","guilsinglleft","guilsinglright","fi","fl",
  "daggerdbl","periodcentered","quotesinglbase","quotedblbase",
  "perthousand","Acircumflex","Ecircumflex","Aacute","Edieresis","Egrave",
  "Iacute","Icircumflex","Idieresis","Igrave","Oacute","Ocircumflex",
  "apple","Ograve","Uacute","Ucircumflex","Ugrave","dotlessi",
  "circumflex","tilde","macron","breve","dotaccent","ring","cedilla",
  "hungarumlaut","ogonek","caron","Lslash","lslash","Scaron","scaron",
  "Zcaron","zcaron","brokenbar","Eth","eth","Yacute","yacute","Thorn",
  "thorn","minus","multiply","onesuperior","twosuperior","threesuperior",
  "onehalf","onequarter","threequarters","franc","Gbreve","gbreve",
  "Idotaccent","Scedilla","scedilla","Cacute","cacute","Ccaron","ccaron",
  "dcroat",
}
local weights={
  [100]="thin",
  [200]="extralight",
  [300]="light",
  [400]="normal",
  [500]="medium",
  [600]="semibold",
  [700]="bold",
  [800]="extrabold",
  [900]="black",
}
local widths={
  [1]="ultracondensed",
  [2]="extracondensed",
  [3]="condensed",
  [4]="semicondensed",
  [5]="normal",
  [6]="semiexpanded",
  [7]="expanded",
  [8]="extraexpanded",
  [9]="ultraexpanded",
}
setmetatableindex(weights,function(t,k)
  local r=floor((k+50)/100)*100
  local v=(r>900 and "black") or rawget(t,r) or "normal"
  return v
end)
setmetatableindex(widths,function(t,k)
  return "normal"
end)
local panoseweights={
  [ 0]="normal",
  [ 1]="normal",
  [ 2]="verylight",
  [ 3]="light",
  [ 4]="thin",
  [ 5]="book",
  [ 6]="medium",
  [ 7]="demi",
  [ 8]="bold",
  [ 9]="heavy",
  [10]="black",
}
local panosewidths={
  [ 0]="normal",
  [ 1]="normal",
  [ 2]="normal",
  [ 3]="normal",
  [ 4]="normal",
  [ 5]="expanded",
  [ 6]="condensed",
  [ 7]="veryexpanded",
  [ 8]="verycondensed",
  [ 9]="monospaced",
}
local helpers={}
readers.helpers=helpers
local function gotodatatable(f,fontdata,tag,criterium)
  if criterium and f then
    local datatable=fontdata.tables[tag]
    if datatable then
      local tableoffset=datatable.offset
      setposition(f,tableoffset)
      return tableoffset
    end
  end
end
local function reportskippedtable(f,fontdata,tag,criterium)
  if criterium and f then
    local datatable=fontdata.tables[tag]
    if datatable then
      report("loading of table %a skipped",tag)
    end
  end
end
local function setvariabledata(fontdata,tag,data)
  local variabledata=fontdata.variabledata
  if variabledata then
    variabledata[tag]=data
  else
    fontdata.variabledata={ [tag]=data }
  end
end
helpers.gotodatatable=gotodatatable
helpers.setvariabledata=setvariabledata
helpers.reportskippedtable=reportskippedtable
local platformnames={
  postscriptname=true,
  fullname=true,
  family=true,
  subfamily=true,
  typographicfamily=true,
  typographicsubfamily=true,
  compatiblefullname=true,
}
function readers.name(f,fontdata,specification)
  local tableoffset=gotodatatable(f,fontdata,"name",true)
  if tableoffset then
    local format=readushort(f)
    local nofnames=readushort(f)
    local offset=readushort(f)
    local start=tableoffset+offset
    local namelists={
      unicode={},
      windows={},
      macintosh={},
    }
    for i=1,nofnames do
      local platform=platforms[readushort(f)]
      if platform then
        local namelist=namelists[platform]
        if namelist then
          local encoding=readushort(f)
          local language=readushort(f)
          local encodings=encodings[platform]
          local languages=languages[platform]
          if encodings and languages then
            local encoding=encodings[encoding]
            local language=languages[language]
            if encoding and language then
              local index=readushort(f)
              local name=reservednames[index]
              namelist[#namelist+1]={
                platform=platform,
                encoding=encoding,
                language=language,
                name=name,
                index=index,
                length=readushort(f),
                offset=start+readushort(f),
              }
            else
              skipshort(f,3)
            end
          else
            skipshort(f,3)
          end
        else
          skipshort(f,5)
        end
      else
        skipshort(f,5)
      end
    end
    local names={}
    local done={}
    local extras={}
    local function filter(platform,e,l)
      local namelist=namelists[platform]
      for i=1,#namelist do
        local name=namelist[i]
        local nametag=name.name
        local index=name.index
        if not done[nametag or i] then
          local encoding=name.encoding
          local language=name.language
          if (not e or encoding==e) and (not l or language==l) then
            setposition(f,name.offset)
            local content=readstring(f,name.length)
            local decoder=decoders[platform]
            if decoder then
              decoder=decoder[encoding]
            end
            if decoder then
              content=decoder(content)
            end
            if nametag then
              names[nametag]={
                content=content,
                platform=platform,
                encoding=encoding,
                language=language,
              }
            end
            extras[index]=content
            done[nametag or i]=true
          end
        end
      end
    end
    filter("windows","unicode bmp","english - united states")
    filter("macintosh","roman","english")
    filter("windows")
    filter("macintosh")
    filter("unicode")
    fontdata.names=names
    fontdata.extras=extras
    if specification.platformnames then
      local collected={}
      for platform,namelist in next,namelists do
        local filtered=false
        for i=1,#namelist do
          local entry=namelist[i]
          local name=entry.name
          if platformnames[name] then
            setposition(f,entry.offset)
            local content=readstring(f,entry.length)
            local encoding=entry.encoding
            local decoder=decoders[platform]
            if decoder then
              decoder=decoder[encoding]
            end
            if decoder then
              content=decoder(content)
            end
            if filtered then
              filtered[name]=content
            else
              filtered={ [name]=content }
            end
          end
        end
        if filtered then
          collected[platform]=filtered
        end
      end
      fontdata.platformnames=collected
    end
  else
    fontdata.names={}
  end
end
local validutf=lpeg.patterns.validutf8
local function getname(fontdata,key)
  local names=fontdata.names
  if names then
    local value=names[key]
    if value then
      local content=value.content
      return lpegmatch(validutf,content) and content or nil
    end
  end
end
readers["os/2"]=function(f,fontdata)
  local tableoffset=gotodatatable(f,fontdata,"os/2",true)
  if tableoffset then
    local version=readushort(f)
    local windowsmetrics={
      version=version,
      averagewidth=readshort(f),
      weightclass=readushort(f),
      widthclass=readushort(f),
      fstype=readushort(f),
      subscriptxsize=readshort(f),
      subscriptysize=readshort(f),
      subscriptxoffset=readshort(f),
      subscriptyoffset=readshort(f),
      superscriptxsize=readshort(f),
      superscriptysize=readshort(f),
      superscriptxoffset=readshort(f),
      superscriptyoffset=readshort(f),
      strikeoutsize=readshort(f),
      strikeoutpos=readshort(f),
      familyclass=readshort(f),
      panose={ readbytes(f,10) },
      unicoderanges={ readulong(f),readulong(f),readulong(f),readulong(f) },
      vendor=readstring(f,4),
      fsselection=readushort(f),
      firstcharindex=readushort(f),
      lastcharindex=readushort(f),
      typoascender=readshort(f),
      typodescender=readshort(f),
      typolinegap=readshort(f),
      winascent=readushort(f),
      windescent=readushort(f),
    }
    if version>=1 then
      windowsmetrics.codepageranges={ readulong(f),readulong(f) }
    end
    if version>=3 then
      windowsmetrics.xheight=readshort(f)
      windowsmetrics.capheight=readshort(f)
      windowsmetrics.defaultchar=readushort(f)
      windowsmetrics.breakchar=readushort(f)
    end
    windowsmetrics.weight=windowsmetrics.weightclass and weights[windowsmetrics.weightclass]
    windowsmetrics.width=windowsmetrics.widthclass and widths [windowsmetrics.widthclass]
    windowsmetrics.panoseweight=panoseweights[windowsmetrics.panose[3]]
    windowsmetrics.panosewidth=panosewidths [windowsmetrics.panose[4]]
    fontdata.windowsmetrics=windowsmetrics
  else
    fontdata.windowsmetrics={}
  end
end
readers.head=function(f,fontdata)
  local tableoffset=gotodatatable(f,fontdata,"head",true)
  if tableoffset then
    local fontheader={
      version=readfixed(f),
      revision=readfixed(f),
      checksum=readulong(f),
      magic=readulong(f),
      flags=readushort(f),
      units=readushort(f),
      created=readlongdatetime(f),
      modified=readlongdatetime(f),
      xmin=readshort(f),
      ymin=readshort(f),
      xmax=readshort(f),
      ymax=readshort(f),
      macstyle=readushort(f),
      smallpixels=readushort(f),
      directionhint=readshort(f),
      indextolocformat=readshort(f),
      glyphformat=readshort(f),
    }
    fontdata.fontheader=fontheader
  else
    fontdata.fontheader={}
  end
  fontdata.nofglyphs=0
end
readers.hhea=function(f,fontdata,specification)
  local tableoffset=gotodatatable(f,fontdata,"hhea",specification.details)
  if tableoffset then
    fontdata.horizontalheader={
      version=readfixed(f),
      ascender=readfword(f),
      descender=readfword(f),
      linegap=readfword(f),
      maxadvancewidth=readufword(f),
      minleftsidebearing=readfword(f),
      minrightsidebearing=readfword(f),
      maxextent=readfword(f),
      caretsloperise=readshort(f),
      caretsloperun=readshort(f),
      caretoffset=readshort(f),
      reserved_1=readshort(f),
      reserved_2=readshort(f),
      reserved_3=readshort(f),
      reserved_4=readshort(f),
      metricdataformat=readshort(f),
      nofmetrics=readushort(f),
    }
  else
    fontdata.horizontalheader={
      nofmetrics=0,
    }
  end
end
readers.vhea=function(f,fontdata,specification)
  local tableoffset=gotodatatable(f,fontdata,"vhea",specification.details)
  if tableoffset then
    fontdata.verticalheader={
      version=readfixed(f),
      ascender=readfword(f),
      descender=readfword(f),
      linegap=readfword(f),
      maxadvanceheight=readufword(f),
      mintopsidebearing=readfword(f),
      minbottomsidebearing=readfword(f),
      maxextent=readfword(f),
      caretsloperise=readshort(f),
      caretsloperun=readshort(f),
      caretoffset=readshort(f),
      reserved_1=readshort(f),
      reserved_2=readshort(f),
      reserved_3=readshort(f),
      reserved_4=readshort(f),
      metricdataformat=readshort(f),
      nofmetrics=readushort(f),
    }
  else
    fontdata.verticalheader={
      nofmetrics=0,
    }
  end
end
readers.maxp=function(f,fontdata,specification)
  local tableoffset=gotodatatable(f,fontdata,"maxp",specification.details)
  if tableoffset then
    local version=readfixed(f)
    local nofglyphs=readushort(f)
    fontdata.nofglyphs=nofglyphs
    if version==0.5 then
      fontdata.maximumprofile={
        version=version,
        nofglyphs=nofglyphs,
      }
    elseif version==1.0 then
      fontdata.maximumprofile={
        version=version,
        nofglyphs=nofglyphs,
        points=readushort(f),
        contours=readushort(f),
        compositepoints=readushort(f),
        compositecontours=readushort(f),
        zones=readushort(f),
        twilightpoints=readushort(f),
        storage=readushort(f),
        functiondefs=readushort(f),
        instructiondefs=readushort(f),
        stackelements=readushort(f),
        sizeofinstructions=readushort(f),
        componentelements=readushort(f),
        componentdepth=readushort(f),
      }
    else
      fontdata.maximumprofile={
        version=version,
        nofglyphs=0,
      }
    end
  end
end
readers.hmtx=function(f,fontdata,specification)
  local tableoffset=gotodatatable(f,fontdata,"hmtx",specification.glyphs)
  if tableoffset then
    local horizontalheader=fontdata.horizontalheader
    local nofmetrics=horizontalheader.nofmetrics
    local glyphs=fontdata.glyphs
    local nofglyphs=fontdata.nofglyphs
    local width=0 
    local leftsidebearing=0
    for i=0,nofmetrics-1 do
      local glyph=glyphs[i]
      width=readshort(f)
      leftsidebearing=readshort(f)
      if width~=0 then
        glyph.width=width
      end
    end
    for i=nofmetrics,nofglyphs-1 do
      local glyph=glyphs[i]
      if width~=0 then
        glyph.width=width
      end
    end
  end
end
readers.vmtx=function(f,fontdata,specification)
  local tableoffset=gotodatatable(f,fontdata,"vmtx",specification.glyphs)
  if tableoffset then
    local verticalheader=fontdata.verticalheader
    local nofmetrics=verticalheader.nofmetrics
    local glyphs=fontdata.glyphs
    local nofglyphs=fontdata.nofglyphs
    local vheight=0
    local vdefault=verticalheader.ascender+verticalheader.descender
    local topsidebearing=0
    for i=0,nofmetrics-1 do
      local glyph=glyphs[i]
      vheight=readshort(f)
      topsidebearing=readshort(f)
      if vheight~=0 and vheight~=vdefault then
        glyph.vheight=vheight
      end
    end
    for i=nofmetrics,nofglyphs-1 do
      local glyph=glyphs[i]
      if vheight~=0 and vheight~=vdefault then
        glyph.vheight=vheight
      end
    end
  end
end
readers.vorg=function(f,fontdata,specification)
  reportskippedtable(f,fontdata,"vorg",specification.glyphs)
end
readers.post=function(f,fontdata,specification)
  local tableoffset=gotodatatable(f,fontdata,"post",true)
  if tableoffset then
    local version=readfixed(f)
    fontdata.postscript={
      version=version,
      italicangle=round(1000*readfixed(f))/1000,
      underlineposition=readfword(f),
      underlinethickness=readfword(f),
      monospaced=readulong(f),
      minmemtype42=readulong(f),
      maxmemtype42=readulong(f),
      minmemtype1=readulong(f),
      maxmemtype1=readulong(f),
    }
    if not specification.glyphs then
    elseif version==1.0 then
      for index=0,#standardromanencoding do
        glyphs[index].name=standardromanencoding[index]
      end
    elseif version==2.0 then
      local glyphs=fontdata.glyphs
      local nofglyphs=readushort(f)
      local indices={}
      local names={}
      local maxnames=0
      for i=0,nofglyphs-1 do
        local nameindex=readushort(f)
        if nameindex>=258 then
          maxnames=maxnames+1
          nameindex=nameindex-257
          indices[nameindex]=i
        else
          glyphs[i].name=standardromanencoding[nameindex]
        end
      end
      for i=1,maxnames do
        local mapping=indices[i]
        if not mapping then
          report("quit post name fetching at %a of %a: %s",i,maxnames,"no index")
          break
        else
          local length=readbyte(f)
          if length>0 then
            glyphs[mapping].name=readstring(f,length)
          else
            report("quit post name fetching at %a of %a: %s",i,maxnames,"overflow")
            break
          end
        end
      end
    elseif version==2.5 then
    elseif version==3.0 then
    end
  else
    fontdata.postscript={}
  end
end
readers.cff=function(f,fontdata,specification)
  reportskippedtable(f,fontdata,"cff",specification.glyphs)
end
local formatreaders={}
local duplicatestoo=true
local sequence={
  { 3,1,4 },
  { 3,10,12 },
  { 0,3,4 },
  { 0,1,4 },
  { 0,0,6 },
  { 3,0,6 },
  { 0,5,14 },
{ 0,4,12 },
  { 3,10,13 },
}
local supported={}
for i=1,#sequence do
  local si=sequence[i]
  local sp,se,sf=si[1],si[2],si[3]
  local p=supported[sp]
  if not p then
    p={}
    supported[sp]=p
  end
  local e=p[se]
  if not e then
    e={}
    p[se]=e
  end
  e[sf]=true
end
formatreaders[4]=function(f,fontdata,offset)
  setposition(f,offset+2)
  local length=readushort(f) 
  local language=readushort(f)
  local nofsegments=readushort(f)/2
  skipshort(f,3)
  local mapping=fontdata.mapping
  local glyphs=fontdata.glyphs
  local duplicates=fontdata.duplicates
  local nofdone=0
  local endchars=readcardinaltable(f,nofsegments,ushort)
  local reserved=readushort(f) 
  local startchars=readcardinaltable(f,nofsegments,ushort)
  local deltas=readcardinaltable(f,nofsegments,ushort)
  local offsets=readcardinaltable(f,nofsegments,ushort)
  local size=(length-2*2-5*2-4*2*nofsegments)/2
  local indices=readcardinaltable(f,size-1,ushort)
  for segment=1,nofsegments do
    local startchar=startchars[segment]
    local endchar=endchars[segment]
    local offset=offsets[segment]
    local delta=deltas[segment]
    if startchar==0xFFFF and endchar==0xFFFF then
    elseif startchar==0xFFFF and offset==0 then
    elseif offset==0xFFFF then
    elseif offset==0 then
      if trace_cmap_detail then
        report("format 4.%i segment %2i from %C upto %C at index %H",1,segment,startchar,endchar,(startchar+delta)%65536)
      end
      for unicode=startchar,endchar do
        local index=(unicode+delta)%65536
        if index and index>0 then
          local glyph=glyphs[index]
          if glyph then
            local gu=glyph.unicode
            if not gu then
              glyph.unicode=unicode
              nofdone=nofdone+1
            elseif gu~=unicode then
              if duplicatestoo then
                local d=duplicates[gu]
                if d then
                  d[unicode]=true
                else
                  duplicates[gu]={ [unicode]=true }
                end
              else
                report("duplicate case 1: %C %04i %s",unicode,index,glyphs[index].name)
              end
            end
            if not mapping[index] then
              mapping[index]=unicode
            end
          end
        end
      end
    else
      local shift=(segment-nofsegments+offset/2)-startchar
      if trace_cmap_detail then
        report("format 4.%i segment %2i from %C upto %C at index %H",0,segment,startchar,endchar,(startchar+delta)%65536)
      end
      for unicode=startchar,endchar do
        local slot=shift+unicode
        local index=indices[slot]
        if index and index>0 then
          index=(index+delta)%65536
          local glyph=glyphs[index]
          if glyph then
            local gu=glyph.unicode
            if not gu then
              glyph.unicode=unicode
              nofdone=nofdone+1
            elseif gu~=unicode then
              if duplicatestoo then
                local d=duplicates[gu]
                if d then
                  d[unicode]=true
                else
                  duplicates[gu]={ [unicode]=true }
                end
              else
                report("duplicate case 2: %C %04i %s",unicode,index,glyphs[index].name)
              end
            end
            if not mapping[index] then
              mapping[index]=unicode
            end
          end
        end
      end
    end
  end
  return nofdone
end
formatreaders[6]=function(f,fontdata,offset)
  setposition(f,offset) 
  local format=readushort(f)
  local length=readushort(f)
  local language=readushort(f)
  local mapping=fontdata.mapping
  local glyphs=fontdata.glyphs
  local duplicates=fontdata.duplicates
  local start=readushort(f)
  local count=readushort(f)
  local stop=start+count-1
  local nofdone=0
  if trace_cmap_detail then
    report("format 6 from %C to %C",2,start,stop)
  end
  for unicode=start,stop do
    local index=readushort(f)
    if index>0 then
      local glyph=glyphs[index]
      if glyph then
        local gu=glyph.unicode
        if not gu then
          glyph.unicode=unicode
          nofdone=nofdone+1
        elseif gu~=unicode then
        end
        if not mapping[index] then
          mapping[index]=unicode
        end
      end
    end
  end
  return nofdone
end
formatreaders[12]=function(f,fontdata,offset)
  setposition(f,offset+2+2+4+4) 
  local mapping=fontdata.mapping
  local glyphs=fontdata.glyphs
  local duplicates=fontdata.duplicates
  local nofgroups=readulong(f)
  local nofdone=0
  for i=1,nofgroups do
    local first=readulong(f)
    local last=readulong(f)
    local index=readulong(f)
    if trace_cmap_detail then
      report("format 12 from %C to %C starts at index %i",first,last,index)
    end
    for unicode=first,last do
      local glyph=glyphs[index]
      if glyph then
        local gu=glyph.unicode
        if not gu then
          glyph.unicode=unicode
          nofdone=nofdone+1
        elseif gu~=unicode then
          local d=duplicates[gu]
          if d then
            d[unicode]=true
          else
            duplicates[gu]={ [unicode]=true }
          end
        end
        if not mapping[index] then
          mapping[index]=unicode
        end
      end
      index=index+1
    end
  end
  return nofdone
end
formatreaders[13]=function(f,fontdata,offset)
  setposition(f,offset+2+2+4+4) 
  local mapping=fontdata.mapping
  local glyphs=fontdata.glyphs
  local duplicates=fontdata.duplicates
  local nofgroups=readulong(f)
  local nofdone=0
  for i=1,nofgroups do
    local first=readulong(f)
    local last=readulong(f)
    local index=readulong(f)
    if first<privateoffset then
      if trace_cmap_detail then
        report("format 13 from %C to %C get index %i",first,last,index)
      end
      local glyph=glyphs[index]
      local unicode=glyph.unicode
      if not unicode then
        unicode=first
        glyph.unicode=unicode
        first=first+1
      end
      local list=duplicates[unicode]
      mapping[index]=unicode
      if not list then
        list={}
        duplicates[unicode]=list
      end
      if last>=privateoffset then
        local limit=privateoffset-1
        report("format 13 from %C to %C pruned to %C",first,last,limit)
        last=limit
      end
      for unicode=first,last do
        list[unicode]=true
      end
      nofdone=nofdone+last-first+1
    else
      report("format 13 from %C to %C ignored",first,last)
    end
  end
  return nofdone
end
formatreaders[14]=function(f,fontdata,offset)
  if offset and offset~=0 then
    setposition(f,offset)
    local format=readushort(f)
    local length=readulong(f)
    local nofrecords=readulong(f)
    local records={}
    local variants={}
    local nofdone=0
    fontdata.variants=variants
    for i=1,nofrecords do
      records[i]={
        selector=readuint(f),
        default=readulong(f),
        other=readulong(f),
      }
    end
    for i=1,nofrecords do
      local record=records[i]
      local selector=record.selector
      local default=record.default
      local other=record.other
      local other=record.other
      if other~=0 then
        setposition(f,offset+other)
        local mapping={}
        local count=readulong(f)
        for i=1,count do
          mapping[readuint(f)]=readushort(f)
        end
        nofdone=nofdone+count
        variants[selector]=mapping
      end
    end
    return nofdone
  else
    return 0
  end
end
local function checkcmap(f,fontdata,records,platform,encoding,format)
  local data=records[platform]
  if not data then
    return 0
  end
  data=data[encoding]
  if not data then
    return 0
  end
  data=data[format]
  if not data then
    return 0
  end
  local reader=formatreaders[format]
  if not reader then
    return 0
  end
  local p=platforms[platform]
  local e=encodings[p]
  local n=reader(f,fontdata,data) or 0
  if trace_cmap then
    report("cmap checked: platform %i (%s), encoding %i (%s), format %i, new unicodes %i",platform,p,encoding,e and e[encoding] or "?",format,n)
  end
  return n
end
function readers.cmap(f,fontdata,specification)
  local tableoffset=gotodatatable(f,fontdata,"cmap",specification.glyphs)
  if tableoffset then
    local version=readushort(f)
    local noftables=readushort(f)
    local records={}
    local unicodecid=false
    local variantcid=false
    local variants={}
    local duplicates=fontdata.duplicates or {}
    fontdata.duplicates=duplicates
    for i=1,noftables do
      local platform=readushort(f)
      local encoding=readushort(f)
      local offset=readulong(f)
      local record=records[platform]
      if not record then
        records[platform]={
          [encoding]={
            offsets={ offset },
            formats={},
          }
        }
      else
        local subtables=record[encoding]
        if not subtables then
          record[encoding]={
            offsets={ offset },
            formats={},
          }
        else
          local offsets=subtables.offsets
          offsets[#offsets+1]=offset
        end
      end
    end
    if trace_cmap then
      report("found cmaps:")
    end
    for platform,record in sortedhash(records) do
      local p=platforms[platform]
      local e=encodings[p]
      local sp=supported[platform]
      local ps=p or "?"
      if trace_cmap then
        if sp then
          report("  platform %i: %s",platform,ps)
        else
          report("  platform %i: %s (unsupported)",platform,ps)
        end
      end
      for encoding,subtables in sortedhash(record) do
        local se=sp and sp[encoding]
        local es=e and e[encoding] or "?"
        if trace_cmap then
          if se then
            report("    encoding %i: %s",encoding,es)
          else
            report("    encoding %i: %s (unsupported)",encoding,es)
          end
        end
        local offsets=subtables.offsets
        local formats=subtables.formats
        for i=1,#offsets do
          local offset=tableoffset+offsets[i]
          setposition(f,offset)
          formats[readushort(f)]=offset
        end
        record[encoding]=formats
        if trace_cmap then
          local list=sortedkeys(formats)
          for i=1,#list do
            if not (se and se[list[i]]) then
              list[i]=list[i].." (unsupported)"
            end
          end
          report("      formats: % t",list)
        end
      end
    end
    local ok=false
    for i=1,#sequence do
      local si=sequence[i]
      local sp,se,sf=si[1],si[2],si[3]
      if checkcmap(f,fontdata,records,sp,se,sf)>0 then
        ok=true
      end
    end
    if not ok then
      report("no useable unicode cmap found")
    end
    fontdata.cidmaps={
      version=version,
      noftables=noftables,
      records=records,
    }
  else
    fontdata.cidmaps={}
  end
end
function readers.loca(f,fontdata,specification)
  reportskippedtable(f,fontdata,"loca",specification.glyphs)
end
function readers.glyf(f,fontdata,specification) 
  reportskippedtable(f,fontdata,"glyf",specification.glyphs)
end
function readers.colr(f,fontdata,specification)
  reportskippedtable(f,fontdata,"colr",specification.glyphs)
end
function readers.cpal(f,fontdata,specification)
  reportskippedtable(f,fontdata,"cpal",specification.glyphs)
end
function readers.svg(f,fontdata,specification)
  reportskippedtable(f,fontdata,"svg",specification.glyphs)
end
function readers.sbix(f,fontdata,specification)
  reportskippedtable(f,fontdata,"sbix",specification.glyphs)
end
function readers.cbdt(f,fontdata,specification)
  reportskippedtable(f,fontdata,"cbdt",specification.glyphs)
end
function readers.cblc(f,fontdata,specification)
  reportskippedtable(f,fontdata,"cblc",specification.glyphs)
end
function readers.ebdt(f,fontdata,specification)
  reportskippedtable(f,fontdata,"ebdt",specification.glyphs)
end
function readers.ebsc(f,fontdata,specification)
  reportskippedtable(f,fontdata,"ebsc",specification.glyphs)
end
function readers.eblc(f,fontdata,specification)
  reportskippedtable(f,fontdata,"eblc",specification.glyphs)
end
function readers.kern(f,fontdata,specification)
  local tableoffset=gotodatatable(f,fontdata,"kern",specification.kerns)
  if tableoffset then
    local version=readushort(f)
    local noftables=readushort(f)
    for i=1,noftables do
      local version=readushort(f)
      local length=readushort(f)
      local coverage=readushort(f)
      local format=rshift(coverage,8) 
      if format==0 then
        local nofpairs=readushort(f)
        local searchrange=readushort(f)
        local entryselector=readushort(f)
        local rangeshift=readushort(f)
        local kerns={}
        local glyphs=fontdata.glyphs
        for i=1,nofpairs do
          local left=readushort(f)
          local right=readushort(f)
          local kern=readfword(f)
          local glyph=glyphs[left]
          local kerns=glyph.kerns
          if kerns then
            kerns[right]=kern
          else
            glyph.kerns={ [right]=kern }
          end
        end
      elseif format==2 then
        report("todo: kern classes")
      else
        report("todo: kerns")
      end
    end
  end
end
function readers.gdef(f,fontdata,specification)
  reportskippedtable(f,fontdata,"gdef",specification.details)
end
function readers.gsub(f,fontdata,specification)
  reportskippedtable(f,fontdata,"gsub",specification.details)
end
function readers.gpos(f,fontdata,specification)
  reportskippedtable(f,fontdata,"gpos",specification.details)
end
function readers.math(f,fontdata,specification)
  reportskippedtable(f,fontdata,"math",specification.details)
end
local function getinfo(maindata,sub,platformnames,rawfamilynames,metricstoo,instancenames)
  local fontdata=sub and maindata.subfonts and maindata.subfonts[sub] or maindata
  local names=fontdata.names
  local info=nil
  if names then
    local metrics=fontdata.windowsmetrics or {}
    local postscript=fontdata.postscript   or {}
    local fontheader=fontdata.fontheader   or {}
    local cffinfo=fontdata.cffinfo    or {}
    local filename=fontdata.filename
    local weight=getname(fontdata,"weight") or (cffinfo and cffinfo.weight) or (metrics and metrics.weight)
    local width=getname(fontdata,"width") or (cffinfo and cffinfo.width ) or (metrics and metrics.width )
    local fontname=getname(fontdata,"postscriptname")
    local fullname=getname(fontdata,"fullname")
    local family=getname(fontdata,"family")
    local subfamily=getname(fontdata,"subfamily")
    local familyname=getname(fontdata,"typographicfamily")
    local subfamilyname=getname(fontdata,"typographicsubfamily")
    local compatiblename=getname(fontdata,"compatiblefullname") 
    if rawfamilynames then
    else
      if not  familyname then  familyname=family end
      if not subfamilyname then subfamilyname=subfamily end
    end
    if platformnames then
      platformnames=fontdata.platformnames
    end
    if instancenames then
      local variabledata=fontdata.variabledata
      if variabledata then
        local instances=variabledata and variabledata.instances
        if instances then
          instancenames={}
          for i=1,#instances do
            instancenames[i]=lower(stripstring(instances[i].subfamily))
          end
        else
          instancenames=nil
        end
      else
        instancenames=nil
      end
    end
    info={ 
      subfontindex=fontdata.subfontindex or sub or 0,
      version=getname(fontdata,"version"),
      fontname=fontname,
      fullname=fullname,
      family=family,
      subfamily=subfamily,
      familyname=familyname,
      subfamilyname=subfamilyname,
      compatiblename=compatiblename,
      weight=weight and lower(weight),
      width=width and lower(width),
      pfmweight=metrics.weightclass or 400,
      pfmwidth=metrics.widthclass or 5,
      panosewidth=metrics.panosewidth,
      panoseweight=metrics.panoseweight,
      italicangle=postscript.italicangle or 0,
      units=fontheader.units or 0,
      designsize=fontdata.designsize,
      minsize=fontdata.minsize,
      maxsize=fontdata.maxsize,
      monospaced=(tonumber(postscript.monospaced or 0)>0) or metrics.panosewidth=="monospaced",
      averagewidth=metrics.averagewidth,
      xheight=metrics.xheight,
      capheight=metrics.capheight,
      ascender=metrics.typoascender,
      descender=metrics.typodescender,
      platformnames=platformnames or nil,
      instancenames=instancenames or nil,
    }
    if metricstoo then
      local keys={
        "version",
        "ascender","descender","linegap",
        "maxadvancewidth","maxadvanceheight","maxextent",
        "minbottomsidebearing","mintopsidebearing",
      }
      local h=fontdata.horizontalheader or {}
      local v=fontdata.verticalheader  or {}
      if h then
        local th={}
        local tv={}
        for i=1,#keys do
          local key=keys[i]
          th[key]=h[key] or 0
          tv[key]=v[key] or 0
        end
        info.horizontalmetrics=th
        info.verticalmetrics=tv
      end
    end
  elseif n then
    info={
      filename=fontdata.filename,
      comment="there is no info for subfont "..n,
    }
  else
    info={
      filename=fontdata.filename,
      comment="there is no info",
    }
  end
  return info
end
local function loadtables(f,specification,offset)
  if offset then
    setposition(f,offset)
  end
  local tables={}
  local basename=file.basename(specification.filename)
  local filesize=specification.filesize
  local filetime=specification.filetime
  local fontdata={ 
    filename=basename,
    filesize=filesize,
    filetime=filetime,
    version=readstring(f,4),
    noftables=readushort(f),
    searchrange=readushort(f),
    entryselector=readushort(f),
    rangeshift=readushort(f),
    tables=tables,
    foundtables=false,
  }
  for i=1,fontdata.noftables do
    local tag=lower(stripstring(readstring(f,4)))
    local checksum=readulong(f) 
    local offset=readulong(f)
    local length=readulong(f)
    if offset+length>filesize then
      report("bad %a table in file %a",tag,basename)
    end
    tables[tag]={
      checksum=checksum,
      offset=offset,
      length=length,
    }
  end
  fontdata.foundtables=sortedkeys(tables)
  if tables.cff or tables.cff2 then
    fontdata.format="opentype"
  else
    fontdata.format="truetype"
  end
  return fontdata
end
local function prepareglyps(fontdata)
  local glyphs=setmetatableindex(function(t,k)
    local v={
      index=k,
    }
    t[k]=v
    return v
  end)
  fontdata.glyphs=glyphs
  fontdata.mapping={}
end
local function readtable(tag,f,fontdata,specification,...)
  local reader=readers[tag]
  if reader then
    reader(f,fontdata,specification,...)
  end
end
local variablefonts_supported=(context and true) or (logs and logs.application and true) or false
local function readdata(f,offset,specification)
  local fontdata=loadtables(f,specification,offset)
  if specification.glyphs then
    prepareglyps(fontdata)
  end
  if not variablefonts_supported then
    specification.instance=nil
    specification.variable=nil
    specification.factors=nil
  end
  fontdata.temporary={}
  readtable("name",f,fontdata,specification)
  local askedname=specification.askedname
  if askedname then
    local fullname=getname(fontdata,"fullname") or ""
    local cleanname=gsub(askedname,"[^a-zA-Z0-9]","")
    local foundname=gsub(fullname,"[^a-zA-Z0-9]","")
    if lower(cleanname)~=lower(foundname) then
      return 
    end
  end
  readtable("stat",f,fontdata,specification)
  readtable("avar",f,fontdata,specification)
  readtable("fvar",f,fontdata,specification)
  if variablefonts_supported then
    local variabledata=fontdata.variabledata
    if variabledata then
      local instances=variabledata.instances
      local axis=variabledata.axis
      if axis and (not instances or #instances==0) then
        instances={}
        variabledata.instances=instances
        local function add(n,subfamily,value)
          local values={}
          for i=1,#axis do
            local a=axis[i]
            values[i]={
              axis=a.tag,
              value=i==n and value or a.default,
            }
          end
          instances[#instances+1]={
            subfamily=subfamily,
            values=values,
          }
        end
        for i=1,#axis do
          local a=axis[i]
          local tag=a.tag
          add(i,"default"..tag,a.default)
          add(i,"minimum"..tag,a.minimum)
          add(i,"maximum"..tag,a.maximum)
        end
      end
    end
    if not specification.factors then
      local instance=specification.instance
      if type(instance)=="string" then
        local factors=helpers.getfactors(fontdata,instance)
        if factors then
          specification.factors=factors
          fontdata.factors=factors
          fontdata.instance=instance
          report("user instance: %s, factors: % t",instance,factors)
        else
          report("user instance: %s, bad factors",instance)
        end
      end
    end
    if not fontdata.factors then
      if fontdata.variabledata then
        local factors=helpers.getfactors(fontdata,true)
        if factors then
          specification.factors=factors
          fontdata.factors=factors
        end
      else
      end
    end
  end
  readtable("os/2",f,fontdata,specification)
  readtable("head",f,fontdata,specification)
  readtable("maxp",f,fontdata,specification)
  readtable("hhea",f,fontdata,specification)
  readtable("vhea",f,fontdata,specification)
  readtable("hmtx",f,fontdata,specification)
  readtable("vmtx",f,fontdata,specification)
  readtable("vorg",f,fontdata,specification)
  readtable("post",f,fontdata,specification)
  readtable("mvar",f,fontdata,specification)
  readtable("hvar",f,fontdata,specification)
  readtable("vvar",f,fontdata,specification)
  readtable("gdef",f,fontdata,specification)
  readtable("cff",f,fontdata,specification)
  readtable("cff2",f,fontdata,specification)
  readtable("cmap",f,fontdata,specification)
  readtable("loca",f,fontdata,specification) 
  readtable("glyf",f,fontdata,specification) 
  readtable("colr",f,fontdata,specification)
  readtable("cpal",f,fontdata,specification)
  readtable("svg",f,fontdata,specification)
  readtable("sbix",f,fontdata,specification)
  readtable("cbdt",f,fontdata,specification)
  readtable("cblc",f,fontdata,specification)
  readtable("ebdt",f,fontdata,specification)
  readtable("eblc",f,fontdata,specification)
  readtable("kern",f,fontdata,specification)
  readtable("gsub",f,fontdata,specification)
  readtable("gpos",f,fontdata,specification)
  readtable("math",f,fontdata,specification)
  fontdata.locations=nil
  fontdata.tables=nil
  fontdata.cidmaps=nil
  fontdata.dictionaries=nil
  return fontdata
end
local function loadfontdata(specification)
  local filename=specification.filename
  local fileattr=lfs.attributes(filename)
  local filesize=fileattr and fileattr.size or 0
  local filetime=fileattr and fileattr.modification or 0
  local f=openfile(filename,true) 
  if not f then
    report("unable to open %a",filename)
  elseif filesize==0 then
    report("empty file %a",filename)
    closefile(f)
  else
    specification.filesize=filesize
    specification.filetime=filetime
    local version=readstring(f,4)
    local fontdata=nil
    if version=="OTTO" or version=="true" or version=="\0\1\0\0" then
      fontdata=readdata(f,0,specification)
    elseif version=="ttcf" then
      local subfont=tonumber(specification.subfont)
      local ttcversion=readulong(f)
      local nofsubfonts=readulong(f)
      local offsets=readcardinaltable(f,nofsubfonts,ulong)
      if subfont then 
        if subfont>=1 and subfont<=nofsubfonts then
          fontdata=readdata(f,offsets[subfont],specification)
        else
          report("no subfont %a in file %a",subfont,filename)
        end
      else
        subfont=specification.subfont
        if type(subfont)=="string" and subfont~="" then
          specification.askedname=subfont
          for i=1,nofsubfonts do
            fontdata=readdata(f,offsets[i],specification)
            if fontdata then
              fontdata.subfontindex=i
              report("subfont named %a has index %a",subfont,i)
              break
            end
          end
          if not fontdata then
            report("no subfont named %a",subfont)
          end
        else
          local subfonts={}
          fontdata={
            filename=filename,
            filesize=filesize,
            filetime=filetime,
            version=version,
            subfonts=subfonts,
            ttcversion=ttcversion,
            nofsubfonts=nofsubfonts,
          }
          for i=1,nofsubfonts do
            subfonts[i]=readdata(f,offsets[i],specification)
          end
        end
      end
    else
      report("unknown version %a in file %a",version,filename)
    end
    closefile(f)
    return fontdata or {}
  end
end
local function loadfont(specification,n,instance)
  if type(specification)=="string" then
    specification={
      filename=specification,
      info=true,
      details=true,
      glyphs=true,
      shapes=true,
      kerns=true,
      variable=true,
      globalkerns=true,
      lookups=true,
      subfont=n or true,
      tounicode=false,
      instance=instance
    }
  end
  if specification.shapes or specification.lookups or specification.kerns then
    specification.glyphs=true
  end
  if specification.glyphs then
    specification.details=true
  end
  if specification.details then
    specification.info=true 
  end
  if specification.platformnames then
    specification.platformnames=true 
  end
  if specification.instance or instance then
    specification.variable=true
    specification.instance=specification.instance or instance
  end
  local function message(str)
    report("fatal error in file %a: %s\n%s",specification.filename,str,debug.traceback())
  end
  local ok,result=xpcall(loadfontdata,message,specification)
  if ok then
    return result
  end
end
function readers.loadshapes(filename,n,instance,streams)
  local fontdata=loadfont {
    filename=filename,
    shapes=true,
    streams=streams,
    variable=true,
    subfont=n,
    instance=instance,
  }
  if fontdata then
    for k,v in next,fontdata.glyphs do
      v.class=nil
      v.index=nil
      v.math=nil
    end
  end
  return fontdata and {
    filename=filename,
    format=fontdata.format,
    glyphs=fontdata.glyphs,
    units=fontdata.fontheader.units,
  } or {
    filename=filename,
    format="unknown",
    glyphs={},
    units=0,
  }
end
function readers.loadfont(filename,n,instance)
  local fontdata=loadfont {
    filename=filename,
    glyphs=true,
    shapes=false,
    lookups=true,
    variable=true,
    subfont=n,
    instance=instance,
  }
  if fontdata then
    return {
      tableversion=tableversion,
      creator="context mkiv",
      size=fontdata.filesize,
      time=fontdata.filetime,
      glyphs=fontdata.glyphs,
      descriptions=fontdata.descriptions,
      format=fontdata.format,
      goodies={},
      metadata=getinfo(fontdata,n,false,false,true,true),
      properties={
        hasitalics=fontdata.hasitalics or false,
        maxcolorclass=fontdata.maxcolorclass,
        hascolor=fontdata.hascolor or false,
        instance=fontdata.instance,
        factors=fontdata.factors,
      },
      resources={
        filename=filename,
        private=privateoffset,
        duplicates=fontdata.duplicates or {},
        features=fontdata.features  or {},
        sublookups=fontdata.sublookups or {},
        marks=fontdata.marks    or {},
        markclasses=fontdata.markclasses or {},
        marksets=fontdata.marksets  or {},
        sequences=fontdata.sequences  or {},
        variants=fontdata.variants,
        version=getname(fontdata,"version"),
        cidinfo=fontdata.cidinfo,
        mathconstants=fontdata.mathconstants,
        colorpalettes=fontdata.colorpalettes,
        svgshapes=fontdata.svgshapes,
        sbixshapes=fontdata.sbixshapes,
        variabledata=fontdata.variabledata,
        foundtables=fontdata.foundtables,
      },
    }
  end
end
function readers.getinfo(filename,specification)
  local subfont=nil
  local platformnames=false
  local rawfamilynames=false
  local instancenames=true
  if type(specification)=="table" then
    subfont=tonumber(specification.subfont)
    platformnames=specification.platformnames
    rawfamilynames=specification.rawfamilynames
  else
    subfont=tonumber(specification)
  end
  local fontdata=loadfont {
    filename=filename,
    details=true,
    platformnames=platformnames,
    instancenames=true,
  }
  if fontdata then
    local subfonts=fontdata.subfonts
    if not subfonts then
      return getinfo(fontdata,nil,platformnames,rawfamilynames,false,instancenames)
    elseif not subfont then
      local info={}
      for i=1,#subfonts do
        info[i]=getinfo(fontdata,i,platformnames,rawfamilynames,false,instancenames)
      end
      return info
    elseif subfont>=1 and subfont<=#subfonts then
      return getinfo(fontdata,subfont,platformnames,rawfamilynames,false,instancenames)
    else
      return {
        filename=filename,
        comment="there is no subfont "..subfont.." in this file"
      }
    end
  else
    return {
      filename=filename,
      comment="the file cannot be opened for reading",
    }
  end
end
function readers.rehash(fontdata,hashmethod)
  report("the %a helper is not yet implemented","rehash")
end
function readers.checkhash(fontdata)
  report("the %a helper is not yet implemented","checkhash")
end
function readers.pack(fontdata,hashmethod)
  report("the %a helper is not yet implemented","pack")
end
function readers.unpack(fontdata)
  report("the %a helper is not yet implemented","unpack")
end
function readers.expand(fontdata)
  report("the %a helper is not yet implemented","unpack")
end
function readers.compact(fontdata)
  report("the %a helper is not yet implemented","compact")
end
local extenders={}
function readers.registerextender(extender)
  extenders[#extenders+1]=extender
end
function readers.extend(fontdata)
  for i=1,#extenders do
    local extender=extenders[i]
    local name=extender.name or "unknown"
    local action=extender.action
    if action then
      action(fontdata)
    end
  end
end

end --- [luaotfload, fontloader-2018-10-08.lua scope for “font-otr”] ---


do  --- [luaotfload, fontloader-2018-10-08.lua scope for “font-oti” 309a75f9c14b77d87e94eba827dc4e71] ---

if not modules then modules={} end modules ['font-oti']={
  version=1.001,
  comment="companion to font-ini.mkiv",
  author="Hans Hagen, PRAGMA-ADE, Hasselt NL",
  copyright="PRAGMA ADE / ConTeXt Development Team",
  license="see context related readme files"
}
local lower=string.lower
local fonts=fonts
local constructors=fonts.constructors
local otf=constructors.handlers.otf
local otffeatures=constructors.features.otf
local registerotffeature=otffeatures.register
local otftables=otf.tables or {}
otf.tables=otftables
local allocate=utilities.storage.allocate
registerotffeature {
  name="features",
  description="initialization of feature handler",
  default=true,
}
local function setmode(tfmdata,value)
  if value then
    tfmdata.properties.mode=lower(value)
  end
end
otf.modeinitializer=setmode
local function setlanguage(tfmdata,value)
  if value then
    local cleanvalue=lower(value)
    local languages=otftables and otftables.languages
    local properties=tfmdata.properties
    if not languages then
      properties.language=cleanvalue
    elseif languages[value] then
      properties.language=cleanvalue
    else
      properties.language="dflt"
    end
  end
end
local function setscript(tfmdata,value)
  if value then
    local cleanvalue=lower(value)
    local scripts=otftables and otftables.scripts
    local properties=tfmdata.properties
    if not scripts then
      properties.script=cleanvalue
    elseif scripts[value] then
      properties.script=cleanvalue
    else
      properties.script="dflt"
    end
  end
end
registerotffeature {
  name="mode",
  description="mode",
  initializers={
    base=setmode,
    node=setmode,
    plug=setmode,
  }
}
registerotffeature {
  name="language",
  description="language",
  initializers={
    base=setlanguage,
    node=setlanguage,
    plug=setlanguage,
  }
}
registerotffeature {
  name="script",
  description="script",
  initializers={
    base=setscript,
    node=setscript,
    plug=setscript,
  }
}
otftables.featuretypes=allocate {
  gpos_single="position",
  gpos_pair="position",
  gpos_cursive="position",
  gpos_mark2base="position",
  gpos_mark2ligature="position",
  gpos_mark2mark="position",
  gpos_context="position",
  gpos_contextchain="position",
  gsub_single="substitution",
  gsub_multiple="substitution",
  gsub_alternate="substitution",
  gsub_ligature="substitution",
  gsub_context="substitution",
  gsub_contextchain="substitution",
  gsub_reversecontextchain="substitution",
  gsub_reversesub="substitution",
}
function otffeatures.checkeddefaultscript(featuretype,autoscript,scripts)
  if featuretype=="position" then
    local default=scripts.dflt
    if default then
      if autoscript=="position" or autoscript==true then
        return default
      else
        report_otf("script feature %s not applied, enable default positioning")
      end
    else
    end
  elseif featuretype=="substitution" then
    local default=scripts.dflt
    if default then
      if autoscript=="substitution" or autoscript==true then
        return default
      end
    end
  end
end
function otffeatures.checkeddefaultlanguage(featuretype,autolanguage,languages)
  if featuretype=="position" then
    local default=languages.dflt
    if default then
      if autolanguage=="position" or autolanguage==true then
        return default
      else
        report_otf("language feature %s not applied, enable default positioning")
      end
    else
    end
  elseif featuretype=="substitution" then
    local default=languages.dflt
    if default then
      if autolanguage=="substitution" or autolanguage==true then
        return default
      end
    end
  end
end

end --- [luaotfload, fontloader-2018-10-08.lua scope for “font-oti”] ---


do  --- [luaotfload, fontloader-2018-10-08.lua scope for “font-ott” b20ddcf6360a2e35e79b7bdad0289a19] ---

if not modules then modules={} end modules ["font-ott"]={
  version=1.001,
  comment="companion to font-ini.mkiv",
  author="Hans Hagen, PRAGMA-ADE, Hasselt NL",
  copyright="PRAGMA ADE / ConTeXt Development Team",
  license="see context related readme files",
}
local type,next,tonumber,tostring,rawget,rawset=type,next,tonumber,tostring,rawget,rawset
local gsub,lower,format,match,gmatch,find=string.gsub,string.lower,string.format,string.match,string.gmatch,string.find
local sequenced=table.sequenced
local is_boolean=string.is_boolean
local setmetatableindex=table.setmetatableindex
local setmetatablenewindex=table.setmetatablenewindex
local allocate=utilities.storage.allocate
local fonts=fonts
local otf=fonts.handlers.otf
local otffeatures=otf.features
local tables=otf.tables or {}
otf.tables=tables
local statistics=otf.statistics or {}
otf.statistics=statistics
local scripts=allocate {
  ["arab"]="arabic",
  ["armi"]="imperial aramaic",
  ["armn"]="armenian",
  ["avst"]="avestan",
  ["bali"]="balinese",
  ["bamu"]="bamum",
  ["batk"]="batak",
  ["beng"]="bengali",
  ["bng2"]="bengali variant 2",
  ["bopo"]="bopomofo",
  ["brah"]="brahmi",
  ["brai"]="braille",
  ["bugi"]="buginese",
  ["buhd"]="buhid",
  ["byzm"]="byzantine music",
  ["cakm"]="chakma",
  ["cans"]="canadian syllabics",
  ["cari"]="carian",
  ["cham"]="cham",
  ["cher"]="cherokee",
  ["copt"]="coptic",
  ["cprt"]="cypriot syllabary",
  ["cyrl"]="cyrillic",
  ["deva"]="devanagari",
  ["dev2"]="devanagari variant 2",
  ["dsrt"]="deseret",
  ["egyp"]="egyptian heiroglyphs",
  ["ethi"]="ethiopic",
  ["geor"]="georgian",
  ["glag"]="glagolitic",
  ["goth"]="gothic",
  ["grek"]="greek",
  ["gujr"]="gujarati",
  ["gjr2"]="gujarati variant 2",
  ["guru"]="gurmukhi",
  ["gur2"]="gurmukhi variant 2",
  ["hang"]="hangul",
  ["hani"]="cjk ideographic",
  ["hano"]="hanunoo",
  ["hebr"]="hebrew",
  ["ital"]="old italic",
  ["jamo"]="hangul jamo",
  ["java"]="javanese",
  ["kali"]="kayah li",
  ["kana"]="hiragana and katakana",
  ["khar"]="kharosthi",
  ["khmr"]="khmer",
  ["knda"]="kannada",
  ["knd2"]="kannada variant 2",
  ["kthi"]="kaithi",
  ["lana"]="tai tham",
  ["lao" ]="lao",
  ["latn"]="latin",
  ["lepc"]="lepcha",
  ["limb"]="limbu",
  ["linb"]="linear b",
  ["lisu"]="lisu",
  ["lyci"]="lycian",
  ["lydi"]="lydian",
  ["mand"]="mandaic and mandaean",
  ["math"]="mathematical alphanumeric symbols",
  ["merc"]="meroitic cursive",
  ["mero"]="meroitic hieroglyphs",
  ["mlym"]="malayalam",
  ["mlm2"]="malayalam variant 2",
  ["mong"]="mongolian",
  ["mtei"]="meitei Mayek",
  ["musc"]="musical symbols",
  ["mym2"]="myanmar variant 2",
  ["mymr"]="myanmar",
  ["nko" ]='n"ko',
  ["ogam"]="ogham",
  ["olck"]="ol chiki",
  ["orkh"]="old turkic and orkhon runic",
  ["orya"]="oriya",
  ["ory2"]="odia variant 2",
  ["osma"]="osmanya",
  ["phag"]="phags-pa",
  ["phli"]="inscriptional pahlavi",
  ["phnx"]="phoenician",
  ["prti"]="inscriptional parthian",
  ["rjng"]="rejang",
  ["runr"]="runic",
  ["samr"]="samaritan",
  ["sarb"]="old south arabian",
  ["saur"]="saurashtra",
  ["shaw"]="shavian",
  ["shrd"]="sharada",
  ["sinh"]="sinhala",
  ["sora"]="sora sompeng",
  ["sund"]="sundanese",
  ["sylo"]="syloti nagri",
  ["syrc"]="syriac",
  ["tagb"]="tagbanwa",
  ["takr"]="takri",
  ["tale"]="tai le",
  ["talu"]="tai lu",
  ["taml"]="tamil",
  ["tavt"]="tai viet",
  ["telu"]="telugu",
  ["tel2"]="telugu variant 2",
  ["tfng"]="tifinagh",
  ["tglg"]="tagalog",
  ["thaa"]="thaana",
  ["thai"]="thai",
  ["tibt"]="tibetan",
  ["tml2"]="tamil variant 2",
  ["ugar"]="ugaritic cuneiform",
  ["vai" ]="vai",
  ["xpeo"]="old persian cuneiform",
  ["xsux"]="sumero-akkadian cuneiform",
  ["yi" ]="yi",
}
local languages=allocate {
  ["aba" ]="abaza",
  ["abk" ]="abkhazian",
  ["ach" ]="acholi",
  ["acr" ]="achi",
  ["ady" ]="adyghe",
  ["afk" ]="afrikaans",
  ["afr" ]="afar",
  ["agw" ]="agaw",
  ["aio" ]="aiton",
  ["aka" ]="akan",
  ["als" ]="alsatian",
  ["alt" ]="altai",
  ["amh" ]="amharic",
  ["ang" ]="anglo-saxon",
  ["apph"]="phonetic transcription—americanist conventions",
  ["ara" ]="arabic",
  ["arg" ]="aragonese",
  ["ari" ]="aari",
  ["ark" ]="rakhine",
  ["asm" ]="assamese",
  ["ast" ]="asturian",
  ["ath" ]="athapaskan",
  ["avr" ]="avar",
  ["awa" ]="awadhi",
  ["aym" ]="aymara",
  ["azb" ]="torki",
  ["aze" ]="azerbaijani",
  ["bad" ]="badaga",
  ["bad0"]="banda",
  ["bag" ]="baghelkhandi",
  ["bal" ]="balkar",
  ["ban" ]="balinese",
  ["bar" ]="bavarian",
  ["bau" ]="baulé",
  ["bbc" ]="batak toba",
  ["bbr" ]="berber",
  ["bch" ]="bench",
  ["bcr" ]="bible cree",
  ["bdy" ]="bandjalang",
  ["bel" ]="belarussian",
  ["bem" ]="bemba",
  ["ben" ]="bengali",
  ["bgc" ]="haryanvi",
  ["bgq" ]="bagri",
  ["bgr" ]="bulgarian",
  ["bhi" ]="bhili",
  ["bho" ]="bhojpuri",
  ["bik" ]="bikol",
  ["bil" ]="bilen",
  ["bis" ]="bislama",
  ["bjj" ]="kanauji",
  ["bkf" ]="blackfoot",
  ["bli" ]="baluchi",
  ["blk" ]="pa'o karen",
  ["bln" ]="balante",
  ["blt" ]="balti",
  ["bmb" ]="bambara (bamanankan)",
  ["bml" ]="bamileke",
  ["bos" ]="bosnian",
  ["bpy" ]="bishnupriya manipuri",
  ["bre" ]="breton",
  ["brh" ]="brahui",
  ["bri" ]="braj bhasha",
  ["brm" ]="burmese",
  ["brx" ]="bodo",
  ["bsh" ]="bashkir",
  ["bti" ]="beti",
  ["bts" ]="batak simalungun",
  ["bug" ]="bugis",
  ["cak" ]="kaqchikel",
  ["cat" ]="catalan",
  ["cbk" ]="zamboanga chavacano",
  ["ceb" ]="cebuano",
  ["cgg" ]="chiga",
  ["cha" ]="chamorro",
  ["che" ]="chechen",
  ["chg" ]="chaha gurage",
  ["chh" ]="chattisgarhi",
  ["chi" ]="chichewa (chewa, nyanja)",
  ["chk" ]="chukchi",
  ["chk0"]="chuukese",
  ["cho" ]="choctaw",
  ["chp" ]="chipewyan",
  ["chr" ]="cherokee",
  ["chu" ]="chuvash",
  ["chy" ]="cheyenne",
  ["cmr" ]="comorian",
  ["cop" ]="coptic",
  ["cor" ]="cornish",
  ["cos" ]="corsican",
  ["cpp" ]="creoles",
  ["cre" ]="cree",
  ["crr" ]="carrier",
  ["crt" ]="crimean tatar",
  ["csb" ]="kashubian",
  ["csl" ]="church slavonic",
  ["csy" ]="czech",
  ["ctg" ]="chittagonian",
  ["cuk" ]="san blas kuna",
  ["dan" ]="danish",
  ["dar" ]="dargwa",
  ["dax" ]="dayi",
  ["dcr" ]="woods cree",
  ["deu" ]="german",
  ["dgo" ]="dogri",
  ["dgr" ]="dogri",
  ["dhg" ]="dhangu",
  ["dhv" ]="divehi (dhivehi, maldivian)",
  ["diq" ]="dimli",
  ["div" ]="divehi (dhivehi, maldivian)",
  ["djr" ]="zarma",
  ["djr0"]="djambarrpuyngu",
  ["dng" ]="dangme",
  ["dnj" ]="dan",
  ["dnk" ]="dinka",
  ["dri" ]="dari",
  ["duj" ]="dhuwal",
  ["dun" ]="dungan",
  ["dzn" ]="dzongkha",
  ["ebi" ]="ebira",
  ["ecr" ]="eastern cree",
  ["edo" ]="edo",
  ["efi" ]="efik",
  ["ell" ]="greek",
  ["emk" ]="eastern maninkakan",
  ["eng" ]="english",
  ["erz" ]="erzya",
  ["esp" ]="spanish",
  ["esu" ]="central yupik",
  ["eti" ]="estonian",
  ["euq" ]="basque",
  ["evk" ]="evenki",
  ["evn" ]="even",
  ["ewe" ]="ewe",
  ["fan" ]="french antillean",
  ["fan0"]=" fang",
  ["far" ]="persian",
  ["fat" ]="fanti",
  ["fin" ]="finnish",
  ["fji" ]="fijian",
  ["fle" ]="dutch (flemish)",
  ["fne" ]="forest nenets",
  ["fon" ]="fon",
  ["fos" ]="faroese",
  ["fra" ]="french",
  ["frc" ]="cajun french",
  ["fri" ]="frisian",
  ["frl" ]="friulian",
  ["frp" ]="arpitan",
  ["fta" ]="futa",
  ["ful" ]="fulah",
  ["fuv" ]="nigerian fulfulde",
  ["gad" ]="ga",
  ["gae" ]="scottish gaelic (gaelic)",
  ["gag" ]="gagauz",
  ["gal" ]="galician",
  ["gar" ]="garshuni",
  ["gaw" ]="garhwali",
  ["gez" ]="ge'ez",
  ["gih" ]="githabul",
  ["gil" ]="gilyak",
  ["gil0"]="kiribati (gilbertese)",
  ["gkp" ]="kpelle (guinea)",
  ["glk" ]="gilaki",
  ["gmz" ]="gumuz",
  ["gnn" ]="gumatj",
  ["gog" ]="gogo",
  ["gon" ]="gondi",
  ["grn" ]="greenlandic",
  ["gro" ]="garo",
  ["gua" ]="guarani",
  ["guc" ]="wayuu",
  ["guf" ]="gupapuyngu",
  ["guj" ]="gujarati",
  ["guz" ]="gusii",
  ["hai" ]="haitian (haitian creole)",
  ["hal" ]="halam",
  ["har" ]="harauti",
  ["hau" ]="hausa",
  ["haw" ]="hawaiian",
  ["hay" ]="haya",
  ["haz" ]="hazaragi",
  ["hbn" ]="hammer-banna",
  ["her" ]="herero",
  ["hil" ]="hiligaynon",
  ["hin" ]="hindi",
  ["hma" ]="high mari",
  ["hmn" ]="hmong",
  ["hmo" ]="hiri motu",
  ["hnd" ]="hindko",
  ["ho" ]="ho",
  ["hri" ]="harari",
  ["hrv" ]="croatian",
  ["hun" ]="hungarian",
  ["hye" ]="armenian",
  ["hye0"]="armenian east",
  ["iba" ]="iban",
  ["ibb" ]="ibibio",
  ["ibo" ]="igbo",
  ["ido" ]="ido",
  ["ijo" ]="ijo languages",
  ["ile" ]="interlingue",
  ["ilo" ]="ilokano",
  ["ina" ]="interlingua",
  ["ind" ]="indonesian",
  ["ing" ]="ingush",
  ["inu" ]="inuktitut",
  ["ipk" ]="inupiat",
  ["ipph"]="phonetic transcription—ipa conventions",
  ["iri" ]="irish",
  ["irt" ]="irish traditional",
  ["isl" ]="icelandic",
  ["ism" ]="inari sami",
  ["ita" ]="italian",
  ["iwr" ]="hebrew",
  ["jam" ]="jamaican creole",
  ["jan" ]="japanese",
  ["jav" ]="javanese",
  ["jbo" ]="lojban",
  ["jii" ]="yiddish",
  ["jud" ]="ladino",
  ["jul" ]="jula",
  ["kab" ]="kabardian",
  ["kab0"]="kabyle",
  ["kac" ]="kachchi",
  ["kal" ]="kalenjin",
  ["kan" ]="kannada",
  ["kar" ]="karachay",
  ["kat" ]="georgian",
  ["kaz" ]="kazakh",
  ["kde" ]="makonde",
  ["kea" ]="kabuverdianu (crioulo)",
  ["keb" ]="kebena",
  ["kek" ]="kekchi",
  ["kge" ]="khutsuri georgian",
  ["kha" ]="khakass",
  ["khk" ]="khanty-kazim",
  ["khm" ]="khmer",
  ["khs" ]="khanty-shurishkar",
  ["kht" ]="khamti shan",
  ["khv" ]="khanty-vakhi",
  ["khw" ]="khowar",
  ["kik" ]="kikuyu (gikuyu)",
  ["kir" ]="kirghiz (kyrgyz)",
  ["kis" ]="kisii",
  ["kiu" ]="kirmanjki",
  ["kjd" ]="southern kiwai",
  ["kjp" ]="eastern pwo karen",
  ["kjz" ]="bumthangkha",
  ["kkn" ]="kokni",
  ["klm" ]="kalmyk",
  ["kmb" ]="kamba",
  ["kmn" ]="kumaoni",
  ["kmo" ]="komo",
  ["kms" ]="komso",
  ["knr" ]="kanuri",
  ["kod" ]="kodagu",
  ["koh" ]="korean old hangul",
  ["kok" ]="konkani",
  ["kom" ]="komi",
  ["kon" ]="kikongo",
  ["kon0"]="kongo",
  ["kop" ]="komi-permyak",
  ["kor" ]="korean",
  ["kos" ]="kosraean",
  ["koz" ]="komi-zyrian",
  ["kpl" ]="kpelle",
  ["kri" ]="krio",
  ["krk" ]="karakalpak",
  ["krl" ]="karelian",
  ["krm" ]="karaim",
  ["krn" ]="karen",
  ["krt" ]="koorete",
  ["ksh" ]="kashmiri",
  ["ksh0"]="ripuarian",
  ["ksi" ]="khasi",
  ["ksm" ]="kildin sami",
  ["ksw" ]="s’gaw karen",
  ["kua" ]="kuanyama",
  ["kui" ]="kui",
  ["kul" ]="kulvi",
  ["kum" ]="kumyk",
  ["kur" ]="kurdish",
  ["kuu" ]="kurukh",
  ["kuy" ]="kuy",
  ["kyk" ]="koryak",
  ["kyu" ]="western kayah",
  ["lad" ]="ladin",
  ["lah" ]="lahuli",
  ["lak" ]="lak",
  ["lam" ]="lambani",
  ["lao" ]="lao",
  ["lat" ]="latin",
  ["laz" ]="laz",
  ["lcr" ]="l-cree",
  ["ldk" ]="ladakhi",
  ["lez" ]="lezgi",
  ["lij" ]="ligurian",
  ["lim" ]="limburgish",
  ["lin" ]="lingala",
  ["lis" ]="lisu",
  ["ljp" ]="lampung",
  ["lki" ]="laki",
  ["lma" ]="low mari",
  ["lmb" ]="limbu",
  ["lmo" ]="lombard",
  ["lmw" ]="lomwe",
  ["lom" ]="loma",
  ["lrc" ]="luri",
  ["lsb" ]="lower sorbian",
  ["lsm" ]="lule sami",
  ["lth" ]="lithuanian",
  ["ltz" ]="luxembourgish",
  ["lua" ]="luba-lulua",
  ["lub" ]="luba-katanga",
  ["lug" ]="ganda",
  ["luh" ]="luyia",
  ["luo" ]="luo",
  ["lvi" ]="latvian",
  ["mad" ]="madura",
  ["mag" ]="magahi",
  ["mah" ]="marshallese",
  ["maj" ]="majang",
  ["mak" ]="makhuwa",
  ["mal" ]="malayalam reformed",
  ["mam" ]="mam",
  ["man" ]="mansi",
  ["map" ]="mapudungun",
  ["mar" ]="marathi",
  ["maw" ]="marwari",
  ["mbn" ]="mbundu",
  ["mch" ]="manchu",
  ["mcr" ]="moose cree",
  ["mde" ]="mende",
  ["mdr" ]="mandar",
  ["men" ]="me'en",
  ["mer" ]="meru",
  ["mfa" ]="pattani malay",
  ["mfe" ]="morisyen",
  ["min" ]="minangkabau",
  ["miz" ]="mizo",
  ["mkd" ]="macedonian",
  ["mkr" ]="makasar",
  ["mkw" ]="kituba",
  ["mle" ]="male",
  ["mlg" ]="malagasy",
  ["mln" ]="malinke",
  ["mly" ]="malay",
  ["mnd" ]="mandinka",
  ["mng" ]="mongolian",
  ["mni" ]="manipuri",
  ["mnk" ]="maninka",
  ["mnx" ]="manx",
  ["moh" ]="mohawk",
  ["mok" ]="moksha",
  ["mol" ]="moldavian",
  ["mon" ]="mon",
  ["mor" ]="moroccan",
  ["mos" ]="mossi",
  ["mri" ]="maori",
  ["mth" ]="maithili",
  ["mts" ]="maltese",
  ["mun" ]="mundari",
  ["mus" ]="muscogee",
  ["mwl" ]="mirandese",
  ["mww" ]="hmong daw",
  ["myn" ]="mayan",
  ["mzn" ]="mazanderani",
  ["nag" ]="naga-assamese",
  ["nah" ]="nahuatl",
  ["nan" ]="nanai",
  ["nap" ]="neapolitan",
  ["nas" ]="naskapi",
  ["nau" ]="nauruan",
  ["nav" ]="navajo",
  ["ncr" ]="n-cree",
  ["ndb" ]="ndebele",
  ["ndc" ]="ndau",
  ["ndg" ]="ndonga",
  ["nds" ]="low saxon",
  ["nep" ]="nepali",
  ["new" ]="newari",
  ["nga" ]="ngbaka",
  ["ngr" ]="nagari",
  ["nhc" ]="norway house cree",
  ["nis" ]="nisi",
  ["niu" ]="niuean",
  ["nkl" ]="nyankole",
  ["nko" ]="n'ko",
  ["nld" ]="dutch",
  ["noe" ]="nimadi",
  ["nog" ]="nogai",
  ["nor" ]="norwegian",
  ["nov" ]="novial",
  ["nsm" ]="northern sami",
  ["nso" ]="sotho, northern",
  ["nta" ]="northern tai",
  ["nto" ]="esperanto",
  ["nym" ]="nyamwezi",
  ["nyn" ]="norwegian nynorsk",
  ["oci" ]="occitan",
  ["ocr" ]="oji-cree",
  ["ojb" ]="ojibway",
  ["ori" ]="odia",
  ["oro" ]="oromo",
  ["oss" ]="ossetian",
  ["paa" ]="palestinian aramaic",
  ["pag" ]="pangasinan",
  ["pal" ]="pali",
  ["pam" ]="pampangan",
  ["pan" ]="punjabi",
  ["pap" ]="palpa",
  ["pap0"]="papiamentu",
  ["pas" ]="pashto",
  ["pau" ]="palauan",
  ["pcc" ]="bouyei",
  ["pcd" ]="picard",
  ["pdc" ]="pennsylvania german",
  ["pgr" ]="polytonic greek",
  ["phk" ]="phake",
  ["pih" ]="norfolk",
  ["pil" ]="filipino",
  ["plg" ]="palaung",
  ["plk" ]="polish",
  ["pms" ]="piemontese",
  ["pnb" ]="western panjabi",
  ["poh" ]="pocomchi",
  ["pon" ]="pohnpeian",
  ["pro" ]="provencal",
  ["ptg" ]="portuguese",
  ["pwo" ]="western pwo karen",
  ["qin" ]="chin",
  ["quc" ]="k’iche’",
  ["quh" ]="quechua (bolivia)",
  ["quz" ]="quechua",
  ["qvi" ]="quechua (ecuador)",
  ["qwh" ]="quechua (peru)",
  ["raj" ]="rajasthani",
  ["rar" ]="rarotongan",
  ["rbu" ]="russian buriat",
  ["rcr" ]="r-cree",
  ["rej" ]="rejang",
  ["ria" ]="riang",
  ["rif" ]="tarifit",
  ["rit" ]="ritarungo",
  ["rkw" ]="arakwal",
  ["rms" ]="romansh",
  ["rmy" ]="vlax romani",
  ["rom" ]="romanian",
  ["roy" ]="romany",
  ["rsy" ]="rusyn",
  ["rtm" ]="rotuman",
  ["rua" ]="kinyarwanda",
  ["run" ]="rundi",
  ["rup" ]="aromanian",
  ["rus" ]="russian",
  ["sad" ]="sadri",
  ["san" ]="sanskrit",
  ["sas" ]="sasak",
  ["sat" ]="santali",
  ["say" ]="sayisi",
  ["scn" ]="sicilian",
  ["sco" ]="scots",
  ["sek" ]="sekota",
  ["sel" ]="selkup",
  ["sga" ]="old irish",
  ["sgo" ]="sango",
  ["sgs" ]="samogitian",
  ["shi" ]="tachelhit",
  ["shn" ]="shan",
  ["sib" ]="sibe",
  ["sid" ]="sidamo",
  ["sig" ]="silte gurage",
  ["sks" ]="skolt sami",
  ["sky" ]="slovak",
  ["sla" ]="slavey",
  ["slv" ]="slovenian",
  ["sml" ]="somali",
  ["smo" ]="samoan",
  ["sna" ]="sena",
  ["sna0"]="shona",
  ["snd" ]="sindhi",
  ["snh" ]="sinhala (sinhalese)",
  ["snk" ]="soninke",
  ["sog" ]="sodo gurage",
  ["sop" ]="songe",
  ["sot" ]="sotho, southern",
  ["sqi" ]="albanian",
  ["srb" ]="serbian",
  ["srd" ]="sardinian",
  ["srk" ]="saraiki",
  ["srr" ]="serer",
  ["ssl" ]="south slavey",
  ["ssm" ]="southern sami",
  ["stq" ]="saterland frisian",
  ["suk" ]="sukuma",
  ["sun" ]="sundanese",
  ["sur" ]="suri",
  ["sva" ]="svan",
  ["sve" ]="swedish",
  ["swa" ]="swadaya aramaic",
  ["swk" ]="swahili",
  ["swz" ]="swati",
  ["sxt" ]="sutu",
  ["sxu" ]="upper saxon",
  ["syl" ]="sylheti",
  ["syr" ]="syriac",
  ["szl" ]="silesian",
  ["tab" ]="tabasaran",
  ["taj" ]="tajiki",
  ["tam" ]="tamil",
  ["tat" ]="tatar",
  ["tcr" ]="th-cree",
  ["tdd" ]="dehong dai",
  ["tel" ]="telugu",
  ["tet" ]="tetum",
  ["tgl" ]="tagalog",
  ["tgn" ]="tongan",
  ["tgr" ]="tigre",
  ["tgy" ]="tigrinya",
  ["tha" ]="thai",
  ["tht" ]="tahitian",
  ["tib" ]="tibetan",
  ["tiv" ]="tiv",
  ["tkm" ]="turkmen",
  ["tmh" ]="tamashek",
  ["tmn" ]="temne",
  ["tna" ]="tswana",
  ["tne" ]="tundra nenets",
  ["tng" ]="tonga",
  ["tod" ]="todo",
  ["tod0"]="toma",
  ["tpi" ]="tok pisin",
  ["trk" ]="turkish",
  ["tsg" ]="tsonga",
  ["tsj" ]="tshangla",
  ["tua" ]="turoyo aramaic",
  ["tul" ]="tulu",
  ["tuv" ]="tuvin",
  ["tvl" ]="tuvalu",
  ["twi" ]="twi",
  ["tyz" ]="tày",
  ["tzm" ]="tamazight",
  ["tzo" ]="tzotzil",
  ["udm" ]="udmurt",
  ["ukr" ]="ukrainian",
  ["umb" ]="umbundu",
  ["urd" ]="urdu",
  ["usb" ]="upper sorbian",
  ["uyg" ]="uyghur",
  ["uzb" ]="uzbek",
  ["vec" ]="venetian",
  ["ven" ]="venda",
  ["vit" ]="vietnamese",
  ["vol" ]="volapük",
  ["vro" ]="võro",
  ["wa" ]="wa",
  ["wag" ]="wagdi",
  ["war" ]="waray-waray",
  ["wcr" ]="west-cree",
  ["wel" ]="welsh",
  ["wlf" ]="wolof",
  ["wln" ]="walloon",
  ["xbd" ]="lü",
  ["xhs" ]="xhosa",
  ["xjb" ]="minjangbal",
  ["xkf" ]="khengkha",
  ["xog" ]="soga",
  ["xpe" ]="kpelle (liberia)",
  ["yak" ]="sakha",
  ["yao" ]="yao",
  ["yap" ]="yapese",
  ["yba" ]="yoruba",
  ["ycr" ]="y-cree",
  ["yic" ]="yi classic",
  ["yim" ]="yi modern",
  ["zea" ]="zealandic",
  ["zgh" ]="standard morrocan tamazigh",
  ["zha" ]="zhuang",
  ["zhh" ]="chinese, hong kong sar",
  ["zhp" ]="chinese phonetic",
  ["zhs" ]="chinese simplified",
  ["zht" ]="chinese traditional",
  ["znd" ]="zande",
  ["zul" ]="zulu",
  ["zza" ]="zazaki",
}
local features=allocate {
  ["aalt"]="access all alternates",
  ["abvf"]="above-base forms",
  ["abvm"]="above-base mark positioning",
  ["abvs"]="above-base substitutions",
  ["afrc"]="alternative fractions",
  ["akhn"]="akhands",
  ["blwf"]="below-base forms",
  ["blwm"]="below-base mark positioning",
  ["blws"]="below-base substitutions",
  ["c2pc"]="petite capitals from capitals",
  ["c2sc"]="small capitals from capitals",
  ["calt"]="contextual alternates",
  ["case"]="case-sensitive forms",
  ["ccmp"]="glyph composition/decomposition",
  ["cfar"]="conjunct form after ro",
  ["cjct"]="conjunct forms",
  ["clig"]="contextual ligatures",
  ["cpct"]="centered cjk punctuation",
  ["cpsp"]="capital spacing",
  ["cswh"]="contextual swash",
  ["curs"]="cursive positioning",
  ["dflt"]="default processing",
  ["dist"]="distances",
  ["dlig"]="discretionary ligatures",
  ["dnom"]="denominators",
  ["dtls"]="dotless forms",
  ["expt"]="expert forms",
  ["falt"]="final glyph alternates",
  ["fin2"]="terminal forms #2",
  ["fin3"]="terminal forms #3",
  ["fina"]="terminal forms",
  ["flac"]="flattened accents over capitals",
  ["frac"]="fractions",
  ["fwid"]="full width",
  ["half"]="half forms",
  ["haln"]="halant forms",
  ["halt"]="alternate half width",
  ["hist"]="historical forms",
  ["hkna"]="horizontal kana alternates",
  ["hlig"]="historical ligatures",
  ["hngl"]="hangul",
  ["hojo"]="hojo kanji forms",
  ["hwid"]="half width",
  ["init"]="initial forms",
  ["isol"]="isolated forms",
  ["ital"]="italics",
  ["jalt"]="justification alternatives",
  ["jp04"]="jis2004 forms",
  ["jp78"]="jis78 forms",
  ["jp83"]="jis83 forms",
  ["jp90"]="jis90 forms",
  ["kern"]="kerning",
  ["lfbd"]="left bounds",
  ["liga"]="standard ligatures",
  ["ljmo"]="leading jamo forms",
  ["lnum"]="lining figures",
  ["locl"]="localized forms",
  ["ltra"]="left-to-right alternates",
  ["ltrm"]="left-to-right mirrored forms",
  ["mark"]="mark positioning",
  ["med2"]="medial forms #2",
  ["medi"]="medial forms",
  ["mgrk"]="mathematical greek",
  ["mkmk"]="mark to mark positioning",
  ["mset"]="mark positioning via substitution",
  ["nalt"]="alternate annotation forms",
  ["nlck"]="nlc kanji forms",
  ["nukt"]="nukta forms",
  ["numr"]="numerators",
  ["onum"]="old style figures",
  ["opbd"]="optical bounds",
  ["ordn"]="ordinals",
  ["ornm"]="ornaments",
  ["palt"]="proportional alternate width",
  ["pcap"]="petite capitals",
  ["pkna"]="proportional kana",
  ["pnum"]="proportional figures",
  ["pref"]="pre-base forms",
  ["pres"]="pre-base substitutions",
  ["pstf"]="post-base forms",
  ["psts"]="post-base substitutions",
  ["pwid"]="proportional widths",
  ["qwid"]="quarter widths",
  ["rand"]="randomize",
  ["rclt"]="required contextual alternates",
  ["rkrf"]="rakar forms",
  ["rlig"]="required ligatures",
  ["rphf"]="reph form",
  ["rtbd"]="right bounds",
  ["rtla"]="right-to-left alternates",
  ["rtlm"]="right to left mirrored forms",
  ["rvrn"]="required variation alternates",
  ["ruby"]="ruby notation forms",
  ["salt"]="stylistic alternates",
  ["sinf"]="scientific inferiors",
  ["size"]="optical size",
  ["smcp"]="small capitals",
  ["smpl"]="simplified forms",
  ["ssty"]="script style",
  ["stch"]="stretching glyph decomposition",
  ["subs"]="subscript",
  ["sups"]="superscript",
  ["swsh"]="swash",
  ["titl"]="titling",
  ["tjmo"]="trailing jamo forms",
  ["tnam"]="traditional name forms",
  ["tnum"]="tabular figures",
  ["trad"]="traditional forms",
  ["twid"]="third widths",
  ["unic"]="unicase",
  ["valt"]="alternate vertical metrics",
  ["vatu"]="vattu variants",
  ["vert"]="vertical writing",
  ["vhal"]="alternate vertical half metrics",
  ["vjmo"]="vowel jamo forms",
  ["vkna"]="vertical kana alternates",
  ["vkrn"]="vertical kerning",
  ["vpal"]="proportional alternate vertical metrics",
  ["vrt2"]="vertical rotation",
  ["zero"]="slashed zero",
  ["trep"]="traditional tex replacements",
  ["tlig"]="traditional tex ligatures",
  ["ss.."]="stylistic set ..",
  ["cv.."]="character variant ..",
  ["js.."]="justification ..",
  ["dv.."]="devanagari ..",
  ["ml.."]="malayalam ..",
}
local baselines=allocate {
  ["hang"]="hanging baseline",
  ["icfb"]="ideographic character face bottom edge baseline",
  ["icft"]="ideographic character face tope edige baseline",
  ["ideo"]="ideographic em-box bottom edge baseline",
  ["idtp"]="ideographic em-box top edge baseline",
  ["math"]="mathematical centered baseline",
  ["romn"]="roman baseline"
}
tables.scripts=scripts
tables.languages=languages
tables.features=features
tables.baselines=baselines
local acceptscripts=true directives.register("otf.acceptscripts",function(v) acceptscripts=v end)
local acceptlanguages=true directives.register("otf.acceptlanguages",function(v) acceptlanguages=v end)
local report_checks=logs.reporter("fonts","checks")
if otffeatures.features then
  for k,v in next,otffeatures.features do
    features[k]=v
  end
  otffeatures.features=features
end
local function swapped(h)
  local r={}
  for k,v in next,h do
    r[gsub(v,"[^a-z0-9]","")]=k 
  end
  return r
end
local verbosescripts=allocate(swapped(scripts ))
local verboselanguages=allocate(swapped(languages))
local verbosefeatures=allocate(swapped(features ))
local verbosebaselines=allocate(swapped(baselines))
local function resolve(t,k)
  if k then
    k=gsub(lower(k),"[^a-z0-9]","")
    local v=rawget(t,k)
    if v then
      return v
    end
  end
end
setmetatableindex(verbosescripts,resolve)
setmetatableindex(verboselanguages,resolve)
setmetatableindex(verbosefeatures,resolve)
setmetatableindex(verbosebaselines,resolve)
setmetatableindex(scripts,function(t,k)
  if k then
    k=lower(k)
    if k=="dflt" then
      return k
    end
    local v=rawget(t,k)
    if v then
      return v
    end
    k=gsub(k," ","")
    v=rawget(t,v)
    if v then
      return v
    elseif acceptscripts then
      report_checks("registering extra script %a",k)
      rawset(t,k,k)
      return k
    end
  end
  return "dflt"
end)
setmetatableindex(languages,function(t,k)
  if k then
    k=lower(k)
    if k=="dflt" then
      return k
    end
    local v=rawget(t,k)
    if v then
      return v
    end
    k=gsub(k," ","")
    v=rawget(t,v)
    if v then
      return v
    elseif acceptlanguages then
      report_checks("registering extra language %a",k)
      rawset(t,k,k)
      return k
    end
  end
  return "dflt"
end)
if setmetatablenewindex then
  setmetatablenewindex(languages,"ignore")
  setmetatablenewindex(scripts,"ignore")
  setmetatablenewindex(baselines,"ignore")
end
local function resolve(t,k)
  if k then
    k=lower(k)
    local v=rawget(t,k)
    if v then
      return v
    end
    k=gsub(k," ","")
    local v=rawget(t,k)
    if v then
      return v
    end
    local tag,dd=match(k,"(..)(%d+)")
    if tag and dd then
      local v=rawget(t,tag)
      if v then
        return v 
      else
        local v=rawget(t,tag.."..") 
        if v then
          return (gsub(v,"%.%.",tonumber(dd))) 
        end
      end
    end
  end
  return k 
end
setmetatableindex(features,resolve)
local function assign(t,k,v)
  if k and v then
    v=lower(v)
    rawset(t,k,v)
  end
end
if setmetatablenewindex then
  setmetatablenewindex(features,assign)
end
local checkers={
  rand=function(v)
    return v==true and "random" or v
  end
}
if not storage then
  return
end
local usedfeatures=statistics.usedfeatures or {}
statistics.usedfeatures=usedfeatures
table.setmetatableindex(usedfeatures,function(t,k) if k then local v={} t[k]=v return v end end) 
storage.register("fonts/otf/usedfeatures",usedfeatures,"fonts.handlers.otf.statistics.usedfeatures" )
local normalizedaxis=otf.readers.helpers.normalizedaxis or function(s) return s end
function otffeatures.normalize(features)
  if features then
    local h={}
    for key,value in next,features do
      local k=lower(key)
      if k=="language" then
        local v=gsub(lower(value),"[^a-z0-9]","")
        h.language=rawget(verboselanguages,v) or (languages[v] and v) or "dflt" 
      elseif k=="script" then
        local v=gsub(lower(value),"[^a-z0-9]","")
        h.script=rawget(verbosescripts,v) or (scripts[v] and v) or "dflt" 
      elseif k=="axis" then
        h[k]=normalizedaxis(value)
        if not callbacks.supported.glyph_stream_provider then
          h.variableshapes=true 
        end
      else
        local uk=usedfeatures[key]
        local uv=uk[value]
        if uv then
        else
          uv=tonumber(value) 
          if uv then
          elseif type(value)=="string" then
            local b=is_boolean(value)
            if type(b)=="nil" then
              uv=lower(value)
            else
              uv=b
            end
          elseif type(value)=="table" then
            uv=sequenced(t,",")
          else
            uv=value
          end
          if not rawget(features,k) then
            k=rawget(verbosefeatures,k) or k
          end
          local c=checkers[k]
          if c then
            uv=c(uv) or vc
          end
          uk[value]=uv
        end
        h[k]=uv
      end
    end
    return h
  end
end

end --- [luaotfload, fontloader-2018-10-08.lua scope for “font-ott”] ---


do  --- [luaotfload, fontloader-2018-10-08.lua scope for “font-cff” 47d4b58d365b159d14fdb8264a415639] ---

if not modules then modules={} end modules ['font-cff']={
  version=1.001,
  comment="companion to font-ini.mkiv",
  author="Hans Hagen, PRAGMA-ADE, Hasselt NL",
  copyright="PRAGMA ADE / ConTeXt Development Team",
  license="see context related readme files"
}
local next,type,tonumber=next,type,tonumber
local byte,char,gmatch=string.byte,string.char,string.gmatch
local concat,remove,unpack=table.concat,table.remove,table.unpack
local floor,abs,round,ceil,min,max=math.floor,math.abs,math.round,math.ceil,math.min,math.max
local P,C,R,S,C,Cs,Ct=lpeg.P,lpeg.C,lpeg.R,lpeg.S,lpeg.C,lpeg.Cs,lpeg.Ct
local lpegmatch=lpeg.match
local formatters=string.formatters
local bytetable=string.bytetable
local readers=fonts.handlers.otf.readers
local streamreader=readers.streamreader
local readstring=streamreader.readstring
local readbyte=streamreader.readcardinal1 
local readushort=streamreader.readcardinal2 
local readuint=streamreader.readcardinal3 
local readulong=streamreader.readcardinal4 
local setposition=streamreader.setposition
local getposition=streamreader.getposition
local readbytetable=streamreader.readbytetable
directives.register("fonts.streamreader",function()
  streamreader=utilities.streams
  readstring=streamreader.readstring
  readbyte=streamreader.readcardinal1
  readushort=streamreader.readcardinal2
  readuint=streamreader.readcardinal3
  readulong=streamreader.readcardinal4
  setposition=streamreader.setposition
  getposition=streamreader.getposition
  readbytetable=streamreader.readbytetable
end)
local setmetatableindex=table.setmetatableindex
local trace_charstrings=false trackers.register("fonts.cff.charstrings",function(v) trace_charstrings=v end)
local report=logs.reporter("otf reader","cff")
local parsedictionaries
local parsecharstring
local parsecharstrings
local resetcharstrings
local parseprivates
local startparsing
local stopparsing
local defaultstrings={ [0]=
  ".notdef","space","exclam","quotedbl","numbersign","dollar","percent",
  "ampersand","quoteright","parenleft","parenright","asterisk","plus",
  "comma","hyphen","period","slash","zero","one","two","three","four",
  "five","six","seven","eight","nine","colon","semicolon","less",
  "equal","greater","question","at","A","B","C","D","E","F","G","H",
  "I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W",
  "X","Y","Z","bracketleft","backslash","bracketright","asciicircum",
  "underscore","quoteleft","a","b","c","d","e","f","g","h","i","j",
  "k","l","m","n","o","p","q","r","s","t","u","v","w","x","y",
  "z","braceleft","bar","braceright","asciitilde","exclamdown","cent",
  "sterling","fraction","yen","florin","section","currency",
  "quotesingle","quotedblleft","guillemotleft","guilsinglleft",
  "guilsinglright","fi","fl","endash","dagger","daggerdbl",
  "periodcentered","paragraph","bullet","quotesinglbase","quotedblbase",
  "quotedblright","guillemotright","ellipsis","perthousand","questiondown",
  "grave","acute","circumflex","tilde","macron","breve","dotaccent",
  "dieresis","ring","cedilla","hungarumlaut","ogonek","caron","emdash",
  "AE","ordfeminine","Lslash","Oslash","OE","ordmasculine","ae",
  "dotlessi","lslash","oslash","oe","germandbls","onesuperior",
  "logicalnot","mu","trademark","Eth","onehalf","plusminus","Thorn",
  "onequarter","divide","brokenbar","degree","thorn","threequarters",
  "twosuperior","registered","minus","eth","multiply","threesuperior",
  "copyright","Aacute","Acircumflex","Adieresis","Agrave","Aring",
  "Atilde","Ccedilla","Eacute","Ecircumflex","Edieresis","Egrave",
  "Iacute","Icircumflex","Idieresis","Igrave","Ntilde","Oacute",
  "Ocircumflex","Odieresis","Ograve","Otilde","Scaron","Uacute",
  "Ucircumflex","Udieresis","Ugrave","Yacute","Ydieresis","Zcaron",
  "aacute","acircumflex","adieresis","agrave","aring","atilde",
  "ccedilla","eacute","ecircumflex","edieresis","egrave","iacute",
  "icircumflex","idieresis","igrave","ntilde","oacute","ocircumflex",
  "odieresis","ograve","otilde","scaron","uacute","ucircumflex",
  "udieresis","ugrave","yacute","ydieresis","zcaron","exclamsmall",
  "Hungarumlautsmall","dollaroldstyle","dollarsuperior","ampersandsmall",
  "Acutesmall","parenleftsuperior","parenrightsuperior","twodotenleader",
  "onedotenleader","zerooldstyle","oneoldstyle","twooldstyle",
  "threeoldstyle","fouroldstyle","fiveoldstyle","sixoldstyle",
  "sevenoldstyle","eightoldstyle","nineoldstyle","commasuperior",
  "threequartersemdash","periodsuperior","questionsmall","asuperior",
  "bsuperior","centsuperior","dsuperior","esuperior","isuperior",
  "lsuperior","msuperior","nsuperior","osuperior","rsuperior","ssuperior",
  "tsuperior","ff","ffi","ffl","parenleftinferior","parenrightinferior",
  "Circumflexsmall","hyphensuperior","Gravesmall","Asmall","Bsmall",
  "Csmall","Dsmall","Esmall","Fsmall","Gsmall","Hsmall","Ismall",
  "Jsmall","Ksmall","Lsmall","Msmall","Nsmall","Osmall","Psmall",
  "Qsmall","Rsmall","Ssmall","Tsmall","Usmall","Vsmall","Wsmall",
  "Xsmall","Ysmall","Zsmall","colonmonetary","onefitted","rupiah",
  "Tildesmall","exclamdownsmall","centoldstyle","Lslashsmall",
  "Scaronsmall","Zcaronsmall","Dieresissmall","Brevesmall","Caronsmall",
  "Dotaccentsmall","Macronsmall","figuredash","hypheninferior",
  "Ogoneksmall","Ringsmall","Cedillasmall","questiondownsmall","oneeighth",
  "threeeighths","fiveeighths","seveneighths","onethird","twothirds",
  "zerosuperior","foursuperior","fivesuperior","sixsuperior",
  "sevensuperior","eightsuperior","ninesuperior","zeroinferior",
  "oneinferior","twoinferior","threeinferior","fourinferior",
  "fiveinferior","sixinferior","seveninferior","eightinferior",
  "nineinferior","centinferior","dollarinferior","periodinferior",
  "commainferior","Agravesmall","Aacutesmall","Acircumflexsmall",
  "Atildesmall","Adieresissmall","Aringsmall","AEsmall","Ccedillasmall",
  "Egravesmall","Eacutesmall","Ecircumflexsmall","Edieresissmall",
  "Igravesmall","Iacutesmall","Icircumflexsmall","Idieresissmall",
  "Ethsmall","Ntildesmall","Ogravesmall","Oacutesmall","Ocircumflexsmall",
  "Otildesmall","Odieresissmall","OEsmall","Oslashsmall","Ugravesmall",
  "Uacutesmall","Ucircumflexsmall","Udieresissmall","Yacutesmall",
  "Thornsmall","Ydieresissmall","001.000","001.001","001.002","001.003",
  "Black","Bold","Book","Light","Medium","Regular","Roman","Semibold",
}
local cffreaders={
  readbyte,
  readushort,
  readuint,
  readulong,
}
local function readheader(f)
  local offset=getposition(f)
  local major=readbyte(f)
  local header={
    offset=offset,
    major=major,
    minor=readbyte(f),
    size=readbyte(f),
  }
  if major==1 then
    header.dsize=readbyte(f)  
  elseif major==2 then
    header.dsize=readushort(f) 
  else
  end
  setposition(f,offset+header.size)
  return header
end
local function readlengths(f,longcount)
  local count=longcount and readulong(f) or readushort(f)
  if count==0 then
    return {}
  end
  local osize=readbyte(f)
  local read=cffreaders[osize]
  if not read then
    report("bad offset size: %i",osize)
    return {}
  end
  local lengths={}
  local previous=read(f)
  for i=1,count do
    local offset=read(f)
    local length=offset-previous
    if length<0 then
      report("bad offset: %i",length)
      length=0
    end
    lengths[i]=length
    previous=offset
  end
  return lengths
end
local function readfontnames(f)
  local names=readlengths(f)
  for i=1,#names do
    names[i]=readstring(f,names[i])
  end
  return names
end
local function readtopdictionaries(f)
  local dictionaries=readlengths(f)
  for i=1,#dictionaries do
    dictionaries[i]=readstring(f,dictionaries[i])
  end
  return dictionaries
end
local function readstrings(f)
  local lengths=readlengths(f)
  local strings=setmetatableindex({},defaultstrings)
  local index=#defaultstrings
  for i=1,#lengths do
    index=index+1
    strings[index]=readstring(f,lengths[i])
  end
  return strings
end
do
  local stack={}
  local top=0
  local result={}
  local strings={}
  local p_single=P("\00")/function()
      result.version=strings[stack[top]] or "unset"
      top=0
    end+P("\01")/function()
      result.notice=strings[stack[top]] or "unset"
      top=0
    end+P("\02")/function()
      result.fullname=strings[stack[top]] or "unset"
      top=0
    end+P("\03")/function()
      result.familyname=strings[stack[top]] or "unset"
      top=0
    end+P("\04")/function()
      result.weight=strings[stack[top]] or "unset"
      top=0
    end+P("\05")/function()
      result.fontbbox={ unpack(stack,1,4) }
      top=0
    end
+P("\13")/function()
      result.uniqueid=stack[top]
      top=0
    end+P("\14")/function()
      result.xuid=concat(stack,"",1,top)
      top=0
    end+P("\15")/function()
      result.charset=stack[top]
      top=0
    end+P("\16")/function()
      result.encoding=stack[top]
      top=0
    end+P("\17")/function() 
      result.charstrings=stack[top]
      top=0
    end+P("\18")/function()
      result.private={
        size=stack[top-1],
        offset=stack[top],
      }
      top=0
    end+P("\19")/function()
      result.subroutines=stack[top]
      top=0 
    end+P("\20")/function()
      result.defaultwidthx=stack[top]
      top=0 
    end+P("\21")/function()
      result.nominalwidthx=stack[top]
      top=0 
    end
+P("\24")/function() 
      result.vstore=stack[top]
      top=0
    end+P("\25")/function() 
      result.maxstack=stack[top]
      top=0
    end
  local p_double=P("\12")*(
    P("\00")/function()
      result.copyright=stack[top]
      top=0
    end+P("\01")/function()
      result.monospaced=stack[top]==1 and true or false 
      top=0
    end+P("\02")/function()
      result.italicangle=stack[top]
      top=0
    end+P("\03")/function()
      result.underlineposition=stack[top]
      top=0
    end+P("\04")/function()
      result.underlinethickness=stack[top]
      top=0
    end+P("\05")/function()
      result.painttype=stack[top]
      top=0
    end+P("\06")/function()
      result.charstringtype=stack[top]
      top=0
    end+P("\07")/function() 
      result.fontmatrix={ unpack(stack,1,6) }
      top=0
    end+P("\08")/function()
      result.strokewidth=stack[top]
      top=0
    end+P("\20")/function()
      result.syntheticbase=stack[top]
      top=0
    end+P("\21")/function()
      result.postscript=strings[stack[top]] or "unset"
      top=0
    end+P("\22")/function()
      result.basefontname=strings[stack[top]] or "unset"
      top=0
    end+P("\21")/function()
      result.basefontblend=stack[top]
      top=0
    end+P("\30")/function()
      result.cid.registry=strings[stack[top-2]] or "unset"
      result.cid.ordering=strings[stack[top-1]] or "unset"
      result.cid.supplement=stack[top]
      top=0
    end+P("\31")/function()
      result.cid.fontversion=stack[top]
      top=0
    end+P("\32")/function()
      result.cid.fontrevision=stack[top]
      top=0
    end+P("\33")/function()
      result.cid.fonttype=stack[top]
      top=0
    end+P("\34")/function()
      result.cid.count=stack[top]
      top=0
    end+P("\35")/function()
      result.cid.uidbase=stack[top]
      top=0
    end+P("\36")/function() 
      result.cid.fdarray=stack[top]
      top=0
    end+P("\37")/function() 
      result.cid.fdselect=stack[top]
      top=0
    end+P("\38")/function()
      result.cid.fontname=strings[stack[top]] or "unset"
      top=0
    end
  )
  local p_last=P("\x0F")/"0"+P("\x1F")/"1"+P("\x2F")/"2"+P("\x3F")/"3"+P("\x4F")/"4"+P("\x5F")/"5"+P("\x6F")/"6"+P("\x7F")/"7"+P("\x8F")/"8"+P("\x9F")/"9"+P("\xAF")/""+P("\xBF")/""+P("\xCF")/""+P("\xDF")/""+P("\xEF")/""+R("\xF0\xFF")/""
  local remap={
    ["\x00"]="00",["\x01"]="01",["\x02"]="02",["\x03"]="03",["\x04"]="04",["\x05"]="05",["\x06"]="06",["\x07"]="07",["\x08"]="08",["\x09"]="09",["\x0A"]="0.",["\x0B"]="0E",["\x0C"]="0E-",["\x0D"]="0",["\x0E"]="0-",["\x0F"]="0",
    ["\x10"]="10",["\x11"]="11",["\x12"]="12",["\x13"]="13",["\x14"]="14",["\x15"]="15",["\x16"]="16",["\x17"]="17",["\x18"]="18",["\x19"]="19",["\x1A"]="0.",["\x1B"]="0E",["\x1C"]="0E-",["\x1D"]="0",["\x1E"]="0-",["\x1F"]="0",
    ["\x20"]="20",["\x21"]="21",["\x22"]="22",["\x23"]="23",["\x24"]="24",["\x25"]="25",["\x26"]="26",["\x27"]="27",["\x28"]="28",["\x29"]="29",["\x2A"]="0.",["\x2B"]="0E",["\x2C"]="0E-",["\x2D"]="0",["\x2E"]="0-",["\x2F"]="0",
    ["\x30"]="30",["\x31"]="31",["\x32"]="32",["\x33"]="33",["\x34"]="34",["\x35"]="35",["\x36"]="36",["\x37"]="37",["\x38"]="38",["\x39"]="39",["\x3A"]="0.",["\x3B"]="0E",["\x3C"]="0E-",["\x3D"]="0",["\x3E"]="0-",["\x3F"]="0",
    ["\x40"]="40",["\x41"]="41",["\x42"]="42",["\x43"]="43",["\x44"]="44",["\x45"]="45",["\x46"]="46",["\x47"]="47",["\x48"]="48",["\x49"]="49",["\x4A"]="0.",["\x4B"]="0E",["\x4C"]="0E-",["\x4D"]="0",["\x4E"]="0-",["\x4F"]="0",
    ["\x50"]="50",["\x51"]="51",["\x52"]="52",["\x53"]="53",["\x54"]="54",["\x55"]="55",["\x56"]="56",["\x57"]="57",["\x58"]="58",["\x59"]="59",["\x5A"]="0.",["\x5B"]="0E",["\x5C"]="0E-",["\x5D"]="0",["\x5E"]="0-",["\x5F"]="0",
    ["\x60"]="60",["\x61"]="61",["\x62"]="62",["\x63"]="63",["\x64"]="64",["\x65"]="65",["\x66"]="66",["\x67"]="67",["\x68"]="68",["\x69"]="69",["\x6A"]="0.",["\x6B"]="0E",["\x6C"]="0E-",["\x6D"]="0",["\x6E"]="0-",["\x6F"]="0",
    ["\x70"]="70",["\x71"]="71",["\x72"]="72",["\x73"]="73",["\x74"]="74",["\x75"]="75",["\x76"]="76",["\x77"]="77",["\x78"]="78",["\x79"]="79",["\x7A"]="0.",["\x7B"]="0E",["\x7C"]="0E-",["\x7D"]="0",["\x7E"]="0-",["\x7F"]="0",
    ["\x80"]="80",["\x81"]="81",["\x82"]="82",["\x83"]="83",["\x84"]="84",["\x85"]="85",["\x86"]="86",["\x87"]="87",["\x88"]="88",["\x89"]="89",["\x8A"]="0.",["\x8B"]="0E",["\x8C"]="0E-",["\x8D"]="0",["\x8E"]="0-",["\x8F"]="0",
    ["\x90"]="90",["\x91"]="91",["\x92"]="92",["\x93"]="93",["\x94"]="94",["\x95"]="95",["\x96"]="96",["\x97"]="97",["\x98"]="98",["\x99"]="99",["\x9A"]="0.",["\x9B"]="0E",["\x9C"]="0E-",["\x9D"]="0",["\x9E"]="0-",["\x9F"]="0",
    ["\xA0"]=".0",["\xA1"]=".1",["\xA2"]=".2",["\xA3"]=".3",["\xA4"]=".4",["\xA5"]=".5",["\xA6"]=".6",["\xA7"]=".7",["\xA8"]=".8",["\xA9"]=".9",["\xAA"]="..",["\xAB"]=".E",["\xAC"]=".E-",["\xAD"]=".",["\xAE"]=".-",["\xAF"]=".",
    ["\xB0"]="E0",["\xB1"]="E1",["\xB2"]="E2",["\xB3"]="E3",["\xB4"]="E4",["\xB5"]="E5",["\xB6"]="E6",["\xB7"]="E7",["\xB8"]="E8",["\xB9"]="E9",["\xBA"]="E.",["\xBB"]="EE",["\xBC"]="EE-",["\xBD"]="E",["\xBE"]="E-",["\xBF"]="E",
    ["\xC0"]="E-0",["\xC1"]="E-1",["\xC2"]="E-2",["\xC3"]="E-3",["\xC4"]="E-4",["\xC5"]="E-5",["\xC6"]="E-6",["\xC7"]="E-7",["\xC8"]="E-8",["\xC9"]="E-9",["\xCA"]="E-.",["\xCB"]="E-E",["\xCC"]="E-E-",["\xCD"]="E-",["\xCE"]="E--",["\xCF"]="E-",
    ["\xD0"]="-0",["\xD1"]="-1",["\xD2"]="-2",["\xD3"]="-3",["\xD4"]="-4",["\xD5"]="-5",["\xD6"]="-6",["\xD7"]="-7",["\xD8"]="-8",["\xD9"]="-9",["\xDA"]="-.",["\xDB"]="-E",["\xDC"]="-E-",["\xDD"]="-",["\xDE"]="--",["\xDF"]="-",
  }
  local p_nibbles=P("\30")*Cs(((1-p_last)/remap)^0+p_last)/function(n)
    top=top+1
    stack[top]=tonumber(n) or 0
  end
  local p_byte=C(R("\32\246"))/function(b0)
    top=top+1
    stack[top]=byte(b0)-139
  end
  local p_positive=C(R("\247\250"))*C(1)/function(b0,b1)
    top=top+1
    stack[top]=(byte(b0)-247)*256+byte(b1)+108
  end
  local p_negative=C(R("\251\254"))*C(1)/function(b0,b1)
    top=top+1
    stack[top]=-(byte(b0)-251)*256-byte(b1)-108
  end
  local p_short=P("\28")*C(1)*C(1)/function(b1,b2)
    top=top+1
    local n=0x100*byte(b1)+byte(b2)
    if n>=0x8000 then
      stack[top]=n-0xFFFF-1
    else
      stack[top]=n
    end
  end
  local p_long=P("\29")*C(1)*C(1)*C(1)*C(1)/function(b1,b2,b3,b4)
    top=top+1
    local n=0x1000000*byte(b1)+0x10000*byte(b2)+0x100*byte(b3)+byte(b4)
    if n>=0x8000000 then
      stack[top]=n-0xFFFFFFFF-1
    else
      stack[top]=n
    end
  end
  local p_unsupported=P(1)/function(detail)
    top=0
  end
  local p_dictionary=(
    p_byte+p_positive+p_negative+p_short+p_long+p_nibbles+p_single+p_double+p_unsupported
  )^1
  parsedictionaries=function(data,dictionaries,what)
    stack={}
    strings=data.strings
    for i=1,#dictionaries do
      top=0
      result=what=="cff" and {
        monospaced=false,
        italicangle=0,
        underlineposition=-100,
        underlinethickness=50,
        painttype=0,
        charstringtype=2,
        fontmatrix={ 0.001,0,0,0.001,0,0 },
        fontbbox={ 0,0,0,0 },
        strokewidth=0,
        charset=0,
        encoding=0,
        cid={
          fontversion=0,
          fontrevision=0,
          fonttype=0,
          count=8720,
        }
      } or {
        charstringtype=2,
        charset=0,
        vstore=0,
        cid={
        },
      }
      lpegmatch(p_dictionary,dictionaries[i])
      dictionaries[i]=result
    end
    result={}
    top=0
    stack={}
  end
  parseprivates=function(data,dictionaries)
    stack={}
    strings=data.strings
    for i=1,#dictionaries do
      local private=dictionaries[i].private
      if private and private.data then
        top=0
        result={
          forcebold=false,
          languagegroup=0,
          expansionfactor=0.06,
          initialrandomseed=0,
          subroutines=0,
          defaultwidthx=0,
          nominalwidthx=0,
          cid={
          },
        }
        lpegmatch(p_dictionary,private.data)
        private.data=result
      end
    end
    result={}
    top=0
    stack={}
  end
  local x=0
  local y=0
  local width=false
  local r=0
  local stems=0
  local globalbias=0
  local localbias=0
  local nominalwidth=0
  local defaultwidth=0
  local charset=false
  local globals=false
  local locals=false
  local depth=1
  local xmin=0
  local xmax=0
  local ymin=0
  local ymax=0
  local checked=false
  local keepcurve=false
  local version=2
  local regions=false
  local nofregions=0
  local region=false
  local factors=false
  local axis=false
  local vsindex=0
  local function showstate(where)
    report("%w%-10s : [%s] n=%i",depth*2,where,concat(stack," ",1,top),top)
  end
  local function showvalue(where,value,showstack)
    if showstack then
      report("%w%-10s : %s : [%s] n=%i",depth*2,where,tostring(value),concat(stack," ",1,top),top)
    else
      report("%w%-10s : %s",depth*2,where,tostring(value))
    end
  end
  local function xymoveto()
    if keepcurve then
      r=r+1
      result[r]={ x,y,"m" }
    end
    if checked then
      if x>xmax then xmax=x elseif x<xmin then xmin=x end
      if y>ymax then ymax=y elseif y<ymin then ymin=y end
    else
      xmin=x
      ymin=y
      xmax=x
      ymax=y
      checked=true
    end
  end
  local function xmoveto() 
    if keepcurve then
      r=r+1
      result[r]={ x,y,"m" }
    end
    if not checked then
      xmin=x
      ymin=y
      xmax=x
      ymax=y
      checked=true
    elseif x>xmax then
      xmax=x
    elseif x<xmin then
      xmin=x
    end
  end
  local function ymoveto() 
    if keepcurve then
      r=r+1
      result[r]={ x,y,"m" }
    end
    if not checked then
      xmin=x
      ymin=y
      xmax=x
      ymax=y
      checked=true
    elseif y>ymax then
      ymax=y
    elseif y<ymin then
      ymin=y
    end
  end
  local function moveto()
    if trace_charstrings then
      showstate("moveto")
    end
    top=0 
    xymoveto()
  end
  local function xylineto() 
    if keepcurve then
      r=r+1
      result[r]={ x,y,"l" }
    end
    if checked then
      if x>xmax then xmax=x elseif x<xmin then xmin=x end
      if y>ymax then ymax=y elseif y<ymin then ymin=y end
    else
      xmin=x
      ymin=y
      xmax=x
      ymax=y
      checked=true
    end
  end
  local function xlineto() 
    if keepcurve then
      r=r+1
      result[r]={ x,y,"l" }
    end
    if not checked then
      xmin=x
      ymin=y
      xmax=x
      ymax=y
      checked=true
    elseif x>xmax then
      xmax=x
    elseif x<xmin then
      xmin=x
    end
  end
  local function ylineto() 
    if keepcurve then
      r=r+1
      result[r]={ x,y,"l" }
    end
    if not checked then
      xmin=x
      ymin=y
      xmax=x
      ymax=y
      checked=true
    elseif y>ymax then
      ymax=y
    elseif y<ymin then
      ymin=y
    end
  end
  local function xycurveto(x1,y1,x2,y2,x3,y3) 
    if trace_charstrings then
      showstate("curveto")
    end
    if keepcurve then
      r=r+1
      result[r]={ x1,y1,x2,y2,x3,y3,"c" }
    end
    if checked then
      if x1>xmax then xmax=x1 elseif x1<xmin then xmin=x1 end
      if y1>ymax then ymax=y1 elseif y1<ymin then ymin=y1 end
    else
      xmin=x1
      ymin=y1
      xmax=x1
      ymax=y1
      checked=true
    end
    if x2>xmax then xmax=x2 elseif x2<xmin then xmin=x2 end
    if y2>ymax then ymax=y2 elseif y2<ymin then ymin=y2 end
    if x3>xmax then xmax=x3 elseif x3<xmin then xmin=x3 end
    if y3>ymax then ymax=y3 elseif y3<ymin then ymin=y3 end
  end
  local function rmoveto()
    if not width then
      if top>2 then
        width=stack[1]
        if trace_charstrings then
          showvalue("backtrack width",width)
        end
      else
        width=true
      end
    end
    if trace_charstrings then
      showstate("rmoveto")
    end
    x=x+stack[top-1] 
    y=y+stack[top]  
    top=0
    xymoveto()
  end
  local function hmoveto()
    if not width then
      if top>1 then
        width=stack[1]
        if trace_charstrings then
          showvalue("backtrack width",width)
        end
      else
        width=true
      end
    end
    if trace_charstrings then
      showstate("hmoveto")
    end
    x=x+stack[top] 
    top=0
    xmoveto()
  end
  local function vmoveto()
    if not width then
      if top>1 then
        width=stack[1]
        if trace_charstrings then
          showvalue("backtrack width",width)
        end
      else
        width=true
      end
    end
    if trace_charstrings then
      showstate("vmoveto")
    end
    y=y+stack[top] 
    top=0
    ymoveto()
  end
  local function rlineto()
    if trace_charstrings then
      showstate("rlineto")
    end
    for i=1,top,2 do
      x=x+stack[i]  
      y=y+stack[i+1] 
      xylineto()
    end
    top=0
  end
  local function hlineto() 
    if trace_charstrings then
      showstate("hlineto")
    end
    if top==1 then
      x=x+stack[1]
      xlineto()
    else
      local swap=true
      for i=1,top do
        if swap then
          x=x+stack[i]
          xlineto()
          swap=false
        else
          y=y+stack[i]
          ylineto()
          swap=true
        end
      end
    end
    top=0
  end
  local function vlineto() 
    if trace_charstrings then
      showstate("vlineto")
    end
    if top==1 then
      y=y+stack[1]
      ylineto()
    else
      local swap=false
      for i=1,top do
        if swap then
          x=x+stack[i]
          xlineto()
          swap=false
        else
          y=y+stack[i]
          ylineto()
          swap=true
        end
      end
    end
    top=0
  end
  local function rrcurveto()
    if trace_charstrings then
      showstate("rrcurveto")
    end
    for i=1,top,6 do
      local ax=x+stack[i]  
      local ay=y+stack[i+1] 
      local bx=ax+stack[i+2] 
      local by=ay+stack[i+3] 
      x=bx+stack[i+4]    
      y=by+stack[i+5]    
      xycurveto(ax,ay,bx,by,x,y)
    end
    top=0
  end
  local function hhcurveto()
    if trace_charstrings then
      showstate("hhcurveto")
    end
    local s=1
    if top%2~=0 then
      y=y+stack[1]      
      s=2
    end
    for i=s,top,4 do
      local ax=x+stack[i]  
      local ay=y
      local bx=ax+stack[i+1] 
      local by=ay+stack[i+2] 
      x=bx+stack[i+3]    
      y=by
      xycurveto(ax,ay,bx,by,x,y)
    end
    top=0
  end
  local function vvcurveto()
    if trace_charstrings then
      showstate("vvcurveto")
    end
    local s=1
    local d=0
    if top%2~=0 then
      d=stack[1]        
      s=2
    end
    for i=s,top,4 do
      local ax=x+d
      local ay=y+stack[i]  
      local bx=ax+stack[i+1] 
      local by=ay+stack[i+2] 
      x=bx
      y=by+stack[i+3]    
      xycurveto(ax,ay,bx,by,x,y)
      d=0
    end
    top=0
  end
  local function xxcurveto(swap)
    local last=top%4~=0 and stack[top]
    if last then
      top=top-1
    end
    for i=1,top,4 do
      local ax,ay,bx,by
      if swap then
        ax=x+stack[i]
        ay=y
        bx=ax+stack[i+1]
        by=ay+stack[i+2]
        y=by+stack[i+3]
        if last and i+3==top then
          x=bx+last
        else
          x=bx
        end
        swap=false
      else
        ax=x
        ay=y+stack[i]
        bx=ax+stack[i+1]
        by=ay+stack[i+2]
        x=bx+stack[i+3]
        if last and i+3==top then
          y=by+last
        else
          y=by
        end
        swap=true
      end
      xycurveto(ax,ay,bx,by,x,y)
    end
    top=0
  end
  local function hvcurveto()
    if trace_charstrings then
      showstate("hvcurveto")
    end
    xxcurveto(true)
  end
  local function vhcurveto()
    if trace_charstrings then
      showstate("vhcurveto")
    end
    xxcurveto(false)
  end
  local function rcurveline()
    if trace_charstrings then
      showstate("rcurveline")
    end
    for i=1,top-2,6 do
      local ax=x+stack[i]  
      local ay=y+stack[i+1] 
      local bx=ax+stack[i+2] 
      local by=ay+stack[i+3] 
      x=bx+stack[i+4] 
      y=by+stack[i+5] 
      xycurveto(ax,ay,bx,by,x,y)
    end
    x=x+stack[top-1] 
    y=y+stack[top]  
    xylineto()
    top=0
  end
  local function rlinecurve()
    if trace_charstrings then
      showstate("rlinecurve")
    end
    if top>6 then
      for i=1,top-6,2 do
        x=x+stack[i]
        y=y+stack[i+1]
        xylineto()
      end
    end
    local ax=x+stack[top-5]
    local ay=y+stack[top-4]
    local bx=ax+stack[top-3]
    local by=ay+stack[top-2]
    x=bx+stack[top-1]
    y=by+stack[top]
    xycurveto(ax,ay,bx,by,x,y)
    top=0
  end
  local function flex() 
    if trace_charstrings then
      showstate("flex")
    end
    local ax=x+stack[1] 
    local ay=y+stack[2] 
    local bx=ax+stack[3] 
    local by=ay+stack[4] 
    local cx=bx+stack[5] 
    local cy=by+stack[6] 
    xycurveto(ax,ay,bx,by,cx,cy)
    local dx=cx+stack[7] 
    local dy=cy+stack[8] 
    local ex=dx+stack[9] 
    local ey=dy+stack[10] 
    x=ex+stack[11]    
    y=ey+stack[12]    
    xycurveto(dx,dy,ex,ey,x,y)
    top=0
  end
  local function hflex()
    if trace_charstrings then
      showstate("hflex")
    end
    local ax=x+stack[1] 
    local ay=y
    local bx=ax+stack[2] 
    local by=ay+stack[3] 
    local cx=bx+stack[4] 
    local cy=by
    xycurveto(ax,ay,bx,by,cx,cy)
    local dx=cx+stack[5] 
    local dy=by
    local ex=dx+stack[6] 
    local ey=y
    x=ex+stack[7]    
    xycurveto(dx,dy,ex,ey,x,y)
    top=0
  end
  local function hflex1()
    if trace_charstrings then
      showstate("hflex1")
    end
    local ax=x+stack[1] 
    local ay=y+stack[2] 
    local bx=ax+stack[3] 
    local by=ay+stack[4] 
    local cx=bx+stack[5] 
    local cy=by
    xycurveto(ax,ay,bx,by,cx,cy)
    local dx=cx+stack[6] 
    local dy=by
    local ex=dx+stack[7] 
    local ey=dy+stack[8] 
    x=ex+stack[9]    
    xycurveto(dx,dy,ex,ey,x,y)
    top=0
  end
  local function flex1()
    if trace_charstrings then
      showstate("flex1")
    end
    local ax=x+stack[1] 
    local ay=y+stack[2] 
    local bx=ax+stack[3] 
    local by=ay+stack[4] 
    local cx=bx+stack[5] 
    local cy=by+stack[6] 
    xycurveto(ax,ay,bx,by,cx,cy)
    local dx=cx+stack[7] 
    local dy=cy+stack[8] 
    local ex=dx+stack[9] 
    local ey=dy+stack[10] 
    if abs(ex-x)>abs(ey-y) then 
      x=ex+stack[11]
    else
      y=ey+stack[11]
    end
    xycurveto(dx,dy,ex,ey,x,y)
    top=0
  end
  local function getstem()
    if top==0 then
    elseif top%2~=0 then
      if width then
        remove(stack,1)
      else
        width=remove(stack,1)
        if trace_charstrings then
          showvalue("width",width)
        end
      end
      top=top-1
    end
    if trace_charstrings then
      showstate("stem")
    end
    stems=stems+top/2
    top=0
  end
  local function getmask()
    if top==0 then
    elseif top%2~=0 then
      if width then
        remove(stack,1)
      else
        width=remove(stack,1)
        if trace_charstrings then
          showvalue("width",width)
        end
      end
      top=top-1
    end
    if trace_charstrings then
      showstate(operator==19 and "hintmark" or "cntrmask")
    end
    stems=stems+top/2
    top=0
    if stems==0 then
    elseif stems<=8 then
      return 1
    else
      return floor((stems+7)/8)
    end
  end
  local function unsupported(t)
    if trace_charstrings then
      showstate("unsupported "..t)
    end
    top=0
  end
  local function unsupportedsub(t)
    if trace_charstrings then
      showstate("unsupported sub "..t)
    end
    top=0
  end
  local function getstem3()
    if trace_charstrings then
      showstate("stem3")
    end
    top=0
  end
  local function divide()
    if version==1 then
      local d=stack[top]
      top=top-1
      stack[top]=stack[top]/d
    end
  end
  local function closepath()
    if version==1 then
      if trace_charstrings then
        showstate("closepath")
      end
    end
    top=0
  end
  local function hsbw()
    if version==1 then
      if trace_charstrings then
        showstate("dotsection")
      end
      width=stack[top]
    end
    top=0
  end
  local function seac()
    if version==1 then
      if trace_charstrings then
        showstate("seac")
      end
    end
    top=0
  end
  local function sbw()
    if version==1 then
      if trace_charstrings then
        showstate("sbw")
      end
      width=stack[top-1]
    end
    top=0
  end
  local function callothersubr()
    if version==1 then
      if trace_charstrings then
        showstate("callothersubr (unsupported)")
      end
    end
    top=0
  end
  local function pop()
    if version==1 then
      if trace_charstrings then
        showstate("pop (unsupported)")
      end
      top=top+1
      stack[top]=0 
    else
      top=0
    end
  end
  local function setcurrentpoint()
    if version==1 then
      if trace_charstrings then
        showstate("pop (unsupported)")
      end
      x=x+stack[top-1]
      y=y+stack[top]
    end
    top=0
  end
  local reginit=false
  local function updateregions(n) 
    if regions then
      local current=regions[n] or regions[1]
      nofregions=#current
      if axis and n~=reginit then
        factors={}
        for i=1,nofregions do
          local region=current[i]
          local s=1
          for j=1,#axis do
            local f=axis[j]
            local r=region[j]
            local start=r.start
            local peak=r.peak
            local stop=r.stop
            if start>peak or peak>stop then
            elseif start<0 and stop>0 and peak~=0 then
            elseif peak==0 then
            elseif f<start or f>stop then
              s=0
              break
            elseif f<peak then
              s=s*(f-start)/(peak-start)
            elseif f>peak then
              s=s*(stop-f)/(stop-peak)
            else
            end
          end
          factors[i]=s
        end
      end
    end
    reginit=n
  end
  local function setvsindex()
    local vsindex=stack[top]
    if trace_charstrings then
      showstate(formatters["vsindex %i"](vsindex))
    end
    updateregions(vsindex)
    top=top-1
  end
  local function blend()
    local n=stack[top]
    top=top-1
    if axis then
      if trace_charstrings then
        local t=top-nofregions*n
        local m=t-n
        for i=1,n do
          local k=m+i
          local d=m+n+(i-1)*nofregions
          local old=stack[k]
          local new=old
          for r=1,nofregions do
            new=new+stack[d+r]*factors[r]
          end
          stack[k]=new
          showstate(formatters["blend %i of %i: %s -> %s"](i,n,old,new))
        end
        top=t
      elseif n==1 then
        top=top-nofregions
        local v=stack[top]
        for r=1,nofregions do
          v=v+stack[top+r]*factors[r]
        end
        stack[top]=v
      else
        top=top-nofregions*n
        local d=top
        local k=top-n
        for i=1,n do
          k=k+1
          local v=stack[k]
          for r=1,nofregions do
            v=v+stack[d+r]*factors[r]
          end
          stack[k]=v
          d=d+nofregions
        end
      end
    else
    end
  end
  local actions={ [0]=unsupported,
    getstem,
    unsupported,
    getstem,
    vmoveto,
    rlineto,
    hlineto,
    vlineto,
    rrcurveto,
    unsupported,
    unsupported,
    unsupported,
    unsupported,
    hsbw,
    unsupported,
    setvsindex,
    blend,
    unsupported,
    getstem,
    getmask,
    getmask,
    rmoveto,
    hmoveto,
    getstem,
    rcurveline,
    rlinecurve,
    vvcurveto,
    hhcurveto,
    unsupported,
    unsupported,
    vhcurveto,
    hvcurveto,
  }
  local subactions={
    [000]=dotsection,
    [001]=getstem3,
    [002]=getstem3,
    [006]=seac,
    [007]=sbw,
    [012]=divide,
    [016]=callothersubr,
    [017]=pop,
    [033]=setcurrentpoint,
    [034]=hflex,
    [035]=flex,
    [036]=hflex1,
    [037]=flex1,
  }
  local c_endchar=char(14)
  local passon do
    local rshift=bit32.rshift
    local band=bit32.band
    local round=math.round
    local encode=table.setmetatableindex(function(t,i)
      for i=-2048,-1130 do
        t[i]=char(28,band(rshift(i,8),0xFF),band(i,0xFF))
      end
      for i=-1131,-108 do
        local v=0xFB00-i-108
        t[i]=char(band(rshift(v,8),0xFF),band(v,0xFF))
      end
      for i=-107,107 do
        t[i]=char(i+139)
      end
      for i=108,1131 do
        local v=0xF700+i-108
        t[i]=char(band(rshift(v,8),0xFF),band(v,0xFF))
      end
      for i=1132,2048 do
        t[i]=char(28,band(rshift(i,8),0xFF),band(i,0xFF))
      end
      return t[i]
    end)
    local function setvsindex()
      local vsindex=stack[top]
      updateregions(vsindex)
      top=top-1
    end
    local function blend()
      local n=stack[top]
      top=top-1
      if not axis then
      elseif n==1 then
        top=top-nofregions
        local v=stack[top]
        for r=1,nofregions do
          v=v+stack[top+r]*factors[r]
        end
        stack[top]=round(v)
      else
        top=top-nofregions*n
        local d=top
        local k=top-n
        for i=1,n do
          k=k+1
          local v=stack[k]
          for r=1,nofregions do
            v=v+stack[d+r]*factors[r]
          end
          stack[k]=round(v)
          d=d+nofregions
        end
      end
    end
    passon=function(operation)
      if operation==15 then
        setvsindex()
      elseif operation==16 then
        blend()
      else
        for i=1,top do
          r=r+1
          result[r]=encode[stack[i]]
        end
        r=r+1
        result[r]=char(operation) 
        top=0
      end
    end
  end
  local process
  local function call(scope,list,bias) 
    depth=depth+1
    if top==0 then
      showstate(formatters["unknown %s call"](scope))
      top=0
    else
      local index=stack[top]+bias
      top=top-1
      if trace_charstrings then
        showvalue(scope,index,true)
      end
      local tab=list[index]
      if tab then
        process(tab)
      else
        showstate(formatters["unknown %s call %i"](scope,index))
        top=0
      end
    end
    depth=depth-1
  end
  local justpass=false
  process=function(tab)
    local i=1
    local n=#tab
    while i<=n do
      local t=tab[i]
      if t>=32 then
        top=top+1
        if t<=246 then
          stack[top]=t-139
          i=i+1
        elseif t<=250 then
          stack[top]=t*256-63124+tab[i+1]
          i=i+2
        elseif t<=254 then
          stack[top]=-t*256+64148-tab[i+1]
          i=i+2
        else
          local n=0x100*tab[i+1]+tab[i+2]
          if n>=0x8000 then
            stack[top]=n-0x10000+(0x100*tab[i+3]+tab[i+4])/0xFFFF
          else
            stack[top]=n+(0x100*tab[i+3]+tab[i+4])/0xFFFF
          end
          i=i+5
        end
      elseif t==28 then
        top=top+1
        local n=0x100*tab[i+1]+tab[i+2]
        if n>=0x8000 then
          stack[top]=n-0x10000
        else
          stack[top]=n
        end
        i=i+3
      elseif t==11 then 
        if trace_charstrings then
          showstate("return")
        end
        return
      elseif t==10 then
        call("local",locals,localbias) 
        i=i+1
      elseif t==14 then 
        if width then
        elseif top>0 then
          width=stack[1]
          if trace_charstrings then
            showvalue("width",width)
          end
        else
          width=true
        end
        if trace_charstrings then
          showstate("endchar")
        end
        return
      elseif t==29 then
        call("global",globals,globalbias) 
        i=i+1
      elseif t==12 then
        i=i+1
        local t=tab[i]
        local a=subactions[t]
        if a then
          a(t)
        else
          if trace_charstrings then
            showvalue("<subaction>",t)
          end
          top=0
        end
        i=i+1
      elseif justpass then
        passon(t)
        i=i+1
      else
        local a=actions[t]
        if a then
          local s=a(t)
          if s then
            i=i+s+1
          else
            i=i+1
          end
        else
          if trace_charstrings then
            showvalue("<action>",t)
          end
          top=0
          i=i+1
        end
      end
    end
  end
  local function setbias(globals,locals)
    if version==1 then
      return
        false,
        false
    else
      local g,l=#globals,#locals
      return
        ((g<1240 and 107) or (g<33900 and 1131) or 32768)+1,
        ((l<1240 and 107) or (l<33900 and 1131) or 32768)+1
    end
  end
  local function processshape(tab,index)
    tab=bytetable(tab)
    x=0
    y=0
    width=false
    r=0
    top=0
    stems=0
    result={} 
    xmin=0
    xmax=0
    ymin=0
    ymax=0
    checked=false
    if trace_charstrings then
      report("glyph: %i",index)
      report("data : % t",tab)
    end
    if regions then
      updateregions(vsindex)
    end
    process(tab)
    local boundingbox={
      round(xmin),
      round(ymin),
      round(xmax),
      round(ymax),
    }
    if width==true or width==false then
      width=defaultwidth
    else
      width=nominalwidth+width
    end
    local glyph=glyphs[index] 
    if justpass then
      r=r+1
      result[r]=c_endchar
      local stream=concat(result)
      if glyph then
        glyph.stream=stream
      else
        glyphs[index]={ stream=stream }
      end
    elseif glyph then
      glyph.segments=keepcurve~=false and result or nil
      glyph.boundingbox=boundingbox
      if not glyph.width then
        glyph.width=width
      end
      if charset and not glyph.name then
        glyph.name=charset[index]
      end
    elseif keepcurve then
      glyphs[index]={
        segments=result,
        boundingbox=boundingbox,
        width=width,
        name=charset and charset[index] or nil,
      }
    else
      glyphs[index]={
        boundingbox=boundingbox,
        width=width,
        name=charset and charset[index] or nil,
      }
    end
    if trace_charstrings then
      report("width      : %s",tostring(width))
      report("boundingbox: % t",boundingbox)
    end
  end
  startparsing=function(fontdata,data,streams)
    reginit=false
    axis=false
    regions=data.regions
    justpass=streams==true
    if regions then
      regions={ regions } 
      axis=data.factors or false
    end
  end
  stopparsing=function(fontdata,data)
    stack={}
    glyphs=false
    result={}
    top=0
    locals=false
    globals=false
    strings=false
  end
  local function setwidths(private)
    if not private then
      return 0,0
    end
    local privatedata=private.data
    if not privatedata then
      return 0,0
    end
    return privatedata.nominalwidthx or 0,privatedata.defaultwidthx or 0
  end
  parsecharstrings=function(fontdata,data,glphs,doshapes,tversion,streams)
    local dictionary=data.dictionaries[1]
    local charstrings=dictionary.charstrings
    keepcurve=doshapes
    version=tversion
    strings=data.strings
    globals=data.routines or {}
    locals=dictionary.subroutines or {}
    charset=dictionary.charset
    vsindex=dictionary.vsindex or 0
    glyphs=glphs or {}
    globalbias,localbias=setbias(globals,locals)
    nominalwidth,defaultwidth=setwidths(dictionary.private)
    startparsing(fontdata,data,streams)
    for index=1,#charstrings do
      processshape(charstrings[index],index-1)
      charstrings[index]=nil 
    end
    stopparsing(fontdata,data)
    return glyphs
  end
  parsecharstring=function(fontdata,data,dictionary,tab,glphs,index,doshapes,tversion)
    keepcurve=doshapes
    version=tversion
    strings=data.strings
    globals=data.routines or {}
    locals=dictionary.subroutines or {}
    charset=false
    vsindex=dictionary.vsindex or 0
    glyphs=glphs or {}
    globalbias,localbias=setbias(globals,locals)
    nominalwidth,defaultwidth=setwidths(dictionary.private)
    processshape(tab,index-1)
  end
end
local function readglobals(f,data)
  local routines=readlengths(f)
  for i=1,#routines do
    routines[i]=readbytetable(f,routines[i])
  end
  data.routines=routines
end
local function readencodings(f,data)
  data.encodings={}
end
local function readcharsets(f,data,dictionary)
  local header=data.header
  local strings=data.strings
  local nofglyphs=data.nofglyphs
  local charsetoffset=dictionary.charset
  if charsetoffset and charsetoffset~=0 then
    setposition(f,header.offset+charsetoffset)
    local format=readbyte(f)
    local charset={ [0]=".notdef" }
    dictionary.charset=charset
    if format==0 then
      for i=1,nofglyphs do
        charset[i]=strings[readushort(f)]
      end
    elseif format==1 or format==2 then
      local readcount=format==1 and readbyte or readushort
      local i=1
      while i<=nofglyphs do
        local sid=readushort(f)
        local n=readcount(f)
        for s=sid,sid+n do
          charset[i]=strings[s]
          i=i+1
          if i>nofglyphs then
            break
          end
        end
      end
    else
      report("cff parser: unsupported charset format %a",format)
    end
  else
    dictionary.nocharset=true
    dictionary.charset=nil
  end
end
local function readprivates(f,data)
  local header=data.header
  local dictionaries=data.dictionaries
  local private=dictionaries[1].private
  if private then
    setposition(f,header.offset+private.offset)
    private.data=readstring(f,private.size)
  end
end
local function readlocals(f,data,dictionary)
  local header=data.header
  local private=dictionary.private
  if private then
    local subroutineoffset=private.data.subroutines
    if subroutineoffset~=0 then
      setposition(f,header.offset+private.offset+subroutineoffset)
      local subroutines=readlengths(f)
      for i=1,#subroutines do
        subroutines[i]=readbytetable(f,subroutines[i])
      end
      dictionary.subroutines=subroutines
      private.data.subroutines=nil
    else
      dictionary.subroutines={}
    end
  else
    dictionary.subroutines={}
  end
end
local function readcharstrings(f,data,what)
  local header=data.header
  local dictionaries=data.dictionaries
  local dictionary=dictionaries[1]
  local stringtype=dictionary.charstringtype
  local offset=dictionary.charstrings
  if type(offset)~="number" then
  elseif stringtype==2 then
    setposition(f,header.offset+offset)
    local charstrings=readlengths(f,what=="cff2")
    local nofglyphs=#charstrings
    for i=1,nofglyphs do
      charstrings[i]=readstring(f,charstrings[i])
    end
    data.nofglyphs=nofglyphs
    dictionary.charstrings=charstrings
  else
    report("unsupported charstr type %i",stringtype)
    data.nofglyphs=0
    dictionary.charstrings={}
  end
end
local function readcidprivates(f,data)
  local header=data.header
  local dictionaries=data.dictionaries[1].cid.dictionaries
  for i=1,#dictionaries do
    local dictionary=dictionaries[i]
    local private=dictionary.private
    if private then
      setposition(f,header.offset+private.offset)
      private.data=readstring(f,private.size)
    end
  end
  parseprivates(data,dictionaries)
end
readers.parsecharstrings=parsecharstrings 
local function readnoselect(f,fontdata,data,glyphs,doshapes,version,streams)
  local dictionaries=data.dictionaries
  local dictionary=dictionaries[1]
  readglobals(f,data)
  readcharstrings(f,data,version)
  if version=="cff2" then
    dictionary.charset=nil
  else
    readencodings(f,data)
    readcharsets(f,data,dictionary)
  end
  readprivates(f,data)
  parseprivates(data,data.dictionaries)
  readlocals(f,data,dictionary)
  startparsing(fontdata,data,streams)
  parsecharstrings(fontdata,data,glyphs,doshapes,version,streams)
  stopparsing(fontdata,data)
end
local function readfdselect(f,fontdata,data,glyphs,doshapes,version,streams)
  local header=data.header
  local dictionaries=data.dictionaries
  local dictionary=dictionaries[1]
  local cid=dictionary.cid
  local cidselect=cid and cid.fdselect
  readglobals(f,data)
  readcharstrings(f,data,version)
  if version~="cff2" then
    readencodings(f,data)
  end
  local charstrings=dictionary.charstrings
  local fdindex={}
  local nofglyphs=data.nofglyphs
  local maxindex=-1
  setposition(f,header.offset+cidselect)
  local format=readbyte(f)
  if format==1 then
    for i=0,nofglyphs do 
      local index=readbyte(i)
      fdindex[i]=index
      if index>maxindex then
        maxindex=index
      end
    end
  elseif format==3 then
    local nofranges=readushort(f)
    local first=readushort(f)
    local index=readbyte(f)
    while true do
      local last=readushort(f)
      if index>maxindex then
        maxindex=index
      end
      for i=first,last do
        fdindex[i]=index
      end
      if last>=nofglyphs then
        break
      else
        first=last+1
        index=readbyte(f)
      end
    end
  else
  end
  if maxindex>=0 then
    local cidarray=cid.fdarray
    setposition(f,header.offset+cidarray)
    local dictionaries=readlengths(f)
    for i=1,#dictionaries do
      dictionaries[i]=readstring(f,dictionaries[i])
    end
    parsedictionaries(data,dictionaries)
    cid.dictionaries=dictionaries
    readcidprivates(f,data)
    for i=1,#dictionaries do
      readlocals(f,data,dictionaries[i])
    end
    startparsing(fontdata,data,streams)
    for i=1,#charstrings do
      parsecharstring(fontdata,data,dictionaries[fdindex[i]+1],charstrings[i],glyphs,i,doshapes,version)
      charstrings[i]=nil
    end
    stopparsing(fontdata,data)
  end
end
local gotodatatable=readers.helpers.gotodatatable
local function cleanup(data,dictionaries)
end
function readers.cff(f,fontdata,specification)
  local tableoffset=gotodatatable(f,fontdata,"cff",specification.details)
  if tableoffset then
    local header=readheader(f)
    if header.major~=1 then
      report("only version %s is supported for table %a",1,"cff")
      return
    end
    local glyphs=fontdata.glyphs
    local names=readfontnames(f)
    local dictionaries=readtopdictionaries(f)
    local strings=readstrings(f)
    local data={
      header=header,
      names=names,
      dictionaries=dictionaries,
      strings=strings,
      nofglyphs=fontdata.nofglyphs,
    }
    parsedictionaries(data,dictionaries,"cff")
    local dic=dictionaries[1]
    local cid=dic.cid
    fontdata.cffinfo={
      familynamename=dic.familyname,
      fullname=dic.fullname,
      boundingbox=dic.boundingbox,
      weight=dic.weight,
      italicangle=dic.italicangle,
      underlineposition=dic.underlineposition,
      underlinethickness=dic.underlinethickness,
      monospaced=dic.monospaced,
    }
    fontdata.cidinfo=cid and {
      registry=cid.registry,
      ordering=cid.ordering,
      supplement=cid.supplement,
    }
    if specification.glyphs then
      local all=specification.shapes or false
      if cid and cid.fdselect then
        readfdselect(f,fontdata,data,glyphs,all,"cff")
      else
        readnoselect(f,fontdata,data,glyphs,all,"cff")
      end
    end
    cleanup(data,dictionaries)
  end
end
function readers.cff2(f,fontdata,specification)
  local tableoffset=gotodatatable(f,fontdata,"cff2",specification.glyphs)
  if tableoffset then
    local header=readheader(f)
    if header.major~=2 then
      report("only version %s is supported for table %a",2,"cff2")
      return
    end
    local glyphs=fontdata.glyphs
    local dictionaries={ readstring(f,header.dsize) }
    local data={
      header=header,
      dictionaries=dictionaries,
      nofglyphs=fontdata.nofglyphs,
    }
    parsedictionaries(data,dictionaries,"cff2")
    local offset=dictionaries[1].vstore
    if offset>0 then
      local storeoffset=dictionaries[1].vstore+data.header.offset+2 
      local regions,deltas=readers.helpers.readvariationdata(f,storeoffset,factors)
      data.regions=regions
      data.deltas=deltas
    else
      data.regions={}
      data.deltas={}
    end
    data.factors=specification.factors
    local cid=data.dictionaries[1].cid
    local all=specification.shapes or false
    if cid and cid.fdselect then
      readfdselect(f,fontdata,data,glyphs,all,"cff2",specification.streams)
    else
      readnoselect(f,fontdata,data,glyphs,all,"cff2",specification.streams)
    end
    cleanup(data,dictionaries)
  end
end
function readers.cffcheck(filename)
  local f=io.open(filename,"rb")
  if f then
    local fontdata={
      glyphs={},
    }
    local header=readheader(f)
    if header.major~=1 then
      report("only version %s is supported for table %a",1,"cff")
      return
    end
    local names=readfontnames(f)
    local dictionaries=readtopdictionaries(f)
    local strings=readstrings(f)
    local glyphs={}
    local data={
      header=header,
      names=names,
      dictionaries=dictionaries,
      strings=strings,
      glyphs=glyphs,
      nofglyphs=4,
    }
    parsedictionaries(data,dictionaries,"cff")
    local cid=data.dictionaries[1].cid
    if cid and cid.fdselect then
      readfdselect(f,fontdata,data,glyphs,false)
    else
      readnoselect(f,fontdata,data,glyphs,false)
    end
    return data
  end
end

end --- [luaotfload, fontloader-2018-10-08.lua scope for “font-cff”] ---


do  --- [luaotfload, fontloader-2018-10-08.lua scope for “font-ttf” ff587471f4297aa8ba0fa022609adc6e] ---

if not modules then modules={} end modules ['font-ttf']={
  version=1.001,
  comment="companion to font-ini.mkiv",
  author="Hans Hagen, PRAGMA-ADE, Hasselt NL",
  copyright="PRAGMA ADE / ConTeXt Development Team",
  license="see context related readme files"
}
local next,type,unpack=next,type,unpack
local band,rshift=bit32.band,bit32.rshift
local sqrt,round=math.sqrt,math.round
local char=string.char
local concat=table.concat
local report=logs.reporter("otf reader","ttf")
local trace_deltas=false
local readers=fonts.handlers.otf.readers
local streamreader=readers.streamreader
local setposition=streamreader.setposition
local getposition=streamreader.getposition
local skipbytes=streamreader.skip
local readbyte=streamreader.readcardinal1 
local readushort=streamreader.readcardinal2 
local readulong=streamreader.readcardinal4 
local readchar=streamreader.readinteger1  
local readshort=streamreader.readinteger2  
local read2dot14=streamreader.read2dot14   
local readinteger=streamreader.readinteger1
local readcardinaltable=streamreader.readcardinaltable
local readintegertable=streamreader.readintegertable
directives.register("fonts.streamreader",function()
  streamreader=utilities.streams
  setposition=streamreader.setposition
  getposition=streamreader.getposition
  skipbytes=streamreader.skip
  readbyte=streamreader.readcardinal1
  readushort=streamreader.readcardinal2
  readulong=streamreader.readcardinal4
  readchar=streamreader.readinteger1
  readshort=streamreader.readinteger2
  read2dot14=streamreader.read2dot14
  readinteger=streamreader.readinteger1
  readcardinaltable=streamreader.readcardinaltable
  readintegertable=streamreader.readintegertable
end)
local short=2
local ushort=2
local ulong=4
local helpers=readers.helpers
local gotodatatable=helpers.gotodatatable
local function mergecomposites(glyphs,shapes)
  local function merge(index,shape,components)
    local contours={}
    local points={}
    local nofcontours=0
    local nofpoints=0
    local offset=0
    local deltas=shape.deltas
    for i=1,#components do
      local component=components[i]
      local subindex=component.index
      local subshape=shapes[subindex]
      local subcontours=subshape.contours
      local subpoints=subshape.points
      if not subcontours then
        local subcomponents=subshape.components
        if subcomponents then
          subcontours,subpoints=merge(subindex,subshape,subcomponents)
        end
      end
      if subpoints then
        local matrix=component.matrix
        local xscale=matrix[1]
        local xrotate=matrix[2]
        local yrotate=matrix[3]
        local yscale=matrix[4]
        local xoffset=matrix[5]
        local yoffset=matrix[6]
        for i=1,#subpoints do
          local p=subpoints[i]
          local x=p[1]
          local y=p[2]
          nofpoints=nofpoints+1
          points[nofpoints]={
            xscale*x+xrotate*y+xoffset,
            yscale*y+yrotate*x+yoffset,
            p[3]
          }
        end
        for i=1,#subcontours do
          nofcontours=nofcontours+1
          contours[nofcontours]=offset+subcontours[i]
        end
        offset=offset+#subpoints
      else
        report("missing contours composite %s, component %s of %s, glyph %s",index,i,#components,subindex)
      end
    end
    shape.points=points 
    shape.contours=contours
    shape.components=nil
    return contours,points
  end
  for index=1,#glyphs do
    local shape=shapes[index]
    if shape then
      local components=shape.components
      if components then
        merge(index,shape,components)
      end
    end
  end
end
local function readnothing(f,nofcontours)
  return {
    type="nothing",
  }
end
local function curveto(m_x,m_y,l_x,l_y,r_x,r_y) 
  return
    l_x+2/3*(m_x-l_x),l_y+2/3*(m_y-l_y),
    r_x+2/3*(m_x-r_x),r_y+2/3*(m_y-r_y),
    r_x,r_y,"c"
end
local function applyaxis(glyph,shape,deltas,dowidth)
  local points=shape.points
  if points then
    local nofpoints=#points
    local h=nofpoints+2 
    local l=nofpoints+1
    local dw=0
    local dl=0
    for i=1,#deltas do
      local deltaset=deltas[i]
      local xvalues=deltaset.xvalues
      local yvalues=deltaset.yvalues
      local dpoints=deltaset.points
      local factor=deltaset.factor
      if dpoints then
        local nofdpoints=#dpoints
        for i=1,nofdpoints do
          local d=dpoints[i]
          local p=points[d]
          if p then
            if xvalues then
              local x=xvalues[i]
              if x and x~=0 then
                p[1]=p[1]+factor*x
              end
            end
            if yvalues then
              local y=yvalues[i]
              if y and y~=0 then
                p[2]=p[2]+factor*y
              end
            end
          elseif dowidth then
            if d==h then
              local x=xvalues[i]
              if x then
                dw=dw+factor*x
              end
            elseif d==l then
              local x=xvalues[i]
              if x then
                dl=dl+factor*x
              end
            end
          end
        end
      else
        for i=1,nofpoints do
          local p=points[i]
          if xvalues then
            local x=xvalues[i]
            if x and x~=0 then
              p[1]=p[1]+factor*x
            end
          end
          if yvalues then
            local y=yvalues[i]
            if y and y~=0 then
              p[2]=p[2]+factor*y
            end
          end
        end
        if dowidth then
          local x=xvalues[h]
          if x then
            dw=dw+factor*x
          end
          local x=xvalues[l]
          if x then
            dl=dl+factor*x
          end
        end
      end
    end
    if dowidth then
      local width=glyph.width or 0
      glyph.width=width+dw-dl
    end
  else
    report("no points for glyph %a",glyph.name)
  end
end
local quadratic=false
local function contours2outlines_normal(glyphs,shapes) 
  for index=1,#glyphs do
    local shape=shapes[index]
    if shape then
      local glyph=glyphs[index]
      local contours=shape.contours
      local points=shape.points
      if contours then
        local nofcontours=#contours
        local segments={}
        local nofsegments=0
        glyph.segments=segments
        if nofcontours>0 then
          local px,py=0,0 
          local first=1
          for i=1,nofcontours do
            local last=contours[i]
            if last>=first then
              local first_pt=points[first]
              local first_on=first_pt[3]
              if first==last then
                first_pt[3]="m" 
                nofsegments=nofsegments+1
                segments[nofsegments]=first_pt
              else 
                local first_on=first_pt[3]
                local last_pt=points[last]
                local last_on=last_pt[3]
                local start=1
                local control_pt=false
                if first_on then
                  start=2
                else
                  if last_on then
                    first_pt=last_pt
                  else
                    first_pt={ (first_pt[1]+last_pt[1])/2,(first_pt[2]+last_pt[2])/2,false }
                  end
                  control_pt=first_pt
                end
                local x,y=first_pt[1],first_pt[2]
                if not done then
                  xmin,ymin,xmax,ymax=x,y,x,y
                  done=true
                end
                nofsegments=nofsegments+1
                segments[nofsegments]={ x,y,"m" } 
                if not quadratic then
                  px,py=x,y
                end
                local previous_pt=first_pt
                for i=first,last do
                  local current_pt=points[i]
                  local current_on=current_pt[3]
                  local previous_on=previous_pt[3]
                  if previous_on then
                    if current_on then
                      local x,y=current_pt[1],current_pt[2]
                      nofsegments=nofsegments+1
                      segments[nofsegments]={ x,y,"l" } 
                      if not quadratic then
                        px,py=x,y
                      end
                    else
                      control_pt=current_pt
                    end
                  elseif current_on then
                    local x1,y1=control_pt[1],control_pt[2]
                    local x2,y2=current_pt[1],current_pt[2]
                    nofsegments=nofsegments+1
                    if quadratic then
                      segments[nofsegments]={ x1,y1,x2,y2,"q" } 
                    else
                      x1,y1,x2,y2,px,py=curveto(x1,y1,px,py,x2,y2)
                      segments[nofsegments]={ x1,y1,x2,y2,px,py,"c" } 
                    end
                    control_pt=false
                  else
                    local x2,y2=(previous_pt[1]+current_pt[1])/2,(previous_pt[2]+current_pt[2])/2
                    local x1,y1=control_pt[1],control_pt[2]
                    nofsegments=nofsegments+1
                    if quadratic then
                      segments[nofsegments]={ x1,y1,x2,y2,"q" } 
                    else
                      x1,y1,x2,y2,px,py=curveto(x1,y1,px,py,x2,y2)
                      segments[nofsegments]={ x1,y1,x2,y2,px,py,"c" } 
                    end
                    control_pt=current_pt
                  end
                  previous_pt=current_pt
                end
                if first_pt==last_pt then
                else
                  nofsegments=nofsegments+1
                  local x2,y2=first_pt[1],first_pt[2]
                  if not control_pt then
                    segments[nofsegments]={ x2,y2,"l" } 
                  elseif quadratic then
                    local x1,y1=control_pt[1],control_pt[2]
                    segments[nofsegments]={ x1,y1,x2,y2,"q" } 
                  else
                    local x1,y1=control_pt[1],control_pt[2]
                    x1,y1,x2,y2,px,py=curveto(x1,y1,px,py,x2,y2)
                    segments[nofsegments]={ x1,y1,x2,y2,px,py,"c" }
                  end
                end
              end
            end
            first=last+1
          end
        end
      end
    end
  end
end
local function contours2outlines_shaped(glyphs,shapes,keepcurve)
  for index=1,#glyphs do
    local shape=shapes[index]
    if shape then
      local glyph=glyphs[index]
      local contours=shape.contours
      local points=shape.points
      if contours then
        local nofcontours=#contours
        local segments=keepcurve and {} or nil
        local nofsegments=0
        if keepcurve then
          glyph.segments=segments
        end
        if nofcontours>0 then
          local xmin,ymin,xmax,ymax,done=0,0,0,0,false
          local px,py=0,0 
          local first=1
          for i=1,nofcontours do
            local last=contours[i]
            if last>=first then
              local first_pt=points[first]
              local first_on=first_pt[3]
              if first==last then
                if keepcurve then
                  first_pt[3]="m" 
                  nofsegments=nofsegments+1
                  segments[nofsegments]=first_pt
                end
              else 
                local first_on=first_pt[3]
                local last_pt=points[last]
                local last_on=last_pt[3]
                local start=1
                local control_pt=false
                if first_on then
                  start=2
                else
                  if last_on then
                    first_pt=last_pt
                  else
                    first_pt={ (first_pt[1]+last_pt[1])/2,(first_pt[2]+last_pt[2])/2,false }
                  end
                  control_pt=first_pt
                end
                local x,y=first_pt[1],first_pt[2]
                if not done then
                  xmin,ymin,xmax,ymax=x,y,x,y
                  done=true
                else
                  if x<xmin then xmin=x elseif x>xmax then xmax=x end
                  if y<ymin then ymin=y elseif y>ymax then ymax=y end
                end
                if keepcurve then
                  nofsegments=nofsegments+1
                  segments[nofsegments]={ x,y,"m" } 
                end
                if not quadratic then
                  px,py=x,y
                end
                local previous_pt=first_pt
                for i=first,last do
                  local current_pt=points[i]
                  local current_on=current_pt[3]
                  local previous_on=previous_pt[3]
                  if previous_on then
                    if current_on then
                      local x,y=current_pt[1],current_pt[2]
                      if x<xmin then xmin=x elseif x>xmax then xmax=x end
                      if y<ymin then ymin=y elseif y>ymax then ymax=y end
                      if keepcurve then
                        nofsegments=nofsegments+1
                        segments[nofsegments]={ x,y,"l" } 
                      end
                      if not quadratic then
                        px,py=x,y
                      end
                    else
                      control_pt=current_pt
                    end
                  elseif current_on then
                    local x1,y1=control_pt[1],control_pt[2]
                    local x2,y2=current_pt[1],current_pt[2]
                    if quadratic then
                      if x1<xmin then xmin=x1 elseif x1>xmax then xmax=x1 end
                      if y1<ymin then ymin=y1 elseif y1>ymax then ymax=y1 end
                      if keepcurve then
                        nofsegments=nofsegments+1
                        segments[nofsegments]={ x1,y1,x2,y2,"q" } 
                      end
                    else
                      x1,y1,x2,y2,px,py=curveto(x1,y1,px,py,x2,y2)
                      if x1<xmin then xmin=x1 elseif x1>xmax then xmax=x1 end
                      if y1<ymin then ymin=y1 elseif y1>ymax then ymax=y1 end
                      if x2<xmin then xmin=x2 elseif x2>xmax then xmax=x2 end
                      if y2<ymin then ymin=y2 elseif y2>ymax then ymax=y2 end
                      if px<xmin then xmin=px elseif px>xmax then xmax=px end
                      if py<ymin then ymin=py elseif py>ymax then ymax=py end
                      if keepcurve then
                        nofsegments=nofsegments+1
                        segments[nofsegments]={ x1,y1,x2,y2,px,py,"c" } 
                      end
                    end
                    control_pt=false
                  else
                    local x2,y2=(previous_pt[1]+current_pt[1])/2,(previous_pt[2]+current_pt[2])/2
                    local x1,y1=control_pt[1],control_pt[2]
                    if quadratic then
                      if x1<xmin then xmin=x1 elseif x1>xmax then xmax=x1 end
                      if y1<ymin then ymin=y1 elseif y1>ymax then ymax=y1 end
                      if keepcurve then
                        nofsegments=nofsegments+1
                        segments[nofsegments]={ x1,y1,x2,y2,"q" } 
                      end
                    else
                      x1,y1,x2,y2,px,py=curveto(x1,y1,px,py,x2,y2)
                      if x1<xmin then xmin=x1 elseif x1>xmax then xmax=x1 end
                      if y1<ymin then ymin=y1 elseif y1>ymax then ymax=y1 end
                      if x2<xmin then xmin=x2 elseif x2>xmax then xmax=x2 end
                      if y2<ymin then ymin=y2 elseif y2>ymax then ymax=y2 end
                      if px<xmin then xmin=px elseif px>xmax then xmax=px end
                      if py<ymin then ymin=py elseif py>ymax then ymax=py end
                      if keepcurve then
                        nofsegments=nofsegments+1
                        segments[nofsegments]={ x1,y1,x2,y2,px,py,"c" } 
                      end
                    end
                    control_pt=current_pt
                  end
                  previous_pt=current_pt
                end
                if first_pt==last_pt then
                elseif not control_pt then
                  if keepcurve then
                    nofsegments=nofsegments+1
                    segments[nofsegments]={ first_pt[1],first_pt[2],"l" } 
                  end
                else
                  local x1,y1=control_pt[1],control_pt[2]
                  local x2,y2=first_pt[1],first_pt[2]
                  if x1<xmin then xmin=x1 elseif x1>xmax then xmax=x1 end
                  if y1<ymin then ymin=y1 elseif y1>ymax then ymax=y1 end
                  if quadratic then
                    if keepcurve then
                      nofsegments=nofsegments+1
                      segments[nofsegments]={ x1,y1,x2,y2,"q" } 
                    end
                  else
                    x1,y1,x2,y2,px,py=curveto(x1,y1,px,py,x2,y2)
                    if x2<xmin then xmin=x2 elseif x2>xmax then xmax=x2 end
                    if y2<ymin then ymin=y2 elseif y2>ymax then ymax=y2 end
                    if px<xmin then xmin=px elseif px>xmax then xmax=px end
                    if py<ymin then ymin=py elseif py>ymax then ymax=py end
                    if keepcurve then
                      nofsegments=nofsegments+1
                      segments[nofsegments]={ x1,y1,x2,y2,px,py,"c" } 
                    end
                  end
                end
              end
            end
            first=last+1
          end
          glyph.boundingbox={ round(xmin),round(ymin),round(xmax),round(ymax) }
        end
      end
    end
  end
end
local c_zero=char(0)
local s_zero=char(0,0)
local function toushort(n)
  return char(band(rshift(n,8),0xFF),band(n,0xFF))
end
local function toshort(n)
  if n<0 then
    n=n+0x10000
  end
  return char(band(rshift(n,8),0xFF),band(n,0xFF))
end
local function repackpoints(glyphs,shapes)
  local noboundingbox={ 0,0,0,0 }
  local result={} 
  for index=1,#glyphs do
    local shape=shapes[index]
    if shape then
      local r=0
      local glyph=glyphs[index]
      if false then
      else
        local contours=shape.contours
        local nofcontours=contours and #contours or 0
        local boundingbox=glyph.boundingbox or noboundingbox
        r=r+1 result[r]=toshort(nofcontours)
        r=r+1 result[r]=toshort(boundingbox[1]) 
        r=r+1 result[r]=toshort(boundingbox[2]) 
        r=r+1 result[r]=toshort(boundingbox[3]) 
        r=r+1 result[r]=toshort(boundingbox[4]) 
        if nofcontours>0 then
          for i=1,nofcontours do
            r=r+1 result[r]=toshort(contours[i]-1)
          end
          r=r+1 result[r]=s_zero 
          local points=shape.points
          local currentx=0
          local currenty=0
          local xpoints={}
          local ypoints={}
          local x=0
          local y=0
          local lastflag=nil
          local nofflags=0
          for i=1,#points do
            local pt=points[i]
            local px=pt[1]
            local py=pt[2]
            local fl=pt[3] and 0x01 or 0x00
            if px==currentx then
              fl=fl+0x10
            else
              local dx=round(px-currentx)
              if dx<-255 or dx>255 then
                x=x+1 xpoints[x]=toshort(dx)
              elseif dx<0 then
                fl=fl+0x02
                x=x+1 xpoints[x]=char(-dx)
              elseif dx>0 then
                fl=fl+0x12
                x=x+1 xpoints[x]=char(dx)
              else
                fl=fl+0x02
                x=x+1 xpoints[x]=c_zero
              end
            end
            if py==currenty then
              fl=fl+0x20
            else
              local dy=round(py-currenty)
              if dy<-255 or dy>255 then
                y=y+1 ypoints[y]=toshort(dy)
              elseif dy<0 then
                fl=fl+0x04
                y=y+1 ypoints[y]=char(-dy)
              elseif dy>0 then
                fl=fl+0x24
                y=y+1 ypoints[y]=char(dy)
              else
                fl=fl+0x04
                y=y+1 ypoints[y]=c_zero
              end
            end
            currentx=px
            currenty=py
            if lastflag==fl then
              nofflags=nofflags+1
            else 
              if nofflags==1 then
                r=r+1 result[r]=char(lastflag)
              elseif nofflags==2 then
                r=r+1 result[r]=char(lastflag,lastflag)
              elseif nofflags>2 then
                lastflag=lastflag+0x08
                r=r+1 result[r]=char(lastflag,nofflags-1)
              end
              nofflags=1
              lastflag=fl
            end
          end
          if nofflags==1 then
            r=r+1 result[r]=char(lastflag)
          elseif nofflags==2 then
            r=r+1 result[r]=char(lastflag,lastflag)
          elseif nofflags>2 then
            lastflag=lastflag+0x08
            r=r+1 result[r]=char(lastflag,nofflags-1)
          end
          r=r+1 result[r]=concat(xpoints)
          r=r+1 result[r]=concat(ypoints)
        end
      end
      glyph.stream=concat(result,"",1,r)
    else
    end
  end
end
local function readglyph(f,nofcontours) 
  local points={}
  local instructions={}
  local flags={}
  local contours={} 
  for i=1,nofcontours do
    contours[i]=readshort(f)+1
  end
  local nofpoints=contours[nofcontours]
  local nofinstructions=readushort(f)
  skipbytes(f,nofinstructions)
  local i=1
  while i<=nofpoints do
    local flag=readbyte(f)
    flags[i]=flag
    if band(flag,0x08)~=0 then
      for j=1,readbyte(f) do
        i=i+1
        flags[i]=flag
      end
    end
    i=i+1
  end
  local x=0
  for i=1,nofpoints do
    local flag=flags[i]
    local short=band(flag,0x02)~=0
    local same=band(flag,0x10)~=0
    if short then
      if same then
        x=x+readbyte(f)
      else
        x=x-readbyte(f)
      end
    elseif same then
    else
      x=x+readshort(f)
    end
    points[i]={ x,0,band(flag,0x01)~=0 }
  end
  local y=0
  for i=1,nofpoints do
    local flag=flags[i]
    local short=band(flag,0x04)~=0
    local same=band(flag,0x20)~=0
    if short then
      if same then
        y=y+readbyte(f)
      else
        y=y-readbyte(f)
      end
    elseif same then
    else
      y=y+readshort(f)
    end
    points[i][2]=y
  end
  return {
    type="glyph",
    points=points,
    contours=contours,
    nofpoints=nofpoints,
  }
end
local function readcomposite(f)
  local components={}
  local nofcomponents=0
  local instructions=false
  while true do
    local flags=readushort(f)
    local index=readushort(f)
    local f_xyarg=band(flags,0x0002)~=0
    local f_offset=band(flags,0x0800)~=0
    local xscale=1
    local xrotate=0
    local yrotate=0
    local yscale=1
    local xoffset=0
    local yoffset=0
    local base=false
    local reference=false
    if f_xyarg then
      if band(flags,0x0001)~=0 then 
        xoffset=readshort(f)
        yoffset=readshort(f)
      else
        xoffset=readchar(f) 
        yoffset=readchar(f) 
      end
    else
      if band(flags,0x0001)~=0 then 
        base=readshort(f)
        reference=readshort(f)
      else
        base=readchar(f) 
        reference=readchar(f) 
      end
    end
    if band(flags,0x0008)~=0 then 
      xscale=read2dot14(f)
      yscale=xscale
      if f_xyarg and f_offset then
        xoffset=xoffset*xscale
        yoffset=yoffset*yscale
      end
    elseif band(flags,0x0040)~=0 then 
      xscale=read2dot14(f)
      yscale=read2dot14(f)
      if f_xyarg and f_offset then
        xoffset=xoffset*xscale
        yoffset=yoffset*yscale
      end
    elseif band(flags,0x0080)~=0 then 
      xscale=read2dot14(f)
      xrotate=read2dot14(f)
      yrotate=read2dot14(f)
      yscale=read2dot14(f)
      if f_xyarg and f_offset then
        xoffset=xoffset*sqrt(xscale^2+xrotate^2)
        yoffset=yoffset*sqrt(yrotate^2+yscale^2)
      end
    end
    nofcomponents=nofcomponents+1
    components[nofcomponents]={
      index=index,
      usemine=band(flags,0x0200)~=0,
      round=band(flags,0x0006)~=0,
      base=base,
      reference=reference,
      matrix={ xscale,xrotate,yrotate,yscale,xoffset,yoffset },
    }
    if band(flags,0x0100)~=0 then
      instructions=true
    end
    if not band(flags,0x0020)~=0 then 
      break
    end
  end
  return {
    type="composite",
    components=components,
  }
end
function readers.loca(f,fontdata,specification)
  if specification.glyphs then
    local datatable=fontdata.tables.loca
    if datatable then
      local offset=fontdata.tables.glyf.offset
      local format=fontdata.fontheader.indextolocformat
      local locations={}
      setposition(f,datatable.offset)
      if format==1 then
        local nofglyphs=datatable.length/4-2
        for i=0,nofglyphs do
          locations[i]=offset+readulong(f)
        end
        fontdata.nofglyphs=nofglyphs
      else
        local nofglyphs=datatable.length/2-2
        for i=0,nofglyphs do
          locations[i]=offset+readushort(f)*2
        end
        fontdata.nofglyphs=nofglyphs
      end
      fontdata.locations=locations
    end
  end
end
function readers.glyf(f,fontdata,specification) 
  local tableoffset=gotodatatable(f,fontdata,"glyf",specification.glyphs)
  if tableoffset then
    local locations=fontdata.locations
    if locations then
      local glyphs=fontdata.glyphs
      local nofglyphs=fontdata.nofglyphs
      local filesize=fontdata.filesize
      local nothing={ 0,0,0,0 }
      local shapes={}
      local loadshapes=specification.shapes or specification.instance
      for index=0,nofglyphs do
        local location=locations[index]
        if location>=filesize then
          report("discarding %s glyphs due to glyph location bug",nofglyphs-index+1)
          fontdata.nofglyphs=index-1
          fontdata.badfont=true
          break
        elseif location>0 then
          setposition(f,location)
          local nofcontours=readshort(f)
          glyphs[index].boundingbox={
            readshort(f),
            readshort(f),
            readshort(f),
            readshort(f),
          }
          if not loadshapes then
          elseif nofcontours==0 then
            shapes[index]=readnothing(f,nofcontours)
          elseif nofcontours>0 then
            shapes[index]=readglyph(f,nofcontours)
          else
            shapes[index]=readcomposite(f,nofcontours)
          end
        else
          if loadshapes then
            shapes[index]={}
          end
          glyphs[index].boundingbox=nothing
        end
      end
      if loadshapes then
        if readers.gvar then
          readers.gvar(f,fontdata,specification,glyphs,shapes)
        end
        mergecomposites(glyphs,shapes)
        if specification.instance then
          if specification.streams then
            repackpoints(glyphs,shapes)
          else
            contours2outlines_shaped(glyphs,shapes,specification.shapes)
          end
        elseif specification.shapes then
          contours2outlines_normal(glyphs,shapes)
        end
      end
    end
  end
end
local function readtuplerecord(f,nofaxis)
  local record={}
  for i=1,nofaxis do
    record[i]=read2dot14(f)
  end
  return record
end
local function readpoints(f)
  local count=readbyte(f)
  if count==0 then
    return nil,0 
  else
    if count<128 then
    elseif band(count,0x80)~=0 then
      count=band(count,0x7F)*256+readbyte(f)
    else
    end
    local points={}
    local p=0
    local n=1 
    while p<count do
      local control=readbyte(f)
      local runreader=band(control,0x80)~=0 and readushort or readbyte
      local runlength=band(control,0x7F)
      for i=1,runlength+1 do
        n=n+runreader(f)
        p=p+1
        points[p]=n
      end
    end
    return points,p
  end
end
local function readdeltas(f,nofpoints)
  local deltas={}
  local p=0
  local z=0
  while nofpoints>0 do
    local control=readbyte(f)
if not control then
  break
end
    local allzero=band(control,0x80)~=0
    local runlength=band(control,0x3F)+1
    if allzero then
      z=z+runlength
    else
      local runreader=band(control,0x40)~=0 and readshort or readinteger
      if z>0 then
        for i=1,z do
          p=p+1
          deltas[p]=0
        end
        z=0
      end
      for i=1,runlength do
        p=p+1
        deltas[p]=runreader(f)
      end
    end
    nofpoints=nofpoints-runlength
  end
  if p>0 then
    return deltas
  else
  end
end
local function readdeltas(f,nofpoints)
  local deltas={}
  local p=0
  while nofpoints>0 do
    local control=readbyte(f)
    if control then
      local allzero=band(control,0x80)~=0
      local runlength=band(control,0x3F)+1
      if allzero then
        for i=1,runlength do
          p=p+1
          deltas[p]=0
        end
      else
        local runreader=band(control,0x40)~=0 and readshort or readinteger
        for i=1,runlength do
          p=p+1
          deltas[p]=runreader(f)
        end
      end
      nofpoints=nofpoints-runlength
    else
      break
    end
  end
  if p>0 then
    return deltas
  else
  end
end
function readers.gvar(f,fontdata,specification,glyphdata,shapedata)
  local instance=specification.instance
  if not instance then
    return
  end
  local factors=specification.factors
  if not factors then
    return
  end
  local tableoffset=gotodatatable(f,fontdata,"gvar",specification.variable or specification.shapes)
  if tableoffset then
    local version=readulong(f) 
    local nofaxis=readushort(f)
    local noftuples=readushort(f)
    local tupleoffset=tableoffset+readulong(f)
    local nofglyphs=readushort(f)
    local flags=readushort(f)
    local dataoffset=tableoffset+readulong(f)
    local data={}
    local tuples={}
    local glyphdata=fontdata.glyphs
    local dowidth=not fontdata.variabledata.hvarwidths
    if band(flags,0x0001)~=0 then
      for i=1,nofglyphs+1 do
        data[i]=dataoffset+readulong(f)
      end
    else
      for i=1,nofglyphs+1 do
        data[i]=dataoffset+2*readushort(f)
      end
    end
    if noftuples>0 then
      setposition(f,tupleoffset)
      for i=1,noftuples do
        tuples[i]=readtuplerecord(f,nofaxis)
      end
    end
    local nextoffset=false
    local startoffset=data[1]
    for i=1,nofglyphs do 
      nextoffset=data[i+1]
      local glyph=glyphdata[i-1]
      local name=trace_deltas and glyph.name
      if startoffset==nextoffset then
        if name then
          report("no deltas for glyph %a",name)
        end
      else
        local shape=shapedata[i-1] 
        if not shape then
          if name then
            report("no shape for glyph %a",name)
          end
        else
          lastoffset=startoffset
          setposition(f,startoffset)
          local flags=readushort(f)
          local count=band(flags,0x0FFF)
          local offset=startoffset+readushort(f) 
          local deltas={}
          local allpoints=(shape.nofpoints or 0) 
          local shared=false
          local nofshared=0
          if band(flags,0x8000)~=0 then
            local current=getposition(f)
            setposition(f,offset)
            shared,nofshared=readpoints(f)
            offset=getposition(f)
            setposition(f,current)
          end
          for j=1,count do
            local size=readushort(f) 
            local flags=readushort(f)
            local index=band(flags,0x0FFF)
            local haspeak=band(flags,0x8000)~=0
            local intermediate=band(flags,0x4000)~=0
            local private=band(flags,0x2000)~=0
            local peak=nil
            local start=nil
            local stop=nil
            local xvalues=nil
            local yvalues=nil
            local points=shared  
            local nofpoints=nofshared
            if haspeak then
              peak=readtuplerecord(f,nofaxis)
            else
              if index+1>#tuples then
                report("error, bad tuple index",index)
              end
              peak=tuples[index+1] 
            end
            if intermediate then
              start=readtuplerecord(f,nofaxis)
              stop=readtuplerecord(f,nofaxis)
            end
            if size>0 then
              local current=getposition(f)
              setposition(f,offset)
              if private then
                points,nofpoints=readpoints(f)
              end 
              if nofpoints==0 then
                nofpoints=allpoints+4
              end
              if nofpoints>0 then
                xvalues=readdeltas(f,nofpoints)
                yvalues=readdeltas(f,nofpoints)
              end
              offset=offset+size
              setposition(f,current)
            end
            if not xvalues and not yvalues then
              points=nil
            end
            local s=1
            for i=1,nofaxis do
              local f=factors[i]
              local peak=peak and peak [i] or 0
              local start=start and start[i] or (peak<0 and peak or 0)
              local stop=stop and stop [i] or (peak>0 and peak or 0)
              if start>peak or peak>stop then
              elseif start<0 and stop>0 and peak~=0 then
              elseif peak==0 then
              elseif f<start or f>stop then
                s=0
                break
              elseif f<peak then
                s=s*(f-start)/(peak-start)
              elseif f>peak then
                s=s*(stop-f)/(stop-peak)
              else
              end
            end
            if s==0 then
              if name then
                report("no deltas applied for glyph %a",name)
              end
            else
              deltas[#deltas+1]={
                factor=s,
                points=points,
                xvalues=xvalues,
                yvalues=yvalues,
              }
            end
          end
          if shape.type=="glyph" then
            applyaxis(glyph,shape,deltas,dowidth)
          else
            shape.deltas=deltas
          end
        end
      end
      startoffset=nextoffset
    end
  end
end

end --- [luaotfload, fontloader-2018-10-08.lua scope for “font-ttf”] ---


do  --- [luaotfload, fontloader-2018-10-08.lua scope for “font-dsp” cb8138a91cfbe562467821c5e0c2568e] ---

if not modules then modules={} end modules ['font-dsp']={
  version=1.001,
  comment="companion to font-ini.mkiv",
  author="Hans Hagen, PRAGMA-ADE, Hasselt NL",
  copyright="PRAGMA ADE / ConTeXt Development Team",
  license="see context related readme files"
}
local next,type,tonumber=next,type,tonumber
local band=bit32.band
local extract=bit32.extract
local bor=bit32.bor
local lshift=bit32.lshift
local rshift=bit32.rshift
local gsub=string.gsub
local lower=string.lower
local sub=string.sub
local strip=string.strip
local tohash=table.tohash
local concat=table.concat
local copy=table.copy
local reversed=table.reversed
local sort=table.sort
local insert=table.insert
local round=math.round
local settings_to_hash=utilities.parsers.settings_to_hash_colon_too
local setmetatableindex=table.setmetatableindex
local formatters=string.formatters
local sortedkeys=table.sortedkeys
local sortedhash=table.sortedhash
local sequenced=table.sequenced
local report=logs.reporter("otf reader")
local readers=fonts.handlers.otf.readers
local streamreader=readers.streamreader
local setposition=streamreader.setposition
local getposition=streamreader.getposition
local readushort=streamreader.readcardinal2 
local readulong=streamreader.readcardinal4 
local readinteger=streamreader.readinteger1
local readshort=streamreader.readinteger2  
local readstring=streamreader.readstring
local readtag=streamreader.readtag
local readbytes=streamreader.readbytes
local readfixed=streamreader.readfixed4
local read2dot14=streamreader.read2dot14
local skipshort=streamreader.skipshort
local skipbytes=streamreader.skip
local readbytetable=streamreader.readbytetable
local readbyte=streamreader.readbyte
local readcardinaltable=streamreader.readcardinaltable
local readintegertable=streamreader.readintegertable
local readfword=readshort
local short=2
local ushort=2
local ulong=4
directives.register("fonts.streamreader",function()
  streamreader=utilities.streams
  setposition=streamreader.setposition
  getposition=streamreader.getposition
  readushort=streamreader.readcardinal2
  readulong=streamreader.readcardinal4
  readinteger=streamreader.readinteger1
  readshort=streamreader.readinteger2
  readstring=streamreader.readstring
  readtag=streamreader.readtag
  readbytes=streamreader.readbytes
  readfixed=streamreader.readfixed4
  read2dot14=streamreader.read2dot14
  skipshort=streamreader.skipshort
  skipbytes=streamreader.skip
  readbytetable=streamreader.readbytetable
  readbyte=streamreader.readbyte
  readcardinaltable=streamreader.readcardinaltable
  readintegertable=streamreader.readintegertable
  readfword=readshort
end)
local gsubhandlers={}
local gposhandlers={}
readers.gsubhandlers=gsubhandlers
readers.gposhandlers=gposhandlers
local helpers=readers.helpers
local gotodatatable=helpers.gotodatatable
local setvariabledata=helpers.setvariabledata
local lookupidoffset=-1  
local classes={
  "base",
  "ligature",
  "mark",
  "component",
}
local gsubtypes={
  "single",
  "multiple",
  "alternate",
  "ligature",
  "context",
  "chainedcontext",
  "extension",
  "reversechainedcontextsingle",
}
local gpostypes={
  "single",
  "pair",
  "cursive",
  "marktobase",
  "marktoligature",
  "marktomark",
  "context",
  "chainedcontext",
  "extension",
}
local chaindirections={
  context=0,
  chainedcontext=1,
  reversechainedcontextsingle=-1,
}
local function setmetrics(data,where,tag,d)
  local w=data[where]
  if w then
    local v=w[tag]
    if v then
      w[tag]=v+d
    end
  end
end
local variabletags={
  hasc=function(data,d) setmetrics(data,"windowsmetrics","typoascender",d) end,
  hdsc=function(data,d) setmetrics(data,"windowsmetrics","typodescender",d) end,
  hlgp=function(data,d) setmetrics(data,"windowsmetrics","typolinegap",d) end,
  hcla=function(data,d) setmetrics(data,"windowsmetrics","winascent",d) end,
  hcld=function(data,d) setmetrics(data,"windowsmetrics","windescent",d) end,
  vasc=function(data,d) setmetrics(data,"vhea not done","ascent",d) end,
  vdsc=function(data,d) setmetrics(data,"vhea not done","descent",d) end,
  vlgp=function(data,d) setmetrics(data,"vhea not done","linegap",d) end,
  xhgt=function(data,d) setmetrics(data,"windowsmetrics","xheight",d) end,
  cpht=function(data,d) setmetrics(data,"windowsmetrics","capheight",d) end,
  sbxs=function(data,d) setmetrics(data,"windowsmetrics","subscriptxsize",d) end,
  sbys=function(data,d) setmetrics(data,"windowsmetrics","subscriptysize",d) end,
  sbxo=function(data,d) setmetrics(data,"windowsmetrics","subscriptxoffset",d) end,
  sbyo=function(data,d) setmetrics(data,"windowsmetrics","subscriptyoffset",d) end,
  spxs=function(data,d) setmetrics(data,"windowsmetrics","superscriptxsize",d) end,
  spys=function(data,d) setmetrics(data,"windowsmetrics","superscriptysize",d) end,
  spxo=function(data,d) setmetrics(data,"windowsmetrics","superscriptxoffset",d) end,
  spyo=function(data,d) setmetrics(data,"windowsmetrics","superscriptyoffset",d) end,
  strs=function(data,d) setmetrics(data,"windowsmetrics","strikeoutsize",d) end,
  stro=function(data,d) setmetrics(data,"windowsmetrics","strikeoutpos",d) end,
  unds=function(data,d) setmetrics(data,"postscript","underlineposition",d) end,
  undo=function(data,d) setmetrics(data,"postscript","underlinethickness",d) end,
}
local read_cardinal={
  streamreader.readcardinal1,
  streamreader.readcardinal2,
  streamreader.readcardinal3,
  streamreader.readcardinal4,
}
local read_integer={
  streamreader.readinteger1,
  streamreader.readinteger2,
  streamreader.readinteger3,
  streamreader.readinteger4,
}
local lookupnames={
  gsub={
    single="gsub_single",
    multiple="gsub_multiple",
    alternate="gsub_alternate",
    ligature="gsub_ligature",
    context="gsub_context",
    chainedcontext="gsub_contextchain",
    reversechainedcontextsingle="gsub_reversecontextchain",
  },
  gpos={
    single="gpos_single",
    pair="gpos_pair",
    cursive="gpos_cursive",
    marktobase="gpos_mark2base",
    marktoligature="gpos_mark2ligature",
    marktomark="gpos_mark2mark",
    context="gpos_context",
    chainedcontext="gpos_contextchain",
  }
}
local lookupflags=setmetatableindex(function(t,k)
  local v={
    band(k,0x0008)~=0 and true or false,
    band(k,0x0004)~=0 and true or false,
    band(k,0x0002)~=0 and true or false,
    band(k,0x0001)~=0 and true or false,
  }
  t[k]=v
  return v
end)
local function axistofactors(str)
  local t=settings_to_hash(str)
  for k,v in next,t do
    t[k]=tonumber(v) or v 
  end
  return t
end
local hash=table.setmetatableindex(function(t,k)
  local v=sequenced(axistofactors(k),",")
  t[k]=v
  return v
end)
helpers.normalizedaxishash=hash
local cleanname=fonts.names and fonts.names.cleanname or function(name)
  return name and (gsub(lower(name),"[^%a%d]","")) or nil
end
helpers.cleanname=cleanname
function helpers.normalizedaxis(str)
  return hash[str] or str
end
local function getaxisscale(segments,minimum,default,maximum,user)
  if not minimum or not default or not maximum then
    return false
  end
  if user<minimum then
    user=minimum
  elseif user>maximum then
    user=maximum
  end
  if user<default then
    default=- (default-user)/(default-minimum)
  elseif user>default then
    default=(user-default)/(maximum-default)
  else
    default=0
  end
  if not segments then
    return default
  end
  local e
  for i=1,#segments do
    local s=segments[i]
    if type(s)~="number" then
      report("using default axis scale")
      return default
    elseif s[1]>=default then
      if s[2]==default then
        return default
      else
        e=i
        break
      end
    end
  end
  if e then
    local b=segments[e-1]
    local e=segments[e]
    return b[2]+(e[2]-b[2])*(default-b[1])/(e[1]-b[1])
  else
    return false
  end
end
local function getfactors(data,instancespec)
  if instancespec==true then
  elseif type(instancespec)~="string" or instancespec=="" then
    return
  end
  local variabledata=data.variabledata
  if not variabledata then
    return
  end
  local instances=variabledata.instances
  local axis=variabledata.axis
  local segments=variabledata.segments
  if instances and axis then
    local values
    if instancespec==true then
      values={}
      for i=1,#axis do
        values[i]={
          value=axis[i].default,
        }
      end
    else
      for i=1,#instances do
        local instance=instances[i]
        if cleanname(instance.subfamily)==instancespec then
          values=instance.values
          break
        end
      end
    end
    if values then
      local factors={}
      for i=1,#axis do
        local a=axis[i]
        factors[i]=getaxisscale(segments,a.minimum,a.default,a.maximum,values[i].value)
      end
      return factors
    end
    local values=axistofactors(hash[instancespec] or instancespec)
    if values then
      local factors={}
      for i=1,#axis do
        local a=axis[i]
        local d=a.default
        factors[i]=getaxisscale(segments,a.minimum,d,a.maximum,values[a.name or a.tag] or d)
      end
      return factors
    end
  end
end
local function getscales(regions,factors)
  local scales={}
  for i=1,#regions do
    local region=regions[i]
    local s=1
    for j=1,#region do
      local axis=region[j]
      local f=factors[j]
      local start=axis.start
      local peak=axis.peak
      local stop=axis.stop
      if start>peak or peak>stop then
      elseif start<0 and stop>0 and peak~=0 then
      elseif peak==0 then
      elseif f<start or f>stop then
        s=0
        break
      elseif f<peak then
        s=s*(f-start)/(peak-start)
      elseif f>peak then
        s=s*(stop-f)/(stop-peak)
      else
      end
    end
    scales[i]=s
  end
  return scales
end
helpers.getaxisscale=getaxisscale
helpers.getfactors=getfactors
helpers.getscales=getscales
helpers.axistofactors=axistofactors
local function readvariationdata(f,storeoffset,factors) 
  local position=getposition(f)
  setposition(f,storeoffset)
  local format=readushort(f)
  local regionoffset=storeoffset+readulong(f)
  local nofdeltadata=readushort(f)
  local deltadata=readcardinaltable(f,nofdeltadata,ulong)
  setposition(f,regionoffset)
  local nofaxis=readushort(f)
  local nofregions=readushort(f)
  local regions={}
  for i=1,nofregions do 
    local t={}
    for i=1,nofaxis do
      t[i]={ 
        start=read2dot14(f),
        peak=read2dot14(f),
        stop=read2dot14(f),
      }
    end
    regions[i]=t
  end
  if factors then
    for i=1,nofdeltadata do
      setposition(f,storeoffset+deltadata[i])
      local nofdeltasets=readushort(f)
      local nofshorts=readushort(f)
      local nofregions=readushort(f)
      local usedregions={}
      local deltas={}
      for i=1,nofregions do
        usedregions[i]=regions[readushort(f)+1]
      end
      for i=1,nofdeltasets do
        local t=readintegertable(f,nofshorts,short)
        for i=nofshorts+1,nofregions do
          t[i]=readinteger(f)
        end
        deltas[i]=t
      end
      deltadata[i]={
        regions=usedregions,
        deltas=deltas,
        scales=factors and getscales(usedregions,factors) or nil,
      }
    end
  end
  setposition(f,position)
  return regions,deltadata
end
helpers.readvariationdata=readvariationdata
local function readcoverage(f,offset,simple)
  setposition(f,offset)
  local coverageformat=readushort(f)
  if coverageformat==1 then
    local nofcoverage=readushort(f)
    if simple then
      if nofcoverage==1 then
        return { readushort(f) }
      elseif nofcoverage==2 then
        return { readushort(f),readushort(f) }
      else
        return readcardinaltable(f,nofcoverage,ushort)
      end
    elseif nofcoverage==1 then
      return { [readushort(f)]=0 }
    elseif nofcoverage==2 then
      return { [readushort(f)]=0,[readushort(f)]=1 }
    else
      local coverage={}
      for i=0,nofcoverage-1 do
        coverage[readushort(f)]=i 
      end
      return coverage
    end
  elseif coverageformat==2 then
    local nofranges=readushort(f)
    local coverage={}
    local n=simple and 1 or 0 
    for i=1,nofranges do
      local firstindex=readushort(f)
      local lastindex=readushort(f)
      local coverindex=readushort(f)
      if simple then
        for i=firstindex,lastindex do
          coverage[n]=i
          n=n+1
        end
      else
        for i=firstindex,lastindex do
          coverage[i]=n
          n=n+1
        end
      end
    end
    return coverage
  else
    report("unknown coverage format %a ",coverageformat)
    return {}
  end
end
local function readclassdef(f,offset,preset)
  setposition(f,offset)
  local classdefformat=readushort(f)
  local classdef={}
  if type(preset)=="number" then
    for k=0,preset-1 do
      classdef[k]=1
    end
  end
  if classdefformat==1 then
    local index=readushort(f)
    local nofclassdef=readushort(f)
    for i=1,nofclassdef do
      classdef[index]=readushort(f)+1
      index=index+1
    end
  elseif classdefformat==2 then
    local nofranges=readushort(f)
    local n=0
    for i=1,nofranges do
      local firstindex=readushort(f)
      local lastindex=readushort(f)
      local class=readushort(f)+1
      for i=firstindex,lastindex do
        classdef[i]=class
      end
    end
  else
    report("unknown classdef format %a ",classdefformat)
  end
  if type(preset)=="table" then
    for k in next,preset do
      if not classdef[k] then
        classdef[k]=1
      end
    end
  end
  return classdef
end
local function classtocoverage(defs)
  if defs then
    local list={}
    for index,class in next,defs do
      local c=list[class]
      if c then
        c[#c+1]=index
      else
        list[class]={ index }
      end
    end
    return list
  end
end
local skips={ [0]=0,
  1,
  1,
  2,
  1,
  2,
  2,
  3,
  2,
  2,
  3,
  2,
  3,
  3,
  4,
}
local function readvariation(f,offset)
  local p=getposition(f)
  setposition(f,offset)
  local outer=readushort(f)
  local inner=readushort(f)
  local format=readushort(f)
  setposition(f,p)
  if format==0x8000 then
    return outer,inner
  end
end
local function readposition(f,format,mainoffset,getdelta)
  if format==0 then
    return false
  end
  if format==0x04 then
    local h=readshort(f)
    if h==0 then
      return true 
    else
      return { 0,0,h,0 }
    end
  end
  if format==0x05 then
    local x=readshort(f)
    local h=readshort(f)
    if x==0 and h==0 then
      return true 
    else
      return { x,0,h,0 }
    end
  end
  if format==0x44 then
    local h=readshort(f)
    if getdelta then
      local d=readshort(f) 
      if d>0 then
        local outer,inner=readvariation(f,mainoffset+d)
        if outer then
          h=h+getdelta(outer,inner)
        end
      end
    else
      skipshort(f,1)
    end
    if h==0 then
      return true 
    else
      return { 0,0,h,0 }
    end
  end
  local x=band(format,0x1)~=0 and readshort(f) or 0 
  local y=band(format,0x2)~=0 and readshort(f) or 0 
  local h=band(format,0x4)~=0 and readshort(f) or 0 
  local v=band(format,0x8)~=0 and readshort(f) or 0 
  if format>=0x10 then
    local X=band(format,0x10)~=0 and skipshort(f) or 0
    local Y=band(format,0x20)~=0 and skipshort(f) or 0
    local H=band(format,0x40)~=0 and skipshort(f) or 0
    local V=band(format,0x80)~=0 and skipshort(f) or 0
    local s=skips[extract(format,4,4)]
    if s>0 then
      skipshort(f,s)
    end
    if getdelta then
      if X>0 then
        local outer,inner=readvariation(f,mainoffset+X)
        if outer then
          x=x+getdelta(outer,inner)
        end
      end
      if Y>0 then
        local outer,inner=readvariation(f,mainoffset+Y)
        if outer then
          y=y+getdelta(outer,inner)
        end
      end
      if H>0 then
        local outer,inner=readvariation(f,mainoffset+H)
        if outer then
          h=h+getdelta(outer,inner)
        end
      end
      if V>0 then
        local outer,inner=readvariation(f,mainoffset+V)
        if outer then
          v=v+getdelta(outer,inner)
        end
      end
    end
    return { x,y,h,v }
  elseif x==0 and y==0 and h==0 and v==0 then
    return true 
  else
    return { x,y,h,v }
  end
end
local function readanchor(f,offset,getdelta) 
  if not offset or offset==0 then
    return nil 
  end
  setposition(f,offset)
  local format=readshort(f) 
  local x=readshort(f)
  local y=readshort(f)
  if format==3 then
    if getdelta then
      local X=readshort(f)
      local Y=readshort(f)
      if X>0 then
        local outer,inner=readvariation(f,offset+X)
        if outer then
          x=x+getdelta(outer,inner)
        end
      end
      if Y>0 then
        local outer,inner=readvariation(f,offset+Y)
        if outer then
          y=y+getdelta(outer,inner)
        end
      end
    else
      skipshort(f,2)
    end
    return { x,y } 
  else
    return { x,y }
  end
end
local function readfirst(f,offset)
  if offset then
    setposition(f,offset)
  end
  return { readushort(f) }
end
function readarray(f,offset)
  if offset then
    setposition(f,offset)
  end
  local n=readushort(f)
  if n==1 then
    return { readushort(f) },1
  elseif n>0 then
    return readcardinaltable(f,n,ushort),n
  end
end
local function readcoveragearray(f,offset,t,simple)
  if not t then
    return nil
  end
  local n=#t
  if n==0 then
    return nil
  end
  for i=1,n do
    t[i]=readcoverage(f,offset+t[i],simple)
  end
  return t
end
local function covered(subset,all)
  local used,u
  for i=1,#subset do
    local s=subset[i]
    if all[s] then
      if used then
        u=u+1
        used[u]=s
      else
        u=1
        used={ s }
      end
    end
  end
  return used
end
local function readlookuparray(f,noflookups,nofcurrent)
  local lookups={}
  if noflookups>0 then
    local length=0
    for i=1,noflookups do
      local index=readushort(f)+1
      if index>length then
        length=index
      end
      local lookup=readushort(f)+1
      local list=lookups[index]
      if list then
        list[#list+1]=lookup
      else
        lookups[index]={ lookup }
      end
    end
    for index=1,length do
      if not lookups[index] then
        lookups[index]=false
      end
    end
  end
  return lookups
end
local function unchainedcontext(f,fontdata,lookupid,lookupoffset,offset,glyphs,nofglyphs,what)
  local tableoffset=lookupoffset+offset
  setposition(f,tableoffset)
  local subtype=readushort(f)
  if subtype==1 then
    local coverage=readushort(f)
    local subclasssets=readarray(f)
    local rules={}
    if subclasssets then
      coverage=readcoverage(f,tableoffset+coverage,true)
      for i=1,#subclasssets do
        local offset=subclasssets[i]
        if offset>0 then
          local firstcoverage=coverage[i]
          local rulesoffset=tableoffset+offset
          local subclassrules=readarray(f,rulesoffset)
          for rule=1,#subclassrules do
            setposition(f,rulesoffset+subclassrules[rule])
            local nofcurrent=readushort(f)
            local noflookups=readushort(f)
            local current={ { firstcoverage } }
            for i=2,nofcurrent do
              current[i]={ readushort(f) }
            end
            local lookups=readlookuparray(f,noflookups,nofcurrent)
            rules[#rules+1]={
              current=current,
              lookups=lookups
            }
          end
        end
      end
    else
      report("empty subclassset in %a subtype %i","unchainedcontext",subtype)
    end
    return {
      format="glyphs",
      rules=rules,
    }
  elseif subtype==2 then
    local coverage=readushort(f)
    local currentclassdef=readushort(f)
    local subclasssets=readarray(f)
    local rules={}
    if subclasssets then
      coverage=readcoverage(f,tableoffset+coverage)
      currentclassdef=readclassdef(f,tableoffset+currentclassdef,coverage)
      local currentclasses=classtocoverage(currentclassdef,fontdata.glyphs)
      for class=1,#subclasssets do
        local offset=subclasssets[class]
        if offset>0 then
          local firstcoverage=currentclasses[class]
          if firstcoverage then
            firstcoverage=covered(firstcoverage,coverage) 
            if firstcoverage then
              local rulesoffset=tableoffset+offset
              local subclassrules=readarray(f,rulesoffset)
              for rule=1,#subclassrules do
                setposition(f,rulesoffset+subclassrules[rule])
                local nofcurrent=readushort(f)
                local noflookups=readushort(f)
                local current={ firstcoverage }
                for i=2,nofcurrent do
                  current[i]=currentclasses[readushort(f)+1]
                end
                local lookups=readlookuparray(f,noflookups,nofcurrent)
                rules[#rules+1]={
                  current=current,
                  lookups=lookups
                }
              end
            else
              report("no coverage")
            end
          else
            report("no coverage class")
          end
        end
      end
    else
      report("empty subclassset in %a subtype %i","unchainedcontext",subtype)
    end
    return {
      format="class",
      rules=rules,
    }
  elseif subtype==3 then
    local nofglyphs=readushort(f)
    local noflookups=readushort(f)
    local current=readcardinaltable(f,nofglyphs,ushort)
    local lookups=readlookuparray(f,noflookups,#current)
    current=readcoveragearray(f,tableoffset,current,true)
    return {
      format="coverage",
      rules={
        {
          current=current,
          lookups=lookups,
        }
      }
    }
  else
    report("unsupported subtype %a in %a %s",subtype,"unchainedcontext",what)
  end
end
local function chainedcontext(f,fontdata,lookupid,lookupoffset,offset,glyphs,nofglyphs,what)
  local tableoffset=lookupoffset+offset
  setposition(f,tableoffset)
  local subtype=readushort(f)
  if subtype==1 then
    local coverage=readushort(f)
    local subclasssets=readarray(f)
    local rules={}
    if subclasssets then
      coverage=readcoverage(f,tableoffset+coverage,true)
      for i=1,#subclasssets do
        local offset=subclasssets[i]
        if offset>0 then
          local firstcoverage=coverage[i]
          local rulesoffset=tableoffset+offset
          local subclassrules=readarray(f,rulesoffset)
          for rule=1,#subclassrules do
            setposition(f,rulesoffset+subclassrules[rule])
            local nofbefore=readushort(f)
            local before
            if nofbefore>0 then
              before={}
              for i=1,nofbefore do
                before[i]={ readushort(f) }
              end
            end
            local nofcurrent=readushort(f)
            local current={ { firstcoverage } }
            for i=2,nofcurrent do
              current[i]={ readushort(f) }
            end
            local nofafter=readushort(f)
            local after
            if nofafter>0 then
              after={}
              for i=1,nofafter do
                after[i]={ readushort(f) }
              end
            end
            local noflookups=readushort(f)
            local lookups=readlookuparray(f,noflookups,nofcurrent)
            rules[#rules+1]={
              before=before,
              current=current,
              after=after,
              lookups=lookups,
            }
          end
        end
      end
    else
      report("empty subclassset in %a subtype %i","chainedcontext",subtype)
    end
    return {
      format="glyphs",
      rules=rules,
    }
  elseif subtype==2 then
    local coverage=readushort(f)
    local beforeclassdef=readushort(f)
    local currentclassdef=readushort(f)
    local afterclassdef=readushort(f)
    local subclasssets=readarray(f)
    local rules={}
    if subclasssets then
      local coverage=readcoverage(f,tableoffset+coverage)
      local beforeclassdef=readclassdef(f,tableoffset+beforeclassdef,nofglyphs)
      local currentclassdef=readclassdef(f,tableoffset+currentclassdef,coverage)
      local afterclassdef=readclassdef(f,tableoffset+afterclassdef,nofglyphs)
      local beforeclasses=classtocoverage(beforeclassdef,fontdata.glyphs)
      local currentclasses=classtocoverage(currentclassdef,fontdata.glyphs)
      local afterclasses=classtocoverage(afterclassdef,fontdata.glyphs)
      for class=1,#subclasssets do
        local offset=subclasssets[class]
        if offset>0 then
          local firstcoverage=currentclasses[class]
          if firstcoverage then
            firstcoverage=covered(firstcoverage,coverage) 
            if firstcoverage then
              local rulesoffset=tableoffset+offset
              local subclassrules=readarray(f,rulesoffset)
              for rule=1,#subclassrules do
                setposition(f,rulesoffset+subclassrules[rule])
                local nofbefore=readushort(f)
                local before
                if nofbefore>0 then
                  before={}
                  for i=1,nofbefore do
                    before[i]=beforeclasses[readushort(f)+1]
                  end
                end
                local nofcurrent=readushort(f)
                local current={ firstcoverage }
                for i=2,nofcurrent do
                  current[i]=currentclasses[readushort(f)+1]
                end
                local nofafter=readushort(f)
                local after
                if nofafter>0 then
                  after={}
                  for i=1,nofafter do
                    after[i]=afterclasses[readushort(f)+1]
                  end
                end
                local noflookups=readushort(f)
                local lookups=readlookuparray(f,noflookups,nofcurrent)
                rules[#rules+1]={
                  before=before,
                  current=current,
                  after=after,
                  lookups=lookups,
                }
              end
            else
              report("no coverage")
            end
          else
            report("class is not covered")
          end
        end
      end
    else
      report("empty subclassset in %a subtype %i","chainedcontext",subtype)
    end
    return {
      format="class",
      rules=rules,
    }
  elseif subtype==3 then
    local before=readarray(f)
    local current=readarray(f)
    local after=readarray(f)
    local noflookups=readushort(f)
    local lookups=readlookuparray(f,noflookups,#current)
    before=readcoveragearray(f,tableoffset,before,true)
    current=readcoveragearray(f,tableoffset,current,true)
    after=readcoveragearray(f,tableoffset,after,true)
    return {
      format="coverage",
      rules={
        {
          before=before,
          current=current,
          after=after,
          lookups=lookups,
        }
      }
    }
  else
    report("unsupported subtype %a in %a %s",subtype,"chainedcontext",what)
  end
end
local function extension(f,fontdata,lookupid,lookupoffset,offset,glyphs,nofglyphs,types,handlers,what)
  local tableoffset=lookupoffset+offset
  setposition(f,tableoffset)
  local subtype=readushort(f)
  if subtype==1 then
    local lookuptype=types[readushort(f)]
    local faroffset=readulong(f)
    local handler=handlers[lookuptype]
    if handler then
      return handler(f,fontdata,lookupid,tableoffset+faroffset,0,glyphs,nofglyphs),lookuptype
    else
      report("no handler for lookuptype %a subtype %a in %s %s",lookuptype,subtype,what,"extension")
    end
  else
    report("unsupported subtype %a in %s %s",subtype,what,"extension")
  end
end
function gsubhandlers.single(f,fontdata,lookupid,lookupoffset,offset,glyphs,nofglyphs)
  local tableoffset=lookupoffset+offset
  setposition(f,tableoffset)
  local subtype=readushort(f)
  if subtype==1 then
    local coverage=readushort(f)
    local delta=readshort(f) 
    local coverage=readcoverage(f,tableoffset+coverage) 
    for index in next,coverage do
      local newindex=(index+delta)%65536 
      if index>nofglyphs or newindex>nofglyphs then
        report("invalid index in %s format %i: %i -> %i (max %i)","single",subtype,index,newindex,nofglyphs)
        coverage[index]=nil
      else
        coverage[index]=newindex
      end
    end
    return {
      coverage=coverage
    }
  elseif subtype==2 then 
    local coverage=readushort(f)
    local nofreplacements=readushort(f)
    local replacements=readcardinaltable(f,nofreplacements,ushort)
    local coverage=readcoverage(f,tableoffset+coverage) 
    for index,newindex in next,coverage do
      newindex=newindex+1
      if index>nofglyphs or newindex>nofglyphs then
        report("invalid index in %s format %i: %i -> %i (max %i)","single",subtype,index,newindex,nofglyphs)
        coverage[index]=nil
      else
        coverage[index]=replacements[newindex]
      end
    end
    return {
      coverage=coverage
    }
  else
    report("unsupported subtype %a in %a substitution",subtype,"single")
  end
end
local function sethandler(f,fontdata,lookupid,lookupoffset,offset,glyphs,nofglyphs,what)
  local tableoffset=lookupoffset+offset
  setposition(f,tableoffset)
  local subtype=readushort(f)
  if subtype==1 then
    local coverage=readushort(f)
    local nofsequence=readushort(f)
    local sequences=readcardinaltable(f,nofsequence,ushort)
    for i=1,nofsequence do
      setposition(f,tableoffset+sequences[i])
      sequences[i]=readcardinaltable(f,readushort(f),ushort)
    end
    local coverage=readcoverage(f,tableoffset+coverage)
    for index,newindex in next,coverage do
      newindex=newindex+1
      if index>nofglyphs or newindex>nofglyphs then
        report("invalid index in %s format %i: %i -> %i (max %i)",what,subtype,index,newindex,nofglyphs)
        coverage[index]=nil
      else
        coverage[index]=sequences[newindex]
      end
    end
    return {
      coverage=coverage
    }
  else
    report("unsupported subtype %a in %a substitution",subtype,what)
  end
end
function gsubhandlers.multiple(f,fontdata,lookupid,lookupoffset,offset,glyphs,nofglyphs)
  return sethandler(f,fontdata,lookupid,lookupoffset,offset,glyphs,nofglyphs,"multiple")
end
function gsubhandlers.alternate(f,fontdata,lookupid,lookupoffset,offset,glyphs,nofglyphs)
  return sethandler(f,fontdata,lookupid,lookupoffset,offset,glyphs,nofglyphs,"alternate")
end
function gsubhandlers.ligature(f,fontdata,lookupid,lookupoffset,offset,glyphs,nofglyphs)
  local tableoffset=lookupoffset+offset
  setposition(f,tableoffset)
  local subtype=readushort(f)
  if subtype==1 then
    local coverage=readushort(f)
    local nofsets=readushort(f)
    local ligatures=readcardinaltable(f,nofsets,ushort)
    for i=1,nofsets do
      local offset=lookupoffset+offset+ligatures[i]
      setposition(f,offset)
      local n=readushort(f)
      if n==1 then
        ligatures[i]={ offset+readushort(f) }
      else
        local l={}
        for i=1,n do
          l[i]=offset+readushort(f)
        end
        ligatures[i]=l
      end
    end
    local coverage=readcoverage(f,tableoffset+coverage)
    for index,newindex in next,coverage do
      local hash={}
      local ligatures=ligatures[newindex+1]
      for i=1,#ligatures do
        local offset=ligatures[i]
        setposition(f,offset)
        local lig=readushort(f)
        local cnt=readushort(f)
        local hsh=hash
        for i=2,cnt do
          local c=readushort(f)
          local h=hsh[c]
          if not h then
            h={}
            hsh[c]=h
          end
          hsh=h
        end
        hsh.ligature=lig
      end
      coverage[index]=hash
    end
    return {
      coverage=coverage
    }
  else
    report("unsupported subtype %a in %a substitution",subtype,"ligature")
  end
end
function gsubhandlers.context(f,fontdata,lookupid,lookupoffset,offset,glyphs,nofglyphs)
  return unchainedcontext(f,fontdata,lookupid,lookupoffset,offset,glyphs,nofglyphs,"substitution"),"context"
end
function gsubhandlers.chainedcontext(f,fontdata,lookupid,lookupoffset,offset,glyphs,nofglyphs)
  return chainedcontext(f,fontdata,lookupid,lookupoffset,offset,glyphs,nofglyphs,"substitution"),"chainedcontext"
end
function gsubhandlers.extension(f,fontdata,lookupid,lookupoffset,offset,glyphs,nofglyphs)
  return extension(f,fontdata,lookupid,lookupoffset,offset,glyphs,nofglyphs,gsubtypes,gsubhandlers,"substitution")
end
function gsubhandlers.reversechainedcontextsingle(f,fontdata,lookupid,lookupoffset,offset,glyphs,nofglyphs)
  local tableoffset=lookupoffset+offset
  setposition(f,tableoffset)
  local subtype=readushort(f)
  if subtype==1 then 
    local current=readfirst(f)
    local before=readarray(f)
    local after=readarray(f)
    local replacements=readarray(f)
    current=readcoveragearray(f,tableoffset,current,true)
    before=readcoveragearray(f,tableoffset,before,true)
    after=readcoveragearray(f,tableoffset,after,true)
    return {
      format="reversecoverage",
      rules={
        {
          before=before,
          current=current,
          after=after,
          replacements=replacements,
        }
      }
    },"reversechainedcontextsingle"
  else
    report("unsupported subtype %a in %a substitution",subtype,"reversechainedcontextsingle")
  end
end
local function readpairsets(f,tableoffset,sets,format1,format2,mainoffset,getdelta)
  local done={}
  for i=1,#sets do
    local offset=sets[i]
    local reused=done[offset]
    if not reused then
      offset=tableoffset+offset
      setposition(f,offset)
      local n=readushort(f)
      reused={}
      for i=1,n do
        reused[i]={
          readushort(f),
          readposition(f,format1,offset,getdelta),
          readposition(f,format2,offset,getdelta),
        }
      end
      done[offset]=reused
    end
    sets[i]=reused
  end
  return sets
end
local function readpairclasssets(f,nofclasses1,nofclasses2,format1,format2,mainoffset,getdelta)
  local classlist1={}
  for i=1,nofclasses1 do
    local classlist2={}
    classlist1[i]=classlist2
    for j=1,nofclasses2 do
      local one=readposition(f,format1,mainoffset,getdelta)
      local two=readposition(f,format2,mainoffset,getdelta)
      if one or two then
        classlist2[j]={ one,two }
      else
        classlist2[j]=false
      end
    end
  end
  return classlist1
end
function gposhandlers.single(f,fontdata,lookupid,lookupoffset,offset,glyphs,nofglyphs)
  local tableoffset=lookupoffset+offset
  setposition(f,tableoffset)
  local subtype=readushort(f)
  local getdelta=fontdata.temporary.getdelta
  if subtype==1 then
    local coverage=readushort(f)
    local format=readushort(f)
    local value=readposition(f,format,tableoffset,getdelta)
    local coverage=readcoverage(f,tableoffset+coverage)
    for index,newindex in next,coverage do
      coverage[index]=value 
    end
    return {
      format="single",
      coverage=coverage,
    }
  elseif subtype==2 then
    local coverage=readushort(f)
    local format=readushort(f)
    local nofvalues=readushort(f)
    local values={}
    for i=1,nofvalues do
      values[i]=readposition(f,format,tableoffset,getdelta)
    end
    local coverage=readcoverage(f,tableoffset+coverage)
    for index,newindex in next,coverage do
      coverage[index]=values[newindex+1]
    end
    return {
      format="single",
      coverage=coverage,
    }
  else
    report("unsupported subtype %a in %a positioning",subtype,"single")
  end
end
function gposhandlers.pair(f,fontdata,lookupid,lookupoffset,offset,glyphs,nofglyphs)
  local tableoffset=lookupoffset+offset
  setposition(f,tableoffset)
  local subtype=readushort(f)
  local getdelta=fontdata.temporary.getdelta
  if subtype==1 then
    local coverage=readushort(f)
    local format1=readushort(f)
    local format2=readushort(f)
    local sets=readarray(f)
       sets=readpairsets(f,tableoffset,sets,format1,format2,mainoffset,getdelta)
       coverage=readcoverage(f,tableoffset+coverage)
    for index,newindex in next,coverage do
      local set=sets[newindex+1]
      local hash={}
      for i=1,#set do
        local value=set[i]
        if value then
          local other=value[1]
          local first=value[2]
          local second=value[3]
          if first or second then
            hash[other]={ first,second or nil } 
          else
            hash[other]=nil 
          end
        end
      end
      coverage[index]=hash
    end
    return {
      format="pair",
      coverage=coverage,
    }
  elseif subtype==2 then
    local coverage=readushort(f)
    local format1=readushort(f)
    local format2=readushort(f)
    local classdef1=readushort(f)
    local classdef2=readushort(f)
    local nofclasses1=readushort(f) 
    local nofclasses2=readushort(f) 
    local classlist=readpairclasssets(f,nofclasses1,nofclasses2,format1,format2,tableoffset,getdelta)
       coverage=readcoverage(f,tableoffset+coverage)
       classdef1=readclassdef(f,tableoffset+classdef1,coverage)
       classdef2=readclassdef(f,tableoffset+classdef2,nofglyphs)
    local usedcoverage={}
    for g1,c1 in next,classdef1 do
      if coverage[g1] then
        local l1=classlist[c1]
        if l1 then
          local hash={}
          for paired,class in next,classdef2 do
            local offsets=l1[class]
            if offsets then
              local first=offsets[1]
              local second=offsets[2]
              if first or second then
                hash[paired]={ first,second or nil }
              else
              end
            end
          end
          usedcoverage[g1]=hash
        end
      end
    end
    return {
      format="pair",
      coverage=usedcoverage,
    }
  elseif subtype==3 then
    report("yet unsupported subtype %a in %a positioning",subtype,"pair")
  else
    report("unsupported subtype %a in %a positioning",subtype,"pair")
  end
end
function gposhandlers.cursive(f,fontdata,lookupid,lookupoffset,offset,glyphs,nofglyphs)
  local tableoffset=lookupoffset+offset
  setposition(f,tableoffset)
  local subtype=readushort(f)
  local getdelta=fontdata.temporary.getdelta
  if subtype==1 then
    local coverage=tableoffset+readushort(f)
    local nofrecords=readushort(f)
    local records={}
    for i=1,nofrecords do
      local entry=readushort(f)
      local exit=readushort(f)
      records[i]={
        entry~=0 and (tableoffset+entry) or false,
        exit~=0 and (tableoffset+exit ) or nil,
      }
    end
    local cc=(fontdata.temporary.cursivecount or 0)+1
    fontdata.temporary.cursivecount=cc
    cc="cc-"..cc
    coverage=readcoverage(f,coverage)
    for i=1,nofrecords do
      local r=records[i]
      records[i]={
        cc,
        readanchor(f,r[1],getdelta) or false,
        readanchor(f,r[2],getdelta) or nil,
      }
    end
    for index,newindex in next,coverage do
      coverage[index]=records[newindex+1]
    end
    return {
      coverage=coverage,
    }
  else
    report("unsupported subtype %a in %a positioning",subtype,"cursive")
  end
end
local function handlemark(f,fontdata,lookupid,lookupoffset,offset,glyphs,nofglyphs,ligature)
  local tableoffset=lookupoffset+offset
  setposition(f,tableoffset)
  local subtype=readushort(f)
  local getdelta=fontdata.temporary.getdelta
  if subtype==1 then
    local markcoverage=tableoffset+readushort(f)
    local basecoverage=tableoffset+readushort(f)
    local nofclasses=readushort(f)
    local markoffset=tableoffset+readushort(f)
    local baseoffset=tableoffset+readushort(f)
    local markcoverage=readcoverage(f,markcoverage)
    local basecoverage=readcoverage(f,basecoverage,true)
    setposition(f,markoffset)
    local markclasses={}
    local nofmarkclasses=readushort(f)
    local lastanchor=fontdata.lastanchor or 0
    local usedanchors={}
    for i=1,nofmarkclasses do
      local class=readushort(f)+1
      local offset=readushort(f)
      if offset==0 then
        markclasses[i]=false
      else
        markclasses[i]={ class,markoffset+offset }
      end
      usedanchors[class]=true
    end
    for i=1,nofmarkclasses do
      local mc=markclasses[i]
      if mc then
        mc[2]=readanchor(f,mc[2],getdelta)
      end
    end
    setposition(f,baseoffset)
    local nofbaserecords=readushort(f)
    local baserecords={}
    if ligature then
      for i=1,nofbaserecords do 
        local offset=readushort(f)
        if offset==0 then
          baserecords[i]=false
        else
          baserecords[i]=baseoffset+offset
        end
      end
      for i=1,nofbaserecords do
        local recordoffset=baserecords[i]
        if recordoffset then
          setposition(f,recordoffset)
          local nofcomponents=readushort(f)
          local components={}
          for i=1,nofcomponents do
            local classes={}
            for i=1,nofclasses do
              local offset=readushort(f)
              if offset~=0 then
                classes[i]=recordoffset+offset
              else
                classes[i]=false
              end
            end
            components[i]=classes
          end
          baserecords[i]=components
        end
      end
      local baseclasses={} 
      for i=1,nofclasses do
        baseclasses[i]={}
      end
      for i=1,nofbaserecords do
        local components=baserecords[i]
        if components then
          local b=basecoverage[i]
          for c=1,#components do
            local classes=components[c]
            if classes then
              for i=1,nofclasses do
                local anchor=readanchor(f,classes[i],getdelta)
                local bclass=baseclasses[i]
                local bentry=bclass[b]
                if bentry then
                  bentry[c]=anchor
                else
                  bclass[b]={ [c]=anchor }
                end
              end
            end
          end
        end
      end
      for index,newindex in next,markcoverage do
        markcoverage[index]=markclasses[newindex+1] or nil
      end
      return {
        format="ligature",
        baseclasses=baseclasses,
        coverage=markcoverage,
      }
    else
      for i=1,nofbaserecords do
        local r={}
        for j=1,nofclasses do
          local offset=readushort(f)
          if offset==0 then
            r[j]=false
          else
            r[j]=baseoffset+offset
          end
        end
        baserecords[i]=r
      end
      local baseclasses={} 
      for i=1,nofclasses do
        baseclasses[i]={}
      end
      for i=1,nofbaserecords do
        local r=baserecords[i]
        local b=basecoverage[i]
        for j=1,nofclasses do
          baseclasses[j][b]=readanchor(f,r[j],getdelta)
        end
      end
      for index,newindex in next,markcoverage do
        markcoverage[index]=markclasses[newindex+1] or nil
      end
      return {
        format="base",
        baseclasses=baseclasses,
        coverage=markcoverage,
      }
    end
  else
    report("unsupported subtype %a in",subtype)
  end
end
function gposhandlers.marktobase(f,fontdata,lookupid,lookupoffset,offset,glyphs,nofglyphs)
  return handlemark(f,fontdata,lookupid,lookupoffset,offset,glyphs,nofglyphs)
end
function gposhandlers.marktoligature(f,fontdata,lookupid,lookupoffset,offset,glyphs,nofglyphs)
  return handlemark(f,fontdata,lookupid,lookupoffset,offset,glyphs,nofglyphs,true)
end
function gposhandlers.marktomark(f,fontdata,lookupid,lookupoffset,offset,glyphs,nofglyphs)
  return handlemark(f,fontdata,lookupid,lookupoffset,offset,glyphs,nofglyphs)
end
function gposhandlers.context(f,fontdata,lookupid,lookupoffset,offset,glyphs,nofglyphs)
  return unchainedcontext(f,fontdata,lookupid,lookupoffset,offset,glyphs,nofglyphs,"positioning"),"context"
end
function gposhandlers.chainedcontext(f,fontdata,lookupid,lookupoffset,offset,glyphs,nofglyphs)
  return chainedcontext(f,fontdata,lookupid,lookupoffset,offset,glyphs,nofglyphs,"positioning"),"chainedcontext"
end
function gposhandlers.extension(f,fontdata,lookupid,lookupoffset,offset,glyphs,nofglyphs)
  return extension(f,fontdata,lookupid,lookupoffset,offset,glyphs,nofglyphs,gpostypes,gposhandlers,"positioning")
end
do
  local plugins={}
  function plugins.size(f,fontdata,tableoffset,feature)
    if fontdata.designsize then
    else
      local function check(offset)
        setposition(f,offset)
        local designsize=readushort(f)
        if designsize>0 then 
          local fontstyleid=readushort(f)
          local guimenuid=readushort(f)
          local minsize=readushort(f)
          local maxsize=readushort(f)
          if minsize==0 and maxsize==0 and fontstyleid==0 and guimenuid==0 then
            minsize=designsize
            maxsize=designsize
          end
          if designsize>=minsize and designsize<=maxsize then
            return minsize,maxsize,designsize
          end
        end
      end
      local minsize,maxsize,designsize=check(tableoffset+feature.offset+feature.parameters)
      if not designsize then
        minsize,maxsize,designsize=check(tableoffset+feature.parameters)
        if designsize then
          report("bad size feature in %a, falling back to wrong offset",fontdata.filename or "?")
        else
          report("bad size feature in %a,",fontdata.filename or "?")
        end
      end
      if designsize then
        fontdata.minsize=minsize
        fontdata.maxsize=maxsize
        fontdata.designsize=designsize
      end
    end
  end
  local function reorderfeatures(fontdata,scripts,features)
    local scriptlangs={}
    local featurehash={}
    local featureorder={}
    for script,languages in next,scripts do
      for language,record in next,languages do
        local hash={}
        local list=record.featureindices
        for k=1,#list do
          local index=list[k]
          local feature=features[index]
          local lookups=feature.lookups
          local tag=feature.tag
          if tag then
            hash[tag]=true
          end
          if lookups then
            for i=1,#lookups do
              local lookup=lookups[i]
              local o=featureorder[lookup]
              if o then
                local okay=true
                for i=1,#o do
                  if o[i]==tag then
                    okay=false
                    break
                  end
                end
                if okay then
                  o[#o+1]=tag
                end
              else
                featureorder[lookup]={ tag }
              end
              local f=featurehash[lookup]
              if f then
                local h=f[tag]
                if h then
                  local s=h[script]
                  if s then
                    s[language]=true
                  else
                    h[script]={ [language]=true }
                  end
                else
                  f[tag]={ [script]={ [language]=true } }
                end
              else
                featurehash[lookup]={ [tag]={ [script]={ [language]=true } } }
              end
              local h=scriptlangs[tag]
              if h then
                local s=h[script]
                if s then
                  s[language]=true
                else
                  h[script]={ [language]=true }
                end
              else
                scriptlangs[tag]={ [script]={ [language]=true } }
              end
            end
          end
        end
      end
    end
    return scriptlangs,featurehash,featureorder
  end
  local function readscriplan(f,fontdata,scriptoffset)
    setposition(f,scriptoffset)
    local nofscripts=readushort(f)
    local scripts={}
    for i=1,nofscripts do
      scripts[readtag(f)]=scriptoffset+readushort(f)
    end
    local languagesystems=setmetatableindex("table")
    for script,offset in next,scripts do
      setposition(f,offset)
      local defaultoffset=readushort(f)
      local noflanguages=readushort(f)
      local languages={}
      if defaultoffset>0 then
        languages.dflt=languagesystems[offset+defaultoffset]
      end
      for i=1,noflanguages do
        local language=readtag(f)
        local offset=offset+readushort(f)
        languages[language]=languagesystems[offset]
      end
      scripts[script]=languages
    end
    for offset,usedfeatures in next,languagesystems do
      if offset>0 then
        setposition(f,offset)
        local featureindices={}
        usedfeatures.featureindices=featureindices
        usedfeatures.lookuporder=readushort(f) 
        usedfeatures.requiredindex=readushort(f) 
        local noffeatures=readushort(f)
        for i=1,noffeatures do
          featureindices[i]=readushort(f)+1
        end
      end
    end
    return scripts
  end
  local function readfeatures(f,fontdata,featureoffset)
    setposition(f,featureoffset)
    local features={}
    local noffeatures=readushort(f)
    for i=1,noffeatures do
      features[i]={
        tag=readtag(f),
        offset=readushort(f)
      }
    end
    for i=1,noffeatures do
      local feature=features[i]
      local offset=featureoffset+feature.offset
      setposition(f,offset)
      local parameters=readushort(f) 
      local noflookups=readushort(f)
      if noflookups>0 then
        local lookups=readcardinaltable(f,noflookups,ushort)
        feature.lookups=lookups
        for j=1,noflookups do
          lookups[j]=lookups[j]+1
        end
      end
      if parameters>0 then
        feature.parameters=parameters
        local plugin=plugins[feature.tag]
        if plugin then
          plugin(f,fontdata,featureoffset,feature)
        end
      end
    end
    return features
  end
  local function readlookups(f,lookupoffset,lookuptypes,featurehash,featureorder)
    setposition(f,lookupoffset)
    local noflookups=readushort(f)
    local lookups=readcardinaltable(f,noflookups,ushort)
    for lookupid=1,noflookups do
      local offset=lookups[lookupid]
      setposition(f,lookupoffset+offset)
      local subtables={}
      local typebits=readushort(f)
      local flagbits=readushort(f)
      local lookuptype=lookuptypes[typebits]
      local lookupflags=lookupflags[flagbits]
      local nofsubtables=readushort(f)
      for j=1,nofsubtables do
        subtables[j]=offset+readushort(f) 
      end
      local markclass=band(flagbits,0x0010)~=0 
      if markclass then
        markclass=readushort(f) 
      end
      local markset=rshift(flagbits,8)
      if markset>0 then
        markclass=markset 
      end
      lookups[lookupid]={
        type=lookuptype,
        flags=lookupflags,
        name=lookupid,
        subtables=subtables,
        markclass=markclass,
        features=featurehash[lookupid],
        order=featureorder[lookupid],
      }
    end
    return lookups
  end
  local f_lookupname=formatters["%s_%s_%s"]
  local function resolvelookups(f,lookupoffset,fontdata,lookups,lookuptypes,lookuphandlers,what,tableoffset)
    local sequences=fontdata.sequences or {}
    local sublookuplist=fontdata.sublookups or {}
    fontdata.sequences=sequences
    fontdata.sublookups=sublookuplist
    local nofsublookups=#sublookuplist
    local nofsequences=#sequences 
    local lastsublookup=nofsublookups
    local lastsequence=nofsequences
    local lookupnames=lookupnames[what]
    local sublookuphash={}
    local sublookupcheck={}
    local glyphs=fontdata.glyphs
    local nofglyphs=fontdata.nofglyphs or #glyphs
    local noflookups=#lookups
    local lookupprefix=sub(what,2,2)
    local usedlookups=false
    for lookupid=1,noflookups do
      local lookup=lookups[lookupid]
      local lookuptype=lookup.type
      local subtables=lookup.subtables
      local features=lookup.features
      local handler=lookuphandlers[lookuptype]
      if handler then
        local nofsubtables=#subtables
        local order=lookup.order
        local flags=lookup.flags
        if flags[1] then flags[1]="mark" end
        if flags[2] then flags[2]="ligature" end
        if flags[3] then flags[3]="base" end
        local markclass=lookup.markclass
        if nofsubtables>0 then
          local steps={}
          local nofsteps=0
          local oldtype=nil
          for s=1,nofsubtables do
            local step,lt=handler(f,fontdata,lookupid,lookupoffset,subtables[s],glyphs,nofglyphs)
            if lt then
              lookuptype=lt
              if oldtype and lt~=oldtype then
                report("messy %s lookup type %a and %a",what,lookuptype,oldtype)
              end
              oldtype=lookuptype
            end
            if not step then
              report("unsupported %s lookup type %a",what,lookuptype)
            else
              nofsteps=nofsteps+1
              steps[nofsteps]=step
              local rules=step.rules
              if rules then
                for i=1,#rules do
                  local rule=rules[i]
                  local before=rule.before
                  local current=rule.current
                  local after=rule.after
                  local replacements=rule.replacements
                  if before then
                    for i=1,#before do
                      before[i]=tohash(before[i])
                    end
                    rule.before=reversed(before)
                  end
                  if current then
                    if replacements then
                      local first=current[1]
                      local hash={}
                      local repl={}
                      for i=1,#first do
                        local c=first[i]
                        hash[c]=true
                        repl[c]=replacements[i]
                      end
                      rule.current={ hash }
                      rule.replacements=repl
                    else
                      for i=1,#current do
                        current[i]=tohash(current[i])
                      end
                    end
                  else
                  end
                  if after then
                    for i=1,#after do
                      after[i]=tohash(after[i])
                    end
                  end
                  if usedlookups then
                    local lookups=rule.lookups
                    if lookups then
                      for k,v in next,lookups do
                        if v then
                          for k,v in next,v do
                            usedlookups[v]=usedlookups[v]+1
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
          if nofsteps~=nofsubtables then
            report("bogus subtables removed in %s lookup type %a",what,lookuptype)
          end
          lookuptype=lookupnames[lookuptype] or lookuptype
          if features then
            nofsequences=nofsequences+1
            local l={
              index=nofsequences,
              name=f_lookupname(lookupprefix,"s",lookupid+lookupidoffset),
              steps=steps,
              nofsteps=nofsteps,
              type=lookuptype,
              markclass=markclass or nil,
              flags=flags,
              order=order,
              features=features,
            }
            sequences[nofsequences]=l
            lookup.done=l
          else
            nofsublookups=nofsublookups+1
            local l={
              index=nofsublookups,
              name=f_lookupname(lookupprefix,"l",lookupid+lookupidoffset),
              steps=steps,
              nofsteps=nofsteps,
              type=lookuptype,
              markclass=markclass or nil,
              flags=flags,
            }
            sublookuplist[nofsublookups]=l
            sublookuphash[lookupid]=nofsublookups
            sublookupcheck[lookupid]=0
            lookup.done=l
          end
        else
          report("no subtables for lookup %a",lookupid)
        end
      else
        report("no handler for lookup %a with type %a",lookupid,lookuptype)
      end
    end
    if usedlookups then
      report("used %s lookups: % t",what,sortedkeys(usedlookups))
    end
    local reported={}
    local function report_issue(i,what,sequence,kind)
      local name=sequence.name
      if not reported[name] then
        report("rule %i in %s lookup %a has %s lookups",i,what,name,kind)
        reported[name]=true
      end
    end
    for i=lastsequence+1,nofsequences do
      local sequence=sequences[i]
      local steps=sequence.steps
      for i=1,#steps do
        local step=steps[i]
        local rules=step.rules
        if rules then
          for i=1,#rules do
            local rule=rules[i]
            local rlookups=rule.lookups
            if not rlookups then
              report_issue(i,what,sequence,"no")
            elseif not next(rlookups) then
              rule.lookups=nil
            else
              local length=#rlookups
              for index=1,length do
                local lookuplist=rlookups[index]
                if lookuplist then
                  local length=#lookuplist
                  local found={}
                  local noffound=0
                  for index=1,length do
                    local lookupid=lookuplist[index]
                    if lookupid then
                      local h=sublookuphash[lookupid]
                      if not h then
                        local lookup=lookups[lookupid]
                        if lookup then
                          local d=lookup.done
                          if d then
                            nofsublookups=nofsublookups+1
                            local l={
                              index=nofsublookups,
                              name=f_lookupname(lookupprefix,"d",lookupid+lookupidoffset),
                              derived=true,
                              steps=d.steps,
                              nofsteps=d.nofsteps,
                              type=d.lookuptype or "gsub_single",
                              markclass=d.markclass or nil,
                              flags=d.flags,
                            }
                            sublookuplist[nofsublookups]=copy(l) 
                            sublookuphash[lookupid]=nofsublookups
                            sublookupcheck[lookupid]=1
                            h=nofsublookups
                          else
                            report_issue(i,what,sequence,"missing")
                            rule.lookups=nil
                            break
                          end
                        else
                          report_issue(i,what,sequence,"bad")
                          rule.lookups=nil
                          break
                        end
                      else
                        sublookupcheck[lookupid]=sublookupcheck[lookupid]+1
                      end
                      if h then
                        noffound=noffound+1
                        found[noffound]=h
                      end
                    end
                  end
                  rlookups[index]=noffound>0 and found or false
                else
                  rlookups[index]=false
                end
              end
            end
          end
        end
      end
    end
    for i,n in sortedhash(sublookupcheck) do
      local l=lookups[i]
      local t=l.type
      if n==0 and t~="extension" then
        local d=l.done
        report("%s lookup %s of type %a is not used",what,d and d.name or l.name,t)
      end
    end
  end
  local function loadvariations(f,fontdata,variationsoffset,lookuptypes,featurehash,featureorder)
    setposition(f,variationsoffset)
    local version=readulong(f)
    local nofrecords=readulong(f)
    local records={}
    for i=1,nofrecords do
      records[i]={
        conditions=readulong(f),
        substitutions=readulong(f),
      }
    end
    for i=1,nofrecords do
      local record=records[i]
      local offset=record.conditions
      if offset==0 then
        record.condition=nil
        record.matchtype="always"
      else
        local offset=variationsoffset+offset
        setposition(f,offset)
        local nofconditions=readushort(f)
        local conditions={}
        for i=1,nofconditions do
          conditions[i]=offset+readulong(f)
        end
        record.conditions=conditions
        record.matchtype="condition"
      end
    end
    for i=1,nofrecords do
      local record=records[i]
      if record.matchtype=="condition" then
        local conditions=record.conditions
        for i=1,#conditions do
          setposition(f,conditions[i])
          conditions[i]={
            format=readushort(f),
            axis=readushort(f),
            minvalue=read2dot14(f),
            maxvalue=read2dot14(f),
          }
        end
      end
    end
    for i=1,nofrecords do
      local record=records[i]
      local offset=record.substitutions
      if offset==0 then
        record.substitutions={}
      else
        setposition(f,variationsoffset+offset)
        local version=readulong(f)
        local nofsubstitutions=readushort(f)
        local substitutions={}
        for i=1,nofsubstitutions do
          substitutions[readushort(f)]=readulong(f)
        end
        for index,alternates in sortedhash(substitutions) do
          if index==0 then
            record.substitutions=false
          else
            local tableoffset=variationsoffset+offset+alternates
            setposition(f,tableoffset)
            local parameters=readulong(f) 
            local noflookups=readushort(f)
            local lookups=readcardinaltable(f,noflookups,ushort)
            record.substitutions=lookups
          end
        end
      end
    end
    setvariabledata(fontdata,"features",records)
  end
  local function readscripts(f,fontdata,what,lookuptypes,lookuphandlers,lookupstoo)
    local tableoffset=gotodatatable(f,fontdata,what,true)
    if tableoffset then
      local version=readulong(f)
      local scriptoffset=tableoffset+readushort(f)
      local featureoffset=tableoffset+readushort(f)
      local lookupoffset=tableoffset+readushort(f)
      local variationsoffset=version>0x00010000 and (tableoffset+readulong(f)) or 0
      if not scriptoffset then
        return
      end
      local scripts=readscriplan(f,fontdata,scriptoffset)
      local features=readfeatures(f,fontdata,featureoffset)
      local scriptlangs,featurehash,featureorder=reorderfeatures(fontdata,scripts,features)
      if fontdata.features then
        fontdata.features[what]=scriptlangs
      else
        fontdata.features={ [what]=scriptlangs }
      end
      if not lookupstoo then
        return
      end
      local lookups=readlookups(f,lookupoffset,lookuptypes,featurehash,featureorder)
      if lookups then
        resolvelookups(f,lookupoffset,fontdata,lookups,lookuptypes,lookuphandlers,what,tableoffset)
      end
      if variationsoffset>0 then
        loadvariations(f,fontdata,variationsoffset,lookuptypes,featurehash,featureorder)
      end
    end
  end
  local function checkkerns(f,fontdata,specification)
    local datatable=fontdata.tables.kern
    if not datatable then
      return 
    end
    local features=fontdata.features
    local gposfeatures=features and features.gpos
    local name
    if not gposfeatures or not gposfeatures.kern then
      name="kern"
    elseif specification.globalkerns then
      name="globalkern"
    else
      report("ignoring global kern table, using gpos kern feature")
      return
    end
    setposition(f,datatable.offset)
    local version=readushort(f)
    local noftables=readushort(f)
    if noftables>1 then
      report("adding global kern table as gpos feature %a",name)
      local kerns=setmetatableindex("table")
      for i=1,noftables do
        local version=readushort(f)
        local length=readushort(f)
        local coverage=readushort(f)
        local format=rshift(coverage,8) 
        if format==0 then
          local nofpairs=readushort(f)
          local searchrange=readushort(f)
          local entryselector=readushort(f)
          local rangeshift=readushort(f)
          for i=1,nofpairs do
            kerns[readushort(f)][readushort(f)]=readfword(f)
          end
        elseif format==2 then
        else
        end
      end
      local feature={ dflt={ dflt=true } }
      if not features then
        fontdata.features={ gpos={ [name]=feature } }
      elseif not gposfeatures then
        fontdata.features.gpos={ [name]=feature }
      else
        gposfeatures[name]=feature
      end
      local sequences=fontdata.sequences
      if not sequences then
        sequences={}
        fontdata.sequences=sequences
      end
      local nofsequences=#sequences+1
      sequences[nofsequences]={
        index=nofsequences,
        name=name,
        steps={
          {
            coverage=kerns,
            format="kern",
          },
        },
        nofsteps=1,
        type="gpos_pair",
        flags={ false,false,false,false },
        order={ name },
        features={ [name]=feature },
      }
    else
      report("ignoring empty kern table of feature %a",name)
    end
  end
  function readers.gsub(f,fontdata,specification)
    if specification.details then
      readscripts(f,fontdata,"gsub",gsubtypes,gsubhandlers,specification.lookups)
    end
  end
  function readers.gpos(f,fontdata,specification)
    if specification.details then
      readscripts(f,fontdata,"gpos",gpostypes,gposhandlers,specification.lookups)
      if specification.lookups then
        checkkerns(f,fontdata,specification)
      end
    end
  end
end
function readers.gdef(f,fontdata,specification)
  if not specification.glyphs then
    return
  end
  local datatable=fontdata.tables.gdef
  if datatable then
    local tableoffset=datatable.offset
    setposition(f,tableoffset)
    local version=readulong(f)
    local classoffset=readushort(f)
    local attachmentoffset=readushort(f) 
    local ligaturecarets=readushort(f) 
    local markclassoffset=readushort(f)
    local marksetsoffset=version>=0x00010002 and readushort(f) or 0
    local varsetsoffset=version>=0x00010003 and readulong(f) or 0
    local glyphs=fontdata.glyphs
    local marks={}
    local markclasses=setmetatableindex("table")
    local marksets=setmetatableindex("table")
    fontdata.marks=marks
    fontdata.markclasses=markclasses
    fontdata.marksets=marksets
    if classoffset~=0 then
      setposition(f,tableoffset+classoffset)
      local classformat=readushort(f)
      if classformat==1 then
        local firstindex=readushort(f)
        local lastindex=firstindex+readushort(f)-1
        for index=firstindex,lastindex do
          local class=classes[readushort(f)]
          if class=="mark" then
            marks[index]=true
          end
          glyphs[index].class=class
        end
      elseif classformat==2 then
        local nofranges=readushort(f)
        for i=1,nofranges do
          local firstindex=readushort(f)
          local lastindex=readushort(f)
          local class=classes[readushort(f)]
          if class then
            for index=firstindex,lastindex do
              glyphs[index].class=class
              if class=="mark" then
                marks[index]=true
              end
            end
          end
        end
      end
    end
    if markclassoffset~=0 then
      setposition(f,tableoffset+markclassoffset)
      local classformat=readushort(f)
      if classformat==1 then
        local firstindex=readushort(f)
        local lastindex=firstindex+readushort(f)-1
        for index=firstindex,lastindex do
          markclasses[readushort(f)][index]=true
        end
      elseif classformat==2 then
        local nofranges=readushort(f)
        for i=1,nofranges do
          local firstindex=readushort(f)
          local lastindex=readushort(f)
          local class=markclasses[readushort(f)]
          for index=firstindex,lastindex do
            class[index]=true
          end
        end
      end
    end
    if marksetsoffset~=0 then
      marksetsoffset=tableoffset+marksetsoffset
      setposition(f,marksetsoffset)
      local format=readushort(f)
      if format==1 then
        local nofsets=readushort(f)
        local sets=readcardinaltable(f,nofsets,ulong)
        for i=1,nofsets do
          local offset=sets[i]
          if offset~=0 then
            marksets[i]=readcoverage(f,marksetsoffset+offset)
          end
        end
      end
    end
    local factors=specification.factors
    if (specification.variable or factors) and varsetsoffset~=0 then
      local regions,deltas=readvariationdata(f,tableoffset+varsetsoffset,factors)
      if factors then
        fontdata.temporary.getdelta=function(outer,inner)
          local delta=deltas[outer+1]
          if delta then
            local d=delta.deltas[inner+1]
            if d then
              local scales=delta.scales
              local dd=0
              for i=1,#scales do
                local di=d[i]
                if di then
                  dd=dd+scales[i]*di
                else
                  break
                end
              end
              return round(dd)
            end
          end
          return 0
        end
      end
    end
  end
end
local function readmathvalue(f)
  local v=readshort(f)
  skipshort(f,1) 
  return v
end
local function readmathconstants(f,fontdata,offset)
  setposition(f,offset)
  fontdata.mathconstants={
    ScriptPercentScaleDown=readshort(f),
    ScriptScriptPercentScaleDown=readshort(f),
    DelimitedSubFormulaMinHeight=readushort(f),
    DisplayOperatorMinHeight=readushort(f),
    MathLeading=readmathvalue(f),
    AxisHeight=readmathvalue(f),
    AccentBaseHeight=readmathvalue(f),
    FlattenedAccentBaseHeight=readmathvalue(f),
    SubscriptShiftDown=readmathvalue(f),
    SubscriptTopMax=readmathvalue(f),
    SubscriptBaselineDropMin=readmathvalue(f),
    SuperscriptShiftUp=readmathvalue(f),
    SuperscriptShiftUpCramped=readmathvalue(f),
    SuperscriptBottomMin=readmathvalue(f),
    SuperscriptBaselineDropMax=readmathvalue(f),
    SubSuperscriptGapMin=readmathvalue(f),
    SuperscriptBottomMaxWithSubscript=readmathvalue(f),
    SpaceAfterScript=readmathvalue(f),
    UpperLimitGapMin=readmathvalue(f),
    UpperLimitBaselineRiseMin=readmathvalue(f),
    LowerLimitGapMin=readmathvalue(f),
    LowerLimitBaselineDropMin=readmathvalue(f),
    StackTopShiftUp=readmathvalue(f),
    StackTopDisplayStyleShiftUp=readmathvalue(f),
    StackBottomShiftDown=readmathvalue(f),
    StackBottomDisplayStyleShiftDown=readmathvalue(f),
    StackGapMin=readmathvalue(f),
    StackDisplayStyleGapMin=readmathvalue(f),
    StretchStackTopShiftUp=readmathvalue(f),
    StretchStackBottomShiftDown=readmathvalue(f),
    StretchStackGapAboveMin=readmathvalue(f),
    StretchStackGapBelowMin=readmathvalue(f),
    FractionNumeratorShiftUp=readmathvalue(f),
    FractionNumeratorDisplayStyleShiftUp=readmathvalue(f),
    FractionDenominatorShiftDown=readmathvalue(f),
    FractionDenominatorDisplayStyleShiftDown=readmathvalue(f),
    FractionNumeratorGapMin=readmathvalue(f),
    FractionNumeratorDisplayStyleGapMin=readmathvalue(f),
    FractionRuleThickness=readmathvalue(f),
    FractionDenominatorGapMin=readmathvalue(f),
    FractionDenominatorDisplayStyleGapMin=readmathvalue(f),
    SkewedFractionHorizontalGap=readmathvalue(f),
    SkewedFractionVerticalGap=readmathvalue(f),
    OverbarVerticalGap=readmathvalue(f),
    OverbarRuleThickness=readmathvalue(f),
    OverbarExtraAscender=readmathvalue(f),
    UnderbarVerticalGap=readmathvalue(f),
    UnderbarRuleThickness=readmathvalue(f),
    UnderbarExtraDescender=readmathvalue(f),
    RadicalVerticalGap=readmathvalue(f),
    RadicalDisplayStyleVerticalGap=readmathvalue(f),
    RadicalRuleThickness=readmathvalue(f),
    RadicalExtraAscender=readmathvalue(f),
    RadicalKernBeforeDegree=readmathvalue(f),
    RadicalKernAfterDegree=readmathvalue(f),
    RadicalDegreeBottomRaisePercent=readshort(f),
  }
end
local function readmathglyphinfo(f,fontdata,offset)
  setposition(f,offset)
  local italics=readushort(f)
  local accents=readushort(f)
  local extensions=readushort(f)
  local kerns=readushort(f)
  local glyphs=fontdata.glyphs
  if italics~=0 then
    setposition(f,offset+italics)
    local coverage=readushort(f)
    local nofglyphs=readushort(f)
    coverage=readcoverage(f,offset+italics+coverage,true)
    setposition(f,offset+italics+4)
    for i=1,nofglyphs do
      local italic=readmathvalue(f)
      if italic~=0 then
        local glyph=glyphs[coverage[i]]
        local math=glyph.math
        if not math then
          glyph.math={ italic=italic }
        else
          math.italic=italic
        end
      end
    end
    fontdata.hasitalics=true
  end
  if accents~=0 then
    setposition(f,offset+accents)
    local coverage=readushort(f)
    local nofglyphs=readushort(f)
    coverage=readcoverage(f,offset+accents+coverage,true)
    setposition(f,offset+accents+4)
    for i=1,nofglyphs do
      local accent=readmathvalue(f)
      if accent~=0 then
        local glyph=glyphs[coverage[i]]
        local math=glyph.math
        if not math then
          glyph.math={ accent=accent }
        else
          math.accent=accent
        end
      end
    end
  end
  if extensions~=0 then
    setposition(f,offset+extensions)
  end
  if kerns~=0 then
    local kernoffset=offset+kerns
    setposition(f,kernoffset)
    local coverage=readushort(f)
    local nofglyphs=readushort(f)
    if nofglyphs>0 then
      local function get(offset)
        setposition(f,kernoffset+offset)
        local n=readushort(f)
        if n==0 then
          local k=readmathvalue(f)
          if k==0 then
          else
            return { { kern=k } }
          end
        else
          local l={}
          for i=1,n do
            l[i]={ height=readmathvalue(f) }
          end
          for i=1,n do
            l[i].kern=readmathvalue(f)
          end
          l[n+1]={ kern=readmathvalue(f) }
          return l
        end
      end
      local kernsets={}
      for i=1,nofglyphs do
        local topright=readushort(f)
        local topleft=readushort(f)
        local bottomright=readushort(f)
        local bottomleft=readushort(f)
        kernsets[i]={
          topright=topright~=0 and topright  or nil,
          topleft=topleft~=0 and topleft   or nil,
          bottomright=bottomright~=0 and bottomright or nil,
          bottomleft=bottomleft~=0 and bottomleft or nil,
        }
      end
      coverage=readcoverage(f,kernoffset+coverage,true)
      for i=1,nofglyphs do
        local kernset=kernsets[i]
        if next(kernset) then
          local k=kernset.topright  if k then kernset.topright=get(k) end
          local k=kernset.topleft   if k then kernset.topleft=get(k) end
          local k=kernset.bottomright if k then kernset.bottomright=get(k) end
          local k=kernset.bottomleft if k then kernset.bottomleft=get(k) end
          if next(kernset) then
            local glyph=glyphs[coverage[i]]
            local math=glyph.math
            if math then
              math.kerns=kernset
            else
              glyph.math={ kerns=kernset }
            end
          end
        end
      end
    end
  end
end
local function readmathvariants(f,fontdata,offset)
  setposition(f,offset)
  local glyphs=fontdata.glyphs
  local minoverlap=readushort(f)
  local vcoverage=readushort(f)
  local hcoverage=readushort(f)
  local vnofglyphs=readushort(f)
  local hnofglyphs=readushort(f)
  local vconstruction=readcardinaltable(f,vnofglyphs,ushort)
  local hconstruction=readcardinaltable(f,hnofglyphs,ushort)
  fontdata.mathconstants.MinConnectorOverlap=minoverlap
  local function get(offset,coverage,nofglyphs,construction,kvariants,kparts,kitalic)
    if coverage~=0 and nofglyphs>0 then
      local coverage=readcoverage(f,offset+coverage,true)
      for i=1,nofglyphs do
        local c=construction[i]
        if c~=0 then
          local index=coverage[i]
          local glyph=glyphs[index]
          local math=glyph.math
          setposition(f,offset+c)
          local assembly=readushort(f)
          local nofvariants=readushort(f)
          if nofvariants>0 then
            local variants,v=nil,0
            for i=1,nofvariants do
              local variant=readushort(f)
              if variant==index then
              elseif variants then
                v=v+1
                variants[v]=variant
              else
                v=1
                variants={ variant }
              end
              skipshort(f)
            end
            if not variants then
            elseif not math then
              math={ [kvariants]=variants }
              glyph.math=math
            else
              math[kvariants]=variants
            end
          end
          if assembly~=0 then
            setposition(f,offset+c+assembly)
            local italic=readmathvalue(f)
            local nofparts=readushort(f)
            local parts={}
            for i=1,nofparts do
              local p={
                glyph=readushort(f),
                start=readushort(f),
                ["end"]=readushort(f),
                advance=readushort(f),
              }
              local flags=readushort(f)
              if band(flags,0x0001)~=0 then
                p.extender=1 
              end
              parts[i]=p
            end
            if not math then
              math={
                [kparts]=parts
              }
              glyph.math=math
            else
              math[kparts]=parts
            end
            if italic and italic~=0 then
              math[kitalic]=italic
            end
          end
        end
      end
    end
  end
  get(offset,vcoverage,vnofglyphs,vconstruction,"vvariants","vparts","vitalic")
  get(offset,hcoverage,hnofglyphs,hconstruction,"hvariants","hparts","hitalic")
end
function readers.math(f,fontdata,specification)
  local tableoffset=gotodatatable(f,fontdata,"math",specification.glyphs)
  if tableoffset then
    local version=readulong(f)
    local constants=readushort(f)
    local glyphinfo=readushort(f)
    local variants=readushort(f)
    if constants==0 then
      report("the math table of %a has no constants",fontdata.filename)
    else
      readmathconstants(f,fontdata,tableoffset+constants)
    end
    if glyphinfo~=0 then
      readmathglyphinfo(f,fontdata,tableoffset+glyphinfo)
    end
    if variants~=0 then
      readmathvariants(f,fontdata,tableoffset+variants)
    end
  end
end
function readers.colr(f,fontdata,specification)
  local tableoffset=gotodatatable(f,fontdata,"colr",specification.glyphs)
  if tableoffset then
    local version=readushort(f)
    if version~=0 then
      report("table version %a of %a is not supported (yet), maybe font %s is bad",version,"colr",fontdata.filename)
      return
    end
    if not fontdata.tables.cpal then
      report("color table %a in font %a has no mandate %a table","colr",fontdata.filename,"cpal")
      fontdata.colorpalettes={}
    end
    local glyphs=fontdata.glyphs
    local nofglyphs=readushort(f)
    local baseoffset=readulong(f)
    local layeroffset=readulong(f)
    local noflayers=readushort(f)
    local layerrecords={}
    local maxclass=0
    setposition(f,tableoffset+layeroffset)
    for i=1,noflayers do
      local slot=readushort(f)
      local class=readushort(f)
      if class<0xFFFF then
        class=class+1
        if class>maxclass then
          maxclass=class
        end
      end
      layerrecords[i]={
        slot=slot,
        class=class,
      }
    end
    fontdata.maxcolorclass=maxclass
    setposition(f,tableoffset+baseoffset)
    for i=0,nofglyphs-1 do
      local glyphindex=readushort(f)
      local firstlayer=readushort(f)
      local noflayers=readushort(f)
      local t={}
      for i=1,noflayers do
        t[i]=layerrecords[firstlayer+i]
      end
      glyphs[glyphindex].colors=t
    end
  end
  fontdata.hascolor=true
end
function readers.cpal(f,fontdata,specification)
  local tableoffset=gotodatatable(f,fontdata,"cpal",specification.glyphs)
  if tableoffset then
    local version=readushort(f)
    local nofpaletteentries=readushort(f)
    local nofpalettes=readushort(f)
    local nofcolorrecords=readushort(f)
    local firstcoloroffset=readulong(f)
    local colorrecords={}
    local palettes=readcardinaltable(f,nofpalettes,ushort)
    if version==1 then
      local palettettypesoffset=readulong(f)
      local palettelabelsoffset=readulong(f)
      local paletteentryoffset=readulong(f)
    end
    setposition(f,tableoffset+firstcoloroffset)
    for i=1,nofcolorrecords do
      local b,g,r,a=readbytes(f,4)
      colorrecords[i]={
        r,g,b,a~=255 and a or nil,
      }
    end
    for i=1,nofpalettes do
      local p={}
      local o=palettes[i]
      for j=1,nofpaletteentries do
        p[j]=colorrecords[o+j]
      end
      palettes[i]=p
    end
    fontdata.colorpalettes=palettes
  end
end
function readers.svg(f,fontdata,specification)
  local tableoffset=gotodatatable(f,fontdata,"svg",specification.glyphs)
  if tableoffset then
    local version=readushort(f)
    local glyphs=fontdata.glyphs
    local indexoffset=tableoffset+readulong(f)
    local reserved=readulong(f)
    setposition(f,indexoffset)
    local nofentries=readushort(f)
    local entries={}
    for i=1,nofentries do
      entries[i]={
        first=readushort(f),
        last=readushort(f),
        offset=indexoffset+readulong(f),
        length=readulong(f),
      }
    end
    for i=1,nofentries do
      local entry=entries[i]
      setposition(f,entry.offset)
      entries[i]={
        first=entry.first,
        last=entry.last,
        data=readstring(f,entry.length)
      }
    end
    fontdata.svgshapes=entries
  end
  fontdata.hascolor=true
end
function readers.sbix(f,fontdata,specification)
  local tableoffset=gotodatatable(f,fontdata,"sbix",specification.glyphs)
  if tableoffset then
    local version=readushort(f)
    local flags=readushort(f)
    local nofstrikes=readulong(f)
    local strikes={}
    local nofglyphs=fontdata.nofglyphs
    for i=1,nofstrikes do
      strikes[i]=readulong(f)
    end
      local shapes={}
      local done=0
      for i=1,nofstrikes do
        local strikeoffset=strikes[i]+tableoffset
        setposition(f,strikeoffset)
        strikes[i]={
          ppem=readushort(f),
          ppi=readushort(f),
          offset=strikeoffset
        }
      end
      sort(strikes,function(a,b)
        if b.ppem==a.ppem then
          return b.ppi<a.ppi
        else
          return b.ppem<a.ppem
        end
      end)
      local glyphs={}
      for i=1,nofstrikes do
        local strike=strikes[i]
        local strikeppem=strike.ppem
        local strikeppi=strike.ppi
        local strikeoffset=strike.offset
        setposition(f,strikeoffset)
        for i=0,nofglyphs do
          glyphs[i]=readulong(f)
        end
        local glyphoffset=glyphs[0]
        for i=0,nofglyphs-1 do
          local nextoffset=glyphs[i+1]
          if not shapes[i] then
            local datasize=nextoffset-glyphoffset
            if datasize>0 then
              setposition(f,strikeoffset+glyphoffset)
              shapes[i]={
                x=readshort(f),
                y=readshort(f),
                tag=readtag(f),
                data=readstring(f,datasize-8),
                ppem=strikeppem,
                ppi=strikeppi,
              }
              done=done+1
              if done==nofglyphs then
                break
              end
            end
          end
          glyphoffset=nextoffset
        end
      end
      fontdata.sbixshapes=shapes
  end
end
function readers.stat(f,fontdata,specification)
  local tableoffset=gotodatatable(f,fontdata,"stat",true) 
  if tableoffset then
    local extras=fontdata.extras
    local version=readulong(f) 
    local axissize=readushort(f)
    local nofaxis=readushort(f)
    local axisoffset=readulong(f)
    local nofvalues=readushort(f)
    local valuesoffset=readulong(f)
    local fallbackname=extras[readushort(f)] 
    local axis={}
    local values={}
    setposition(f,tableoffset+axisoffset)
    for i=1,nofaxis do
      local tag=readtag(f)
      axis[i]={
        tag=tag,
        name=lower(extras[readushort(f)] or tag),
        ordering=readushort(f),
        variants={}
      }
    end
    setposition(f,tableoffset+valuesoffset)
    for i=1,nofvalues do
      values[i]=readushort(f)
    end
    for i=1,nofvalues do
      setposition(f,tableoffset+valuesoffset+values[i])
      local format=readushort(f)
      local index=readushort(f)+1
      local flags=readushort(f)
      local name=lower(extras[readushort(f)] or "no name")
      local value=readfixed(f)
      local variant
      if format==1 then
        variant={
          flags=flags,
          name=name,
          value=value,
        }
      elseif format==2 then
        variant={
          flags=flags,
          name=name,
          value=value,
          minimum=readfixed(f),
          maximum=readfixed(f),
        }
      elseif format==3 then
        variant={
          flags=flags,
          name=name,
          value=value,
          link=readfixed(f),
        }
      end
      insert(axis[index].variants,variant)
    end
    sort(axis,function(a,b)
      return a.ordering<b.ordering
    end)
    for i=1,#axis do
      local a=axis[i]
      sort(a.variants,function(a,b)
        return a.name<b.name
      end)
      a.ordering=nil
    end
    setvariabledata(fontdata,"designaxis",axis)
    setvariabledata(fontdata,"fallbackname",fallbackname)
  end
end
function readers.avar(f,fontdata,specification)
  local tableoffset=gotodatatable(f,fontdata,"avar",true) 
  if tableoffset then
    local function collect()
      local nofvalues=readushort(f)
      local values={}
      local lastfrom=false
      local lastto=false
      for i=1,nofvalues do
        local f,t=read2dot14(f),read2dot14(f)
        if lastfrom and f<=lastfrom then
        elseif lastto and t>=lastto then
        else
          values[#values+1]={ f,t }
          lastfrom,lastto=f,t
        end
      end
      nofvalues=#values
      if nofvalues>2 then
        local some=values[1]
        if some[1]==-1 and some[2]==-1 then
          some=values[nofvalues]
          if some[1]==1 and some[2]==1 then
            for i=2,nofvalues-1 do
              some=values[i]
              if some[1]==0 and some[2]==0 then
                return values
              end
            end
          end
        end
      end
      return false
    end
    local majorversion=readushort(f) 
    local minorversion=readushort(f) 
    local reserved=readushort(f)
    local nofaxis=readushort(f)
    local segments={}
    for i=1,nofaxis do
      segments[i]=collect()
    end
    setvariabledata(fontdata,"segments",segments)
  end
end
function readers.fvar(f,fontdata,specification)
  local tableoffset=gotodatatable(f,fontdata,"fvar",true) 
  if tableoffset then
    local version=readulong(f) 
    local offsettoaxis=tableoffset+readushort(f)
    local reserved=skipshort(f)
    local nofaxis=readushort(f)
    local sizeofaxis=readushort(f)
    local nofinstances=readushort(f)
    local sizeofinstances=readushort(f)
    local extras=fontdata.extras
    local axis={}
    local instances={}
    setposition(f,offsettoaxis)
    for i=1,nofaxis do
      axis[i]={
        tag=readtag(f),
        minimum=readfixed(f),
        default=readfixed(f),
        maximum=readfixed(f),
        flags=readushort(f),
        name=lower(extras[readushort(f)] or "bad name"),
      }
      local n=sizeofaxis-20
      if n>0 then
        skipbytes(f,n)
      elseif n<0 then
      end
    end
    local nofbytes=2+2+2+nofaxis*4
    local readpsname=nofbytes<=sizeofinstances
    local skippable=sizeofinstances-nofbytes
    for i=1,nofinstances do
      local subfamid=readushort(f)
      local flags=readushort(f) 
      local values={}
      for i=1,nofaxis do
        values[i]={
          axis=axis[i].tag,
          value=readfixed(f),
        }
      end
      local psnameid=readpsname and readushort(f) or 0xFFFF
      if subfamid==2 or subfamid==17 then
      elseif subfamid==0xFFFF then
        subfamid=nil
      elseif subfamid<=256 or subfamid>=32768 then
        subfamid=nil 
      end
      if psnameid==6 then
      elseif psnameid==0xFFFF then
        psnameid=nil
      elseif psnameid<=256 or psnameid>=32768 then
        psnameid=nil 
      end
      instances[i]={
        subfamily=extras[subfamid],
        psname=psnameid and extras[psnameid] or nil,
        values=values,
      }
      if skippable>0 then
        skipbytes(f,skippable)
      end
    end
    setvariabledata(fontdata,"axis",axis)
    setvariabledata(fontdata,"instances",instances)
  end
end
function readers.hvar(f,fontdata,specification)
  local factors=specification.factors
  if not factors then
    return
  end
  local tableoffset=gotodatatable(f,fontdata,"hvar",specification.variable)
  if not tableoffset then
    return
  end
  local version=readulong(f) 
  local variationoffset=tableoffset+readulong(f) 
  local advanceoffset=tableoffset+readulong(f)
  local lsboffset=tableoffset+readulong(f)
  local rsboffset=tableoffset+readulong(f)
  local regions={}
  local variations={}
  local innerindex={} 
  local outerindex={} 
  if variationoffset>0 then
    regions,deltas=readvariationdata(f,variationoffset,factors)
  end
  if not regions then
    return
  end
  if advanceoffset>0 then
    setposition(f,advanceoffset)
    local format=readushort(f) 
    local mapcount=readushort(f)
    local entrysize=rshift(band(format,0x0030),4)+1
    local nofinnerbits=band(format,0x000F)+1 
    local innermask=lshift(1,nofinnerbits)-1
    local readcardinal=read_cardinal[entrysize] 
    for i=0,mapcount-1 do
      local mapdata=readcardinal(f)
      outerindex[i]=rshift(mapdata,nofinnerbits)
      innerindex[i]=band(mapdata,innermask)
    end
    setvariabledata(fontdata,"hvarwidths",true)
    local glyphs=fontdata.glyphs
    for i=0,fontdata.nofglyphs-1 do
      local glyph=glyphs[i]
      local width=glyph.width
      if width then
        local outer=outerindex[i] or 0
        local inner=innerindex[i] or i
        if outer and inner then 
          local delta=deltas[outer+1]
          if delta then
            local d=delta.deltas[inner+1]
            if d then
              local scales=delta.scales
              local deltaw=0
              for i=1,#scales do
                local di=d[i]
                if di then
                  deltaw=deltaw+scales[i]*di
                else
                  break 
                end
              end
              glyph.width=width+round(deltaw)
            end
          end
        end
      end
    end
  end
end
function readers.vvar(f,fontdata,specification)
  if not specification.variable then
    return
  end
end
function readers.mvar(f,fontdata,specification)
  local tableoffset=gotodatatable(f,fontdata,"mvar",specification.variable)
  if tableoffset then
    local version=readulong(f) 
    local reserved=skipshort(f,1)
    local recordsize=readushort(f)
    local nofrecords=readushort(f)
    local offsettostore=tableoffset+readushort(f)
    local dimensions={}
    local factors=specification.factors
    if factors then
      local regions,deltas=readvariationdata(f,offsettostore,factors)
      for i=1,nofrecords do
        local tag=readtag(f)
        local var=variabletags[tag]
        if var then
          local outer=readushort(f)
          local inner=readushort(f)
          local delta=deltas[outer+1]
          if delta then
            local d=delta.deltas[inner+1]
            if d then
              local scales=delta.scales
              local dd=0
              for i=1,#scales do
                dd=dd+scales[i]*d[i]
              end
              var(fontdata,round(dd))
            end
          end
        else
          skipshort(f,2)
        end
        if recordsize>8 then 
          skipbytes(recordsize-8)
        end
      end
    end
  end
end

end --- [luaotfload, fontloader-2018-10-08.lua scope for “font-dsp”] ---


do  --- [luaotfload, fontloader-2018-10-08.lua scope for “font-oup” 7b8c2974b5ba404790feb3bd6c5cddb1] ---

if not modules then modules={} end modules ['font-oup']={
  version=1.001,
  comment="companion to font-ini.mkiv",
  author="Hans Hagen, PRAGMA-ADE, Hasselt NL",
  copyright="PRAGMA ADE / ConTeXt Development Team",
  license="see context related readme files"
}
local next,type=next,type
local P,R,S=lpeg.P,lpeg.R,lpeg.S
local lpegmatch=lpeg.match
local insert,remove,copy,unpack=table.insert,table.remove,table.copy,table.unpack
local formatters=string.formatters
local sortedkeys=table.sortedkeys
local sortedhash=table.sortedhash
local tohash=table.tohash
local setmetatableindex=table.setmetatableindex
local report_error=logs.reporter("otf reader","error")
local report_markwidth=logs.reporter("otf reader","markwidth")
local report_cleanup=logs.reporter("otf reader","cleanup")
local report_optimizations=logs.reporter("otf reader","merges")
local report_unicodes=logs.reporter("otf reader","unicodes")
local trace_markwidth=false trackers.register("otf.markwidth",function(v) trace_markwidth=v end)
local trace_cleanup=false trackers.register("otf.cleanups",function(v) trace_cleanups=v end)
local trace_optimizations=false trackers.register("otf.optimizations",function(v) trace_optimizations=v end)
local trace_unicodes=false trackers.register("otf.unicodes",function(v) trace_unicodes=v end)
local readers=fonts.handlers.otf.readers
local privateoffset=fonts.constructors and fonts.constructors.privateoffset or 0xF0000 
local f_private=formatters["P%05X"]
local f_unicode=formatters["U%05X"]
local f_index=formatters["I%05X"]
local f_character_y=formatters["%C"]
local f_character_n=formatters["[ %C ]"]
local check_duplicates=true 
local check_soft_hyphen=true 
directives.register("otf.checksofthyphen",function(v)
  check_soft_hyphen=v
end)
local function replaced(list,index,replacement)
  if type(list)=="number" then
    return replacement
  elseif type(replacement)=="table" then
    local t={}
    local n=index-1
    for i=1,n do
      t[i]=list[i]
    end
    for i=1,#replacement do
      n=n+1
      t[n]=replacement[i]
    end
    for i=index+1,#list do
      n=n+1
      t[n]=list[i]
    end
  else
    list[index]=replacement
    return list
  end
end
local function unifyresources(fontdata,indices)
  local descriptions=fontdata.descriptions
  local resources=fontdata.resources
  if not descriptions or not resources then
    return
  end
  local nofindices=#indices
  local variants=fontdata.resources.variants
  if variants then
    for selector,unicodes in next,variants do
      for unicode,index in next,unicodes do
        unicodes[unicode]=indices[index]
      end
    end
  end
  local function remark(marks)
    if marks then
      local newmarks={}
      for k,v in next,marks do
        local u=indices[k]
        if u then
          newmarks[u]=v
        elseif trace_optimizations then
          report_optimizations("discarding mark %i",k)
        end
      end
      return newmarks
    end
  end
  local marks=resources.marks
  if marks then
    resources.marks=remark(marks)
  end
  local markclasses=resources.markclasses
  if markclasses then
    for class,marks in next,markclasses do
      markclasses[class]=remark(marks)
    end
  end
  local marksets=resources.marksets
  if marksets then
    for class,marks in next,marksets do
      marksets[class]=remark(marks)
    end
  end
  local done={}
  local duplicates=check_duplicates and resources.duplicates
  if duplicates and not next(duplicates) then
    duplicates=false
  end
  local function recover(cover) 
    for i=1,#cover do
      local c=cover[i]
      if not done[c] then
        local t={}
        for k,v in next,c do
          local ug=indices[k]
          if ug then
            t[ug]=v
          else
            report_error("case %i, bad index in unifying %s: %s of %s",1,"coverage",k,nofindices)
          end
        end
        cover[i]=t
        done[c]=d
      end
    end
  end
  local function recursed(c,kind) 
    local t={}
    for g,d in next,c do
      if type(d)=="table" then
        local ug=indices[g]
        if ug then
          t[ug]=recursed(d,kind)
        else
          report_error("case %i, bad index in unifying %s: %s of %s",1,kind,g,nofindices)
        end
      else
        t[g]=indices[d] 
      end
    end
    return t
  end
  local function unifythem(sequences)
    if not sequences then
      return
    end
    for i=1,#sequences do
      local sequence=sequences[i]
      local kind=sequence.type
      local steps=sequence.steps
      local features=sequence.features
      if steps then
        for i=1,#steps do
          local step=steps[i]
          if kind=="gsub_single" then
            local c=step.coverage
            if c then
              local t1=done[c]
              if not t1 then
                t1={}
                if duplicates then
                  for g1,d1 in next,c do
                    local ug1=indices[g1]
                    if ug1 then
                      local ud1=indices[d1]
                      if ud1 then
                        t1[ug1]=ud1
                        local dg1=duplicates[ug1]
                        if dg1 then
                          for u in next,dg1 do
                            t1[u]=ud1
                          end
                        end
                      else
                        report_error("case %i, bad index in unifying %s: %s of %s",3,kind,d1,nofindices)
                      end
                    else
                      report_error("case %i, bad index in unifying %s: %s of %s",1,kind,g1,nofindices)
                    end
                  end
                else
                  for g1,d1 in next,c do
                    local ug1=indices[g1]
                    if ug1 then
                      t1[ug1]=indices[d1]
                    else
                      report_error("fuzzy case %i in unifying %s: %i",2,kind,g1)
                    end
                  end
                end
                done[c]=t1
              end
              step.coverage=t1
            end
          elseif kind=="gpos_pair" then
            local c=step.coverage
            if c then
              local t1=done[c]
              if not t1 then
                t1={}
                for g1,d1 in next,c do
                  local ug1=indices[g1]
                  if ug1 then
                    local t2=done[d1]
                    if not t2 then
                      t2={}
                      for g2,d2 in next,d1 do
                        local ug2=indices[g2]
                        if ug2 then
                          t2[ug2]=d2
                        else
                          report_error("case %i, bad index in unifying %s: %s of %s",1,kind,g2,nofindices,nofindices)
                        end
                      end
                      done[d1]=t2
                    end
                    t1[ug1]=t2
                  else
                    report_error("case %i, bad index in unifying %s: %s of %s",2,kind,g1,nofindices)
                  end
                end
                done[c]=t1
              end
              step.coverage=t1
            end
          elseif kind=="gsub_ligature" then
            local c=step.coverage
            if c then
              step.coverage=recursed(c,kind)
            end
          elseif kind=="gsub_alternate" or kind=="gsub_multiple" then
            local c=step.coverage
            if c then
              local t1=done[c]
              if not t1 then
                t1={}
                if duplicates then
                  for g1,d1 in next,c do
                    for i=1,#d1 do
                      local d1i=d1[i]
                      local d1u=indices[d1i]
                      if d1u then
                        d1[i]=d1u
                      else
                        report_error("case %i, bad index in unifying %s: %s of %s",1,kind,i,d1i,nofindices)
                      end
                    end
                    local ug1=indices[g1]
                    if ug1 then
                      t1[ug1]=d1
                      local dg1=duplicates[ug1]
                      if dg1 then
                        for u in next,dg1 do
                          t1[u]=copy(d1)
                        end
                      end
                    else
                      report_error("case %i, bad index in unifying %s: %s of %s",2,kind,g1,nofindices)
                    end
                  end
                else
                  for g1,d1 in next,c do
                    for i=1,#d1 do
                      local d1i=d1[i]
                      local d1u=indices[d1i]
                      if d1u then
                        d1[i]=d1u
                      else
                        report_error("case %i, bad index in unifying %s: %s of %s",2,kind,d1i,nofindices)
                      end
                    end
                    t1[indices[g1]]=d1
                  end
                end
                done[c]=t1
              end
              step.coverage=t1
            end
          elseif kind=="gpos_single" then
            local c=step.coverage
            if c then
              local t1=done[c]
              if not t1 then
                t1={}
                if duplicates then
                  for g1,d1 in next,c do
                    local ug1=indices[g1]
                    if ug1 then
                      t1[ug1]=d1
                      local dg1=duplicates[ug1]
                      if dg1 then
                        for u in next,dg1 do
                          t1[u]=d1
                        end
                      end
                    else
                      report_error("case %i, bad index in unifying %s: %s of %s",1,kind,g1,nofindices)
                    end
                  end
                else
                  for g1,d1 in next,c do
                    local ug1=indices[g1]
                    if ug1 then
                      t1[ug1]=d1
                    else
                      report_error("case %i, bad index in unifying %s: %s of %s",2,kind,g1,nofindices)
                    end
                  end
                end
                done[c]=t1
              end
              step.coverage=t1
            end
          elseif kind=="gpos_mark2base" or kind=="gpos_mark2mark" or kind=="gpos_mark2ligature" then
            local c=step.coverage
            if c then
              local t1=done[c]
              if not t1 then
                t1={}
                for g1,d1 in next,c do
                  local ug1=indices[g1]
                  if ug1 then
                    t1[ug1]=d1
                  else
                    report_error("case %i, bad index in unifying %s: %s of %s",1,kind,g1,nofindices)
                  end
                end
                done[c]=t1
              end
              step.coverage=t1
            end
            local c=step.baseclasses
            if c then
              local t1=done[c]
              if not t1 then
                for g1,d1 in next,c do
                  local t2=done[d1]
                  if not t2 then
                    t2={}
                    for g2,d2 in next,d1 do
                      local ug2=indices[g2]
                      if ug2 then
                        t2[ug2]=d2
                      else
                        report_error("case %i, bad index in unifying %s: %s of %s",2,kind,g2,nofindices)
                      end
                    end
                    done[d1]=t2
                  end
                  c[g1]=t2
                end
                done[c]=c
              end
            end
          elseif kind=="gpos_cursive" then
            local c=step.coverage
            if c then
              local t1=done[c]
              if not t1 then
                t1={}
                if duplicates then
                  for g1,d1 in next,c do
                    local ug1=indices[g1]
                    if ug1 then
                      t1[ug1]=d1
                      local dg1=duplicates[ug1]
                      if dg1 then
                        for u in next,dg1 do
                          t1[u]=copy(d1)
                        end
                      end
                    else
                      report_error("case %i, bad index in unifying %s: %s of %s",1,kind,g1,nofindices)
                    end
                  end
                else
                  for g1,d1 in next,c do
                    local ug1=indices[g1]
                    if ug1 then
                      t1[ug1]=d1
                    else
                      report_error("case %i, bad index in unifying %s: %s of %s",2,kind,g1,nofindices)
                    end
                  end
                end
                done[c]=t1
              end
              step.coverage=t1
            end
          end
          local rules=step.rules
          if rules then
            for i=1,#rules do
              local rule=rules[i]
              local before=rule.before  if before then recover(before) end
              local after=rule.after  if after  then recover(after)  end
              local current=rule.current if current then recover(current) end
              local replacements=rule.replacements
              if replacements then
                if not done[replacements] then
                  local r={}
                  for k,v in next,replacements do
                    r[indices[k]]=indices[v]
                  end
                  rule.replacements=r
                  done[replacements]=r
                end
              end
            end
          end
        end
      end
    end
  end
  unifythem(resources.sequences)
  unifythem(resources.sublookups)
end
local function copyduplicates(fontdata)
  if check_duplicates then
    local descriptions=fontdata.descriptions
    local resources=fontdata.resources
    local duplicates=resources.duplicates
    if check_soft_hyphen then
      local ds=descriptions[0xAD]
      if not ds or ds.width==0 then
        if ds then
          descriptions[0xAD]=nil
          if trace_unicodes then
            report_unicodes("patching soft hyphen")
          end
        else
          if trace_unicodes then
            report_unicodes("adding soft hyphen")
          end
        end
        if not duplicates then
          duplicates={}
          resources.duplicates=duplicates
        end
        local dh=duplicates[0x2D]
        if dh then
          dh[#dh+1]={ [0xAD]=true }
        else
          duplicates[0x2D]={ [0xAD]=true }
        end
      end
    end
    if duplicates then
      for u,d in next,duplicates do
        local du=descriptions[u]
        if du then
          local t={ f_character_y(u),"@",f_index(du.index),"->" }
          local n=0
          local m=25
          for u in next,d do
            if descriptions[u] then
              if n<m then
                t[n+4]=f_character_n(u)
              end
            else
              local c=copy(du)
              c.unicode=u 
              descriptions[u]=c
              if n<m then
                t[n+4]=f_character_y(u)
              end
            end
            n=n+1
          end
          if trace_unicodes then
            if n<=m then
              report_unicodes("%i : % t",n,t)
            else
              report_unicodes("%i : % t ...",n,t)
            end
          end
        else
        end
      end
    end
  end
end
local ignore={ 
  ["notdef"]=true,
  [".notdef"]=true,
  ["null"]=true,
  [".null"]=true,
  ["nonmarkingreturn"]=true,
}
local function checklookups(fontdata,missing,nofmissing)
  local descriptions=fontdata.descriptions
  local resources=fontdata.resources
  if missing and nofmissing and nofmissing<=0 then
    return
  end
  local singles={}
  local alternates={}
  local ligatures={}
  if not missing then
    missing={}
    nofmissing=0
    for u,d in next,descriptions do
      if not d.unicode then
        nofmissing=nofmissing+1
        missing[u]=true
      end
    end
  end
  local function collectthem(sequences)
    if not sequences then
      return
    end
    for i=1,#sequences do
      local sequence=sequences[i]
      local kind=sequence.type
      local steps=sequence.steps
      if steps then
        for i=1,#steps do
          local step=steps[i]
          if kind=="gsub_single" then
            local c=step.coverage
            if c then
              singles[#singles+1]=c
            end
          elseif kind=="gsub_alternate" then
            local c=step.coverage
            if c then
              alternates[#alternates+1]=c
            end
          elseif kind=="gsub_ligature" then
            local c=step.coverage
            if c then
              ligatures[#ligatures+1]=c
            end
          end
        end
      end
    end
  end
  collectthem(resources.sequences)
  collectthem(resources.sublookups)
  local loops=0
  while true do
    loops=loops+1
    local old=nofmissing
    for i=1,#singles do
      local c=singles[i]
      for g1,g2 in next,c do
        if missing[g1] then
          local u2=descriptions[g2].unicode
          if u2 then
            missing[g1]=false
            descriptions[g1].unicode=u2
            nofmissing=nofmissing-1
          end
        end
        if missing[g2] then
          local u1=descriptions[g1].unicode
          if u1 then
            missing[g2]=false
            descriptions[g2].unicode=u1
            nofmissing=nofmissing-1
          end
        end
      end
    end
    for i=1,#alternates do
      local c=alternates[i]
      for g1,d1 in next,c do
        if missing[g1] then
          for i=1,#d1 do
            local g2=d1[i]
            local u2=descriptions[g2].unicode
            if u2 then
              missing[g1]=false
              descriptions[g1].unicode=u2
              nofmissing=nofmissing-1
            end
          end
        end
        if not missing[g1] then
          for i=1,#d1 do
            local g2=d1[i]
            if missing[g2] then
              local u1=descriptions[g1].unicode
              if u1 then
                missing[g2]=false
                descriptions[g2].unicode=u1
                nofmissing=nofmissing-1
              end
            end
          end
        end
      end
    end
    if nofmissing<=0 then
      if trace_unicodes then
        report_unicodes("all missings done in %s loops",loops)
      end
      return
    elseif old==nofmissing then
      break
    end
  end
  local t,n 
  local function recursed(c)
    for g,d in next,c do
      if g~="ligature" then
        local u=descriptions[g].unicode
        if u then
          n=n+1
          t[n]=u
          recursed(d)
          n=n-1
        end
      elseif missing[d] then
        local l={}
        local m=0
        for i=1,n do
          local u=t[i]
          if type(u)=="table" then
            for i=1,#u do
              m=m+1
              l[m]=u[i]
            end
          else
            m=m+1
            l[m]=u
          end
        end
        missing[d]=false
        descriptions[d].unicode=l
        nofmissing=nofmissing-1
      end
    end
  end
  if nofmissing>0 then
    t={}
    n=0
    local loops=0
    while true do
      loops=loops+1
      local old=nofmissing
      for i=1,#ligatures do
        recursed(ligatures[i])
      end
      if nofmissing<=0 then
        if trace_unicodes then
          report_unicodes("all missings done in %s loops",loops)
        end
        return
      elseif old==nofmissing then
        break
      end
    end
    t=nil
    n=0
  end
  if trace_unicodes and nofmissing>0 then
    local done={}
    for i,r in next,missing do
      if r then
        local data=descriptions[i]
        local name=data and data.name or f_index(i)
        if not ignore[name] then
          done[name]=true
        end
      end
    end
    if next(done) then
      report_unicodes("not unicoded: % t",sortedkeys(done))
    end
  end
end
local function unifymissing(fontdata)
  if not fonts.mappings then
    require("font-map")
    require("font-agl")
  end
  local unicodes={}
  local resources=fontdata.resources
  resources.unicodes=unicodes
  for unicode,d in next,fontdata.descriptions do
    if unicode<privateoffset then
      local name=d.name
      if name then
        unicodes[name]=unicode
      end
    end
  end
  fonts.mappings.addtounicode(fontdata,fontdata.filename,checklookups)
  resources.unicodes=nil
end
local firstprivate=fonts.privateoffsets.textbase or 0xF0000
local puafirst=0xE000
local pualast=0xF8FF
local function unifyglyphs(fontdata,usenames)
  local private=fontdata.private or privateoffset
  local glyphs=fontdata.glyphs
  local indices={}
  local descriptions={}
  local names=usenames and {}
  local resources=fontdata.resources
  local zero=glyphs[0]
  local zerocode=zero.unicode
  if not zerocode then
    zerocode=private
    zero.unicode=zerocode
    private=private+1
  end
  descriptions[zerocode]=zero
  if names then
    local name=glyphs[0].name or f_private(zerocode)
    indices[0]=name
    names[name]=zerocode
  else
    indices[0]=zerocode
  end
  if names then
    for index=1,#glyphs do
      local glyph=glyphs[index]
      local unicode=glyph.unicode 
      if not unicode then
        unicode=private
        local name=glyph.name or f_private(unicode)
        indices[index]=name
        names[name]=unicode
        private=private+1
      elseif unicode>=firstprivate then
        unicode=private
        local name=glyph.name or f_private(unicode)
        indices[index]=name
        names[name]=unicode
        private=private+1
      elseif unicode>=puafirst and unicode<=pualast then
        local name=glyph.name or f_private(unicode)
        indices[index]=name
        names[name]=unicode
      elseif descriptions[unicode] then
        unicode=private
        local name=glyph.name or f_private(unicode)
        indices[index]=name
        names[name]=unicode
        private=private+1
      else
        local name=glyph.name or f_unicode(unicode)
        indices[index]=name
        names[name]=unicode
      end
      descriptions[unicode]=glyph
    end
  elseif trace_unicodes then
    for index=1,#glyphs do
      local glyph=glyphs[index]
      local unicode=glyph.unicode 
      if not unicode then
        unicode=private
        indices[index]=unicode
        private=private+1
      elseif unicode>=firstprivate then
        local name=glyph.name
        if name then
          report_unicodes("moving glyph %a indexed %05X from private %U to %U ",name,index,unicode,private)
        else
          report_unicodes("moving glyph indexed %05X from private %U to %U ",index,unicode,private)
        end
        unicode=private
        indices[index]=unicode
        private=private+1
      elseif unicode>=puafirst and unicode<=pualast then
        local name=glyph.name
        if name then
          report_unicodes("keeping private unicode %U for glyph %a indexed %05X",unicode,name,index)
        else
          report_unicodes("keeping private unicode %U for glyph indexed %05X",unicode,index)
        end
        indices[index]=unicode
      elseif descriptions[unicode] then
        local name=glyph.name
        if name then
          report_unicodes("assigning duplicate unicode %U to %U for glyph %a indexed %05X ",unicode,private,name,index)
        else
          report_unicodes("assigning duplicate unicode %U to %U for glyph indexed %05X ",unicode,private,index)
        end
        unicode=private
        indices[index]=unicode
        private=private+1
      else
        indices[index]=unicode
      end
      descriptions[unicode]=glyph
    end
  else
    for index=1,#glyphs do
      local glyph=glyphs[index]
      local unicode=glyph.unicode 
      if not unicode then
        unicode=private
        indices[index]=unicode
        private=private+1
      elseif unicode>=firstprivate then
        local name=glyph.name
        unicode=private
        indices[index]=unicode
        private=private+1
      elseif unicode>=puafirst and unicode<=pualast then
        local name=glyph.name
        indices[index]=unicode
      elseif descriptions[unicode] then
        local name=glyph.name
        unicode=private
        indices[index]=unicode
        private=private+1
      else
        indices[index]=unicode
      end
      descriptions[unicode]=glyph
    end
  end
  for index=1,#glyphs do
    local math=glyphs[index].math
    if math then
      local list=math.vparts
      if list then
        for i=1,#list do local l=list[i] l.glyph=indices[l.glyph] end
      end
      local list=math.hparts
      if list then
        for i=1,#list do local l=list[i] l.glyph=indices[l.glyph] end
      end
      local list=math.vvariants
      if list then
        for i=1,#list do list[i]=indices[list[i]] end
      end
      local list=math.hvariants
      if list then
        for i=1,#list do list[i]=indices[list[i]] end
      end
    end
  end
  local colorpalettes=resources.colorpalettes
  if colorpalettes then
    for index=1,#glyphs do
      local colors=glyphs[index].colors
      if colors then
        for i=1,#colors do
          local c=colors[i]
          c.slot=indices[c.slot]
        end
      end
    end
  end
  fontdata.private=private
  fontdata.glyphs=nil
  fontdata.names=names
  fontdata.descriptions=descriptions
  fontdata.hashmethod=hashmethod
  return indices,names
end
local p_crappyname do
  local p_hex=R("af","AF","09")
  local p_digit=R("09")
  local p_done=S("._-")^0+P(-1)
  local p_alpha=R("az","AZ")
  local p_ALPHA=R("AZ")
  p_crappyname=(
    lpeg.utfchartabletopattern({ "uni","u" },true)*S("Xx_")^0*p_hex^1
+lpeg.utfchartabletopattern({ "identity","glyph","jamo" },true)*p_hex^1
+lpeg.utfchartabletopattern({ "index","afii" },true)*p_digit^1
+p_digit*p_hex^3+p_alpha*p_digit^1
+P("aj")*p_digit^1+P("eh_")*(p_digit^1+p_ALPHA*p_digit^1)+(1-P("_"))^1*P("_uni")*p_hex^1
  )*p_done
end
local forcekeep=false 
directives.register("otf.keepnames",function(v)
  report_cleanup("keeping weird glyph names, expect larger files and more memory usage")
  forcekeep=v
end)
local function stripredundant(fontdata)
  local descriptions=fontdata.descriptions
  if descriptions then
    local n=0
    local c=0
    if not context and fonts.privateoffsets.keepnames then
      for unicode,d in next,descriptions do
        if d.class=="base" then
          d.class=nil
          c=c+1
        end
      end
    else
      for unicode,d in next,descriptions do
        local name=d.name
        if name and lpegmatch(p_crappyname,name) then
          d.name=nil
          n=n+1
        end
        if d.class=="base" then
          d.class=nil
          c=c+1
        end
      end
    end
    if trace_cleanup then
      if n>0 then
        report_cleanup("%s bogus names removed (verbose unicode)",n)
      end
      if c>0 then
        report_cleanup("%s base class tags removed (default is base)",c)
      end
    end
  end
end
readers.stripredundant=stripredundant
function readers.getcomponents(fontdata) 
  local resources=fontdata.resources
  if resources then
    local sequences=resources.sequences
    if sequences then
      local collected={}
      for i=1,#sequences do
        local sequence=sequences[i]
        if sequence.type=="gsub_ligature" then
          local steps=sequence.steps
          if steps then
            local l={}
            local function traverse(p,k,v)
              if k=="ligature" then
                collected[v]={ unpack(l) }
              else
                insert(l,k)
                for k,vv in next,v do
                  traverse(p,k,vv)
                end
                remove(l)
              end
            end
            for i=1,#steps do
              local c=steps[i].coverage
              if c then
                for k,v in next,c do
                  traverse(k,k,v)
                end
              end
            end
          end
        end
      end
      if next(collected) then
        while true do
          local done=false
          for k,v in next,collected do
            for i=1,#v do
              local vi=v[i]
              if vi==k then
                collected[k]=nil
                break
              else
                local c=collected[vi]
                if c then
                  done=true
                  local t={}
                  local n=i-1
                  for j=1,n do
                    t[j]=v[j]
                  end
                  for j=1,#c do
                    n=n+1
                    t[n]=c[j]
                  end
                  for j=i+1,#v do
                    n=n+1
                    t[n]=v[j]
                  end
                  collected[k]=t
                  break
                end
              end
            end
          end
          if not done then
            break
          end
        end
        return collected
      end
    end
  end
end
readers.unifymissing=unifymissing
function readers.rehash(fontdata,hashmethod) 
  if not (fontdata and fontdata.glyphs) then
    return
  end
  if hashmethod=="indices" then
    fontdata.hashmethod="indices"
  elseif hashmethod=="names" then
    fontdata.hashmethod="names"
    local indices=unifyglyphs(fontdata,true)
    unifyresources(fontdata,indices)
    copyduplicates(fontdata)
    unifymissing(fontdata)
  else
    fontdata.hashmethod="unicodes"
    local indices=unifyglyphs(fontdata)
    unifyresources(fontdata,indices)
    copyduplicates(fontdata)
    unifymissing(fontdata)
    stripredundant(fontdata)
  end
end
function readers.checkhash(fontdata)
  local hashmethod=fontdata.hashmethod
  if hashmethod=="unicodes" then
    fontdata.names=nil 
  elseif hashmethod=="names" and fontdata.names then
    unifyresources(fontdata,fontdata.names)
    copyduplicates(fontdata)
    fontdata.hashmethod="unicodes"
    fontdata.names=nil 
  else
    readers.rehash(fontdata,"unicodes")
  end
end
function readers.addunicodetable(fontdata)
  local resources=fontdata.resources
  local unicodes=resources.unicodes
  if not unicodes then
    local descriptions=fontdata.descriptions
    if descriptions then
      unicodes={}
      resources.unicodes=unicodes
      for u,d in next,descriptions do
        local n=d.name
        if n then
          unicodes[n]=u
        end
      end
    end
  end
end
local concat,sort=table.concat,table.sort
local next,type,tostring=next,type,tostring
local criterium=1
local threshold=0
local trace_packing=false trackers.register("otf.packing",function(v) trace_packing=v end)
local trace_loading=false trackers.register("otf.loading",function(v) trace_loading=v end)
local report_otf=logs.reporter("fonts","otf loading")
local function tabstr_normal(t)
  local s={}
  local n=0
  for k,v in next,t do
    n=n+1
    if type(v)=="table" then
      s[n]=k..">"..tabstr_normal(v)
    elseif v==true then
      s[n]=k.."+" 
    elseif v then
      s[n]=k.."="..v
    else
      s[n]=k.."-" 
    end
  end
  if n==0 then
    return ""
  elseif n==1 then
    return s[1]
  else
    sort(s) 
    return concat(s,",")
  end
end
local function tabstr_flat(t)
  local s={}
  local n=0
  for k,v in next,t do
    n=n+1
    s[n]=k.."="..v
  end
  if n==0 then
    return ""
  elseif n==1 then
    return s[1]
  else
    sort(s) 
    return concat(s,",")
  end
end
local function tabstr_mixed(t) 
  local s={}
  local n=#t
  if n==0 then
    return ""
  elseif n==1 then
    local k=t[1]
    if k==true then
      return "++" 
    elseif k==false then
      return "--" 
    else
      return tostring(k) 
    end
  else
    for i=1,n do
      local k=t[i]
      if k==true then
        s[i]="++" 
      elseif k==false then
        s[i]="--" 
      else
        s[i]=k 
      end
    end
    return concat(s,",")
  end
end
local function tabstr_boolean(t)
  local s={}
  local n=0
  for k,v in next,t do
    n=n+1
    if v then
      s[n]=k.."+"
    else
      s[n]=k.."-"
    end
  end
  if n==0 then
    return ""
  elseif n==1 then
    return s[1]
  else
    sort(s) 
    return concat(s,",")
  end
end
function readers.pack(data)
  if data then
    local h,t,c={},{},{}
    local hh,tt,cc={},{},{}
    local nt,ntt=0,0
    local function pack_normal(v)
      local tag=tabstr_normal(v)
      local ht=h[tag]
      if ht then
        c[ht]=c[ht]+1
        return ht
      else
        nt=nt+1
        t[nt]=v
        h[tag]=nt
        c[nt]=1
        return nt
      end
    end
    local function pack_normal_cc(v)
      local tag=tabstr_normal(v)
      local ht=h[tag]
      if ht then
        c[ht]=c[ht]+1
        return ht
      else
        v[1]=0
        nt=nt+1
        t[nt]=v
        h[tag]=nt
        c[nt]=1
        return nt
      end
    end
    local function pack_flat(v)
      local tag=tabstr_flat(v)
      local ht=h[tag]
      if ht then
        c[ht]=c[ht]+1
        return ht
      else
        nt=nt+1
        t[nt]=v
        h[tag]=nt
        c[nt]=1
        return nt
      end
    end
    local function pack_indexed(v)
      local tag=concat(v," ")
      local ht=h[tag]
      if ht then
        c[ht]=c[ht]+1
        return ht
      else
        nt=nt+1
        t[nt]=v
        h[tag]=nt
        c[nt]=1
        return nt
      end
    end
    local function pack_mixed(v)
      local tag=tabstr_mixed(v)
      local ht=h[tag]
      if ht then
        c[ht]=c[ht]+1
        return ht
      else
        nt=nt+1
        t[nt]=v
        h[tag]=nt
        c[nt]=1
        return nt
      end
    end
    local function pack_boolean(v)
      local tag=tabstr_boolean(v)
      local ht=h[tag]
      if ht then
        c[ht]=c[ht]+1
        return ht
      else
        nt=nt+1
        t[nt]=v
        h[tag]=nt
        c[nt]=1
        return nt
      end
    end
    local function pack_final(v)
      if c[v]<=criterium then
        return t[v]
      else
        local hv=hh[v]
        if hv then
          return hv
        else
          ntt=ntt+1
          tt[ntt]=t[v]
          hh[v]=ntt
          cc[ntt]=c[v]
          return ntt
        end
      end
    end
    local function pack_final_cc(v)
      if c[v]<=criterium then
        return t[v]
      else
        local hv=hh[v]
        if hv then
          return hv
        else
          ntt=ntt+1
          tt[ntt]=t[v]
          hh[v]=ntt
          cc[ntt]=c[v]
          return ntt
        end
      end
    end
    local function success(stage,pass)
      if nt==0 then
        if trace_loading or trace_packing then
          report_otf("pack quality: nothing to pack")
        end
        return false
      elseif nt>=threshold then
        local one,two,rest=0,0,0
        if pass==1 then
          for k,v in next,c do
            if v==1 then
              one=one+1
            elseif v==2 then
              two=two+1
            else
              rest=rest+1
            end
          end
        else
          for k,v in next,cc do
            if v>20 then
              rest=rest+1
            elseif v>10 then
              two=two+1
            else
              one=one+1
            end
          end
          data.tables=tt
        end
        if trace_loading or trace_packing then
          report_otf("pack quality: stage %s, pass %s, %s packed, 1-10:%s, 11-20:%s, rest:%s (criterium: %s)",
            stage,pass,one+two+rest,one,two,rest,criterium)
        end
        return true
      else
        if trace_loading or trace_packing then
          report_otf("pack quality: stage %s, pass %s, %s packed, aborting pack (threshold: %s)",
            stage,pass,nt,threshold)
        end
        return false
      end
    end
    local function packers(pass)
      if pass==1 then
        return pack_normal,pack_indexed,pack_flat,pack_boolean,pack_mixed,pack_normal_cc
      else
        return pack_final,pack_final,pack_final,pack_final,pack_final,pack_final_cc
      end
    end
    local resources=data.resources
    local sequences=resources.sequences
    local sublookups=resources.sublookups
    local features=resources.features
    local palettes=resources.colorpalettes
    local variable=resources.variabledata
    local chardata=characters and characters.data
    local descriptions=data.descriptions or data.glyphs
    if not descriptions then
      return
    end
    for pass=1,2 do
      if trace_packing then
        report_otf("start packing: stage 1, pass %s",pass)
      end
      local pack_normal,pack_indexed,pack_flat,pack_boolean,pack_mixed,pack_normal_cc=packers(pass)
      for unicode,description in next,descriptions do
        local boundingbox=description.boundingbox
        if boundingbox then
          description.boundingbox=pack_indexed(boundingbox)
        end
        local math=description.math
        if math then
          local kerns=math.kerns
          if kerns then
            for tag,kern in next,kerns do
              kerns[tag]=pack_normal(kern)
            end
          end
        end
      end
      local function packthem(sequences)
        for i=1,#sequences do
          local sequence=sequences[i]
          local kind=sequence.type
          local steps=sequence.steps
          local order=sequence.order
          local features=sequence.features
          local flags=sequence.flags
          if steps then
            for i=1,#steps do
              local step=steps[i]
              if kind=="gpos_pair" then
                local c=step.coverage
                if c then
                  if step.format=="pair" then
                    for g1,d1 in next,c do
                      for g2,d2 in next,d1 do
                        local f=d2[1] if f and f~=true then d2[1]=pack_indexed(f) end
                        local s=d2[2] if s and s~=true then d2[2]=pack_indexed(s) end
                      end
                    end
                  else
                    for g1,d1 in next,c do
                      c[g1]=pack_normal(d1)
                    end
                  end
                end
              elseif kind=="gpos_single" then
                local c=step.coverage
                if c then
                  if step.format=="single" then
                    for g1,d1 in next,c do
                      if d1 and d1~=true then
                        c[g1]=pack_indexed(d1)
                      end
                    end
                  else
                    step.coverage=pack_normal(c)
                  end
                end
              elseif kind=="gpos_cursive" then
                local c=step.coverage
                if c then
                  for g1,d1 in next,c do
                    local f=d1[2] if f then d1[2]=pack_indexed(f) end
                    local s=d1[3] if s then d1[3]=pack_indexed(s) end
                  end
                end
              elseif kind=="gpos_mark2base" or kind=="gpos_mark2mark" then
                local c=step.baseclasses
                if c then
                  for g1,d1 in next,c do
                    for g2,d2 in next,d1 do
                      d1[g2]=pack_indexed(d2)
                    end
                  end
                end
                local c=step.coverage
                if c then
                  for g1,d1 in next,c do
                    d1[2]=pack_indexed(d1[2])
                  end
                end
              elseif kind=="gpos_mark2ligature" then
                local c=step.baseclasses
                if c then
                  for g1,d1 in next,c do
                    for g2,d2 in next,d1 do
                      for g3,d3 in next,d2 do
                        d2[g3]=pack_indexed(d3)
                      end
                    end
                  end
                end
                local c=step.coverage
                if c then
                  for g1,d1 in next,c do
                    d1[2]=pack_indexed(d1[2])
                  end
                end
              end
              local rules=step.rules
              if rules then
                for i=1,#rules do
                  local rule=rules[i]
                  local r=rule.before    if r then for i=1,#r do r[i]=pack_boolean(r[i]) end end
                  local r=rule.after    if r then for i=1,#r do r[i]=pack_boolean(r[i]) end end
                  local r=rule.current   if r then for i=1,#r do r[i]=pack_boolean(r[i]) end end
                  local r=rule.replacements if r then rule.replacements=pack_flat  (r)  end
                end
              end
            end
          end
          if order then
            sequence.order=pack_indexed(order)
          end
          if features then
            for script,feature in next,features do
              features[script]=pack_normal(feature)
            end
          end
          if flags then
            sequence.flags=pack_normal(flags)
          end
        end
      end
      if sequences then
        packthem(sequences)
      end
      if sublookups then
        packthem(sublookups)
      end
      if features then
        for k,list in next,features do
          for feature,spec in next,list do
            list[feature]=pack_normal(spec)
          end
        end
      end
      if palettes then
        for i=1,#palettes do
          local p=palettes[i]
          for j=1,#p do
            p[j]=pack_indexed(p[j])
          end
        end
      end
      if variable then
        local instances=variable.instances
        if instances then
          for i=1,#instances do
            local v=instances[i].values
            for j=1,#v do
              v[j]=pack_normal(v[j])
            end
          end
        end
        local function packdeltas(main)
          if main then
            local deltas=main.deltas
            if deltas then
              for i=1,#deltas do
                local di=deltas[i]
                local d=di.deltas
                for j=1,#d do
                  d[j]=pack_indexed(d[j])
                end
                di.regions=pack_indexed(di.regions)
              end
            end
            local regions=main.regions
            if regions then
              for i=1,#regions do
                local r=regions[i]
                for j=1,#r do
                  r[j]=pack_normal(r[j])
                end
              end
            end
          end
        end
        packdeltas(variable.global)
        packdeltas(variable.horizontal)
        packdeltas(variable.vertical)
        packdeltas(variable.metrics)
      end
      if not success(1,pass) then
        return
      end
    end
    if nt>0 then
      for pass=1,2 do
        if trace_packing then
          report_otf("start packing: stage 2, pass %s",pass)
        end
        local pack_normal,pack_indexed,pack_flat,pack_boolean,pack_mixed,pack_normal_cc=packers(pass)
        for unicode,description in next,descriptions do
          local math=description.math
          if math then
            local kerns=math.kerns
            if kerns then
              math.kerns=pack_normal(kerns)
            end
          end
        end
        local function packthem(sequences)
          for i=1,#sequences do
            local sequence=sequences[i]
            local kind=sequence.type
            local steps=sequence.steps
            local features=sequence.features
            if steps then
              for i=1,#steps do
                local step=steps[i]
                if kind=="gpos_pair" then
                  local c=step.coverage
                  if c then
                    if step.format=="pair" then
                      for g1,d1 in next,c do
                        for g2,d2 in next,d1 do
                          d1[g2]=pack_normal(d2)
                        end
                      end
                    end
                  end
                elseif kind=="gpos_mark2ligature" then
                  local c=step.baseclasses 
                  if c then
                    for g1,d1 in next,c do
                      for g2,d2 in next,d1 do
                        d1[g2]=pack_normal(d2)
                      end
                    end
                  end
                end
                local rules=step.rules
                if rules then
                  for i=1,#rules do
                    local rule=rules[i]
                    local r=rule.before if r then rule.before=pack_normal(r) end
                    local r=rule.after  if r then rule.after=pack_normal(r) end
                    local r=rule.current if r then rule.current=pack_normal(r) end
                  end
                end
              end
            end
            if features then
              sequence.features=pack_normal(features)
            end
          end
        end
        if sequences then
          packthem(sequences)
        end
        if sublookups then
          packthem(sublookups)
        end
        if variable then
          local function unpackdeltas(main)
            if main then
              local regions=main.regions
              if regions then
                main.regions=pack_normal(regions)
              end
            end
          end
          unpackdeltas(variable.global)
          unpackdeltas(variable.horizontal)
          unpackdeltas(variable.vertical)
          unpackdeltas(variable.metrics)
        end
      end
      for pass=1,2 do
        if trace_packing then
          report_otf("start packing: stage 3, pass %s",pass)
        end
        local pack_normal,pack_indexed,pack_flat,pack_boolean,pack_mixed,pack_normal_cc=packers(pass)
        local function packthem(sequences)
          for i=1,#sequences do
            local sequence=sequences[i]
            local kind=sequence.type
            local steps=sequence.steps
            local features=sequence.features
            if steps then
              for i=1,#steps do
                local step=steps[i]
                if kind=="gpos_pair" then
                  local c=step.coverage
                  if c then
                    if step.format=="pair" then
                      for g1,d1 in next,c do
                        c[g1]=pack_normal(d1)
                      end
                    end
                  end
                elseif kind=="gpos_cursive" then
                  local c=step.coverage
                  if c then
                    for g1,d1 in next,c do
                      c[g1]=pack_normal_cc(d1)
                    end
                  end
                end
              end
            end
          end
        end
        if sequences then
          packthem(sequences)
        end
        if sublookups then
          packthem(sublookups)
        end
      end
    end
  end
end
local unpacked_mt={
  __index=function(t,k)
      t[k]=false
      return k 
    end
}
function readers.unpack(data)
  if data then
    local tables=data.tables
    if tables then
      local resources=data.resources
      local descriptions=data.descriptions or data.glyphs
      local sequences=resources.sequences
      local sublookups=resources.sublookups
      local features=resources.features
      local palettes=resources.colorpalettes
      local variable=resources.variabledata
      local unpacked={}
      setmetatable(unpacked,unpacked_mt)
      for unicode,description in next,descriptions do
        local tv=tables[description.boundingbox]
        if tv then
          description.boundingbox=tv
        end
        local math=description.math
        if math then
          local kerns=math.kerns
          if kerns then
            local tm=tables[kerns]
            if tm then
              math.kerns=tm
              kerns=unpacked[tm]
            end
            if kerns then
              for k,kern in next,kerns do
                local tv=tables[kern]
                if tv then
                  kerns[k]=tv
                end
              end
            end
          end
        end
      end
      local function unpackthem(sequences)
        for i=1,#sequences do
          local sequence=sequences[i]
          local kind=sequence.type
          local steps=sequence.steps
          local order=sequence.order
          local features=sequence.features
          local flags=sequence.flags
          local markclass=sequence.markclass
          if features then
            local tv=tables[features]
            if tv then
              sequence.features=tv
              features=tv
            end
            for script,feature in next,features do
              local tv=tables[feature]
              if tv then
                features[script]=tv
              end
            end
          end
          if steps then
            for i=1,#steps do
              local step=steps[i]
              if kind=="gpos_pair" then
                local c=step.coverage
                if c then
                  if step.format=="pair" then
                    for g1,d1 in next,c do
                      local tv=tables[d1]
                      if tv then
                        c[g1]=tv
                        d1=tv
                      end
                      for g2,d2 in next,d1 do
                        local tv=tables[d2]
                        if tv then
                          d1[g2]=tv
                          d2=tv
                        end
                        local f=tables[d2[1]] if f then d2[1]=f end
                        local s=tables[d2[2]] if s then d2[2]=s end
                      end
                    end
                  else
                    for g1,d1 in next,c do
                      local tv=tables[d1]
                      if tv then
                        c[g1]=tv
                      end
                    end
                  end
                end
              elseif kind=="gpos_single" then
                local c=step.coverage
                if c then
                  if step.format=="single" then
                    for g1,d1 in next,c do
                      local tv=tables[d1]
                      if tv then
                        c[g1]=tv
                      end
                    end
                  else
                    local tv=tables[c]
                    if tv then
                      step.coverage=tv
                    end
                  end
                end
              elseif kind=="gpos_cursive" then
                local c=step.coverage
                if c then
                  for g1,d1 in next,c do
                    local tv=tables[d1]
                    if tv then
                      d1=tv
                      c[g1]=d1
                    end
                    local f=tables[d1[2]] if f then d1[2]=f end
                    local s=tables[d1[3]] if s then d1[3]=s end
                  end
                end
              elseif kind=="gpos_mark2base" or kind=="gpos_mark2mark" then
                local c=step.baseclasses
                if c then
                  for g1,d1 in next,c do
                    for g2,d2 in next,d1 do
                      local tv=tables[d2]
                      if tv then
                        d1[g2]=tv
                      end
                    end
                  end
                end
                local c=step.coverage
                if c then
                  for g1,d1 in next,c do
                    local tv=tables[d1[2]]
                    if tv then
                      d1[2]=tv
                    end
                  end
                end
              elseif kind=="gpos_mark2ligature" then
                local c=step.baseclasses
                if c then
                  for g1,d1 in next,c do
                    for g2,d2 in next,d1 do
                      local tv=tables[d2] 
                      if tv then
                        d2=tv
                        d1[g2]=d2
                      end
                      for g3,d3 in next,d2 do
                        local tv=tables[d2[g3]]
                        if tv then
                          d2[g3]=tv
                        end
                      end
                    end
                  end
                end
                local c=step.coverage
                if c then
                  for g1,d1 in next,c do
                    local tv=tables[d1[2]]
                    if tv then
                      d1[2]=tv
                    end
                  end
                end
              end
              local rules=step.rules
              if rules then
                for i=1,#rules do
                  local rule=rules[i]
                  local before=rule.before
                  if before then
                    local tv=tables[before]
                    if tv then
                      rule.before=tv
                      before=tv
                    end
                    for i=1,#before do
                      local tv=tables[before[i]]
                      if tv then
                        before[i]=tv
                      end
                    end
                  end
                  local after=rule.after
                  if after then
                    local tv=tables[after]
                    if tv then
                      rule.after=tv
                      after=tv
                    end
                    for i=1,#after do
                      local tv=tables[after[i]]
                      if tv then
                        after[i]=tv
                      end
                    end
                  end
                  local current=rule.current
                  if current then
                    local tv=tables[current]
                    if tv then
                      rule.current=tv
                      current=tv
                    end
                    for i=1,#current do
                      local tv=tables[current[i]]
                      if tv then
                        current[i]=tv
                      end
                    end
                  end
                  local replacements=rule.replacements
                  if replacements then
                    local tv=tables[replacements]
                    if tv then
                      rule.replacements=tv
                    end
                  end
                end
              end
            end
          end
          if order then
            local tv=tables[order]
            if tv then
              sequence.order=tv
            end
          end
          if flags then
            local tv=tables[flags]
            if tv then
              sequence.flags=tv
            end
          end
        end
      end
      if sequences then
        unpackthem(sequences)
      end
      if sublookups then
        unpackthem(sublookups)
      end
      if features then
        for k,list in next,features do
          for feature,spec in next,list do
            local tv=tables[spec]
            if tv then
              list[feature]=tv
            end
          end
        end
      end
      if palettes then
        for i=1,#palettes do
          local p=palettes[i]
          for j=1,#p do
            local tv=tables[p[j]]
            if tv then
              p[j]=tv
            end
          end
        end
      end
      if variable then
        local instances=variable.instances
        if instances then
          for i=1,#instances do
            local v=instances[i].values
            for j=1,#v do
              local tv=tables[v[j]]
              if tv then
                v[j]=tv
              end
            end
          end
        end
        local function unpackdeltas(main)
          if main then
            local deltas=main.deltas
            if deltas then
              for i=1,#deltas do
                local di=deltas[i]
                local d=di.deltas
                local r=di.regions
                for j=1,#d do
                  local tv=tables[d[j]]
                  if tv then
                    d[j]=tv
                  end
                end
                local tv=di.regions
                if tv then
                  di.regions=tv
                end
              end
            end
            local regions=main.regions
            if regions then
              local tv=tables[regions]
              if tv then
                main.regions=tv
                regions=tv
              end
              for i=1,#regions do
                local r=regions[i]
                for j=1,#r do
                  local tv=tables[r[j]]
                  if tv then
                    r[j]=tv
                  end
                end
              end
            end
          end
        end
        unpackdeltas(variable.global)
        unpackdeltas(variable.horizontal)
        unpackdeltas(variable.vertical)
        unpackdeltas(variable.metrics)
      end
      data.tables=nil
    end
  end
end
local mt={
  __index=function(t,k) 
    if k=="height" then
      local ht=t.boundingbox[4]
      return ht<0 and 0 or ht
    elseif k=="depth" then
      local dp=-t.boundingbox[2]
      return dp<0 and 0 or dp
    elseif k=="width" then
      return 0
    elseif k=="name" then 
      return forcenotdef and ".notdef"
    end
  end
}
local function sameformat(sequence,steps,first,nofsteps,kind)
  return true
end
local function mergesteps_1(lookup,strict)
  local steps=lookup.steps
  local nofsteps=lookup.nofsteps
  local first=steps[1]
  if strict then
    local f=first.format
    for i=2,nofsteps do
      if steps[i].format~=f then
        if trace_optimizations then
          report_optimizations("not merging %a steps of %a lookup %a, different formats",nofsteps,lookup.type,lookup.name)
        end
        return 0
      end
    end
  end
  if trace_optimizations then
    report_optimizations("merging %a steps of %a lookup %a",nofsteps,lookup.type,lookup.name)
  end
  local target=first.coverage
  for i=2,nofsteps do
    local c=steps[i].coverage
    if c then
      for k,v in next,c do
        if not target[k] then
          target[k]=v
        end
      end
    end
  end
  lookup.nofsteps=1
  lookup.merged=true
  lookup.steps={ first }
  return nofsteps-1
end
local function mergesteps_2(lookup)
  local steps=lookup.steps
  local nofsteps=lookup.nofsteps
  local first=steps[1]
  if strict then
    local f=first.format
    for i=2,nofsteps do
      if steps[i].format~=f then
        if trace_optimizations then
          report_optimizations("not merging %a steps of %a lookup %a, different formats",nofsteps,lookup.type,lookup.name)
        end
        return 0
      end
    end
  end
  if trace_optimizations then
    report_optimizations("merging %a steps of %a lookup %a",nofsteps,lookup.type,lookup.name)
  end
  local target=first.coverage
  for i=2,nofsteps do
    local c=steps[i].coverage
    if c then
      for k,v in next,c do
        local tk=target[k]
        if tk then
          for kk,vv in next,v do
            if tk[kk]==nil then
              tk[kk]=vv
            end
          end
        else
          target[k]=v
        end
      end
    end
  end
  lookup.nofsteps=1
  lookup.merged=true
  lookup.steps={ first }
  return nofsteps-1
end
local function mergesteps_3(lookup,strict) 
  local steps=lookup.steps
  local nofsteps=lookup.nofsteps
  if trace_optimizations then
    report_optimizations("merging %a steps of %a lookup %a",nofsteps,lookup.type,lookup.name)
  end
  local coverage={}
  for i=1,nofsteps do
    local c=steps[i].coverage
    if c then
      for k,v in next,c do
        local tk=coverage[k] 
        if tk then
          if trace_optimizations then
            report_optimizations("quitting merge due to multiple checks")
          end
          return nofsteps
        else
          coverage[k]=v
        end
      end
    end
  end
  local first=steps[1]
  local baseclasses={} 
  for i=1,nofsteps do
    local offset=i*10 
    local step=steps[i]
    for k,v in sortedhash(step.baseclasses) do
      baseclasses[offset+k]=v
    end
    for k,v in next,step.coverage do
      v[1]=offset+v[1]
    end
  end
  first.baseclasses=baseclasses
  first.coverage=coverage
  lookup.nofsteps=1
  lookup.merged=true
  lookup.steps={ first }
  return nofsteps-1
end
local function nested(old,new)
  for k,v in next,old do
    if k=="ligature" then
      if not new.ligature then
        new.ligature=v
      end
    else
      local n=new[k]
      if n then
        nested(v,n)
      else
        new[k]=v
      end
    end
  end
end
local function mergesteps_4(lookup) 
  local steps=lookup.steps
  local nofsteps=lookup.nofsteps
  local first=steps[1]
  if trace_optimizations then
    report_optimizations("merging %a steps of %a lookup %a",nofsteps,lookup.type,lookup.name)
  end
  local target=first.coverage
  for i=2,nofsteps do
    local c=steps[i].coverage
    if c then
      for k,v in next,c do
        local tk=target[k]
        if tk then
          nested(v,tk)
        else
          target[k]=v
        end
      end
    end
  end
  lookup.nofsteps=1
  lookup.steps={ first }
  return nofsteps-1
end
local function mergesteps_5(lookup) 
  local steps=lookup.steps
  local nofsteps=lookup.nofsteps
  local first=steps[1]
  if trace_optimizations then
    report_optimizations("merging %a steps of %a lookup %a",nofsteps,lookup.type,lookup.name)
  end
  local target=first.coverage
  local hash=nil
  for k,v in next,target do
    hash=v[1]
    break
  end
  for i=2,nofsteps do
    local c=steps[i].coverage
    if c then
      for k,v in next,c do
        local tk=target[k]
        if tk then
          if not tk[2] then
            tk[2]=v[2]
          end
          if not tk[3] then
            tk[3]=v[3]
          end
        else
          target[k]=v
          v[1]=hash
        end
      end
    end
  end
  lookup.nofsteps=1
  lookup.merged=true
  lookup.steps={ first }
  return nofsteps-1
end
local function checkkerns(lookup)
  local steps=lookup.steps
  local nofsteps=lookup.nofsteps
  local kerned=0
  for i=1,nofsteps do
    local step=steps[i]
    if step.format=="pair" then
      local coverage=step.coverage
      local kerns=true
      for g1,d1 in next,coverage do
        if d1==true then
        elseif not d1 then
        elseif d1[1]~=0 or d1[2]~=0 or d1[4]~=0 then
          kerns=false
          break
        end
      end
      if kerns then
        if trace_optimizations then
          report_optimizations("turning pairs of step %a of %a lookup %a into kerns",i,lookup.type,lookup.name)
        end
        local c={}
        for g1,d1 in next,coverage do
          if d1 and d1~=true then
            c[g1]=d1[3]
          end
        end
        step.coverage=c
        step.format="move"
        kerned=kerned+1
      end
    end
  end
  return kerned
end
local function checkpairs(lookup)
  local steps=lookup.steps
  local nofsteps=lookup.nofsteps
  local kerned=0
  local function onlykerns(step)
    local coverage=step.coverage
    for g1,d1 in next,coverage do
      for g2,d2 in next,d1 do
        if d2[2] then
          return false
        else
          local v=d2[1]
          if v==true then
          elseif v and (v[1]~=0 or v[2]~=0 or v[4]~=0) then
            return false
          end
        end
      end
    end
    return coverage
  end
  for i=1,nofsteps do
    local step=steps[i]
    if step.format=="pair" then
      local coverage=onlykerns(step)
      if coverage then
        if trace_optimizations then
          report_optimizations("turning pairs of step %a of %a lookup %a into kerns",i,lookup.type,lookup.name)
        end
        for g1,d1 in next,coverage do
          local d={}
          for g2,d2 in next,d1 do
            local v=d2[1]
            if v==true then
            elseif v then
              d[g2]=v[3] 
            end
          end
          coverage[g1]=d
        end
        step.format="move"
        kerned=kerned+1
      end
    end
  end
  return kerned
end
local compact_pairs=true
local compact_singles=true
local merge_pairs=true
local merge_singles=true
local merge_substitutions=true
local merge_alternates=true
local merge_multiples=true
local merge_ligatures=true
local merge_cursives=true
local merge_marks=true
directives.register("otf.compact.pairs",function(v) compact_pairs=v end)
directives.register("otf.compact.singles",function(v) compact_singles=v end)
directives.register("otf.merge.pairs",function(v) merge_pairs=v end)
directives.register("otf.merge.singles",function(v) merge_singles=v end)
directives.register("otf.merge.substitutions",function(v) merge_substitutions=v end)
directives.register("otf.merge.alternates",function(v) merge_alternates=v end)
directives.register("otf.merge.multiples",function(v) merge_multiples=v end)
directives.register("otf.merge.ligatures",function(v) merge_ligatures=v end)
directives.register("otf.merge.cursives",function(v) merge_cursives=v end)
directives.register("otf.merge.marks",function(v) merge_marks=v end)
function readers.compact(data)
  if not data or data.compacted then
    return
  else
    data.compacted=true
  end
  local resources=data.resources
  local merged=0
  local kerned=0
  local allsteps=0
  local function compact(what)
    local lookups=resources[what]
    if lookups then
      for i=1,#lookups do
        local lookup=lookups[i]
        local nofsteps=lookup.nofsteps
        local kind=lookup.type
        allsteps=allsteps+nofsteps
        if nofsteps>1 then
          local merg=merged
          if kind=="gsub_single" then
            if merge_substitutions then
              merged=merged+mergesteps_1(lookup)
            end
          elseif kind=="gsub_alternate" then
            if merge_alternates then
              merged=merged+mergesteps_1(lookup)
            end
          elseif kind=="gsub_multiple" then
            if merge_multiples then
              merged=merged+mergesteps_1(lookup)
            end
          elseif kind=="gsub_ligature" then
            if merge_ligatures then
              merged=merged+mergesteps_4(lookup)
            end
          elseif kind=="gpos_single" then
            if merge_singles then
              merged=merged+mergesteps_1(lookup,true)
            end
            if compact_singles then
              kerned=kerned+checkkerns(lookup)
            end
          elseif kind=="gpos_pair" then
            if merge_pairs then
              merged=merged+mergesteps_2(lookup)
            end
            if compact_pairs then
              kerned=kerned+checkpairs(lookup)
            end
          elseif kind=="gpos_cursive" then
            if merge_cursives then
              merged=merged+mergesteps_5(lookup)
            end
          elseif kind=="gpos_mark2mark" or kind=="gpos_mark2base" or kind=="gpos_mark2ligature" then
            if merge_marks then
              merged=merged+mergesteps_3(lookup)
            end
          end
          if merg~=merged then
            lookup.merged=true
          end
        elseif nofsteps==1 then
          local kern=kerned
          if kind=="gpos_single" then
            if compact_singles then
              kerned=kerned+checkkerns(lookup)
            end
          elseif kind=="gpos_pair" then
            if compact_pairs then
              kerned=kerned+checkpairs(lookup)
            end
          end
          if kern~=kerned then
          end
        end
      end
    elseif trace_optimizations then
      report_optimizations("no lookups in %a",what)
    end
  end
  compact("sequences")
  compact("sublookups")
  if trace_optimizations then
    if merged>0 then
      report_optimizations("%i steps of %i removed due to merging",merged,allsteps)
    end
    if kerned>0 then
      report_optimizations("%i steps of %i steps turned from pairs into kerns",kerned,allsteps)
    end
  end
end
local function mergesteps(t,k)
  if k=="merged" then
    local merged={}
    for i=1,#t do
      local step=t[i]
      local coverage=step.coverage
      for k in next,coverage do
        local m=merged[k]
        if m then
          m[2]=i
        else
          merged[k]={ i,i }
        end
      end
    end
    t.merged=merged
    return merged
  end
end
local function checkmerge(sequence)
  local steps=sequence.steps
  if steps then
    setmetatableindex(steps,mergesteps)
  end
end
local function checkflags(sequence,resources)
  if not sequence.skiphash then
    local flags=sequence.flags
    if flags then
      local skipmark=flags[1]
      local skipligature=flags[2]
      local skipbase=flags[3]
      local markclass=sequence.markclass
      local skipsome=skipmark or skipligature or skipbase or markclass or false
      if skipsome then
        sequence.skiphash=setmetatableindex(function(t,k)
          local c=resources.classes[k] 
          local v=c==skipmark
              or (markclass and c=="mark" and not markclass[k])
              or c==skipligature
              or c==skipbase
              or false
          t[k]=v
          return v
        end)
      else
        sequence.skiphash=false
      end
    else
      sequence.skiphash=false
    end
  end
end
local function checksteps(sequence)
  local steps=sequence.steps
  if steps then
    for i=1,#steps do
      steps[i].index=i
    end
  end
end
if fonts.helpers then
  fonts.helpers.checkmerge=checkmerge
  fonts.helpers.checkflags=checkflags
  fonts.helpers.checksteps=checksteps 
end
function readers.expand(data)
  if not data or data.expanded then
    return
  else
    data.expanded=true
  end
  local resources=data.resources
  local sublookups=resources.sublookups
  local sequences=resources.sequences 
  local markclasses=resources.markclasses
  local descriptions=data.descriptions
  if descriptions then
    local defaultwidth=resources.defaultwidth or 0
    local defaultheight=resources.defaultheight or 0
    local defaultdepth=resources.defaultdepth or 0
    local basename=trace_markwidth and file.basename(resources.filename)
    for u,d in next,descriptions do
      local bb=d.boundingbox
      local wd=d.width
      if not wd then
        d.width=defaultwidth
      elseif trace_markwidth and wd~=0 and d.class=="mark" then
        report_markwidth("mark %a with width %b found in %a",d.name or "<noname>",wd,basename)
      end
      if bb then
        local ht=bb[4]
        local dp=-bb[2]
        if ht==0 or ht<0 then
        else
          d.height=ht
        end
        if dp==0 or dp<0 then
        else
          d.depth=dp
        end
      end
    end
  end
  local function expandlookups(sequences)
    if sequences then
      for i=1,#sequences do
        local sequence=sequences[i]
        local steps=sequence.steps
        if steps then
          local nofsteps=sequence.nofsteps
          local kind=sequence.type
          local markclass=sequence.markclass
          if markclass then
            if not markclasses then
              report_warning("missing markclasses")
              sequence.markclass=false
            else
              sequence.markclass=markclasses[markclass]
            end
          end
          for i=1,nofsteps do
            local step=steps[i]
            local baseclasses=step.baseclasses
            if baseclasses then
              local coverage=step.coverage
              for k,v in next,coverage do
                v[1]=baseclasses[v[1]] 
              end
            elseif kind=="gpos_cursive" then
              local coverage=step.coverage
              for k,v in next,coverage do
                v[1]=coverage 
              end
            end
            local rules=step.rules
            if rules then
              local rulehash={ n=0 } 
              local rulesize=0
              local coverage={}
              local lookuptype=sequence.type
              local nofrules=#rules
              step.coverage=coverage 
              for currentrule=1,nofrules do
                local rule=rules[currentrule]
                local current=rule.current
                local before=rule.before
                local after=rule.after
                local replacements=rule.replacements or false
                local sequence={}
                local nofsequences=0
                if before then
                  for n=1,#before do
                    nofsequences=nofsequences+1
                    sequence[nofsequences]=before[n]
                  end
                end
                local start=nofsequences+1
                for n=1,#current do
                  nofsequences=nofsequences+1
                  sequence[nofsequences]=current[n]
                end
                local stop=nofsequences
                if after then
                  for n=1,#after do
                    nofsequences=nofsequences+1
                    sequence[nofsequences]=after[n]
                  end
                end
                local lookups=rule.lookups or false
                local subtype=nil
                if lookups then
                  for i=1,#lookups do
                    local lookups=lookups[i]
                    if lookups then
                      for k,v in next,lookups do 
                        local lookup=sublookups[v]
                        if lookup then
                          lookups[k]=lookup
                          if not subtype then
                            subtype=lookup.type
                          end
                        else
                        end
                      end
                    end
                  end
                end
                if sequence[1] then 
                  sequence.n=#sequence 
                  local ruledata={
                    currentrule,
                    lookuptype,
                    sequence,
                    start,
                    stop,
                    lookups,
                    replacements,
                    subtype,
                  }
                  rulesize=rulesize+1
                  rulehash[rulesize]=ruledata
                  rulehash.n=rulesize
                  if true then 
                    for unic in next,sequence[start] do
                      local cu=coverage[unic]
                      if cu then
                        local n=#cu+1
                        cu[n]=ruledata
                        cu.n=n
                      else
                        coverage[unic]={ ruledata,n=1 }
                      end
                    end
                  else
                    for unic in next,sequence[start] do
                      local cu=coverage[unic]
                      if cu then
                      else
                        coverage[unic]=rulehash
                      end
                    end
                  end
                end
              end
            end
          end
          checkmerge(sequence)
          checkflags(sequence,resources)
          checksteps(sequence)
        end
      end
    end
  end
  expandlookups(sequences)
  expandlookups(sublookups)
end

end --- [luaotfload, fontloader-2018-10-08.lua scope for “font-oup”] ---


do  --- [luaotfload, fontloader-2018-10-08.lua scope for “font-otl” 40cdceeb682bac55b4a69465b76bcc33] ---

if not modules then modules={} end modules ['font-otl']={
  version=1.001,
  comment="companion to font-ini.mkiv",
  author="Hans Hagen, PRAGMA-ADE, Hasselt NL",
  copyright="PRAGMA ADE / ConTeXt Development Team",
  license="see context related readme files",
}
local lower=string.lower
local type,next,tonumber,tostring,unpack=type,next,tonumber,tostring,unpack
local abs=math.abs
local derivetable=table.derive
local formatters=string.formatters
local setmetatableindex=table.setmetatableindex
local allocate=utilities.storage.allocate
local registertracker=trackers.register
local registerdirective=directives.register
local starttiming=statistics.starttiming
local stoptiming=statistics.stoptiming
local elapsedtime=statistics.elapsedtime
local findbinfile=resolvers.findbinfile
local trace_loading=false registertracker("otf.loading",function(v) trace_loading=v end)
local trace_features=false registertracker("otf.features",function(v) trace_features=v end)
local trace_defining=false registertracker("fonts.defining",function(v) trace_defining=v end)
local report_otf=logs.reporter("fonts","otf loading")
local fonts=fonts
local otf=fonts.handlers.otf
otf.version=3.106 
otf.cache=containers.define("fonts","otl",otf.version,true)
otf.svgcache=containers.define("fonts","svg",otf.version,true)
otf.sbixcache=containers.define("fonts","sbix",otf.version,true)
otf.pdfcache=containers.define("fonts","pdf",otf.version,true)
otf.svgenabled=false
otf.sbixenabled=false
local otfreaders=otf.readers
local hashes=fonts.hashes
local definers=fonts.definers
local readers=fonts.readers
local constructors=fonts.constructors
local otffeatures=constructors.features.otf
local registerotffeature=otffeatures.register
local otfenhancers=constructors.enhancers.otf
local registerotfenhancer=otfenhancers.register
local forceload=false
local cleanup=0   
local syncspace=true
local forcenotdef=false
local privateoffset=fonts.constructors and fonts.constructors.privateoffset or 0xF0000 
local applyruntimefixes=fonts.treatments and fonts.treatments.applyfixes
local wildcard="*"
local default="dflt"
local formats=fonts.formats
formats.otf="opentype"
formats.ttf="truetype"
formats.ttc="truetype"
registerdirective("fonts.otf.loader.cleanup",function(v) cleanup=tonumber(v) or (v and 1) or 0 end)
registerdirective("fonts.otf.loader.force",function(v) forceload=v end)
registerdirective("fonts.otf.loader.syncspace",function(v) syncspace=v end)
registerdirective("fonts.otf.loader.forcenotdef",function(v) forcenotdef=v end)
registerotfenhancer("check extra features",function() end)
local checkmemory=utilities.lua and utilities.lua.checkmemory
local threshold=100 
local tracememory=false
registertracker("fonts.otf.loader.memory",function(v) tracememory=v end)
if not checkmemory then 
  local collectgarbage=collectgarbage
  checkmemory=function(previous,threshold) 
    local current=collectgarbage("count")
    if previous then
      local checked=(threshold or 64)*1024
      if current-previous>checked then
        collectgarbage("collect")
        current=collectgarbage("count")
      end
    end
    return current
  end
end
function otf.load(filename,sub,instance)
  local base=file.basename(file.removesuffix(filename))
  local name=file.removesuffix(base) 
  local attr=lfs.attributes(filename)
  local size=attr and attr.size or 0
  local time=attr and attr.modification or 0
  if sub=="" then
    sub=false
  end
  local hash=name
  if sub then
    hash=hash.."-"..sub
  end
  if instance then
    hash=hash.."-"..instance
  end
  hash=containers.cleanname(hash)
  local data=containers.read(otf.cache,hash)
  local reload=not data or data.size~=size or data.time~=time or data.tableversion~=otfreaders.tableversion
  if forceload then
    report_otf("forced reload of %a due to hard coded flag",filename)
    reload=true
  end
   if reload then
    report_otf("loading %a, hash %a",filename,hash)
    starttiming(otfreaders,true)
    data=otfreaders.loadfont(filename,sub or 1,instance) 
    if data then
      local used=checkmemory()
      local resources=data.resources
      local svgshapes=resources.svgshapes
      local sbixshapes=resources.sbixshapes
      if cleanup==0 then
        checkmemory(used,threshold,tracememory)
      end
      if svgshapes then
        resources.svgshapes=nil
        if otf.svgenabled then
          local timestamp=os.date()
          containers.write(otf.svgcache,hash,{
            svgshapes=svgshapes,
            timestamp=timestamp,
          })
          data.properties.svg={
            hash=hash,
            timestamp=timestamp,
          }
        end
        if cleanup>1 then
          collectgarbage("collect")
        else
          checkmemory(used,threshold,tracememory)
        end
      end
      if sbixshapes then
        resources.sbixshapes=nil
        if otf.sbixenabled then
          local timestamp=os.date()
          containers.write(otf.sbixcache,hash,{
            sbixshapes=sbixshapes,
            timestamp=timestamp,
          })
          data.properties.sbix={
            hash=hash,
            timestamp=timestamp,
          }
        end
        if cleanup>1 then
          collectgarbage("collect")
        else
          checkmemory(used,threshold,tracememory)
        end
      end
      otfreaders.compact(data)
      if cleanup==0 then
        checkmemory(used,threshold,tracememory)
      end
      otfreaders.rehash(data,"unicodes")
      otfreaders.addunicodetable(data)
      otfreaders.extend(data)
      if cleanup==0 then
        checkmemory(used,threshold,tracememory)
      end
      otfreaders.pack(data)
      report_otf("loading done")
      report_otf("saving %a in cache",filename)
      data=containers.write(otf.cache,hash,data)
      if cleanup>1 then
        collectgarbage("collect")
      else
        checkmemory(used,threshold,tracememory)
      end
      stoptiming(otfreaders)
      if elapsedtime then
        report_otf("loading, optimizing, packing and caching time %s",elapsedtime(otfreaders))
      end
      if cleanup>3 then
        collectgarbage("collect")
      else
        checkmemory(used,threshold,tracememory)
      end
      data=containers.read(otf.cache,hash) 
      if cleanup>2 then
        collectgarbage("collect")
      else
        checkmemory(used,threshold,tracememory)
      end
    else
      stoptiming(otfreaders)
      data=nil
      report_otf("loading failed due to read error")
    end
  end
  if data then
    if trace_defining then
      report_otf("loading from cache using hash %a",hash)
    end
    otfreaders.unpack(data)
    otfreaders.expand(data) 
    otfreaders.addunicodetable(data)
    otfenhancers.apply(data,filename,data)
    if applyruntimefixes then
      applyruntimefixes(filename,data) 
    end
    data.metadata.math=data.resources.mathconstants
    local classes=data.resources.classes
    if not classes then
      local descriptions=data.descriptions
      classes=setmetatableindex(function(t,k)
        local d=descriptions[k]
        local v=(d and d.class or "base") or false
        t[k]=v
        return v
      end)
      data.resources.classes=classes
    end
  end
  return data
end
function otf.setfeatures(tfmdata,features)
  local okay=constructors.initializefeatures("otf",tfmdata,features,trace_features,report_otf)
  if okay then
    return constructors.collectprocessors("otf",tfmdata,features,trace_features,report_otf)
  else
    return {} 
  end
end
local function copytotfm(data,cache_id)
  if data then
    local metadata=data.metadata
    local properties=derivetable(data.properties)
    local descriptions=derivetable(data.descriptions)
    local goodies=derivetable(data.goodies)
    local characters={}
    local parameters={}
    local mathparameters={}
    local resources=data.resources
    local unicodes=resources.unicodes
    local spaceunits=500
    local spacer="space"
    local designsize=metadata.designsize or 100
    local minsize=metadata.minsize or designsize
    local maxsize=metadata.maxsize or designsize
    local mathspecs=metadata.math
    if designsize==0 then
      designsize=100
      minsize=100
      maxsize=100
    end
    if mathspecs then
      for name,value in next,mathspecs do
        mathparameters[name]=value
      end
    end
    for unicode in next,data.descriptions do 
      characters[unicode]={}
    end
    if mathspecs then
      for unicode,character in next,characters do
        local d=descriptions[unicode] 
        local m=d.math
        if m then
          local italic=m.italic
          local vitalic=m.vitalic
          local variants=m.hvariants
          local parts=m.hparts
          if variants then
            local c=character
            for i=1,#variants do
              local un=variants[i]
              c.next=un
              c=characters[un]
            end 
            c.horiz_variants=parts
          elseif parts then
            character.horiz_variants=parts
            italic=m.hitalic
          end
          local variants=m.vvariants
          local parts=m.vparts
          if variants then
            local c=character
            for i=1,#variants do
              local un=variants[i]
              c.next=un
              c=characters[un]
            end 
            c.vert_variants=parts
          elseif parts then
            character.vert_variants=parts
          end
          if italic and italic~=0 then
            character.italic=italic
          end
          if vitalic and vitalic~=0 then
            character.vert_italic=vitalic
          end
          local accent=m.accent 
          if accent then
            character.accent=accent
          end
          local kerns=m.kerns
          if kerns then
            character.mathkerns=kerns
          end
        end
      end
    end
    local filename=constructors.checkedfilename(resources)
    local fontname=metadata.fontname
    local fullname=metadata.fullname or fontname
    local psname=fontname or fullname
    local subfont=metadata.subfontindex
    local units=metadata.units or 1000
    if units==0 then 
      units=1000 
      metadata.units=1000
      report_otf("changing %a units to %a",0,units)
    end
    local monospaced=metadata.monospaced
    local charwidth=metadata.averagewidth 
    local charxheight=metadata.xheight 
    local italicangle=metadata.italicangle
    local hasitalics=metadata.hasitalics
    properties.monospaced=monospaced
    properties.hasitalics=hasitalics
    parameters.italicangle=italicangle
    parameters.charwidth=charwidth
    parameters.charxheight=charxheight
    local space=0x0020
    local emdash=0x2014
    if monospaced then
      if descriptions[space] then
        spaceunits,spacer=descriptions[space].width,"space"
      end
      if not spaceunits and descriptions[emdash] then
        spaceunits,spacer=descriptions[emdash].width,"emdash"
      end
      if not spaceunits and charwidth then
        spaceunits,spacer=charwidth,"charwidth"
      end
    else
      if descriptions[space] then
        spaceunits,spacer=descriptions[space].width,"space"
      end
      if not spaceunits and descriptions[emdash] then
        spaceunits,spacer=descriptions[emdash].width/2,"emdash/2"
      end
      if not spaceunits and charwidth then
        spaceunits,spacer=charwidth,"charwidth"
      end
    end
    spaceunits=tonumber(spaceunits) or units/2
    parameters.slant=0
    parameters.space=spaceunits      
    parameters.space_stretch=1*units/2  
    parameters.space_shrink=1*units/3  
    parameters.x_height=2*units/5  
    parameters.quad=units    
    if spaceunits<2*units/5 then
    end
    if italicangle and italicangle~=0 then
      parameters.italicangle=italicangle
      parameters.italicfactor=math.cos(math.rad(90+italicangle))
      parameters.slant=- math.tan(italicangle*math.pi/180)
    end
    if monospaced then
      parameters.space_stretch=0
      parameters.space_shrink=0
    elseif syncspace then 
      parameters.space_stretch=spaceunits/2
      parameters.space_shrink=spaceunits/3
    end
    parameters.extra_space=parameters.space_shrink 
    if charxheight then
      parameters.x_height=charxheight
    else
      local x=0x0078
      if x then
        local x=descriptions[x]
        if x then
          parameters.x_height=x.height
        end
      end
    end
    parameters.designsize=(designsize/10)*65536
    parameters.minsize=(minsize/10)*65536
    parameters.maxsize=(maxsize/10)*65536
    parameters.ascender=abs(metadata.ascender or 0)
    parameters.descender=abs(metadata.descender or 0)
    parameters.units=units
    properties.space=spacer
    properties.encodingbytes=2
    properties.format=data.format or formats.otf
    properties.noglyphnames=true
    properties.filename=filename
    properties.fontname=fontname
    properties.fullname=fullname
    properties.psname=psname
    properties.name=filename or fullname
    properties.subfont=subfont
    properties.private=properties.private or data.private or privateoffset
    return {
      characters=characters,
      descriptions=descriptions,
      parameters=parameters,
      mathparameters=mathparameters,
      resources=resources,
      properties=properties,
      goodies=goodies,
    }
  end
end
local converters={
  woff={
    cachename="webfonts",
    action=otf.readers.woff2otf,
  }
}
local function checkconversion(specification)
  local filename=specification.filename
  local converter=converters[lower(file.suffix(filename))]
  if converter then
    local base=file.basename(filename)
    local name=file.removesuffix(base)
    local attr=lfs.attributes(filename)
    local size=attr and attr.size or 0
    local time=attr and attr.modification or 0
    if size>0 then
      local cleanname=containers.cleanname(name)
      local cachename=caches.setfirstwritablefile(cleanname,converter.cachename)
      if not io.exists(cachename) or (time~=lfs.attributes(cachename).modification) then
        report_otf("caching font %a in %a",filename,cachename)
        converter.action(filename,cachename) 
        lfs.touch(cachename,time,time)
      end
      specification.filename=cachename
    end
  end
end
local function otftotfm(specification)
  local cache_id=specification.hash
  local tfmdata=containers.read(constructors.cache,cache_id)
  if not tfmdata then
    checkconversion(specification) 
    local name=specification.name
    local sub=specification.sub
    local subindex=specification.subindex
    local filename=specification.filename
    local features=specification.features.normal
    local instance=specification.instance or (features and features.axis)
    local rawdata=otf.load(filename,sub,instance)
    if rawdata and next(rawdata) then
      local descriptions=rawdata.descriptions
      rawdata.lookuphash={} 
      tfmdata=copytotfm(rawdata,cache_id)
      if tfmdata and next(tfmdata) then
        local features=constructors.checkedfeatures("otf",features)
        local shared=tfmdata.shared
        if not shared then
          shared={}
          tfmdata.shared=shared
        end
        shared.rawdata=rawdata
        shared.dynamics={}
        tfmdata.changed={}
        shared.features=features
        shared.processes=otf.setfeatures(tfmdata,features)
      end
    end
    containers.write(constructors.cache,cache_id,tfmdata)
  end
  return tfmdata
end
local function read_from_otf(specification)
  local tfmdata=otftotfm(specification)
  if tfmdata then
    tfmdata.properties.name=specification.name
    tfmdata.properties.sub=specification.sub
    tfmdata=constructors.scale(tfmdata,specification)
    local allfeatures=tfmdata.shared.features or specification.features.normal
    constructors.applymanipulators("otf",tfmdata,allfeatures,trace_features,report_otf)
    constructors.setname(tfmdata,specification) 
    fonts.loggers.register(tfmdata,file.suffix(specification.filename),specification)
  end
  return tfmdata
end
local function checkmathsize(tfmdata,mathsize)
  local mathdata=tfmdata.shared.rawdata.metadata.math
  local mathsize=tonumber(mathsize)
  if mathdata then 
    local parameters=tfmdata.parameters
    parameters.scriptpercentage=mathdata.ScriptPercentScaleDown
    parameters.scriptscriptpercentage=mathdata.ScriptScriptPercentScaleDown
    parameters.mathsize=mathsize 
  end
end
registerotffeature {
  name="mathsize",
  description="apply mathsize specified in the font",
  initializers={
    base=checkmathsize,
    node=checkmathsize,
  }
}
function otf.collectlookups(rawdata,kind,script,language)
  if not kind then
    return
  end
  if not script then
    script=default
  end
  if not language then
    language=default
  end
  local lookupcache=rawdata.lookupcache
  if not lookupcache then
    lookupcache={}
    rawdata.lookupcache=lookupcache
  end
  local kindlookup=lookupcache[kind]
  if not kindlookup then
    kindlookup={}
    lookupcache[kind]=kindlookup
  end
  local scriptlookup=kindlookup[script]
  if not scriptlookup then
    scriptlookup={}
    kindlookup[script]=scriptlookup
  end
  local languagelookup=scriptlookup[language]
  if not languagelookup then
    local sequences=rawdata.resources.sequences
    local featuremap={}
    local featurelist={}
    if sequences then
      for s=1,#sequences do
        local sequence=sequences[s]
        local features=sequence.features
        if features then
          features=features[kind]
          if features then
            features=features[script] or features[wildcard]
            if features then
              features=features[language] or features[wildcard]
              if features then
                if not featuremap[sequence] then
                  featuremap[sequence]=true
                  featurelist[#featurelist+1]=sequence
                end
              end
            end
          end
        end
      end
      if #featurelist==0 then
        featuremap,featurelist=false,false
      end
    else
      featuremap,featurelist=false,false
    end
    languagelookup={ featuremap,featurelist }
    scriptlookup[language]=languagelookup
  end
  return unpack(languagelookup)
end
local function getgsub(tfmdata,k,kind,value)
  local shared=tfmdata.shared
  local rawdata=shared and shared.rawdata
  if rawdata then
    local sequences=rawdata.resources.sequences
    if sequences then
      local properties=tfmdata.properties
      local validlookups,lookuplist=otf.collectlookups(rawdata,kind,properties.script,properties.language)
      if validlookups then
        for i=1,#lookuplist do
          local lookup=lookuplist[i]
          local steps=lookup.steps
          local nofsteps=lookup.nofsteps
          for i=1,nofsteps do
            local coverage=steps[i].coverage
            if coverage then
              local found=coverage[k]
              if found then
                return found,lookup.type
              end
            end
          end
        end
      end
    end
  end
end
otf.getgsub=getgsub 
function otf.getsubstitution(tfmdata,k,kind,value)
  local found,kind=getgsub(tfmdata,k,kind,value)
  if not found then
  elseif kind=="gsub_single" then
    return found
  elseif kind=="gsub_alternate" then
    local choice=tonumber(value) or 1 
    return found[choice] or found[1] or k
  end
  return k
end
otf.getalternate=otf.getsubstitution
function otf.getmultiple(tfmdata,k,kind)
  local found,kind=getgsub(tfmdata,k,kind)
  if found and kind=="gsub_multiple" then
    return found
  end
  return { k }
end
function otf.getkern(tfmdata,left,right,kind)
  local kerns=getgsub(tfmdata,left,kind or "kern",true) 
  if kerns then
    local found=kerns[right]
    local kind=type(found)
    if kind=="table" then
      found=found[1][3] 
    elseif kind~="number" then
      found=false
    end
    if found then
      return found*tfmdata.parameters.factor
    end
  end
  return 0
end
local function check_otf(forced,specification,suffix)
  local name=specification.name
  if forced then
    name=specification.forcedname 
  end
  local fullname=findbinfile(name,suffix) or ""
  if fullname=="" then
    fullname=fonts.names.getfilename(name,suffix) or ""
  end
  if fullname~="" and not fonts.names.ignoredfile(fullname) then
    specification.filename=fullname
    return read_from_otf(specification)
  end
end
local function opentypereader(specification,suffix)
  local forced=specification.forced or ""
  if formats[forced] then
    return check_otf(true,specification,forced)
  else
    return check_otf(false,specification,suffix)
  end
end
readers.opentype=opentypereader 
function readers.otf(specification) return opentypereader(specification,"otf") end
function readers.ttf(specification) return opentypereader(specification,"ttf") end
function readers.ttc(specification) return opentypereader(specification,"ttf") end
function readers.woff(specification)
  checkconversion(specification)
  opentypereader(specification,"")
end
function otf.scriptandlanguage(tfmdata,attr)
  local properties=tfmdata.properties
  return properties.script or "dflt",properties.language or "dflt"
end
local function justset(coverage,unicode,replacement)
  coverage[unicode]=replacement
end
otf.coverup={
  stepkey="steps",
  actions={
    chainsubstitution=justset,
    chainposition=justset,
    substitution=justset,
    alternate=justset,
    multiple=justset,
    kern=justset,
    pair=justset,
    single=justset,
    ligature=function(coverage,unicode,ligature)
      local first=ligature[1]
      local tree=coverage[first]
      if not tree then
        tree={}
        coverage[first]=tree
      end
      for i=2,#ligature do
        local l=ligature[i]
        local t=tree[l]
        if not t then
          t={}
          tree[l]=t
        end
        tree=t
      end
      tree.ligature=unicode
    end,
  },
  register=function(coverage,featuretype,format)
    return {
      format=format,
      coverage=coverage,
    }
  end
}

end --- [luaotfload, fontloader-2018-10-08.lua scope for “font-otl”] ---


do  --- [luaotfload, fontloader-2018-10-08.lua scope for “font-oto” d78a6165b7ff6c21f4c3c4c3c0553648] ---

if not modules then modules={} end modules ['font-oto']={ 
  version=1.001,
  comment="companion to font-ini.mkiv",
  author="Hans Hagen, PRAGMA-ADE, Hasselt NL",
  copyright="PRAGMA ADE / ConTeXt Development Team",
  license="see context related readme files"
}
local concat,unpack=table.concat,table.unpack
local insert,remove=table.insert,table.remove
local format,gmatch,gsub,find,match,lower,strip=string.format,string.gmatch,string.gsub,string.find,string.match,string.lower,string.strip
local type,next,tonumber,tostring,rawget=type,next,tonumber,tostring,rawget
local trace_baseinit=false trackers.register("otf.baseinit",function(v) trace_baseinit=v end)
local trace_singles=false trackers.register("otf.singles",function(v) trace_singles=v end)
local trace_multiples=false trackers.register("otf.multiples",function(v) trace_multiples=v end)
local trace_alternatives=false trackers.register("otf.alternatives",function(v) trace_alternatives=v end)
local trace_ligatures=false trackers.register("otf.ligatures",function(v) trace_ligatures=v end)
local trace_kerns=false trackers.register("otf.kerns",function(v) trace_kerns=v end)
local trace_preparing=false trackers.register("otf.preparing",function(v) trace_preparing=v end)
local report_prepare=logs.reporter("fonts","otf prepare")
local fonts=fonts
local otf=fonts.handlers.otf
local otffeatures=otf.features
local registerotffeature=otffeatures.register
otf.defaultbasealternate="none" 
local getprivate=fonts.constructors.getprivate
local wildcard="*"
local default="dflt"
local formatters=string.formatters
local f_unicode=formatters["%U"]
local f_uniname=formatters["%U (%s)"]
local f_unilist=formatters["% t (% t)"]
local function gref(descriptions,n)
  if type(n)=="number" then
    local name=descriptions[n].name
    if name then
      return f_uniname(n,name)
    else
      return f_unicode(n)
    end
  elseif n then
    local num,nam,j={},{},0
    for i=1,#n do
      local ni=n[i]
      if tonumber(ni) then 
        j=j+1
        local di=descriptions[ni]
        num[j]=f_unicode(ni)
        nam[j]=di and di.name or "-"
      end
    end
    return f_unilist(num,nam)
  else
    return "<error in base mode tracing>"
  end
end
local function cref(feature,sequence)
  return formatters["feature %a, type %a, chain lookup %a"](feature,sequence.type,sequence.name)
end
local function report_substitution(feature,sequence,descriptions,unicode,substitution)
  if unicode==substitution then
    report_prepare("%s: base substitution %s maps onto itself",
      cref(feature,sequence),
      gref(descriptions,unicode))
  else
    report_prepare("%s: base substitution %s => %S",
      cref(feature,sequence),
      gref(descriptions,unicode),
      gref(descriptions,substitution))
  end
end
local function report_alternate(feature,sequence,descriptions,unicode,replacement,value,comment)
  if unicode==replacement then
    report_prepare("%s: base alternate %s maps onto itself",
      cref(feature,sequence),
      gref(descriptions,unicode))
  else
    report_prepare("%s: base alternate %s => %s (%S => %S)",
      cref(feature,sequence),
      gref(descriptions,unicode),
      replacement and gref(descriptions,replacement),
      value,
      comment)
  end
end
local function report_ligature(feature,sequence,descriptions,unicode,ligature)
  report_prepare("%s: base ligature %s => %S",
    cref(feature,sequence),
    gref(descriptions,ligature),
    gref(descriptions,unicode))
end
local function report_kern(feature,sequence,descriptions,unicode,otherunicode,value)
  report_prepare("%s: base kern %s + %s => %S",
    cref(feature,sequence),
    gref(descriptions,unicode),
    gref(descriptions,otherunicode),
    value)
end
local basehash,basehashes,applied={},1,{}
local function registerbasehash(tfmdata)
  local properties=tfmdata.properties
  local hash=concat(applied," ")
  local base=basehash[hash]
  if not base then
    basehashes=basehashes+1
    base=basehashes
    basehash[hash]=base
  end
  properties.basehash=base
  properties.fullname=(properties.fullname or properties.name).."-"..base
  applied={}
end
local function registerbasefeature(feature,value)
  applied[#applied+1]=feature.."="..tostring(value)
end
local function makefake(tfmdata,name,present)
  local private=getprivate(tfmdata)
  local character={ intermediate=true,ligatures={} }
  resources.unicodes[name]=private
  tfmdata.characters[private]=character
  tfmdata.descriptions[private]={ name=name }
  present[name]=private
  return character
end
local function make_1(present,tree,name)
  for k,v in next,tree do
    if k=="ligature" then
      present[name]=v
    else
      make_1(present,v,name.."_"..k)
    end
  end
end
local function make_2(present,tfmdata,characters,tree,name,preceding,unicode,done)
  for k,v in next,tree do
    if k=="ligature" then
      local character=characters[preceding]
      if not character then
        if trace_baseinit then
          report_prepare("weird ligature in lookup %a, current %C, preceding %C",sequence.name,v,preceding)
        end
        character=makefake(tfmdata,name,present)
      end
      local ligatures=character.ligatures
      if ligatures then
        ligatures[unicode]={ char=v }
      else
        character.ligatures={ [unicode]={ char=v } }
      end
      if done then
        local d=done[name]
        if not d then
          done[name]={ "dummy",v }
        else
          d[#d+1]=v
        end
      end
    else
      local code=present[name] or unicode
      local name=name.."_"..k
      make_2(present,tfmdata,characters,v,name,code,k,done)
    end
  end
end
local function preparesubstitutions(tfmdata,feature,value,validlookups,lookuplist)
  local characters=tfmdata.characters
  local descriptions=tfmdata.descriptions
  local resources=tfmdata.resources
  local changed=tfmdata.changed
  local ligatures={}
  local alternate=tonumber(value) or true and 1
  local defaultalt=otf.defaultbasealternate
  local trace_singles=trace_baseinit and trace_singles
  local trace_alternatives=trace_baseinit and trace_alternatives
  local trace_ligatures=trace_baseinit and trace_ligatures
  if not changed then
    changed={}
    tfmdata.changed=changed
  end
  for i=1,#lookuplist do
    local sequence=lookuplist[i]
    local steps=sequence.steps
    local kind=sequence.type
    if kind=="gsub_single" then
      for i=1,#steps do
        for unicode,data in next,steps[i].coverage do
          if unicode~=data then
            changed[unicode]=data
          end
          if trace_singles then
            report_substitution(feature,sequence,descriptions,unicode,data)
          end
        end
      end
    elseif kind=="gsub_alternate" then
      for i=1,#steps do
        for unicode,data in next,steps[i].coverage do
          local replacement=data[alternate]
          if replacement then
            if unicode~=replacement then
              changed[unicode]=replacement
            end
            if trace_alternatives then
              report_alternate(feature,sequence,descriptions,unicode,replacement,value,"normal")
            end
          elseif defaultalt=="first" then
            replacement=data[1]
            if unicode~=replacement then
              changed[unicode]=replacement
            end
            if trace_alternatives then
              report_alternate(feature,sequence,descriptions,unicode,replacement,value,defaultalt)
            end
          elseif defaultalt=="last" then
            replacement=data[#data]
            if unicode~=replacement then
              changed[unicode]=replacement
            end
            if trace_alternatives then
              report_alternate(feature,sequence,descriptions,unicode,replacement,value,defaultalt)
            end
          else
            if trace_alternatives then
              report_alternate(feature,sequence,descriptions,unicode,replacement,value,"unknown")
            end
          end
        end
      end
    elseif kind=="gsub_ligature" then
      for i=1,#steps do
        for unicode,data in next,steps[i].coverage do
          ligatures[#ligatures+1]={ unicode,data,"" } 
          if trace_ligatures then
            report_ligature(feature,sequence,descriptions,unicode,data)
          end
        end
      end
    end
  end
  local nofligatures=#ligatures
  if nofligatures>0 then
    local characters=tfmdata.characters
    local present={}
    local done=trace_baseinit and trace_ligatures and {}
    for i=1,nofligatures do
      local ligature=ligatures[i]
      local unicode,tree=ligature[1],ligature[2]
      make_1(present,tree,"ctx_"..unicode)
    end
    for i=1,nofligatures do
      local ligature=ligatures[i]
      local unicode,tree,lookupname=ligature[1],ligature[2],ligature[3]
      make_2(present,tfmdata,characters,tree,"ctx_"..unicode,unicode,unicode,done,sequence)
    end
  end
end
local function preparepositionings(tfmdata,feature,value,validlookups,lookuplist)
  local characters=tfmdata.characters
  local descriptions=tfmdata.descriptions
  local resources=tfmdata.resources
  local properties=tfmdata.properties
  local traceindeed=trace_baseinit and trace_kerns
  for i=1,#lookuplist do
    local sequence=lookuplist[i]
    local steps=sequence.steps
    local kind=sequence.type
    local format=sequence.format
    if kind=="gpos_pair" then
      for i=1,#steps do
        local step=steps[i]
        local format=step.format
        if format=="kern" or format=="move" then
          for unicode,data in next,steps[i].coverage do
            local character=characters[unicode]
            local kerns=character.kerns
            if not kerns then
              kerns={}
              character.kerns=kerns
            end
            if traceindeed then
              for otherunicode,kern in next,data do
                if not kerns[otherunicode] and kern~=0 then
                  kerns[otherunicode]=kern
                  report_kern(feature,sequence,descriptions,unicode,otherunicode,kern)
                end
              end
            else
              for otherunicode,kern in next,data do
                if not kerns[otherunicode] and kern~=0 then
                  kerns[otherunicode]=kern
                end
              end
            end
          end
        else
          for unicode,data in next,steps[i].coverage do
            local character=characters[unicode]
            local kerns=character.kerns
            for otherunicode,kern in next,data do
              local other=kern[2]
              if other==true or (not other and not (kerns and kerns[otherunicode])) then
                local kern=kern[1]
                if kern==true then
                elseif kern[1]~=0 or kern[2]~=0 or kern[4]~=0 then
                else
                  kern=kern[3]
                  if kern~=0 then
                    if kerns then
                      kerns[otherunicode]=kern
                    else
                      kerns={ [otherunicode]=kern }
                      character.kerns=kerns
                    end
                    if traceindeed then
                      report_kern(feature,sequence,descriptions,unicode,otherunicode,kern)
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
local function initializehashes(tfmdata)
end
local function checkmathreplacements(tfmdata,fullname,fixitalics)
  if tfmdata.mathparameters then
    local characters=tfmdata.characters
    local changed=tfmdata.changed
    if next(changed) then
      if trace_preparing or trace_baseinit then
        report_prepare("checking math replacements for %a",fullname)
      end
      for unicode,replacement in next,changed do
        local u=characters[unicode]
        local r=characters[replacement]
        local n=u.next
        local v=u.vert_variants
        local h=u.horiz_variants
        if fixitalics then
          local ui=u.italic
          if ui and not r.italic then
            if trace_preparing then
              report_prepare("using %i units of italic correction from %C for %U",ui,unicode,replacement)
            end
            r.italic=ui 
          end
        end
        if n and not r.next then
          if trace_preparing then
            report_prepare("forcing %s for %C substituted by %U","incremental step",unicode,replacement)
          end
          r.next=n
        end
        if v and not r.vert_variants then
          if trace_preparing then
            report_prepare("forcing %s for %C substituted by %U","vertical variants",unicode,replacement)
          end
          r.vert_variants=v
        end
        if h and not r.horiz_variants then
          if trace_preparing then
            report_prepare("forcing %s for %C substituted by %U","horizontal variants",unicode,replacement)
          end
          r.horiz_variants=h
        end
      end
    end
  end
end
local function featuresinitializer(tfmdata,value)
  if true then 
    local starttime=trace_preparing and os.clock()
    local features=tfmdata.shared.features
    local fullname=tfmdata.properties.fullname or "?"
    if features then
      initializehashes(tfmdata)
      local collectlookups=otf.collectlookups
      local rawdata=tfmdata.shared.rawdata
      local properties=tfmdata.properties
      local script=properties.script
      local language=properties.language
      local rawresources=rawdata.resources
      local rawfeatures=rawresources and rawresources.features
      local basesubstitutions=rawfeatures and rawfeatures.gsub
      local basepositionings=rawfeatures and rawfeatures.gpos
      local substitutionsdone=false
      local positioningsdone=false
      if basesubstitutions or basepositionings then
        local sequences=tfmdata.resources.sequences
        for s=1,#sequences do
          local sequence=sequences[s]
          local sfeatures=sequence.features
          if sfeatures then
            local order=sequence.order
            if order then
              for i=1,#order do 
                local feature=order[i]
                local value=features[feature]
                if value then
                  local validlookups,lookuplist=collectlookups(rawdata,feature,script,language)
                  if not validlookups then
                  elseif basesubstitutions and basesubstitutions[feature] then
                    if trace_preparing then
                      report_prepare("filtering base %s feature %a for %a with value %a","sub",feature,fullname,value)
                    end
                    preparesubstitutions(tfmdata,feature,value,validlookups,lookuplist)
                    registerbasefeature(feature,value)
                    substitutionsdone=true
                  elseif basepositionings and basepositionings[feature] then
                    if trace_preparing then
                      report_prepare("filtering base %a feature %a for %a with value %a","pos",feature,fullname,value)
                    end
                    preparepositionings(tfmdata,feature,value,validlookups,lookuplist)
                    registerbasefeature(feature,value)
                    positioningsdone=true
                  end
                end
              end
            end
          end
        end
      end
      if substitutionsdone then
        checkmathreplacements(tfmdata,fullname,features.fixitalics)
      end
      registerbasehash(tfmdata)
    end
    if trace_preparing then
      report_prepare("preparation time is %0.3f seconds for %a",os.clock()-starttime,fullname)
    end
  end
end
registerotffeature {
  name="features",
  description="features",
  default=true,
  initializers={
    base=featuresinitializer,
  }
}
otf.basemodeinitializer=featuresinitializer

end --- [luaotfload, fontloader-2018-10-08.lua scope for “font-oto”] ---


do  --- [luaotfload, fontloader-2018-10-08.lua scope for “font-otj” 578448ae37a167319dbccd5af04738da] ---

if not modules then modules={} end modules ['font-otj']={
  version=1.001,
  comment="companion to font-lib.mkiv",
  author="Hans Hagen, PRAGMA-ADE, Hasselt NL",
  copyright="PRAGMA ADE / ConTeXt Development Team",
  license="see context related readme files",
}
if not nodes.properties then return end
local next,rawget,tonumber=next,rawget,tonumber
local fastcopy=table.fastcopy
local registertracker=trackers.register
local registerdirective=directives.register
local trace_injections=false registertracker("fonts.injections",function(v) trace_injections=v end)
local trace_marks=false registertracker("fonts.injections.marks",function(v) trace_marks=v end)
local trace_cursive=false registertracker("fonts.injections.cursive",function(v) trace_cursive=v end)
local trace_spaces=false registertracker("fonts.injections.spaces",function(v) trace_spaces=v end)
local report_injections=logs.reporter("fonts","injections")
local report_spaces=logs.reporter("fonts","spaces")
local attributes,nodes,node=attributes,nodes,node
fonts=fonts
local hashes=fonts.hashes
local fontdata=hashes.identifiers
local fontmarks=hashes.marks
nodes.injections=nodes.injections or {}
local injections=nodes.injections
local tracers=nodes.tracers
local setcolor=tracers and tracers.colors.set
local resetcolor=tracers and tracers.colors.reset
local nodecodes=nodes.nodecodes
local glyph_code=nodecodes.glyph
local disc_code=nodecodes.disc
local kern_code=nodecodes.kern
local glue_code=nodecodes.glue
local nuts=nodes.nuts
local nodepool=nuts.pool
local tonode=nuts.tonode
local tonut=nuts.tonut
local setfield=nuts.setfield
local getnext=nuts.getnext
local getprev=nuts.getprev
local getid=nuts.getid
local getfont=nuts.getfont
local getchar=nuts.getchar
local getoffsets=nuts.getoffsets
local getboth=nuts.getboth
local getdisc=nuts.getdisc
local setdisc=nuts.setdisc
local setoffsets=nuts.setoffsets
local ischar=nuts.is_char
local getkern=nuts.getkern
local setkern=nuts.setkern
local setlink=nuts.setlink
local setwidth=nuts.setwidth
local getwidth=nuts.getwidth
local nextchar=nuts.traversers.char
local nextglue=nuts.traversers.glue
local insert_node_before=nuts.insert_before
local insert_node_after=nuts.insert_after
local properties=nodes.properties.data
local fontkern=nuts.pool and nuts.pool.fontkern  
local italickern=nuts.pool and nuts.pool.italickern 
local useitalickerns=false
directives.register("fonts.injections.useitalics",function(v)
  if v then
    report_injections("using italics for space kerns (tracing only)")
  end
  useitalickerns=v
end)
do if not fontkern then 
  local thekern=nuts.new("kern",0) 
  local setkern=nuts.setkern
  local copy_node=nuts.copy_node
  fontkern=function(k)
    local n=copy_node(thekern)
    setkern(n,k)
    return n
  end
end end
do if not italickern then 
  local thekern=nuts.new("kern",3) 
  local setkern=nuts.setkern
  local copy_node=nuts.copy_node
  italickern=function(k)
    local n=copy_node(thekern)
    setkern(n,k)
    return n
  end
end end
function injections.installnewkern() end 
local nofregisteredkerns=0
local nofregisteredpositions=0
local nofregisteredmarks=0
local nofregisteredcursives=0
local keepregisteredcounts=false
function injections.keepcounts()
  keepregisteredcounts=true
end
function injections.resetcounts()
  nofregisteredkerns=0
  nofregisteredpositions=0
  nofregisteredmarks=0
  nofregisteredcursives=0
  keepregisteredcounts=false
end
function injections.reset(n)
  local p=rawget(properties,n)
  if p then
    p.injections=false 
  else
    properties[n]=false 
  end
end
function injections.copy(target,source)
  local sp=rawget(properties,source)
  if sp then
    local tp=rawget(properties,target)
    local si=sp.injections
    if si then
      si=fastcopy(si)
      if tp then
        tp.injections=si
      else
        properties[target]={
          injections=si,
        }
      end
    elseif tp then
      tp.injections=false 
    else
      properties[target]={ injections={} }
    end
  else
    local tp=rawget(properties,target)
    if tp then
      tp.injections=false 
    else
      properties[target]=false 
    end
  end
end
function injections.setligaindex(n,index) 
  local p=rawget(properties,n)
  if p then
    local i=p.injections
    if i then
      i.ligaindex=index
    else
      p.injections={
        ligaindex=index
      }
    end
  else
    properties[n]={
      injections={
        ligaindex=index
      }
    }
  end
end
function injections.getligaindex(n,default)
  local p=rawget(properties,n)
  if p then
    local i=p.injections
    if i then
      return i.ligaindex or default
    end
  end
  return default
end
function injections.setcursive(start,nxt,factor,rlmode,exit,entry,tfmstart,tfmnext,r2lflag)
  local dx=factor*(exit[1]-entry[1])
  local dy=-factor*(exit[2]-entry[2])
  local ws=tfmstart.width
  local wn=tfmnext.width
  nofregisteredcursives=nofregisteredcursives+1
  if rlmode<0 then
    dx=-(dx+wn)
  else
    dx=dx-ws
  end
  if dx==0 then
    dx=0
  end
  local p=rawget(properties,start)
  if p then
    local i=p.injections
    if i then
      i.cursiveanchor=true
    else
      p.injections={
        cursiveanchor=true,
      }
    end
  else
    properties[start]={
      injections={
        cursiveanchor=true,
      },
    }
  end
  local p=rawget(properties,nxt)
  if p then
    local i=p.injections
    if i then
      i.cursivex=dx
      i.cursivey=dy
    else
      p.injections={
        cursivex=dx,
        cursivey=dy,
      }
    end
  else
    properties[nxt]={
      injections={
        cursivex=dx,
        cursivey=dy,
      },
    }
  end
  return dx,dy,nofregisteredcursives
end
function injections.setposition(kind,current,factor,rlmode,spec,injection)
  local x=factor*(spec[1] or 0)
  local y=factor*(spec[2] or 0)
  local w=factor*(spec[3] or 0)
  local h=factor*(spec[4] or 0)
  if x~=0 or w~=0 or y~=0 or h~=0 then 
    local yoffset=y-h
    local leftkern=x   
    local rightkern=w-x 
    if leftkern~=0 or rightkern~=0 or yoffset~=0 then
      nofregisteredpositions=nofregisteredpositions+1
      if rlmode and rlmode<0 then
        leftkern,rightkern=rightkern,leftkern
      end
      if not injection then
        injection="injections"
      end
      local p=rawget(properties,current)
      if p then
        local i=p[injection]
        if i then
          if leftkern~=0 then
            i.leftkern=(i.leftkern or 0)+leftkern
          end
          if rightkern~=0 then
            i.rightkern=(i.rightkern or 0)+rightkern
          end
          if yoffset~=0 then
            i.yoffset=(i.yoffset or 0)+yoffset
          end
        elseif leftkern~=0 or rightkern~=0 then
          p[injection]={
            leftkern=leftkern,
            rightkern=rightkern,
            yoffset=yoffset,
          }
        else
          p[injection]={
            yoffset=yoffset,
          }
        end
      elseif leftkern~=0 or rightkern~=0 then
        properties[current]={
          [injection]={
            leftkern=leftkern,
            rightkern=rightkern,
            yoffset=yoffset,
          },
        }
      else
        properties[current]={
          [injection]={
            yoffset=yoffset,
          },
        }
      end
      return x,y,w,h,nofregisteredpositions
     end
  end
  return x,y,w,h 
end
function injections.setkern(current,factor,rlmode,x,injection)
  local dx=factor*x
  if dx~=0 then
    nofregisteredkerns=nofregisteredkerns+1
    local p=rawget(properties,current)
    if not injection then
      injection="injections"
    end
    if p then
      local i=p[injection]
      if i then
        i.leftkern=dx+(i.leftkern or 0)
      else
        p[injection]={
          leftkern=dx,
        }
      end
    else
      properties[current]={
        [injection]={
          leftkern=dx,
        },
      }
    end
    return dx,nofregisteredkerns
  else
    return 0,0
  end
end
function injections.setmove(current,factor,rlmode,x,injection)
  local dx=factor*x
  if dx~=0 then
    nofregisteredkerns=nofregisteredkerns+1
    local p=rawget(properties,current)
    if not injection then
      injection="injections"
    end
    if rlmode and rlmode<0 then
      if p then
        local i=p[injection]
        if i then
          i.rightkern=dx+(i.rightkern or 0)
        else
          p[injection]={
            rightkern=dx,
          }
        end
      else
        properties[current]={
          [injection]={
            rightkern=dx,
          },
        }
      end
    else
      if p then
        local i=p[injection]
        if i then
          i.leftkern=dx+(i.leftkern or 0)
        else
          p[injection]={
            leftkern=dx,
          }
        end
      else
        properties[current]={
          [injection]={
            leftkern=dx,
          },
        }
      end
    end
    return dx,nofregisteredkerns
  else
    return 0,0
  end
end
function injections.setmark(start,base,factor,rlmode,ba,ma,tfmbase,mkmk,checkmark) 
  local dx,dy=factor*(ba[1]-ma[1]),factor*(ba[2]-ma[2])
  nofregisteredmarks=nofregisteredmarks+1
  if rlmode>=0 then
    dx=tfmbase.width-dx 
  end
  local p=rawget(properties,start)
  if p then
    local i=p.injections
    if i then
      if i.markmark then
      else
        if dx~=0 then
          i.markx=dx
        end
        if y~=0 then
          i.marky=dy
        end
        if rlmode then
          i.markdir=rlmode
        end
        i.markbase=nofregisteredmarks
        i.markbasenode=base
        i.markmark=mkmk
        i.checkmark=checkmark
      end
    else
      p.injections={
        markx=dx,
        marky=dy,
        markdir=rlmode or 0,
        markbase=nofregisteredmarks,
        markbasenode=base,
        markmark=mkmk,
        checkmark=checkmark,
      }
    end
  else
    properties[start]={
      injections={
        markx=dx,
        marky=dy,
        markdir=rlmode or 0,
        markbase=nofregisteredmarks,
        markbasenode=base,
        markmark=mkmk,
        checkmark=checkmark,
      },
    }
  end
  return dx,dy,nofregisteredmarks
end
local function dir(n)
  return (n and n<0 and "r-to-l") or (n and n>0 and "l-to-r") or "unset"
end
local function showchar(n,nested)
  local char=getchar(n)
  report_injections("%wfont %s, char %U, glyph %c",nested and 2 or 0,getfont(n),char,char)
end
local function show(n,what,nested,symbol)
  if n then
    local p=rawget(properties,n)
    if p then
      local i=p[what]
      if i then
        local leftkern=i.leftkern or 0
        local rightkern=i.rightkern or 0
        local yoffset=i.yoffset  or 0
        local markx=i.markx   or 0
        local marky=i.marky   or 0
        local markdir=i.markdir  or 0
        local markbase=i.markbase or 0
        local cursivex=i.cursivex or 0
        local cursivey=i.cursivey or 0
        local ligaindex=i.ligaindex or 0
        local cursbase=i.cursiveanchor
        local margin=nested and 4 or 2
        if rightkern~=0 or yoffset~=0 then
          report_injections("%w%s pair: lx %p, rx %p, dy %p",margin,symbol,leftkern,rightkern,yoffset)
        elseif leftkern~=0 then
          report_injections("%w%s kern: dx %p",margin,symbol,leftkern)
        end
        if markx~=0 or marky~=0 or markbase~=0 then
          report_injections("%w%s mark: dx %p, dy %p, dir %s, base %s",margin,symbol,markx,marky,markdir,markbase~=0 and "yes" or "no")
        end
        if cursivex~=0 or cursivey~=0 then
          if cursbase then
            report_injections("%w%s curs: base dx %p, dy %p",margin,symbol,cursivex,cursivey)
          else
            report_injections("%w%s curs: dx %p, dy %p",margin,symbol,cursivex,cursivey)
          end
        elseif cursbase then
          report_injections("%w%s curs: base",margin,symbol)
        end
        if ligaindex~=0 then
          report_injections("%w%s liga: index %i",margin,symbol,ligaindex)
        end
      end
    end
  end
end
local function showsub(n,what,where)
  report_injections("begin subrun: %s",where)
  for n in nextchar,n do
    showchar(n,where)
    show(n,what,where," ")
  end
  report_injections("end subrun")
end
local function trace(head,where)
  report_injections()
  report_injections("begin run %s: %s kerns, %s positions, %s marks and %s cursives registered",
    where or "",nofregisteredkerns,nofregisteredpositions,nofregisteredmarks,nofregisteredcursives)
  local n=head
  while n do
    local id=getid(n)
    if id==glyph_code then
      showchar(n)
      show(n,"injections",false," ")
      show(n,"preinjections",false,"<")
      show(n,"postinjections",false,">")
      show(n,"replaceinjections",false,"=")
      show(n,"emptyinjections",false,"*")
    elseif id==disc_code then
      local pre,post,replace=getdisc(n)
      if pre then
        showsub(pre,"preinjections","pre")
      end
      if post then
        showsub(post,"postinjections","post")
      end
      if replace then
        showsub(replace,"replaceinjections","replace")
      end
      show(n,"emptyinjections",false,"*")
    end
    n=getnext(n)
  end
  report_injections("end run")
end
local function show_result(head)
  local current=head
  local skipping=false
  while current do
    local id=getid(current)
    if id==glyph_code then
      local w=getwidth(current)
      local x,y=getoffsets(current)
      report_injections("char: %C, width %p, xoffset %p, yoffset %p",getchar(current),w,x,y)
      skipping=false
    elseif id==kern_code then
      report_injections("kern: %p",getkern(current))
      skipping=false
    elseif not skipping then
      report_injections()
      skipping=true
    end
    current=getnext(current)
  end
  report_injections()
end
local function inject_kerns_only(head,where)
  if trace_injections then
    trace(head,"kerns")
  end
  local current=head
  local prev=nil
  local next=nil
  local prevdisc=nil
  local pre=nil 
  local post=nil 
  local replace=nil 
  local pretail=nil 
  local posttail=nil 
  local replacetail=nil 
  while current do
    local next=getnext(current)
    local char,id=ischar(current)
    if char then
      local p=rawget(properties,current)
      if p then
        local i=p.injections
        if i then
          local leftkern=i.leftkern
          if leftkern and leftkern~=0 then
            head=insert_node_before(head,current,fontkern(leftkern))
          end
        end
        if prevdisc then
          local done=false
          if post then
            local i=p.postinjections
            if i then
              local leftkern=i.leftkern
              if leftkern and leftkern~=0 then
                setlink(posttail,fontkern(leftkern))
                done=true
              end
            end
          end
          if replace then
            local i=p.replaceinjections
            if i then
              local leftkern=i.leftkern
              if leftkern and leftkern~=0 then
                setlink(replacetail,fontkern(leftkern))
                done=true
              end
            end
          else
            local i=p.emptyinjections
            if i then
              local leftkern=i.leftkern
              if leftkern and leftkern~=0 then
                setfield(prev,"replace",fontkern(leftkern)) 
              end
            end
          end
          if done then
            setdisc(prevdisc,pre,post,replace)
          end
        end
      end
      prevdisc=nil
    elseif char==false then
      prevdisc=nil
    elseif id==disc_code then
      pre,post,replace,pretail,posttail,replacetail=getdisc(current,true)
      local done=false
      if pre then
        for n in nextchar,pre do
          local p=rawget(properties,n)
          if p then
            local i=p.injections or p.preinjections
            if i then
              local leftkern=i.leftkern
              if leftkern and leftkern~=0 then
                pre=insert_node_before(pre,n,fontkern(leftkern))
                done=true
              end
            end
          end
        end
      end
      if post then
        for n in nextchar,post do
          local p=rawget(properties,n)
          if p then
            local i=p.injections or p.postinjections
            if i then
              local leftkern=i.leftkern
              if leftkern and leftkern~=0 then
                post=insert_node_before(post,n,fontkern(leftkern))
                done=true
              end
            end
          end
        end
      end
      if replace then
        for n in nextchar,replace do
          local p=rawget(properties,n)
          if p then
            local i=p.injections or p.replaceinjections
            if i then
              local leftkern=i.leftkern
              if leftkern and leftkern~=0 then
                replace=insert_node_before(replace,n,fontkern(leftkern))
                done=true
              end
            end
          end
        end
      end
      if done then
        setdisc(current,pre,post,replace)
      end
      prevdisc=current
    else
      prevdisc=nil
    end
    prev=current
    current=next
  end
  if keepregisteredcounts then
    keepregisteredcounts=false
  else
    nofregisteredkerns=0
  end
  if trace_injections then
    show_result(head)
  end
  return head
end
local function inject_positions_only(head,where)
  if trace_injections then
    trace(head,"positions")
  end
  local current=head
  local prev=nil
  local next=nil
  local prevdisc=nil
  local prevglyph=nil
  local pre=nil 
  local post=nil 
  local replace=nil 
  local pretail=nil 
  local posttail=nil 
  local replacetail=nil 
  while current do
    local next=getnext(current)
    local char,id=ischar(current)
    if char then
      local p=rawget(properties,current)
      if p then
        local i=p.injections
        if i then
          local yoffset=i.yoffset
          if yoffset and yoffset~=0 then
            setoffsets(current,false,yoffset)
          end
          local leftkern=i.leftkern
          local rightkern=i.rightkern
          if leftkern and leftkern~=0 then
            if rightkern and leftkern==-rightkern then
              setoffsets(current,leftkern,false)
              rightkern=0
            else
              head=insert_node_before(head,current,fontkern(leftkern))
            end
          end
          if rightkern and rightkern~=0 then
            insert_node_after(head,current,fontkern(rightkern))
          end
        else
          local i=p.emptyinjections
          if i then
            local rightkern=i.rightkern
            if rightkern and rightkern~=0 then
              if next and getid(next)==disc_code then
                if replace then
                else
                  setfield(next,"replace",fontkern(rightkern)) 
                end
              end
            end
          end
        end
        if prevdisc then
          local done=false
          if post then
            local i=p.postinjections
            if i then
              local leftkern=i.leftkern
              if leftkern and leftkern~=0 then
                setlink(posttail,fontkern(leftkern))
                done=true
              end
            end
          end
          if replace then
            local i=p.replaceinjections
            if i then
              local leftkern=i.leftkern
              if leftkern and leftkern~=0 then
                setlink(replacetail,fontkern(leftkern))
                done=true
              end
            end
          else
            local i=p.emptyinjections
            if i then
              local leftkern=i.leftkern
              if leftkern and leftkern~=0 then
                setfield(prev,"replace",fontkern(leftkern)) 
              end
            end
          end
          if done then
            setdisc(prevdisc,pre,post,replace)
          end
        end
      end
      prevdisc=nil
      prevglyph=current
    elseif char==false then
      prevdisc=nil
      prevglyph=current
    elseif id==disc_code then
      pre,post,replace,pretail,posttail,replacetail=getdisc(current,true)
      local done=false
      if pre then
        for n in nextchar,pre do
          local p=rawget(properties,n)
          if p then
            local i=p.injections or p.preinjections
            if i then
              local yoffset=i.yoffset
              if yoffset and yoffset~=0 then
                setoffsets(n,false,yoffset)
              end
              local leftkern=i.leftkern
              if leftkern and leftkern~=0 then
                pre=insert_node_before(pre,n,fontkern(leftkern))
                done=true
              end
              local rightkern=i.rightkern
              if rightkern and rightkern~=0 then
                insert_node_after(pre,n,fontkern(rightkern))
                done=true
              end
            end
          end
        end
      end
      if post then
        for n in nextchar,post do
          local p=rawget(properties,n)
          if p then
            local i=p.injections or p.postinjections
            if i then
              local yoffset=i.yoffset
              if yoffset and yoffset~=0 then
                setoffsets(n,false,yoffset)
              end
              local leftkern=i.leftkern
              if leftkern and leftkern~=0 then
                post=insert_node_before(post,n,fontkern(leftkern))
                done=true
              end
              local rightkern=i.rightkern
              if rightkern and rightkern~=0 then
                insert_node_after(post,n,fontkern(rightkern))
                done=true
              end
            end
          end
        end
      end
      if replace then
        for n in nextchar,replace do
          local p=rawget(properties,n)
          if p then
            local i=p.injections or p.replaceinjections
            if i then
              local yoffset=i.yoffset
              if yoffset and yoffset~=0 then
                setoffsets(n,false,yoffset)
              end
              local leftkern=i.leftkern
              if leftkern and leftkern~=0 then
                replace=insert_node_before(replace,n,fontkern(leftkern))
                done=true
              end
              local rightkern=i.rightkern
              if rightkern and rightkern~=0 then
                insert_node_after(replace,n,fontkern(rightkern))
                done=true
              end
            end
          end
        end
      end
      if prevglyph then
        if pre then
          local p=rawget(properties,prevglyph)
          if p then
            local i=p.preinjections
            if i then
              local rightkern=i.rightkern
              if rightkern and rightkern~=0 then
                pre=insert_node_before(pre,pre,fontkern(rightkern))
                done=true
              end
            end
          end
        end
        if replace then
          local p=rawget(properties,prevglyph)
          if p then
            local i=p.replaceinjections
            if i then
              local rightkern=i.rightkern
              if rightkern and rightkern~=0 then
                replace=insert_node_before(replace,replace,fontkern(rightkern))
                done=true
              end
            end
          end
        end
      end
      if done then
        setdisc(current,pre,post,replace)
      end
      prevglyph=nil
      prevdisc=current
    else
      prevglyph=nil
      prevdisc=nil
    end
    prev=current
    current=next
  end
  if keepregisteredcounts then
    keepregisteredcounts=false
  else
    nofregisteredpositions=0
  end
  if trace_injections then
    show_result(head)
  end
  return head
end
local function showoffset(n,flag)
  local x,y=getoffsets(n)
  if x~=0 or y~=0 then
    setcolor(n,"darkgray")
  end
end
local function inject_everything(head,where)
  if trace_injections then
    trace(head,"everything")
  end
  local hascursives=nofregisteredcursives>0
  local hasmarks=nofregisteredmarks>0
  local current=head
  local last=nil
  local prev=nil
  local next=nil
  local prevdisc=nil
  local prevglyph=nil
  local pre=nil 
  local post=nil 
  local replace=nil 
  local pretail=nil 
  local posttail=nil 
  local replacetail=nil
  local cursiveanchor=nil
  local minc=0
  local maxc=0
  local glyphs={}
  local marks={}
  local nofmarks=0
  local function processmark(p,n,pn) 
    local px,py=getoffsets(p)
    local nx,ny=getoffsets(n)
    local ox=0
    local rightkern=nil
    local pp=rawget(properties,p)
    if pp then
      pp=pp.injections
      if pp then
        rightkern=pp.rightkern
      end
    end
    local markdir=pn.markdir
    if rightkern then 
      ox=px-(pn.markx or 0)-rightkern
      if markdir and markdir<0 then
        if not pn.markmark then
          ox=ox+(pn.leftkern or 0)
        end
      else
        if false then
          local leftkern=pp.leftkern
          if leftkern then
            ox=ox-leftkern
          end
        end
      end
    else
      ox=px-(pn.markx or 0)
      if markdir and markdir<0 then
        if not pn.markmark then
          local leftkern=pn.leftkern
          if leftkern then
            ox=ox+leftkern 
          end
        end
      end
      if pn.checkmark then
        local wn=getwidth(n) 
        if wn and wn~=0 then
          wn=wn/2
          if trace_injections then
            report_injections("correcting non zero width mark %C",getchar(n))
          end
          insert_node_before(n,n,fontkern(-wn))
          insert_node_after(n,n,fontkern(-wn))
        end
      end
    end
    local oy=ny+py+(pn.marky or 0)
    if not pn.markmark then
      local yoffset=pn.yoffset
      if yoffset then
        oy=oy+yoffset 
      end
    end
    setoffsets(n,ox,oy)
    if trace_marks then
      showoffset(n,true)
    end
  end
  while current do
    local next=getnext(current)
    local char,id=ischar(current)
    if char then
      local p=rawget(properties,current)
      if p then
        local i=p.injections
        if i then
          local pm=i.markbasenode
          if pm then
            nofmarks=nofmarks+1
            marks[nofmarks]=current
          else
            local yoffset=i.yoffset
            if yoffset and yoffset~=0 then
              setoffsets(current,false,yoffset)
            end
            if hascursives then
              local cursivex=i.cursivex
              if cursivex then
                if cursiveanchor then
                  if cursivex~=0 then
                    i.leftkern=(i.leftkern or 0)+cursivex
                  end
                  if maxc==0 then
                    minc=1
                    maxc=1
                    glyphs[1]=cursiveanchor
                  else
                    maxc=maxc+1
                    glyphs[maxc]=cursiveanchor
                  end
                  properties[cursiveanchor].cursivedy=i.cursivey 
                  last=current
                else
                  maxc=0
                end
              elseif maxc>0 then
                local nx,ny=getoffsets(current)
                for i=maxc,minc,-1 do
                  local ti=glyphs[i]
                  ny=ny+properties[ti].cursivedy
                  setoffsets(ti,false,ny) 
                  if trace_cursive then
                    showoffset(ti)
                  end
                end
                maxc=0
                cursiveanchor=nil
              end
              if i.cursiveanchor then
                cursiveanchor=current 
              else
                if maxc>0 then
                  local nx,ny=getoffsets(current)
                  for i=maxc,minc,-1 do
                    local ti=glyphs[i]
                    ny=ny+properties[ti].cursivedy
                    setoffsets(ti,false,ny) 
                    if trace_cursive then
                      showoffset(ti)
                    end
                  end
                  maxc=0
                end
                cursiveanchor=nil
              end
            end
            local leftkern=i.leftkern
            local rightkern=i.rightkern
            if leftkern and leftkern~=0 then
              if rightkern and leftkern==-rightkern then
                setoffsets(current,leftkern,false)
                rightkern=0
              else
                head=insert_node_before(head,current,fontkern(leftkern))
              end
            end
            if rightkern and rightkern~=0 then
              insert_node_after(head,current,fontkern(rightkern))
            end
          end
        else
          local i=p.emptyinjections
          if i then
            local rightkern=i.rightkern
            if rightkern and rightkern~=0 then
              if next and getid(next)==disc_code then
                if replace then
                else
                  setfield(next,"replace",fontkern(rightkern)) 
                end
              end
            end
          end
        end
        if prevdisc then
          if p then
            local done=false
            if post then
              local i=p.postinjections
              if i then
                local leftkern=i.leftkern
                if leftkern and leftkern~=0 then
                  setlink(posttail,fontkern(leftkern))
                  done=true
                end
              end
            end
            if replace then
              local i=p.replaceinjections
              if i then
                local leftkern=i.leftkern
                if leftkern and leftkern~=0 then
                  setlink(replacetail,fontkern(leftkern))
                  done=true
                end
              end
            else
              local i=p.emptyinjections
              if i then
                local leftkern=i.leftkern
                if leftkern and leftkern~=0 then
                  setfield(prev,"replace",fontkern(leftkern)) 
                end
              end
            end
            if done then
              setdisc(prevdisc,pre,post,replace)
            end
          end
        end
      else
        if hascursives and maxc>0 then
          local nx,ny=getoffsets(current)
          for i=maxc,minc,-1 do
            local ti=glyphs[i]
            ny=ny+properties[ti].cursivedy
            local xi,yi=getoffsets(ti)
            setoffsets(ti,xi,yi+ny) 
          end
          maxc=0
          cursiveanchor=nil
        end
      end
      prevdisc=nil
      prevglyph=current
    elseif char==false then
      prevdisc=nil
      prevglyph=current
    elseif id==disc_code then
      pre,post,replace,pretail,posttail,replacetail=getdisc(current,true)
      local done=false
      if pre then
        for n in nextchar,pre do
          local p=rawget(properties,n)
          if p then
            local i=p.injections or p.preinjections
            if i then
              local yoffset=i.yoffset
              if yoffset and yoffset~=0 then
                setoffsets(n,false,yoffset)
              end
              local leftkern=i.leftkern
              if leftkern and leftkern~=0 then
                pre=insert_node_before(pre,n,fontkern(leftkern))
                done=true
              end
              local rightkern=i.rightkern
              if rightkern and rightkern~=0 then
                insert_node_after(pre,n,fontkern(rightkern))
                done=true
              end
              if hasmarks then
                local pm=i.markbasenode
                if pm then
                  processmark(pm,n,i)
                end
              end
            end
          end
        end
      end
      if post then
        for n in nextchar,post do
          local p=rawget(properties,n)
          if p then
            local i=p.injections or p.postinjections
            if i then
              local yoffset=i.yoffset
              if yoffset and yoffset~=0 then
                setoffsets(n,false,yoffset)
              end
              local leftkern=i.leftkern
              if leftkern and leftkern~=0 then
                post=insert_node_before(post,n,fontkern(leftkern))
                done=true
              end
              local rightkern=i.rightkern
              if rightkern and rightkern~=0 then
                insert_node_after(post,n,fontkern(rightkern))
                done=true
              end
              if hasmarks then
                local pm=i.markbasenode
                if pm then
                  processmark(pm,n,i)
                end
              end
            end
          end
        end
      end
      if replace then
        for n in nextchar,replace do
          local p=rawget(properties,n)
          if p then
            local i=p.injections or p.replaceinjections
            if i then
              local yoffset=i.yoffset
              if yoffset and yoffset~=0 then
                setoffsets(n,false,yoffset)
              end
              local leftkern=i.leftkern
              if leftkern and leftkern~=0 then
                replace=insert_node_before(replace,n,fontkern(leftkern))
                done=true
              end
              local rightkern=i.rightkern
              if rightkern and rightkern~=0 then
                insert_node_after(replace,n,fontkern(rightkern))
                done=true
              end
              if hasmarks then
                local pm=i.markbasenode
                if pm then
                  processmark(pm,n,i)
                end
              end
            end
          end
        end
      end
      if prevglyph then
        if pre then
          local p=rawget(properties,prevglyph)
          if p then
            local i=p.preinjections
            if i then
              local rightkern=i.rightkern
              if rightkern and rightkern~=0 then
                pre=insert_node_before(pre,pre,fontkern(rightkern))
                done=true
              end
            end
          end
        end
        if replace then
          local p=rawget(properties,prevglyph)
          if p then
            local i=p.replaceinjections
            if i then
              local rightkern=i.rightkern
              if rightkern and rightkern~=0 then
                replace=insert_node_before(replace,replace,fontkern(rightkern))
                done=true
              end
            end
          end
        end
      end
      if done then
        setdisc(current,pre,post,replace)
      end
      prevglyph=nil
      prevdisc=current
    else
      prevglyph=nil
      prevdisc=nil
    end
    prev=current
    current=next
  end
  if hascursives and maxc>0 then
    local nx,ny=getoffsets(last)
    for i=maxc,minc,-1 do
      local ti=glyphs[i]
      ny=ny+properties[ti].cursivedy
      setoffsets(ti,false,ny) 
      if trace_cursive then
        showoffset(ti)
      end
    end
  end
  if nofmarks>0 then
    for i=1,nofmarks do
      local m=marks[i]
      local p=rawget(properties,m)
      local i=p.injections
      local b=i.markbasenode
      processmark(b,m,i)
    end
  elseif hasmarks then
  end
  if keepregisteredcounts then
    keepregisteredcounts=false
  else
    nofregisteredkerns=0
    nofregisteredpositions=0
    nofregisteredmarks=0
    nofregisteredcursives=0
  end
  if trace_injections then
    show_result(head)
  end
  return head
end
local triggers=false
function nodes.injections.setspacekerns(font,sequence)
  if triggers then
    triggers[font]=sequence
  else
    triggers={ [font]=sequence }
  end
end
local getthreshold
if context then
  local threshold=1 
  local parameters=fonts.hashes.parameters
  directives.register("otf.threshold",function(v) threshold=tonumber(v) or 1 end)
  getthreshold=function(font)
    local p=parameters[font]
    local f=p.factor
    local s=p.spacing
    local t=threshold*(s and s.width or p.space or 0)-2
    return t>0 and t or 0,f
  end
else
  injections.threshold=0
  getthreshold=function(font)
    local p=fontdata[font].parameters
    local f=p.factor
    local s=p.spacing
    local t=injections.threshold*(s and s.width or p.space or 0)-2
    return t>0 and t or 0,f
  end
end
injections.getthreshold=getthreshold
function injections.isspace(n,threshold,id)
  if (id or getid(n))==glue_code then
    local w=getwidth(n)
    if threshold and w>threshold then 
      return 32
    end
  end
end
local getspaceboth=getboth
function injections.installgetspaceboth(gb)
  getspaceboth=gb or getboth
end
local function injectspaces(head)
  if not triggers then
    return head
  end
  local lastfont=nil
  local spacekerns=nil
  local leftkerns=nil
  local rightkerns=nil
  local factor=0
  local threshold=0
  local leftkern=false
  local rightkern=false
  local function updatefont(font,trig)
    leftkerns=trig.left
    rightkerns=trig.right
    lastfont=font
    threshold,
    factor=getthreshold(font)
  end
  for n in nextglue,head do
    local prev,next=getspaceboth(n)
    local prevchar=prev and ischar(prev)
    local nextchar=next and ischar(next)
    if nextchar then
      local font=getfont(next)
      local trig=triggers[font]
      if trig then
        if lastfont~=font then
          updatefont(font,trig)
        end
        if rightkerns then
          rightkern=rightkerns[nextchar]
        end
      end
    end
    if prevchar then
      local font=getfont(prev)
      local trig=triggers[font]
      if trig then
        if lastfont~=font then
          updatefont(font,trig)
        end
        if leftkerns then
          leftkern=leftkerns[prevchar]
        end
      end
    end
    if leftkern then
      local old=getwidth(n)
      if old>threshold then
        if rightkern then
          if useitalickerns then
            local lnew=leftkern*factor
            local rnew=rightkern*factor
            if trace_spaces then
              report_spaces("%C [%p + %p + %p] %C",prevchar,lnew,old,rnew,nextchar)
            end
            head=insert_node_before(head,n,italickern(lnew))
            insert_node_after(head,n,italickern(rnew))
          else
            local new=old+(leftkern+rightkern)*factor
            if trace_spaces then
              report_spaces("%C [%p -> %p] %C",prevchar,old,new,nextchar)
            end
            setwidth(n,new)
          end
          rightkern=false
        else
          if useitalickerns then
            local new=leftkern*factor
            if trace_spaces then
              report_spaces("%C [%p + %p]",prevchar,old,new)
            end
            insert_node_after(head,n,italickern(new)) 
          else
            local new=old+leftkern*factor
            if trace_spaces then
              report_spaces("%C [%p -> %p]",prevchar,old,new)
            end
            setwidth(n,new)
          end
        end
      end
      leftkern=false
    elseif rightkern then
      local old=getwidth(n)
      if old>threshold then
        if useitalickerns then
          local new=rightkern*factor
          if trace_spaces then
            report_spaces("%C [%p + %p]",nextchar,old,new)
          end
          insert_node_after(head,n,italickern(new))
        else
          local new=old+rightkern*factor
          if trace_spaces then
            report_spaces("[%p -> %p] %C",nextchar,old,new)
          end
          setwidth(n,new)
        end
      end
      rightkern=false
    end
  end
  triggers=false
  return head
end
function injections.handler(head,where)
  if triggers then
    head=injectspaces(head)
  end
  if nofregisteredmarks>0 or nofregisteredcursives>0 then
    if trace_injections then
      report_injections("injection variant %a","everything")
    end
    return inject_everything(head,where)
  elseif nofregisteredpositions>0 then
    if trace_injections then
      report_injections("injection variant %a","positions")
    end
    return inject_positions_only(head,where)
  elseif nofregisteredkerns>0 then
    if trace_injections then
      report_injections("injection variant %a","kerns")
    end
    return inject_kerns_only(head,where)
  else
    return head
  end
end

end --- [luaotfload, fontloader-2018-10-08.lua scope for “font-otj”] ---


do  --- [luaotfload, fontloader-2018-10-08.lua scope for “font-ota” d883cf661bb8c27bfa9b7cc66420c1ed] ---

if not modules then modules={} end modules ['font-ota']={
  version=1.001,
  comment="companion to font-ini.mkiv",
  author="Hans Hagen, PRAGMA-ADE, Hasselt NL",
  copyright="PRAGMA ADE / ConTeXt Development Team",
  license="see context related readme files"
}
local type=type
if not trackers then trackers={ register=function() end } end
local fonts,nodes,node=fonts,nodes,node
local allocate=utilities.storage.allocate
local otf=fonts.handlers.otf
local analyzers=fonts.analyzers
local initializers=allocate()
local methods=allocate()
analyzers.initializers=initializers
analyzers.methods=methods
local a_state=attributes.private('state')
local nuts=nodes.nuts
local tonut=nuts.tonut
local getnext=nuts.getnext
local getprev=nuts.getprev
local getprev=nuts.getprev
local getprop=nuts.getprop
local setprop=nuts.setprop
local getfont=nuts.getfont
local getsubtype=nuts.getsubtype
local getchar=nuts.getchar
local ischar=nuts.is_char
local end_of_math=nuts.end_of_math
local nodecodes=nodes.nodecodes
local disc_code=nodecodes.disc
local math_code=nodecodes.math
local fontdata=fonts.hashes.identifiers
local categories=characters and characters.categories or {} 
local chardata=characters and characters.data
local otffeatures=fonts.constructors.features.otf
local registerotffeature=otffeatures.register
local s_init=1  local s_rphf=7
local s_medi=2  local s_half=8
local s_fina=3  local s_pref=9
local s_isol=4  local s_blwf=10
local s_mark=5  local s_pstf=11
local s_rest=6
local states=allocate {
  init=s_init,
  medi=s_medi,
  med2=s_medi,
  fina=s_fina,
  fin2=s_fina,
  fin3=s_fina,
  isol=s_isol,
  mark=s_mark,
  rest=s_rest,
  rphf=s_rphf,
  half=s_half,
  pref=s_pref,
  blwf=s_blwf,
  pstf=s_pstf,
}
local features=allocate {
  init=s_init,
  medi=s_medi,
  med2=s_medi,
  fina=s_fina,
  fin2=s_fina,
  fin3=s_fina,
  isol=s_isol,
  rphf=s_rphf,
  half=s_half,
  pref=s_pref,
  blwf=s_blwf,
  pstf=s_pstf,
}
analyzers.states=states
analyzers.features=features
analyzers.useunicodemarks=false
function analyzers.setstate(head,font)
  local useunicodemarks=analyzers.useunicodemarks
  local tfmdata=fontdata[font]
  local descriptions=tfmdata.descriptions
  local first,last,current,n,done=nil,nil,head,0,false 
  current=tonut(current)
  while current do
    local char,id=ischar(current,font)
    if char and not getprop(current,a_state) then
      done=true
      local d=descriptions[char]
      if d then
        if d.class=="mark" then
          done=true
          setprop(current,a_state,s_mark)
        elseif useunicodemarks and categories[char]=="mn" then
          done=true
          setprop(current,a_state,s_mark)
        elseif n==0 then
          first,last,n=current,current,1
          setprop(current,a_state,s_init)
        else
          last,n=current,n+1
          setprop(current,a_state,s_medi)
        end
      else 
        if first and first==last then
          setprop(last,a_state,s_isol)
        elseif last then
          setprop(last,a_state,s_fina)
        end
        first,last,n=nil,nil,0
      end
    elseif char==false then
      if first and first==last then
        setprop(last,a_state,s_isol)
      elseif last then
        setprop(last,a_state,s_fina)
      end
      first,last,n=nil,nil,0
      if id==math_code then
        current=end_of_math(current)
      end
    elseif id==disc_code then
      setprop(current,a_state,s_medi)
      last=current
    else 
      if first and first==last then
        setprop(last,a_state,s_isol)
      elseif last then
        setprop(last,a_state,s_fina)
      end
      first,last,n=nil,nil,0
      if id==math_code then
        current=end_of_math(current)
      end
    end
    current=getnext(current)
  end
  if first and first==last then
    setprop(last,a_state,s_isol)
  elseif last then
    setprop(last,a_state,s_fina)
  end
  return head,done
end
local function analyzeinitializer(tfmdata,value) 
  local script,language=otf.scriptandlanguage(tfmdata) 
  local action=initializers[script]
  if not action then
  elseif type(action)=="function" then
    return action(tfmdata,value)
  else
    local action=action[language]
    if action then
      return action(tfmdata,value)
    end
  end
end
local function analyzeprocessor(head,font,attr)
  local tfmdata=fontdata[font]
  local script,language=otf.scriptandlanguage(tfmdata,attr)
  local action=methods[script]
  if not action then
  elseif type(action)=="function" then
    return action(head,font,attr)
  else
    action=action[language]
    if action then
      return action(head,font,attr)
    end
  end
  return head,false
end
registerotffeature {
  name="analyze",
  description="analysis of character classes",
  default=true,
  initializers={
    node=analyzeinitializer,
  },
  processors={
    position=1,
    node=analyzeprocessor,
  }
}
methods.latn=analyzers.setstate
local arab_warned={}
local function warning(current,what)
  local char=getchar(current)
  if not arab_warned[char] then
    log.report("analyze","arab: character %C has no %a class",char,what)
    arab_warned[char]=true
  end
end
local mappers=allocate {
  l=s_init,
  d=s_medi,
  c=s_medi,
  r=s_fina,
  u=s_isol,
}
local classifiers=characters.classifiers
if not classifiers then
  local f_arabic,l_arabic=characters.blockrange("arabic")
  local f_syriac,l_syriac=characters.blockrange("syriac")
  local f_mandiac,l_mandiac=characters.blockrange("mandiac")
  local f_nko,l_nko=characters.blockrange("nko")
  local f_ext_a,l_ext_a=characters.blockrange("arabicextendeda")
  classifiers=table.setmetatableindex(function(t,k)
    if type(k)=="number" then
      local c=chardata[k]
      local v=false
      if c then
        local arabic=c.arabic
        if arabic then
          v=mappers[arabic]
          if not v then
            log.report("analyze","error in mapping arabic %C",k)
            v=false
          end
        elseif (k>=f_arabic and k<=l_arabic) or
            (k>=f_syriac and k<=l_syriac) or
            (k>=f_mandiac and k<=l_mandiac) or
            (k>=f_nko   and k<=l_nko)   or
            (k>=f_ext_a  and k<=l_ext_a)  then
          if categories[k]=="mn" then
            v=s_mark
          else
            v=s_rest
          end
        end
      end
      t[k]=v
      return v
    end
  end)
  characters.classifiers=classifiers
end
function methods.arab(head,font,attr)
  local first,last=nil,nil
  local c_first,c_last=nil,nil
  local current,done=head,false
  current=tonut(current)
  while current do
    local char,id=ischar(current,font)
    if char and not getprop(current,a_state) then
      done=true
      local classifier=classifiers[char]
      if not classifier then
        if last then
          if c_last==s_medi or c_last==s_fina then
            setprop(last,a_state,s_fina)
          else
            warning(last,"fina")
            setprop(last,a_state,s_error)
          end
          first,last=nil,nil
        elseif first then
          if c_first==s_medi or c_first==s_fina then
            setprop(first,a_state,s_isol)
          else
            warning(first,"isol")
            setprop(first,a_state,s_error)
          end
          first=nil
        end
      elseif classifier==s_mark then
        setprop(current,a_state,s_mark)
      elseif classifier==s_isol then
        if last then
          if c_last==s_medi or c_last==s_fina then
            setprop(last,a_state,s_fina)
          else
            warning(last,"fina")
            setprop(last,a_state,s_error)
          end
          first,last=nil,nil
        elseif first then
          if c_first==s_medi or c_first==s_fina then
            setprop(first,a_state,s_isol)
          else
            warning(first,"isol")
            setprop(first,a_state,s_error)
          end
          first=nil
        end
        setprop(current,a_state,s_isol)
      elseif classifier==s_medi then
        if first then
          last=current
          c_last=classifier
          setprop(current,a_state,s_medi)
        else
          setprop(current,a_state,s_init)
          first=current
          c_first=classifier
        end
      elseif classifier==s_fina then
        if last then
          if getprop(last,a_state)~=s_init then
            setprop(last,a_state,s_medi)
          end
          setprop(current,a_state,s_fina)
          first,last=nil,nil
        elseif first then
          setprop(current,a_state,s_fina)
          first=nil
        else
          setprop(current,a_state,s_isol)
        end
      else 
        setprop(current,a_state,s_rest)
        if last then
          if c_last==s_medi or c_last==s_fina then
            setprop(last,a_state,s_fina)
          else
            warning(last,"fina")
            setprop(last,a_state,s_error)
          end
          first,last=nil,nil
        elseif first then
          if c_first==s_medi or c_first==s_fina then
            setprop(first,a_state,s_isol)
          else
            warning(first,"isol")
            setprop(first,a_state,s_error)
          end
          first=nil
        end
      end
    else
      if last then
        if c_last==s_medi or c_last==s_fina then
          setprop(last,a_state,s_fina)
        else
          warning(last,"fina")
          setprop(last,a_state,s_error)
        end
        first,last=nil,nil
      elseif first then
        if c_first==s_medi or c_first==s_fina then
          setprop(first,a_state,s_isol)
        else
          warning(first,"isol")
          setprop(first,a_state,s_error)
        end
        first=nil
      end
      if id==math_code then 
        current=end_of_math(current)
      end
    end
    current=getnext(current)
  end
  if last then
    if c_last==s_medi or c_last==s_fina then
      setprop(last,a_state,s_fina)
    else
      warning(last,"fina")
      setprop(last,a_state,s_error)
    end
  elseif first then
    if c_first==s_medi or c_first==s_fina then
      setprop(first,a_state,s_isol)
    else
      warning(first,"isol")
      setprop(first,a_state,s_error)
    end
  end
  return head,done
end
methods.syrc=methods.arab
methods.mand=methods.arab
methods.nko=methods.arab
directives.register("otf.analyze.useunicodemarks",function(v)
  analyzers.useunicodemarks=v
end)

end --- [luaotfload, fontloader-2018-10-08.lua scope for “font-ota”] ---


do  --- [luaotfload, fontloader-2018-10-08.lua scope for “font-ots” 624f23e63b7430a51212c8824d09924f] ---

if not modules then modules={} end modules ['font-ots']={ 
  version=1.001,
  comment="companion to font-ini.mkiv",
  author="Hans Hagen, PRAGMA-ADE, Hasselt NL",
  copyright="PRAGMA ADE / ConTeXt Development Team",
  license="see context related readme files",
}
local type,next,tonumber=type,next,tonumber
local random=math.random
local formatters=string.formatters
local insert=table.insert
local registertracker=trackers.register
local logs=logs
local trackers=trackers
local nodes=nodes
local attributes=attributes
local fonts=fonts
local otf=fonts.handlers.otf
local tracers=nodes.tracers
local trace_singles=false registertracker("otf.singles",function(v) trace_singles=v end)
local trace_multiples=false registertracker("otf.multiples",function(v) trace_multiples=v end)
local trace_alternatives=false registertracker("otf.alternatives",function(v) trace_alternatives=v end)
local trace_ligatures=false registertracker("otf.ligatures",function(v) trace_ligatures=v end)
local trace_contexts=false registertracker("otf.contexts",function(v) trace_contexts=v end)
local trace_marks=false registertracker("otf.marks",function(v) trace_marks=v end)
local trace_kerns=false registertracker("otf.kerns",function(v) trace_kerns=v end)
local trace_cursive=false registertracker("otf.cursive",function(v) trace_cursive=v end)
local trace_preparing=false registertracker("otf.preparing",function(v) trace_preparing=v end)
local trace_bugs=false registertracker("otf.bugs",function(v) trace_bugs=v end)
local trace_details=false registertracker("otf.details",function(v) trace_details=v end)
local trace_steps=false registertracker("otf.steps",function(v) trace_steps=v end)
local trace_skips=false registertracker("otf.skips",function(v) trace_skips=v end)
local trace_plugins=false registertracker("otf.plugins",function(v) trace_plugins=v end)
local trace_chains=false registertracker("otf.chains",function(v) trace_chains=v end)
local trace_kernruns=false registertracker("otf.kernruns",function(v) trace_kernruns=v end)
local trace_compruns=false registertracker("otf.compruns",function(v) trace_compruns=v end)
local trace_testruns=false registertracker("otf.testruns",function(v) trace_testruns=v end)
local forcediscretionaries=false
local forcepairadvance=false 
directives.register("otf.forcediscretionaries",function(v)
  forcediscretionaries=v
end)
directives.register("otf.forcepairadvance",function(v)
  forcepairadvance=v
end)
local report_direct=logs.reporter("fonts","otf direct")
local report_subchain=logs.reporter("fonts","otf subchain")
local report_chain=logs.reporter("fonts","otf chain")
local report_process=logs.reporter("fonts","otf process")
local report_warning=logs.reporter("fonts","otf warning")
local report_run=logs.reporter("fonts","otf run")
registertracker("otf.substitutions","otf.singles","otf.multiples","otf.alternatives","otf.ligatures")
registertracker("otf.positions","otf.marks","otf.kerns","otf.cursive")
registertracker("otf.actions","otf.substitutions","otf.positions")
registertracker("otf.sample","otf.steps","otf.substitutions","otf.positions","otf.analyzing")
registertracker("otf.sample.silent","otf.steps=silent","otf.substitutions","otf.positions","otf.analyzing")
local nuts=nodes.nuts
local getfield=nuts.getfield
local getnext=nuts.getnext
local setnext=nuts.setnext
local getprev=nuts.getprev
local setprev=nuts.setprev
local getboth=nuts.getboth
local setboth=nuts.setboth
local getid=nuts.getid
local getattr=nuts.getattr
local setattr=nuts.setattr
local getprop=nuts.getprop
local setprop=nuts.setprop
local getfont=nuts.getfont
local getsubtype=nuts.getsubtype
local setsubtype=nuts.setsubtype
local getchar=nuts.getchar
local setchar=nuts.setchar
local getdisc=nuts.getdisc
local setdisc=nuts.setdisc
local setlink=nuts.setlink
local getcomponents=nuts.getcomponents 
local setcomponents=nuts.setcomponents 
local getdir=nuts.getdir
local getwidth=nuts.getwidth
local ischar=nuts.is_char
local usesfont=nuts.uses_font
local insert_node_after=nuts.insert_after
local copy_node=nuts.copy
local copy_node_list=nuts.copy_list
local remove_node=nuts.remove
local find_node_tail=nuts.tail
local flush_node_list=nuts.flush_list
local flush_node=nuts.flush_node
local end_of_math=nuts.end_of_math
local set_components=nuts.set_components
local take_components=nuts.take_components
local count_components=nuts.count_components
local copy_no_components=nuts.copy_no_components
local copy_only_glyphs=nuts.copy_only_glyphs
local setmetatable=setmetatable
local setmetatableindex=table.setmetatableindex
local nextnode=nuts.traversers.node
local nodecodes=nodes.nodecodes
local glyphcodes=nodes.glyphcodes
local disccodes=nodes.disccodes
local glyph_code=nodecodes.glyph
local glue_code=nodecodes.glue
local disc_code=nodecodes.disc
local math_code=nodecodes.math
local dir_code=nodecodes.dir
local localpar_code=nodecodes.localpar
local discretionary_code=disccodes.discretionary
local ligature_code=glyphcodes.ligature
local a_state=attributes.private('state')
local a_noligature=attributes.private("noligature")
local injections=nodes.injections
local setmark=injections.setmark
local setcursive=injections.setcursive
local setkern=injections.setkern
local setmove=injections.setmove
local setposition=injections.setposition
local resetinjection=injections.reset
local copyinjection=injections.copy
local setligaindex=injections.setligaindex
local getligaindex=injections.getligaindex
local fontdata=fonts.hashes.identifiers
local fontfeatures=fonts.hashes.features
local otffeatures=fonts.constructors.features.otf
local registerotffeature=otffeatures.register
local onetimemessage=fonts.loggers.onetimemessage or function() end
local getrandom=utilities and utilities.randomizer and utilities.randomizer.get
otf.defaultnodealternate="none"
local tfmdata=false
local characters=false
local descriptions=false
local marks=false
local classes=false
local currentfont=false
local factor=0
local threshold=0
local checkmarks=false
local discs=false
local spaces=false
local sweepnode=nil
local sweephead={} 
local notmatchpre={} 
local notmatchpost={} 
local notmatchreplace={} 
local handlers={}
local isspace=injections.isspace
local getthreshold=injections.getthreshold
local checkstep=(tracers and tracers.steppers.check)  or function() end
local registerstep=(tracers and tracers.steppers.register) or function() end
local registermessage=(tracers and tracers.steppers.message) or function() end
local function logprocess(...)
  if trace_steps then
    registermessage(...)
    if trace_steps=="silent" then
      return
    end
  end
  report_direct(...)
end
local function logwarning(...)
  report_direct(...)
end
local gref do
  local f_unicode=formatters["U+%X"]   
  local f_uniname=formatters["U+%X (%s)"] 
  local f_unilist=formatters["% t"]
  gref=function(n) 
    if type(n)=="number" then
      local description=descriptions[n]
      local name=description and description.name
      if name then
        return f_uniname(n,name)
      else
        return f_unicode(n)
      end
    elseif n then
      local t={}
      for i=1,#n do
        local ni=n[i]
        if tonumber(ni) then 
          local di=descriptions[ni]
          local nn=di and di.name
          if nn then
            t[#t+1]=f_uniname(ni,nn)
          else
            t[#t+1]=f_unicode(ni)
          end
        end
      end
      return f_unilist(t)
    else
      return "<error in node mode tracing>"
    end
  end
end
local function cref(dataset,sequence,index)
  if not dataset then
    return "no valid dataset"
  end
  local merged=sequence.merged and "merged " or ""
  if index then
    return formatters["feature %a, type %a, %schain lookup %a, index %a"](
      dataset[4],sequence.type,merged,sequence.name,index)
  else
    return formatters["feature %a, type %a, %schain lookup %a"](
      dataset[4],sequence.type,merged,sequence.name)
  end
end
local function pref(dataset,sequence)
  return formatters["feature %a, type %a, %slookup %a"](
    dataset[4],sequence.type,sequence.merged and "merged " or "",sequence.name)
end
local function mref(rlmode)
  if not rlmode or rlmode>=0 then
    return "l2r"
  else
    return "r2l"
  end
end
local function flattendisk(head,disc)
  local pre,post,replace,pretail,posttail,replacetail=getdisc(disc,true)
  local prev,next=getboth(disc)
  local ishead=head==disc
  setdisc(disc)
  flush_node(disc)
  if pre then
    flush_node_list(pre)
  end
  if post then
    flush_node_list(post)
  end
  if ishead then
    if replace then
      if next then
        setlink(replacetail,next)
      end
      return replace,replace
    elseif next then
      return next,next
    else
    end
  else
    if replace then
      if next then
        setlink(replacetail,next)
      end
      setlink(prev,replace)
      return head,replace
    else
      setlink(prev,next) 
      return head,next
    end
  end
end
local function appenddisc(disc,list)
  local pre,post,replace,pretail,posttail,replacetail=getdisc(disc,true)
  local posthead=list
  local replacehead=copy_node_list(list)
  if post then
    setlink(posttail,posthead)
  else
    post=posthead
  end
  if replace then
    setlink(replacetail,replacehead)
  else
    replace=replacehead
  end
  setdisc(disc,pre,post,replace)
end
local take_components=getcomponents 
local set_components=setcomponents
local function count_components(start,marks)
  if getid(start)~=glyph_code then
    return 0
  elseif getsubtype(start)==ligature_code then
    local i=0
    local components=getcomponents(start)
    while components do
      i=i+count_components(components,marks)
      components=getnext(components)
    end
    return i
  elseif not marks[getchar(start)] then
    return 1
  else
    return 0
  end
end
local function markstoligature(head,start,stop,char)
  if start==stop and getchar(start)==char then
    return head,start
  else
    local prev=getprev(start)
    local next=getnext(stop)
    setprev(start)
    setnext(stop)
    local base=copy_no_components(start,copyinjection)
    if head==start then
      head=base
    end
    resetinjection(base)
    setchar(base,char)
    setsubtype(base,ligature_code)
    set_components(base,start)
    setlink(prev,base,next)
    return head,base
  end
end
local function toligature(head,start,stop,char,dataset,sequence,skiphash,discfound,hasmarks) 
  if getattr(start,a_noligature)==1 then
    return head,start
  end
  if start==stop and getchar(start)==char then
    resetinjection(start)
    setchar(start,char)
    return head,start
  end
  local prev=getprev(start)
  local next=getnext(stop)
  local comp=start
  setprev(start)
  setnext(stop)
  local base=copy_no_components(start,copyinjection)
  if start==head then
    head=base
  end
  resetinjection(base)
  setchar(base,char)
  setsubtype(base,ligature_code)
  set_components(base,comp)
  setlink(prev,base,next)
  if not discfound then
    local deletemarks=not skiphash or hasmarks
    local components=start
    local baseindex=0
    local componentindex=0
    local head=base
    local current=base
    while start do
      local char=getchar(start)
      if not marks[char] then
        baseindex=baseindex+componentindex
        componentindex=count_components(start,marks)
      elseif not deletemarks then
        setligaindex(start,baseindex+getligaindex(start,componentindex))
        if trace_marks then
          logwarning("%s: keep mark %s, gets index %s",pref(dataset,sequence),gref(char),getligaindex(start))
        end
        local n=copy_node(start)
        copyinjection(n,start) 
        head,current=insert_node_after(head,current,n) 
      elseif trace_marks then
        logwarning("%s: delete mark %s",pref(dataset,sequence),gref(char))
      end
      start=getnext(start)
    end
    local start=getnext(current)
    while start do
      local char=ischar(start)
      if char then
        if marks[char] then
          setligaindex(start,baseindex+getligaindex(start,componentindex))
          if trace_marks then
            logwarning("%s: set mark %s, gets index %s",pref(dataset,sequence),gref(char),getligaindex(start))
          end
          start=getnext(start)
        else
          break
        end
      else
        break
      end
    end
  else
    local discprev,discnext=getboth(discfound)
    if discprev and discnext then
      local pre,post,replace,pretail,posttail,replacetail=getdisc(discfound,true)
      if not replace then
        local prev=getprev(base)
        local comp=take_components(base)
        local copied=copy_only_glyphs(comp)
        if pre then
          setlink(discprev,pre)
        else
          setnext(discprev) 
        end
        pre=comp
        if post then
          setlink(posttail,discnext)
          setprev(post)
        else
          post=discnext
          setprev(discnext) 
        end
        setlink(prev,discfound,next)
        setboth(base)
        set_components(base,copied)
        replace=base
        if forcediscretionaries then
          setdisc(discfound,pre,post,replace,discretionary_code)
        else
          setdisc(discfound,pre,post,replace)
        end
        base=prev
      end
    end
  end
  return head,base
end
local function multiple_glyphs(head,start,multiple,skiphash,what,stop) 
  local nofmultiples=#multiple
  if nofmultiples>0 then
    resetinjection(start)
    setchar(start,multiple[1])
    if nofmultiples>1 then
      local sn=getnext(start)
      for k=2,nofmultiples do
        local n=copy_node(start) 
        resetinjection(n)
        setchar(n,multiple[k])
        insert_node_after(head,start,n)
        start=n
      end
      if what==true then
      elseif what>1 then
        local m=multiple[nofmultiples]
        for i=2,what do
          local n=copy_node(start) 
          resetinjection(n)
          setchar(n,m)
          insert_node_after(head,start,n)
          start=n
        end
      end
    end
    return head,start,true
  else
    if trace_multiples then
      logprocess("no multiple for %s",gref(getchar(start)))
    end
    return head,start,false
  end
end
local function get_alternative_glyph(start,alternatives,value)
  local n=#alternatives
  if n==1 then
    return alternatives[1],trace_alternatives and "1 (only one present)"
  elseif value=="random" then
    local r=getrandom and getrandom("glyph",1,n) or random(1,n)
    return alternatives[r],trace_alternatives and formatters["value %a, taking %a"](value,r)
  elseif value=="first" then
    return alternatives[1],trace_alternatives and formatters["value %a, taking %a"](value,1)
  elseif value=="last" then
    return alternatives[n],trace_alternatives and formatters["value %a, taking %a"](value,n)
  end
  value=value==true and 1 or tonumber(value)
  if type(value)~="number" then
    return alternatives[1],trace_alternatives and formatters["invalid value %s, taking %a"](value,1)
  end
  if value>n then
    local defaultalt=otf.defaultnodealternate
    if defaultalt=="first" then
      return alternatives[n],trace_alternatives and formatters["invalid value %s, taking %a"](value,1)
    elseif defaultalt=="last" then
      return alternatives[1],trace_alternatives and formatters["invalid value %s, taking %a"](value,n)
    else
      return false,trace_alternatives and formatters["invalid value %a, %s"](value,"out of range")
    end
  elseif value==0 then
    return getchar(start),trace_alternatives and formatters["invalid value %a, %s"](value,"no change")
  elseif value<1 then
    return alternatives[1],trace_alternatives and formatters["invalid value %a, taking %a"](value,1)
  else
    return alternatives[value],trace_alternatives and formatters["value %a, taking %a"](value,value)
  end
end
function handlers.gsub_single(head,start,dataset,sequence,replacement)
  if trace_singles then
    logprocess("%s: replacing %s by single %s",pref(dataset,sequence),gref(getchar(start)),gref(replacement))
  end
  resetinjection(start)
  setchar(start,replacement)
  return head,start,true
end
function handlers.gsub_alternate(head,start,dataset,sequence,alternative)
  local kind=dataset[4]
  local what=dataset[1]
  local value=what==true and tfmdata.shared.features[kind] or what
  local choice,comment=get_alternative_glyph(start,alternative,value)
  if choice then
    if trace_alternatives then
      logprocess("%s: replacing %s by alternative %a to %s, %s",pref(dataset,sequence),gref(getchar(start)),gref(choice),comment)
    end
    resetinjection(start)
    setchar(start,choice)
  else
    if trace_alternatives then
      logwarning("%s: no variant %a for %s, %s",pref(dataset,sequence),value,gref(getchar(start)),comment)
    end
  end
  return head,start,true
end
function handlers.gsub_multiple(head,start,dataset,sequence,multiple,rlmode,skiphash)
  if trace_multiples then
    logprocess("%s: replacing %s by multiple %s",pref(dataset,sequence),gref(getchar(start)),gref(multiple))
  end
  return multiple_glyphs(head,start,multiple,skiphash,dataset[1])
end
function handlers.gsub_ligature(head,start,dataset,sequence,ligature,rlmode,skiphash)
  local current=getnext(start)
  if not current then
    return head,start,false,nil
  end
  local stop=nil
  local startchar=getchar(start)
  if skiphash and skiphash[startchar] then
    while current do
      local char=ischar(current,currentfont)
      if char then
        local lg=ligature[char]
        if lg then
          stop=current
          ligature=lg
          current=getnext(current)
        else
          break
        end
      else
        break
      end
    end
    if stop then
      local lig=ligature.ligature
      if lig then
        if trace_ligatures then
          local stopchar=getchar(stop)
          head,start=markstoligature(head,start,stop,lig)
          logprocess("%s: replacing %s upto %s by ligature %s case 1",pref(dataset,sequence),gref(startchar),gref(stopchar),gref(getchar(start)))
        else
          head,start=markstoligature(head,start,stop,lig)
        end
        return head,start,true,false
      else
      end
    end
  else 
    local discfound=false
    local lastdisc=nil
    local hasmarks=marks[startchar]
    while current do
      local char,id=ischar(current,currentfont)
      if char then
        if skiphash and skiphash[char] then
          current=getnext(current)
        else 
          local lg=ligature[char] 
          if lg then
            if not discfound and lastdisc then
              discfound=lastdisc
              lastdisc=nil
            end
            if marks[char] then
              hasmarks=true
            end
            stop=current 
            ligature=lg
            current=getnext(current)
          else
            break
          end
        end
      elseif char==false then
        break
      elseif id==disc_code then
        local replace=getfield(current,"replace") 
        if replace then
          while replace do
            local char,id=ischar(replace,currentfont)
            if char then
              local lg=ligature[char] 
              if lg then
                if marks[char] then
                  hasmarks=true 
                end
                ligature=lg
                replace=getnext(replace)
              else
                return head,start,false,false
              end
            else
              return head,start,false,false
            end
          end
          stop=current
        end
        lastdisc=current
        current=getnext(current)
      else
        break
      end
    end
    local lig=ligature.ligature
    if lig then
      if stop then
        if trace_ligatures then
          local stopchar=getchar(stop)
          head,start=toligature(head,start,stop,lig,dataset,sequence,skiphash,discfound,hasmarks)
          logprocess("%s: replacing %s upto %s by ligature %s case 2",pref(dataset,sequence),gref(startchar),gref(stopchar),gref(lig))
        else
          head,start=toligature(head,start,stop,lig,dataset,sequence,skiphash,discfound,hasmarks)
        end
      else
        resetinjection(start)
        setchar(start,lig)
        if trace_ligatures then
          logprocess("%s: replacing %s by (no real) ligature %s case 3",pref(dataset,sequence),gref(startchar),gref(lig))
        end
      end
      return head,start,true,discfound
    else
    end
  end
  return head,start,false,discfound
end
function handlers.gpos_single(head,start,dataset,sequence,kerns,rlmode,skiphash,step,injection)
  local startchar=getchar(start)
  local format=step.format
  if format=="single" or type(kerns)=="table" then 
    local dx,dy,w,h=setposition(0,start,factor,rlmode,kerns,injection)
    if trace_kerns then
      logprocess("%s: shifting single %s by %s xy (%p,%p) and wh (%p,%p)",pref(dataset,sequence),gref(startchar),format,dx,dy,w,h)
    end
  else
    local k=(format=="move" and setmove or setkern)(start,factor,rlmode,kerns,injection)
    if trace_kerns then
      logprocess("%s: shifting single %s by %s %p",pref(dataset,sequence),gref(startchar),format,k)
    end
  end
  return head,start,true
end
function handlers.gpos_pair(head,start,dataset,sequence,kerns,rlmode,skiphash,step,injection)
  local snext=getnext(start)
  if not snext then
    return head,start,false
  else
    local prev=start
    while snext do
      local nextchar=ischar(snext,currentfont)
      if nextchar then
        if skiphash and skiphash[nextchar] then 
          prev=snext
          snext=getnext(snext)
        else
          local krn=kerns[nextchar]
          if not krn then
            break
          end
          local format=step.format
          if format=="pair" then
            local a,b=krn[1],krn[2]
            if a==true then
            elseif a then 
              local x,y,w,h=setposition(1,start,factor,rlmode,a,injection)
              if trace_kerns then
                local startchar=getchar(start)
                logprocess("%s: shifting first of pair %s and %s by xy (%p,%p) and wh (%p,%p) as %s",pref(dataset,sequence),gref(startchar),gref(nextchar),x,y,w,h,injection or "injections")
              end
            end
            if b==true then
              start=snext 
            elseif b then 
              local x,y,w,h=setposition(2,snext,factor,rlmode,b,injection)
              if trace_kerns then
                local startchar=getchar(start)
                logprocess("%s: shifting second of pair %s and %s by xy (%p,%p) and wh (%p,%p) as %s",pref(dataset,sequence),gref(startchar),gref(nextchar),x,y,w,h,injection or "injections")
              end
              start=snext 
            elseif forcepairadvance then
              start=snext 
            end
            return head,start,true
          elseif krn~=0 then
            local k=(format=="move" and setmove or setkern)(snext,factor,rlmode,krn,injection)
            if trace_kerns then
              logprocess("%s: inserting %s %p between %s and %s as %s",pref(dataset,sequence),format,k,gref(getchar(prev)),gref(nextchar),injection or "injections")
            end
            return head,start,true
          else 
            break
          end
        end
      else
        break
      end
    end
    return head,start,false
  end
end
function handlers.gpos_mark2base(head,start,dataset,sequence,markanchors,rlmode,skiphash)
  local markchar=getchar(start)
  if marks[markchar] then
    local base=getprev(start) 
    if base then
      local basechar=ischar(base,currentfont)
      if basechar then
        if marks[basechar] then
          while base do
            base=getprev(base)
            if base then
              basechar=ischar(base,currentfont)
              if basechar then
                if not marks[basechar] then
                  break
                end
              else
                if trace_bugs then
                  logwarning("%s: no base for mark %s, case %i",pref(dataset,sequence),gref(markchar),1)
                end
                return head,start,false
              end
            else
              if trace_bugs then
                logwarning("%s: no base for mark %s, case %i",pref(dataset,sequence),gref(markchar),2)
              end
              return head,start,false
            end
          end
        end
        local ba=markanchors[1][basechar]
        if ba then
          local ma=markanchors[2]
          local dx,dy,bound=setmark(start,base,factor,rlmode,ba,ma,characters[basechar],false,checkmarks)
          if trace_marks then
            logprocess("%s, bound %s, anchoring mark %s to basechar %s => (%p,%p)",
              pref(dataset,sequence),bound,gref(markchar),gref(basechar),dx,dy)
          end
          return head,start,true
        elseif trace_bugs then
          logwarning("%s: mark %s is not anchored to %s",pref(dataset,sequence),gref(markchar),gref(basechar))
        end
      elseif trace_bugs then
        logwarning("%s: nothing preceding, case %i",pref(dataset,sequence),1)
      end
    elseif trace_bugs then
      logwarning("%s: nothing preceding, case %i",pref(dataset,sequence),2)
    end
  elseif trace_bugs then
    logwarning("%s: mark %s is no mark",pref(dataset,sequence),gref(markchar))
  end
  return head,start,false
end
function handlers.gpos_mark2ligature(head,start,dataset,sequence,markanchors,rlmode,skiphash)
  local markchar=getchar(start)
  if marks[markchar] then
    local base=getprev(start) 
    if base then
      local basechar=ischar(base,currentfont)
      if basechar then
        if marks[basechar] then
          while base do
            base=getprev(base)
            if base then
              basechar=ischar(base,currentfont)
              if basechar then
                if not marks[basechar] then
                  break
                end
              else
                if trace_bugs then
                  logwarning("%s: no base for mark %s, case %i",pref(dataset,sequence),gref(markchar),1)
                end
                return head,start,false
              end
            else
              if trace_bugs then
                logwarning("%s: no base for mark %s, case %i",pref(dataset,sequence),gref(markchar),2)
              end
              return head,start,false
            end
          end
        end
        local ba=markanchors[1][basechar]
        if ba then
          local ma=markanchors[2]
          if ma then
            local index=getligaindex(start)
            ba=ba[index]
            if ba then
              local dx,dy,bound=setmark(start,base,factor,rlmode,ba,ma,characters[basechar],false,checkmarks)
              if trace_marks then
                logprocess("%s, index %s, bound %s, anchoring mark %s to baselig %s at index %s => (%p,%p)",
                  pref(dataset,sequence),index,bound,gref(markchar),gref(basechar),index,dx,dy)
              end
              return head,start,true
            else
              if trace_bugs then
                logwarning("%s: no matching anchors for mark %s and baselig %s with index %a",pref(dataset,sequence),gref(markchar),gref(basechar),index)
              end
            end
          end
        elseif trace_bugs then
          onetimemessage(currentfont,basechar,"no base anchors",report_fonts)
        end
      elseif trace_bugs then
        logwarning("%s: prev node is no char, case %i",pref(dataset,sequence),1)
      end
    elseif trace_bugs then
      logwarning("%s: prev node is no char, case %i",pref(dataset,sequence),2)
    end
  elseif trace_bugs then
    logwarning("%s: mark %s is no mark",pref(dataset,sequence),gref(markchar))
  end
  return head,start,false
end
function handlers.gpos_mark2mark(head,start,dataset,sequence,markanchors,rlmode,skiphash)
  local markchar=getchar(start)
  if marks[markchar] then
    local base=getprev(start) 
    local slc=getligaindex(start)
    if slc then 
      while base do
        local blc=getligaindex(base)
        if blc and blc~=slc then
          base=getprev(base)
        else
          break
        end
      end
    end
    if base then
      local basechar=ischar(base,currentfont)
      if basechar then 
        local ba=markanchors[1][basechar] 
        if ba then
          local ma=markanchors[2]
          local dx,dy,bound=setmark(start,base,factor,rlmode,ba,ma,characters[basechar],true,checkmarks)
          if trace_marks then
            logprocess("%s, bound %s, anchoring mark %s to basemark %s => (%p,%p)",
              pref(dataset,sequence),bound,gref(markchar),gref(basechar),dx,dy)
          end
          return head,start,true
        end
      end
    end
  elseif trace_bugs then
    logwarning("%s: mark %s is no mark",pref(dataset,sequence),gref(markchar))
  end
  return head,start,false
end
function handlers.gpos_cursive(head,start,dataset,sequence,exitanchors,rlmode,skiphash,step) 
  local startchar=getchar(start)
  if marks[startchar] then
    if trace_cursive then
      logprocess("%s: ignoring cursive for mark %s",pref(dataset,sequence),gref(startchar))
    end
  else
    local nxt=getnext(start)
    while nxt do
      local nextchar=ischar(nxt,currentfont)
      if not nextchar then
        break
      elseif marks[nextchar] then 
        nxt=getnext(nxt)
      else
        local exit=exitanchors[3]
        if exit then
          local entry=exitanchors[1][nextchar]
          if entry then
            entry=entry[2]
            if entry then
              local r2lflag=sequence.flags[4] 
              local dx,dy,bound=setcursive(start,nxt,factor,rlmode,exit,entry,characters[startchar],characters[nextchar],r2lflag)
              if trace_cursive then
                logprocess("%s: moving %s to %s cursive (%p,%p) using bound %s in %s mode",pref(dataset,sequence),gref(startchar),gref(nextchar),dx,dy,bound,mref(rlmode))
              end
              return head,start,true
            end
          end
        end
        break
      end
    end
  end
  return head,start,false
end
local chainprocs={}
local function logprocess(...)
  if trace_steps then
    registermessage(...)
    if trace_steps=="silent" then
      return
    end
  end
  report_subchain(...)
end
local logwarning=report_subchain
local function logprocess(...)
  if trace_steps then
    registermessage(...)
    if trace_steps=="silent" then
      return
    end
  end
  report_chain(...)
end
local logwarning=report_chain
local function reversesub(head,start,stop,dataset,sequence,replacements,rlmode,skiphash)
  local char=getchar(start)
  local replacement=replacements[char]
  if replacement then
    if trace_singles then
      logprocess("%s: single reverse replacement of %s by %s",cref(dataset,sequence),gref(char),gref(replacement))
    end
    resetinjection(start)
    setchar(start,replacement)
    return head,start,true
  else
    return head,start,false
  end
end
chainprocs.reversesub=reversesub
local function reportzerosteps(dataset,sequence)
  logwarning("%s: no steps",cref(dataset,sequence))
end
local function reportmoresteps(dataset,sequence)
  logwarning("%s: more than 1 step",cref(dataset,sequence))
end
local function getmapping(dataset,sequence,currentlookup)
  local steps=currentlookup.steps
  local nofsteps=currentlookup.nofsteps
  if nofsteps==0 then
    reportzerosteps(dataset,sequence)
    currentlookup.mapping=false
    return false
  else
    if nofsteps>1 then
      reportmoresteps(dataset,sequence)
    end
    local mapping=steps[1].coverage
    currentlookup.mapping=mapping
    currentlookup.format=steps[1].format
    return mapping
  end
end
function chainprocs.gsub_remove(head,start,stop,dataset,sequence,currentlookup,rlmode,skiphash,chainindex)
  if trace_chains then
    logprocess("%s: removing character %s",cref(dataset,sequence,chainindex),gref(getchar(start)))
  end
  head,start=remove_node(head,start,true)
  return head,getprev(start),true
end
function chainprocs.gsub_single(head,start,stop,dataset,sequence,currentlookup,rlmode,skiphash,chainindex)
  local mapping=currentlookup.mapping
  if mapping==nil then
    mapping=getmapping(dataset,sequence,currentlookup)
  end
  if mapping then
    local current=start
    while current do
      local currentchar=ischar(current)
      if currentchar then
        local replacement=mapping[currentchar]
        if not replacement or replacement=="" then
          if trace_bugs then
            logwarning("%s: no single for %s",cref(dataset,sequence,chainindex),gref(currentchar))
          end
        else
          if trace_singles then
            logprocess("%s: replacing single %s by %s",cref(dataset,sequence,chainindex),gref(currentchar),gref(replacement))
          end
          resetinjection(current)
          setchar(current,replacement)
        end
        return head,start,true
      elseif currentchar==false then
        break
      elseif current==stop then
        break
      else
        current=getnext(current)
      end
    end
  end
  return head,start,false
end
function chainprocs.gsub_alternate(head,start,stop,dataset,sequence,currentlookup,rlmode,skiphash,chainindex)
  local mapping=currentlookup.mapping
  if mapping==nil then
    mapping=getmapping(dataset,sequence,currentlookup)
  end
  if mapping then
    local kind=dataset[4]
    local what=dataset[1]
    local value=what==true and tfmdata.shared.features[kind] or what 
    local current=start
    while current do
      local currentchar=ischar(current)
      if currentchar then
        local alternatives=mapping[currentchar]
        if alternatives then
          local choice,comment=get_alternative_glyph(current,alternatives,value)
          if choice then
            if trace_alternatives then
              logprocess("%s: replacing %s by alternative %a to %s, %s",cref(dataset,sequence),gref(currentchar),choice,gref(choice),comment)
            end
            resetinjection(start)
            setchar(start,choice)
          else
            if trace_alternatives then
              logwarning("%s: no variant %a for %s, %s",cref(dataset,sequence),value,gref(currentchar),comment)
            end
          end
        end
        return head,start,true
      elseif currentchar==false then
        break
      elseif current==stop then
        break
      else
        current=getnext(current)
      end
    end
  end
  return head,start,false
end
function chainprocs.gsub_multiple(head,start,stop,dataset,sequence,currentlookup,rlmode,skiphash,chainindex)
  local mapping=currentlookup.mapping
  if mapping==nil then
    mapping=getmapping(dataset,sequence,currentlookup)
  end
  if mapping then
    local startchar=getchar(start)
    local replacement=mapping[startchar]
    if not replacement or replacement=="" then
      if trace_bugs then
        logwarning("%s: no multiple for %s",cref(dataset,sequence),gref(startchar))
      end
    else
      if trace_multiples then
        logprocess("%s: replacing %s by multiple characters %s",cref(dataset,sequence),gref(startchar),gref(replacement))
      end
      return multiple_glyphs(head,start,replacement,skiphash,dataset[1],stop)
    end
  end
  return head,start,false
end
function chainprocs.gsub_ligature(head,start,stop,dataset,sequence,currentlookup,rlmode,skiphash,chainindex)
  local mapping=currentlookup.mapping
  if mapping==nil then
    mapping=getmapping(dataset,sequence,currentlookup)
  end
  if mapping then
    local startchar=getchar(start)
    local ligatures=mapping[startchar]
    if not ligatures then
      if trace_bugs then
        logwarning("%s: no ligatures starting with %s",cref(dataset,sequence,chainindex),gref(startchar))
      end
    else
      local hasmarks=marks[startchar]
      local current=getnext(start)
      local discfound=false
      local last=stop
      local nofreplacements=1
      while current do
        local id=getid(current)
        if id==disc_code then
          if not discfound then
            discfound=current
          end
          if current==stop then
            break 
          else
            current=getnext(current)
          end
        else
          local schar=getchar(current)
          if skiphash and skiphash[schar] then
              current=getnext(current)
          else
            local lg=ligatures[schar]
            if lg then
              ligatures=lg
              last=current
              nofreplacements=nofreplacements+1
              if marks[char] then
                hasmarks=true
              end
              if current==stop then
                break
              else
                current=getnext(current)
              end
            else
              break
            end
          end
        end
      end
      local ligature=ligatures.ligature
      if ligature then
        if chainindex then
          stop=last
        end
        if trace_ligatures then
          if start==stop then
            logprocess("%s: replacing character %s by ligature %s case 3",cref(dataset,sequence,chainindex),gref(startchar),gref(ligature))
          else
            logprocess("%s: replacing character %s upto %s by ligature %s case 4",cref(dataset,sequence,chainindex),gref(startchar),gref(getchar(stop)),gref(ligature))
          end
        end
        head,start=toligature(head,start,stop,ligature,dataset,sequence,skiphash,discfound,hasmarks)
        return head,start,true,nofreplacements,discfound
      elseif trace_bugs then
        if start==stop then
          logwarning("%s: replacing character %s by ligature fails",cref(dataset,sequence,chainindex),gref(startchar))
        else
          logwarning("%s: replacing character %s upto %s by ligature fails",cref(dataset,sequence,chainindex),gref(startchar),gref(getchar(stop)))
        end
      end
    end
  end
  return head,start,false,0,false
end
function chainprocs.gpos_single(head,start,stop,dataset,sequence,currentlookup,rlmode,skiphash,chainindex)
  local mapping=currentlookup.mapping
  if mapping==nil then
    mapping=getmapping(dataset,sequence,currentlookup)
  end
  if mapping then
    local startchar=getchar(start)
    local kerns=mapping[startchar]
    if kerns then
      local format=currentlookup.format
      if format=="single" then
        local dx,dy,w,h=setposition(0,start,factor,rlmode,kerns) 
        if trace_kerns then
          logprocess("%s: shifting single %s by %s (%p,%p) and correction (%p,%p)",cref(dataset,sequence),gref(startchar),format,dx,dy,w,h)
        end
      else 
        local k=(format=="move" and setmove or setkern)(start,factor,rlmode,kerns,injection)
        if trace_kerns then
          logprocess("%s: shifting single %s by %s %p",cref(dataset,sequence),gref(startchar),format,k)
        end
      end
      return head,start,true
    end
  end
  return head,start,false
end
function chainprocs.gpos_pair(head,start,stop,dataset,sequence,currentlookup,rlmode,skiphash,chainindex) 
  local mapping=currentlookup.mapping
  if mapping==nil then
    mapping=getmapping(dataset,sequence,currentlookup)
  end
  if mapping then
    local snext=getnext(start)
    if snext then
      local startchar=getchar(start)
      local kerns=mapping[startchar] 
      if kerns then
        local prev=start
        while snext do
          local nextchar=ischar(snext,currentfont)
          if not nextchar then
            break
          end
          if skiphash and skiphash[nextchar] then
            prev=snext
            snext=getnext(snext)
          else
            local krn=kerns[nextchar]
            if not krn then
              break
            end
            local format=currentlookup.format
            if format=="pair" then
              local a,b=krn[1],krn[2]
              if a==true then
              elseif a then
                local x,y,w,h=setposition(1,start,factor,rlmode,a,"injections") 
                if trace_kerns then
                  local startchar=getchar(start)
                  logprocess("%s: shifting first of pair %s and %s by (%p,%p) and correction (%p,%p)",cref(dataset,sequence),gref(startchar),gref(nextchar),x,y,w,h)
                end
              end
              if b==true then
                start=snext 
              elseif b then 
                local x,y,w,h=setposition(2,snext,factor,rlmode,b,"injections")
                if trace_kerns then
                  local startchar=getchar(start)
                  logprocess("%s: shifting second of pair %s and %s by (%p,%p) and correction (%p,%p)",cref(dataset,sequence),gref(startchar),gref(nextchar),x,y,w,h)
                end
                start=snext 
              elseif forcepairadvance then
                start=snext 
              end
              return head,start,true
            elseif krn~=0 then
              local k=(format=="move" and setmove or setkern)(snext,factor,rlmode,krn)
              if trace_kerns then
                logprocess("%s: inserting %s %p between %s and %s",cref(dataset,sequence),format,k,gref(getchar(prev)),gref(nextchar))
              end
              return head,start,true
            else
              break
            end
          end
        end
      end
    end
  end
  return head,start,false
end
function chainprocs.gpos_mark2base(head,start,stop,dataset,sequence,currentlookup,rlmode,skiphash,chainindex)
  local mapping=currentlookup.mapping
  if mapping==nil then
    mapping=getmapping(dataset,sequence,currentlookup)
  end
  if mapping then
    local markchar=getchar(start)
    if marks[markchar] then
      local markanchors=mapping[markchar] 
      if markanchors then
        local base=getprev(start) 
        if base then
          local basechar=ischar(base,currentfont)
          if basechar then
            if marks[basechar] then
              while base do
                base=getprev(base)
                if base then
                  local basechar=ischar(base,currentfont)
                  if basechar then
                    if not marks[basechar] then
                      break
                    end
                  else
                    if trace_bugs then
                      logwarning("%s: no base for mark %s, case %i",pref(dataset,sequence),gref(markchar),1)
                    end
                    return head,start,false
                  end
                else
                  if trace_bugs then
                    logwarning("%s: no base for mark %s, case %i",pref(dataset,sequence),gref(markchar),2)
                  end
                  return head,start,false
                end
              end
            end
            local ba=markanchors[1][basechar]
            if ba then
              local ma=markanchors[2]
              if ma then
                local dx,dy,bound=setmark(start,base,factor,rlmode,ba,ma,characters[basechar],false,checkmarks)
                if trace_marks then
                  logprocess("%s, bound %s, anchoring mark %s to basechar %s => (%p,%p)",
                    cref(dataset,sequence),bound,gref(markchar),gref(basechar),dx,dy)
                end
                return head,start,true
              end
            end
          elseif trace_bugs then
            logwarning("%s: prev node is no char, case %i",cref(dataset,sequence),1)
          end
        elseif trace_bugs then
          logwarning("%s: prev node is no char, case %i",cref(dataset,sequence),2)
        end
      elseif trace_bugs then
        logwarning("%s: mark %s has no anchors",cref(dataset,sequence),gref(markchar))
      end
    elseif trace_bugs then
      logwarning("%s: mark %s is no mark",cref(dataset,sequence),gref(markchar))
    end
  end
  return head,start,false
end
function chainprocs.gpos_mark2ligature(head,start,stop,dataset,sequence,currentlookup,rlmode,skiphash,chainindex)
  local mapping=currentlookup.mapping
  if mapping==nil then
    mapping=getmapping(dataset,sequence,currentlookup)
  end
  if mapping then
    local markchar=getchar(start)
    if marks[markchar] then
      local markanchors=mapping[markchar] 
      if markanchors then
        local base=getprev(start) 
        if base then
          local basechar=ischar(base,currentfont)
          if basechar then
            if marks[basechar] then
              while base do
                base=getprev(base)
                if base then
                  local basechar=ischar(base,currentfont)
                  if basechar then
                    if not marks[basechar] then
                      break
                    end
                  else
                    if trace_bugs then
                      logwarning("%s: no base for mark %s, case %i",cref(dataset,sequence),markchar,1)
                    end
                    return head,start,false
                  end
                else
                  if trace_bugs then
                    logwarning("%s: no base for mark %s, case %i",cref(dataset,sequence),markchar,2)
                  end
                  return head,start,false
                end
              end
            end
            local ba=markanchors[1][basechar]
            if ba then
              local ma=markanchors[2]
              if ma then
                local index=getligaindex(start)
                ba=ba[index]
                if ba then
                  local dx,dy,bound=setmark(start,base,factor,rlmode,ba,ma,characters[basechar],false,checkmarks)
                  if trace_marks then
                    logprocess("%s, bound %s, anchoring mark %s to baselig %s at index %s => (%p,%p)",
                      cref(dataset,sequence),a or bound,gref(markchar),gref(basechar),index,dx,dy)
                  end
                  return head,start,true
                end
              end
            end
          elseif trace_bugs then
            logwarning("%s, prev node is no char, case %i",cref(dataset,sequence),1)
          end
        elseif trace_bugs then
          logwarning("%s, prev node is no char, case %i",cref(dataset,sequence),2)
        end
      elseif trace_bugs then
        logwarning("%s, mark %s has no anchors",cref(dataset,sequence),gref(markchar))
      end
    elseif trace_bugs then
      logwarning("%s, mark %s is no mark",cref(dataset,sequence),gref(markchar))
    end
  end
  return head,start,false
end
function chainprocs.gpos_mark2mark(head,start,stop,dataset,sequence,currentlookup,rlmode,skiphash,chainindex)
  local mapping=currentlookup.mapping
  if mapping==nil then
    mapping=getmapping(dataset,sequence,currentlookup)
  end
  if mapping then
    local markchar=getchar(start)
    if marks[markchar] then
      local markanchors=mapping[markchar] 
      if markanchors then
        local base=getprev(start) 
        local slc=getligaindex(start)
        if slc then 
          while base do
            local blc=getligaindex(base)
            if blc and blc~=slc then
              base=getprev(base)
            else
              break
            end
          end
        end
        if base then 
          local basechar=ischar(base,currentfont)
          if basechar then
            local ba=markanchors[1][basechar]
            if ba then
              local ma=markanchors[2]
              if ma then
                local dx,dy,bound=setmark(start,base,factor,rlmode,ba,ma,characters[basechar],true,checkmarks)
                if trace_marks then
                  logprocess("%s, bound %s, anchoring mark %s to basemark %s => (%p,%p)",
                    cref(dataset,sequence),bound,gref(markchar),gref(basechar),dx,dy)
                end
                return head,start,true
              end
            end
          elseif trace_bugs then
            logwarning("%s: prev node is no mark, case %i",cref(dataset,sequence),1)
          end
        elseif trace_bugs then
          logwarning("%s: prev node is no mark, case %i",cref(dataset,sequence),2)
        end
      elseif trace_bugs then
        logwarning("%s: mark %s has no anchors",cref(dataset,sequence),gref(markchar))
      end
    elseif trace_bugs then
      logwarning("%s: mark %s is no mark",cref(dataset,sequence),gref(markchar))
    end
  end
  return head,start,false
end
function chainprocs.gpos_cursive(head,start,stop,dataset,sequence,currentlookup,rlmode,skiphash,chainindex)
  local mapping=currentlookup.mapping
  if mapping==nil then
    mapping=getmapping(dataset,sequence,currentlookup)
  end
  if mapping then
    local startchar=getchar(start)
    local exitanchors=mapping[startchar] 
    if exitanchors then
      if marks[startchar] then
        if trace_cursive then
          logprocess("%s: ignoring cursive for mark %s",pref(dataset,sequence),gref(startchar))
        end
      else
        local nxt=getnext(start)
        while nxt do
          local nextchar=ischar(nxt,currentfont)
          if not nextchar then
            break
          elseif marks[nextchar] then
            nxt=getnext(nxt)
          else
            local exit=exitanchors[3]
            if exit then
              local entry=exitanchors[1][nextchar]
              if entry then
                entry=entry[2]
                if entry then
                  local r2lflag=sequence.flags[4] 
                  local dx,dy,bound=setcursive(start,nxt,factor,rlmode,exit,entry,characters[startchar],characters[nextchar],r2lflag)
                  if trace_cursive then
                    logprocess("%s: moving %s to %s cursive (%p,%p) using bound %s in %s mode",pref(dataset,sequence),gref(startchar),gref(nextchar),dx,dy,bound,mref(rlmode))
                  end
                  return head,start,true
                end
              end
            elseif trace_bugs then
              onetimemessage(currentfont,startchar,"no entry anchors",report_fonts)
            end
            break
          end
        end
      end
    elseif trace_cursive and trace_details then
      logprocess("%s, cursive %s is already done",pref(dataset,sequence),gref(getchar(start)),alreadydone)
    end
  end
  return head,start,false
end
local function show_skip(dataset,sequence,char,ck,class)
  logwarning("%s: skipping char %s, class %a, rule %a, lookuptype %a",cref(dataset,sequence),gref(char),class,ck[1],ck[8] or ck[2])
end
local userkern=nuts.pool and nuts.pool.newkern 
do if not userkern then 
  local thekern=nuts.new("kern",1) 
  local setkern=nuts.setkern    
  userkern=function(k)
    local n=copy_node(thekern)
    setkern(n,k)
    return n
  end
end end
local function checked(head)
  local current=head
  while current do
    if getid(current)==glue_code then
      local kern=userkern(getwidth(current))
      if head==current then
        local next=getnext(current)
        if next then
          setlink(kern,next)
        end
        flush_node(current)
        head=kern
        current=next
      else
        local prev,next=getboth(current)
        setlink(prev,kern,next)
        flush_node(current)
        current=next
      end
    else
      current=getnext(current)
    end
  end
  return head
end
local function setdiscchecked(d,pre,post,replace)
  if pre   then pre=checked(pre)   end
  if post  then post=checked(post)  end
  if replace then replace=checked(replace) end
  setdisc(d,pre,post,replace)
end
local noflags={ false,false,false,false }
local function chainrun(head,start,last,dataset,sequence,rlmode,skiphash,ck)
  local size=ck[5]-ck[4]+1
  local chainlookups=ck[6]
  local done=false
  if chainlookups then
    if size==1 then
      local chainlookup=chainlookups[1]
      for j=1,#chainlookup do
        local chainstep=chainlookup[j]
        local chainkind=chainstep.type
        local chainproc=chainprocs[chainkind]
        if chainproc then
          local ok
          head,start,ok=chainproc(head,start,last,dataset,sequence,chainstep,rlmode,skiphash)
          if ok then
            done=true
          end
        else
          logprocess("%s: %s is not yet supported (1)",cref(dataset,sequence),chainkind)
        end
      end
     else
      local i=1
      local laststart=start
      local nofchainlookups=#chainlookups 
      while start do
        if skiphash then 
          while start do
            local char=ischar(start,currentfont)
            if char then
              if skiphash and skiphash[char] then
                start=getnext(start)
              else
                break
              end
            else
              break
            end
          end
        end
        local chainlookup=chainlookups[i]
        if chainlookup then
          for j=1,#chainlookup do
            local chainstep=chainlookup[j]
            local chainkind=chainstep.type
            local chainproc=chainprocs[chainkind]
            if chainproc then
              local ok,n
              head,start,ok,n=chainproc(head,start,last,dataset,sequence,chainstep,rlmode,skiphash,i)
              if ok then
                done=true
                if n and n>1 and i+n>nofchainlookups then
                  i=size 
                  break
                end
              end
            else
              logprocess("%s: %s is not yet supported (2)",cref(dataset,sequence),chainkind)
            end
          end
        else
        end
        i=i+1
        if i>size or not start then
          break
        elseif start then
          laststart=start
          start=getnext(start)
        end
      end
      if not start then
        start=laststart
      end
    end
  else
    local replacements=ck[7]
    if replacements then
      head,start,done=reversesub(head,start,last,dataset,sequence,replacements,rlmode,skiphash)
    else
      done=true
      if trace_contexts then
        logprocess("%s: skipping match",cref(dataset,sequence))
      end
    end
  end
  return head,start,done
end
local function chaindisk(head,start,dataset,sequence,rlmode,skiphash,ck)
  if not start then
    return head,start,false
  end
  local startishead=start==head
  local seq=ck[3]
  local f=ck[4]
  local l=ck[5]
  local s=#seq
  local done=false
  local sweepnode=sweepnode
  local sweeptype=sweeptype
  local sweepoverflow=false
  local keepdisc=not sweepnode
  local lookaheaddisc=nil
  local backtrackdisc=nil
  local current=start
  local last=start
  local prev=getprev(start)
  local hasglue=false
  local i=f
  while i<=l do
    local id=getid(current)
    if id==glyph_code then
      i=i+1
      last=current
      current=getnext(current)
    elseif id==glue_code then
      i=i+1
      last=current
      current=getnext(current)
      hasglue=true
    elseif id==disc_code then
      if keepdisc then
        keepdisc=false
        lookaheaddisc=current
        local replace=getfield(current,"replace")
        if not replace then
          sweepoverflow=true
          sweepnode=current
          current=getnext(current)
        else
          while replace and i<=l do
            if getid(replace)==glyph_code then
              i=i+1
            end
            replace=getnext(replace)
          end
          current=getnext(replace)
        end
        last=current
      else
        head,current=flattendisk(head,current)
      end
    else
      last=current
      current=getnext(current)
    end
    if current then
    elseif sweepoverflow then
      break
    elseif sweeptype=="post" or sweeptype=="replace" then
      current=getnext(sweepnode)
      if current then
        sweeptype=nil
        sweepoverflow=true
      else
        break
      end
    else
      break 
    end
  end
  if sweepoverflow then
    local prev=current and getprev(current)
    if not current or prev~=sweepnode then
      local head=getnext(sweepnode)
      local tail=nil
      if prev then
        tail=prev
        setprev(current,sweepnode)
      else
        tail=find_node_tail(head)
      end
      setnext(sweepnode,current)
      setprev(head)
      setnext(tail)
      appenddisc(sweepnode,head)
    end
  end
  if l<s then
    local i=l
    local t=sweeptype=="post" or sweeptype=="replace"
    while current and i<s do
      local id=getid(current)
      if id==glyph_code then
        i=i+1
        current=getnext(current)
      elseif id==glue_code then
        i=i+1
        current=getnext(current)
        hasglue=true
      elseif id==disc_code then
        if keepdisc then
          keepdisc=false
          if notmatchpre[current]~=notmatchreplace[current] then
            lookaheaddisc=current
          end
          local replace=getfield(current,"replace")
          while replace and i<s do
            if getid(replace)==glyph_code then
              i=i+1
            end
            replace=getnext(replace)
          end
          current=getnext(current)
        elseif notmatchpre[current]~=notmatchreplace[current] then
          head,current=flattendisk(head,current)
        else
          current=getnext(current) 
        end
      else
        current=getnext(current)
      end
      if not current and t then
        current=getnext(sweepnode)
        if current then
          sweeptype=nil
        end
      end
    end
  end
  if f>1 then
    local current=prev
    local i=f
    local t=sweeptype=="pre" or sweeptype=="replace"
    if not current and t and current==checkdisk then
      current=getprev(sweepnode)
    end
    while current and i>1 do 
      local id=getid(current)
      if id==glyph_code then
        i=i-1
      elseif id==glue_code then
        i=i-1
        hasglue=true
      elseif id==disc_code then
        if keepdisc then
          keepdisc=false
          if notmatchpost[current]~=notmatchreplace[current] then
            backtrackdisc=current
          end
          local replace=getfield(current,"replace")
          while replace and i>1 do
            if getid(replace)==glyph_code then
              i=i-1
            end
            replace=getnext(replace)
          end
        elseif notmatchpost[current]~=notmatchreplace[current] then
          head,current=flattendisk(head,current)
        end
      end
      current=getprev(current)
      if t and current==checkdisk then
        current=getprev(sweepnode)
      end
    end
  end
  local done=false
  if lookaheaddisc then
    local cf=start
    local cl=getprev(lookaheaddisc)
    local cprev=getprev(start)
    local insertedmarks=0
    while cprev do
      local char=ischar(cf,currentfont)
      if char and marks[char] then
        insertedmarks=insertedmarks+1
        cf=cprev
        startishead=cf==head
        cprev=getprev(cprev)
      else
        break
      end
    end
    setlink(cprev,lookaheaddisc)
    setprev(cf)
    setnext(cl)
    if startishead then
      head=lookaheaddisc
    end
    local pre,post,replace=getdisc(lookaheaddisc)
    local new=copy_node_list(cf) 
    local cnew=new
    if pre then
      setlink(find_node_tail(cf),pre)
    end
    if replace then
      local tail=find_node_tail(new)
      setlink(tail,replace)
    end
    for i=1,insertedmarks do
      cnew=getnext(cnew)
    end
    cl=start
    local clast=cnew
    for i=f,l do
      cl=getnext(cl)
      clast=getnext(clast)
    end
    if not notmatchpre[lookaheaddisc] then
      local ok=false
      cf,start,ok=chainrun(cf,start,cl,dataset,sequence,rlmode,skiphash,ck)
      if ok then
        done=true
      end
    end
    if not notmatchreplace[lookaheaddisc] then
      local ok=false
      new,cnew,ok=chainrun(new,cnew,clast,dataset,sequence,rlmode,skiphash,ck)
      if ok then
        done=true
      end
    end
    if hasglue then
      setdiscchecked(lookaheaddisc,cf,post,new)
    else
      setdisc(lookaheaddisc,cf,post,new)
    end
    start=getprev(lookaheaddisc)
    sweephead[cf]=getnext(clast) or false
    sweephead[new]=getnext(cl) or false
  elseif backtrackdisc then
    local cf=getnext(backtrackdisc)
    local cl=start
    local cnext=getnext(start)
    local insertedmarks=0
    while cnext do
      local char=ischar(cnext,currentfont)
      if char and marks[char] then
        insertedmarks=insertedmarks+1
        cl=cnext
        cnext=getnext(cnext)
      else
        break
      end
    end
    setlink(backtrackdisc,cnext)
    setprev(cf)
    setnext(cl)
    local pre,post,replace,pretail,posttail,replacetail=getdisc(backtrackdisc,true)
    local new=copy_node_list(cf)
    local cnew=find_node_tail(new)
    for i=1,insertedmarks do
      cnew=getprev(cnew)
    end
    local clast=cnew
    for i=f,l do
      clast=getnext(clast)
    end
    if not notmatchpost[backtrackdisc] then
      local ok=false
      cf,start,ok=chainrun(cf,start,last,dataset,sequence,rlmode,skiphash,ck)
      if ok then
        done=true
      end
    end
    if not notmatchreplace[backtrackdisc] then
      local ok=false
      new,cnew,ok=chainrun(new,cnew,clast,dataset,sequence,rlmode,skiphash,ck)
      if ok then
        done=true
      end
    end
    if post then
      setlink(posttail,cf)
    else
      post=cf
    end
    if replace then
      setlink(replacetail,new)
    else
      replace=new
    end
    if hasglue then
      setdiscchecked(backtrackdisc,pre,post,replace)
    else
      setdisc(backtrackdisc,pre,post,replace)
    end
    start=getprev(backtrackdisc)
    sweephead[post]=getnext(clast) or false
    sweephead[replace]=getnext(last) or false
  else
    local ok=false
    head,start,ok=chainrun(head,start,last,dataset,sequence,rlmode,skiphash,ck)
    if ok then
      done=true
    end
  end
  return head,start,done
end
local function chaintrac(head,start,dataset,sequence,rlmode,skiphash,ck,match,discseen,sweepnode)
  local rule=ck[1]
  local lookuptype=ck[8] or ck[2]
  local nofseq=#ck[3]
  local first=ck[4]
  local last=ck[5]
  local char=getchar(start)
  logwarning("%s: rule %s %s at char %s for (%s,%s,%s) chars, lookuptype %a, %sdisc seen, %ssweeping",
    cref(dataset,sequence),rule,match and "matches" or "nomatch",
    gref(char),first-1,last-first+1,nofseq-last,lookuptype,
    discseen and "" or "no ",sweepnode and "" or "not ")
end
local function handle_contextchain(head,start,dataset,sequence,contexts,rlmode,skiphash)
  local sweepnode=sweepnode
  local sweeptype=sweeptype
  local postreplace
  local prereplace
  local checkdisc
  local discseen 
  if sweeptype then
    if sweeptype=="replace" then
      postreplace=true
      prereplace=true
    else
      postreplace=sweeptype=="post"
      prereplace=sweeptype=="pre"
    end
    checkdisc=getprev(head)
  end
  local currentfont=currentfont
  local skipped  
  local startprev,
     startnext=getboth(start)
  local done
  local nofcontexts=contexts.n 
  local startchar=nofcontext==1 or ischar(start,currentfont) 
  for k=1,nofcontexts do 
    local ck=contexts[k]
    local seq=ck[3]
    local f=ck[4] 
    if not startchar or not seq[f][startchar] then
      goto next
    end
    local s=seq.n 
    local l=ck[5] 
    local current=start
    local last=start
    if l>f then
      local discfound 
      local n=f+1
      last=startnext 
      while n<=l do
        if postreplace and not last then
          last=getnext(sweepnode)
          sweeptype=nil
        end
        if last then
          local char,id=ischar(last,currentfont)
          if char then
            if skiphash and skiphash[char] then
              skipped=true
              if trace_skips then
                show_skip(dataset,sequence,char,ck,classes[char])
              end
              last=getnext(last)
            elseif seq[n][char] then
              if n<l then
                last=getnext(last)
              end
              n=n+1
            elseif discfound then
              notmatchreplace[discfound]=true
              if notmatchpre[discfound] then
                goto next
              else
                break
              end
            else
              goto next
            end
          elseif char==false then
            if discfound then
              notmatchreplace[discfound]=true
              if notmatchpre[discfound] then
                goto next
              else
                break
              end
            else
              goto next
            end
          elseif id==disc_code then
            discseen=true
            discfound=last
            notmatchpre[last]=nil
            notmatchpost[last]=true
            notmatchreplace[last]=nil
            local pre,post,replace=getdisc(last)
            if pre then
              local n=n
              while pre do
                if seq[n][getchar(pre)] then
                  n=n+1
                  if n>l then
                    break
                  end
                  pre=getnext(pre)
                else
                  notmatchpre[last]=true
                  break
                end
              end
            else
              notmatchpre[last]=true
            end
            if replace then
              while replace do
                if seq[n][getchar(replace)] then
                  n=n+1
                  if n>l then
                    break
                  end
                  replace=getnext(replace)
                else
                  notmatchreplace[last]=true
                  if notmatchpre[last] then
                    goto next
                  else
                    break
                  end
                end
              end
              if notmatchpre[last] then
                goto next
              end
            end
            last=getnext(last)
          else
            goto next
          end
        else
          goto next
        end
      end
    end
    if f>1 then
      if startprev then
        local prev=startprev
        if prereplace and prev==checkdisc then
          prev=getprev(sweepnode)
        end
        if prev then
          local discfound 
          local n=f-1
          while n>=1 do
            if prev then
              local char,id=ischar(prev,currentfont)
              if char then
                if skiphash and skiphash[char] then
                  skipped=true
                  if trace_skips then
                    show_skip(dataset,sequence,char,ck,classes[char])
                  end
                  prev=getprev(prev)
                elseif seq[n][char] then
                  if n>1 then
                    prev=getprev(prev)
                  end
                  n=n-1
                elseif discfound then
                  notmatchreplace[discfound]=true
                  if notmatchpost[discfound] then
                    goto next
                  else
                    break
                  end
                else
                  goto next
                end
              elseif char==false then
                if discfound then
                  notmatchreplace[discfound]=true
                  if notmatchpost[discfound] then
                    goto next
                  end
                else
                  goto next
                end
                break
              elseif id==disc_code then
                discseen=true
                discfound=prev
                notmatchpre[prev]=true
                notmatchpost[prev]=nil
                notmatchreplace[prev]=nil
                local pre,post,replace,pretail,posttail,replacetail=getdisc(prev,true)
                if pre~=start and post~=start and replace~=start then
                  if post then
                    local n=n
                    while posttail do
                      if seq[n][getchar(posttail)] then
                        n=n-1
                        if posttail==post or n<1 then
                          break
                        else
                          posttail=getprev(posttail)
                        end
                      else
                        notmatchpost[prev]=true
                        break
                      end
                    end
                    if n>=1 then
                      notmatchpost[prev]=true
                    end
                  else
                    notmatchpost[prev]=true
                  end
                  if replace then
                    while replacetail do
                      if seq[n][getchar(replacetail)] then
                        n=n-1
                        if replacetail==replace or n<1 then
                          break
                        else
                          replacetail=getprev(replacetail)
                        end
                      else
                        notmatchreplace[prev]=true
                        if notmatchpost[prev] then
                          goto next
                        else
                          break
                        end
                      end
                    end
                  else
                    notmatchreplace[prev]=true 
                  end
                end
                prev=getprev(prev)
              elseif id==glue_code then
                local sn=seq[n]
                if (sn[32] and spaces[prev]) or sn[0xFFFC] then
                  n=n-1
                  prev=getprev(prev)
                else
                  goto next
                end
              elseif seq[n][0xFFFC] then
                n=n-1
                prev=getprev(prev)
              else
                goto next
              end
            else
              goto next
            end
          end
        else
          goto next
        end
      else
        goto next
      end
    end
    if s>l then
      local current=last and getnext(last)
      if not current and postreplace then
        current=getnext(sweepnode)
      end
      if current then
        local discfound 
        local n=l+1
        while n<=s do
          if current then
            local char,id=ischar(current,currentfont)
            if char then
              if skiphash and skiphash[char] then
                skipped=true
                if trace_skips then
                  show_skip(dataset,sequence,char,ck,classes[char])
                end
                current=getnext(current) 
              elseif seq[n][char] then
                if n<s then 
                  current=getnext(current) 
                end
                n=n+1
              elseif discfound then
                notmatchreplace[discfound]=true
                if notmatchpre[discfound] then
                  goto next
                else
                  break
                end
              else
                goto next
              end
            elseif char==false then
              if discfound then
                notmatchreplace[discfound]=true
                if notmatchpre[discfound] then
                  goto next
                else
                  break
                end
              else
                goto next
              end
            elseif id==disc_code then
              discseen=true
              discfound=current
              notmatchpre[current]=nil
              notmatchpost[current]=true
              notmatchreplace[current]=nil
              local pre,post,replace=getdisc(current)
              if pre then
                local n=n
                while pre do
                  if seq[n][getchar(pre)] then
                    n=n+1
                    if n>s then
                      break
                    else
                      pre=getnext(pre)
                    end
                  else
                    notmatchpre[current]=true
                    break
                  end
                end
                if n<=s then
                  notmatchpre[current]=true
                end
              else
                notmatchpre[current]=true
              end
              if replace then
                while replace do
                  if seq[n][getchar(replace)] then
                    n=n+1
                    if n>s then
                      break
                    else
                      replace=getnext(replace)
                    end
                  else
                    notmatchreplace[current]=true
                    if notmatchpre[current] then
                      goto next
                    else
                      break
                    end
                  end
                end
              else
                notmatchreplace[current]=true 
              end
              current=getnext(current)
            elseif id==glue_code then
              local sn=seq[n]
              if (sn[32] and spaces[current]) or sn[0xFFFC] then
                n=n+1
                current=getnext(current)
              else
                goto next
              end
            elseif seq[n][0xFFFC] then
              n=n+1
              current=getnext(current)
            else
              goto next
            end
          else
            goto next
          end
        end
      else
        goto next
      end
    end
    if trace_contexts then
      chaintrac(head,start,dataset,sequence,rlmode,skipped and skiphash,ck,true,discseen,sweepnode)
    end
    if discseen or sweepnode then
      head,start,done=chaindisk(head,start,dataset,sequence,rlmode,skipped and skiphash,ck)
    else
      head,start,done=chainrun(head,start,last,dataset,sequence,rlmode,skipped and skiphash,ck)
    end
    if done then
      break
    end
    ::next::
  end
  if discseen then
    notmatchpre={}
    notmatchpost={}
    notmatchreplace={}
  end
  return head,start,done
end
handlers.gsub_context=handle_contextchain
handlers.gsub_contextchain=handle_contextchain
handlers.gsub_reversecontextchain=handle_contextchain
handlers.gpos_contextchain=handle_contextchain
handlers.gpos_context=handle_contextchain
local function chained_contextchain(head,start,stop,dataset,sequence,currentlookup,rlmode,skiphash)
  local steps=currentlookup.steps
  local nofsteps=currentlookup.nofsteps
  if nofsteps>1 then
    reportmoresteps(dataset,sequence)
  end
  local l=steps[1].coverage[getchar(start)]
  if l then
    return handle_contextchain(head,start,dataset,sequence,l,rlmode,skiphash)
  else
    return head,start,false
  end
end
chainprocs.gsub_context=chained_contextchain
chainprocs.gsub_contextchain=chained_contextchain
chainprocs.gsub_reversecontextchain=chained_contextchain
chainprocs.gpos_contextchain=chained_contextchain
chainprocs.gpos_context=chained_contextchain
local missing=setmetatableindex("table")
local logwarning=report_process
local resolved={} 
local function logprocess(...)
  if trace_steps then
    registermessage(...)
    if trace_steps=="silent" then
      return
    end
  end
  report_process(...)
end
local sequencelists=setmetatableindex(function(t,font)
  local sequences=fontdata[font].resources.sequences
  if not sequences or not next(sequences) then
    sequences=false
  end
  t[font]=sequences
  return sequences
end)
do 
  local autofeatures=fonts.analyzers.features
  local featuretypes=otf.tables.featuretypes
  local defaultscript=otf.features.checkeddefaultscript
  local defaultlanguage=otf.features.checkeddefaultlanguage
  local wildcard="*"
  local default="dflt"
  local function initialize(sequence,script,language,enabled,autoscript,autolanguage)
    local features=sequence.features
    if features then
      local order=sequence.order
      if order then
        local featuretype=featuretypes[sequence.type or "unknown"]
        for i=1,#order do
          local kind=order[i]
          local valid=enabled[kind]
          if valid then
            local scripts=features[kind]
            local languages=scripts and (
              scripts[script] or
              scripts[wildcard] or
              (autoscript and defaultscript(featuretype,autoscript,scripts))
            )
            local enabled=languages and (
              languages[language] or
              languages[wildcard] or
              (autolanguage and defaultlanguage(featuretype,autolanguage,languages))
            )
            if enabled then
              return { valid,autofeatures[kind] or false,sequence,kind }
            end
          end
        end
      else
      end
    end
    return false
  end
  function otf.dataset(tfmdata,font) 
    local shared=tfmdata.shared
    local properties=tfmdata.properties
    local language=properties.language or "dflt"
    local script=properties.script  or "dflt"
    local enabled=shared.features
    local autoscript=enabled and enabled.autoscript
    local autolanguage=enabled and enabled.autolanguage
    local res=resolved[font]
    if not res then
      res={}
      resolved[font]=res
    end
    local rs=res[script]
    if not rs then
      rs={}
      res[script]=rs
    end
    local rl=rs[language]
    if not rl then
      rl={
      }
      rs[language]=rl
      local sequences=tfmdata.resources.sequences
      if sequences then
        for s=1,#sequences do
          local v=enabled and initialize(sequences[s],script,language,enabled,autoscript,autolanguage)
          if v then
            rl[#rl+1]=v
          end
        end
      end
    end
    return rl
  end
end
local function report_disc(what,n)
  report_run("%s: %s > %s",what,n,languages.serializediscretionary(n))
end
local function kernrun(disc,k_run,font,attr,...)
  if trace_kernruns then
    report_disc("kern",disc)
  end
  local prev,next=getboth(disc)
  local nextstart=next
  local done=false
  local pre,post,replace,pretail,posttail,replacetail=getdisc(disc,true)
  local prevmarks=prev
  while prevmarks do
    local char=ischar(prevmarks,font)
    if char and marks[char] then
      prevmarks=getprev(prevmarks)
    else
      break
    end
  end
  if prev and not ischar(prev,font) then 
    prev=false
  end
  if next and not ischar(next,font) then 
    next=false
  end
  if pre then
    if k_run(pre,"injections",nil,font,attr,...) then
      done=true
    end
    if prev then
      setlink(prev,pre)
      if k_run(prevmarks,"preinjections",pre,font,attr,...) then 
        done=true
      end
      setprev(pre)
      setlink(prev,disc)
    end
  end
  if post then
    if k_run(post,"injections",nil,font,attr,...) then
      done=true
    end
    if next then
      setlink(posttail,next)
      if k_run(posttail,"postinjections",next,font,attr,...) then
        done=true
      end
      setnext(posttail)
      setlink(disc,next)
    end
  end
  if replace then
    if k_run(replace,"injections",nil,font,attr,...) then
      done=true
    end
    if prev then
      setlink(prev,replace)
      if k_run(prevmarks,"replaceinjections",replace,font,attr,...) then 
        done=true
      end
      setprev(replace)
      setlink(prev,disc)
    end
    if next then
      setlink(replacetail,next)
      if k_run(replacetail,"replaceinjections",next,font,attr,...) then
        done=true
      end
      setnext(replacetail)
      setlink(disc,next)
    end
  elseif prev and next then
    setlink(prev,next)
    if k_run(prevmarks,"emptyinjections",next,font,attr,...) then
      done=true
    end
    setlink(prev,disc,next)
  end
  if done and trace_testruns then
    report_disc("done",disc)
  end
  return nextstart,done
end
local function comprun(disc,c_run,...) 
  if trace_compruns then
    report_disc("comp",disc)
  end
  local pre,post,replace=getdisc(disc)
  local renewed=false
  if pre then
    sweepnode=disc
    sweeptype="pre" 
    local new,done=c_run(pre,...)
    if done then
      pre=new
      renewed=true
    end
  end
  if post then
    sweepnode=disc
    sweeptype="post"
    local new,done=c_run(post,...)
    if done then
      post=new
      renewed=true
    end
  end
  if replace then
    sweepnode=disc
    sweeptype="replace"
    local new,done=c_run(replace,...)
    if done then
      replace=new
      renewed=true
    end
  end
  sweepnode=nil
  sweeptype=nil
  if renewed then
    if trace_testruns then
      report_disc("done",disc)
    end
    setdisc(disc,pre,post,replace)
  end
  return getnext(disc),renewed
end
local function testrun(disc,t_run,c_run,...)
  if trace_testruns then
    report_disc("test",disc)
  end
  local prev,next=getboth(disc)
  if not next then
    return
  end
  local pre,post,replace,pretail,posttail,replacetail=getdisc(disc,true)
  local renewed=false
  if (post or replace) and prev then
    if post then
      setlink(posttail,next)
    else
      post=next
    end
    if replace then
      setlink(replacetail,next)
    else
      replace=next
    end
    local d_post=t_run(post,next,...)
    local d_replace=t_run(replace,next,...)
    if d_post>0 or d_replace>0 then
      local d=d_replace>d_post and d_replace or d_post
      local head=getnext(disc) 
      local tail=head
      for i=1,d do
        local nx=getnext(tail)
        local id=getid(nx)
        if id==disc_code then
          head,tail=flattendisk(head,nx)
        elseif id==glyph_code then
          tail=nx
        else
          break
        end
      end
      next=getnext(tail)
      setnext(tail)
      setprev(head)
      local new=copy_node_list(head)
      if posttail then
        setlink(posttail,head)
      else
        post=head
      end
      if replacetail then
        setlink(replacetail,new)
      else
        replace=new
      end
    else
      if posttail then
        setnext(posttail)
      else
        post=nil
      end
      if replacetail then
        setnext(replacetail)
      else
        replace=nil
      end
    end
    setlink(disc,next)
  end
  if trace_testruns then
    report_disc("more",disc)
  end
  if pre then
    sweepnode=disc
    sweeptype="pre"
    local new,ok=c_run(pre,...)
    if ok then
      pre=new
      renewed=true
    end
  end
  if post then
    sweepnode=disc
    sweeptype="post"
    local new,ok=c_run(post,...)
    if ok then
      post=new
      renewed=true
    end
  end
  if replace then
    sweepnode=disc
    sweeptype="replace"
    local new,ok=c_run(replace,...)
    if ok then
      replace=new
      renewed=true
    end
  end
  sweepnode=nil
  sweeptype=nil
  if renewed then
    setdisc(disc,pre,post,replace)
    if trace_testruns then
      report_disc("done",disc)
    end
  end
  return getnext(disc),renewed
end
local nesting=0
local function c_run_single(head,font,attr,lookupcache,step,dataset,sequence,rlmode,skiphash,handler)
  local done=false
  local sweep=sweephead[head]
  if sweep then
    start=sweep
    sweephead[head]=false
  else
    start=head
  end
  while start do
    local char,id=ischar(start,font)
    if char then
      local a 
      if attr then
        a=getattr(start,0)
      end
      if not a or (a==attr) then
        local lookupmatch=lookupcache[char]
        if lookupmatch then
          local ok
          head,start,ok=handler(head,start,dataset,sequence,lookupmatch,rlmode,skiphash,step)
          if ok then
            done=true
          end
        end
        if start then
          start=getnext(start)
        end
      else
        start=getnext(start)
      end
    elseif char==false then
      return head,done
    elseif sweep then
      return head,done
    else
      start=getnext(start)
    end
  end
  return head,done
end
local function t_run_single(start,stop,font,attr,lookupcache)
  local lastd=nil
  while start~=stop do
    local char=ischar(start,font)
    if char then
      local a 
      if attr then
        a=getattr(start,0)
      end
      local startnext=getnext(start)
      if not a or (a==attr) then
        local lookupmatch=lookupcache[char]
        if lookupmatch then
          local s=startnext
          local ss=nil
          local sstop=s==stop
          if not s then
            s=ss
            ss=nil
          end
          while getid(s)==disc_code do
            ss=getnext(s)
            s=getfield(s,"replace")
            if not s then
              s=ss
              ss=nil
            end
          end
          local l=nil
          local d=0
          while s do
            local char=ischar(s,font)
            if char then
              local lg=lookupmatch[char]
              if lg then
                if sstop then
                  d=1
                elseif d>0 then
                  d=d+1
                end
                l=lg
                s=getnext(s)
                sstop=s==stop
                if not s then
                  s=ss
                  ss=nil
                end
                while getid(s)==disc_code do
                  ss=getnext(s)
                  s=getfield(s,"replace")
                  if not s then
                    s=ss
                    ss=nil
                  end
                end
              else
                break
              end
            else
              break
            end
          end
          if l and l.ligature then 
            lastd=d
          end
        else
        end
      else
      end
      if lastd then
        return lastd
      end
      start=startnext
    else
      break
    end
  end
  return 0
end
local function k_run_single(sub,injection,last,font,attr,lookupcache,step,dataset,sequence,rlmode,skiphash,handler)
  local a 
  if attr then
    a=getattr(sub,0)
  end
  if not a or (a==attr) then
    for n in nextnode,sub do 
      if n==last then
        break
      end
      local char=ischar(n)
      if char then
        local lookupmatch=lookupcache[char]
        if lookupmatch then
          local h,d,ok=handler(sub,n,dataset,sequence,lookupmatch,rlmode,skiphash,step,injection)
          if ok then
            return true
          end
        end
      end
    end
  end
end
local function c_run_multiple(head,font,attr,steps,nofsteps,dataset,sequence,rlmode,skiphash,handler)
  local done=false
  local sweep=sweephead[head]
  if sweep then
    start=sweep
    sweephead[head]=false
  else
    start=head
  end
  while start do
    local char=ischar(start,font)
    if char then
      local a 
      if attr then
        a=getattr(start,0)
      end
      if not a or (a==attr) then
        for i=1,nofsteps do
          local step=steps[i]
          local lookupcache=step.coverage
          local lookupmatch=lookupcache[char]
          if lookupmatch then
            local ok
            head,start,ok=handler(head,start,dataset,sequence,lookupmatch,rlmode,skiphash,step)
            if ok then
              done=true
              break
            elseif not start then
              break
            end
          end
        end
        if start then
          start=getnext(start)
        end
      else
        start=getnext(start)
      end
    elseif char==false then
      return head,done
    elseif sweep then
      return head,done
    else
      start=getnext(start)
    end
  end
  return head,done
end
local function t_run_multiple(start,stop,font,attr,steps,nofsteps)
  local lastd=nil
  while start~=stop do
    local char=ischar(start,font)
    if char then
      local a 
      if attr then
        a=getattr(start,0)
      end
      local startnext=getnext(start)
      if not a or (a==attr) then
        for i=1,nofsteps do
          local step=steps[i]
          local lookupcache=step.coverage
          local lookupmatch=lookupcache[char]
          if lookupmatch then
            local s=startnext
            local ss=nil
            local sstop=s==stop
            if not s then
              s=ss
              ss=nil
            end
            while getid(s)==disc_code do
              ss=getnext(s)
              s=getfield(s,"replace")
              if not s then
                s=ss
                ss=nil
              end
            end
            local l=nil
            local d=0
            while s do
              local char=ischar(s)
              if char then
                local lg=lookupmatch[char]
                if lg then
                  if sstop then
                    d=1
                  elseif d>0 then
                    d=d+1
                  end
                  l=lg
                  s=getnext(s)
                  sstop=s==stop
                  if not s then
                    s=ss
                    ss=nil
                  end
                  while getid(s)==disc_code do
                    ss=getnext(s)
                    s=getfield(s,"replace")
                    if not s then
                      s=ss
                      ss=nil
                    end
                  end
                else
                  break
                end
              else
                break
              end
            end
            if l and l.ligature then
              lastd=d
            end
          end
        end
      else
      end
      if lastd then
        return lastd
      end
      start=startnext
    else
      break
    end
  end
  return 0
end
local function k_run_multiple(sub,injection,last,font,attr,steps,nofsteps,dataset,sequence,rlmode,skiphash,handler)
  local a 
  if attr then
    a=getattr(sub,0)
  end
  if not a or (a==attr) then
    for n in nextnode,sub do 
      if n==last then
        break
      end
      local char=ischar(n)
      if char then
        for i=1,nofsteps do
          local step=steps[i]
          local lookupcache=step.coverage
          local lookupmatch=lookupcache[char]
          if lookupmatch then
            local h,d,ok=handler(sub,n,dataset,sequence,lookupmatch,rlmode,skiphash,step,injection) 
            if ok then
              return true
            end
          end
        end
      end
    end
  end
end
local function txtdirstate(start,stack,top,rlparmode)
  local nxt=getnext(start)
  local dir=getdir(start)
  if dir=="+TRT" then
    top=top+1
    stack[top]=dir
    return nxt,top,-1
  elseif dir=="+TLT" then
    top=top+1
    stack[top]=dir
    return nxt,top,1
  elseif dir=="-TRT" or dir=="-TLT" then
    if top==1 then
      return nxt,0,rlparmode
    else
      top=top-1
      if stack[top]=="+TRT" then
        return nxt,top,-1
      else
        return nxt,top,1
      end
    end
  else
    return nxt,top,rlparmode
  end
end
local function pardirstate(start)
  local nxt=getnext(start)
  local dir=getdir(start)
  if dir=="TLT" then
    return nxt,1,1
  elseif dir=="TRT" then
    return nxt,-1,-1
  else
    return nxt,0,0
  end
end
otf.helpers=otf.helpers or {}
otf.helpers.txtdirstate=txtdirstate
otf.helpers.pardirstate=pardirstate
do
  local fastdisc=true
  local testdics=false
  directives.register("otf.fastdisc",function(v) fastdisc=v end)
  local otfdataset=nil 
  local getfastdisc={ __index=function(t,k)
    local v=usesfont(k,currentfont)
    t[k]=v
    return v
  end }
  local getfastspace={ __index=function(t,k)
    local v=isspace(k,threshold) or false
    t[k]=v
    return v
  end }
  function otf.featuresprocessor(head,font,attr,direction,n)
    local sequences=sequencelists[font] 
    nesting=nesting+1
    if nesting==1 then
      currentfont=font
      tfmdata=fontdata[font]
      descriptions=tfmdata.descriptions 
      characters=tfmdata.characters  
   local resources=tfmdata.resources
      marks=resources.marks
      classes=resources.classes
      threshold,
      factor=getthreshold(font)
      checkmarks=tfmdata.properties.checkmarks
      if not otfdataset then
        otfdataset=otf.dataset
      end
      discs=fastdisc and n and n>1 and setmetatable({},getfastdisc) 
      spaces=setmetatable({},getfastspace)
    elseif currentfont~=font then
      report_warning("nested call with a different font, level %s, quitting",nesting)
      nesting=nesting-1
      return head,false
    end
    if trace_steps then
      checkstep(head)
    end
    local initialrl=direction=="TRT" and -1 or 0
    local datasets=otfdataset(tfmdata,font,attr)
    local dirstack={ nil } 
    sweephead={}
    for s=1,#datasets do
      local dataset=datasets[s]
      local attribute=dataset[2]
      local sequence=dataset[3] 
      local rlparmode=initialrl
      local topstack=0
      local typ=sequence.type
      local gpossing=typ=="gpos_single" or typ=="gpos_pair" 
      local forcetestrun=typ=="gsub_ligature" 
      local handler=handlers[typ] 
      local steps=sequence.steps
      local nofsteps=sequence.nofsteps
      local skiphash=sequence.skiphash
      if not steps then
        local h,ok=handler(head,dataset,sequence,initialrl,font,attr)
        if h and h~=head then
          head=h
        end
      elseif typ=="gsub_reversecontextchain" then
        local start=find_node_tail(head)
        local rlmode=0 
        local merged=steps.merged
        while start do
          local char=ischar(start,font)
          if char then
            local m=merged[char]
            if m then
              local a 
              if attr then
                a=getattr(start,0)
              end
              if not a or (a==attr) then
                for i=m[1],m[2] do
                  local step=steps[i]
                  local lookupcache=step.coverage
                  local lookupmatch=lookupcache[char]
                  if lookupmatch then
                    local ok
                    head,start,ok=handler(head,start,dataset,sequence,lookupmatch,rlmode,skiphash,step)
                    if ok then
                      break
                    end
                  end
                end
                if start then
                  start=getprev(start)
                end
              else
                start=getprev(start)
              end
            else
              start=getprev(start)
            end
          else
            start=getprev(start)
          end
        end
      else
        local start=head
        local rlmode=initialrl
        if nofsteps==1 then 
          local step=steps[1]
          local lookupcache=step.coverage
          while start do
            local char,id=ischar(start,font)
            if char then
              if skiphash and skiphash[char] then 
                start=getnext(start)
              else
                local lookupmatch=lookupcache[char]
                if lookupmatch then
                  local a 
                  if attr then
                    if getattr(start,0)==attr and (not attribute or getprop(start,a_state)==attribute) then
                      a=true
                    end
                  elseif not attribute or getprop(start,a_state)==attribute then
                    a=true
                  end
                  if a then
                    local ok
                    head,start,ok=handler(head,start,dataset,sequence,lookupmatch,rlmode,skiphash,step)
                    if start then
                      start=getnext(start)
                    end
                  else
                    start=getnext(start)
                  end
                else
                  start=getnext(start)
                end
              end
            elseif char==false or id==glue_code then
              start=getnext(start)
            elseif id==disc_code then
              if not discs or discs[start]==true then
                local ok
                if gpossing then
                  start,ok=kernrun(start,k_run_single,font,attr,lookupcache,step,dataset,sequence,rlmode,skiphash,handler)
                elseif forcetestrun then
                  start,ok=testrun(start,t_run_single,c_run_single,font,attr,lookupcache,step,dataset,sequence,rlmode,skiphash,handler)
                else
                  start,ok=comprun(start,c_run_single,font,attr,lookupcache,step,dataset,sequence,rlmode,skiphash,handler)
                end
              else
                start=getnext(start)
              end
            elseif id==math_code then
              start=getnext(end_of_math(start))
            elseif id==dir_code then
              start,topstack,rlmode=txtdirstate(start,dirstack,topstack,rlparmode)
            elseif id==localpar_code then
              start,rlparmode,rlmode=pardirstate(start)
            else
              start=getnext(start)
            end
          end
        else
          local merged=steps.merged
          while start do
            local char,id=ischar(start,font)
            if char then
              if skiphash and skiphash[char] then 
                start=getnext(start)
              else
                local m=merged[char]
                if m then
                  local a 
                  if attr then
                    if getattr(start,0)==attr and (not attribute or getprop(start,a_state)==attribute) then
                      a=true
                    end
                  elseif not attribute or getprop(start,a_state)==attribute then
                    a=true
                  end
                  if a then
                    for i=m[1],m[2] do
                      local step=steps[i]
                      local lookupcache=step.coverage
                      local lookupmatch=lookupcache[char]
                      if lookupmatch then
                        local ok
                        head,start,ok=handler(head,start,dataset,sequence,lookupmatch,rlmode,skiphash,step)
                        if ok then
                          break
                        elseif not start then
                          break
                        end
                      end
                    end
                    if start then
                      start=getnext(start)
                    end
                  else
                    start=getnext(start)
                  end
                else
                  start=getnext(start)
                end
              end
            elseif char==false or id==glue_code then
              start=getnext(start)
            elseif id==disc_code then
              if not discs or discs[start]==true then
                local ok
                if gpossing then
                  start,ok=kernrun(start,k_run_multiple,font,attr,steps,nofsteps,dataset,sequence,rlmode,skiphash,handler)
                elseif forcetestrun then
                  start,ok=testrun(start,t_run_multiple,c_run_multiple,font,attr,steps,nofsteps,dataset,sequence,rlmode,skiphash,handler)
                else
                  start,ok=comprun(start,c_run_multiple,font,attr,steps,nofsteps,dataset,sequence,rlmode,skiphash,handler)
                end
              else
                start=getnext(start)
              end
            elseif id==math_code then
              start=getnext(end_of_math(start))
            elseif id==dir_code then
              start,topstack,rlmode=txtdirstate(start,dirstack,topstack,rlparmode)
            elseif id==localpar_code then
              start,rlparmode,rlmode=pardirstate(start)
            else
              start=getnext(start)
            end
          end
        end
      end
      if trace_steps then 
        registerstep(head)
      end
    end
    nesting=nesting-1
    return head
  end
  function otf.datasetpositionprocessor(head,font,direction,dataset)
    currentfont=font
    tfmdata=fontdata[font]
    descriptions=tfmdata.descriptions 
    characters=tfmdata.characters  
 local resources=tfmdata.resources
    marks=resources.marks
    classes=resources.classes
    threshold,
    factor=getthreshold(font)
    checkmarks=tfmdata.properties.checkmarks
    if type(dataset)=="number" then
      dataset=otfdataset(tfmdata,font,0)[dataset]
    end
    local sequence=dataset[3] 
    local typ=sequence.type
    local handler=handlers[typ] 
    local steps=sequence.steps
    local nofsteps=sequence.nofsteps
    local done=false
    local dirstack={ nil } 
    local start=head
    local initialrl=direction=="TRT" and -1 or 0
    local rlmode=initialrl
    local rlparmode=initialrl
    local topstack=0
    local merged=steps.merged
    local position=0
    while start do
      local char,id=ischar(start,font)
      if char then
        position=position+1
        local m=merged[char]
        if m then
          if skiphash and skiphash[char] then 
            start=getnext(start)
          else
            for i=m[1],m[2] do
              local step=steps[i]
              local lookupcache=step.coverage
              local lookupmatch=lookupcache[char]
              if lookupmatch then
                local ok
                head,start,ok=handler(head,start,dataset,sequence,lookupmatch,rlmode,skiphash,step)
                if ok then
                  break
                elseif not start then
                  break
                end
              end
            end
            if start then
              start=getnext(start)
            end
          end
        else
          start=getnext(start)
        end
      elseif char==false or id==glue_code then
        start=getnext(start)
      elseif id==math_code then
        start=getnext(end_of_math(start))
      elseif id==dir_code then
        start,topstack,rlmode=txtdirstate(start,dirstack,topstack,rlparmode)
      elseif id==localpar_code then
        start,rlparmode,rlmode=pardirstate(start)
      else
        start=getnext(start)
      end
    end
    return head
  end
end
local plugins={}
otf.plugins=plugins
local report=logs.reporter("fonts")
function otf.registerplugin(name,f)
  if type(name)=="string" and type(f)=="function" then
    plugins[name]={ name,f }
    report()
    report("plugin %a has been loaded, please be aware of possible side effects",name)
    report()
    if logs.pushtarget then
      logs.pushtarget("log")
    end
    report("Plugins are not officially supported unless stated otherwise. This is because")
    report("they bypass the regular font handling and therefore some features in ConTeXt")
    report("(especially those related to fonts) might not work as expected or might not work")
    report("at all. Some plugins are for testing and development only and might change")
    report("whenever we feel the need for it.")
    report()
    if logs.poptarget then
      logs.poptarget()
    end
  end
end
function otf.plugininitializer(tfmdata,value)
  if type(value)=="string" then
    tfmdata.shared.plugin=plugins[value]
  end
end
function otf.pluginprocessor(head,font,attr,direction) 
  local s=fontdata[font].shared
  local p=s and s.plugin
  if p then
    if trace_plugins then
      report_process("applying plugin %a",p[1])
    end
    return p[2](head,font,attr,direction)
  else
    return head,false
  end
end
function otf.featuresinitializer(tfmdata,value)
end
registerotffeature {
  name="features",
  description="features",
  default=true,
  initializers={
    position=1,
    node=otf.featuresinitializer,
    plug=otf.plugininitializer,
  },
  processors={
    node=otf.featuresprocessor,
    plug=otf.pluginprocessor,
  }
}
otf.handlers=handlers
local setspacekerns=nodes.injections.setspacekerns if not setspacekerns then os.exit() end
local tag="kern" 
if fontfeatures then
  function handlers.trigger_space_kerns(head,dataset,sequence,initialrl,font,attr)
    local features=fontfeatures[font]
    local enabled=features and features.spacekern and features[tag]
    if enabled then
      setspacekerns(font,sequence)
    end
    return head,enabled
  end
else 
  function handlers.trigger_space_kerns(head,dataset,sequence,initialrl,font,attr)
    local shared=fontdata[font].shared
    local features=shared and shared.features
    local enabled=features and features.spacekern and features[tag]
    if enabled then
      setspacekerns(font,sequence)
    end
    return head,enabled
  end
end
local function hasspacekerns(data)
  local resources=data.resources
  local sequences=resources.sequences
  local validgpos=resources.features.gpos
  if validgpos and sequences then
    for i=1,#sequences do
      local sequence=sequences[i]
      local steps=sequence.steps
      if steps and sequence.features[tag] then
        local kind=sequence.type
        if kind=="gpos_pair" or kind=="gpos_single" then
          for i=1,#steps do
            local step=steps[i]
            local coverage=step.coverage
            local rules=step.rules
            if rules then
            elseif not coverage then
            elseif kind=="gpos_single" then
            elseif kind=="gpos_pair" then
              local format=step.format
              if format=="move" or format=="kern" then
                local kerns=coverage[32]
                if kerns then
                  return true
                end
                for k,v in next,coverage do
                  if v[32] then
                    return true
                  end
                end
              elseif format=="pair" then
                local kerns=coverage[32]
                if kerns then
                  for k,v in next,kerns do
                    local one=v[1]
                    if one and one~=true then
                      return true
                    end
                  end
                end
                for k,v in next,coverage do
                  local kern=v[32]
                  if kern then
                    local one=kern[1]
                    if one and one~=true then
                      return true
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
  return false
end
otf.readers.registerextender {
  name="spacekerns",
  action=function(data)
    data.properties.hasspacekerns=hasspacekerns(data)
  end
}
local function spaceinitializer(tfmdata,value) 
  local resources=tfmdata.resources
  local spacekerns=resources and resources.spacekerns
  if value and spacekerns==nil then
    local rawdata=tfmdata.shared and tfmdata.shared.rawdata
    local properties=rawdata.properties
    if properties and properties.hasspacekerns then
      local sequences=resources.sequences
      local validgpos=resources.features.gpos
      if validgpos and sequences then
        local left={}
        local right={}
        local last=0
        local feat=nil
        for i=1,#sequences do
          local sequence=sequences[i]
          local steps=sequence.steps
          if steps then
            local kern=sequence.features[tag]
            if kern then
              local kind=sequence.type
              if kind=="gpos_pair" or kind=="gpos_single" then
                if feat then
                  for script,languages in next,kern do
                    local f=feat[script]
                    if f then
                      for l in next,languages do
                        f[l]=true
                      end
                    else
                      feat[script]=languages
                    end
                  end
                else
                  feat=kern
                end
                for i=1,#steps do
                  local step=steps[i]
                  local coverage=step.coverage
                  local rules=step.rules
                  if rules then
                  elseif not coverage then
                  elseif kind=="gpos_single" then
                  elseif kind=="gpos_pair" then
                    local format=step.format
                    if format=="move" or format=="kern" then
                      local kerns=coverage[32]
                      if kerns then
                        for k,v in next,kerns do
                          right[k]=v
                        end
                      end
                      for k,v in next,coverage do
                        local kern=v[32]
                        if kern then
                          left[k]=kern
                        end
                      end
                    elseif format=="pair" then
                      local kerns=coverage[32]
                      if kerns then
                        for k,v in next,kerns do
                          local one=v[1]
                          if one and one~=true then
                            right[k]=one[3]
                          end
                        end
                      end
                      for k,v in next,coverage do
                        local kern=v[32]
                        if kern then
                          local one=kern[1]
                          if one and one~=true then
                            left[k]=one[3]
                          end
                        end
                      end
                    end
                  end
                end
                last=i
              end
            else
            end
          end
        end
        left=next(left) and left or false
        right=next(right) and right or false
        if left or right then
          spacekerns={
            left=left,
            right=right,
          }
          if last>0 then
            local triggersequence={
              features={ [tag]=feat or { dflt={ dflt=true,} } },
              flags=noflags,
              name="trigger_space_kerns",
              order={ tag },
              type="trigger_space_kerns",
              left=left,
              right=right,
            }
            insert(sequences,last,triggersequence)
          end
        end
      end
    end
    resources.spacekerns=spacekerns
  end
  return spacekerns
end
registerotffeature {
  name="spacekern",
  description="space kern injection",
  default=true,
  initializers={
    node=spaceinitializer,
  },
}
local function markinitializer(tfmdata,value)
  local properties=tfmdata.properties
  properties.checkmarks=value
end
registerotffeature {
  name="checkmarks",
  description="check mark widths",
  default=true,
  initializers={
    node=markinitializer,
  },
}

end --- [luaotfload, fontloader-2018-10-08.lua scope for “font-ots”] ---


do  --- [luaotfload, fontloader-2018-10-08.lua scope for “font-osd” d2b542031aa693bb423b6d3272820c9a] ---

if not modules then modules={} end modules ['font-osd']={ 
  version=1.001,
  comment="companion to font-ini.mkiv",
  author="Kai Eigner, TAT Zetwerk / Hans Hagen, PRAGMA ADE",
  copyright="TAT Zetwerk / PRAGMA ADE / ConTeXt Development Team",
  license="see context related readme files"
}
local insert,imerge,copy=table.insert,table.imerge,table.copy
local next,type=next,type
local report=logs.reporter("otf","devanagari")
fonts=fonts          or {}
fonts.analyzers=fonts.analyzers     or {}
fonts.analyzers.methods=fonts.analyzers.methods or { node={ otf={} } }
local otf=fonts.handlers.otf
local handlers=otf.handlers
local methods=fonts.analyzers.methods
local otffeatures=fonts.constructors.features.otf
local registerotffeature=otffeatures.register
local nuts=nodes.nuts
local getnext=nuts.getnext
local getprev=nuts.getprev
local getboth=nuts.getboth
local getid=nuts.getid
local getchar=nuts.getchar
local getfont=nuts.getfont
local getsubtype=nuts.getsubtype
local setlink=nuts.setlink
local setnext=nuts.setnext
local setprev=nuts.setprev
local setchar=nuts.setchar
local getprop=nuts.getprop
local setprop=nuts.setprop
local ischar=nuts.is_char
local insert_node_after=nuts.insert_after
local copy_node=nuts.copy
local remove_node=nuts.remove
local flush_list=nuts.flush_list
local flush_node=nuts.flush_node
local copyinjection=nodes.injections.copy 
local unsetvalue=attributes.unsetvalue
local fontdata=fonts.hashes.identifiers
local a_state=attributes.private('state')
local a_syllabe=attributes.private('syllabe')
local dotted_circle=0x25CC
local c_nbsp=0x00A0
local c_zwnj=0x200C
local c_zwj=0x200D
local states=fonts.analyzers.states 
local s_rphf=states.rphf
local s_half=states.half
local s_pref=states.pref
local s_blwf=states.blwf
local s_pstf=states.pstf
local replace_all_nbsp=nil
replace_all_nbsp=function(head) 
  replace_all_nbsp=typesetters and typesetters.characters and typesetters.characters.replacenbspaces or function(head)
    return head
  end
  return replace_all_nbsp(head)
end
local processcharacters=nil
if context then
  local fontprocesses=fonts.hashes.processes
  function processcharacters(head,font)
    local processors=fontprocesses[font]
    for i=1,#processors do
      head=processors[i](head,font,0)
    end
    return head
  end
else
  function processcharacters(head,font)
    local processors=fontdata[font].shared.processes
    for i=1,#processors do
      head=processors[i](head,font,0)
    end
    return head
  end
end
local indicgroups=characters and characters.indicgroups
if not indicgroups and characters then
  local indic={
    c={},
    i={},
    d={},
    m={},
    s={},
    o={},
  }
  local indicmarks={
    l={},
    t={},
    b={},
    r={},
    s={},
  }
  local indicclasses={
    nukta={},
    halant={},
    ra={},
    anudatta={},
  }
  local indicorders={
    bp={},
    ap={},
    bs={},
    as={},
    bh={},
    ah={},
    bm={},
    am={},
  }
  for k,v in next,characters.data do
    local i=v.indic
    if i then
      indic[i][k]=true
      i=v.indicmark
      if i then
        if i=="s" then
          local s=v.specials
          indicmarks[i][k]={ s[2],s[3] }
        else
          indicmarks[i][k]=true
        end
      end
      i=v.indicclass
      if i then
        indicclasses[i][k]=true
      end
      i=v.indicorder
      if i then
        indicorders[i][k]=true
      end
    end
  end
  indicgroups={
    consonant=indic.c,
    independent_vowel=indic.i,
    dependent_vowel=indic.d,
    vowel_modifier=indic.m,
    stress_tone_mark=indic.s,
    pre_mark=indicmarks.l,
    above_mark=indicmarks.t,
    below_mark=indicmarks.b,
    post_mark=indicmarks.r,
    twopart_mark=indicmarks.s,
    nukta=indicclasses.nukta,
    halant=indicclasses.halant,
    ra=indicclasses.ra,
    anudatta=indicclasses.anudatta,
    before_postscript=indicorders.bp,
    after_postscript=indicorders.ap,
    before_half=indicorders.bh,
    after_half=indicorders.ah,
    before_subscript=indicorders.bs,
    after_subscript=indicorders.as,
    before_main=indicorders.bm,
    after_main=indicorders.am,
  }
  indic=nil
  indicmarks=nil
  indicclasses=nil
  indicorders=nil
  characters.indicgroups=indicgroups
end
local consonant=indicgroups.consonant
local independent_vowel=indicgroups.independent_vowel
local dependent_vowel=indicgroups.dependent_vowel
local vowel_modifier=indicgroups.vowel_modifier
local stress_tone_mark=indicgroups.stress_tone_mark
local pre_mark=indicgroups.pre_mark
local above_mark=indicgroups.above_mark
local below_mark=indicgroups.below_mark
local post_mark=indicgroups.post_mark
local twopart_mark=indicgroups.twopart_mark
local nukta=indicgroups.nukta
local halant=indicgroups.halant
local ra=indicgroups.ra
local anudatta=indicgroups.anudatta
local before_postscript=indicgroups.before_postscript
local after_postscript=indicgroups.after_postscript
local before_half=indicgroups.before_half
local after_half=indicgroups.after_half
local before_subscript=indicgroups.before_subscript
local after_subscript=indicgroups.after_subscript
local before_main=indicgroups.before_main
local after_main=indicgroups.after_main
local mark_four=table.merged (
  pre_mark,
  above_mark,
  below_mark,
  post_mark
)
local mark_above_below_post=table.merged (
  above_mark,
  below_mark,
  post_mark
)
local zw_char={ 
  [c_zwnj]=true,
  [c_zwj ]=true,
}
local dflt_true={
  dflt=true
}
local two_defaults={
  dev2=dflt_true,
}
local one_defaults={
  dev2=dflt_true,
  deva=dflt_true,
}
local false_flags={ false,false,false,false }
local sequence_reorder_matras={
  features={ dv01=two_defaults },
  flags=false_flags,
  name="dv01_reorder_matras",
  order={ "dv01" },
  type="devanagari_reorder_matras",
  nofsteps=1,
  steps={
    {
      coverage=pre_mark,
    }
  }
}
local sequence_reorder_reph={
  features={ dv02=two_defaults },
  flags=false_flags,
  name="dv02_reorder_reph",
  order={ "dv02" },
  type="devanagari_reorder_reph",
  nofsteps=1,
  steps={
    {
      coverage={},
    }
  }
}
local sequence_reorder_pre_base_reordering_consonants={
  features={ dv03=two_defaults },
  flags=false_flags,
  name="dv03_reorder_pre_base_reordering_consonants",
  order={ "dv03" },
  type="devanagari_reorder_pre_base_reordering_consonants",
  nofsteps=1,
  steps={
    {
      coverage={},
    }
  }
}
local sequence_remove_joiners={
  features={ dv04=one_defaults },
  flags=false_flags,
  name="dv04_remove_joiners",
  order={ "dv04" },
  type="devanagari_remove_joiners",
  nofsteps=1,
  steps={
    {
      coverage=zw_char,
    },
  }
}
local basic_shaping_forms={
  akhn=true,
  blwf=true,
  cjct=true,
  half=true,
  nukt=true,
  pref=true,
  pstf=true,
  rkrf=true,
  rphf=true,
  vatu=true,
}
local valid={
  abvs=true,
  akhn=true,
  blwf=true,
  calt=true,
  cjct=true,
  half=true,
  haln=true,
  nukt=true,
  pref=true,
  pres=true,
  pstf=true,
  psts=true,
  rkrf=true,
  rphf=true,
  vatu=true,
  pres=true,
  abvs=true,
  blws=true,
  psts=true,
  haln=true,
  calt=true,
}
local scripts={}
local scripts_one={ "deva","mlym","beng","gujr","guru","knda","orya","taml","telu" }
local scripts_two={ "dev2","mlm2","bng2","gjr2","gur2","knd2","ory2","tml2","tel2" }
local nofscripts=#scripts_one
for i=1,nofscripts do
  local one=scripts_one[i]
  local two=scripts_two[i]
  scripts[one]=true
  scripts[two]=true
  two_defaults[one]=dflt_true
  one_defaults[one]=dflt_true
  one_defaults[two]=dflt_true
end
local function valid_one(s) for i=1,nofscripts do if s[scripts_one[i]] then return true end end end
local function valid_two(s) for i=1,nofscripts do if s[scripts_two[i]] then return true end end end
local function initializedevanagi(tfmdata)
  local script,language=otf.scriptandlanguage(tfmdata,attr) 
  if scripts[script] then
    local resources=tfmdata.resources
    local devanagari=resources.devanagari
    if not devanagari then
      report("adding devanagari features to font")
      local gsubfeatures=resources.features.gsub
      local sequences=resources.sequences
      local sharedfeatures=tfmdata.shared.features
      local lastmatch=0
      for s=1,#sequences do 
        local features=sequences[s].features
        if features then
          for k,v in next,features do
            if basic_shaping_forms[k] then
              lastmatch=s
            end
          end
        end
      end
      local insertindex=lastmatch+1
      gsubfeatures["dv01"]=two_defaults 
      gsubfeatures["dv02"]=two_defaults 
      gsubfeatures["dv03"]=two_defaults 
      gsubfeatures["dv04"]=one_defaults
      local reorder_pre_base_reordering_consonants=copy(sequence_reorder_pre_base_reordering_consonants)
      local reorder_reph=copy(sequence_reorder_reph)
      local reorder_matras=copy(sequence_reorder_matras)
      local remove_joiners=copy(sequence_remove_joiners)
      insert(sequences,insertindex,reorder_pre_base_reordering_consonants)
      insert(sequences,insertindex,reorder_reph)
      insert(sequences,insertindex,reorder_matras)
      insert(sequences,insertindex,remove_joiners)
      local blwfcache={}
      local seqsubset={}
      local rephstep={
        coverage={} 
      }
      local devanagari={
        reph=false,
        vattu=false,
        blwfcache=blwfcache,
        seqsubset=seqsubset,
        reorderreph=rephstep,
      }
      reorder_reph.steps={ rephstep }
      local pre_base_reordering_consonants={}
      reorder_pre_base_reordering_consonants.steps[1].coverage=pre_base_reordering_consonants
      resources.devanagari=devanagari
      for s=1,#sequences do
        local sequence=sequences[s]
        local steps=sequence.steps
        local nofsteps=sequence.nofsteps
        local features=sequence.features
        local has_rphf=features.rphf
        local has_blwf=features.blwf
        if has_rphf and has_rphf.deva then
          devanagari.reph=true
        elseif has_blwf and has_blwf.deva then
          devanagari.vattu=true
          for i=1,nofsteps do
            local step=steps[i]
            local coverage=step.coverage
            if coverage then
              for k,v in next,coverage do
                if not blwfcache[k] then
                  blwfcache[k]=v
                end
              end
            end
          end
        end
        for kind,spec in next,features do
          if valid[kind] and valid_two(spec)then
            for i=1,nofsteps do
              local step=steps[i]
              local coverage=step.coverage
              if coverage then
                local reph=false
                if kind=="rphf" then
                  for k,v in next,ra do
                    local r=coverage[k]
                    if r then
                      local h=false
                      for k,v in next,halant do
                        local h=r[k]
                        if h then
                          reph=h.ligature or false
                          break
                        end
                      end
                      if reph then
                        break
                      end
                    end
                  end
                end
                seqsubset[#seqsubset+1]={ kind,coverage,reph }
              end
            end
          end
          if kind=="pref" then
            local steps=sequence.steps
            local nofsteps=sequence.nofsteps
            for i=1,nofsteps do
              local step=steps[i]
              local coverage=step.coverage
              if coverage then
                for k,v in next,halant do
                  local h=coverage[k]
                  if h then
                    local found=false
                    for k,v in next,h do
                      found=v and v.ligature
                      if found then
                        pre_base_reordering_consonants[k]=found
                        break
                      end
                    end
                    if found then
                      break
                    end
                  end
                end
              end
            end
          end
        end
      end
      if script=="deva" then
        sharedfeatures["dv04"]=true 
      elseif script=="dev2" then
        sharedfeatures["dv01"]=true 
        sharedfeatures["dv02"]=true 
        sharedfeatures["dv03"]=true 
        sharedfeatures["dv04"]=true 
      elseif script=="mlym" then
        sharedfeatures["pstf"]=true
      elseif script=="mlm2" then
        sharedfeatures["pstf"]=true
        sharedfeatures["pref"]=true
        sharedfeatures["dv03"]=true 
        gsubfeatures ["dv03"]=two_defaults 
        insert(sequences,insertindex,sequence_reorder_pre_base_reordering_consonants)
      elseif script=="taml" then
        sharedfeatures["dv04"]=true 
sharedfeatures["pstf"]=true
      elseif script=="tml2" then
      else
        report("todo: enable the right features for script %a",script)
      end
    end
  end
end
registerotffeature {
  name="devanagari",
  description="inject additional features",
  default=true,
  initializers={
    node=initializedevanagi,
  },
}
local show_syntax_errors=false
local function inject_syntax_error(head,current,char)
  local signal=copy_node(current)
  copyinjection(signal,current)
  if pre_mark[char] then
    setchar(signal,dotted_circle)
  else
    setchar(current,dotted_circle)
  end
  return insert_node_after(head,current,signal)
end
local function initialize_one(font,attr) 
  local tfmdata=fontdata[font]
  local datasets=otf.dataset(tfmdata,font,attr) 
  local devanagaridata=datasets.devanagari
  if not devanagaridata then
    devanagaridata={
      reph=false,
      vattu=false,
      blwfcache={},
    }
    datasets.devanagari=devanagaridata
    local resources=tfmdata.resources
    local devanagari=resources.devanagari
    for s=1,#datasets do
      local dataset=datasets[s]
      if dataset and dataset[1] then 
        local kind=dataset[4]
        if kind=="rphf" then
          devanagaridata.reph=true
        elseif kind=="blwf" then
          devanagaridata.vattu=true
          devanagaridata.blwfcache=devanagari.blwfcache
        end
      end
    end
  end
  return devanagaridata.reph,devanagaridata.vattu,devanagaridata.blwfcache
end
local function reorder_one(head,start,stop,font,attr,nbspaces)
  local reph,vattu,blwfcache=initialize_one(font,attr) 
  local current=start
  local n=getnext(start)
  local base=nil
  local firstcons=nil
  local lastcons=nil
  local basefound=false
  if reph and ra[getchar(start)] and halant[getchar(n)] then
    if n==stop then
      return head,stop,nbspaces
    end
    if getchar(getnext(n))==c_zwj then
      current=start
    else
      current=getnext(n)
      setprop(start,a_state,s_rphf)
    end
  end
  if getchar(current)==c_nbsp then
    if current==stop then
      stop=getprev(stop)
      head=remove_node(head,current)
      flush_node(current)
      return head,stop,nbspaces
    else
      nbspaces=nbspaces+1
      base=current
      firstcons=current
      lastcons=current
      current=getnext(current)
      if current~=stop then
        local char=getchar(current)
        if nukta[char] then
          current=getnext(current)
          char=getchar(current)
        end
        if char==c_zwj and current~=stop then
          local next=getnext(current)
          if next~=stop and halant[getchar(next)] then
            current=next
            next=getnext(current)
            local tmp=next and getnext(next) or nil 
            local changestop=next==stop
            local tempcurrent=copy_node(next)
            copyinjection(tempcurrent,next)
            local nextcurrent=copy_node(current)
            copyinjection(nextcurrent,current) 
            setlink(tempcurrent,nextcurrent)
            setprop(tempcurrent,a_state,s_blwf)
            tempcurrent=processcharacters(tempcurrent,font)
            setprop(tempcurrent,a_state,unsetvalue)
            if getchar(next)==getchar(tempcurrent) then
              flush_list(tempcurrent)
              if show_syntax_errors then
                head,current=inject_syntax_error(head,current,char)
              end
            else
              setchar(current,getchar(tempcurrent)) 
              local freenode=getnext(current)
              setlink(current,tmp)
              flush_node(freenode)
              flush_list(tempcurrent)
              if changestop then
                stop=current
              end
            end
          end
        end
      end
    end
  end
  while not basefound do
    local char=getchar(current)
    if consonant[char] then
      setprop(current,a_state,s_half)
      if not firstcons then
        firstcons=current
      end
      lastcons=current
      if not base then
        base=current
      elseif blwfcache[char] then
        setprop(current,a_state,s_blwf)
      else
        base=current
      end
    end
    basefound=current==stop
    current=getnext(current)
  end
  if base~=lastcons then
    local np=base
    local n=getnext(base)
    local ch=getchar(n)
    if nukta[ch] then
      np=n
      n=getnext(n)
      ch=getchar(n)
    end
    if halant[ch] then
      if lastcons~=stop then
        local ln=getnext(lastcons)
        if nukta[getchar(ln)] then
          lastcons=ln
        end
      end
      local nn=getnext(n)
      local ln=getnext(lastcons) 
      setlink(np,nn)
      setnext(lastcons,n)
      if ln then
        setprev(ln,n)
      end
      setnext(n,ln)
      setprev(n,lastcons)
      if lastcons==stop then
        stop=n
      end
    end
  end
  n=getnext(start)
  if n~=stop and ra[getchar(start)] and halant[getchar(n)] and not zw_char[getchar(getnext(n))] then
    local matra=base
    if base~=stop then
      local next=getnext(base)
      if dependent_vowel[getchar(next)] then
        matra=next
      end
    end
    local sp=getprev(start)
    local nn=getnext(n)
    local mn=getnext(matra)
    setlink(sp,nn)
    setlink(matra,start)
    setlink(n,mn)
    if head==start then
      head=nn
    end
    start=nn
    if matra==stop then
      stop=n
    end
  end
  local current=start
  while current~=stop do
    local next=getnext(current)
    if next~=stop and halant[getchar(next)] and getchar(getnext(next))==c_zwnj then
      setprop(current,a_state,unsetvalue)
    end
    current=next
  end
  if base~=stop and getprop(base,a_state) then
    local next=getnext(base)
    if halant[getchar(next)] and not (next~=stop and getchar(getnext(next))==c_zwj) then
      setprop(base,a_state,unsetvalue)
    end
  end
  local current,allreordered,moved=start,false,{ [base]=true }
  local a,b,p,bn=base,base,base,getnext(base)
  if base~=stop and nukta[getchar(bn)] then
    a,b,p=bn,bn,bn
  end
  while not allreordered do
    local c=current
    local n=getnext(current)
    local l=nil 
    if c~=stop then
      local ch=getchar(n)
      if nukta[ch] then
        c=n
        n=getnext(n)
        ch=getchar(n)
      end
      if c~=stop then
        if halant[ch] then
          c=n
          n=getnext(n)
          ch=getchar(n)
        end
        while c~=stop and dependent_vowel[ch] do
          c=n
          n=getnext(n)
          ch=getchar(n)
        end
        if c~=stop then
          if vowel_modifier[ch] then
            c=n
            n=getnext(n)
            ch=getchar(n)
          end
          if c~=stop and stress_tone_mark[ch] then
            c=n
            n=getnext(n)
          end
        end
      end
    end
    local bp=getprev(firstcons)
    local cn=getnext(current)
    local last=getnext(c)
    while cn~=last do
      if pre_mark[getchar(cn)] then
        if bp then
          setnext(bp,cn)
        end
        local prev,next=getboth(cn)
        if next then
          setprev(next,prev)
        end
        setnext(prev,next)
        if cn==stop then
          stop=prev
        end
        setprev(cn,bp)
        setlink(cn,firstcons)
        if firstcons==start then
          if head==start then
            head=cn
          end
          start=cn
        end
        break
      end
      cn=getnext(cn)
    end
    allreordered=c==stop
    current=getnext(c)
  end
  if reph or vattu then
    local current,cns=start,nil
    while current~=stop do
      local c=current
      local n=getnext(current)
      if ra[getchar(current)] and halant[getchar(n)] then
        c=n
        n=getnext(n)
        local b,bn=base,base
        while bn~=stop do
          local next=getnext(bn)
          if dependent_vowel[getchar(next)] then
            b=next
          end
          bn=next
        end
        if getprop(current,a_state)==s_rphf then
          if b~=current then
            if current==start then
              if head==start then
                head=n
              end
              start=n
            end
            if b==stop then
              stop=c
            end
            local prev=getprev(current)
            setlink(prev,n)
            local next=getnext(b)
            setlink(c,next)
            setlink(b,current)
          end
        elseif cns and getnext(cns)~=current then
          local cp=getprev(current)
          local cnsn=getnext(cns)
          setlink(cp,n)
          setlink(cns,current)
          setlink(c,cnsn)
          if c==stop then
            stop=cp
            break
          end
          current=getprev(n)
        end
      else
        local char=getchar(current)
        if consonant[char] then
          cns=current
          local next=getnext(cns)
          if halant[getchar(next)] then
            cns=next
          end
        elseif char==c_nbsp then
          nbspaces=nbspaces+1
          cns=current
          local next=getnext(cns)
          if halant[getchar(next)] then
            cns=next
          end
        end
      end
      current=getnext(current)
    end
  end
  if getchar(base)==c_nbsp then
    nbspaces=nbspaces-1
    head=remove_node(head,base)
    flush_node(base)
  end
  return head,stop,nbspaces
end
function handlers.devanagari_reorder_matras(head,start) 
  local current=start 
  local startfont=getfont(start)
  local startattr=getprop(start,a_syllabe)
  while current do
    local char=ischar(current,startfont)
    local next=getnext(current)
    if char and getprop(current,a_syllabe)==startattr then
      if halant[char] and not getprop(current,a_state) then
        if next then
          local char=ischar(next,startfont)
          if char and zw_char[char] and getprop(next,a_syllabe)==startattr then
            current=next
            next=getnext(current)
          end
        end
        local startnext=getnext(start)
        head=remove_node(head,start)
        setlink(start,next)
        setlink(current,start)
        start=startnext
        break
      end
    else
      break
    end
    current=next
  end
  return head,start,true
end
function handlers.devanagari_reorder_reph(head,start)
  local current=getnext(start)
  local startnext=nil
  local startprev=nil
  local startfont=getfont(start)
  local startattr=getprop(start,a_syllabe)
  ::step_1::
  ::step_2::
  while current do
    local char=ischar(current,startfont)
    if char and getprop(current,a_syllabe)==startattr then
      if halant[char] and not getprop(current,a_state) then
        local next=getnext(current)
        if next then
          local nextchar=ischar(next,startfont)
          if nextchar and zw_char[nextchar] and getprop(next,a_syllabe)==startattr then
            current=next
            next=getnext(current)
          end
        end
        startnext=getnext(start)
        head=remove_node(head,start)
        setlink(start,next)
        setlink(current,start)
        start=startnext
        startattr=getprop(start,a_syllabe)
        break
      end
      current=getnext(current)
    else
      break
    end
  end
  ::step_3::
  ::step_4::
  if not startnext then
    current=getnext(start)
    while current do
      local char=ischar(current,startfont)
      if char and getprop(current,a_syllabe)==startattr then
        if getprop(current,a_state)==s_pstf then 
          startnext=getnext(start)
          head=remove_node(head,start)
          setlink(getprev(current),start)
          setlink(start,current)
          start=startnext
          startattr=getprop(start,a_syllabe)
          break
        end
        current=getnext(current)
      else
        break
      end
    end
  end
  ::step_5::
  if not startnext then
    current=getnext(start)
    local c=nil
    while current do
      local char=ischar(current,startfont)
      if char and getprop(current,a_syllabe)==startattr then
        if not c and mark_above_below_post[char] and not after_subscript[char] then
          c=current
        end
        current=getnext(current)
      else
        break
      end
    end
    if c then
      startnext=getnext(start)
      head=remove_node(head,start)
      setlink(getprev(c),start)
      setlink(start,c)
      start=startnext
      startattr=getprop(start,a_syllabe)
    end
  end
  ::step_6::
  if not startnext then
    current=start
    local next=getnext(current)
    while next do
      local nextchar=ischar(next,startfont)
      if nextchar and getprop(next,a_syllabe)==startattr then
        current=next
        next=getnext(current)
      else
        break
      end
    end
    if start~=current then
      startnext=getnext(start)
      head=remove_node(head,start)
      setlink(start,getnext(current))
      setlink(current,start)
      start=startnext
    end
  end
  return head,start,true
end
function handlers.devanagari_reorder_pre_base_reordering_consonants(head,start)
  local current=start
  local startnext=nil
  local startprev=nil
  local startfont=getfont(start)
  local startattr=getprop(start,a_syllabe)
  while current do
    local char=ischar(current,startfont)
    if char and getprop(current,a_syllabe)==startattr then
      local next=getnext(current)
      if halant[char] and not getprop(current,a_state) then
        if next then
          local nextchar=ischar(next,startfont)
          if nextchar and getprop(next,a_syllabe)==startattr then
            if nextchar==c_zwnj or nextchar==c_zwj then
              current=next
              next=getnext(current)
            end
          end
        end
        startnext=getnext(start)
        removenode(start,start)
        setlink(start,next)
        setlink(current,start)
        start=startnext
        break
      end
      current=next
    else
      break
    end
  end
  if not startnext then
    current=getnext(start)
    startattr=getprop(start,a_syllabe)
    while current do
      local char=ischar(current,startfont)
      if char and getprop(current,a_syllabe)==startattr then
        if not consonant[char] and getprop(current,a_state) then 
          startnext=getnext(start)
          removenode(start,start)
          setlink(getprev(current),start)
          setlink(start,current)
          start=startnext
          break
        end
        current=getnext(current)
      else
        break
      end
    end
  end
  return head,start,true
end
function handlers.devanagari_remove_joiners(head,start,kind,lookupname,replacement)
  local stop=getnext(start)
  local font=getfont(start)
  local last=start
  while stop do
    local char=ischar(stop,font)
    if char and (char==c_zwnj or char==c_zwj) then
      last=stop
      stop=getnext(stop)
    else
      break
    end
  end
  local prev=getprev(start)
  if stop then
    setnext(last)
    setlink(prev,stop)
  elseif prev then
    setnext(prev)
  end
  if head==start then
    head=stop
  end
  flush_list(start)
  return head,stop,true
end
local function initialize_two(font,attr)
  local devanagari=fontdata[font].resources.devanagari
  if devanagari then
    return devanagari.seqsubset or {},devanagari.reorderreph or {}
  else
    return {},{}
  end
end
local function reorder_two(head,start,stop,font,attr,nbspaces) 
  local seqsubset,reorderreph=initialize_two(font,attr)
  local reph=false 
  local halfpos=nil
  local basepos=nil
  local subpos=nil
  local postpos=nil
  local locl={}
  for i=1,#seqsubset do
    local subset=seqsubset[i]
    local kind=subset[1]
    local lookupcache=subset[2]
    if kind=="rphf" then
      reph=subset[3]
      local current=start
      local last=getnext(stop)
      while current~=last do
        if current~=stop then
          local c=locl[current] or getchar(current)
          local found=lookupcache[c]
          if found then
            local next=getnext(current)
            local n=locl[next] or getchar(next)
            if found[n] then  
              local afternext=next~=stop and getnext(next)
              if afternext and zw_char[getchar(afternext)] then 
                current=afternext 
              elseif current==start then
                setprop(current,a_state,s_rphf)
                current=next
              else
                current=next
              end
            end
          end
        end
        current=getnext(current)
      end
    elseif kind=="pref" then
      local current=start
      local last=getnext(stop)
      while current~=last do
        if current~=stop then
          local c=locl[current] or getchar(current)
          local found=lookupcache[c]
          if found then 
            local next=getnext(current)
            local n=locl[next] or getchar(next)
            if found[n] then
              setprop(current,a_state,s_pref)
              setprop(next,a_state,s_pref)
              current=next
            end
          end
        end
        current=getnext(current)
      end
    elseif kind=="half" then 
      local current=start
      local last=getnext(stop)
      while current~=last do
        if current~=stop then
          local c=locl[current] or getchar(current)
          local found=lookupcache[c]
          if found then
            local next=getnext(current)
            local n=locl[next] or getchar(next)
            if found[n] then
              if next~=stop and getchar(getnext(next))==c_zwnj then  
                current=next
              else
                setprop(current,a_state,s_half)
                if not halfpos then
                  halfpos=current
                end
              end
              current=getnext(current)
            end
          end
        end
        current=getnext(current)
      end
    elseif kind=="blwf" then 
      local current=start
      local last=getnext(stop)
      while current~=last do
        if current~=stop then
          local c=locl[current] or getchar(current)
          local found=lookupcache[c]
          if found then
            local next=getnext(current)
            local n=locl[next] or getchar(next)
            if found[n] then
              setprop(current,a_state,s_blwf)
              setprop(next,a_state,s_blwf)
              current=next
              subpos=current
            end
          end
        end
        current=getnext(current)
      end
    elseif kind=="pstf" then 
      local current=start
      local last=getnext(stop)
      while current~=last do
        if current~=stop then
          local c=locl[current] or getchar(current)
          local found=lookupcache[c]
          if found then
            local next=getnext(current)
            local n=locl[next] or getchar(next)
            if found[n] then
              setprop(current,a_state,s_pstf)
              setprop(next,a_state,s_pstf)
              current=next
              postpos=current
            end
          end
        end
        current=getnext(current)
      end
    end
  end
  reorderreph.coverage={ [reph]=true }
  local current,base,firstcons=start,nil,nil
  if getprop(start,a_state)==s_rphf then
    current=getnext(getnext(start))
  end
  if current~=getnext(stop) and getchar(current)==c_nbsp then
    if current==stop then
      stop=getprev(stop)
      head=remove_node(head,current)
      flush_node(current)
      return head,stop,nbspaces
    else
      nbspaces=nbspaces+1
      base=current
      current=getnext(current)
      if current~=stop then
        local char=getchar(current)
        if nukta[char] then
          current=getnext(current)
          char=getchar(current)
        end
        if char==c_zwj then
          local next=getnext(current)
          if current~=stop and next~=stop and halant[getchar(next)] then
            current=next
            next=getnext(current)
            local tmp=getnext(next)
            local changestop=next==stop
            setnext(next)
            setprop(current,a_state,s_pref)
            current=processcharacters(current,font)
            setprop(current,a_state,s_blwf)
            current=processcharacters(current,font)
            setprop(current,a_state,s_pstf)
            current=processcharacters(current,font)
            setprop(current,a_state,unsetvalue)
            if halant[getchar(current)] then
              setnext(getnext(current),tmp)
              if show_syntax_errors then
                head,current=inject_syntax_error(head,current,char)
              end
            else
              setnext(current,tmp) 
              if changestop then
                stop=current
              end
            end
          end
        end
      end
    end
  else 
    local last=getnext(stop)
    while current~=last do  
      local next=getnext(current)
      if consonant[getchar(current)] then
        if not (current~=stop and next~=stop and halant[getchar(next)] and getchar(getnext(next))==c_zwj) then
          if not firstcons then
            firstcons=current
          end
          local a=getprop(current,a_state)
          if not (a==s_pref or a==s_blwf or a==s_pstf) then
            base=current
          end
        end
      end
      current=next
    end
    if not base then
      base=firstcons
    end
  end
  if not base then
    if getprop(start,a_state)==s_rphf then
      setprop(start,a_state,unsetvalue)
    end
    return head,stop,nbspaces
  else
    if getprop(base,a_state) then
      setprop(base,a_state,unsetvalue)
    end
    basepos=base
  end
  if not halfpos then
    halfpos=base
  end
  if not subpos then
    subpos=base
  end
  if not postpos then
    postpos=subpos or base
  end
  local moved={}
  local current=start
  local last=getnext(stop)
  while current~=last do
    local char,target,cn=locl[current] or getchar(current),nil,getnext(current)
    local tpm=twopart_mark[char]
    if tpm then
      local extra=copy_node(current)
      copyinjection(extra,current)
      char=tpm[1]
      setchar(current,char)
      setchar(extra,tpm[2])
      head=insert_node_after(head,current,extra)
    end
    if not moved[current] and dependent_vowel[char] then
      if pre_mark[char] then      
        moved[current]=true
        local prev,next=getboth(current)
        setlink(prev,next)
        if current==stop then
          stop=getprev(current)
        end
        if halfpos==start then
          if head==start then
            head=current
          end
          start=current
        end
        setlink(getprev(halfpos),current)
        setlink(current,halfpos)
        halfpos=current
      elseif above_mark[char] then  
        target=basepos
        if subpos==basepos then
          subpos=current
        end
        if postpos==basepos then
          postpos=current
        end
        basepos=current
      elseif below_mark[char] then  
        target=subpos
        if postpos==subpos then
          postpos=current
        end
        subpos=current
      elseif post_mark[char] then  
        target=postpos
        postpos=current
      end
      if mark_above_below_post[char] then
        local prev=getprev(current)
        if prev~=target then
          local next=getnext(current)
          setlink(prev,next)
          if current==stop then
            stop=prev
          end
          setlink(current,getnext(target))
          setlink(target,current)
        end
      end
    end
    current=cn
  end
  local current,c=start,nil
  while current~=stop do
    local char=getchar(current)
    if halant[char] or stress_tone_mark[char] then
      if not c then
        c=current
      end
    else
      c=nil
    end
    local next=getnext(current)
    if c and nukta[getchar(next)] then
      if head==c then
        head=next
      end
      if stop==next then
        stop=current
      end
      setlink(getprev(c),next)
      local nextnext=getnext(next)
      setnext(current,nextnext)
      local nextnextnext=getnext(nextnext)
      if nextnextnext then
        setprev(nextnextnext,current)
      end
      setlink(nextnext,c)
    end
    if stop==current then break end
    current=getnext(current)
  end
  if getchar(base)==c_nbsp then
    if base==stop then
      stop=getprev(stop)
    end
    nbspaces=nbspaces-1
    head=remove_node(head,base)
    flush_node(base)
  end
  return head,stop,nbspaces
end
local separator={}
imerge(separator,consonant)
imerge(separator,independent_vowel)
imerge(separator,dependent_vowel)
imerge(separator,vowel_modifier)
imerge(separator,stress_tone_mark)
for k,v in next,nukta do separator[k]=true end
for k,v in next,halant do separator[k]=true end
local function analyze_next_chars_one(c,font,variant)
  local n=getnext(c)
  if not n then
    return c
  end
  if variant==1 then
    local v=ischar(n,font)
    if v and nukta[v] then
      n=getnext(n)
      if n then
        v=ischar(n,font)
      end
    end
    if n and v then
      local nn=getnext(n)
      if nn then
        local vv=ischar(nn,font)
        if vv then
          local nnn=getnext(nn)
          if nnn then
            local vvv=ischar(nnn,font)
            if vvv then
              if vv==c_zwj and consonant[vvv] then
                c=nnn
              elseif (vv==c_zwnj or vv==c_zwj) and halant[vvv] then
                local nnnn=getnext(nnn)
                if nnnn then
                  local vvvv=ischar(nnnn,font)
                  if vvvv and consonant[vvvv] then
                    c=nnnn
                  end
                end
              end
            end
          end
        end
      end
    end
  elseif variant==2 then
    local v=ischar(n,font)
    if v and nukta[v] then
      c=n
    end
    n=getnext(c)
    if n then
      v=ischar(n,font)
      if v then
        local nn=getnext(n)
        if nn then
          local vv=ischar(nn,font)
          if vv and zw_char[v] then
            n=nn
            v=vv
            nn=getnext(nn)
            vv=nn and ischar(nn,font)
          end
          if vv and halant[v] and consonant[vv] then
            c=nn
          end
        end
      end
    end
  end
  local n=getnext(c)
  if not n then
    return c
  end
  local v=ischar(n,font)
  if not v then
    return c
  end
  if dependent_vowel[v] then
    c=getnext(c)
    n=getnext(c)
    if not n then
      return c
    end
    v=ischar(n,font)
    if not v then
      return c
    end
  end
  if nukta[v] then
    c=getnext(c)
    n=getnext(c)
    if not n then
      return c
    end
    v=ischar(n,font)
    if not v then
      return c
    end
  end
  if halant[v] then
    c=getnext(c)
    n=getnext(c)
    if not n then
      return c
    end
    v=ischar(n,font)
    if not v then
      return c
    end
  end
  if vowel_modifier[v] then
    c=getnext(c)
    n=getnext(c)
    if not n then
      return c
    end
    v=ischar(n,font)
    if not v then
      return c
    end
  end
  if stress_tone_mark[v] then
    c=getnext(c)
    n=getnext(c)
    if not n then
      return c
    end
    v=ischar(n,font)
    if not v then
      return c
    end
  end
  if stress_tone_mark[v] then
    return n
  else
    return c
  end
end
local function analyze_next_chars_two(c,font)
  local n=getnext(c)
  if not n then
    return c
  end
  local v=ischar(n,font)
  if v and nukta[v] then
    c=n
  end
  n=c
  while true do
    local nn=getnext(n)
    if nn then
      local vv=ischar(nn,font)
      if vv then
        if halant[vv] then
          n=nn
          local nnn=getnext(nn)
          if nnn then
            local vvv=ischar(nnn,font)
            if vvv and zw_char[vvv] then
              n=nnn
            end
          end
        elseif vv==c_zwnj or vv==c_zwj then
          local nnn=getnext(nn)
          if nnn then
            local vvv=ischar(nnn,font)
            if vvv and halant[vvv] then
              n=nnn
            end
          end
        else
          break
        end
        local nn=getnext(n)
        if nn then
          local vv=ischar(nn,font)
          if vv and consonant[vv] then
            n=nn
            local nnn=getnext(nn)
            if nnn then
              local vvv=ischar(nnn,font)
              if vvv and nukta[vvv] then
                n=nnn
              end
            end
            c=n
          else
            break
          end
        else
          break
        end
      else
        break
      end
    else
      break
    end
  end
  if not c then
    return
  end
  local n=getnext(c)
  if not n then
    return c
  end
  local v=ischar(n,font)
  if not v then
    return c
  end
  if anudatta[v] then
    c=n
    n=getnext(c)
    if not n then
      return c
    end
    v=ischar(n,font)
    if not v then
      return c
    end
  end
  if halant[v] then
    c=n
    n=getnext(c)
    if not n then
      return c
    end
    v=ischar(n,font)
    if not v then
      return c
    end
    if v==c_zwnj or v==c_zwj then
      c=n
      n=getnext(c)
      if not n then
        return c
      end
      v=ischar(n,font)
      if not v then
        return c
      end
    end
  else
    if dependent_vowel[v] then
      c=n
      n=getnext(c)
      if not n then
        return c
      end
      v=ischar(n,font)
      if not v then
        return c
      end
    end
    if nukta[v] then
      c=n
      n=getnext(c)
      if not n then
        return c
      end
      v=ischar(n,font)
      if not v then
        return c
      end
    end
    if halant[v] then
      c=n
      n=getnext(c)
      if not n then
        return c
      end
      v=ischar(n,font)
      if not v then
        return c
      end
    end
  end
  if vowel_modifier[v] then
    c=n
    n=getnext(c)
    if not n then
      return c
    end
    v=ischar(n,font)
    if not v then
      return c
    end
  end
  if stress_tone_mark[v] then
    c=n
    n=getnext(c)
    if not n then
      return c
    end
    v=ischar(n,font)
    if not v then
      return c
    end
  end
  if stress_tone_mark[v] then
    return n
  else
    return c
  end
end
local function method_one(head,font,attr)
  local current=head
  local start=true
  local done=false
  local nbspaces=0
  while current do
    local char=ischar(current,font)
    if char then
      done=true
      local syllablestart=current
      local syllableend=nil
      local c=current
      local n=getnext(c)
      local first=char
      if n and ra[first] then
        local second=ischar(n,font)
        if second and halant[second] then
          local n=getnext(n)
          if n then
            local third=ischar(n,font)
            if third then
              c=n
              first=third
            end
          end
        end
      end
      local standalone=first==c_nbsp
      if standalone then
        local prev=getprev(current)
        if prev then
          local prevchar=ischar(prev,font)
          if not prevchar then
          elseif not separator[prevchar] then
          else
            standalone=false
          end
        else
        end
      end
      if standalone then
        local syllableend=analyze_next_chars_one(c,font,2)
        current=getnext(syllableend)
        if syllablestart~=syllableend then
          head,current,nbspaces=reorder_one(head,syllablestart,syllableend,font,attr,nbspaces)
          current=getnext(current)
        end
      else
        if consonant[char] then
          local prevc=true
          while prevc do
            prevc=false
            local n=getnext(current)
            if not n then
              break
            end
            local v=ischar(n,font)
            if not v then
              break
            end
            if nukta[v] then
              n=getnext(n)
              if not n then
                break
              end
              v=ischar(n,font)
              if not v then
                break
              end
            end
            if halant[v] then
              n=getnext(n)
              if not n then
                break
              end
              v=ischar(n,font)
              if not v then
                break
              end
              if v==c_zwnj or v==c_zwj then
                n=getnext(n)
                if not n then
                  break
                end
                v=ischar(n,font)
                if not v then
                  break
                end
              end
              if consonant[v] then
                prevc=true
                current=n
              end
            end
          end
          local n=getnext(current)
          if n then
            local v=ischar(n,font)
            if v and nukta[v] then
              current=n
              n=getnext(current)
            end
          end
          syllableend=current
          current=n
          if current then
            local v=ischar(current,font)
            if not v then
            elseif halant[v] then
              local n=getnext(current)
              if n then
                local v=ischar(n,font)
                if v and zw_char[v] then
                  syllableend=n
                  current=getnext(n)
                else
                  syllableend=current
                  current=n
                end
              else
                syllableend=current
                current=n
              end
            else
              if dependent_vowel[v] then
                syllableend=current
                current=getnext(current)
                v=ischar(current,font)
              end
              if v and vowel_modifier[v] then
                syllableend=current
                current=getnext(current)
                v=ischar(current,font)
              end
              if v and stress_tone_mark[v] then
                syllableend=current
                current=getnext(current)
              end
            end
          end
          if syllablestart~=syllableend then
            head,current,nbspaces=reorder_one(head,syllablestart,syllableend,font,attr,nbspaces)
            current=getnext(current)
          end
        elseif independent_vowel[char] then
          syllableend=current
          current=getnext(current)
          if current then
            local v=ischar(current,font)
            if v then
              if vowel_modifier[v] then
                syllableend=current
                current=getnext(current)
                v=ischar(current,font)
              end
              if v and stress_tone_mark[v] then
                syllableend=current
                current=getnext(current)
              end
            end
          end
        else
          if show_syntax_errors then
            local mark=mark_four[char]
            if mark then
              head,current=inject_syntax_error(head,current,char)
            end
          end
          current=getnext(current)
        end
      end
    else
      current=getnext(current)
    end
    start=false
  end
  if nbspaces>0 then
    head=replace_all_nbsp(head)
  end
  return head,done
end
local function method_two(head,font,attr)
  local current=head
  local start=true
  local done=false
  local syllabe=0
  local nbspaces=0
  while current do
    local syllablestart=nil
    local syllableend=nil
    local char=ischar(current,font)
    if char then
      done=true
      syllablestart=current
      local c=current
      local n=getnext(current)
      if n and ra[char] then
        local nextchar=ischar(n,font)
        if nextchar and halant[nextchar] then
          local n=getnext(n)
          if n then
            local nextnextchar=ischar(n,font)
            if nextnextchar then
              c=n
              char=nextnextchar
            end
          end
        end
      end
      if independent_vowel[char] then
        current=analyze_next_chars_one(c,font,1)
        syllableend=current
      else
        local standalone=char==c_nbsp
        if standalone then
          nbspaces=nbspaces+1
          local p=getprev(current)
          if not p then
          elseif ischar(p,font) then
          elseif not separator[getchar(p)] then
          else
            standalone=false
          end
        end
        if standalone then
          current=analyze_next_chars_one(c,font,2)
          syllableend=current
        elseif consonant[getchar(current)] then
          current=analyze_next_chars_two(current,font) 
          syllableend=current
        end
      end
    end
    if syllableend then
      syllabe=syllabe+1
      local c=syllablestart
      local n=getnext(syllableend)
      while c~=n do
        setprop(c,a_syllabe,syllabe)
        c=getnext(c)
      end
    end
    if syllableend and syllablestart~=syllableend then
      head,current,nbspaces=reorder_two(head,syllablestart,syllableend,font,attr,nbspaces)
    end
    if not syllableend and show_syntax_errors then
      local char=ischar(current,font)
      if char and not getprop(current,a_state) then
        local mark=mark_four[char]
        if mark then
          head,current=inject_syntax_error(head,current,char)
        end
      end
    end
    start=false
    current=getnext(current)
  end
  if nbspaces>0 then
    head=replace_all_nbsp(head)
  end
  return head,done
end
for i=1,nofscripts do
  methods[scripts_one[i]]=method_one
  methods[scripts_two[i]]=method_two
end

end --- [luaotfload, fontloader-2018-10-08.lua scope for “font-osd”] ---


do  --- [luaotfload, fontloader-2018-10-08.lua scope for “font-ocl” 49cf3230228aa7f2d19cd491f55f5395] ---

if not modules then modules={} end modules ['font-ocl']={
  version=1.001,
  comment="companion to font-ini.mkiv",
  author="Hans Hagen, PRAGMA-ADE, Hasselt NL",
  copyright="PRAGMA ADE / ConTeXt Development Team",
  license="see context related readme files"
}
local tostring,tonumber,next=tostring,tonumber,next
local round,max=math.round,math.round
local sortedkeys,sortedhash=table.sortedkeys,table.sortedhash
local setmetatableindex=table.setmetatableindex
local formatters=string.formatters
local tounicode=fonts.mappings.tounicode
local helpers=fonts.helpers
local charcommand=helpers.commands.char
local rightcommand=helpers.commands.right
local leftcommand=helpers.commands.left
local downcommand=helpers.commands.down
local otf=fonts.handlers.otf
local f_color=formatters["%.3f %.3f %.3f rg"]
local f_gray=formatters["%.3f g"]
if context then
  local startactualtext=nil
  local stopactualtext=nil
  function otf.getactualtext(s)
    if not startactualtext then
      startactualtext=backends.codeinjections.startunicodetoactualtextdirect
      stopactualtext=backends.codeinjections.stopunicodetoactualtextdirect
    end
    return startactualtext(s),stopactualtext()
  end
else
  local tounicode=fonts.mappings.tounicode16
  function otf.getactualtext(s)
    return
      "/Span << /ActualText <feff"..s.."> >> BDC",
      "EMC"
  end
end
local sharedpalettes={}
local hash=setmetatableindex(function(t,k)
  local v={ "pdf","direct",k }
  t[k]=v
  return v
end)
if context then
  local colors=attributes.list[attributes.private('color')] or {}
  local transparencies=attributes.list[attributes.private('transparency')] or {}
  function otf.registerpalette(name,values)
    sharedpalettes[name]=values
    for i=1,#values do
      local v=values[i]
      local c=nil
      local t=nil
      if type(v)=="table" then
        c=colors.register(name,"rgb",
          max(round((v.r or 0)*255),255)/255,
          max(round((v.g or 0)*255),255)/255,
          max(round((v.b or 0)*255),255)/255
        )
      else
        c=colors[v]
        t=transparencies[v]
      end
      if c and t then
        values[i]=hash[lpdf.color(1,c).." "..lpdf.transparency(t)]
      elseif c then
        values[i]=hash[lpdf.color(1,c)]
      elseif t then
        values[i]=hash[lpdf.color(1,t)]
      end
    end
  end
else 
  function otf.registerpalette(name,values)
    sharedpalettes[name]=values
    for i=1,#values do
      local v=values[i]
      values[i]=hash[f_color(
        max(round((v.r or 0)*255),255)/255,
        max(round((v.g or 0)*255),255)/255,
        max(round((v.b or 0)*255),255)/255
      )]
    end
  end
end
local function convert(t,k)
  local v={}
  for i=1,#k do
    local p=k[i]
    local r,g,b=p[1],p[2],p[3]
    if r==g and g==b then
      v[i]=hash[f_gray(r/255)]
    else
      v[i]=hash[f_color(r/255,g/255,b/255)]
    end
  end
  t[k]=v
  return v
end
local start={ "pdf","mode","font" }
local push={ "pdf","page","q" }
local pop={ "pdf","page","Q" }
if not LUATEXFUNCTIONALITY or LUATEXFUNCTIONALITY<6472 then 
  start={ "nop" }
end
local function initialize(tfmdata,kind,value) 
  if value then
    local resources=tfmdata.resources
    local palettes=resources.colorpalettes
    if palettes then
      local converted=resources.converted
      if not converted then
        converted=setmetatableindex(convert)
        resources.converted=converted
      end
      local colorvalues=sharedpalettes[value] or converted[palettes[tonumber(value) or 1] or palettes[1]] or {}
      local classes=#colorvalues
      if classes==0 then
        return
      end
      local characters=tfmdata.characters
      local descriptions=tfmdata.descriptions
      local properties=tfmdata.properties
      properties.virtualized=true
      tfmdata.fonts={
        { id=0 }
      }
      local getactualtext=otf.getactualtext
      local default=colorvalues[#colorvalues]
      local b,e=getactualtext(tounicode(0xFFFD))
      local actualb={ "pdf","page",b } 
      local actuale={ "pdf","page",e }
      for unicode,character in next,characters do
        local description=descriptions[unicode]
        if description then
          local colorlist=description.colors
          if colorlist then
            local u=description.unicode or characters[unicode].unicode
            local w=character.width or 0
            local s=#colorlist
            local goback=w~=0 and leftcommand[w] or nil 
            local t={
              start,
              not u and actualb or { "pdf","page",(getactualtext(tounicode(u))) }
            }
            local n=2
            local l=nil
            local f=false
            for i=1,s do
              local entry=colorlist[i]
              local v=colorvalues[entry.class] or default
              if v and l~=v then
                if f then
                  n=n+1 t[n]=pop
                end
                n=n+1 t[n]=push
                f=true
                n=n+1 t[n]=v
                l=v
              end
              n=n+1 t[n]=charcommand[entry.slot]
              if s>1 and i<s and goback then
                n=n+1 t[n]=goback
              end
            end
            if f then
              n=n+1 t[n]=pop
            end
            n=n+1 t[n]=actuale
            character.commands=t
          end
        end
      end
    end
  end
end
fonts.handlers.otf.features.register {
  name="colr",
  description="color glyphs",
  manipulators={
    base=initialize,
    node=initialize,
  }
}
do
  local nofstreams=0
  local f_name=formatters[ [[pdf-glyph-%05i]] ]
  local f_used=context and formatters[ [[original:///%s]] ] or formatters[ [[%s]] ]
  local hashed={}
  local cache={}
  if epdf then
    local openpdf=epdf.openMemStream
    function otf.storepdfdata(pdf)
      local done=hashed[pdf]
      if not done then
        nofstreams=nofstreams+1
        local o,n=openpdf(pdf,#pdf,f_name(nofstreams))
        cache[n]=o 
        done=f_used(n)
        hashed[pdf]=done
      end
      return nil,done,nil
    end
  else
    local openpdf=pdfe.new
    function otf.storepdfdata(pdf)
      local done=hashed[pdf]
      if not done then
        nofstreams=nofstreams+1
        local f=f_name(nofstreams)
        local n=openpdf(pdf,#pdf,f)
        done=f_used(n)
        hashed[pdf]=done
      end
      return nil,done,nil
    end
  end
end
local function pdftovirtual(tfmdata,pdfshapes,kind) 
  if not tfmdata or not pdfshapes or not kind then
    return
  end
  local characters=tfmdata.characters
  local properties=tfmdata.properties
  local parameters=tfmdata.parameters
  local hfactor=parameters.hfactor
  properties.virtualized=true
  tfmdata.fonts={
    { id=0 } 
  }
  local getactualtext=otf.getactualtext
  local storepdfdata=otf.storepdfdata
  local b,e=getactualtext(tounicode(0xFFFD))
  local actualb={ "pdf","page",b } 
  local actuale={ "pdf","page",e }
  for unicode,character in sortedhash(characters) do 
    local index=character.index
    if index then
      local pdf=pdfshapes[index]
      local typ=type(pdf)
      local data=nil
      local dx=nil
      local dy=nil
      if typ=="table" then
        data=pdf.data
        dx=pdf.dx or 0
        dy=pdf.dy or 0
      elseif typ=="string" then
        data=pdf
        dx=0
        dy=0
      end
      if data then
        local setcode,name,nilcode=storepdfdata(data)
        if name then
          local bt=unicode and getactualtext(unicode)
          local wd=character.width or 0
          local ht=character.height or 0
          local dp=character.depth or 0
          character.commands={
            not unicode and actualb or { "pdf","page",(getactualtext(unicode)) },
            downcommand[dp+dy*hfactor],
            rightcommand[dx*hfactor],
            { "image",{ filename=name,width=wd,height=ht,depth=dp } },
            actuale,
          }
          character[kind]=true
        end
      end
    end
  end
end
local otfsvg=otf.svg or {}
otf.svg=otfsvg
otf.svgenabled=true
do
  local report_svg=logs.reporter("fonts","svg conversion")
  local loaddata=io.loaddata
  local savedata=io.savedata
  local remove=os.remove
  if context and xml.convert then
    local xmlconvert=xml.convert
    local xmlfirst=xml.first
    function otfsvg.filterglyph(entry,index)
      local svg=xmlconvert(entry.data)
      local root=svg and xmlfirst(svg,"/svg[@id='glyph"..index.."']")
      local data=root and tostring(root)
      return data
    end
  else
    function otfsvg.filterglyph(entry,index) 
      return entry.data
    end
  end
  local runner=sandbox and sandbox.registerrunner {
    name="otfsvg",
    program="inkscape",
    method="pipeto",
    template="--shell > temp-otf-svg-shape.log",
    reporter=report_svg,
  }
  if not runner then
    runner=function()
      return io.open("inkscape --shell > temp-otf-svg-shape.log","w")
    end
  end
  function otfsvg.topdf(svgshapes)
    local pdfshapes={}
    local inkscape=runner()
    if inkscape then
      local nofshapes=#svgshapes
      local f_svgfile=formatters["temp-otf-svg-shape-%i.svg"]
      local f_pdffile=formatters["temp-otf-svg-shape-%i.pdf"]
      local f_convert=formatters["%s --export-pdf=%s\n"]
      local filterglyph=otfsvg.filterglyph
      local nofdone=0
      report_svg("processing %i svg containers",nofshapes)
      statistics.starttiming()
      for i=1,nofshapes do
        local entry=svgshapes[i]
        for index=entry.first,entry.last do
          local data=filterglyph(entry,index)
          if data and data~="" then
            local svgfile=f_svgfile(index)
            local pdffile=f_pdffile(index)
            savedata(svgfile,data)
            inkscape:write(f_convert(svgfile,pdffile))
            pdfshapes[index]=true
            nofdone=nofdone+1
            if nofdone%100==0 then
              report_svg("%i shapes processed",nofdone)
            end
          end
        end
      end
      inkscape:write("quit\n")
      inkscape:close()
      report_svg("processing %i pdf results",nofshapes)
      for index in next,pdfshapes do
        local svgfile=f_svgfile(index)
        local pdffile=f_pdffile(index)
        pdfshapes[index]=loaddata(pdffile)
        remove(svgfile)
        remove(pdffile)
      end
      statistics.stoptiming()
      if statistics.elapsedseconds then
        report_svg("svg conversion time %s",statistics.elapsedseconds() or "-")
      end
    end
    return pdfshapes
  end
end
local function initializesvg(tfmdata,kind,value) 
  if value and otf.svgenabled then
    local svg=tfmdata.properties.svg
    local hash=svg and svg.hash
    local timestamp=svg and svg.timestamp
    if not hash then
      return
    end
    local pdffile=containers.read(otf.pdfcache,hash)
    local pdfshapes=pdffile and pdffile.pdfshapes
    if not pdfshapes or pdffile.timestamp~=timestamp then
      local svgfile=containers.read(otf.svgcache,hash)
      local svgshapes=svgfile and svgfile.svgshapes
      pdfshapes=svgshapes and otfsvg.topdf(svgshapes) or {}
      containers.write(otf.pdfcache,hash,{
        pdfshapes=pdfshapes,
        timestamp=timestamp,
      })
    end
    pdftovirtual(tfmdata,pdfshapes,"svg")
  end
end
fonts.handlers.otf.features.register {
  name="svg",
  description="svg glyphs",
  manipulators={
    base=initializesvg,
    node=initializesvg,
  }
}
local otfsbix=otf.sbix or {}
otf.sbix=otfsbix
otf.sbixenabled=true
do
  local report_sbix=logs.reporter("fonts","sbix conversion")
  local loaddata=io.loaddata
  local savedata=io.savedata
  local remove=os.remove
  local runner=sandbox and sandbox.registerrunner {
    name="otfsbix",
    program="gm",
    template="convert -quality 100 temp-otf-sbix-shape.sbix temp-otf-sbix-shape.pdf > temp-otf-svg-shape.log",
  }
  if not runner then
    runner=function()
      return os.execute("gm convert -quality 100 temp-otf-sbix-shape.sbix temp-otf-sbix-shape.pdf > temp-otf-svg-shape.log")
    end
  end
  function otfsbix.topdf(sbixshapes)
    local pdfshapes={}
    local sbixfile="temp-otf-sbix-shape.sbix"
    local pdffile="temp-otf-sbix-shape.pdf"
    local nofdone=0
    local indices=sortedkeys(sbixshapes) 
    local nofindices=#indices
    report_sbix("processing %i sbix containers",nofindices)
    statistics.starttiming()
    for i=1,nofindices do
      local index=indices[i]
      local entry=sbixshapes[index]
      local data=entry.data
      local x=entry.x
      local y=entry.y
      savedata(sbixfile,data)
      runner()
      pdfshapes[index]={
        x=x~=0 and x or nil,
        y=y~=0 and y or nil,
        data=loaddata(pdffile),
      }
      nofdone=nofdone+1
      if nofdone%100==0 then
        report_sbix("%i shapes processed",nofdone)
      end
    end
    report_sbix("processing %i pdf results",nofindices)
    remove(sbixfile)
    remove(pdffile)
    statistics.stoptiming()
    if statistics.elapsedseconds then
      report_sbix("sbix conversion time %s",statistics.elapsedseconds() or "-")
    end
    return pdfshapes
  end
end
local function initializesbix(tfmdata,kind,value) 
  if value and otf.sbixenabled then
    local sbix=tfmdata.properties.sbix
    local hash=sbix and sbix.hash
    local timestamp=sbix and sbix.timestamp
    if not hash then
      return
    end
    local pdffile=containers.read(otf.pdfcache,hash)
    local pdfshapes=pdffile and pdffile.pdfshapes
    if not pdfshapes or pdffile.timestamp~=timestamp then
      local sbixfile=containers.read(otf.sbixcache,hash)
      local sbixshapes=sbixfile and sbixfile.sbixshapes
      pdfshapes=sbixshapes and otfsbix.topdf(sbixshapes) or {}
      containers.write(otf.pdfcache,hash,{
        pdfshapes=pdfshapes,
        timestamp=timestamp,
      })
    end
    pdftovirtual(tfmdata,pdfshapes,"sbix")
  end
end
fonts.handlers.otf.features.register {
  name="sbix",
  description="sbix glyphs",
  manipulators={
    base=initializesbix,
    node=initializesbix,
  }
}

end --- [luaotfload, fontloader-2018-10-08.lua scope for “font-ocl”] ---


do  --- [luaotfload, fontloader-2018-10-08.lua scope for “font-otc” 9dcd93d83bc61c90f0fb6161a1911a55] ---

if not modules then modules={} end modules ['font-otc']={
  version=1.001,
  comment="companion to font-ini.mkiv",
  author="Hans Hagen, PRAGMA-ADE, Hasselt NL",
  copyright="PRAGMA ADE / ConTeXt Development Team",
  license="see context related readme files"
}
local insert,sortedkeys,sortedhash,tohash=table.insert,table.sortedkeys,table.sortedhash,table.tohash
local type,next=type,next
local lpegmatch=lpeg.match
local utfbyte,utflen=utf.byte,utf.len
local sortedhash=table.sortedhash
local trace_loading=false trackers.register("otf.loading",function(v) trace_loading=v end)
local report_otf=logs.reporter("fonts","otf loading")
local fonts=fonts
local otf=fonts.handlers.otf
local registerotffeature=otf.features.register
local setmetatableindex=table.setmetatableindex
local checkmerge=fonts.helpers.checkmerge
local checkflags=fonts.helpers.checkflags
local checksteps=fonts.helpers.checksteps
local normalized={
  substitution="substitution",
  single="substitution",
  ligature="ligature",
  alternate="alternate",
  multiple="multiple",
  kern="kern",
  pair="pair",
  single="single",
  chainsubstitution="chainsubstitution",
  chainposition="chainposition",
}
local types={
  substitution="gsub_single",
  ligature="gsub_ligature",
  alternate="gsub_alternate",
  multiple="gsub_multiple",
  kern="gpos_pair",
  pair="gpos_pair",
  single="gpos_single",
  chainsubstitution="gsub_contextchain",
  chainposition="gpos_contextchain",
}
local names={
  gsub_single="gsub",
  gsub_multiple="gsub",
  gsub_alternate="gsub",
  gsub_ligature="gsub",
  gsub_context="gsub",
  gsub_contextchain="gsub",
  gsub_reversecontextchain="gsub",
  gpos_single="gpos",
  gpos_pair="gpos",
  gpos_cursive="gpos",
  gpos_mark2base="gpos",
  gpos_mark2ligature="gpos",
  gpos_mark2mark="gpos",
  gpos_context="gpos",
  gpos_contextchain="gpos",
}
setmetatableindex(types,function(t,k) t[k]=k return k end) 
local everywhere={ ["*"]={ ["*"]=true } } 
local noflags={ false,false,false,false }
local function getrange(sequences,category)
  local count=#sequences
  local first=nil
  local last=nil
  for i=1,count do
    local t=sequences[i].type
    if t and names[t]==category then
      if not first then
        first=i
      end
      last=i
    end
  end
  return first or 1,last or count
end
local function validspecification(specification,name)
  local dataset=specification.dataset
  if dataset then
  elseif specification[1] then
    dataset=specification
    specification={ dataset=dataset }
  else
    dataset={ { data=specification.data } }
    specification.data=nil
    specification.dataset=dataset
  end
  local first=dataset[1]
  if first then
    first=first.data
  end
  if not first then
    report_otf("invalid feature specification, no dataset")
    return
  end
  if type(name)~="string" then
    name=specification.name or first.name
  end
  if type(name)~="string" then
    report_otf("invalid feature specification, no name")
    return
  end
  local n=#dataset
  if n>0 then
    for i=1,n do
      setmetatableindex(dataset[i],specification)
    end
    return specification,name
  end
end
local function addfeature(data,feature,specifications)
  if not specifications then
    report_otf("missing specification")
    return
  end
  local descriptions=data.descriptions
  local resources=data.resources
  local features=resources.features
  local sequences=resources.sequences
  if not features or not sequences then
    report_otf("missing specification")
    return
  end
  local alreadydone=resources.alreadydone
  if not alreadydone then
    alreadydone={}
    resources.alreadydone=alreadydone
  end
  if alreadydone[specifications] then
    return
  else
    alreadydone[specifications]=true
  end
  local fontfeatures=resources.features or everywhere
  local unicodes=resources.unicodes
  local splitter=lpeg.splitter(" ",unicodes)
  local done=0
  local skip=0
  local aglunicodes=false
  local specifications=validspecification(specifications,feature)
  if not specifications then
    return
  end
  local function tounicode(code)
    if not code then
      return
    end
    if type(code)=="number" then
      return code
    end
    local u=unicodes[code]
    if u then
      return u
    end
    if utflen(code)==1 then
      u=utfbyte(code)
      if u then
        return u
      end
    end
    if not aglunicodes then
      aglunicodes=fonts.encodings.agl.unicodes 
    end
    return aglunicodes[code]
  end
  local coverup=otf.coverup
  local coveractions=coverup.actions
  local stepkey=coverup.stepkey
  local register=coverup.register
  local function prepare_substitution(list,featuretype,nocheck)
    local coverage={}
    local cover=coveractions[featuretype]
    for code,replacement in next,list do
      local unicode=tounicode(code)
      local description=descriptions[unicode]
      if not nocheck and not description then
        skip=skip+1
      else
        if type(replacement)=="table" then
          replacement=replacement[1]
        end
        replacement=tounicode(replacement)
        if replacement and descriptions[replacement] then
          cover(coverage,unicode,replacement)
          done=done+1
        else
          skip=skip+1
        end
      end
    end
    return coverage
  end
  local function prepare_alternate(list,featuretype,nocheck)
    local coverage={}
    local cover=coveractions[featuretype]
    for code,replacement in next,list do
      local unicode=tounicode(code)
      local description=descriptions[unicode]
      if not nocheck and not description then
        skip=skip+1
      elseif type(replacement)=="table" then
        local r={}
        for i=1,#replacement do
          local u=tounicode(replacement[i])
          r[i]=(nocheck or descriptions[u]) and u or unicode
        end
        cover(coverage,unicode,r)
        done=done+1
      else
        local u=tounicode(replacement)
        if u then
          cover(coverage,unicode,{ u })
          done=done+1
        else
          skip=skip+1
        end
      end
    end
    return coverage
  end
  local function prepare_multiple(list,featuretype,nocheck)
    local coverage={}
    local cover=coveractions[featuretype]
    for code,replacement in next,list do
      local unicode=tounicode(code)
      local description=descriptions[unicode]
      if not nocheck and not description then
        skip=skip+1
      elseif type(replacement)=="table" then
        local r,n={},0
        for i=1,#replacement do
          local u=tounicode(replacement[i])
          if nocheck or descriptions[u] then
            n=n+1
            r[n]=u
          end
        end
        if n>0 then
          cover(coverage,unicode,r)
          done=done+1
        else
          skip=skip+1
        end
      else
        local u=tounicode(replacement)
        if u then
          cover(coverage,unicode,{ u })
          done=done+1
        else
          skip=skip+1
        end
      end
    end
    return coverage
  end
  local function prepare_ligature(list,featuretype,nocheck)
    local coverage={}
    local cover=coveractions[featuretype]
    for code,ligature in next,list do
      local unicode=tounicode(code)
      local description=descriptions[unicode]
      if not nocheck and not description then
        skip=skip+1
      else
        if type(ligature)=="string" then
          ligature={ lpegmatch(splitter,ligature) }
        end
        local present=true
        for i=1,#ligature do
          local l=ligature[i]
          local u=tounicode(l)
          if nocheck or descriptions[u] then
            ligature[i]=u
          else
            present=false
            break
          end
        end
        if present then
          cover(coverage,unicode,ligature)
          done=done+1
        else
          skip=skip+1
        end
      end
    end
    return coverage
  end
  local function resetspacekerns()
    data.properties.hasspacekerns=true
    data.resources .spacekerns=nil
  end
  local function prepare_kern(list,featuretype)
    local coverage={}
    local cover=coveractions[featuretype]
    local isspace=false
    for code,replacement in next,list do
      local unicode=tounicode(code)
      local description=descriptions[unicode]
      if description and type(replacement)=="table" then
        local r={}
        for k,v in next,replacement do
          local u=tounicode(k)
          if u then
            r[u]=v
            if u==32 then
              isspace=true
            end
          end
        end
        if next(r) then
          cover(coverage,unicode,r)
          done=done+1
          if unicode==32 then
            isspace=true
          end
        else
          skip=skip+1
        end
      else
        skip=skip+1
      end
    end
    if isspace then
      resetspacekerns()
    end
    return coverage
  end
  local function prepare_pair(list,featuretype)
    local coverage={}
    local cover=coveractions[featuretype]
    if cover then
      for code,replacement in next,list do
        local unicode=tounicode(code)
        local description=descriptions[unicode]
        if description and type(replacement)=="table" then
          local r={}
          for k,v in next,replacement do
            local u=tounicode(k)
            if u then
              r[u]=v
              if u==32 then
                isspace=true
              end
            end
          end
          if next(r) then
            cover(coverage,unicode,r)
            done=done+1
            if unicode==32 then
              isspace=true
            end
          else
            skip=skip+1
          end
        else
          skip=skip+1
        end
      end
      if isspace then
        resetspacekerns()
      end
    else
      report_otf("unknown cover type %a",featuretype)
    end
    return coverage
  end
  local prepare_single=prepare_pair 
  local function prepare_chain(list,featuretype,sublookups)
    local rules=list.rules
    local coverage={}
    if rules then
      local rulehash={}
      local rulesize=0
      local lookuptype=types[featuretype]
      for nofrules=1,#rules do
        local rule=rules[nofrules]
        local current=rule.current
        local before=rule.before
        local after=rule.after
        local replacements=rule.replacements or false
        local sequence={}
        local nofsequences=0
        if before then
          for n=1,#before do
            nofsequences=nofsequences+1
            sequence[nofsequences]=before[n]
          end
        end
        local start=nofsequences+1
        for n=1,#current do
          nofsequences=nofsequences+1
          sequence[nofsequences]=current[n]
        end
        local stop=nofsequences
        if after then
          for n=1,#after do
            nofsequences=nofsequences+1
            sequence[nofsequences]=after[n]
          end
        end
        local lookups=rule.lookups or false
        local subtype=nil
        if lookups and sublookups then
          for k,v in sortedhash(lookups) do
            local t=type(v)
            if t=="table" then
              for i=1,#v do
                local vi=v[i]
                if type(vi)~="table" then
                  v[i]={ vi }
                end
              end
            elseif t=="number" then
              local lookup=sublookups[v]
              if lookup then
                lookups[k]={ lookup }
                if not subtype then
                  subtype=lookup.type
                end
              elseif v==0 then
                lookups[k]={ { type="gsub_remove" } }
              else
                lookups[k]=false 
              end
            else
              lookups[k]=false 
            end
          end
        end
        if nofsequences>0 then
          local hashed={}
          for i=1,nofsequences do
            local t={}
            local s=sequence[i]
            for i=1,#s do
              local u=tounicode(s[i])
              if u then
                t[u]=true
              end
            end
            hashed[i]=t
          end
          sequence=hashed
          rulesize=rulesize+1
          rulehash[rulesize]={
            nofrules,
            lookuptype,
            sequence,
            start,
            stop,
            lookups,
            replacements,
            subtype,
          }
          for unic in sortedhash(sequence[start]) do
            local cu=coverage[unic]
            if not cu then
              coverage[unic]=rulehash 
            end
          end
          sequence.n=nofsequences
        end
      end
      rulehash.n=rulesize
    end
    return coverage
  end
  local dataset=specifications.dataset
  local function report(name,category,position,first,last,sequences)
    report_otf("injecting name %a of category %a at position %i in [%i,%i] of [%i,%i]",
      name,category,position,first,last,1,#sequences)
  end
  local function inject(specification,sequences,sequence,first,last,category,name)
    local position=specification.position or false
    if not position then
      position=specification.prepend
      if position==true then
        if trace_loading then
          report(name,category,first,first,last,sequences)
        end
        insert(sequences,first,sequence)
        return
      end
    end
    if not position then
      position=specification.append
      if position==true then
        if trace_loading then
          report(name,category,last+1,first,last,sequences)
        end
        insert(sequences,last+1,sequence)
        return
      end
    end
    local kind=type(position)
    if kind=="string" then
      local index=false
      for i=first,last do
        local s=sequences[i]
        local f=s.features
        if f then
          for k in sortedhash(f) do 
            if k==position then
              index=i
              break
            end
          end
          if index then
            break
          end
        end
      end
      if index then
        position=index
      else
        position=last+1
      end
    elseif kind=="number" then
      if position<0 then
        position=last-position+1
      end
      if position>last then
        position=last+1
      elseif position<first then
        position=first
      end
    else
      position=last+1
    end
    if trace_loading then
      report(name,category,position,first,last,sequences)
    end
    insert(sequences,position,sequence)
  end
  for s=1,#dataset do
    local specification=dataset[s]
    local valid=specification.valid 
    local feature=specification.name or feature
    if not feature or feature=="" then
      report_otf("no valid name given for extra feature")
    elseif not valid or valid(data,specification,feature) then 
      local initialize=specification.initialize
      if initialize then
        specification.initialize=initialize(specification,data) and initialize or nil
      end
      local askedfeatures=specification.features or everywhere
      local askedsteps=specification.steps or specification.subtables or { specification.data } or {}
      local featuretype=normalized[specification.type or "substitution"] or "substitution"
      local featureflags=specification.flags or noflags
      local nocheck=specification.nocheck
      local futuresteps=specification.futuresteps
      local featureorder=specification.order or { feature }
      local featurechain=(featuretype=="chainsubstitution" or featuretype=="chainposition") and 1 or 0
      local nofsteps=0
      local steps={}
      local sublookups=specification.lookups
      local category=nil
      checkflags(specification,resources)
      if sublookups then
        local s={}
        for i=1,#sublookups do
          local specification=sublookups[i]
          local askedsteps=specification.steps or specification.subtables or { specification.data } or {}
          local featuretype=normalized[specification.type or "substitution"] or "substitution"
          local featureflags=specification.flags or noflags
          local nofsteps=0
          local steps={}
          for i=1,#askedsteps do
            local list=askedsteps[i]
            local coverage=nil
            local format=nil
            if featuretype=="substitution" then
              coverage=prepare_substitution(list,featuretype,nocheck)
            elseif featuretype=="ligature" then
              coverage=prepare_ligature(list,featuretype,nocheck)
            elseif featuretype=="alternate" then
              coverage=prepare_alternate(list,featuretype,nocheck)
            elseif featuretype=="multiple" then
              coverage=prepare_multiple(list,featuretype,nocheck)
            elseif featuretype=="kern" or featuretype=="move" then
              format=featuretype
              coverage=prepare_kern(list,featuretype)
            elseif featuretype=="pair" then
              format="pair"
              coverage=prepare_pair(list,featuretype)
            elseif featuretype=="single" then
              format="single"
              coverage=prepare_single(list,featuretype)
            end
            if coverage and next(coverage) then
              nofsteps=nofsteps+1
              steps[nofsteps]=register(coverage,featuretype,format,feature,nofsteps,descriptions,resources)
            end
          end
          checkmerge(specification)
          checksteps(specification)
          s[i]={
            [stepkey]=steps,
            nofsteps=nofsteps,
            flags=featureflags,
            type=types[featuretype],
          }
        end
        sublookups=s
      end
      for i=1,#askedsteps do
        local list=askedsteps[i]
        local coverage=nil
        local format=nil
        if featuretype=="substitution" then
          category="gsub"
          coverage=prepare_substitution(list,featuretype,nocheck)
        elseif featuretype=="ligature" then
          category="gsub"
          coverage=prepare_ligature(list,featuretype,nocheck)
        elseif featuretype=="alternate" then
          category="gsub"
          coverage=prepare_alternate(list,featuretype,nocheck)
        elseif featuretype=="multiple" then
          category="gsub"
          coverage=prepare_multiple(list,featuretype,nocheck)
        elseif featuretype=="kern" or featuretype=="move" then
          category="gpos"
          format=featuretype
          coverage=prepare_kern(list,featuretype)
        elseif featuretype=="pair" then
          category="gpos"
          format="pair"
          coverage=prepare_pair(list,featuretype)
        elseif featuretype=="single" then
          category="gpos"
          format="single"
          coverage=prepare_single(list,featuretype)
        elseif featuretype=="chainsubstitution" then
          category="gsub"
          coverage=prepare_chain(list,featuretype,sublookups)
        elseif featuretype=="chainposition" then
          category="gpos"
          coverage=prepare_chain(list,featuretype,sublookups)
        else
          report_otf("not registering feature %a, unknown category",feature)
          return
        end
        if coverage and next(coverage) then
          nofsteps=nofsteps+1
          steps[nofsteps]=register(coverage,featuretype,format,feature,nofsteps,descriptions,resources)
        end
      end
      if nofsteps>0 then
        for k,v in next,askedfeatures do
          if v[1] then
            askedfeatures[k]=tohash(v)
          end
        end
        if featureflags[1] then featureflags[1]="mark" end
        if featureflags[2] then featureflags[2]="ligature" end
        if featureflags[3] then featureflags[3]="base" end
        local steptype=types[featuretype]
        local sequence={
          chain=featurechain,
          features={ [feature]=askedfeatures },
          flags=featureflags,
          name=feature,
          order=featureorder,
          [stepkey]=steps,
          nofsteps=nofsteps,
          type=steptype,
        }
        checkflags(sequence,resources)
        checkmerge(sequence)
        checksteps(sequence)
        local first,last=getrange(sequences,category)
        inject(specification,sequences,sequence,first,last,category,feature)
        local features=fontfeatures[category]
        if not features then
          features={}
          fontfeatures[category]=features
        end
        local k=features[feature]
        if not k then
          k={}
          features[feature]=k
        end
        for script,languages in next,askedfeatures do
          local kk=k[script]
          if not kk then
            kk={}
            k[script]=kk
          end
          for language,value in next,languages do
            kk[language]=value
          end
        end
      end
    end
  end
  if trace_loading then
    report_otf("registering feature %a, affected glyphs %a, skipped glyphs %a",feature,done,skip)
  end
end
otf.enhancers.addfeature=addfeature
local extrafeatures={}
local knownfeatures={}
function otf.addfeature(name,specification)
  if type(name)=="table" then
    specification=name
  end
  if type(specification)~="table" then
    report_otf("invalid feature specification, no valid table")
    return
  end
  specification,name=validspecification(specification,name)
  if name and specification then
    local slot=knownfeatures[name]
    if not slot then
      slot=#extrafeatures+1
      knownfeatures[name]=slot
    elseif specification.overload==false then
      slot=#extrafeatures+1
      knownfeatures[name]=slot
    else
    end
    specification.name=name 
    extrafeatures[slot]=specification
  end
end
local function enhance(data,filename,raw)
  for slot=1,#extrafeatures do
    local specification=extrafeatures[slot]
    addfeature(data,specification.name,specification)
  end
end
otf.enhancers.enhance=enhance
otf.enhancers.register("check extra features",enhance)

end --- [luaotfload, fontloader-2018-10-08.lua scope for “font-otc”] ---


do  --- [luaotfload, fontloader-2018-10-08.lua scope for “font-onr” cf93eb4ab34461d2b3797792dbdb035f] ---

if not modules then modules={} end modules ['font-onr']={
  version=1.001,
  comment="companion to font-ini.mkiv",
  author="Hans Hagen, PRAGMA-ADE, Hasselt NL",
  copyright="PRAGMA ADE / ConTeXt Development Team",
  license="see context related readme files"
}
local fonts,logs,trackers,resolvers=fonts,logs,trackers,resolvers
local next,type,tonumber,rawget,rawset=next,type,tonumber,rawget,rawset
local match,lower,gsub,strip,find=string.match,string.lower,string.gsub,string.strip,string.find
local char,byte,sub=string.char,string.byte,string.sub
local abs=math.abs
local bxor,rshift=bit32.bxor,bit32.rshift
local P,S,R,Cmt,C,Ct,Cs,Carg,Cf,Cg=lpeg.P,lpeg.S,lpeg.R,lpeg.Cmt,lpeg.C,lpeg.Ct,lpeg.Cs,lpeg.Carg,lpeg.Cf,lpeg.Cg
local lpegmatch,patterns=lpeg.match,lpeg.patterns
local trace_indexing=false trackers.register("afm.indexing",function(v) trace_indexing=v end)
local trace_loading=false trackers.register("afm.loading",function(v) trace_loading=v end)
local report_afm=logs.reporter("fonts","afm loading")
local report_pfb=logs.reporter("fonts","pfb loading")
local handlers=fonts.handlers
local afm=handlers.afm or {}
handlers.afm=afm
local readers=afm.readers or {}
afm.readers=readers
afm.version=1.513
local get_indexes,get_shapes
do
  local decrypt
  do
    local r,c1,c2,n=0,0,0,0
    local function step(c)
      local cipher=byte(c)
      local plain=bxor(cipher,rshift(r,8))
      r=((cipher+r)*c1+c2)%65536
      return char(plain)
    end
    decrypt=function(binary,initial,seed)
      r,c1,c2,n=initial,52845,22719,seed
      binary=gsub(binary,".",step)
      return sub(binary,n+1)
    end
  end
  local charstrings=P("/CharStrings")
  local subroutines=P("/Subrs")
  local encoding=P("/Encoding")
  local dup=P("dup")
  local put=P("put")
  local array=P("array")
  local name=P("/")*C((R("az","AZ","09")+S("-_."))^1)
  local digits=R("09")^1
  local cardinal=digits/tonumber
  local spaces=P(" ")^1
  local spacing=patterns.whitespace^0
  local routines,vector,chars,n,m
  local initialize=function(str,position,size)
    n=0
    m=size 
    return position+1
  end
  local setroutine=function(str,position,index,size,filename)
    local forward=position+tonumber(size)
    local stream=decrypt(sub(str,position+1,forward),4330,4)
    routines[index]={ byte(stream,1,#stream) }
    return forward
  end
  local setvector=function(str,position,name,size,filename)
    local forward=position+tonumber(size)
    if n>=m then
      return #str
    elseif forward<#str then
      if n==0 and name~=".notdef" then
        report_pfb("reserving .notdef at index 0 in %a",filename) 
        n=n+1
      end
      vector[n]=name
      n=n+1
      return forward
    else
      return #str
    end
  end
  local setshapes=function(str,position,name,size,filename)
    local forward=position+tonumber(size)
    local stream=sub(str,position+1,forward)
    if n>m then
      return #str
    elseif forward<#str then
      if n==0 and name~=".notdef" then
        report_pfb("reserving .notdef at index 0 in %a",filename) 
        n=n+1
      end
      vector[n]=name
      n=n+1
      chars [n]=decrypt(stream,4330,4)
      return forward
    else
      return #str
    end
  end
  local p_rd=spacing*(P("RD")+P("-|"))
  local p_np=spacing*(P("NP")+P("|"))
  local p_nd=spacing*(P("ND")+P("|"))
  local p_filterroutines=
    (1-subroutines)^0*subroutines*spaces*Cmt(cardinal,initialize)*(Cmt(cardinal*spaces*cardinal*p_rd*Carg(1),setroutine)*p_np+P(1))^1
  local p_filtershapes=
    (1-charstrings)^0*charstrings*spaces*Cmt(cardinal,initialize)*(Cmt(name*spaces*cardinal*p_rd*Carg(1),setshapes)*p_nd+P(1))^1
  local p_filternames=Ct (
    (1-charstrings)^0*charstrings*spaces*Cmt(cardinal,initialize)*(Cmt(name*spaces*cardinal*Carg(1),setvector)+P(1))^1
  )
  local p_filterencoding=(1-encoding)^0*encoding*spaces*digits*spaces*array*(1-dup)^0*Cf(
      Ct("")*Cg(spacing*dup*spaces*cardinal*spaces*name*spaces*put)^1
,rawset)
  local function loadpfbvector(filename,shapestoo)
    local data=io.loaddata(resolvers.findfile(filename))
    if not data then
      report_pfb("no data in %a",filename)
      return
    end
    if not (find(data,"!PS-AdobeFont-",1,true) or find(data,"%!FontType1",1,true)) then
      report_pfb("no font in %a",filename)
      return
    end
    local ascii,binary=match(data,"(.*)eexec%s+......(.*)")
    if not binary then
      report_pfb("no binary data in %a",filename)
      return
    end
    binary=decrypt(binary,55665,4)
    local names={}
    local encoding=lpegmatch(p_filterencoding,ascii)
    local glyphs={}
    routines,vector,chars={},{},{}
    if shapestoo then
      lpegmatch(p_filterroutines,binary,1,filename)
      lpegmatch(p_filtershapes,binary,1,filename)
      local data={
        dictionaries={
          {
            charstrings=chars,
            charset=vector,
            subroutines=routines,
          }
        },
      }
      fonts.handlers.otf.readers.parsecharstrings(false,data,glyphs,true,true)
    else
      lpegmatch(p_filternames,binary,1,filename)
    end
    names=vector
    routines,vector,chars=nil,nil,nil
    return names,encoding,glyphs
  end
  local pfb=handlers.pfb or {}
  handlers.pfb=pfb
  pfb.loadvector=loadpfbvector
  get_indexes=function(data,pfbname)
    local vector=loadpfbvector(pfbname)
    if vector then
      local characters=data.characters
      if trace_loading then
        report_afm("getting index data from %a",pfbname)
      end
      for index=0,#vector do 
        local name=vector[index]
        local char=characters[name]
        if char then
          if trace_indexing then
            report_afm("glyph %a has index %a",name,index)
          end
          char.index=index
        else
          if trace_indexing then
            report_afm("glyph %a has index %a but no data",name,index)
          end
        end
      end
    end
  end
  get_shapes=function(pfbname)
    local vector,encoding,glyphs=loadpfbvector(pfbname,true)
    return glyphs
  end
end
local spacer=patterns.spacer
local whitespace=patterns.whitespace
local lineend=patterns.newline
local spacing=spacer^0
local number=spacing*S("+-")^-1*(R("09")+S("."))^1/tonumber
local name=spacing*C((1-whitespace)^1)
local words=spacing*((1-lineend)^1/strip)
local rest=(1-lineend)^0
local fontdata=Carg(1)
local semicolon=spacing*P(";")
local plus=spacing*P("plus")*number
local minus=spacing*P("minus")*number
local function addkernpair(data,one,two,value)
  local chr=data.characters[one]
  if chr then
    local kerns=chr.kerns
    if kerns then
      kerns[two]=tonumber(value)
    else
      chr.kerns={ [two]=tonumber(value) }
    end
  end
end
local p_kernpair=(fontdata*P("KPX")*name*name*number)/addkernpair
local chr=false
local ind=0
local function start(data,version)
  data.metadata.afmversion=version
  ind=0
  chr={}
end
local function stop()
  ind=0
  chr=false
end
local function setindex(i)
  if i<0 then
    ind=ind+1 
  else
    ind=i
  end
  chr={
    index=ind
  }
end
local function setwidth(width)
  chr.width=width
end
local function setname(data,name)
  data.characters[name]=chr
end
local function setboundingbox(boundingbox)
  chr.boundingbox=boundingbox
end
local function setligature(plus,becomes)
  local ligatures=chr.ligatures
  if ligatures then
    ligatures[plus]=becomes
  else
    chr.ligatures={ [plus]=becomes }
  end
end
local p_charmetric=((
  P("C")*number/setindex+P("WX")*number/setwidth+P("N")*fontdata*name/setname+P("B")*Ct((number)^4)/setboundingbox+P("L")*(name)^2/setligature
 )*semicolon )^1
local p_charmetrics=P("StartCharMetrics")*number*(p_charmetric+(1-P("EndCharMetrics")))^0*P("EndCharMetrics")
local p_kernpairs=P("StartKernPairs")*number*(p_kernpair+(1-P("EndKernPairs" )))^0*P("EndKernPairs" )
local function set_1(data,key,a)   data.metadata[lower(key)]=a      end
local function set_2(data,key,a,b)  data.metadata[lower(key)]={ a,b }  end
local function set_3(data,key,a,b,c) data.metadata[lower(key)]={ a,b,c } end
local p_parameters=P(false)+fontdata*((P("FontName")+P("FullName")+P("FamilyName"))/lower)*words/function(data,key,value)
    data.metadata[key]=value
  end+fontdata*((P("Weight")+P("Version"))/lower)*name/function(data,key,value)
    data.metadata[key]=value
  end+fontdata*P("IsFixedPitch")*name/function(data,pitch)
    data.metadata.monospaced=toboolean(pitch,true)
  end+fontdata*P("FontBBox")*Ct(number^4)/function(data,boundingbox)
    data.metadata.boundingbox=boundingbox
 end+fontdata*((P("CharWidth")+P("CapHeight")+P("XHeight")+P("Descender")+P("Ascender")+P("ItalicAngle"))/lower)*number/function(data,key,value)
    data.metadata[key]=value
  end+P("Comment")*spacing*(P(false)+(fontdata*C("DESIGNSIZE")*number*rest)/set_1 
+(fontdata*C("TFM designsize")*number*rest)/set_1+(fontdata*C("DesignSize")*number*rest)/set_1+(fontdata*C("CODINGSCHEME")*words*rest)/set_1 
+(fontdata*C("CHECKSUM")*number*words*rest)/set_1 
+(fontdata*C("SPACE")*number*plus*minus*rest)/set_3 
+(fontdata*C("QUAD")*number*rest)/set_1 
+(fontdata*C("EXTRASPACE")*number*rest)/set_1 
+(fontdata*C("NUM")*number*number*number*rest)/set_3 
+(fontdata*C("DENOM")*number*number*rest)/set_2 
+(fontdata*C("SUP")*number*number*number*rest)/set_3 
+(fontdata*C("SUB")*number*number*rest)/set_2 
+(fontdata*C("SUPDROP")*number*rest)/set_1 
+(fontdata*C("SUBDROP")*number*rest)/set_1 
+(fontdata*C("DELIM")*number*number*rest)/set_2 
+(fontdata*C("AXISHEIGHT")*number*rest)/set_1 
  )
local fullparser=(P("StartFontMetrics")*fontdata*name/start )*(p_charmetrics+p_kernpairs+p_parameters+(1-P("EndFontMetrics")) )^0*(P("EndFontMetrics")/stop )
local infoparser=(P("StartFontMetrics")*fontdata*name/start )*(p_parameters+(1-P("EndFontMetrics")) )^0*(P("EndFontMetrics")/stop )
local function read(filename,parser)
  local afmblob=io.loaddata(filename)
  if afmblob then
    local data={
      resources={
        filename=resolvers.unresolve(filename),
        version=afm.version,
        creator="context mkiv",
      },
      properties={
        hasitalics=false,
      },
      goodies={},
      metadata={
        filename=file.removesuffix(file.basename(filename))
      },
      characters={
      },
      descriptions={
      },
    }
    if trace_loading then
      report_afm("parsing afm file %a",filename)
    end
    lpegmatch(parser,afmblob,1,data)
    return data
  else
    if trace_loading then
      report_afm("no valid afm file %a",filename)
    end
    return nil
  end
end
function readers.loadfont(afmname,pfbname)
  local data=read(resolvers.findfile(afmname),fullparser)
  if data then
    if not pfbname or pfbname=="" then
      pfbname=resolvers.findfile(file.replacesuffix(file.nameonly(afmname),"pfb"))
    end
    if pfbname and pfbname~="" then
      data.resources.filename=resolvers.unresolve(pfbname)
      get_indexes(data,pfbname)
      return data
    else 
      report_afm("no pfb file for %a",afmname)
    end
  end
end
function readers.loadshapes(filename)
  local fullname=resolvers.findfile(filename) or ""
  if fullname=="" then
    return {
      filename="not found: "..filename,
      glyphs={}
    }
  else
    return {
      filename=fullname,
      format="opentype",
      glyphs=get_shapes(fullname) or {},
      units=1000,
    }
  end
end
function readers.getinfo(filename)
  local data=read(resolvers.findfile(filename),infoparser)
  if data then
    return data.metadata
  end
end

end --- [luaotfload, fontloader-2018-10-08.lua scope for “font-onr”] ---


do  --- [luaotfload, fontloader-2018-10-08.lua scope for “font-one” 4a74694755df4567176d4c0132a08dc8] ---

if not modules then modules={} end modules ['font-one']={
  version=1.001,
  comment="companion to font-ini.mkiv",
  author="Hans Hagen, PRAGMA-ADE, Hasselt NL",
  copyright="PRAGMA ADE / ConTeXt Development Team",
  license="see context related readme files"
}
local fonts,logs,trackers,containers,resolvers=fonts,logs,trackers,containers,resolvers
local next,type,tonumber,rawget=next,type,tonumber,rawget
local match,gsub=string.match,string.gsub
local abs=math.abs
local P,S,R,Cmt,C,Ct,Cs,Carg=lpeg.P,lpeg.S,lpeg.R,lpeg.Cmt,lpeg.C,lpeg.Ct,lpeg.Cs,lpeg.Carg
local lpegmatch,patterns=lpeg.match,lpeg.patterns
local sortedhash=table.sortedhash
local trace_features=false trackers.register("afm.features",function(v) trace_features=v end)
local trace_indexing=false trackers.register("afm.indexing",function(v) trace_indexing=v end)
local trace_loading=false trackers.register("afm.loading",function(v) trace_loading=v end)
local trace_defining=false trackers.register("fonts.defining",function(v) trace_defining=v end)
local report_afm=logs.reporter("fonts","afm loading")
local setmetatableindex=table.setmetatableindex
local derivetable=table.derive
local findbinfile=resolvers.findbinfile
local privateoffset=fonts.constructors and fonts.constructors.privateoffset or 0xF0000 
local definers=fonts.definers
local readers=fonts.readers
local constructors=fonts.constructors
local afm=constructors.handlers.afm
local pfb=constructors.handlers.pfb
local otf=fonts.handlers.otf
local otfreaders=otf.readers
local otfenhancers=otf.enhancers
local afmfeatures=constructors.features.afm
local registerafmfeature=afmfeatures.register
local afmenhancers=constructors.enhancers.afm
local registerafmenhancer=afmenhancers.register
afm.version=1.513 
afm.cache=containers.define("fonts","one",afm.version,true)
afm.autoprefixed=true 
afm.helpdata={} 
afm.syncspace=true 
local overloads=fonts.mappings.overloads
local applyruntimefixes=fonts.treatments and fonts.treatments.applyfixes
function afm.load(filename)
  filename=resolvers.findfile(filename,'afm') or ""
  if filename~="" and not fonts.names.ignoredfile(filename) then
    local name=file.removesuffix(file.basename(filename))
    local data=containers.read(afm.cache,name)
    local attr=lfs.attributes(filename)
    local size,time=attr and attr.size or 0,attr and attr.modification or 0
    local pfbfile=file.replacesuffix(name,"pfb")
    local pfbname=resolvers.findfile(pfbfile,"pfb") or ""
    if pfbname=="" then
      pfbname=resolvers.findfile(file.basename(pfbfile),"pfb") or ""
    end
    local pfbsize,pfbtime=0,0
    if pfbname~="" then
      local attr=lfs.attributes(pfbname)
      pfbsize=attr.size or 0
      pfbtime=attr.modification or 0
    end
    if not data or data.size~=size or data.time~=time or data.pfbsize~=pfbsize or data.pfbtime~=pfbtime then
      report_afm("reading %a",filename)
      data=afm.readers.loadfont(filename,pfbname)
      if data then
        afmenhancers.apply(data,filename)
        fonts.mappings.addtounicode(data,filename)
        otfreaders.stripredundant(data)
        otfreaders.pack(data)
        data.size=size
        data.time=time
        data.pfbsize=pfbsize
        data.pfbtime=pfbtime
        report_afm("saving %a in cache",name)
        data=containers.write(afm.cache,name,data)
        data=containers.read(afm.cache,name)
      end
    end
    if data then
      otfreaders.unpack(data)
      otfreaders.expand(data) 
      otfreaders.addunicodetable(data) 
      otfenhancers.apply(data,filename,data)
      if applyruntimefixes then
        applyruntimefixes(filename,data)
      end
    end
    return data
  end
end
local uparser=fonts.mappings.makenameparser() 
local function enhance_unify_names(data,filename)
  local unicodevector=fonts.encodings.agl.unicodes 
  local unicodes={}
  local names={}
  local private=data.private or privateoffset
  local descriptions=data.descriptions
  for name,blob in sortedhash(data.characters) do 
    local code=unicodevector[name] 
    if not code then
      code=lpegmatch(uparser,name)
      if type(code)~="number" then
        code=private
        private=private+1
        report_afm("assigning private slot %U for unknown glyph name %a",code,name)
      end
    end
    local index=blob.index
    unicodes[name]=code
    names[name]=index
    blob.name=name
    descriptions[code]={
      boundingbox=blob.boundingbox,
      width=blob.width,
      kerns=blob.kerns,
      index=index,
      name=name,
    }
  end
  for unicode,description in next,descriptions do
    local kerns=description.kerns
    if kerns then
      local krn={}
      for name,kern in next,kerns do
        local unicode=unicodes[name]
        if unicode then
          krn[unicode]=kern
        else
        end
      end
      description.kerns=krn
    end
  end
  data.characters=nil
  data.private=private
  local resources=data.resources
  local filename=resources.filename or file.removesuffix(file.basename(filename))
  resources.filename=resolvers.unresolve(filename) 
  resources.unicodes=unicodes 
  resources.marks={}
end
local everywhere={ ["*"]={ ["*"]=true } } 
local noflags={ false,false,false,false }
local function enhance_normalize_features(data)
  local ligatures=setmetatableindex("table")
  local kerns=setmetatableindex("table")
  local extrakerns=setmetatableindex("table")
  for u,c in next,data.descriptions do
    local l=c.ligatures
    local k=c.kerns
    local e=c.extrakerns
    if l then
      ligatures[u]=l
      for u,v in next,l do
        l[u]={ ligature=v }
      end
      c.ligatures=nil
    end
    if k then
      kerns[u]=k
      for u,v in next,k do
        k[u]=v 
      end
      c.kerns=nil
    end
    if e then
      extrakerns[u]=e
      for u,v in next,e do
        e[u]=v 
      end
      c.extrakerns=nil
    end
  end
  local features={
    gpos={},
    gsub={},
  }
  local sequences={
  }
  if next(ligatures) then
    features.gsub.liga=everywhere
    data.properties.hasligatures=true
    sequences[#sequences+1]={
      features={
        liga=everywhere,
      },
      flags=noflags,
      name="s_s_0",
      nofsteps=1,
      order={ "liga" },
      type="gsub_ligature",
      steps={
        {
          coverage=ligatures,
        },
      },
    }
  end
  if next(kerns) then
    features.gpos.kern=everywhere
    data.properties.haskerns=true
    sequences[#sequences+1]={
      features={
        kern=everywhere,
      },
      flags=noflags,
      name="p_s_0",
      nofsteps=1,
      order={ "kern" },
      type="gpos_pair",
      steps={
        {
          format="kern",
          coverage=kerns,
        },
      },
    }
  end
  if next(extrakerns) then
    features.gpos.extrakerns=everywhere
    data.properties.haskerns=true
    sequences[#sequences+1]={
      features={
        extrakerns=everywhere,
      },
      flags=noflags,
      name="p_s_1",
      nofsteps=1,
      order={ "extrakerns" },
      type="gpos_pair",
      steps={
        {
          format="kern",
          coverage=extrakerns,
        },
      },
    }
  end
  data.resources.features=features
  data.resources.sequences=sequences
end
local function enhance_fix_names(data)
  for k,v in next,data.descriptions do
    local n=v.name
    local r=overloads[n]
    if r then
      local name=r.name
      if trace_indexing then
        report_afm("renaming characters %a to %a",n,name)
      end
      v.name=name
      v.unicode=r.unicode
    end
  end
end
local addthem=function(rawdata,ligatures)
  if ligatures then
    local descriptions=rawdata.descriptions
    local resources=rawdata.resources
    local unicodes=resources.unicodes
    for ligname,ligdata in next,ligatures do
      local one=descriptions[unicodes[ligname]]
      if one then
        for _,pair in next,ligdata do
          local two,three=unicodes[pair[1]],unicodes[pair[2]]
          if two and three then
            local ol=one.ligatures
            if ol then
              if not ol[two] then
                ol[two]=three
              end
            else
              one.ligatures={ [two]=three }
            end
          end
        end
      end
    end
  end
end
local function enhance_add_ligatures(rawdata)
  addthem(rawdata,afm.helpdata.ligatures)
end
local function enhance_add_extra_kerns(rawdata) 
  local descriptions=rawdata.descriptions
  local resources=rawdata.resources
  local unicodes=resources.unicodes
  local function do_it_left(what)
    if what then
      for unicode,description in next,descriptions do
        local kerns=description.kerns
        if kerns then
          local extrakerns
          for complex,simple in next,what do
            complex=unicodes[complex]
            simple=unicodes[simple]
            if complex and simple then
              local ks=kerns[simple]
              if ks and not kerns[complex] then
                if extrakerns then
                  extrakerns[complex]=ks
                else
                  extrakerns={ [complex]=ks }
                end
              end
            end
          end
          if extrakerns then
            description.extrakerns=extrakerns
          end
        end
      end
    end
  end
  local function do_it_copy(what)
    if what then
      for complex,simple in next,what do
        complex=unicodes[complex]
        simple=unicodes[simple]
        if complex and simple then
          local complexdescription=descriptions[complex]
          if complexdescription then 
            local simpledescription=descriptions[complex]
            if simpledescription then
              local extrakerns
              local kerns=simpledescription.kerns
              if kerns then
                for unicode,kern in next,kerns do
                  if extrakerns then
                    extrakerns[unicode]=kern
                  else
                    extrakerns={ [unicode]=kern }
                  end
                end
              end
              local extrakerns=simpledescription.extrakerns
              if extrakerns then
                for unicode,kern in next,extrakerns do
                  if extrakerns then
                    extrakerns[unicode]=kern
                  else
                    extrakerns={ [unicode]=kern }
                  end
                end
              end
              if extrakerns then
                complexdescription.extrakerns=extrakerns
              end
            end
          end
        end
      end
    end
  end
  do_it_left(afm.helpdata.leftkerned)
  do_it_left(afm.helpdata.bothkerned)
  do_it_copy(afm.helpdata.bothkerned)
  do_it_copy(afm.helpdata.rightkerned)
end
local function adddimensions(data) 
  if data then
    for unicode,description in next,data.descriptions do
      local bb=description.boundingbox
      if bb then
        local ht,dp=bb[4],-bb[2]
        if ht==0 or ht<0 then
        else
          description.height=ht
        end
        if dp==0 or dp<0 then
        else
          description.depth=dp
        end
      end
    end
  end
end
local function copytotfm(data)
  if data and data.descriptions then
    local metadata=data.metadata
    local resources=data.resources
    local properties=derivetable(data.properties)
    local descriptions=derivetable(data.descriptions)
    local goodies=derivetable(data.goodies)
    local characters={}
    local parameters={}
    local unicodes=resources.unicodes
    for unicode,description in next,data.descriptions do 
      characters[unicode]={}
    end
    local filename=constructors.checkedfilename(resources)
    local fontname=metadata.fontname or metadata.fullname
    local fullname=metadata.fullname or metadata.fontname
    local endash=0x0020 
    local emdash=0x2014
    local spacer="space"
    local spaceunits=500
    local monospaced=metadata.monospaced
    local charwidth=metadata.charwidth
    local italicangle=metadata.italicangle
    local charxheight=metadata.xheight and metadata.xheight>0 and metadata.xheight
    properties.monospaced=monospaced
    parameters.italicangle=italicangle
    parameters.charwidth=charwidth
    parameters.charxheight=charxheight
    if properties.monospaced then
      if descriptions[endash] then
        spaceunits,spacer=descriptions[endash].width,"space"
      end
      if not spaceunits and descriptions[emdash] then
        spaceunits,spacer=descriptions[emdash].width,"emdash"
      end
      if not spaceunits and charwidth then
        spaceunits,spacer=charwidth,"charwidth"
      end
    else
      if descriptions[endash] then
        spaceunits,spacer=descriptions[endash].width,"space"
      end
      if not spaceunits and charwidth then
        spaceunits,spacer=charwidth,"charwidth"
      end
    end
    spaceunits=tonumber(spaceunits)
    if spaceunits<200 then
    end
    parameters.slant=0
    parameters.space=spaceunits
    parameters.space_stretch=500
    parameters.space_shrink=333
    parameters.x_height=400
    parameters.quad=1000
    if italicangle and italicangle~=0 then
      parameters.italicangle=italicangle
      parameters.italicfactor=math.cos(math.rad(90+italicangle))
      parameters.slant=- math.tan(italicangle*math.pi/180)
    end
    if monospaced then
      parameters.space_stretch=0
      parameters.space_shrink=0
    elseif afm.syncspace then
      parameters.space_stretch=spaceunits/2
      parameters.space_shrink=spaceunits/3
    end
    parameters.extra_space=parameters.space_shrink
    if charxheight then
      parameters.x_height=charxheight
    else
      local x=0x0078 
      if x then
        local x=descriptions[x]
        if x then
          parameters.x_height=x.height
        end
      end
    end
    if metadata.sup then
      local dummy={ 0,0,0 }
      parameters[ 1]=metadata.designsize    or 0
      parameters[ 2]=metadata.checksum     or 0
      parameters[ 3],
      parameters[ 4],
      parameters[ 5]=unpack(metadata.space   or dummy)
      parameters[ 6]=metadata.quad    or 0
      parameters[ 7]=metadata.extraspace or 0
      parameters[ 8],
      parameters[ 9],
      parameters[10]=unpack(metadata.num    or dummy)
      parameters[11],
      parameters[12]=unpack(metadata.denom   or dummy)
      parameters[13],
      parameters[14],
      parameters[15]=unpack(metadata.sup    or dummy)
      parameters[16],
      parameters[17]=unpack(metadata.sub    or dummy)
      parameters[18]=metadata.supdrop  or 0
      parameters[19]=metadata.subdrop  or 0
      parameters[20],
      parameters[21]=unpack(metadata.delim   or dummy)
      parameters[22]=metadata.axisheight or 0
    end
    parameters.designsize=(metadata.designsize or 10)*65536
    parameters.ascender=abs(metadata.ascender or 0)
    parameters.descender=abs(metadata.descender or 0)
    parameters.units=1000
    properties.spacer=spacer
    properties.encodingbytes=2
    properties.format=fonts.formats[filename] or "type1"
    properties.filename=filename
    properties.fontname=fontname
    properties.fullname=fullname
    properties.psname=fullname
    properties.name=filename or fullname or fontname
    properties.private=properties.private or data.private or privateoffset
    if next(characters) then
      return {
        characters=characters,
        descriptions=descriptions,
        parameters=parameters,
        resources=resources,
        properties=properties,
        goodies=goodies,
      }
    end
  end
  return nil
end
function afm.setfeatures(tfmdata,features)
  local okay=constructors.initializefeatures("afm",tfmdata,features,trace_features,report_afm)
  if okay then
    return constructors.collectprocessors("afm",tfmdata,features,trace_features,report_afm)
  else
    return {} 
  end
end
local function addtables(data)
  local resources=data.resources
  local lookuptags=resources.lookuptags
  local unicodes=resources.unicodes
  if not lookuptags then
    lookuptags={}
    resources.lookuptags=lookuptags
  end
  setmetatableindex(lookuptags,function(t,k)
    local v=type(k)=="number" and ("lookup "..k) or k
    t[k]=v
    return v
  end)
  if not unicodes then
    unicodes={}
    resources.unicodes=unicodes
    setmetatableindex(unicodes,function(t,k)
      setmetatableindex(unicodes,nil)
      for u,d in next,data.descriptions do
        local n=d.name
        if n then
          t[n]=u
        end
      end
      return rawget(t,k)
    end)
  end
  constructors.addcoreunicodes(unicodes) 
end
local function afmtotfm(specification)
  local afmname=specification.filename or specification.name
  if specification.forced=="afm" or specification.format=="afm" then 
    if trace_loading then
      report_afm("forcing afm format for %a",afmname)
    end
  else
    local tfmname=findbinfile(afmname,"ofm") or ""
    if tfmname~="" then
      if trace_loading then
        report_afm("fallback from afm to tfm for %a",afmname)
      end
      return 
    end
  end
  if afmname~="" then
    local features=constructors.checkedfeatures("afm",specification.features.normal)
    specification.features.normal=features
    constructors.hashinstance(specification,true)
    specification=definers.resolve(specification) 
    local cache_id=specification.hash
    local tfmdata=containers.read(constructors.cache,cache_id) 
    if not tfmdata then
      local rawdata=afm.load(afmname)
      if rawdata and next(rawdata) then
        addtables(rawdata)
        adddimensions(rawdata)
        tfmdata=copytotfm(rawdata)
        if tfmdata and next(tfmdata) then
          local shared=tfmdata.shared
          if not shared then
            shared={}
            tfmdata.shared=shared
          end
          shared.rawdata=rawdata
          shared.dynamics={}
          tfmdata.changed={}
          shared.features=features
          shared.processes=afm.setfeatures(tfmdata,features)
        end
      elseif trace_loading then
        report_afm("no (valid) afm file found with name %a",afmname)
      end
      tfmdata=containers.write(constructors.cache,cache_id,tfmdata)
    end
    return tfmdata
  end
end
local function read_from_afm(specification)
  local tfmdata=afmtotfm(specification)
  if tfmdata then
    tfmdata.properties.name=specification.name
    tfmdata=constructors.scale(tfmdata,specification)
    local allfeatures=tfmdata.shared.features or specification.features.normal
    constructors.applymanipulators("afm",tfmdata,allfeatures,trace_features,report_afm)
    fonts.loggers.register(tfmdata,'afm',specification)
  end
  return tfmdata
end
registerafmfeature {
  name="mode",
  description="mode",
  initializers={
    base=otf.modeinitializer,
    node=otf.modeinitializer,
  }
}
registerafmfeature {
  name="features",
  description="features",
  default=true,
  initializers={
    node=otf.nodemodeinitializer,
    base=otf.basemodeinitializer,
  },
  processors={
    node=otf.featuresprocessor,
  }
}
fonts.formats.afm="type1"
fonts.formats.pfb="type1"
local function check_afm(specification,fullname)
  local foundname=findbinfile(fullname,'afm') or "" 
  if foundname=="" then
    foundname=fonts.names.getfilename(fullname,"afm") or ""
  end
  if foundname=="" and afm.autoprefixed then
    local encoding,shortname=match(fullname,"^(.-)%-(.*)$") 
    if encoding and shortname and fonts.encodings.known[encoding] then
      shortname=findbinfile(shortname,'afm') or "" 
      if shortname~="" then
        foundname=shortname
        if trace_defining then
          report_afm("stripping encoding prefix from filename %a",afmname)
        end
      end
    end
  end
  if foundname~="" then
    specification.filename=foundname
    specification.format="afm"
    return read_from_afm(specification)
  end
end
function readers.afm(specification,method)
  local fullname=specification.filename or ""
  local tfmdata=nil
  if fullname=="" then
    local forced=specification.forced or ""
    if forced~="" then
      tfmdata=check_afm(specification,specification.name.."."..forced)
    end
    if not tfmdata then
      local check_tfm=readers.check_tfm
      method=(check_tfm and (method or definers.method or "afm or tfm")) or "afm"
      if method=="tfm" then
        tfmdata=check_tfm(specification,specification.name)
      elseif method=="afm" then
        tfmdata=check_afm(specification,specification.name)
      elseif method=="tfm or afm" then
        tfmdata=check_tfm(specification,specification.name) or check_afm(specification,specification.name)
      else 
        tfmdata=check_afm(specification,specification.name) or check_tfm(specification,specification.name)
      end
    end
  else
    tfmdata=check_afm(specification,fullname)
  end
  return tfmdata
end
function readers.pfb(specification,method) 
  local original=specification.specification
  if trace_defining then
    report_afm("using afm reader for %a",original)
  end
  specification.forced="afm"
  local function swap(name)
    local value=specification[swap]
    if value then
      specification[swap]=gsub("%.pfb",".afm",1)
    end
  end
  swap("filename")
  swap("fullname")
  swap("forcedname")
  swap("specification")
  return readers.afm(specification,method)
end
registerafmenhancer("unify names",enhance_unify_names)
registerafmenhancer("add ligatures",enhance_add_ligatures)
registerafmenhancer("add extra kerns",enhance_add_extra_kerns)
registerafmenhancer("normalize features",enhance_normalize_features)
registerafmenhancer("check extra features",otfenhancers.enhance)
registerafmenhancer("fix names",enhance_fix_names)

end --- [luaotfload, fontloader-2018-10-08.lua scope for “font-one”] ---


do  --- [luaotfload, fontloader-2018-10-08.lua scope for “font-afk” 9da14e0fb22129c053acc599d1312544] ---

if not modules then modules={} end modules ['font-afk']={
  version=1.001,
  comment="companion to font-lib.mkiv",
  author="Hans Hagen, PRAGMA-ADE, Hasselt NL",
  copyright="PRAGMA ADE / ConTeXt Development Team",
  license="see context related readme files",
  dataonly=true,
}
local allocate=utilities.storage.allocate
fonts.handlers.afm.helpdata={
  ligatures=allocate { 
    ['f']={ 
      { 'f','ff' },
      { 'i','fi' },
      { 'l','fl' },
    },
    ['ff']={
      { 'i','ffi' }
    },
    ['fi']={
      { 'i','fii' }
    },
    ['fl']={
      { 'i','fli' }
    },
    ['s']={
      { 't','st' }
    },
    ['i']={
      { 'j','ij' }
    },
  },
  texligatures=allocate {
    ['quoteleft']={
      { 'quoteleft','quotedblleft' }
    },
    ['quoteright']={
      { 'quoteright','quotedblright' }
    },
    ['hyphen']={
      { 'hyphen','endash' }
    },
    ['endash']={
      { 'hyphen','emdash' }
    }
  },
  leftkerned=allocate {
    AEligature="A",aeligature="a",
    OEligature="O",oeligature="o",
    IJligature="I",ijligature="i",
    AE="A",ae="a",
    OE="O",oe="o",
    IJ="I",ij="i",
    Ssharp="S",ssharp="s",
  },
  rightkerned=allocate {
    AEligature="E",aeligature="e",
    OEligature="E",oeligature="e",
    IJligature="J",ijligature="j",
    AE="E",ae="e",
    OE="E",oe="e",
    IJ="J",ij="j",
    Ssharp="S",ssharp="s",
  },
  bothkerned=allocate {
    Acircumflex="A",acircumflex="a",
    Ccircumflex="C",ccircumflex="c",
    Ecircumflex="E",ecircumflex="e",
    Gcircumflex="G",gcircumflex="g",
    Hcircumflex="H",hcircumflex="h",
    Icircumflex="I",icircumflex="i",
    Jcircumflex="J",jcircumflex="j",
    Ocircumflex="O",ocircumflex="o",
    Scircumflex="S",scircumflex="s",
    Ucircumflex="U",ucircumflex="u",
    Wcircumflex="W",wcircumflex="w",
    Ycircumflex="Y",ycircumflex="y",
    Agrave="A",agrave="a",
    Egrave="E",egrave="e",
    Igrave="I",igrave="i",
    Ograve="O",ograve="o",
    Ugrave="U",ugrave="u",
    Ygrave="Y",ygrave="y",
    Atilde="A",atilde="a",
    Itilde="I",itilde="i",
    Otilde="O",otilde="o",
    Utilde="U",utilde="u",
    Ntilde="N",ntilde="n",
    Adiaeresis="A",adiaeresis="a",Adieresis="A",adieresis="a",
    Ediaeresis="E",ediaeresis="e",Edieresis="E",edieresis="e",
    Idiaeresis="I",idiaeresis="i",Idieresis="I",idieresis="i",
    Odiaeresis="O",odiaeresis="o",Odieresis="O",odieresis="o",
    Udiaeresis="U",udiaeresis="u",Udieresis="U",udieresis="u",
    Ydiaeresis="Y",ydiaeresis="y",Ydieresis="Y",ydieresis="y",
    Aacute="A",aacute="a",
    Cacute="C",cacute="c",
    Eacute="E",eacute="e",
    Iacute="I",iacute="i",
    Lacute="L",lacute="l",
    Nacute="N",nacute="n",
    Oacute="O",oacute="o",
    Racute="R",racute="r",
    Sacute="S",sacute="s",
    Uacute="U",uacute="u",
    Yacute="Y",yacute="y",
    Zacute="Z",zacute="z",
    Dstroke="D",dstroke="d",
    Hstroke="H",hstroke="h",
    Tstroke="T",tstroke="t",
    Cdotaccent="C",cdotaccent="c",
    Edotaccent="E",edotaccent="e",
    Gdotaccent="G",gdotaccent="g",
    Idotaccent="I",idotaccent="i",
    Zdotaccent="Z",zdotaccent="z",
    Amacron="A",amacron="a",
    Emacron="E",emacron="e",
    Imacron="I",imacron="i",
    Omacron="O",omacron="o",
    Umacron="U",umacron="u",
    Ccedilla="C",ccedilla="c",
    Kcedilla="K",kcedilla="k",
    Lcedilla="L",lcedilla="l",
    Ncedilla="N",ncedilla="n",
    Rcedilla="R",rcedilla="r",
    Scedilla="S",scedilla="s",
    Tcedilla="T",tcedilla="t",
    Ohungarumlaut="O",ohungarumlaut="o",
    Uhungarumlaut="U",uhungarumlaut="u",
    Aogonek="A",aogonek="a",
    Eogonek="E",eogonek="e",
    Iogonek="I",iogonek="i",
    Uogonek="U",uogonek="u",
    Aring="A",aring="a",
    Uring="U",uring="u",
    Abreve="A",abreve="a",
    Ebreve="E",ebreve="e",
    Gbreve="G",gbreve="g",
    Ibreve="I",ibreve="i",
    Obreve="O",obreve="o",
    Ubreve="U",ubreve="u",
    Ccaron="C",ccaron="c",
    Dcaron="D",dcaron="d",
    Ecaron="E",ecaron="e",
    Lcaron="L",lcaron="l",
    Ncaron="N",ncaron="n",
    Rcaron="R",rcaron="r",
    Scaron="S",scaron="s",
    Tcaron="T",tcaron="t",
    Zcaron="Z",zcaron="z",
    dotlessI="I",dotlessi="i",
    dotlessJ="J",dotlessj="j",
    AEligature="AE",aeligature="ae",AE="AE",ae="ae",
    OEligature="OE",oeligature="oe",OE="OE",oe="oe",
    IJligature="IJ",ijligature="ij",IJ="IJ",ij="ij",
    Lstroke="L",lstroke="l",Lslash="L",lslash="l",
    Ostroke="O",ostroke="o",Oslash="O",oslash="o",
    Ssharp="SS",ssharp="ss",
    Aumlaut="A",aumlaut="a",
    Eumlaut="E",eumlaut="e",
    Iumlaut="I",iumlaut="i",
    Oumlaut="O",oumlaut="o",
    Uumlaut="U",uumlaut="u",
  }
}

end --- [luaotfload, fontloader-2018-10-08.lua scope for “font-afk”] ---


do  --- [luaotfload, fontloader-2018-10-08.lua scope for “font-tfm” c9797c1b4ccb8fdb7f041e19207109a2] ---

if not modules then modules={} end modules ['font-tfm']={
  version=1.001,
  comment="companion to font-ini.mkiv",
  author="Hans Hagen, PRAGMA-ADE, Hasselt NL",
  copyright="PRAGMA ADE / ConTeXt Development Team",
  license="see context related readme files"
}
local next,type=next,type
local match,format=string.match,string.format
local concat,sortedhash=table.concat,table.sortedhash
local trace_defining=false trackers.register("fonts.defining",function(v) trace_defining=v end)
local trace_features=false trackers.register("tfm.features",function(v) trace_features=v end)
local report_defining=logs.reporter("fonts","defining")
local report_tfm=logs.reporter("fonts","tfm loading")
local findbinfile=resolvers.findbinfile
local setmetatableindex=table.setmetatableindex
local fonts=fonts
local handlers=fonts.handlers
local helpers=fonts.helpers
local readers=fonts.readers
local constructors=fonts.constructors
local encodings=fonts.encodings
local tfm=constructors.handlers.tfm
tfm.version=1.000
tfm.maxnestingdepth=5
tfm.maxnestingsize=65536*1024
local otf=fonts.handlers.otf
local otfenhancers=otf.enhancers
local tfmfeatures=constructors.features.tfm
local registertfmfeature=tfmfeatures.register
local tfmenhancers=constructors.enhancers.tfm
local registertfmenhancer=tfmenhancers.register
local charcommand=helpers.commands.char
constructors.resolvevirtualtoo=false 
fonts.formats.tfm="type1" 
fonts.formats.ofm="type1"
function tfm.setfeatures(tfmdata,features)
  local okay=constructors.initializefeatures("tfm",tfmdata,features,trace_features,report_tfm)
  if okay then
    return constructors.collectprocessors("tfm",tfmdata,features,trace_features,report_tfm)
  else
    return {} 
  end
end
local depth={}
local function read_from_tfm(specification)
  local filename=specification.filename
  local size=specification.size
  depth[filename]=(depth[filename] or 0)+1
  if trace_defining then
    report_defining("loading tfm file %a at size %s",filename,size)
  end
  local tfmdata=font.read_tfm(filename,size) 
  if tfmdata then
    local features=specification.features and specification.features.normal or {}
    local features=constructors.checkedfeatures("tfm",features)
    specification.features.normal=features
    local newtfmdata=(depth[filename]==1) and tfm.reencode(tfmdata,specification)
    if newtfmdata then
       tfmdata=newtfmdata
    end
    local resources=tfmdata.resources or {}
    local properties=tfmdata.properties or {}
    local parameters=tfmdata.parameters or {}
    local shared=tfmdata.shared   or {}
    shared.features=features
    shared.resources=resources
    properties.name=tfmdata.name      
    properties.fontname=tfmdata.fontname    
    properties.psname=tfmdata.psname     
    properties.fullname=tfmdata.fullname    
    properties.filename=specification.filename 
    properties.format=fonts.formats.tfm
    tfmdata.properties=properties
    tfmdata.resources=resources
    tfmdata.parameters=parameters
    tfmdata.shared=shared
    shared.rawdata={ resources=resources }
    shared.features=features
    if newtfmdata then
      if not resources.marks then
        resources.marks={}
      end
      if not resources.sequences then
        resources.sequences={}
      end
      if not resources.features then
        resources.features={
          gsub={},
          gpos={},
        }
      end
      if not tfmdata.changed then
        tfmdata.changed={}
      end
      if not tfmdata.descriptions then
        tfmdata.descriptions=tfmdata.characters
      end
      otf.readers.addunicodetable(tfmdata)
      tfmenhancers.apply(tfmdata,filename)
      constructors.applymanipulators("tfm",tfmdata,features,trace_features,report_tfm)
      otf.readers.unifymissing(tfmdata)
      fonts.mappings.addtounicode(tfmdata,filename)
      tfmdata.tounicode=1
      local tounicode=fonts.mappings.tounicode
      for unicode,v in next,tfmdata.characters do
        local u=v.unicode
        if u then
          v.tounicode=tounicode(u)
        end
      end
      if tfmdata.usedbitmap then
        tfm.addtounicode(tfmdata)
      end
    end
    shared.processes=next(features) and tfm.setfeatures(tfmdata,features) or nil
    parameters.factor=1 
    parameters.size=size
    parameters.slant=parameters.slant     or parameters[1] or 0
    parameters.space=parameters.space     or parameters[2] or 0
    parameters.space_stretch=parameters.space_stretch or parameters[3] or 0
    parameters.space_shrink=parameters.space_shrink  or parameters[4] or 0
    parameters.x_height=parameters.x_height    or parameters[5] or 0
    parameters.quad=parameters.quad      or parameters[6] or 0
    parameters.extra_space=parameters.extra_space  or parameters[7] or 0
    constructors.enhanceparameters(parameters)
    properties.private=properties.private or tfmdata.private or privateoffset
    if newtfmdata then
    elseif constructors.resolvevirtualtoo then
      fonts.loggers.register(tfmdata,file.suffix(filename),specification) 
      local vfname=findbinfile(specification.name,'ovf')
      if vfname and vfname~="" then
        local vfdata=font.read_vf(vfname,size) 
        if vfdata then
          local chars=tfmdata.characters
          for k,v in next,vfdata.characters do
            chars[k].commands=v.commands
          end
          properties.virtualized=true
          tfmdata.fonts=vfdata.fonts
          tfmdata.type="virtual" 
          local fontlist=vfdata.fonts
          local name=file.nameonly(filename)
          for i=1,#fontlist do
            local n=fontlist[i].name
            local s=fontlist[i].size
            local d=depth[filename]
            s=constructors.scaled(s,vfdata.designsize)
            if d>tfm.maxnestingdepth then
              report_defining("too deeply nested virtual font %a with size %a, max nesting depth %s",n,s,tfm.maxnestingdepth)
              fontlist[i]={ id=0 }
            elseif (d>1) and (s>tfm.maxnestingsize) then
              report_defining("virtual font %a exceeds size %s",n,s)
              fontlist[i]={ id=0 }
            else
              local t,id=fonts.constructors.readanddefine(n,s)
              fontlist[i]={ id=id }
            end
          end
        end
      end
    end
    properties.haskerns=true
    properties.hasligatures=true
    resources.unicodes={}
    resources.lookuptags={}
    depth[filename]=depth[filename]-1
    return tfmdata
  else
    depth[filename]=depth[filename]-1
  end
end
local function check_tfm(specification,fullname) 
  local foundname=findbinfile(fullname,'tfm') or ""
  if foundname=="" then
    foundname=findbinfile(fullname,'ofm') or "" 
  end
  if foundname=="" then
    foundname=fonts.names.getfilename(fullname,"tfm") or ""
  end
  if foundname~="" then
    specification.filename=foundname
    specification.format="ofm"
    return read_from_tfm(specification)
  elseif trace_defining then
    report_defining("loading tfm with name %a fails",specification.name)
  end
end
readers.check_tfm=check_tfm
function readers.tfm(specification)
  local fullname=specification.filename or ""
  if fullname=="" then
    local forced=specification.forced or ""
    if forced~="" then
      fullname=specification.name.."."..forced
    else
      fullname=specification.name
    end
  end
  return check_tfm(specification,fullname)
end
readers.ofm=readers.tfm
do
  local outfiles={}
  local tfmcache=table.setmetatableindex(function(t,tfmdata)
    local id=font.define(tfmdata)
    t[tfmdata]=id
    return id
  end)
  local encdone=table.setmetatableindex("table")
  function tfm.reencode(tfmdata,specification)
    local features=specification.features
    if not features then
      return
    end
    local features=features.normal
    if not features then
      return
    end
    local tfmfile=file.basename(tfmdata.name)
    local encfile=features.reencode 
    local pfbfile=features.pfbfile 
    local bitmap=features.bitmap  
    if not encfile then
      return
    end
    local pfbfile=outfiles[tfmfile]
    if pfbfile==nil then
      if bitmap then
        pfbfile=false
      elseif type(pfbfile)~="string" then
        pfbfile=tfmfile
      end
      if type(pfbfile)=="string" then
        pfbfile=file.addsuffix(pfbfile,"pfb")
        report_tfm("using type1 shapes from %a for %a",pfbfile,tfmfile)
      else
        report_tfm("using bitmap shapes for %a",tfmfile)
        pfbfile=false 
      end
      outfiles[tfmfile]=pfbfile
    end
    local encoding=false
    local vector=false
    if type(pfbfile)=="string" then
      local pfb=fonts.constructors.handlers.pfb
      if pfb and pfb.loadvector then
        local v,e=pfb.loadvector(pfbfile)
        if v then
          vector=v
        end
        if e then
          encoding=e
        end
      end
    end
    if type(encfile)=="string" and encfile~="auto" then
      encoding=fonts.encodings.load(file.addsuffix(encfile,"enc"))
      if encoding then
        encoding=encoding.vector
      end
    end
    if not encoding then
      report_tfm("bad encoding for %a, quitting",tfmfile)
      return
    end
    local unicoding=fonts.encodings.agl and fonts.encodings.agl.unicodes
    local virtualid=tfmcache[tfmdata]
    local tfmdata=table.copy(tfmdata) 
    local characters={}
    local originals=tfmdata.characters
    local indices={}
    local parentfont={ "font",1 }
    local private=tfmdata or fonts.constructors.privateoffset
    local reported=encdone[tfmfile][encfile]
    local backmap=vector and table.swapped(vector)
    local done={} 
    for index,name in sortedhash(encoding) do 
      local unicode=unicoding[name]
      local original=originals[index]
      if original then
        if unicode then
          original.unicode=unicode
        else
          unicode=private
          private=private+1
          if not reported then
            report_tfm("glyph %a in font %a with encoding %a gets unicode %U",name,tfmfile,encfile,unicode)
          end
        end
        characters[unicode]=original
        indices[index]=unicode
        original.name=name 
        if backmap then
          original.index=backmap[name]
        else 
          original.commands={ parentfont,charcommand[index] } 
          original.oindex=index
        end
        done[name]=true
      elseif not done[name] then
        report_tfm("bad index %a in font %a with name %a",index,tfmfile,name)
      end
    end
    encdone[tfmfile][encfile]=true
    for k,v in next,characters do
      local kerns=v.kerns
      if kerns then
        local t={}
        for k,v in next,kerns do
          local i=indices[k]
          if i then
            t[i]=v
          end
        end
        v.kerns=next(t) and t or nil
      end
      local ligatures=v.ligatures
      if ligatures then
        local t={}
        for k,v in next,ligatures do
          local i=indices[k]
          if i then
            t[i]=v
            v.char=indices[v.char]
          end
        end
        v.ligatures=next(t) and t or nil
      end
    end
    tfmdata.fonts={ { id=virtualid } }
    tfmdata.characters=characters
    tfmdata.fullname=tfmdata.fullname or tfmdata.name
    tfmdata.psname=file.nameonly(pfbfile or tfmdata.name)
    tfmdata.filename=pfbfile
    tfmdata.encodingbytes=2
    tfmdata.format="type1"
    tfmdata.tounicode=1
    tfmdata.embedding="subset"
    tfmdata.usedbitmap=bitmap and virtualid
    tfmdata.private=private
    return tfmdata
  end
end
do
  local template=[[
/CIDInit /ProcSet findresource begin
  12 dict begin
  begincmap
    /CIDSystemInfo << /Registry (TeX) /Ordering (bitmap-%s) /Supplement 0 >> def
    /CMapName /TeX-bitmap-%s def
    /CMapType 2 def
    1 begincodespacerange
      <00> <FF>
    endcodespacerange
    %s beginbfchar
%s
    endbfchar
  endcmap
CMapName currentdict /CMap defineresource pop end
end
end
]]
  local flushstreamobject=lpdf and lpdf.flushstreamobject
  local setfontattributes=pdf.setfontattributes
  if flushstreamobject then
  else
    flushstreamobject=function(data)
      return pdf.obj {
        immediate=true,
        type="stream",
        string=data,
      }
    end
  end
  if not setfontattributes then
    setfontattributes=function(id,data)
      print(format("your luatex is too old so no tounicode bitmap font%i",id))
    end
  end
  function tfm.addtounicode(tfmdata)
    local id=tfmdata.usedbitmap
    local map={}
    local char={} 
    for k,v in next,tfmdata.characters do
      local index=v.oindex
      local tounicode=v.tounicode
      if index and tounicode then
        map[index]=tounicode
      end
    end
    for k,v in sortedhash(map) do
      char[#char+1]=format("<%02X> <%s>",k,v)
    end
    char=concat(char,"\n")
    local stream=format(template,id,id,#char,char)
    local reference=flushstreamobject(stream,nil,true)
    setfontattributes(id,format("/ToUnicode %i 0 R",reference))
  end
end
do
  local everywhere={ ["*"]={ ["*"]=true } } 
  local noflags={ false,false,false,false }
  local function enhance_normalize_features(data)
    local ligatures=setmetatableindex("table")
    local kerns=setmetatableindex("table")
    local characters=data.characters
    for u,c in next,characters do
      local l=c.ligatures
      local k=c.kerns
      if l then
        ligatures[u]=l
        for u,v in next,l do
          l[u]={ ligature=v.char }
        end
        c.ligatures=nil
      end
      if k then
        kerns[u]=k
        for u,v in next,k do
          k[u]=v 
        end
        c.kerns=nil
      end
    end
    for u,l in next,ligatures do
      for k,v in next,l do
        local vl=v.ligature
        local dl=ligatures[vl]
        if dl then
          for kk,vv in next,dl do
            v[kk]=vv 
          end
        end
      end
    end
    local features={
      gpos={},
      gsub={},
    }
    local sequences={
    }
    if next(ligatures) then
      features.gsub.liga=everywhere
      data.properties.hasligatures=true
      sequences[#sequences+1]={
        features={
          liga=everywhere,
        },
        flags=noflags,
        name="s_s_0",
        nofsteps=1,
        order={ "liga" },
        type="gsub_ligature",
        steps={
          {
            coverage=ligatures,
          },
        },
      }
    end
    if next(kerns) then
      features.gpos.kern=everywhere
      data.properties.haskerns=true
      sequences[#sequences+1]={
        features={
          kern=everywhere,
        },
        flags=noflags,
        name="p_s_0",
        nofsteps=1,
        order={ "kern" },
        type="gpos_pair",
        steps={
          {
            format="kern",
            coverage=kerns,
          },
        },
      }
    end
    data.resources.features=features
    data.resources.sequences=sequences
    data.shared.resources=data.shared.resources or resources
  end
  registertfmenhancer("normalize features",enhance_normalize_features)
  registertfmenhancer("check extra features",otfenhancers.enhance)
end
registertfmfeature {
  name="mode",
  description="mode",
  initializers={
    base=otf.modeinitializer,
    node=otf.modeinitializer,
  }
}
registertfmfeature {
  name="features",
  description="features",
  default=true,
  initializers={
    base=otf.basemodeinitializer,
    node=otf.nodemodeinitializer,
  },
  processors={
    node=otf.featuresprocessor,
  }
}

end --- [luaotfload, fontloader-2018-10-08.lua scope for “font-tfm”] ---


do  --- [luaotfload, fontloader-2018-10-08.lua scope for “font-lua” 1fbfdf7b689b2bdfd0e3bb9bf74ce136] ---

if not modules then modules={} end modules ['font-lua']={
  version=1.001,
  comment="companion to font-ini.mkiv",
  author="Hans Hagen, PRAGMA-ADE, Hasselt NL",
  copyright="PRAGMA ADE / ConTeXt Development Team",
  license="see context related readme files"
}
local trace_defining=false trackers.register("fonts.defining",function(v) trace_defining=v end)
local report_lua=logs.reporter("fonts","lua loading")
local fonts=fonts
local readers=fonts.readers
fonts.formats.lua="lua"
local function check_lua(specification,fullname)
  local fullname=resolvers.findfile(fullname) or ""
  if fullname~="" then
    local loader=loadfile(fullname)
    loader=loader and loader()
    return loader and loader(specification)
  end
end
readers.check_lua=check_lua
function readers.lua(specification)
  local original=specification.specification
  if trace_defining then
    report_lua("using lua reader for %a",original)
  end
  local fullname=specification.filename or ""
  if fullname=="" then
    local forced=specification.forced or ""
    if forced~="" then
      fullname=specification.name.."."..forced
    else
      fullname=specification.name
    end
  end
  return check_lua(specification,fullname)
end

end --- [luaotfload, fontloader-2018-10-08.lua scope for “font-lua”] ---


do  --- [luaotfload, fontloader-2018-10-08.lua scope for “font-def” 8e2cb2552bf02246da2ac43334b91795] ---

if not modules then modules={} end modules ['font-def']={
  version=1.001,
  comment="companion to font-ini.mkiv",
  author="Hans Hagen, PRAGMA-ADE, Hasselt NL",
  copyright="PRAGMA ADE / ConTeXt Development Team",
  license="see context related readme files"
}
local lower,gsub=string.lower,string.gsub
local tostring,next=tostring,next
local lpegmatch=lpeg.match
local suffixonly,removesuffix,basename=file.suffix,file.removesuffix,file.basename
local formatters=string.formatters
local sortedhash,sortedkeys=table.sortedhash,table.sortedkeys
local allocate=utilities.storage.allocate
local trace_defining=false trackers .register("fonts.defining",function(v) trace_defining=v end)
local directive_embedall=false directives.register("fonts.embedall",function(v) directive_embedall=v end)
trackers.register("fonts.loading","fonts.defining","otf.loading","afm.loading","tfm.loading")
local report_defining=logs.reporter("fonts","defining")
local fonts=fonts
local fontdata=fonts.hashes.identifiers
local readers=fonts.readers
local definers=fonts.definers
local specifiers=fonts.specifiers
local constructors=fonts.constructors
local fontgoodies=fonts.goodies
readers.sequence=allocate { 'otf','ttf','afm','tfm','lua' } 
local variants=allocate()
specifiers.variants=variants
definers.methods=definers.methods or {}
local internalized=allocate() 
local lastdefined=nil 
local loadedfonts=constructors.loadedfonts
local designsizes=constructors.designsizes
local resolvefile=fontgoodies and fontgoodies.filenames and fontgoodies.filenames.resolve or function(s) return s end
local function makespecification(specification,lookup,name,sub,method,detail,size)
  size=size or 655360
  if not lookup or lookup=="" then
    lookup=definers.defaultlookup
  end
  if trace_defining then
    report_defining("specification %a, lookup %a, name %a, sub %a, method %a, detail %a",
      specification,lookup,name,sub,method,detail)
  end
  local t={
    lookup=lookup,
    specification=specification,
    size=size,
    name=name,
    sub=sub,
    method=method,
    detail=detail,
    resolved="",
    forced="",
    features={},
  }
  return t
end
definers.makespecification=makespecification
if context then
  local splitter,splitspecifiers=nil,"" 
  local P,C,S,Cc,Cs=lpeg.P,lpeg.C,lpeg.S,lpeg.Cc,lpeg.Cs
  local left=P("(")
  local right=P(")")
  local colon=P(":")
  local space=P(" ")
  local lbrace=P("{")
  local rbrace=P("}")
  definers.defaultlookup="file"
  local prefixpattern=P(false)
  local function addspecifier(symbol)
    splitspecifiers=splitspecifiers..symbol
    local method=S(splitspecifiers)
    local lookup=C(prefixpattern)*colon
    local sub=left*C(P(1-left-right-method)^1)*right
    local specification=C(method)*C(P(1)^1)
    local name=Cs((lbrace/"")*(1-rbrace)^1*(rbrace/"")+(1-sub-specification)^1)
    splitter=P((lookup+Cc(""))*name*(sub+Cc(""))*(specification+Cc("")))
  end
  local function addlookup(str)
    prefixpattern=prefixpattern+P(str)
  end
  definers.addlookup=addlookup
  addlookup("file")
  addlookup("name")
  addlookup("spec")
  local function getspecification(str)
    return lpegmatch(splitter,str or "") 
  end
  definers.getspecification=getspecification
  function definers.registersplit(symbol,action,verbosename)
    addspecifier(symbol)
    variants[symbol]=action
    if verbosename then
      variants[verbosename]=action
    end
  end
  function definers.analyze(specification,size)
    local lookup,name,sub,method,detail=getspecification(specification or "")
    return makespecification(specification,lookup,name,sub,method,detail,size)
  end
end
definers.resolvers=definers.resolvers or {}
local resolvers=definers.resolvers
function resolvers.file(specification)
  local name=resolvefile(specification.name) 
  local suffix=lower(suffixonly(name))
  if fonts.formats[suffix] then
    specification.forced=suffix
    specification.forcedname=name
    specification.name=removesuffix(name)
  else
    specification.name=name 
  end
end
function resolvers.name(specification)
  local resolve=fonts.names.resolve
  if resolve then
    local resolved,sub,subindex,instance=resolve(specification.name,specification.sub,specification) 
    if resolved then
      specification.resolved=resolved
      specification.sub=sub
      specification.subindex=subindex
      if instance then
        specification.instance=instance
        local features=specification.features
        if not features then
          features={}
          specification.features=features
        end
        local normal=features.normal
        if not normal then
          normal={}
          features.normal=normal
        end
        normal.instance=instance
        if not callbacks.supported.glyph_stream_provider then
          normal.variableshapes=true 
        end
      end
      local suffix=lower(suffixonly(resolved))
      if fonts.formats[suffix] then
        specification.forced=suffix
        specification.forcedname=resolved
        specification.name=removesuffix(resolved)
      else
        specification.name=resolved
      end
    end
  else
    resolvers.file(specification)
  end
end
function resolvers.spec(specification)
  local resolvespec=fonts.names.resolvespec
  if resolvespec then
    local resolved,sub,subindex=resolvespec(specification.name,specification.sub,specification) 
    if resolved then
      specification.resolved=resolved
      specification.sub=sub
      specification.subindex=subindex
      specification.forced=lower(suffixonly(resolved))
      specification.forcedname=resolved
      specification.name=removesuffix(resolved)
    end
  else
    resolvers.name(specification)
  end
end
function definers.resolve(specification)
  if not specification.resolved or specification.resolved=="" then 
    local r=resolvers[specification.lookup]
    if r then
      r(specification)
    end
  end
  if specification.forced=="" then
    specification.forced=nil
    specification.forcedname=nil
  end
  specification.hash=lower(specification.name..' @ '..constructors.hashfeatures(specification))
  if specification.sub and specification.sub~="" then
    specification.hash=specification.sub..' @ '..specification.hash
  end
  return specification
end
function definers.applypostprocessors(tfmdata)
  local postprocessors=tfmdata.postprocessors
  if postprocessors then
    local properties=tfmdata.properties
    for i=1,#postprocessors do
      local extrahash=postprocessors[i](tfmdata) 
      if type(extrahash)=="string" and extrahash~="" then
        extrahash=gsub(lower(extrahash),"[^a-z]","-")
        properties.fullname=formatters["%s-%s"](properties.fullname,extrahash)
      end
    end
  end
  return tfmdata
end
local function checkembedding(tfmdata)
  local properties=tfmdata.properties
  local embedding
  if directive_embedall then
    embedding="full"
  elseif properties and properties.filename and constructors.dontembed[properties.filename] then
    embedding="no"
  else
    embedding="subset"
  end
  if properties then
    properties.embedding=embedding
  else
    tfmdata.properties={ embedding=embedding }
  end
  tfmdata.embedding=embedding
end
local function checkfeatures(tfmdata)
  local resources=tfmdata.resources
  local shared=tfmdata.shared
  if resources and shared then
    local features=resources.features
    local usedfeatures=shared.features
    if features and usedfeatures then
      local usedlanguage=usedfeatures.language or "dflt"
      local usedscript=usedfeatures.script or "dflt"
      local function check(what)
        if what then
          local foundlanguages={}
          for feature,scripts in next,what do
            if usedscript=="auto" or scripts["*"] then
            elseif not scripts[usedscript] then
            else
              for script,languages in next,scripts do
                if languages["*"] then
                elseif not languages[usedlanguage] then
                  report_defining("font %!font:name!, feature %a, script %a, no language %a",
                    tfmdata,feature,script,usedlanguage)
                end
              end
            end
            for script,languages in next,scripts do
              for language in next,languages do
                foundlanguages[language]=true
              end
            end
          end
          if false then
            foundlanguages["*"]=nil
            foundlanguages=sortedkeys(foundlanguages)
            for feature,scripts in sortedhash(what) do
              for script,languages in next,scripts do
                if not languages["*"] then
                  for i=1,#foundlanguages do
                    local language=foundlanguages[i]
                    if not languages[language] then
                      report_defining("font %!font:name!, feature %a, script %a, no language %a",
                        tfmdata,feature,script,language)
                    end
                  end
                end
              end
            end
          end
        end
      end
      check(features.gsub)
      check(features.gpos)
    end
  end
end
function definers.loadfont(specification)
  local hash=constructors.hashinstance(specification)
  local tfmdata=loadedfonts[hash] 
  if not tfmdata then
    local forced=specification.forced or ""
    if forced~="" then
      local reader=readers[lower(forced)] 
      tfmdata=reader and reader(specification)
      if not tfmdata then
        report_defining("forced type %a of %a not found",forced,specification.name)
      end
    else
      local sequence=readers.sequence 
      for s=1,#sequence do
        local reader=sequence[s]
        if readers[reader] then 
          if trace_defining then
            report_defining("trying (reader sequence driven) type %a for %a with file %a",reader,specification.name,specification.filename)
          end
          tfmdata=readers[reader](specification)
          if tfmdata then
            break
          else
            specification.filename=nil
          end
        end
      end
    end
    if tfmdata then
      tfmdata=definers.applypostprocessors(tfmdata)
      checkembedding(tfmdata) 
      loadedfonts[hash]=tfmdata
      designsizes[specification.hash]=tfmdata.parameters.designsize
      checkfeatures(tfmdata)
    end
  end
  if not tfmdata then
    report_defining("font with asked name %a is not found using lookup %a",specification.name,specification.lookup)
  end
  return tfmdata
end
function constructors.readanddefine(name,size) 
  local specification=definers.analyze(name,size)
  local method=specification.method
  if method and variants[method] then
    specification=variants[method](specification)
  end
  specification=definers.resolve(specification)
  local hash=constructors.hashinstance(specification)
  local id=definers.registered(hash)
  if not id then
    local tfmdata=definers.loadfont(specification)
    if tfmdata then
      tfmdata.properties.hash=hash
      id=font.define(tfmdata)
      definers.register(tfmdata,id)
    else
      id=0 
    end
  end
  return fontdata[id],id
end
function definers.current() 
  return lastdefined
end
function definers.registered(hash)
  local id=internalized[hash]
  return id,id and fontdata[id]
end
function definers.register(tfmdata,id)
  if tfmdata and id then
    local hash=tfmdata.properties.hash
    if not hash then
      report_defining("registering font, id %a, name %a, invalid hash",id,tfmdata.properties.filename or "?")
    elseif not internalized[hash] then
      internalized[hash]=id
      if trace_defining then
        report_defining("registering font, id %s, hash %a",id,hash)
      end
      fontdata[id]=tfmdata
    end
  end
end
function definers.read(specification,size,id) 
  statistics.starttiming(fonts)
  if type(specification)=="string" then
    specification=definers.analyze(specification,size)
  end
  local method=specification.method
  if method and variants[method] then
    specification=variants[method](specification)
  end
  specification=definers.resolve(specification)
  local hash=constructors.hashinstance(specification)
  local tfmdata=definers.registered(hash) 
  if tfmdata then
    if trace_defining then
      report_defining("already hashed: %s",hash)
    end
  else
    tfmdata=definers.loadfont(specification) 
    if tfmdata then
      if trace_defining then
        report_defining("loaded and hashed: %s",hash)
      end
      tfmdata.properties.hash=hash
      if id then
        definers.register(tfmdata,id)
      end
    else
      if trace_defining then
        report_defining("not loaded and hashed: %s",hash)
      end
    end
  end
  lastdefined=tfmdata or id 
  if not tfmdata then 
    report_defining("unknown font %a, loading aborted",specification.name)
  elseif trace_defining and type(tfmdata)=="table" then
    local properties=tfmdata.properties or {}
    local parameters=tfmdata.parameters or {}
    report_defining("using %a font with id %a, name %a, size %a, bytes %a, encoding %a, fullname %a, filename %a",
      properties.format or "unknown",id or "-",properties.name,parameters.size,properties.encodingbytes,
      properties.encodingname,properties.fullname,basename(properties.filename))
  end
  statistics.stoptiming(fonts)
  return tfmdata
end
function font.getfont(id)
  return fontdata[id] 
end
callbacks.register('define_font',definers.read,"definition of fonts (tfmdata preparation)")

end --- [luaotfload, fontloader-2018-10-08.lua scope for “font-def”] ---


do  --- [luaotfload, fontloader-2018-10-08.lua scope for “fonts-def” f435e0875f203f343157baeff876ec9c] ---

if not modules then modules={} end modules ['luatex-fonts-def']={
  version=1.001,
  comment="companion to luatex-*.tex",
  author="Hans Hagen, PRAGMA-ADE, Hasselt NL",
  copyright="PRAGMA ADE / ConTeXt Development Team",
  license="see context related readme files"
}
if context then
  os.exit()
end
local fonts=fonts
fonts.constructors.namemode="specification"
function fonts.definers.getspecification(str)
  return "",str,"",":",str
end
local list={} 
local function issome ()  list.lookup='name'     end 
local function isfile ()  list.lookup='file'     end
local function isname ()  list.lookup='name'     end
local function thename(s)  list.name=s        end
local function issub (v)  list.sub=v        end
local function iscrap (s)  list.crap=string.lower(s) end
local function iskey (k,v) list[k]=v        end
local function istrue (s)  list[s]=true      end
local function isfalse(s)  list[s]=false      end
local P,S,R,C,Cs=lpeg.P,lpeg.S,lpeg.R,lpeg.C,lpeg.Cs
local spaces=P(" ")^0
local namespec=Cs((P("{")/"")*(1-S("}"))^0*(P("}")/"")+(1-S("/:("))^0)
local crapspec=spaces*P("/")*(((1-P(":"))^0)/iscrap)*spaces
local filename_1=P("file:")/isfile*(namespec/thename)
local filename_2=P("[")*P(true)/isfile*(((1-P("]"))^0)/thename)*P("]")
local fontname_1=P("name:")/isname*(namespec/thename)
local fontname_2=P(true)/issome*(namespec/thename)
local sometext=R("az","AZ","09")^1
local somekey=R("az","AZ","09")^1
local somevalue=(P("{")/"")*(1-P("}"))^0*(P("}")/"")+(1-S(";"))^1
local truevalue=P("+")*spaces*(sometext/istrue)
local falsevalue=P("-")*spaces*(sometext/isfalse)
local keyvalue=(C(somekey)*spaces*P("=")*spaces*C(somevalue))/iskey
local somevalue=sometext/istrue
local subvalue=P("(")*(C(P(1-S("()"))^1)/issub)*P(")") 
local option=spaces*(keyvalue+falsevalue+truevalue+somevalue)*spaces
local options=P(":")*spaces*(P(";")^0*option)^0
local pattern=(filename_1+filename_2+fontname_1+fontname_2)*subvalue^0*crapspec^0*options^0
function fonts.definers.analyze(str,size)
  local specification=fonts.definers.makespecification(str,nil,nil,nil,":",nil,size)
  list={}
  lpeg.match(pattern,str)
  list.crap=nil
  if list.name then
    specification.name=list.name
    list.name=nil
  end
  if list.lookup then
    specification.lookup=list.lookup
    list.lookup=nil
  end
  if list.sub then
    specification.sub=list.sub
    list.sub=nil
  end
  specification.features.normal=fonts.handlers.otf.features.normalize(list)
  list=nil
  return specification
end
function fonts.definers.applypostprocessors(tfmdata)
  local postprocessors=tfmdata.postprocessors
  if postprocessors then
    for i=1,#postprocessors do
      local extrahash=postprocessors[i](tfmdata) 
      if type(extrahash)=="string" and extrahash~="" then
        extrahash=string.gsub(lower(extrahash),"[^a-z]","-")
        tfmdata.properties.fullname=format("%s-%s",tfmdata.properties.fullname,extrahash)
      end
    end
  end
  return tfmdata
end

end --- [luaotfload, fontloader-2018-10-08.lua scope for “fonts-def”] ---


do  --- [luaotfload, fontloader-2018-10-08.lua scope for “fonts-ext” 32013cbc5d5d336be8b1d1e5879d86c4] ---

if not modules then modules={} end modules ['luatex-fonts-ext']={
  version=1.001,
  comment="companion to luatex-*.tex",
  author="Hans Hagen, PRAGMA-ADE, Hasselt NL",
  copyright="PRAGMA ADE / ConTeXt Development Team",
  license="see context related readme files"
}
if context then
  os.exit()
end
local byte=string.byte
local fonts=fonts
local handlers=fonts.handlers
local otf=handlers.otf
local afm=handlers.afm
local registerotffeature=otf.features.register
local registerafmfeature=afm.features.register
function fonts.loggers.onetimemessage() end
fonts.protrusions=fonts.protrusions    or {}
fonts.protrusions.setups=fonts.protrusions.setups or {}
local setups=fonts.protrusions.setups
setups['default']={ 
  factor=1,
  left=1,
  right=1,
  [0x002C]={ 0,1  },
  [0x002E]={ 0,1  },
  [0x003A]={ 0,1  },
  [0x003B]={ 0,1  },
  [0x002D]={ 0,1  },
  [0x2013]={ 0,0.50 },
  [0x2014]={ 0,0.33 },
  [0x3001]={ 0,1  },
  [0x3002]={ 0,1  },
  [0x060C]={ 0,1  },
  [0x061B]={ 0,1  },
  [0x06D4]={ 0,1  },
}
local function initializeprotrusion(tfmdata,value)
  if value then
    local setup=setups[value]
    if setup then
      local factor,left,right=setup.factor or 1,setup.left or 1,setup.right or 1
      local emwidth=tfmdata.parameters.quad
      tfmdata.parameters.protrusion={
        auto=true,
      }
      for i,chr in next,tfmdata.characters do
        local v,pl,pr=setup[i],nil,nil
        if v then
          pl,pr=v[1],v[2]
        end
        if pl and pl~=0 then chr.left_protruding=left*pl*factor end
        if pr and pr~=0 then chr.right_protruding=right*pr*factor end
      end
    end
  end
end
local specification={
  name="protrusion",
  description="shift characters into the left and or right margin",
  initializers={
    base=initializeprotrusion,
    node=initializeprotrusion,
  }
}
registerotffeature(specification)
registerafmfeature(specification)
fonts.expansions=fonts.expansions    or {}
fonts.expansions.setups=fonts.expansions.setups or {}
local setups=fonts.expansions.setups
setups['default']={ 
  stretch=2,
  shrink=2,
  step=.5,
  factor=1,
  [byte('A')]=0.5,[byte('B')]=0.7,[byte('C')]=0.7,[byte('D')]=0.5,[byte('E')]=0.7,
  [byte('F')]=0.7,[byte('G')]=0.5,[byte('H')]=0.7,[byte('K')]=0.7,[byte('M')]=0.7,
  [byte('N')]=0.7,[byte('O')]=0.5,[byte('P')]=0.7,[byte('Q')]=0.5,[byte('R')]=0.7,
  [byte('S')]=0.7,[byte('U')]=0.7,[byte('W')]=0.7,[byte('Z')]=0.7,
  [byte('a')]=0.7,[byte('b')]=0.7,[byte('c')]=0.7,[byte('d')]=0.7,[byte('e')]=0.7,
  [byte('g')]=0.7,[byte('h')]=0.7,[byte('k')]=0.7,[byte('m')]=0.7,[byte('n')]=0.7,
  [byte('o')]=0.7,[byte('p')]=0.7,[byte('q')]=0.7,[byte('s')]=0.7,[byte('u')]=0.7,
  [byte('w')]=0.7,[byte('z')]=0.7,
  [byte('2')]=0.7,[byte('3')]=0.7,[byte('6')]=0.7,[byte('8')]=0.7,[byte('9')]=0.7,
}
local function initializeexpansion(tfmdata,value)
  if value then
    local setup=setups[value]
    if setup then
      local factor=setup.factor or 1
      tfmdata.parameters.expansion={
        stretch=10*(setup.stretch or 0),
        shrink=10*(setup.shrink or 0),
        step=10*(setup.step  or 0),
        auto=true,
      }
      for i,chr in next,tfmdata.characters do
        local v=setup[i]
        if v and v~=0 then
          chr.expansion_factor=v*factor
        else 
          chr.expansion_factor=factor
        end
      end
    end
  end
end
local specification={
  name="expansion",
  description="apply hz optimization",
  initializers={
    base=initializeexpansion,
    node=initializeexpansion,
  }
}
registerotffeature(specification)
registerafmfeature(specification)
if not otf.features.normalize then
  otf.features.normalize=function(t)
    if t.rand then
      t.rand="random"
    end
    return t
  end
end
function fonts.helpers.nametoslot(name)
  local t=type(name)
  if t=="string" then
    local tfmdata=fonts.hashes.identifiers[currentfont()]
    local shared=tfmdata and tfmdata.shared
    local fntdata=shared and shared.rawdata
    return fntdata and fntdata.resources.unicodes[name]
  elseif t=="number" then
    return n
  end
end
fonts.encodings=fonts.encodings or {}
local reencodings={}
fonts.encodings.reencodings=reencodings
local function specialreencode(tfmdata,value)
  local encoding=value and reencodings[value]
  if encoding then
    local temp={}
    local char=tfmdata.characters
    for k,v in next,encoding do
      temp[k]=char[v]
    end
    for k,v in next,temp do
      char[k]=temp[k]
    end
    return string.format("reencoded:%s",value)
  end
end
local function initialize(tfmdata,value)
  tfmdata.postprocessors=tfmdata.postprocessors or {}
  table.insert(tfmdata.postprocessors,
    function(tfmdata)
      return specialreencode(tfmdata,value)
    end
  )
end
registerotffeature {
  name="reencode",
  description="reencode characters",
  manipulators={
    base=initialize,
    node=initialize,
  }
}
local function initialize(tfmdata,key,value)
  if value then
    tfmdata.mathparameters=nil
  end
end
registerotffeature {
  name="ignoremathconstants",
  description="ignore math constants table",
  initializers={
    base=initialize,
    node=initialize,
  }
}

end --- [luaotfload, fontloader-2018-10-08.lua scope for “fonts-ext”] ---


do  --- [luaotfload, fontloader-2018-10-08.lua scope for “font-imp-tex” ceb087ef6fa2f89aed7179f60ddf8f35] ---

if not modules then modules={} end modules ['font-imp-tex']={
  version=1.001,
  comment="companion to font-ini.mkiv",
  author="Hans Hagen, PRAGMA-ADE, Hasselt NL",
  copyright="PRAGMA ADE / ConTeXt Development Team",
  license="see context related readme files"
}
local next=next
local fonts=fonts
local otf=fonts.handlers.otf
local registerotffeature=otf.features.register
local addotffeature=otf.addfeature
local specification={
  type="ligature",
  order={ "tlig" },
  prepend=true,
  data={
    [0x2013]={ 0x002D,0x002D },
    [0x2014]={ 0x002D,0x002D,0x002D },
  },
}
addotffeature("tlig",specification)
registerotffeature {
  name="tlig",
  description="tex ligatures",
}
local specification={
  type="substitution",
  order={ "trep" },
  prepend=true,
  data={
    [0x0027]=0x2019,
  },
}
addotffeature("trep",specification)
registerotffeature {
  name="trep",
  description="tex replacements",
}
local anum_arabic={
  [0x0030]=0x0660,
  [0x0031]=0x0661,
  [0x0032]=0x0662,
  [0x0033]=0x0663,
  [0x0034]=0x0664,
  [0x0035]=0x0665,
  [0x0036]=0x0666,
  [0x0037]=0x0667,
  [0x0038]=0x0668,
  [0x0039]=0x0669,
}
local anum_persian={
  [0x0030]=0x06F0,
  [0x0031]=0x06F1,
  [0x0032]=0x06F2,
  [0x0033]=0x06F3,
  [0x0034]=0x06F4,
  [0x0035]=0x06F5,
  [0x0036]=0x06F6,
  [0x0037]=0x06F7,
  [0x0038]=0x06F8,
  [0x0039]=0x06F9,
}
local function valid(data)
  local features=data.resources.features
  if features then
    for k,v in next,features do
      for k,v in next,v do
        if v.arab then
          return true
        end
      end
    end
  end
end
local specification={
  {
    type="substitution",
    features={ arab={ urd=true,dflt=true } },
    order={ "anum" },
    data=anum_arabic,
    valid=valid,
  },
  {
    type="substitution",
    features={ arab={ urd=true } },
    order={ "anum" },
    data=anum_persian,
    valid=valid,
  },
}
addotffeature("anum",specification)
registerotffeature {
  name="anum",
  description="arabic digits",
}

end --- [luaotfload, fontloader-2018-10-08.lua scope for “font-imp-tex”] ---


do  --- [luaotfload, fontloader-2018-10-08.lua scope for “font-imp-ligatures” 26ffcf089391445f7af59536c8814364] ---

if not modules then modules={} end modules ['font-imp-ligatures']={
  version=1.001,
  comment="companion to font-ini.mkiv",
  author="Hans Hagen, PRAGMA-ADE, Hasselt NL",
  copyright="PRAGMA ADE / ConTeXt Development Team",
  license="see context related readme files"
}
local lpegmatch=lpeg.match
local utfsplit=utf.split
local settings_to_array=utilities.parsers.settings_to_array
local fonts=fonts
local otf=fonts.handlers.otf
local registerotffeature=otf.features.register
local addotffeature=otf.addfeature
local lookups={}
local protect={}
local revert={}
local zwjchar=0x200C
local zwj={ zwjchar }
addotffeature {
  name="blockligatures",
  type="chainsubstitution",
  nocheck=true,
  prepend=true,
  future=true,
  lookups={
    {
      type="multiple",
      data=lookups,
    },
  },
  data={
    rules=protect,
  }
}
addotffeature {
  name="blockligatures",
  type="chainsubstitution",
  nocheck=true,
  append=true,
  overload=false,
  lookups={
    {
      type="ligature",
      data=lookups,
    },
  },
  data={
    rules=revert,
  }
}
registerotffeature {
  name='blockligatures',
  description='block certain ligatures',
}
local splitter=lpeg.splitat(":")
local function blockligatures(str)
  local t=settings_to_array(str)
  for i=1,#t do
    local ti=t[i]
    local before,current,after=lpegmatch(splitter,ti)
    if current and after then
      if before then
        before=utfsplit(before)
        for i=1,#before do
          before[i]={ before[i] }
        end
      end
      if current then
        current=utfsplit(current)
      end
      if after then
        after=utfsplit(after)
        for i=1,#after do
          after[i]={ after[i] }
        end
      end
    else
      before=nil
      current=utfsplit(ti)
      after=nil
    end
    if #current>1 then
      local one=current[1]
      local two=current[2]
      lookups[one]={ one,zwjchar }
      local one={ one }
      local two={ two }
      local new=#protect+1
      protect[new]={
        before=before,
        current={ one,two },
        after=after,
        lookups={ 1 },
      }
      revert[new]={
        current={ one,zwj },
        after={ two },
        lookups={ 1 },
      }
    end
  end
end
otf.helpers.blockligatures=blockligatures
if context then
  interfaces.implement {
    name="blockligatures",
    arguments="string",
    actions=blockligatures,
  }
end

end --- [luaotfload, fontloader-2018-10-08.lua scope for “font-imp-ligatures”] ---


do  --- [luaotfload, fontloader-2018-10-08.lua scope for “font-imp-italics” c2e6d6c4096a2c30d68fbffd3d7d58a7] ---

if not modules then modules={} end modules ['font-imp-italics']={
  version=1.001,
  comment="companion to font-ini.mkiv and hand-ini.mkiv",
  author="Hans Hagen, PRAGMA-ADE, Hasselt NL",
  copyright="PRAGMA ADE / ConTeXt Development Team",
  license="see context related readme files"
}
local next=next
local fonts=fonts
local handlers=fonts.handlers
local registerotffeature=handlers.otf.features.register
local registerafmfeature=handlers.afm.features.register
local function initialize(tfmdata,key,value)
  for unicode,character in next,tfmdata.characters do
    local olditalic=character.italic
    if olditalic and olditalic~=0 then
      character.width=character.width+olditalic
      character.italic=0
    end
  end
end
local specification={
  name="italicwidths",
  description="add italic to width",
  manipulators={
    base=initialize,
    node=initialize,
  }
}
registerotffeature(specification)
registerafmfeature(specification)
local function initialize(tfmdata,value) 
  if value then
    local parameters=tfmdata.parameters
    local italicangle=parameters.italicangle
    if italicangle and italicangle~=0 then
      local properties=tfmdata.properties
      local factor=tonumber(value) or 1
      properties.hasitalics=true
      properties.autoitalicamount=factor*(parameters.uwidth or 40)/2
    end
  end
end
local specification={
  name="itlc",
  description="italic correction",
  initializers={
    base=initialize,
    node=initialize,
  }
}
registerotffeature(specification)
registerafmfeature(specification)
if context then
  local function initialize(tfmdata,value) 
    tfmdata.properties.textitalics=toboolean(value)
  end
  local specification={
    name="textitalics",
    description="use alternative text italic correction",
    initializers={
      base=initialize,
      node=initialize,
    }
  }
  registerotffeature(specification)
  registerafmfeature(specification)
end
if context then
  local letter=characters.is_letter
  local always=true
  local function collapseitalics(tfmdata,key,value)
    local threshold=value==true and 100 or tonumber(value)
    if threshold and threshold>0 then
      if threshold>100 then
        threshold=100
      end
      for unicode,data in next,tfmdata.characters do
        if always or letter[unicode] or letter[data.unicode] then
          local italic=data.italic
          if italic and italic~=0 then
            local width=data.width
            if width and width~=0 then
              local delta=threshold*italic/100
              data.width=width+delta
              data.italic=italic-delta
            end
          end
        end
      end
    end
  end
  local dimensions_specification={
    name="collapseitalics",
    description="collapse italics",
    manipulators={
      base=collapseitalics,
      node=collapseitalics,
    }
  }
  registerotffeature(dimensions_specification)
  registerafmfeature(dimensions_specification)
end

end --- [luaotfload, fontloader-2018-10-08.lua scope for “font-imp-italics”] ---


do  --- [luaotfload, fontloader-2018-10-08.lua scope for “font-imp-effects” 3327181ef3db6f44dd234ad66ccc3f38] ---

if not modules then modules={} end modules ['font-imp-effects']={
  version=1.001,
  comment="companion to font-ini.mkiv and hand-ini.mkiv",
  author="Hans Hagen, PRAGMA-ADE, Hasselt NL",
  copyright="PRAGMA ADE / ConTeXt Development Team",
  license="see context related readme files"
}
local next,type,tonumber=next,type,tonumber
local is_boolean=string.is_boolean
local fonts=fonts
local handlers=fonts.handlers
local registerotffeature=handlers.otf.features.register
local registerafmfeature=handlers.afm.features.register
local settings_to_hash=utilities.parsers.settings_to_hash_colon_too
local helpers=fonts.helpers
local prependcommands=helpers.prependcommands
local charcommand=helpers.commands.char
local leftcommand=helpers.commands.left
local rightcommand=helpers.commands.right
local upcommand=helpers.commands.up
local downcommand=helpers.commands.down
local dummycommand=helpers.commands.dummy
local report_effect=logs.reporter("fonts","effect")
local report_slant=logs.reporter("fonts","slant")
local report_extend=logs.reporter("fonts","extend")
local report_squeeze=logs.reporter("fonts","squeeze")
local trace=false
trackers.register("fonts.effect",function(v) trace=v end)
trackers.register("fonts.slant",function(v) trace=v end)
trackers.register("fonts.extend",function(v) trace=v end)
trackers.register("fonts.squeeze",function(v) trace=v end)
local function initializeslant(tfmdata,value)
  value=tonumber(value)
  if not value then
    value=0
  elseif value>1 then
    value=1
  elseif value<-1 then
    value=-1
  end
  if trace then
    report_slant("applying %0.3f",value)
  end
  tfmdata.parameters.slantfactor=value
end
local specification={
  name="slant",
  description="slant glyphs",
  initializers={
    base=initializeslant,
    node=initializeslant,
  }
}
registerotffeature(specification)
registerafmfeature(specification)
local function initializeextend(tfmdata,value)
  value=tonumber(value)
  if not value then
    value=0
  elseif value>10 then
    value=10
  elseif value<-10 then
    value=-10
  end
  if trace then
    report_extend("applying %0.3f",value)
  end
  tfmdata.parameters.extendfactor=value
end
local specification={
  name="extend",
  description="scale glyphs horizontally",
  initializers={
    base=initializeextend,
    node=initializeextend,
  }
}
registerotffeature(specification)
registerafmfeature(specification)
local function initializesqueeze(tfmdata,value)
  value=tonumber(value)
  if not value then
    value=0
  elseif value>10 then
    value=10
  elseif value<-10 then
    value=-10
  end
  if trace then
    report_squeeze("applying %0.3f",value)
  end
  tfmdata.parameters.squeezefactor=value
end
local specification={
  name="squeeze",
  description="scale glyphs vertically",
  initializers={
    base=initializesqueeze,
    node=initializesqueeze,
  }
}
registerotffeature(specification)
registerafmfeature(specification)
local effects={
  inner=0,
  normal=0,
  outer=1,
  outline=1,
  both=2,
  hidden=3,
}
local function initializeeffect(tfmdata,value)
  local spec
  if type(value)=="number" then
    spec={ width=value }
  else
    spec=settings_to_hash(value)
  end
  local effect=spec.effect or "both"
  local width=tonumber(spec.width) or 0
  local mode=effects[effect]
  if not mode then
    report_effect("invalid effect %a",effect)
  elseif width==0 and mode==0 then
    report_effect("invalid width %a for effect %a",width,effect)
  else
    local parameters=tfmdata.parameters
    local properties=tfmdata.properties
    parameters.mode=mode
    parameters.width=width*1000
    if is_boolean(spec.auto)==true then
      local squeeze=1-width/20
      local average=(1-squeeze)*width*100
      spec.squeeze=squeeze
      spec.extend=1+width/2
      spec.wdelta=average
      spec.hdelta=average/2
      spec.ddelta=average/2
      spec.vshift=average/2
    end
    local factor=tonumber(spec.factor) or 0
    local hfactor=tonumber(spec.hfactor) or factor
    local vfactor=tonumber(spec.vfactor) or factor
    local delta=tonumber(spec.delta)  or 1
    local wdelta=tonumber(spec.wdelta) or delta
    local hdelta=tonumber(spec.hdelta) or delta
    local ddelta=tonumber(spec.ddelta) or hdelta
    local vshift=tonumber(spec.vshift) or 0
    local slant=spec.slant
    local extend=spec.extend
    local squeeze=spec.squeeze
    if slant then
      initializeslant(tfmdata,slant)
    end
    if extend then
      initializeextend(tfmdata,extend)
    end
    if squeeze then
      initializesqueeze(tfmdata,squeeze)
    end
    properties.effect={
      effect=effect,
      width=width,
      factor=factor,
      hfactor=hfactor,
      vfactor=vfactor,
      wdelta=wdelta,
      hdelta=hdelta,
      ddelta=ddelta,
      vshift=vshift,
      slant=tfmdata.parameters.slantfactor,
      extend=tfmdata.parameters.extendfactor,
      squeeze=tfmdata.parameters.squeezefactor,
    }
  end
end
local rules={
  "RadicalRuleThickness",
  "OverbarRuleThickness",
  "FractionRuleThickness",
  "UnderbarRuleThickness",
}
local function setmathparameters(tfmdata,characters,mathparameters,dx,dy,squeeze)
  if delta~=0 then
    for i=1,#rules do
      local name=rules[i]
      local value=mathparameters[name]
      if value then
        mathparameters[name]=(squeeze or 1)*(value+dx)
      end
    end
  end
end
local function setmathcharacters(tfmdata,characters,mathparameters,dx,dy,squeeze,wdelta,hdelta,ddelta)
  local function wdpatch(char)
    if wsnap~=0 then
      char.width=char.width+wdelta/2
    end
  end
  local function htpatch(char)
    if hsnap~=0 then
      local height=char.height
      if height then
        char.height=char.height+2*dy
      end
    end
  end
  local character=characters[0x221A]
  if character and character.next then
    local char=character
    local next=character.next
    wdpatch(char)
    htpatch(char)
    while next do
      char=characters[next]
      wdpatch(char)
      htpatch(char)
      next=char.next
    end
    if char then
      local v=char.vert_variants
      if v then
        local top=v[#v]
        if top then
          local char=characters[top.glyph]
          htpatch(char)
        end
      end
    end
  end
end
local function manipulateeffect(tfmdata)
  local effect=tfmdata.properties.effect
  if effect then
    local characters=tfmdata.characters
    local parameters=tfmdata.parameters
    local mathparameters=tfmdata.mathparameters
    local multiplier=effect.width*100
    local factor=parameters.factor
    local hfactor=parameters.hfactor
    local vfactor=parameters.vfactor
    local wdelta=effect.wdelta*hfactor*multiplier
    local hdelta=effect.hdelta*vfactor*multiplier
    local ddelta=effect.ddelta*vfactor*multiplier
    local vshift=effect.vshift*vfactor*multiplier
    local squeeze=effect.squeeze
    local hshift=wdelta/2
    local dx=multiplier*vfactor
    local dy=vshift
    local factor=(1+effect.factor)*factor
    local hfactor=(1+effect.hfactor)*hfactor
    local vfactor=(1+effect.vfactor)*vfactor
    local vshift=vshift~=0 and upcommand[vshift] or false
    for unicode,character in next,characters do
      local oldwidth=character.width
      local oldheight=character.height
      local olddepth=character.depth
      if oldwidth and oldwidth>0 then
        character.width=oldwidth+wdelta
        local commands=character.commands
        local hshift=rightcommand[hshift]
        if vshift then
          if commands then
            prependcommands (commands,
              hshift,
              vshift
            )
          else
            character.commands={
              hshift,
              vshift,
              charcommand[unicode]
            }
          end
        else
          if commands then
            prependcommands (commands,
              hshift
            )
          else
            character.commands={
              hshift,
              charcommand[unicode]
            }
          end
        end
      end
      if oldheight and oldheight>0 then
        character.height=oldheight+hdelta
      end
      if olddepth and olddepth>0 then
        character.depth=olddepth+ddelta
      end
    end
    if mathparameters then
      setmathparameters(tfmdata,characters,mathparameters,dx,dy,squeeze)
      setmathcharacters(tfmdata,characters,mathparameters,dx,dy,squeeze,wdelta,hdelta,ddelta)
    end
    parameters.factor=factor
    parameters.hfactor=hfactor
    parameters.vfactor=vfactor
    if trace then
      report_effect("applying")
      report_effect("  effect  : %s",effect.effect)
      report_effect("  width   : %s => %s",effect.width,multiplier)
      report_effect("  factor  : %s => %s",effect.factor,factor )
      report_effect("  hfactor : %s => %s",effect.hfactor,hfactor)
      report_effect("  vfactor : %s => %s",effect.vfactor,vfactor)
      report_effect("  wdelta  : %s => %s",effect.wdelta,wdelta)
      report_effect("  hdelta  : %s => %s",effect.hdelta,hdelta)
      report_effect("  ddelta  : %s => %s",effect.ddelta,ddelta)
    end
  end
end
local specification={
  name="effect",
  description="apply effects to glyphs",
  initializers={
    base=initializeeffect,
    node=initializeeffect,
  },
  manipulators={
    base=manipulateeffect,
    node=manipulateeffect,
  },
}
registerotffeature(specification)
registerafmfeature(specification)
local function initializeoutline(tfmdata,value)
  value=tonumber(value)
  if not value then
    value=0
  else
    value=tonumber(value) or 0
  end
  local parameters=tfmdata.parameters
  local properties=tfmdata.properties
  parameters.mode=effects.outline
  parameters.width=value*1000
  properties.effect={
    effect=effect,
    width=width,
  }
end
local specification={
  name="outline",
  description="outline glyphs",
  initializers={
    base=initializeoutline,
    node=initializeoutline,
  }
}
registerotffeature(specification)
registerafmfeature(specification)

end --- [luaotfload, fontloader-2018-10-08.lua scope for “font-imp-effects”] ---


do  --- [luaotfload, fontloader-2018-10-08.lua scope for “fonts-lig” fbd251eea3810a43a8d5542319361d68] ---


fonts.handlers.otf.addfeature {
 ["dataset"]={
 {
  ["data"]={
  ["À"]={ "A","̀" },
  ["Á"]={ "A","́" },
  ["Â"]={ "A","̂" },
  ["Ã"]={ "A","̃" },
  ["Ä"]={ "A","̈" },
  ["Å"]={ "A","̊" },
  ["Ç"]={ "C","̧" },
  ["È"]={ "E","̀" },
  ["É"]={ "E","́" },
  ["Ê"]={ "E","̂" },
  ["Ë"]={ "E","̈" },
  ["Ì"]={ "I","̀" },
  ["Í"]={ "I","́" },
  ["Î"]={ "I","̂" },
  ["Ï"]={ "I","̈" },
  ["Ñ"]={ "N","̃" },
  ["Ò"]={ "O","̀" },
  ["Ó"]={ "O","́" },
  ["Ô"]={ "O","̂" },
  ["Õ"]={ "O","̃" },
  ["Ö"]={ "O","̈" },
  ["Ù"]={ "U","̀" },
  ["Ú"]={ "U","́" },
  ["Û"]={ "U","̂" },
  ["Ü"]={ "U","̈" },
  ["Ý"]={ "Y","́" },
  ["à"]={ "a","̀" },
  ["á"]={ "a","́" },
  ["â"]={ "a","̂" },
  ["ã"]={ "a","̃" },
  ["ä"]={ "a","̈" },
  ["å"]={ "a","̊" },
  ["ç"]={ "c","̧" },
  ["è"]={ "e","̀" },
  ["é"]={ "e","́" },
  ["ê"]={ "e","̂" },
  ["ë"]={ "e","̈" },
  ["ì"]={ "i","̀" },
  ["í"]={ "i","́" },
  ["î"]={ "i","̂" },
  ["ï"]={ "i","̈" },
  ["ñ"]={ "n","̃" },
  ["ò"]={ "o","̀" },
  ["ó"]={ "o","́" },
  ["ô"]={ "o","̂" },
  ["õ"]={ "o","̃" },
  ["ö"]={ "o","̈" },
  ["ù"]={ "u","̀" },
  ["ú"]={ "u","́" },
  ["û"]={ "u","̂" },
  ["ü"]={ "u","̈" },
  ["ý"]={ "y","́" },
  ["ÿ"]={ "y","̈" },
  ["Ā"]={ "A","̄" },
  ["ā"]={ "a","̄" },
  ["Ă"]={ "A","̆" },
  ["ă"]={ "a","̆" },
  ["Ą"]={ "A","̨" },
  ["ą"]={ "a","̨" },
  ["Ć"]={ "C","́" },
  ["ć"]={ "c","́" },
  ["Ĉ"]={ "C","̂" },
  ["ĉ"]={ "c","̂" },
  ["Ċ"]={ "C","̇" },
  ["ċ"]={ "c","̇" },
  ["Č"]={ "C","̌" },
  ["č"]={ "c","̌" },
  ["Ď"]={ "D","̌" },
  ["ď"]={ "d","̌" },
  ["Ē"]={ "E","̄" },
  ["ē"]={ "e","̄" },
  ["Ĕ"]={ "E","̆" },
  ["ĕ"]={ "e","̆" },
  ["Ė"]={ "E","̇" },
  ["ė"]={ "e","̇" },
  ["Ę"]={ "E","̨" },
  ["ę"]={ "e","̨" },
  ["Ě"]={ "E","̌" },
  ["ě"]={ "e","̌" },
  ["Ĝ"]={ "G","̂" },
  ["ĝ"]={ "g","̂" },
  ["Ğ"]={ "G","̆" },
  ["ğ"]={ "g","̆" },
  ["Ġ"]={ "G","̇" },
  ["ġ"]={ "g","̇" },
  ["Ģ"]={ "G","̧" },
  ["ģ"]={ "g","̧" },
  ["Ĥ"]={ "H","̂" },
  ["ĥ"]={ "h","̂" },
  ["Ĩ"]={ "I","̃" },
  ["ĩ"]={ "i","̃" },
  ["Ī"]={ "I","̄" },
  ["ī"]={ "i","̄" },
  ["Ĭ"]={ "I","̆" },
  ["ĭ"]={ "i","̆" },
  ["Į"]={ "I","̨" },
  ["į"]={ "i","̨" },
  ["İ"]={ "I","̇" },
  ["Ĵ"]={ "J","̂" },
  ["ĵ"]={ "j","̂" },
  ["Ķ"]={ "K","̧" },
  ["ķ"]={ "k","̧" },
  ["Ĺ"]={ "L","́" },
  ["ĺ"]={ "l","́" },
  ["Ļ"]={ "L","̧" },
  ["ļ"]={ "l","̧" },
  ["Ľ"]={ "L","̌" },
  ["ľ"]={ "l","̌" },
  ["Ń"]={ "N","́" },
  ["ń"]={ "n","́" },
  ["Ņ"]={ "N","̧" },
  ["ņ"]={ "n","̧" },
  ["Ň"]={ "N","̌" },
  ["ň"]={ "n","̌" },
  ["Ō"]={ "O","̄" },
  ["ō"]={ "o","̄" },
  ["Ŏ"]={ "O","̆" },
  ["ŏ"]={ "o","̆" },
  ["Ő"]={ "O","̋" },
  ["ő"]={ "o","̋" },
  ["Ŕ"]={ "R","́" },
  ["ŕ"]={ "r","́" },
  ["Ŗ"]={ "R","̧" },
  ["ŗ"]={ "r","̧" },
  ["Ř"]={ "R","̌" },
  ["ř"]={ "r","̌" },
  ["Ś"]={ "S","́" },
  ["ś"]={ "s","́" },
  ["Ŝ"]={ "S","̂" },
  ["ŝ"]={ "s","̂" },
  ["Ş"]={ "S","̧" },
  ["ş"]={ "s","̧" },
  ["Š"]={ "S","̌" },
  ["š"]={ "s","̌" },
  ["Ţ"]={ "T","̧" },
  ["ţ"]={ "t","̧" },
  ["Ť"]={ "T","̌" },
  ["ť"]={ "t","̌" },
  ["Ũ"]={ "U","̃" },
  ["ũ"]={ "u","̃" },
  ["Ū"]={ "U","̄" },
  ["ū"]={ "u","̄" },
  ["Ŭ"]={ "U","̆" },
  ["ŭ"]={ "u","̆" },
  ["Ů"]={ "U","̊" },
  ["ů"]={ "u","̊" },
  ["Ű"]={ "U","̋" },
  ["ű"]={ "u","̋" },
  ["Ų"]={ "U","̨" },
  ["ų"]={ "u","̨" },
  ["Ŵ"]={ "W","̂" },
  ["ŵ"]={ "w","̂" },
  ["Ŷ"]={ "Y","̂" },
  ["ŷ"]={ "y","̂" },
  ["Ÿ"]={ "Y","̈" },
  ["Ź"]={ "Z","́" },
  ["ź"]={ "z","́" },
  ["Ż"]={ "Z","̇" },
  ["ż"]={ "z","̇" },
  ["Ž"]={ "Z","̌" },
  ["ž"]={ "z","̌" },
  ["Ơ"]={ "O","̛" },
  ["ơ"]={ "o","̛" },
  ["Ư"]={ "U","̛" },
  ["ư"]={ "u","̛" },
  ["Ǎ"]={ "A","̌" },
  ["ǎ"]={ "a","̌" },
  ["Ǐ"]={ "I","̌" },
  ["ǐ"]={ "i","̌" },
  ["Ǒ"]={ "O","̌" },
  ["ǒ"]={ "o","̌" },
  ["Ǔ"]={ "U","̌" },
  ["ǔ"]={ "u","̌" },
  ["Ǖ"]={ "Ü","̄" },
  ["ǖ"]={ "ü","̄" },
  ["Ǘ"]={ "Ü","́" },
  ["ǘ"]={ "ü","́" },
  ["Ǚ"]={ "Ü","̌" },
  ["ǚ"]={ "ü","̌" },
  ["Ǜ"]={ "Ü","̀" },
  ["ǜ"]={ "ü","̀" },
  ["Ǟ"]={ "Ä","̄" },
  ["ǟ"]={ "ä","̄" },
  ["Ǡ"]={ "Ȧ","̄" },
  ["ǡ"]={ "ȧ","̄" },
  ["Ǣ"]={ "Æ","̄" },
  ["ǣ"]={ "æ","̄" },
  ["Ǧ"]={ "G","̌" },
  ["ǧ"]={ "g","̌" },
  ["Ǩ"]={ "K","̌" },
  ["ǩ"]={ "k","̌" },
  ["Ǫ"]={ "O","̨" },
  ["ǫ"]={ "o","̨" },
  ["Ǭ"]={ "Ǫ","̄" },
  ["ǭ"]={ "ǫ","̄" },
  ["Ǯ"]={ "Ʒ","̌" },
  ["ǯ"]={ "ʒ","̌" },
  ["ǰ"]={ "j","̌" },
  ["Ǵ"]={ "G","́" },
  ["ǵ"]={ "g","́" },
  ["Ǹ"]={ "N","̀" },
  ["ǹ"]={ "n","̀" },
  ["Ǻ"]={ "Å","́" },
  ["ǻ"]={ "å","́" },
  ["Ǽ"]={ "Æ","́" },
  ["ǽ"]={ "æ","́" },
  ["Ǿ"]={ "Ø","́" },
  ["ǿ"]={ "ø","́" },
  ["Ȁ"]={ "A","̏" },
  ["ȁ"]={ "a","̏" },
  ["Ȃ"]={ "A","̑" },
  ["ȃ"]={ "a","̑" },
  ["Ȅ"]={ "E","̏" },
  ["ȅ"]={ "e","̏" },
  ["Ȇ"]={ "E","̑" },
  ["ȇ"]={ "e","̑" },
  ["Ȉ"]={ "I","̏" },
  ["ȉ"]={ "i","̏" },
  ["Ȋ"]={ "I","̑" },
  ["ȋ"]={ "i","̑" },
  ["Ȍ"]={ "O","̏" },
  ["ȍ"]={ "o","̏" },
  ["Ȏ"]={ "O","̑" },
  ["ȏ"]={ "o","̑" },
  ["Ȑ"]={ "R","̏" },
  ["ȑ"]={ "r","̏" },
  ["Ȓ"]={ "R","̑" },
  ["ȓ"]={ "r","̑" },
  ["Ȕ"]={ "U","̏" },
  ["ȕ"]={ "u","̏" },
  ["Ȗ"]={ "U","̑" },
  ["ȗ"]={ "u","̑" },
  ["Ș"]={ "S","̦" },
  ["ș"]={ "s","̦" },
  ["Ț"]={ "T","̦" },
  ["ț"]={ "t","̦" },
  ["Ȟ"]={ "H","̌" },
  ["ȟ"]={ "h","̌" },
  ["Ȧ"]={ "A","̇" },
  ["ȧ"]={ "a","̇" },
  ["Ȩ"]={ "E","̧" },
  ["ȩ"]={ "e","̧" },
  ["Ȫ"]={ "Ö","̄" },
  ["ȫ"]={ "ö","̄" },
  ["Ȭ"]={ "Õ","̄" },
  ["ȭ"]={ "õ","̄" },
  ["Ȯ"]={ "O","̇" },
  ["ȯ"]={ "o","̇" },
  ["Ȱ"]={ "Ȯ","̄" },
  ["ȱ"]={ "ȯ","̄" },
  ["Ȳ"]={ "Y","̄" },
  ["ȳ"]={ "y","̄" },
  ["̈́"]={ "̈","́" },
  ["΅"]={ "¨","́" },
  ["Ά"]={ "Α","́" },
  ["Έ"]={ "Ε","́" },
  ["Ή"]={ "Η","́" },
  ["Ί"]={ "Ι","́" },
  ["Ό"]={ "Ο","́" },
  ["Ύ"]={ "Υ","́" },
  ["Ώ"]={ "Ω","́" },
  ["ΐ"]={ "ϊ","́" },
  ["Ϊ"]={ "Ι","̈" },
  ["Ϋ"]={ "Υ","̈" },
  ["ά"]={ "α","́" },
  ["έ"]={ "ε","́" },
  ["ή"]={ "η","́" },
  ["ί"]={ "ι","́" },
  ["ΰ"]={ "ϋ","́" },
  ["ϊ"]={ "ι","̈" },
  ["ϋ"]={ "υ","̈" },
  ["ό"]={ "ο","́" },
  ["ύ"]={ "υ","́" },
  ["ώ"]={ "ω","́" },
  ["ϓ"]={ "ϒ","́" },
  ["ϔ"]={ "ϒ","̈" },
  ["Ѐ"]={ "Е","̀" },
  ["Ё"]={ "Е","̈" },
  ["Ѓ"]={ "Г","́" },
  ["Ї"]={ "І","̈" },
  ["Ќ"]={ "К","́" },
  ["Ѝ"]={ "И","̀" },
  ["Ў"]={ "У","̆" },
  ["Й"]={ "И","̆" },
  ["й"]={ "и","̆" },
  ["ѐ"]={ "е","̀" },
  ["ё"]={ "е","̈" },
  ["ѓ"]={ "г","́" },
  ["ї"]={ "і","̈" },
  ["ќ"]={ "к","́" },
  ["ѝ"]={ "и","̀" },
  ["ў"]={ "у","̆" },
  ["Ѷ"]={ "Ѵ","̏" },
  ["ѷ"]={ "ѵ","̏" },
  ["Ӂ"]={ "Ж","̆" },
  ["ӂ"]={ "ж","̆" },
  ["Ӑ"]={ "А","̆" },
  ["ӑ"]={ "а","̆" },
  ["Ӓ"]={ "А","̈" },
  ["ӓ"]={ "а","̈" },
  ["Ӗ"]={ "Е","̆" },
  ["ӗ"]={ "е","̆" },
  ["Ӛ"]={ "Ә","̈" },
  ["ӛ"]={ "ә","̈" },
  ["Ӝ"]={ "Ж","̈" },
  ["ӝ"]={ "ж","̈" },
  ["Ӟ"]={ "З","̈" },
  ["ӟ"]={ "з","̈" },
  ["Ӣ"]={ "И","̄" },
  ["ӣ"]={ "и","̄" },
  ["Ӥ"]={ "И","̈" },
  ["ӥ"]={ "и","̈" },
  ["Ӧ"]={ "О","̈" },
  ["ӧ"]={ "о","̈" },
  ["Ӫ"]={ "Ө","̈" },
  ["ӫ"]={ "ө","̈" },
  ["Ӭ"]={ "Э","̈" },
  ["ӭ"]={ "э","̈" },
  ["Ӯ"]={ "У","̄" },
  ["ӯ"]={ "у","̄" },
  ["Ӱ"]={ "У","̈" },
  ["ӱ"]={ "у","̈" },
  ["Ӳ"]={ "У","̋" },
  ["ӳ"]={ "у","̋" },
  ["Ӵ"]={ "Ч","̈" },
  ["ӵ"]={ "ч","̈" },
  ["Ӹ"]={ "Ы","̈" },
  ["ӹ"]={ "ы","̈" },
  ["آ"]={ "ا","ٓ" },
  ["أ"]={ "ا","ٔ" },
  ["ؤ"]={ "و","ٔ" },
  ["إ"]={ "ا","ٕ" },
  ["ئ"]={ "ي","ٔ" },
  ["ۀ"]={ "ە","ٔ" },
  ["ۂ"]={ "ہ","ٔ" },
  ["ۓ"]={ "ے","ٔ" },
  ["ऩ"]={ "न","़" },
  ["ऱ"]={ "र","़" },
  ["ऴ"]={ "ळ","़" },
  ["क़"]={ "क","़" },
  ["ख़"]={ "ख","़" },
  ["ग़"]={ "ग","़" },
  ["ज़"]={ "ज","़" },
  ["ड़"]={ "ड","़" },
  ["ढ़"]={ "ढ","़" },
  ["फ़"]={ "फ","़" },
  ["य़"]={ "य","़" },
  ["ো"]={ "ে","া" },
  ["ৌ"]={ "ে","ৗ" },
  ["ড়"]={ "ড","়" },
  ["ঢ়"]={ "ঢ","়" },
  ["য়"]={ "য","়" },
  ["ਲ਼"]={ "ਲ","਼" },
  ["ਸ਼"]={ "ਸ","਼" },
  ["ਖ਼"]={ "ਖ","਼" },
  ["ਗ਼"]={ "ਗ","਼" },
  ["ਜ਼"]={ "ਜ","਼" },
  ["ਫ਼"]={ "ਫ","਼" },
  ["ୈ"]={ "େ","ୖ" },
  ["ୋ"]={ "େ","ା" },
  ["ୌ"]={ "େ","ୗ" },
  ["ଡ଼"]={ "ଡ","଼" },
  ["ଢ଼"]={ "ଢ","଼" },
  ["ஔ"]={ "ஒ","ௗ" },
  ["ொ"]={ "ெ","ா" },
  ["ோ"]={ "ே","ா" },
  ["ௌ"]={ "ெ","ௗ" },
  ["ై"]={ "ె","ౖ" },
  ["ೀ"]={ "ಿ","ೕ" },
  ["ೇ"]={ "ೆ","ೕ" },
  ["ೈ"]={ "ೆ","ೖ" },
  ["ೊ"]={ "ೆ","ೂ" },
  ["ೋ"]={ "ೊ","ೕ" },
  ["ൊ"]={ "െ","ാ" },
  ["ോ"]={ "േ","ാ" },
  ["ൌ"]={ "െ","ൗ" },
  ["ේ"]={ "ෙ","්" },
  ["ො"]={ "ෙ","ා" },
  ["ෝ"]={ "ො","්" },
  ["ෞ"]={ "ෙ","ෟ" },
  ["གྷ"]={ "ག","ྷ" },
  ["ཌྷ"]={ "ཌ","ྷ" },
  ["དྷ"]={ "ད","ྷ" },
  ["བྷ"]={ "བ","ྷ" },
  ["ཛྷ"]={ "ཛ","ྷ" },
  ["ཀྵ"]={ "ཀ","ྵ" },
  ["ཱི"]={ "ཱ","ི" },
  ["ཱུ"]={ "ཱ","ུ" },
  ["ྲྀ"]={ "ྲ","ྀ" },
  ["ླྀ"]={ "ླ","ྀ" },
  ["ཱྀ"]={ "ཱ","ྀ" },
  ["ྒྷ"]={ "ྒ","ྷ" },
  ["ྜྷ"]={ "ྜ","ྷ" },
  ["ྡྷ"]={ "ྡ","ྷ" },
  ["ྦྷ"]={ "ྦ","ྷ" },
  ["ྫྷ"]={ "ྫ","ྷ" },
  ["ྐྵ"]={ "ྐ","ྵ" },
  ["ဦ"]={ "ဥ","ီ" },
  ["ᬆ"]={ "ᬅ","ᬵ" },
  ["ᬈ"]={ "ᬇ","ᬵ" },
  ["ᬊ"]={ "ᬉ","ᬵ" },
  ["ᬌ"]={ "ᬋ","ᬵ" },
  ["ᬎ"]={ "ᬍ","ᬵ" },
  ["ᬒ"]={ "ᬑ","ᬵ" },
  ["ᬻ"]={ "ᬺ","ᬵ" },
  ["ᬽ"]={ "ᬼ","ᬵ" },
  ["ᭀ"]={ "ᬾ","ᬵ" },
  ["ᭁ"]={ "ᬿ","ᬵ" },
  ["ᭃ"]={ "ᭂ","ᬵ" },
  ["Ḁ"]={ "A","̥" },
  ["ḁ"]={ "a","̥" },
  ["Ḃ"]={ "B","̇" },
  ["ḃ"]={ "b","̇" },
  ["Ḅ"]={ "B","̣" },
  ["ḅ"]={ "b","̣" },
  ["Ḇ"]={ "B","̱" },
  ["ḇ"]={ "b","̱" },
  ["Ḉ"]={ "Ç","́" },
  ["ḉ"]={ "ç","́" },
  ["Ḋ"]={ "D","̇" },
  ["ḋ"]={ "d","̇" },
  ["Ḍ"]={ "D","̣" },
  ["ḍ"]={ "d","̣" },
  ["Ḏ"]={ "D","̱" },
  ["ḏ"]={ "d","̱" },
  ["Ḑ"]={ "D","̧" },
  ["ḑ"]={ "d","̧" },
  ["Ḓ"]={ "D","̭" },
  ["ḓ"]={ "d","̭" },
  ["Ḕ"]={ "Ē","̀" },
  ["ḕ"]={ "ē","̀" },
  ["Ḗ"]={ "Ē","́" },
  ["ḗ"]={ "ē","́" },
  ["Ḙ"]={ "E","̭" },
  ["ḙ"]={ "e","̭" },
  ["Ḛ"]={ "E","̰" },
  ["ḛ"]={ "e","̰" },
  ["Ḝ"]={ "Ȩ","̆" },
  ["ḝ"]={ "ȩ","̆" },
  ["Ḟ"]={ "F","̇" },
  ["ḟ"]={ "f","̇" },
  ["Ḡ"]={ "G","̄" },
  ["ḡ"]={ "g","̄" },
  ["Ḣ"]={ "H","̇" },
  ["ḣ"]={ "h","̇" },
  ["Ḥ"]={ "H","̣" },
  ["ḥ"]={ "h","̣" },
  ["Ḧ"]={ "H","̈" },
  ["ḧ"]={ "h","̈" },
  ["Ḩ"]={ "H","̧" },
  ["ḩ"]={ "h","̧" },
  ["Ḫ"]={ "H","̮" },
  ["ḫ"]={ "h","̮" },
  ["Ḭ"]={ "I","̰" },
  ["ḭ"]={ "i","̰" },
  ["Ḯ"]={ "Ï","́" },
  ["ḯ"]={ "ï","́" },
  ["Ḱ"]={ "K","́" },
  ["ḱ"]={ "k","́" },
  ["Ḳ"]={ "K","̣" },
  ["ḳ"]={ "k","̣" },
  ["Ḵ"]={ "K","̱" },
  ["ḵ"]={ "k","̱" },
  ["Ḷ"]={ "L","̣" },
  ["ḷ"]={ "l","̣" },
  ["Ḹ"]={ "Ḷ","̄" },
  ["ḹ"]={ "ḷ","̄" },
  ["Ḻ"]={ "L","̱" },
  ["ḻ"]={ "l","̱" },
  ["Ḽ"]={ "L","̭" },
  ["ḽ"]={ "l","̭" },
  ["Ḿ"]={ "M","́" },
  ["ḿ"]={ "m","́" },
  ["Ṁ"]={ "M","̇" },
  ["ṁ"]={ "m","̇" },
  ["Ṃ"]={ "M","̣" },
  ["ṃ"]={ "m","̣" },
  ["Ṅ"]={ "N","̇" },
  ["ṅ"]={ "n","̇" },
  ["Ṇ"]={ "N","̣" },
  ["ṇ"]={ "n","̣" },
  ["Ṉ"]={ "N","̱" },
  ["ṉ"]={ "n","̱" },
  ["Ṋ"]={ "N","̭" },
  ["ṋ"]={ "n","̭" },
  ["Ṍ"]={ "Õ","́" },
  ["ṍ"]={ "õ","́" },
  ["Ṏ"]={ "Õ","̈" },
  ["ṏ"]={ "õ","̈" },
  ["Ṑ"]={ "Ō","̀" },
  ["ṑ"]={ "ō","̀" },
  ["Ṓ"]={ "Ō","́" },
  ["ṓ"]={ "ō","́" },
  ["Ṕ"]={ "P","́" },
  ["ṕ"]={ "p","́" },
  ["Ṗ"]={ "P","̇" },
  ["ṗ"]={ "p","̇" },
  ["Ṙ"]={ "R","̇" },
  ["ṙ"]={ "r","̇" },
  ["Ṛ"]={ "R","̣" },
  ["ṛ"]={ "r","̣" },
  ["Ṝ"]={ "Ṛ","̄" },
  ["ṝ"]={ "ṛ","̄" },
  ["Ṟ"]={ "R","̱" },
  ["ṟ"]={ "r","̱" },
  ["Ṡ"]={ "S","̇" },
  ["ṡ"]={ "s","̇" },
  ["Ṣ"]={ "S","̣" },
  ["ṣ"]={ "s","̣" },
  ["Ṥ"]={ "Ś","̇" },
  ["ṥ"]={ "ś","̇" },
  ["Ṧ"]={ "Š","̇" },
  ["ṧ"]={ "š","̇" },
  ["Ṩ"]={ "Ṣ","̇" },
  ["ṩ"]={ "ṣ","̇" },
  ["Ṫ"]={ "T","̇" },
  ["ṫ"]={ "t","̇" },
  ["Ṭ"]={ "T","̣" },
  ["ṭ"]={ "t","̣" },
  ["Ṯ"]={ "T","̱" },
  ["ṯ"]={ "t","̱" },
  ["Ṱ"]={ "T","̭" },
  ["ṱ"]={ "t","̭" },
  ["Ṳ"]={ "U","̤" },
  ["ṳ"]={ "u","̤" },
  ["Ṵ"]={ "U","̰" },
  ["ṵ"]={ "u","̰" },
  ["Ṷ"]={ "U","̭" },
  ["ṷ"]={ "u","̭" },
  ["Ṹ"]={ "Ũ","́" },
  ["ṹ"]={ "ũ","́" },
  ["Ṻ"]={ "Ū","̈" },
  ["ṻ"]={ "ū","̈" },
  ["Ṽ"]={ "V","̃" },
  ["ṽ"]={ "v","̃" },
  ["Ṿ"]={ "V","̣" },
  ["ṿ"]={ "v","̣" },
  ["Ẁ"]={ "W","̀" },
  ["ẁ"]={ "w","̀" },
  ["Ẃ"]={ "W","́" },
  ["ẃ"]={ "w","́" },
  ["Ẅ"]={ "W","̈" },
  ["ẅ"]={ "w","̈" },
  ["Ẇ"]={ "W","̇" },
  ["ẇ"]={ "w","̇" },
  ["Ẉ"]={ "W","̣" },
  ["ẉ"]={ "w","̣" },
  ["Ẋ"]={ "X","̇" },
  ["ẋ"]={ "x","̇" },
  ["Ẍ"]={ "X","̈" },
  ["ẍ"]={ "x","̈" },
  ["Ẏ"]={ "Y","̇" },
  ["ẏ"]={ "y","̇" },
  ["Ẑ"]={ "Z","̂" },
  ["ẑ"]={ "z","̂" },
  ["Ẓ"]={ "Z","̣" },
  ["ẓ"]={ "z","̣" },
  ["Ẕ"]={ "Z","̱" },
  ["ẕ"]={ "z","̱" },
  ["ẖ"]={ "h","̱" },
  ["ẗ"]={ "t","̈" },
  ["ẘ"]={ "w","̊" },
  ["ẙ"]={ "y","̊" },
  ["ẛ"]={ "ſ","̇" },
  ["Ạ"]={ "A","̣" },
  ["ạ"]={ "a","̣" },
  ["Ả"]={ "A","̉" },
  ["ả"]={ "a","̉" },
  ["Ấ"]={ "Â","́" },
  ["ấ"]={ "â","́" },
  ["Ầ"]={ "Â","̀" },
  ["ầ"]={ "â","̀" },
  ["Ẩ"]={ "Â","̉" },
  ["ẩ"]={ "â","̉" },
  ["Ẫ"]={ "Â","̃" },
  ["ẫ"]={ "â","̃" },
  ["Ậ"]={ "Ạ","̂" },
  ["ậ"]={ "ạ","̂" },
  ["Ắ"]={ "Ă","́" },
  ["ắ"]={ "ă","́" },
  ["Ằ"]={ "Ă","̀" },
  ["ằ"]={ "ă","̀" },
  ["Ẳ"]={ "Ă","̉" },
  ["ẳ"]={ "ă","̉" },
  ["Ẵ"]={ "Ă","̃" },
  ["ẵ"]={ "ă","̃" },
  ["Ặ"]={ "Ạ","̆" },
  ["ặ"]={ "ạ","̆" },
  ["Ẹ"]={ "E","̣" },
  ["ẹ"]={ "e","̣" },
  ["Ẻ"]={ "E","̉" },
  ["ẻ"]={ "e","̉" },
  ["Ẽ"]={ "E","̃" },
  ["ẽ"]={ "e","̃" },
  ["Ế"]={ "Ê","́" },
  ["ế"]={ "ê","́" },
  ["Ề"]={ "Ê","̀" },
  ["ề"]={ "ê","̀" },
  ["Ể"]={ "Ê","̉" },
  ["ể"]={ "ê","̉" },
  ["Ễ"]={ "Ê","̃" },
  ["ễ"]={ "ê","̃" },
  ["Ệ"]={ "Ẹ","̂" },
  ["ệ"]={ "ẹ","̂" },
  ["Ỉ"]={ "I","̉" },
  ["ỉ"]={ "i","̉" },
  ["Ị"]={ "I","̣" },
  ["ị"]={ "i","̣" },
  ["Ọ"]={ "O","̣" },
  ["ọ"]={ "o","̣" },
  ["Ỏ"]={ "O","̉" },
  ["ỏ"]={ "o","̉" },
  ["Ố"]={ "Ô","́" },
  ["ố"]={ "ô","́" },
  ["Ồ"]={ "Ô","̀" },
  ["ồ"]={ "ô","̀" },
  ["Ổ"]={ "Ô","̉" },
  ["ổ"]={ "ô","̉" },
  ["Ỗ"]={ "Ô","̃" },
  ["ỗ"]={ "ô","̃" },
  ["Ộ"]={ "Ọ","̂" },
  ["ộ"]={ "ọ","̂" },
  ["Ớ"]={ "Ơ","́" },
  ["ớ"]={ "ơ","́" },
  ["Ờ"]={ "Ơ","̀" },
  ["ờ"]={ "ơ","̀" },
  ["Ở"]={ "Ơ","̉" },
  ["ở"]={ "ơ","̉" },
  ["Ỡ"]={ "Ơ","̃" },
  ["ỡ"]={ "ơ","̃" },
  ["Ợ"]={ "Ơ","̣" },
  ["ợ"]={ "ơ","̣" },
  ["Ụ"]={ "U","̣" },
  ["ụ"]={ "u","̣" },
  ["Ủ"]={ "U","̉" },
  ["ủ"]={ "u","̉" },
  ["Ứ"]={ "Ư","́" },
  ["ứ"]={ "ư","́" },
  ["Ừ"]={ "Ư","̀" },
  ["ừ"]={ "ư","̀" },
  ["Ử"]={ "Ư","̉" },
  ["ử"]={ "ư","̉" },
  ["Ữ"]={ "Ư","̃" },
  ["ữ"]={ "ư","̃" },
  ["Ự"]={ "Ư","̣" },
  ["ự"]={ "ư","̣" },
  ["Ỳ"]={ "Y","̀" },
  ["ỳ"]={ "y","̀" },
  ["Ỵ"]={ "Y","̣" },
  ["ỵ"]={ "y","̣" },
  ["Ỷ"]={ "Y","̉" },
  ["ỷ"]={ "y","̉" },
  ["Ỹ"]={ "Y","̃" },
  ["ỹ"]={ "y","̃" },
  ["ἀ"]={ "α","̓" },
  ["ἁ"]={ "α","̔" },
  ["ἂ"]={ "ἀ","̀" },
  ["ἃ"]={ "ἁ","̀" },
  ["ἄ"]={ "ἀ","́" },
  ["ἅ"]={ "ἁ","́" },
  ["ἆ"]={ "ἀ","͂" },
  ["ἇ"]={ "ἁ","͂" },
  ["Ἀ"]={ "Α","̓" },
  ["Ἁ"]={ "Α","̔" },
  ["Ἂ"]={ "Ἀ","̀" },
  ["Ἃ"]={ "Ἁ","̀" },
  ["Ἄ"]={ "Ἀ","́" },
  ["Ἅ"]={ "Ἁ","́" },
  ["Ἆ"]={ "Ἀ","͂" },
  ["Ἇ"]={ "Ἁ","͂" },
  ["ἐ"]={ "ε","̓" },
  ["ἑ"]={ "ε","̔" },
  ["ἒ"]={ "ἐ","̀" },
  ["ἓ"]={ "ἑ","̀" },
  ["ἔ"]={ "ἐ","́" },
  ["ἕ"]={ "ἑ","́" },
  ["Ἐ"]={ "Ε","̓" },
  ["Ἑ"]={ "Ε","̔" },
  ["Ἒ"]={ "Ἐ","̀" },
  ["Ἓ"]={ "Ἑ","̀" },
  ["Ἔ"]={ "Ἐ","́" },
  ["Ἕ"]={ "Ἑ","́" },
  ["ἠ"]={ "η","̓" },
  ["ἡ"]={ "η","̔" },
  ["ἢ"]={ "ἠ","̀" },
  ["ἣ"]={ "ἡ","̀" },
  ["ἤ"]={ "ἠ","́" },
  ["ἥ"]={ "ἡ","́" },
  ["ἦ"]={ "ἠ","͂" },
  ["ἧ"]={ "ἡ","͂" },
  ["Ἠ"]={ "Η","̓" },
  ["Ἡ"]={ "Η","̔" },
  ["Ἢ"]={ "Ἠ","̀" },
  ["Ἣ"]={ "Ἡ","̀" },
  ["Ἤ"]={ "Ἠ","́" },
  ["Ἥ"]={ "Ἡ","́" },
  ["Ἦ"]={ "Ἠ","͂" },
  ["Ἧ"]={ "Ἡ","͂" },
  ["ἰ"]={ "ι","̓" },
  ["ἱ"]={ "ι","̔" },
  ["ἲ"]={ "ἰ","̀" },
  ["ἳ"]={ "ἱ","̀" },
  ["ἴ"]={ "ἰ","́" },
  ["ἵ"]={ "ἱ","́" },
  ["ἶ"]={ "ἰ","͂" },
  ["ἷ"]={ "ἱ","͂" },
  ["Ἰ"]={ "Ι","̓" },
  ["Ἱ"]={ "Ι","̔" },
  ["Ἲ"]={ "Ἰ","̀" },
  ["Ἳ"]={ "Ἱ","̀" },
  ["Ἴ"]={ "Ἰ","́" },
  ["Ἵ"]={ "Ἱ","́" },
  ["Ἶ"]={ "Ἰ","͂" },
  ["Ἷ"]={ "Ἱ","͂" },
  ["ὀ"]={ "ο","̓" },
  ["ὁ"]={ "ο","̔" },
  ["ὂ"]={ "ὀ","̀" },
  ["ὃ"]={ "ὁ","̀" },
  ["ὄ"]={ "ὀ","́" },
  ["ὅ"]={ "ὁ","́" },
  ["Ὀ"]={ "Ο","̓" },
  ["Ὁ"]={ "Ο","̔" },
  ["Ὂ"]={ "Ὀ","̀" },
  ["Ὃ"]={ "Ὁ","̀" },
  ["Ὄ"]={ "Ὀ","́" },
  ["Ὅ"]={ "Ὁ","́" },
  ["ὐ"]={ "υ","̓" },
  ["ὑ"]={ "υ","̔" },
  ["ὒ"]={ "ὐ","̀" },
  ["ὓ"]={ "ὑ","̀" },
  ["ὔ"]={ "ὐ","́" },
  ["ὕ"]={ "ὑ","́" },
  ["ὖ"]={ "ὐ","͂" },
  ["ὗ"]={ "ὑ","͂" },
  ["Ὑ"]={ "Υ","̔" },
  ["Ὓ"]={ "Ὑ","̀" },
  ["Ὕ"]={ "Ὑ","́" },
  ["Ὗ"]={ "Ὑ","͂" },
  ["ὠ"]={ "ω","̓" },
  ["ὡ"]={ "ω","̔" },
  ["ὢ"]={ "ὠ","̀" },
  ["ὣ"]={ "ὡ","̀" },
  ["ὤ"]={ "ὠ","́" },
  ["ὥ"]={ "ὡ","́" },
  ["ὦ"]={ "ὠ","͂" },
  ["ὧ"]={ "ὡ","͂" },
  ["Ὠ"]={ "Ω","̓" },
  ["Ὡ"]={ "Ω","̔" },
  ["Ὢ"]={ "Ὠ","̀" },
  ["Ὣ"]={ "Ὡ","̀" },
  ["Ὤ"]={ "Ὠ","́" },
  ["Ὥ"]={ "Ὡ","́" },
  ["Ὦ"]={ "Ὠ","͂" },
  ["Ὧ"]={ "Ὡ","͂" },
  ["ὰ"]={ "α","̀" },
  ["ὲ"]={ "ε","̀" },
  ["ὴ"]={ "η","̀" },
  ["ὶ"]={ "ι","̀" },
  ["ὸ"]={ "ο","̀" },
  ["ὺ"]={ "υ","̀" },
  ["ὼ"]={ "ω","̀" },
  ["ᾀ"]={ "ἀ","ͅ" },
  ["ᾁ"]={ "ἁ","ͅ" },
  ["ᾂ"]={ "ἂ","ͅ" },
  ["ᾃ"]={ "ἃ","ͅ" },
  ["ᾄ"]={ "ἄ","ͅ" },
  ["ᾅ"]={ "ἅ","ͅ" },
  ["ᾆ"]={ "ἆ","ͅ" },
  ["ᾇ"]={ "ἇ","ͅ" },
  ["ᾈ"]={ "Ἀ","ͅ" },
  ["ᾉ"]={ "Ἁ","ͅ" },
  ["ᾊ"]={ "Ἂ","ͅ" },
  ["ᾋ"]={ "Ἃ","ͅ" },
  ["ᾌ"]={ "Ἄ","ͅ" },
  ["ᾍ"]={ "Ἅ","ͅ" },
  ["ᾎ"]={ "Ἆ","ͅ" },
  ["ᾏ"]={ "Ἇ","ͅ" },
  ["ᾐ"]={ "ἠ","ͅ" },
  ["ᾑ"]={ "ἡ","ͅ" },
  ["ᾒ"]={ "ἢ","ͅ" },
  ["ᾓ"]={ "ἣ","ͅ" },
  ["ᾔ"]={ "ἤ","ͅ" },
  ["ᾕ"]={ "ἥ","ͅ" },
  ["ᾖ"]={ "ἦ","ͅ" },
  ["ᾗ"]={ "ἧ","ͅ" },
  ["ᾘ"]={ "Ἠ","ͅ" },
  ["ᾙ"]={ "Ἡ","ͅ" },
  ["ᾚ"]={ "Ἢ","ͅ" },
  ["ᾛ"]={ "Ἣ","ͅ" },
  ["ᾜ"]={ "Ἤ","ͅ" },
  ["ᾝ"]={ "Ἥ","ͅ" },
  ["ᾞ"]={ "Ἦ","ͅ" },
  ["ᾟ"]={ "Ἧ","ͅ" },
  ["ᾠ"]={ "ὠ","ͅ" },
  ["ᾡ"]={ "ὡ","ͅ" },
  ["ᾢ"]={ "ὢ","ͅ" },
  ["ᾣ"]={ "ὣ","ͅ" },
  ["ᾤ"]={ "ὤ","ͅ" },
  ["ᾥ"]={ "ὥ","ͅ" },
  ["ᾦ"]={ "ὦ","ͅ" },
  ["ᾧ"]={ "ὧ","ͅ" },
  ["ᾨ"]={ "Ὠ","ͅ" },
  ["ᾩ"]={ "Ὡ","ͅ" },
  ["ᾪ"]={ "Ὢ","ͅ" },
  ["ᾫ"]={ "Ὣ","ͅ" },
  ["ᾬ"]={ "Ὤ","ͅ" },
  ["ᾭ"]={ "Ὥ","ͅ" },
  ["ᾮ"]={ "Ὦ","ͅ" },
  ["ᾯ"]={ "Ὧ","ͅ" },
  ["ᾰ"]={ "α","̆" },
  ["ᾱ"]={ "α","̄" },
  ["ᾲ"]={ "ὰ","ͅ" },
  ["ᾳ"]={ "α","ͅ" },
  ["ᾴ"]={ "ά","ͅ" },
  ["ᾶ"]={ "α","͂" },
  ["ᾷ"]={ "ᾶ","ͅ" },
  ["Ᾰ"]={ "Α","̆" },
  ["Ᾱ"]={ "Α","̄" },
  ["Ὰ"]={ "Α","̀" },
  ["ᾼ"]={ "Α","ͅ" },
  ["῁"]={ "¨","͂" },
  ["ῂ"]={ "ὴ","ͅ" },
  ["ῃ"]={ "η","ͅ" },
  ["ῄ"]={ "ή","ͅ" },
  ["ῆ"]={ "η","͂" },
  ["ῇ"]={ "ῆ","ͅ" },
  ["Ὲ"]={ "Ε","̀" },
  ["Ὴ"]={ "Η","̀" },
  ["ῌ"]={ "Η","ͅ" },
  ["῍"]={ "᾿","̀" },
  ["῎"]={ "᾿","́" },
  ["῏"]={ "᾿","͂" },
  ["ῐ"]={ "ι","̆" },
  ["ῑ"]={ "ι","̄" },
  ["ῒ"]={ "ϊ","̀" },
  ["ῖ"]={ "ι","͂" },
  ["ῗ"]={ "ϊ","͂" },
  ["Ῐ"]={ "Ι","̆" },
  ["Ῑ"]={ "Ι","̄" },
  ["Ὶ"]={ "Ι","̀" },
  ["῝"]={ "῾","̀" },
  ["῞"]={ "῾","́" },
  ["῟"]={ "῾","͂" },
  ["ῠ"]={ "υ","̆" },
  ["ῡ"]={ "υ","̄" },
  ["ῢ"]={ "ϋ","̀" },
  ["ῤ"]={ "ρ","̓" },
  ["ῥ"]={ "ρ","̔" },
  ["ῦ"]={ "υ","͂" },
  ["ῧ"]={ "ϋ","͂" },
  ["Ῠ"]={ "Υ","̆" },
  ["Ῡ"]={ "Υ","̄" },
  ["Ὺ"]={ "Υ","̀" },
  ["Ῥ"]={ "Ρ","̔" },
  ["῭"]={ "¨","̀" },
  ["ῲ"]={ "ὼ","ͅ" },
  ["ῳ"]={ "ω","ͅ" },
  ["ῴ"]={ "ώ","ͅ" },
  ["ῶ"]={ "ω","͂" },
  ["ῷ"]={ "ῶ","ͅ" },
  ["Ὸ"]={ "Ο","̀" },
  ["Ὼ"]={ "Ω","̀" },
  ["ῼ"]={ "Ω","ͅ" },
  ["↚"]={ "←","̸" },
  ["↛"]={ "→","̸" },
  ["↮"]={ "↔","̸" },
  ["⇍"]={ "⇐","̸" },
  ["⇎"]={ "⇔","̸" },
  ["⇏"]={ "⇒","̸" },
  ["∄"]={ "∃","̸" },
  ["∉"]={ "∈","̸" },
  ["∌"]={ "∋","̸" },
  ["∤"]={ "∣","̸" },
  ["∦"]={ "∥","̸" },
  ["≁"]={ "∼","̸" },
  ["≄"]={ "≃","̸" },
  ["≇"]={ "≅","̸" },
  ["≉"]={ "≈","̸" },
  ["≠"]={ "=","̸" },
  ["≢"]={ "≡","̸" },
  ["≭"]={ "≍","̸" },
  ["≮"]={ "<","̸" },
  ["≯"]={ ">","̸" },
  ["≰"]={ "≤","̸" },
  ["≱"]={ "≥","̸" },
  ["≴"]={ "≲","̸" },
  ["≵"]={ "≳","̸" },
  ["≸"]={ "≶","̸" },
  ["≹"]={ "≷","̸" },
  ["⊀"]={ "≺","̸" },
  ["⊁"]={ "≻","̸" },
  ["⊄"]={ "⊂","̸" },
  ["⊅"]={ "⊃","̸" },
  ["⊈"]={ "⊆","̸" },
  ["⊉"]={ "⊇","̸" },
  ["⊬"]={ "⊢","̸" },
  ["⊭"]={ "⊨","̸" },
  ["⊮"]={ "⊩","̸" },
  ["⊯"]={ "⊫","̸" },
  ["⋠"]={ "≼","̸" },
  ["⋡"]={ "≽","̸" },
  ["⋢"]={ "⊑","̸" },
  ["⋣"]={ "⊒","̸" },
  ["⋪"]={ "⊲","̸" },
  ["⋫"]={ "⊳","̸" },
  ["⋬"]={ "⊴","̸" },
  ["⋭"]={ "⊵","̸" },
  ["⫝̸"]={ "⫝","̸" },
  ["が"]={ "か","゙" },
  ["ぎ"]={ "き","゙" },
  ["ぐ"]={ "く","゙" },
  ["げ"]={ "け","゙" },
  ["ご"]={ "こ","゙" },
  ["ざ"]={ "さ","゙" },
  ["じ"]={ "し","゙" },
  ["ず"]={ "す","゙" },
  ["ぜ"]={ "せ","゙" },
  ["ぞ"]={ "そ","゙" },
  ["だ"]={ "た","゙" },
  ["ぢ"]={ "ち","゙" },
  ["づ"]={ "つ","゙" },
  ["で"]={ "て","゙" },
  ["ど"]={ "と","゙" },
  ["ば"]={ "は","゙" },
  ["ぱ"]={ "は","゚" },
  ["び"]={ "ひ","゙" },
  ["ぴ"]={ "ひ","゚" },
  ["ぶ"]={ "ふ","゙" },
  ["ぷ"]={ "ふ","゚" },
  ["べ"]={ "へ","゙" },
  ["ぺ"]={ "へ","゚" },
  ["ぼ"]={ "ほ","゙" },
  ["ぽ"]={ "ほ","゚" },
  ["ゔ"]={ "う","゙" },
  ["ゞ"]={ "ゝ","゙" },
  ["ガ"]={ "カ","゙" },
  ["ギ"]={ "キ","゙" },
  ["グ"]={ "ク","゙" },
  ["ゲ"]={ "ケ","゙" },
  ["ゴ"]={ "コ","゙" },
  ["ザ"]={ "サ","゙" },
  ["ジ"]={ "シ","゙" },
  ["ズ"]={ "ス","゙" },
  ["ゼ"]={ "セ","゙" },
  ["ゾ"]={ "ソ","゙" },
  ["ダ"]={ "タ","゙" },
  ["ヂ"]={ "チ","゙" },
  ["ヅ"]={ "ツ","゙" },
  ["デ"]={ "テ","゙" },
  ["ド"]={ "ト","゙" },
  ["バ"]={ "ハ","゙" },
  ["パ"]={ "ハ","゚" },
  ["ビ"]={ "ヒ","゙" },
  ["ピ"]={ "ヒ","゚" },
  ["ブ"]={ "フ","゙" },
  ["プ"]={ "フ","゚" },
  ["ベ"]={ "ヘ","゙" },
  ["ペ"]={ "ヘ","゚" },
  ["ボ"]={ "ホ","゙" },
  ["ポ"]={ "ホ","゚" },
  ["ヴ"]={ "ウ","゙" },
  ["ヷ"]={ "ワ","゙" },
  ["ヸ"]={ "ヰ","゙" },
  ["ヹ"]={ "ヱ","゙" },
  ["ヺ"]={ "ヲ","゙" },
  ["ヾ"]={ "ヽ","゙" },
  ["יִ"]={ "י","ִ" },
  ["ײַ"]={ "ײ","ַ" },
  ["שׁ"]={ "ש","ׁ" },
  ["שׂ"]={ "ש","ׂ" },
  ["שּׁ"]={ "שּ","ׁ" },
  ["שּׂ"]={ "שּ","ׂ" },
  ["אַ"]={ "א","ַ" },
  ["אָ"]={ "א","ָ" },
  ["אּ"]={ "א","ּ" },
  ["בּ"]={ "ב","ּ" },
  ["גּ"]={ "ג","ּ" },
  ["דּ"]={ "ד","ּ" },
  ["הּ"]={ "ה","ּ" },
  ["וּ"]={ "ו","ּ" },
  ["זּ"]={ "ז","ּ" },
  ["טּ"]={ "ט","ּ" },
  ["יּ"]={ "י","ּ" },
  ["ךּ"]={ "ך","ּ" },
  ["כּ"]={ "כ","ּ" },
  ["לּ"]={ "ל","ּ" },
  ["מּ"]={ "מ","ּ" },
  ["נּ"]={ "נ","ּ" },
  ["סּ"]={ "ס","ּ" },
  ["ףּ"]={ "ף","ּ" },
  ["פּ"]={ "פ","ּ" },
  ["צּ"]={ "צ","ּ" },
  ["קּ"]={ "ק","ּ" },
  ["רּ"]={ "ר","ּ" },
  ["שּ"]={ "ש","ּ" },
  ["תּ"]={ "ת","ּ" },
  ["וֹ"]={ "ו","ֹ" },
  ["בֿ"]={ "ב","ֿ" },
  ["כֿ"]={ "כ","ֿ" },
  ["פֿ"]={ "פ","ֿ" },
  ["𑂚"]={ "𑂙","𑂺" },
  ["𑂜"]={ "𑂛","𑂺" },
  ["𑂫"]={ "𑂥","𑂺" },
  ["𑄮"]={ "𑄱","𑄧" },
  ["𑄯"]={ "𑄲","𑄧" },
  ["𑍋"]={ "𑍇","𑌾" },
  ["𑍌"]={ "𑍇","𑍗" },
  ["𑒻"]={ "𑒹","𑒺" },
  ["𑒼"]={ "𑒹","𑒰" },
  ["𑒾"]={ "𑒹","𑒽" },
  ["𑖺"]={ "𑖸","𑖯" },
  ["𑖻"]={ "𑖹","𑖯" },
  ["𝅗𝅥"]={ "𝅗","𝅥" },
  ["𝅘𝅥"]={ "𝅘","𝅥" },
  ["𝅘𝅥𝅮"]={ "𝅘𝅥","𝅮" },
  ["𝅘𝅥𝅯"]={ "𝅘𝅥","𝅯" },
  ["𝅘𝅥𝅰"]={ "𝅘𝅥","𝅰" },
  ["𝅘𝅥𝅱"]={ "𝅘𝅥","𝅱" },
  ["𝅘𝅥𝅲"]={ "𝅘𝅥","𝅲" },
  ["𝆹𝅥"]={ "𝆹","𝅥" },
  ["𝆺𝅥"]={ "𝆺","𝅥" },
  ["𝆹𝅥𝅮"]={ "𝆹𝅥","𝅮" },
  ["𝆺𝅥𝅮"]={ "𝆺𝅥","𝅮" },
  ["𝆹𝅥𝅯"]={ "𝆹𝅥","𝅯" },
  ["𝆺𝅥𝅯"]={ "𝆺𝅥","𝅯" },
  },
 },
 {
  ["data"]={
  ["À"]={ "A","̀" },
  ["Á"]={ "A","́" },
  ["Â"]={ "A","̂" },
  ["Ã"]={ "A","̃" },
  ["Ä"]={ "A","̈" },
  ["Å"]={ "A","̊" },
  ["Ç"]={ "C","̧" },
  ["È"]={ "E","̀" },
  ["É"]={ "E","́" },
  ["Ê"]={ "E","̂" },
  ["Ë"]={ "E","̈" },
  ["Ì"]={ "I","̀" },
  ["Í"]={ "I","́" },
  ["Î"]={ "I","̂" },
  ["Ï"]={ "I","̈" },
  ["Ñ"]={ "N","̃" },
  ["Ò"]={ "O","̀" },
  ["Ó"]={ "O","́" },
  ["Ô"]={ "O","̂" },
  ["Õ"]={ "O","̃" },
  ["Ö"]={ "O","̈" },
  ["Ù"]={ "U","̀" },
  ["Ú"]={ "U","́" },
  ["Û"]={ "U","̂" },
  ["Ü"]={ "U","̈" },
  ["Ý"]={ "Y","́" },
  ["à"]={ "a","̀" },
  ["á"]={ "a","́" },
  ["â"]={ "a","̂" },
  ["ã"]={ "a","̃" },
  ["ä"]={ "a","̈" },
  ["å"]={ "a","̊" },
  ["ç"]={ "c","̧" },
  ["è"]={ "e","̀" },
  ["é"]={ "e","́" },
  ["ê"]={ "e","̂" },
  ["ë"]={ "e","̈" },
  ["ì"]={ "i","̀" },
  ["í"]={ "i","́" },
  ["î"]={ "i","̂" },
  ["ï"]={ "i","̈" },
  ["ñ"]={ "n","̃" },
  ["ò"]={ "o","̀" },
  ["ó"]={ "o","́" },
  ["ô"]={ "o","̂" },
  ["õ"]={ "o","̃" },
  ["ö"]={ "o","̈" },
  ["ù"]={ "u","̀" },
  ["ú"]={ "u","́" },
  ["û"]={ "u","̂" },
  ["ü"]={ "u","̈" },
  ["ý"]={ "y","́" },
  ["ÿ"]={ "y","̈" },
  ["Ā"]={ "A","̄" },
  ["ā"]={ "a","̄" },
  ["Ă"]={ "A","̆" },
  ["ă"]={ "a","̆" },
  ["Ą"]={ "A","̨" },
  ["ą"]={ "a","̨" },
  ["Ć"]={ "C","́" },
  ["ć"]={ "c","́" },
  ["Ĉ"]={ "C","̂" },
  ["ĉ"]={ "c","̂" },
  ["Ċ"]={ "C","̇" },
  ["ċ"]={ "c","̇" },
  ["Č"]={ "C","̌" },
  ["č"]={ "c","̌" },
  ["Ď"]={ "D","̌" },
  ["ď"]={ "d","̌" },
  ["Ē"]={ "E","̄" },
  ["ē"]={ "e","̄" },
  ["Ĕ"]={ "E","̆" },
  ["ĕ"]={ "e","̆" },
  ["Ė"]={ "E","̇" },
  ["ė"]={ "e","̇" },
  ["Ę"]={ "E","̨" },
  ["ę"]={ "e","̨" },
  ["Ě"]={ "E","̌" },
  ["ě"]={ "e","̌" },
  ["Ĝ"]={ "G","̂" },
  ["ĝ"]={ "g","̂" },
  ["Ğ"]={ "G","̆" },
  ["ğ"]={ "g","̆" },
  ["Ġ"]={ "G","̇" },
  ["ġ"]={ "g","̇" },
  ["Ģ"]={ "G","̧" },
  ["ģ"]={ "g","̧" },
  ["Ĥ"]={ "H","̂" },
  ["ĥ"]={ "h","̂" },
  ["Ĩ"]={ "I","̃" },
  ["ĩ"]={ "i","̃" },
  ["Ī"]={ "I","̄" },
  ["ī"]={ "i","̄" },
  ["Ĭ"]={ "I","̆" },
  ["ĭ"]={ "i","̆" },
  ["Į"]={ "I","̨" },
  ["į"]={ "i","̨" },
  ["İ"]={ "I","̇" },
  ["Ĵ"]={ "J","̂" },
  ["ĵ"]={ "j","̂" },
  ["Ķ"]={ "K","̧" },
  ["ķ"]={ "k","̧" },
  ["Ĺ"]={ "L","́" },
  ["ĺ"]={ "l","́" },
  ["Ļ"]={ "L","̧" },
  ["ļ"]={ "l","̧" },
  ["Ľ"]={ "L","̌" },
  ["ľ"]={ "l","̌" },
  ["Ń"]={ "N","́" },
  ["ń"]={ "n","́" },
  ["Ņ"]={ "N","̧" },
  ["ņ"]={ "n","̧" },
  ["Ň"]={ "N","̌" },
  ["ň"]={ "n","̌" },
  ["Ō"]={ "O","̄" },
  ["ō"]={ "o","̄" },
  ["Ŏ"]={ "O","̆" },
  ["ŏ"]={ "o","̆" },
  ["Ő"]={ "O","̋" },
  ["ő"]={ "o","̋" },
  ["Ŕ"]={ "R","́" },
  ["ŕ"]={ "r","́" },
  ["Ŗ"]={ "R","̧" },
  ["ŗ"]={ "r","̧" },
  ["Ř"]={ "R","̌" },
  ["ř"]={ "r","̌" },
  ["Ś"]={ "S","́" },
  ["ś"]={ "s","́" },
  ["Ŝ"]={ "S","̂" },
  ["ŝ"]={ "s","̂" },
  ["Ş"]={ "S","̧" },
  ["ş"]={ "s","̧" },
  ["Š"]={ "S","̌" },
  ["š"]={ "s","̌" },
  ["Ţ"]={ "T","̧" },
  ["ţ"]={ "t","̧" },
  ["Ť"]={ "T","̌" },
  ["ť"]={ "t","̌" },
  ["Ũ"]={ "U","̃" },
  ["ũ"]={ "u","̃" },
  ["Ū"]={ "U","̄" },
  ["ū"]={ "u","̄" },
  ["Ŭ"]={ "U","̆" },
  ["ŭ"]={ "u","̆" },
  ["Ů"]={ "U","̊" },
  ["ů"]={ "u","̊" },
  ["Ű"]={ "U","̋" },
  ["ű"]={ "u","̋" },
  ["Ų"]={ "U","̨" },
  ["ų"]={ "u","̨" },
  ["Ŵ"]={ "W","̂" },
  ["ŵ"]={ "w","̂" },
  ["Ŷ"]={ "Y","̂" },
  ["ŷ"]={ "y","̂" },
  ["Ÿ"]={ "Y","̈" },
  ["Ź"]={ "Z","́" },
  ["ź"]={ "z","́" },
  ["Ż"]={ "Z","̇" },
  ["ż"]={ "z","̇" },
  ["Ž"]={ "Z","̌" },
  ["ž"]={ "z","̌" },
  ["Ơ"]={ "O","̛" },
  ["ơ"]={ "o","̛" },
  ["Ư"]={ "U","̛" },
  ["ư"]={ "u","̛" },
  ["Ǎ"]={ "A","̌" },
  ["ǎ"]={ "a","̌" },
  ["Ǐ"]={ "I","̌" },
  ["ǐ"]={ "i","̌" },
  ["Ǒ"]={ "O","̌" },
  ["ǒ"]={ "o","̌" },
  ["Ǔ"]={ "U","̌" },
  ["ǔ"]={ "u","̌" },
  ["Ǖ"]={ "Ü","̄" },
  ["ǖ"]={ "ü","̄" },
  ["Ǘ"]={ "Ü","́" },
  ["ǘ"]={ "ü","́" },
  ["Ǚ"]={ "Ü","̌" },
  ["ǚ"]={ "ü","̌" },
  ["Ǜ"]={ "Ü","̀" },
  ["ǜ"]={ "ü","̀" },
  ["Ǟ"]={ "Ä","̄" },
  ["ǟ"]={ "ä","̄" },
  ["Ǡ"]={ "Ȧ","̄" },
  ["ǡ"]={ "ȧ","̄" },
  ["Ǣ"]={ "Æ","̄" },
  ["ǣ"]={ "æ","̄" },
  ["Ǧ"]={ "G","̌" },
  ["ǧ"]={ "g","̌" },
  ["Ǩ"]={ "K","̌" },
  ["ǩ"]={ "k","̌" },
  ["Ǫ"]={ "O","̨" },
  ["ǫ"]={ "o","̨" },
  ["Ǭ"]={ "Ǫ","̄" },
  ["ǭ"]={ "ǫ","̄" },
  ["Ǯ"]={ "Ʒ","̌" },
  ["ǯ"]={ "ʒ","̌" },
  ["ǰ"]={ "j","̌" },
  ["Ǵ"]={ "G","́" },
  ["ǵ"]={ "g","́" },
  ["Ǹ"]={ "N","̀" },
  ["ǹ"]={ "n","̀" },
  ["Ǻ"]={ "Å","́" },
  ["ǻ"]={ "å","́" },
  ["Ǽ"]={ "Æ","́" },
  ["ǽ"]={ "æ","́" },
  ["Ǿ"]={ "Ø","́" },
  ["ǿ"]={ "ø","́" },
  ["Ȁ"]={ "A","̏" },
  ["ȁ"]={ "a","̏" },
  ["Ȃ"]={ "A","̑" },
  ["ȃ"]={ "a","̑" },
  ["Ȅ"]={ "E","̏" },
  ["ȅ"]={ "e","̏" },
  ["Ȇ"]={ "E","̑" },
  ["ȇ"]={ "e","̑" },
  ["Ȉ"]={ "I","̏" },
  ["ȉ"]={ "i","̏" },
  ["Ȋ"]={ "I","̑" },
  ["ȋ"]={ "i","̑" },
  ["Ȍ"]={ "O","̏" },
  ["ȍ"]={ "o","̏" },
  ["Ȏ"]={ "O","̑" },
  ["ȏ"]={ "o","̑" },
  ["Ȑ"]={ "R","̏" },
  ["ȑ"]={ "r","̏" },
  ["Ȓ"]={ "R","̑" },
  ["ȓ"]={ "r","̑" },
  ["Ȕ"]={ "U","̏" },
  ["ȕ"]={ "u","̏" },
  ["Ȗ"]={ "U","̑" },
  ["ȗ"]={ "u","̑" },
  ["Ș"]={ "S","̦" },
  ["ș"]={ "s","̦" },
  ["Ț"]={ "T","̦" },
  ["ț"]={ "t","̦" },
  ["Ȟ"]={ "H","̌" },
  ["ȟ"]={ "h","̌" },
  ["Ȧ"]={ "A","̇" },
  ["ȧ"]={ "a","̇" },
  ["Ȩ"]={ "E","̧" },
  ["ȩ"]={ "e","̧" },
  ["Ȫ"]={ "Ö","̄" },
  ["ȫ"]={ "ö","̄" },
  ["Ȭ"]={ "Õ","̄" },
  ["ȭ"]={ "õ","̄" },
  ["Ȯ"]={ "O","̇" },
  ["ȯ"]={ "o","̇" },
  ["Ȱ"]={ "Ȯ","̄" },
  ["ȱ"]={ "ȯ","̄" },
  ["Ȳ"]={ "Y","̄" },
  ["ȳ"]={ "y","̄" },
  ["̈́"]={ "̈","́" },
  ["΅"]={ "¨","́" },
  ["Ά"]={ "Α","́" },
  ["Έ"]={ "Ε","́" },
  ["Ή"]={ "Η","́" },
  ["Ί"]={ "Ι","́" },
  ["Ό"]={ "Ο","́" },
  ["Ύ"]={ "Υ","́" },
  ["Ώ"]={ "Ω","́" },
  ["ΐ"]={ "ϊ","́" },
  ["Ϊ"]={ "Ι","̈" },
  ["Ϋ"]={ "Υ","̈" },
  ["ά"]={ "α","́" },
  ["έ"]={ "ε","́" },
  ["ή"]={ "η","́" },
  ["ί"]={ "ι","́" },
  ["ΰ"]={ "ϋ","́" },
  ["ϊ"]={ "ι","̈" },
  ["ϋ"]={ "υ","̈" },
  ["ό"]={ "ο","́" },
  ["ύ"]={ "υ","́" },
  ["ώ"]={ "ω","́" },
  ["ϓ"]={ "ϒ","́" },
  ["ϔ"]={ "ϒ","̈" },
  ["Ѐ"]={ "Е","̀" },
  ["Ё"]={ "Е","̈" },
  ["Ѓ"]={ "Г","́" },
  ["Ї"]={ "І","̈" },
  ["Ќ"]={ "К","́" },
  ["Ѝ"]={ "И","̀" },
  ["Ў"]={ "У","̆" },
  ["Й"]={ "И","̆" },
  ["й"]={ "и","̆" },
  ["ѐ"]={ "е","̀" },
  ["ё"]={ "е","̈" },
  ["ѓ"]={ "г","́" },
  ["ї"]={ "і","̈" },
  ["ќ"]={ "к","́" },
  ["ѝ"]={ "и","̀" },
  ["ў"]={ "у","̆" },
  ["Ѷ"]={ "Ѵ","̏" },
  ["ѷ"]={ "ѵ","̏" },
  ["Ӂ"]={ "Ж","̆" },
  ["ӂ"]={ "ж","̆" },
  ["Ӑ"]={ "А","̆" },
  ["ӑ"]={ "а","̆" },
  ["Ӓ"]={ "А","̈" },
  ["ӓ"]={ "а","̈" },
  ["Ӗ"]={ "Е","̆" },
  ["ӗ"]={ "е","̆" },
  ["Ӛ"]={ "Ә","̈" },
  ["ӛ"]={ "ә","̈" },
  ["Ӝ"]={ "Ж","̈" },
  ["ӝ"]={ "ж","̈" },
  ["Ӟ"]={ "З","̈" },
  ["ӟ"]={ "з","̈" },
  ["Ӣ"]={ "И","̄" },
  ["ӣ"]={ "и","̄" },
  ["Ӥ"]={ "И","̈" },
  ["ӥ"]={ "и","̈" },
  ["Ӧ"]={ "О","̈" },
  ["ӧ"]={ "о","̈" },
  ["Ӫ"]={ "Ө","̈" },
  ["ӫ"]={ "ө","̈" },
  ["Ӭ"]={ "Э","̈" },
  ["ӭ"]={ "э","̈" },
  ["Ӯ"]={ "У","̄" },
  ["ӯ"]={ "у","̄" },
  ["Ӱ"]={ "У","̈" },
  ["ӱ"]={ "у","̈" },
  ["Ӳ"]={ "У","̋" },
  ["ӳ"]={ "у","̋" },
  ["Ӵ"]={ "Ч","̈" },
  ["ӵ"]={ "ч","̈" },
  ["Ӹ"]={ "Ы","̈" },
  ["ӹ"]={ "ы","̈" },
  ["آ"]={ "ا","ٓ" },
  ["أ"]={ "ا","ٔ" },
  ["ؤ"]={ "و","ٔ" },
  ["إ"]={ "ا","ٕ" },
  ["ئ"]={ "ي","ٔ" },
  ["ۀ"]={ "ە","ٔ" },
  ["ۂ"]={ "ہ","ٔ" },
  ["ۓ"]={ "ے","ٔ" },
  ["ऩ"]={ "न","़" },
  ["ऱ"]={ "र","़" },
  ["ऴ"]={ "ळ","़" },
  ["क़"]={ "क","़" },
  ["ख़"]={ "ख","़" },
  ["ग़"]={ "ग","़" },
  ["ज़"]={ "ज","़" },
  ["ड़"]={ "ड","़" },
  ["ढ़"]={ "ढ","़" },
  ["फ़"]={ "फ","़" },
  ["य़"]={ "य","़" },
  ["ো"]={ "ে","া" },
  ["ৌ"]={ "ে","ৗ" },
  ["ড়"]={ "ড","়" },
  ["ঢ়"]={ "ঢ","়" },
  ["য়"]={ "য","়" },
  ["ਲ਼"]={ "ਲ","਼" },
  ["ਸ਼"]={ "ਸ","਼" },
  ["ਖ਼"]={ "ਖ","਼" },
  ["ਗ਼"]={ "ਗ","਼" },
  ["ਜ਼"]={ "ਜ","਼" },
  ["ਫ਼"]={ "ਫ","਼" },
  ["ୈ"]={ "େ","ୖ" },
  ["ୋ"]={ "େ","ା" },
  ["ୌ"]={ "େ","ୗ" },
  ["ଡ଼"]={ "ଡ","଼" },
  ["ଢ଼"]={ "ଢ","଼" },
  ["ஔ"]={ "ஒ","ௗ" },
  ["ொ"]={ "ெ","ா" },
  ["ோ"]={ "ே","ா" },
  ["ௌ"]={ "ெ","ௗ" },
  ["ై"]={ "ె","ౖ" },
  ["ೀ"]={ "ಿ","ೕ" },
  ["ೇ"]={ "ೆ","ೕ" },
  ["ೈ"]={ "ೆ","ೖ" },
  ["ೊ"]={ "ೆ","ೂ" },
  ["ೋ"]={ "ೊ","ೕ" },
  ["ൊ"]={ "െ","ാ" },
  ["ോ"]={ "േ","ാ" },
  ["ൌ"]={ "െ","ൗ" },
  ["ේ"]={ "ෙ","්" },
  ["ො"]={ "ෙ","ා" },
  ["ෝ"]={ "ො","්" },
  ["ෞ"]={ "ෙ","ෟ" },
  ["གྷ"]={ "ག","ྷ" },
  ["ཌྷ"]={ "ཌ","ྷ" },
  ["དྷ"]={ "ད","ྷ" },
  ["བྷ"]={ "བ","ྷ" },
  ["ཛྷ"]={ "ཛ","ྷ" },
  ["ཀྵ"]={ "ཀ","ྵ" },
  ["ཱི"]={ "ཱ","ི" },
  ["ཱུ"]={ "ཱ","ུ" },
  ["ྲྀ"]={ "ྲ","ྀ" },
  ["ླྀ"]={ "ླ","ྀ" },
  ["ཱྀ"]={ "ཱ","ྀ" },
  ["ྒྷ"]={ "ྒ","ྷ" },
  ["ྜྷ"]={ "ྜ","ྷ" },
  ["ྡྷ"]={ "ྡ","ྷ" },
  ["ྦྷ"]={ "ྦ","ྷ" },
  ["ྫྷ"]={ "ྫ","ྷ" },
  ["ྐྵ"]={ "ྐ","ྵ" },
  ["ဦ"]={ "ဥ","ီ" },
  ["ᬆ"]={ "ᬅ","ᬵ" },
  ["ᬈ"]={ "ᬇ","ᬵ" },
  ["ᬊ"]={ "ᬉ","ᬵ" },
  ["ᬌ"]={ "ᬋ","ᬵ" },
  ["ᬎ"]={ "ᬍ","ᬵ" },
  ["ᬒ"]={ "ᬑ","ᬵ" },
  ["ᬻ"]={ "ᬺ","ᬵ" },
  ["ᬽ"]={ "ᬼ","ᬵ" },
  ["ᭀ"]={ "ᬾ","ᬵ" },
  ["ᭁ"]={ "ᬿ","ᬵ" },
  ["ᭃ"]={ "ᭂ","ᬵ" },
  ["Ḁ"]={ "A","̥" },
  ["ḁ"]={ "a","̥" },
  ["Ḃ"]={ "B","̇" },
  ["ḃ"]={ "b","̇" },
  ["Ḅ"]={ "B","̣" },
  ["ḅ"]={ "b","̣" },
  ["Ḇ"]={ "B","̱" },
  ["ḇ"]={ "b","̱" },
  ["Ḉ"]={ "Ç","́" },
  ["ḉ"]={ "ç","́" },
  ["Ḋ"]={ "D","̇" },
  ["ḋ"]={ "d","̇" },
  ["Ḍ"]={ "D","̣" },
  ["ḍ"]={ "d","̣" },
  ["Ḏ"]={ "D","̱" },
  ["ḏ"]={ "d","̱" },
  ["Ḑ"]={ "D","̧" },
  ["ḑ"]={ "d","̧" },
  ["Ḓ"]={ "D","̭" },
  ["ḓ"]={ "d","̭" },
  ["Ḕ"]={ "Ē","̀" },
  ["ḕ"]={ "ē","̀" },
  ["Ḗ"]={ "Ē","́" },
  ["ḗ"]={ "ē","́" },
  ["Ḙ"]={ "E","̭" },
  ["ḙ"]={ "e","̭" },
  ["Ḛ"]={ "E","̰" },
  ["ḛ"]={ "e","̰" },
  ["Ḝ"]={ "Ȩ","̆" },
  ["ḝ"]={ "ȩ","̆" },
  ["Ḟ"]={ "F","̇" },
  ["ḟ"]={ "f","̇" },
  ["Ḡ"]={ "G","̄" },
  ["ḡ"]={ "g","̄" },
  ["Ḣ"]={ "H","̇" },
  ["ḣ"]={ "h","̇" },
  ["Ḥ"]={ "H","̣" },
  ["ḥ"]={ "h","̣" },
  ["Ḧ"]={ "H","̈" },
  ["ḧ"]={ "h","̈" },
  ["Ḩ"]={ "H","̧" },
  ["ḩ"]={ "h","̧" },
  ["Ḫ"]={ "H","̮" },
  ["ḫ"]={ "h","̮" },
  ["Ḭ"]={ "I","̰" },
  ["ḭ"]={ "i","̰" },
  ["Ḯ"]={ "Ï","́" },
  ["ḯ"]={ "ï","́" },
  ["Ḱ"]={ "K","́" },
  ["ḱ"]={ "k","́" },
  ["Ḳ"]={ "K","̣" },
  ["ḳ"]={ "k","̣" },
  ["Ḵ"]={ "K","̱" },
  ["ḵ"]={ "k","̱" },
  ["Ḷ"]={ "L","̣" },
  ["ḷ"]={ "l","̣" },
  ["Ḹ"]={ "Ḷ","̄" },
  ["ḹ"]={ "ḷ","̄" },
  ["Ḻ"]={ "L","̱" },
  ["ḻ"]={ "l","̱" },
  ["Ḽ"]={ "L","̭" },
  ["ḽ"]={ "l","̭" },
  ["Ḿ"]={ "M","́" },
  ["ḿ"]={ "m","́" },
  ["Ṁ"]={ "M","̇" },
  ["ṁ"]={ "m","̇" },
  ["Ṃ"]={ "M","̣" },
  ["ṃ"]={ "m","̣" },
  ["Ṅ"]={ "N","̇" },
  ["ṅ"]={ "n","̇" },
  ["Ṇ"]={ "N","̣" },
  ["ṇ"]={ "n","̣" },
  ["Ṉ"]={ "N","̱" },
  ["ṉ"]={ "n","̱" },
  ["Ṋ"]={ "N","̭" },
  ["ṋ"]={ "n","̭" },
  ["Ṍ"]={ "Õ","́" },
  ["ṍ"]={ "õ","́" },
  ["Ṏ"]={ "Õ","̈" },
  ["ṏ"]={ "õ","̈" },
  ["Ṑ"]={ "Ō","̀" },
  ["ṑ"]={ "ō","̀" },
  ["Ṓ"]={ "Ō","́" },
  ["ṓ"]={ "ō","́" },
  ["Ṕ"]={ "P","́" },
  ["ṕ"]={ "p","́" },
  ["Ṗ"]={ "P","̇" },
  ["ṗ"]={ "p","̇" },
  ["Ṙ"]={ "R","̇" },
  ["ṙ"]={ "r","̇" },
  ["Ṛ"]={ "R","̣" },
  ["ṛ"]={ "r","̣" },
  ["Ṝ"]={ "Ṛ","̄" },
  ["ṝ"]={ "ṛ","̄" },
  ["Ṟ"]={ "R","̱" },
  ["ṟ"]={ "r","̱" },
  ["Ṡ"]={ "S","̇" },
  ["ṡ"]={ "s","̇" },
  ["Ṣ"]={ "S","̣" },
  ["ṣ"]={ "s","̣" },
  ["Ṥ"]={ "Ś","̇" },
  ["ṥ"]={ "ś","̇" },
  ["Ṧ"]={ "Š","̇" },
  ["ṧ"]={ "š","̇" },
  ["Ṩ"]={ "Ṣ","̇" },
  ["ṩ"]={ "ṣ","̇" },
  ["Ṫ"]={ "T","̇" },
  ["ṫ"]={ "t","̇" },
  ["Ṭ"]={ "T","̣" },
  ["ṭ"]={ "t","̣" },
  ["Ṯ"]={ "T","̱" },
  ["ṯ"]={ "t","̱" },
  ["Ṱ"]={ "T","̭" },
  ["ṱ"]={ "t","̭" },
  ["Ṳ"]={ "U","̤" },
  ["ṳ"]={ "u","̤" },
  ["Ṵ"]={ "U","̰" },
  ["ṵ"]={ "u","̰" },
  ["Ṷ"]={ "U","̭" },
  ["ṷ"]={ "u","̭" },
  ["Ṹ"]={ "Ũ","́" },
  ["ṹ"]={ "ũ","́" },
  ["Ṻ"]={ "Ū","̈" },
  ["ṻ"]={ "ū","̈" },
  ["Ṽ"]={ "V","̃" },
  ["ṽ"]={ "v","̃" },
  ["Ṿ"]={ "V","̣" },
  ["ṿ"]={ "v","̣" },
  ["Ẁ"]={ "W","̀" },
  ["ẁ"]={ "w","̀" },
  ["Ẃ"]={ "W","́" },
  ["ẃ"]={ "w","́" },
  ["Ẅ"]={ "W","̈" },
  ["ẅ"]={ "w","̈" },
  ["Ẇ"]={ "W","̇" },
  ["ẇ"]={ "w","̇" },
  ["Ẉ"]={ "W","̣" },
  ["ẉ"]={ "w","̣" },
  ["Ẋ"]={ "X","̇" },
  ["ẋ"]={ "x","̇" },
  ["Ẍ"]={ "X","̈" },
  ["ẍ"]={ "x","̈" },
  ["Ẏ"]={ "Y","̇" },
  ["ẏ"]={ "y","̇" },
  ["Ẑ"]={ "Z","̂" },
  ["ẑ"]={ "z","̂" },
  ["Ẓ"]={ "Z","̣" },
  ["ẓ"]={ "z","̣" },
  ["Ẕ"]={ "Z","̱" },
  ["ẕ"]={ "z","̱" },
  ["ẖ"]={ "h","̱" },
  ["ẗ"]={ "t","̈" },
  ["ẘ"]={ "w","̊" },
  ["ẙ"]={ "y","̊" },
  ["ẛ"]={ "ſ","̇" },
  ["Ạ"]={ "A","̣" },
  ["ạ"]={ "a","̣" },
  ["Ả"]={ "A","̉" },
  ["ả"]={ "a","̉" },
  ["Ấ"]={ "Â","́" },
  ["ấ"]={ "â","́" },
  ["Ầ"]={ "Â","̀" },
  ["ầ"]={ "â","̀" },
  ["Ẩ"]={ "Â","̉" },
  ["ẩ"]={ "â","̉" },
  ["Ẫ"]={ "Â","̃" },
  ["ẫ"]={ "â","̃" },
  ["Ậ"]={ "Ạ","̂" },
  ["ậ"]={ "ạ","̂" },
  ["Ắ"]={ "Ă","́" },
  ["ắ"]={ "ă","́" },
  ["Ằ"]={ "Ă","̀" },
  ["ằ"]={ "ă","̀" },
  ["Ẳ"]={ "Ă","̉" },
  ["ẳ"]={ "ă","̉" },
  ["Ẵ"]={ "Ă","̃" },
  ["ẵ"]={ "ă","̃" },
  ["Ặ"]={ "Ạ","̆" },
  ["ặ"]={ "ạ","̆" },
  ["Ẹ"]={ "E","̣" },
  ["ẹ"]={ "e","̣" },
  ["Ẻ"]={ "E","̉" },
  ["ẻ"]={ "e","̉" },
  ["Ẽ"]={ "E","̃" },
  ["ẽ"]={ "e","̃" },
  ["Ế"]={ "Ê","́" },
  ["ế"]={ "ê","́" },
  ["Ề"]={ "Ê","̀" },
  ["ề"]={ "ê","̀" },
  ["Ể"]={ "Ê","̉" },
  ["ể"]={ "ê","̉" },
  ["Ễ"]={ "Ê","̃" },
  ["ễ"]={ "ê","̃" },
  ["Ệ"]={ "Ẹ","̂" },
  ["ệ"]={ "ẹ","̂" },
  ["Ỉ"]={ "I","̉" },
  ["ỉ"]={ "i","̉" },
  ["Ị"]={ "I","̣" },
  ["ị"]={ "i","̣" },
  ["Ọ"]={ "O","̣" },
  ["ọ"]={ "o","̣" },
  ["Ỏ"]={ "O","̉" },
  ["ỏ"]={ "o","̉" },
  ["Ố"]={ "Ô","́" },
  ["ố"]={ "ô","́" },
  ["Ồ"]={ "Ô","̀" },
  ["ồ"]={ "ô","̀" },
  ["Ổ"]={ "Ô","̉" },
  ["ổ"]={ "ô","̉" },
  ["Ỗ"]={ "Ô","̃" },
  ["ỗ"]={ "ô","̃" },
  ["Ộ"]={ "Ọ","̂" },
  ["ộ"]={ "ọ","̂" },
  ["Ớ"]={ "Ơ","́" },
  ["ớ"]={ "ơ","́" },
  ["Ờ"]={ "Ơ","̀" },
  ["ờ"]={ "ơ","̀" },
  ["Ở"]={ "Ơ","̉" },
  ["ở"]={ "ơ","̉" },
  ["Ỡ"]={ "Ơ","̃" },
  ["ỡ"]={ "ơ","̃" },
  ["Ợ"]={ "Ơ","̣" },
  ["ợ"]={ "ơ","̣" },
  ["Ụ"]={ "U","̣" },
  ["ụ"]={ "u","̣" },
  ["Ủ"]={ "U","̉" },
  ["ủ"]={ "u","̉" },
  ["Ứ"]={ "Ư","́" },
  ["ứ"]={ "ư","́" },
  ["Ừ"]={ "Ư","̀" },
  ["ừ"]={ "ư","̀" },
  ["Ử"]={ "Ư","̉" },
  ["ử"]={ "ư","̉" },
  ["Ữ"]={ "Ư","̃" },
  ["ữ"]={ "ư","̃" },
  ["Ự"]={ "Ư","̣" },
  ["ự"]={ "ư","̣" },
  ["Ỳ"]={ "Y","̀" },
  ["ỳ"]={ "y","̀" },
  ["Ỵ"]={ "Y","̣" },
  ["ỵ"]={ "y","̣" },
  ["Ỷ"]={ "Y","̉" },
  ["ỷ"]={ "y","̉" },
  ["Ỹ"]={ "Y","̃" },
  ["ỹ"]={ "y","̃" },
  ["ἀ"]={ "α","̓" },
  ["ἁ"]={ "α","̔" },
  ["ἂ"]={ "ἀ","̀" },
  ["ἃ"]={ "ἁ","̀" },
  ["ἄ"]={ "ἀ","́" },
  ["ἅ"]={ "ἁ","́" },
  ["ἆ"]={ "ἀ","͂" },
  ["ἇ"]={ "ἁ","͂" },
  ["Ἀ"]={ "Α","̓" },
  ["Ἁ"]={ "Α","̔" },
  ["Ἂ"]={ "Ἀ","̀" },
  ["Ἃ"]={ "Ἁ","̀" },
  ["Ἄ"]={ "Ἀ","́" },
  ["Ἅ"]={ "Ἁ","́" },
  ["Ἆ"]={ "Ἀ","͂" },
  ["Ἇ"]={ "Ἁ","͂" },
  ["ἐ"]={ "ε","̓" },
  ["ἑ"]={ "ε","̔" },
  ["ἒ"]={ "ἐ","̀" },
  ["ἓ"]={ "ἑ","̀" },
  ["ἔ"]={ "ἐ","́" },
  ["ἕ"]={ "ἑ","́" },
  ["Ἐ"]={ "Ε","̓" },
  ["Ἑ"]={ "Ε","̔" },
  ["Ἒ"]={ "Ἐ","̀" },
  ["Ἓ"]={ "Ἑ","̀" },
  ["Ἔ"]={ "Ἐ","́" },
  ["Ἕ"]={ "Ἑ","́" },
  ["ἠ"]={ "η","̓" },
  ["ἡ"]={ "η","̔" },
  ["ἢ"]={ "ἠ","̀" },
  ["ἣ"]={ "ἡ","̀" },
  ["ἤ"]={ "ἠ","́" },
  ["ἥ"]={ "ἡ","́" },
  ["ἦ"]={ "ἠ","͂" },
  ["ἧ"]={ "ἡ","͂" },
  ["Ἠ"]={ "Η","̓" },
  ["Ἡ"]={ "Η","̔" },
  ["Ἢ"]={ "Ἠ","̀" },
  ["Ἣ"]={ "Ἡ","̀" },
  ["Ἤ"]={ "Ἠ","́" },
  ["Ἥ"]={ "Ἡ","́" },
  ["Ἦ"]={ "Ἠ","͂" },
  ["Ἧ"]={ "Ἡ","͂" },
  ["ἰ"]={ "ι","̓" },
  ["ἱ"]={ "ι","̔" },
  ["ἲ"]={ "ἰ","̀" },
  ["ἳ"]={ "ἱ","̀" },
  ["ἴ"]={ "ἰ","́" },
  ["ἵ"]={ "ἱ","́" },
  ["ἶ"]={ "ἰ","͂" },
  ["ἷ"]={ "ἱ","͂" },
  ["Ἰ"]={ "Ι","̓" },
  ["Ἱ"]={ "Ι","̔" },
  ["Ἲ"]={ "Ἰ","̀" },
  ["Ἳ"]={ "Ἱ","̀" },
  ["Ἴ"]={ "Ἰ","́" },
  ["Ἵ"]={ "Ἱ","́" },
  ["Ἶ"]={ "Ἰ","͂" },
  ["Ἷ"]={ "Ἱ","͂" },
  ["ὀ"]={ "ο","̓" },
  ["ὁ"]={ "ο","̔" },
  ["ὂ"]={ "ὀ","̀" },
  ["ὃ"]={ "ὁ","̀" },
  ["ὄ"]={ "ὀ","́" },
  ["ὅ"]={ "ὁ","́" },
  ["Ὀ"]={ "Ο","̓" },
  ["Ὁ"]={ "Ο","̔" },
  ["Ὂ"]={ "Ὀ","̀" },
  ["Ὃ"]={ "Ὁ","̀" },
  ["Ὄ"]={ "Ὀ","́" },
  ["Ὅ"]={ "Ὁ","́" },
  ["ὐ"]={ "υ","̓" },
  ["ὑ"]={ "υ","̔" },
  ["ὒ"]={ "ὐ","̀" },
  ["ὓ"]={ "ὑ","̀" },
  ["ὔ"]={ "ὐ","́" },
  ["ὕ"]={ "ὑ","́" },
  ["ὖ"]={ "ὐ","͂" },
  ["ὗ"]={ "ὑ","͂" },
  ["Ὑ"]={ "Υ","̔" },
  ["Ὓ"]={ "Ὑ","̀" },
  ["Ὕ"]={ "Ὑ","́" },
  ["Ὗ"]={ "Ὑ","͂" },
  ["ὠ"]={ "ω","̓" },
  ["ὡ"]={ "ω","̔" },
  ["ὢ"]={ "ὠ","̀" },
  ["ὣ"]={ "ὡ","̀" },
  ["ὤ"]={ "ὠ","́" },
  ["ὥ"]={ "ὡ","́" },
  ["ὦ"]={ "ὠ","͂" },
  ["ὧ"]={ "ὡ","͂" },
  ["Ὠ"]={ "Ω","̓" },
  ["Ὡ"]={ "Ω","̔" },
  ["Ὢ"]={ "Ὠ","̀" },
  ["Ὣ"]={ "Ὡ","̀" },
  ["Ὤ"]={ "Ὠ","́" },
  ["Ὥ"]={ "Ὡ","́" },
  ["Ὦ"]={ "Ὠ","͂" },
  ["Ὧ"]={ "Ὡ","͂" },
  ["ὰ"]={ "α","̀" },
  ["ὲ"]={ "ε","̀" },
  ["ὴ"]={ "η","̀" },
  ["ὶ"]={ "ι","̀" },
  ["ὸ"]={ "ο","̀" },
  ["ὺ"]={ "υ","̀" },
  ["ὼ"]={ "ω","̀" },
  ["ᾀ"]={ "ἀ","ͅ" },
  ["ᾁ"]={ "ἁ","ͅ" },
  ["ᾂ"]={ "ἂ","ͅ" },
  ["ᾃ"]={ "ἃ","ͅ" },
  ["ᾄ"]={ "ἄ","ͅ" },
  ["ᾅ"]={ "ἅ","ͅ" },
  ["ᾆ"]={ "ἆ","ͅ" },
  ["ᾇ"]={ "ἇ","ͅ" },
  ["ᾈ"]={ "Ἀ","ͅ" },
  ["ᾉ"]={ "Ἁ","ͅ" },
  ["ᾊ"]={ "Ἂ","ͅ" },
  ["ᾋ"]={ "Ἃ","ͅ" },
  ["ᾌ"]={ "Ἄ","ͅ" },
  ["ᾍ"]={ "Ἅ","ͅ" },
  ["ᾎ"]={ "Ἆ","ͅ" },
  ["ᾏ"]={ "Ἇ","ͅ" },
  ["ᾐ"]={ "ἠ","ͅ" },
  ["ᾑ"]={ "ἡ","ͅ" },
  ["ᾒ"]={ "ἢ","ͅ" },
  ["ᾓ"]={ "ἣ","ͅ" },
  ["ᾔ"]={ "ἤ","ͅ" },
  ["ᾕ"]={ "ἥ","ͅ" },
  ["ᾖ"]={ "ἦ","ͅ" },
  ["ᾗ"]={ "ἧ","ͅ" },
  ["ᾘ"]={ "Ἠ","ͅ" },
  ["ᾙ"]={ "Ἡ","ͅ" },
  ["ᾚ"]={ "Ἢ","ͅ" },
  ["ᾛ"]={ "Ἣ","ͅ" },
  ["ᾜ"]={ "Ἤ","ͅ" },
  ["ᾝ"]={ "Ἥ","ͅ" },
  ["ᾞ"]={ "Ἦ","ͅ" },
  ["ᾟ"]={ "Ἧ","ͅ" },
  ["ᾠ"]={ "ὠ","ͅ" },
  ["ᾡ"]={ "ὡ","ͅ" },
  ["ᾢ"]={ "ὢ","ͅ" },
  ["ᾣ"]={ "ὣ","ͅ" },
  ["ᾤ"]={ "ὤ","ͅ" },
  ["ᾥ"]={ "ὥ","ͅ" },
  ["ᾦ"]={ "ὦ","ͅ" },
  ["ᾧ"]={ "ὧ","ͅ" },
  ["ᾨ"]={ "Ὠ","ͅ" },
  ["ᾩ"]={ "Ὡ","ͅ" },
  ["ᾪ"]={ "Ὢ","ͅ" },
  ["ᾫ"]={ "Ὣ","ͅ" },
  ["ᾬ"]={ "Ὤ","ͅ" },
  ["ᾭ"]={ "Ὥ","ͅ" },
  ["ᾮ"]={ "Ὦ","ͅ" },
  ["ᾯ"]={ "Ὧ","ͅ" },
  ["ᾰ"]={ "α","̆" },
  ["ᾱ"]={ "α","̄" },
  ["ᾲ"]={ "ὰ","ͅ" },
  ["ᾳ"]={ "α","ͅ" },
  ["ᾴ"]={ "ά","ͅ" },
  ["ᾶ"]={ "α","͂" },
  ["ᾷ"]={ "ᾶ","ͅ" },
  ["Ᾰ"]={ "Α","̆" },
  ["Ᾱ"]={ "Α","̄" },
  ["Ὰ"]={ "Α","̀" },
  ["ᾼ"]={ "Α","ͅ" },
  ["῁"]={ "¨","͂" },
  ["ῂ"]={ "ὴ","ͅ" },
  ["ῃ"]={ "η","ͅ" },
  ["ῄ"]={ "ή","ͅ" },
  ["ῆ"]={ "η","͂" },
  ["ῇ"]={ "ῆ","ͅ" },
  ["Ὲ"]={ "Ε","̀" },
  ["Ὴ"]={ "Η","̀" },
  ["ῌ"]={ "Η","ͅ" },
  ["῍"]={ "᾿","̀" },
  ["῎"]={ "᾿","́" },
  ["῏"]={ "᾿","͂" },
  ["ῐ"]={ "ι","̆" },
  ["ῑ"]={ "ι","̄" },
  ["ῒ"]={ "ϊ","̀" },
  ["ῖ"]={ "ι","͂" },
  ["ῗ"]={ "ϊ","͂" },
  ["Ῐ"]={ "Ι","̆" },
  ["Ῑ"]={ "Ι","̄" },
  ["Ὶ"]={ "Ι","̀" },
  ["῝"]={ "῾","̀" },
  ["῞"]={ "῾","́" },
  ["῟"]={ "῾","͂" },
  ["ῠ"]={ "υ","̆" },
  ["ῡ"]={ "υ","̄" },
  ["ῢ"]={ "ϋ","̀" },
  ["ῤ"]={ "ρ","̓" },
  ["ῥ"]={ "ρ","̔" },
  ["ῦ"]={ "υ","͂" },
  ["ῧ"]={ "ϋ","͂" },
  ["Ῠ"]={ "Υ","̆" },
  ["Ῡ"]={ "Υ","̄" },
  ["Ὺ"]={ "Υ","̀" },
  ["Ῥ"]={ "Ρ","̔" },
  ["῭"]={ "¨","̀" },
  ["ῲ"]={ "ὼ","ͅ" },
  ["ῳ"]={ "ω","ͅ" },
  ["ῴ"]={ "ώ","ͅ" },
  ["ῶ"]={ "ω","͂" },
  ["ῷ"]={ "ῶ","ͅ" },
  ["Ὸ"]={ "Ο","̀" },
  ["Ὼ"]={ "Ω","̀" },
  ["ῼ"]={ "Ω","ͅ" },
  ["↚"]={ "←","̸" },
  ["↛"]={ "→","̸" },
  ["↮"]={ "↔","̸" },
  ["⇍"]={ "⇐","̸" },
  ["⇎"]={ "⇔","̸" },
  ["⇏"]={ "⇒","̸" },
  ["∄"]={ "∃","̸" },
  ["∉"]={ "∈","̸" },
  ["∌"]={ "∋","̸" },
  ["∤"]={ "∣","̸" },
  ["∦"]={ "∥","̸" },
  ["≁"]={ "∼","̸" },
  ["≄"]={ "≃","̸" },
  ["≇"]={ "≅","̸" },
  ["≉"]={ "≈","̸" },
  ["≠"]={ "=","̸" },
  ["≢"]={ "≡","̸" },
  ["≭"]={ "≍","̸" },
  ["≮"]={ "<","̸" },
  ["≯"]={ ">","̸" },
  ["≰"]={ "≤","̸" },
  ["≱"]={ "≥","̸" },
  ["≴"]={ "≲","̸" },
  ["≵"]={ "≳","̸" },
  ["≸"]={ "≶","̸" },
  ["≹"]={ "≷","̸" },
  ["⊀"]={ "≺","̸" },
  ["⊁"]={ "≻","̸" },
  ["⊄"]={ "⊂","̸" },
  ["⊅"]={ "⊃","̸" },
  ["⊈"]={ "⊆","̸" },
  ["⊉"]={ "⊇","̸" },
  ["⊬"]={ "⊢","̸" },
  ["⊭"]={ "⊨","̸" },
  ["⊮"]={ "⊩","̸" },
  ["⊯"]={ "⊫","̸" },
  ["⋠"]={ "≼","̸" },
  ["⋡"]={ "≽","̸" },
  ["⋢"]={ "⊑","̸" },
  ["⋣"]={ "⊒","̸" },
  ["⋪"]={ "⊲","̸" },
  ["⋫"]={ "⊳","̸" },
  ["⋬"]={ "⊴","̸" },
  ["⋭"]={ "⊵","̸" },
  ["⫝̸"]={ "⫝","̸" },
  ["が"]={ "か","゙" },
  ["ぎ"]={ "き","゙" },
  ["ぐ"]={ "く","゙" },
  ["げ"]={ "け","゙" },
  ["ご"]={ "こ","゙" },
  ["ざ"]={ "さ","゙" },
  ["じ"]={ "し","゙" },
  ["ず"]={ "す","゙" },
  ["ぜ"]={ "せ","゙" },
  ["ぞ"]={ "そ","゙" },
  ["だ"]={ "た","゙" },
  ["ぢ"]={ "ち","゙" },
  ["づ"]={ "つ","゙" },
  ["で"]={ "て","゙" },
  ["ど"]={ "と","゙" },
  ["ば"]={ "は","゙" },
  ["ぱ"]={ "は","゚" },
  ["び"]={ "ひ","゙" },
  ["ぴ"]={ "ひ","゚" },
  ["ぶ"]={ "ふ","゙" },
  ["ぷ"]={ "ふ","゚" },
  ["べ"]={ "へ","゙" },
  ["ぺ"]={ "へ","゚" },
  ["ぼ"]={ "ほ","゙" },
  ["ぽ"]={ "ほ","゚" },
  ["ゔ"]={ "う","゙" },
  ["ゞ"]={ "ゝ","゙" },
  ["ガ"]={ "カ","゙" },
  ["ギ"]={ "キ","゙" },
  ["グ"]={ "ク","゙" },
  ["ゲ"]={ "ケ","゙" },
  ["ゴ"]={ "コ","゙" },
  ["ザ"]={ "サ","゙" },
  ["ジ"]={ "シ","゙" },
  ["ズ"]={ "ス","゙" },
  ["ゼ"]={ "セ","゙" },
  ["ゾ"]={ "ソ","゙" },
  ["ダ"]={ "タ","゙" },
  ["ヂ"]={ "チ","゙" },
  ["ヅ"]={ "ツ","゙" },
  ["デ"]={ "テ","゙" },
  ["ド"]={ "ト","゙" },
  ["バ"]={ "ハ","゙" },
  ["パ"]={ "ハ","゚" },
  ["ビ"]={ "ヒ","゙" },
  ["ピ"]={ "ヒ","゚" },
  ["ブ"]={ "フ","゙" },
  ["プ"]={ "フ","゚" },
  ["ベ"]={ "ヘ","゙" },
  ["ペ"]={ "ヘ","゚" },
  ["ボ"]={ "ホ","゙" },
  ["ポ"]={ "ホ","゚" },
  ["ヴ"]={ "ウ","゙" },
  ["ヷ"]={ "ワ","゙" },
  ["ヸ"]={ "ヰ","゙" },
  ["ヹ"]={ "ヱ","゙" },
  ["ヺ"]={ "ヲ","゙" },
  ["ヾ"]={ "ヽ","゙" },
  ["יִ"]={ "י","ִ" },
  ["ײַ"]={ "ײ","ַ" },
  ["שׁ"]={ "ש","ׁ" },
  ["שׂ"]={ "ש","ׂ" },
  ["שּׁ"]={ "שּ","ׁ" },
  ["שּׂ"]={ "שּ","ׂ" },
  ["אַ"]={ "א","ַ" },
  ["אָ"]={ "א","ָ" },
  ["אּ"]={ "א","ּ" },
  ["בּ"]={ "ב","ּ" },
  ["גּ"]={ "ג","ּ" },
  ["דּ"]={ "ד","ּ" },
  ["הּ"]={ "ה","ּ" },
  ["וּ"]={ "ו","ּ" },
  ["זּ"]={ "ז","ּ" },
  ["טּ"]={ "ט","ּ" },
  ["יּ"]={ "י","ּ" },
  ["ךּ"]={ "ך","ּ" },
  ["כּ"]={ "כ","ּ" },
  ["לּ"]={ "ל","ּ" },
  ["מּ"]={ "מ","ּ" },
  ["נּ"]={ "נ","ּ" },
  ["סּ"]={ "ס","ּ" },
  ["ףּ"]={ "ף","ּ" },
  ["פּ"]={ "פ","ּ" },
  ["צּ"]={ "צ","ּ" },
  ["קּ"]={ "ק","ּ" },
  ["רּ"]={ "ר","ּ" },
  ["שּ"]={ "ש","ּ" },
  ["תּ"]={ "ת","ּ" },
  ["וֹ"]={ "ו","ֹ" },
  ["בֿ"]={ "ב","ֿ" },
  ["כֿ"]={ "כ","ֿ" },
  ["פֿ"]={ "פ","ֿ" },
  ["𑂚"]={ "𑂙","𑂺" },
  ["𑂜"]={ "𑂛","𑂺" },
  ["𑂫"]={ "𑂥","𑂺" },
  ["𑄮"]={ "𑄱","𑄧" },
  ["𑄯"]={ "𑄲","𑄧" },
  ["𑍋"]={ "𑍇","𑌾" },
  ["𑍌"]={ "𑍇","𑍗" },
  ["𑒻"]={ "𑒹","𑒺" },
  ["𑒼"]={ "𑒹","𑒰" },
  ["𑒾"]={ "𑒹","𑒽" },
  ["𑖺"]={ "𑖸","𑖯" },
  ["𑖻"]={ "𑖹","𑖯" },
  ["𝅗𝅥"]={ "𝅗","𝅥" },
  ["𝅘𝅥"]={ "𝅘","𝅥" },
  ["𝅘𝅥𝅮"]={ "𝅘𝅥","𝅮" },
  ["𝅘𝅥𝅯"]={ "𝅘𝅥","𝅯" },
  ["𝅘𝅥𝅰"]={ "𝅘𝅥","𝅰" },
  ["𝅘𝅥𝅱"]={ "𝅘𝅥","𝅱" },
  ["𝅘𝅥𝅲"]={ "𝅘𝅥","𝅲" },
  ["𝆹𝅥"]={ "𝆹","𝅥" },
  ["𝆺𝅥"]={ "𝆺","𝅥" },
  ["𝆹𝅥𝅮"]={ "𝆹𝅥","𝅮" },
  ["𝆺𝅥𝅮"]={ "𝆺𝅥","𝅮" },
  ["𝆹𝅥𝅯"]={ "𝆹𝅥","𝅯" },
  ["𝆺𝅥𝅯"]={ "𝆺𝅥","𝅯" },
  },
 },
 },
 ["name"]="collapse",
 ["prepend"]=true,
 ["type"]="ligature",
}

end --- [luaotfload, fontloader-2018-10-08.lua scope for “fonts-lig”] ---


do  --- [luaotfload, fontloader-2018-10-08.lua scope for “fonts-gbn” 10ecdf01e7c926e5128ad8a9dff4d677] ---

if not modules then modules={} end modules ['luatex-fonts-gbn']={
  version=1.001,
  comment="companion to luatex-*.tex",
  author="Hans Hagen, PRAGMA-ADE, Hasselt NL",
  copyright="PRAGMA ADE / ConTeXt Development Team",
  license="see context related readme files"
}
if context then
  os.exit()
end
local next=next
local fonts=fonts
local nodes=nodes
local nuts=nodes.nuts 
local traverse_id=nuts.traverse_id
local flush_node=nuts.flush_node
local glyph_code=nodes.nodecodes.glyph
local disc_code=nodes.nodecodes.disc
local tonode=nuts.tonode
local tonut=nuts.tonut
local getfont=nuts.getfont
local getchar=nuts.getchar
local getid=nuts.getid
local getboth=nuts.getboth
local getprev=nuts.getprev
local getnext=nuts.getnext
local getdisc=nuts.getdisc
local setchar=nuts.setchar
local setlink=nuts.setlink
local setprev=nuts.setprev
local n_ligaturing=node.ligaturing
local n_kerning=node.kerning
local d_ligaturing=nuts.ligaturing
local d_kerning=nuts.kerning
local basemodepass=true
local function l_warning() logs.report("fonts","don't call 'node.ligaturing' directly") l_warning=nil end
local function k_warning() logs.report("fonts","don't call 'node.kerning' directly")  k_warning=nil end
function node.ligaturing(...)
  if basemodepass and l_warning then
    l_warning()
  end
  return n_ligaturing(...)
end
function node.kerning(...)
  if basemodepass and k_warning then
    k_warning()
  end
  return n_kerning(...)
end
function nuts.ligaturing(...)
  if basemodepass and l_warning then
    l_warning()
  end
  return d_ligaturing(...)
end
function nuts.kerning(...)
  if basemodepass and k_warning then
    k_warning()
  end
  return d_kerning(...)
end
function nodes.handlers.setbasemodepass(v)
  basemodepass=v
end
local function nodepass(head,groupcode,size,packtype,direction)
  local fontdata=fonts.hashes.identifiers
  if fontdata then
    local usedfonts={}
    local basefonts={}
    local prevfont=nil
    local basefont=nil
    local variants=nil
    local redundant=nil
    local nofused=0
    for n in traverse_id(glyph_code,head) do
      local font=getfont(n)
      if font~=prevfont then
        if basefont then
          basefont[2]=getprev(n)
        end
        prevfont=font
        local used=usedfonts[font]
        if not used then
          local tfmdata=fontdata[font] 
          if tfmdata then
            local shared=tfmdata.shared 
            if shared then
              local processors=shared.processes
              if processors and #processors>0 then
                usedfonts[font]=processors
                nofused=nofused+1
              elseif basemodepass then
                basefont={ n,nil }
                basefonts[#basefonts+1]=basefont
              end
            end
            local resources=tfmdata.resources
            variants=resources and resources.variants
            variants=variants and next(variants) and variants or false
          end
        else
          local tfmdata=fontdata[prevfont]
          if tfmdata then
            local resources=tfmdata.resources
            variants=resources and resources.variants
            variants=variants and next(variants) and variants or false
          end
        end
      end
      if variants then
        local char=getchar(n)
        if (char>=0xFE00 and char<=0xFE0F) or (char>=0xE0100 and char<=0xE01EF) then
          local hash=variants[char]
          if hash then
            local p=getprev(n)
            if p and getid(p)==glyph_code then
              local variant=hash[getchar(p)]
              if variant then
                setchar(p,variant)
              end
            end
          end
          if not redundant then
            redundant={ n }
          else
            redundant[#redundant+1]=n
          end
        end
      end
    end
    local nofbasefonts=#basefonts
    if redundant then
      for i=1,#redundant do
        local r=redundant[i]
        local p,n=getboth(r)
        if r==head then
          head=n
          setprev(n)
        else
          setlink(p,n)
        end
        if nofbasefonts>0 then
          for i=1,nofbasefonts do
            local bi=basefonts[i]
            if r==bi[1] then
              bi[1]=n
            end
            if r==bi[2] then
              bi[2]=n
            end
          end
        end
        flush_node(r)
      end
    end
    for d in traverse_id(disc_code,head) do
      local _,_,r=getdisc(d)
      if r then
        for n in traverse_id(glyph_code,r) do
          local font=getfont(n)
          if font~=prevfont then
            prevfont=font
            local used=usedfonts[font]
            if not used then
              local tfmdata=fontdata[font] 
              if tfmdata then
                local shared=tfmdata.shared 
                if shared then
                  local processors=shared.processes
                  if processors and #processors>0 then
                    usedfonts[font]=processors
                    nofused=nofused+1
                  end
                end
              end
            end
          end
        end
      end
    end
    if next(usedfonts) then
      for font,processors in next,usedfonts do
        for i=1,#processors do
          head=processors[i](head,font,0,direction,nofused) or head
        end
      end
    end
    if basemodepass and nofbasefonts>0 then
      for i=1,nofbasefonts do
        local range=basefonts[i]
        local start=range[1]
        local stop=range[2]
        if start then
          local front=head==start
          local prev,next
          if stop then
            next=getnext(stop)
            start,stop=d_ligaturing(start,stop)
            start,stop=d_kerning(start,stop)
          else
            prev=getprev(start)
            start=d_ligaturing(start)
            start=d_kerning(start)
          end
          if prev then
            setlink(prev,start)
          end
          if next then
            setlink(stop,next)
          end
          if front and head~=start then
            head=start
          end
        end
      end
    end
  end
  return head
end
local function basepass(head)
  if basemodepass then
    head=d_ligaturing(head)
    head=d_kerning(head)
  end
  return head
end
local protectpass=node.direct.protect_glyphs
local injectpass=nodes.injections.handler
function nodes.handlers.nodepass(head,...)
  if head then
    return tonode(nodepass(tonut(head),...))
  end
end
function nodes.handlers.basepass(head)
  if head then
    return tonode(basepass(tonut(head)))
  end
end
function nodes.handlers.injectpass(head)
  if head then
    return tonode(injectpass(tonut(head)))
  end
end
function nodes.handlers.protectpass(head)
  if head then
    protectpass(tonut(head))
    return head
  end
end
function nodes.simple_font_handler(head,groupcode,size,packtype,direction)
  if head then
    head=tonut(head)
    head=nodepass(head,groupcode,size,packtype,direction)
    head=injectpass(head)
    if not basemodepass then
      head=basepass(head)
    end
    protectpass(head)
    head=tonode(head)
  end
  return head
end

end --- [luaotfload, fontloader-2018-10-08.lua scope for “fonts-gbn”] ---


--- vim:ft=lua:sw=2:ts=8:et:tw=79