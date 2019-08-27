
packageversion= "7.002-dev"
packagedate   = "2019-08-11"
packagedesc   = "ignorable"
checkformat   = "latex" -- for travis until something better comes up

module   = "luaotfload"
ctanpkg  = "luaotfload"
tdsroot  = "luatex"

-- load my personal data for the ctan upload
local ok, mydata = pcall(require, "ulrikefischerdata.lua")
if not ok then
  mydata= {email="XXX",github="XXX",name="XXX"}
end

-- test the email
print(mydata.email)

--------- setup things for a dev-version
-- See stackoverflow.com/a/12142066/212001 / build-config from latex2e
local master_branch do
  local branch = os.getenv'TRAVIS_BRANCH'
  if not branch then
    local f = io.popen'git rev-parse --abbrev-ref HEAD'
    branch = f:read'*a':sub(1,-2)
    assert(f:close())
  end
  master_branch = string.match(branch, '^master')
  if not master_branch then
    tdsroot = "latex-dev"
    print("creating/installing dev-version in " .. tdsroot)
    ctanpkg = ctanpkg .. "-dev"
    ctanzip = ctanpkg
    checkformat="latex-dev"
  end
end
---------------------------------

uploadconfig = {
     pkg     = ctanpkg,
  version    = "v"..packageversion.." "..packagedate,
-- author    = "Ulrike Fischer;Philipp Gesang;Marcel Krüger;The LaTeX Team;Élie Roux;Manuel Pégourié-Gonnard (inactive);Khaled Hosny (inactive);Will Robertson (inactive)",
-- author list is too long
  author     = "... as before ...",
  license    = "gpl2",
  summary    = "OpenType ‘loader’ for Plain TeX and LaTeX",
  ctanPath   = "/macros/luatex/generic/"..ctanpkg,
  repository = "https://github.com/latex3/luaotfload",
  bugtracker = "https://github.com/latex3/luaotfload/issues",
  support    = "https://github.com/latex3/luaotfload/issues",
  uploader   = mydata.name,
  email      = mydata.email,
  update     = true ,
  topic      = {"font-use","luatex"},
  note       = [[Uploaded automatically by l3build... description is unchanged despite the missing linebreaks, authors are unchanged]],
  description=[[The package adopts the TrueType/OpenType Font loader code provided in ConTeXt,
              and adapts it to use in Plain TeX and LaTeX. It works under LuaLaTeX only.]],
  announcement_file="ctan.ann"
}

-- we perhaps need different settings for miktex ...
local luatexstatus = status.list()
local ismiktex = string.match (luatexstatus.banner,"MiKTeX")

-- l3build check settings

stdengine    = "luatex"
checkengines = {"luatex"}

 -- local errorlevel   = os.execute("harftex --version")
 -- if not os.getenv('TRAVIS') and errorlevel==0 then
 --  checkengines = {"luatex","harftex"}
 -- end

-- temporary for test dev branch
if master_branch then
checkconfigs = {
                "build",
                "config-loader-unpackaged",
                "config-loader-reference",
                "config-latex-TU",
                "config-unicode-math",
                "config-plain",
                "config-fontspec"
               }
else
checkconfigs={}
end
checkruns = 3
checksuppfiles = {"texmf.cnf"}

-- exclude some text temporarly or in certain systems ...
if os.env["CONTEXTPATH"] then
  -- local system
  if ismiktex then
   excludetests = {"arabkernsfs","fontload-ttc-fontindex"}
  else
   -- excludetests = {"luatex-ja"}
  end
else
  -- travis or somewhere else ...
  excludetests = {"luatex-ja","aux-resolve-fontname"}
end

---------------------------------------------
-- l3build settings for CTAN/install target
---------------------------------------------

packtdszip=true
sourcefiledir = "./src"
docfiledir    = "./doc"
-- install directory is the texmf-tree
options = options or {}
options["texmfhome"] = "./texmf"

-------------------
-- documentation
-------------------

typesetexe = "lualatex --fmt="..checkformat

-- main docu
typesetfiles      = {"luaotfload-latex.tex"}
typesetcycles = 3 -- for the tests

ctanreadme= "CTANREADME.md"

docfiles =
 {
  "luaotfload.conf.example",
  "luaotfload-main.tex",
  "luaotfload.conf.rst",
  "luaotfload-tool.rst"
  }

textfiles =
 {
  "COPYING",
  "NEWS",
   docfiledir .. "/CTANREADME.md",
  }

typesetdemofiles  =
  {
   "filegraph.tex",
   "luaotfload-conf.tex",
   "luaotfload-tool.tex"
  }
-- typesetsuppfiles  = {"texmf.cnf"} --later

---------------------
-- installation
---------------------


if options["target"] == "check" or options["target"] == "save" then
  print("check/save")
  installfiles ={}
  sourcefiles  ={}
  unpackfiles  ={}
else
  sourcefiles  =
  {
    "luaotfload.sty",
    "**/luaotfload-*.lua",
    "**/fontloader-*.lua",
    "**/fontloader-*.tex",
    "luaotfload-blacklist.cnf",
    "./doc/filegraph.tex",
    "./doc/luaotfload-main.tex",
   }
   installfiles = {
     "luaotfload.sty",
     "luaotfload-blacklist.cnf",
     "**/luaotfload-*.lua",
     "**/fontloader-*.lua",
     "**/fontloader-*.tex",
                }
end
tdslocations=
 {
  "source/luatex/luaotfload/fontloader-reference-load-order.lua",
  "source/luatex/luaotfload/fontloader-reference-load-order.tex",
 }

scriptfiles   =  {"luaotfload-tool.lua"}

scriptmanfiles = {"luaotfload.conf.5","luaotfload-tool.1"}

-----------------------------
-- l3build settings for tags:
-----------------------------
tagfiles = {
            "doc/CTANREADME.md",
            "README.md",
            "src/luaotfload.sty",
            "src/luaotfload-*.lua",
            "src/auto/luaotfload-glyphlist.lua",
            "doc/luaotfload-main.tex",
            "doc/luaotfload.conf.rst",
            "doc/luaotfload-tool.rst",
            "src/fontloader/runtime/fontloader-basics-gen.lua",
            "scripts/mkstatus",
            "testfiles/aaaaa-luakern.tlg"
            }

function typeset_demo_tasks()
 local errorlevel = 0
 errorlevel = run (docfiledir,"rst2man luaotfload.conf.rst luaotfload.conf.5")
 if errorlevel ~= 0 then
        return errorlevel
 end
 errorlevel = run (docfiledir,"rst2man luaotfload-tool.rst luaotfload-tool.1")
 if errorlevel ~= 0 then
        return errorlevel
 end
 errorlevel= run (typesetdir,"rst2xetex luaotfload.conf.rst luaotfload-conf.tex")
 if errorlevel ~= 0 then
        return errorlevel
 end
 errorlevel=run (typesetdir,"rst2xetex luaotfload-tool.rst luaotfload-tool.tex")
 if errorlevel ~= 0 then
        return errorlevel
 end
 return 0
end

local function lpeggsub(pattern)
  return lpeg.Cs(lpeg.P{pattern + (1 * (lpeg.V(1) + -1))}^0)
end
local digit = lpeg.R'09'
local spaces = lpeg.P' '^1
local function lpegrep(pattern,times)
  if times == 0 then return true end
  return pattern * lpegrep(pattern, times - 1)
end
local tagdatepat = lpeg.Cg( -- Date: YYYY/MM/DD
  lpegrep(digit, 4) * lpegrep('/' * digit * digit, 2)
  * lpeg.Cc(string.gsub(packagedate, '-', '/')))
local packagedatepat = lpeg.Cg( -- Date: YYYY-MM-DD
  lpegrep(digit, 4) * lpegrep('-' * digit * digit, 2)
  * lpeg.Cc(packagedate))
local imgpackagedatepat = lpeg.Cg( -- Date: YYYY--MM--DD
  lpegrep(digit, 4) * lpegrep('--' * digit * digit, 2)
  * lpeg.Cc(string.gsub(packagedate, '-', '--')))
local xxxpackagedatepat = lpeg.Cg( -- Date: YYYYxxxMMxxxDD
  lpegrep(digit, 4) * lpegrep('xxx' * digit * digit, 2)
  * lpeg.Cc(string.gsub(packagedate, '-', 'xxx')))
local packageversionpat = lpeg.Cg( -- Version: M.mmmm-dev
  digit * '.' * digit^1 * lpeg.P'-dev'^-1
  * lpeg.Cc(packageversion))
local sty_pattern = lpeggsub(tagdatepat * ' v' * packageversionpat)
local tex_pattern = lpeggsub(packagedatepat * ' v' * packageversionpat)
local lua_pattern = lpeggsub(
      'version' * spaces * '=' * spaces
           * '"' * packageversionpat * '",' * spaces * '--TAGVERSION'
    + 'date' * spaces * '=' * spaces
           * '"' * packagedatepat * '",' * spaces * '--TAGDATE')
local readme_pattern = lpeggsub(
      (lpeg.P'Version: ' + 'version-' + 'for ') * packageversionpat
    + packagedatepat + imgpackagedatepat)
local ctanreadme_pattern = lpeggsub(
      'VERSION: ' * packageversionpat
    + 'DATE: ' * packagedatepat)
local rst_pattern = lpeggsub(
      ':Date:' * spaces * packagedatepat
    + ':Version:' * spaces * packageversionpat)
local status_pattern = lpeggsub('v' * packageversionpat * '/' * packagedatepat)
local fontloader_pattern = lpeggsub(
      packageversionpat * ' with fontloaderxxx' * xxxpackagedatepat)
function update_tag (file,content,_tagname,_tagdate)
  if string.match (file, "%.sty$" ) then
    return sty_pattern:match(content)
  elseif string.match (file,"fontloader%-basic") then
   if master_branch then
     return string.gsub (content,
                          "caches.namespace = 'generic%-dev'",
                          "caches.namespace = 'generic'")
   else
     return string.gsub (content,
                          "caches.namespace = 'generic'",
                          "caches.namespace = 'generic-dev'")
   end
  elseif string.match (file, "%.lua$") then
    return lua_pattern:match(content)
  elseif file == 'README.md$' then
    return readme_pattern:match(content)
  elseif string.match (file, "CTANREADME.md$") then
    return ctanreadme_pattern:match(content)
  elseif string.match (file, "%.tex$" ) then
    return tex_pattern:match(content)
  elseif string.match (file, "%.rst$" ) then
    return rst_pattern:match(content)
  elseif string.match (file,"mkstatus$") then
    return status_pattern:match(content)
  elseif string.match (file,"aaaaa%-luakern") then
    return fontloader_pattern:match(content)
  end
  return content
end


kpse.set_program_name ("kpsewhich")
if not release_date then
 dofile ( kpse.lookup ("l3build.lua"))
end
