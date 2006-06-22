(:
 : contents.xqy  renders the table of contents
 :
 : Copyright (c)2002-2006 Mark Logic Corporation. All Rights Reserved.
 :
 : Licensed under the Apache License, Version 2.0 (the "License");
 : you may not use this file except in compliance with the License.
 : You may obtain a copy of the License at
 :
 : http://www.apache.org/licenses/LICENSE-2.0
 :
 : Unless required by applicable law or agreed to in writing, software
 : distributed under the License is distributed on an "AS IS" BASIS,
 : WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 : See the License for the specific language governing permissions and
 : limitations under the License.
 :
 : The use of the Apache License does not indicate that this project is
 : affiliated with the Apache Software Foundation.
 :
 :)

declare namespace no=""
declare namespace xh="http://www.w3.org/1999/xhtml"

declare xmlspace=preserve

define function passthru(
  $x as element())
as element()*
{
  for $z in $x/node() 
  return dispatch($z)
}

define function dispatch(
  $x as node())
as element()*
{
  if (empty($x)) then () else
  typeswitch ($x)
  case text() return ()
  case element(PLAY) return play($x)
  case element(COMEDIES) return comedies($x)
  case element(TRAGEDIES) return tragedies($x)
  case element(HISTORIES) return histories($x)
  case element(TITLE) return title($x)
  case element(ACTS) return collapsedNode($x)
  case element(ACT) return act($x)
  case element(ACTTITLE) return acttitle($x)
  case element(SCENES) return collapsedNode($x)
  case element(SCENETITLE) return sceneOnly($x) 
  case element(uri) return ()

  case processing-instruction() return ()
  default return passthru($x)
}


define function play(
  $x as element() )
as element()
{
<div  class="treeNode" id="books">
  <img src="treenodeplus.gif" class="treeLinkImage" 
       onclick="expandCollapse(this.parentNode)"/>
{passthru($x)}
</div>
}

define function comedies(
  $x as element() )
as element()
{
<div class="treeNode" id="books">
  <img src="treenodeplus.gif" class="treeLinkImage" 
       onclick="expandCollapse(this.parentNode)"/>
   <span class="treeLinkImage" onclick="expandCollapse(this.parentNode)">
   Comedies</span> 
   <div class="treeSubnodesHidden">
    {passthru($x)}
   </div>
</div>
}

define function tragedies(
  $x as element() )
as element()
{
<div class="treeNode" id="books">
  <img src="treenodeplus.gif" class="treeLinkImage" 
       onclick="expandCollapse(this.parentNode)"/>
   <span class="treeLinkImage" onclick="expandCollapse(this.parentNode)">
   Tragedies</span> 
   <div class="treeSubnodesHidden">
    {passthru($x)}
   </div>
</div>
}

define function histories(
  $x as element() )
as element()
{
<div class="treeNode" id="books">
  <img src="treenodeplus.gif" class="treeLinkImage" 
       onclick="expandCollapse(this.parentNode)"/>
   <span class="treeLinkImage" onclick="expandCollapse(this.parentNode)">
   Histories</span> 
   <div class="treeSubnodesHidden">
    {passthru($x)}
   </div>
</div>
}



define function title(
  $x as element() )
as element()
{

     <a href={concat("displayScene.xqy?fname=", $x/../no:uri/text(),
              "&drama=true" )}
     target="mainFrame" class="treeUnselected" onclick="clickAnchor(this)">{
       normalize-space(string-join($x/text(), ""))}</a>
}

define function collapsedNode(
  $x as element() )
as element()
{
  <div class="treeSubnodesHidden">
    {passthru($x)}
   </div>
}

define function act(
  $x as element() )
as element()
{
<div  class="treeNode" id="books">
  <img src="treenodeplus.gif" class="treeLinkImage" 
       onclick="expandCollapse(this.parentNode)"/>
{passthru($x)}
</div>
}

define function acttitle(
  $x as element() )
as element()
{
     <a href={concat("displayScene.xqy?fname=", $x/../../../no:uri/text(), 
                if ( $x/preceding-sibling::no:number/text() eq "0" )
                then ( "&preprologue=true")
                else (fn:concat("&act=", $x/preceding-sibling::no:number/text()
                      ) ) ) }
     target="mainFrame" class="treeUnselected" onclick="clickAnchor(this)">{
       normalize-space(string-join($x/text(), ""))}</a>
}

(: use this version to get to the act anchor in the whole-play display :)
define function acttitlePlay(
  $x as element() )
as element()
{
     <a href={concat("display.xqy?fname=", $x/../../../no:uri/text(), "#",
                     fn:string-join(fn:tokenize(fn:normalize-space(
                 fn:string-join($x/text(), "")), "\s+" ), ""))}
     target="mainFrame" class="treeUnselected" onclick="clickAnchor(this)">{
       normalize-space(string-join($x/text(), ""))}</a>
}

(: displays the scene on the page that shows the entire play :)
define function scene(
  $x as element() )
as element()
{
  <div class="treeNode"> <img src="treenodedot.gif" class="treeNoLinkImage" />
     <a href={concat("display.xqy?fname=", $x/../../../../../no:uri/text(), 
                     "#", $x/../no:path/text())}
     target="mainFrame" class="treeUnselected" onclick="clickAnchor(this)">{
       normalize-space(string-join($x/text(), ""))}</a>
  </div>
}

(: displays the scene on the page that goes 1 scene at a time :)
define function sceneOnly(
  $x as element() )
as element()
{
  <div class="treeNode"> <img src="treenodedot.gif" class="treeNoLinkImage" />
     <a href={concat("displayScene.xqy?fname=", $x/../../../../../no:uri/text(), 
                     "&act=", $x/ancestor::no:ACT/no:number/text(), 
                    if ( $x/ancestor::no:SCENE/no:number/text() eq "0" )
                    then ( "&prologue=true" )
                    else ( if ( $x/ancestor::no:SCENE/no:number/text() eq "99" ) 
                           then ( "&epilogue=true" )
                           else ( fn:concat("&scene=", 
                                  $x/ancestor::no:SCENE/no:number/text() ) 
                                ) 
                         ) )}
     target="mainFrame" class="treeUnselected" onclick="clickAnchor(this)">{
       normalize-space(string-join($x/text(), ""))}</a>
  </div>
}

let $tocnode :=
<PLAYS>
 <COMEDIES>
{
 for $x in  xdmp:directory("/shakespeare/plays/")
 where $x/property::no:playtype/text() eq "COMEDY"
 order by doc(base-uri($x))/no:PLAY/no:TITLE/text()
 return
(
<PLAY>
 <uri>{base-uri($x)}</uri>
 {$x/PLAY/TITLE}
 <ACTS>
  {for $y at $actidx in ( $x/PLAY/PROLOGUE | $x/PLAY/ACT )
   return
  <ACT>
    <number>{if ( $x/PLAY/PROLOGUE )
             then ( $actidx - 1 )
             else ( $actidx ) }</number>
    <path>{xdmp:base64-encode(xdmp:describe($y))}</path>
    <ACTTITLE>{fn:normalize-space(fn:string-join($y/TITLE/text(), ""))}
    </ACTTITLE> 
     <SCENES>
      {for $z at $sceneidx in ( $y/PROLOGUE | $y/SCENE | $y/EPILOGUE )
       return 
      <SCENE>
       <number>{if ( $y/PROLOGUE )
                then ( if ( $z is $y/EPILOGUE ) 
                       then ( 99 ) 
                       else ( $sceneidx - 1 ) )
                else ( if ( $z is $y/EPILOGUE ) 
                       then ( 99 ) 
                       else ( $sceneidx ) )}</number>
       <path>{xdmp:base64-encode(xdmp:describe(for $node in $z/TITLE 
                                      return $node))}</path>
       <SCENETITLE>{fn:normalize-space( fn:string-join($z/TITLE/text(), ""))}
       </SCENETITLE>
      </SCENE>}
     </SCENES>
  </ACT>}
 </ACTS>
</PLAY> 
)
}
  </COMEDIES>
  <TRAGEDIES>
{
 for $x in  xdmp:directory("/shakespeare/plays/")
 where $x/property::no:playtype/text() eq "TRAGEDY"
 order by doc(base-uri($x))/no:PLAY/no:TITLE/text()
 return
(
<PLAY>
 <uri>{base-uri($x)}</uri>
 {$x/PLAY/TITLE}
 <ACTS>
  {for $y at $actidx in ( $x/PLAY/PROLOGUE | $x/PLAY/ACT )
   return
  <ACT>
    <number>{if ( $x/PLAY/PROLOGUE )
             then ( $actidx - 1 )
             else ( $actidx ) }</number>
    <path>{xdmp:base64-encode(xdmp:describe($y))}</path>
    <ACTTITLE>{fn:normalize-space(fn:string-join($y/TITLE/text(), ""))}
    </ACTTITLE> 
     <SCENES>
      {for $z at $sceneidx in ( $y/PROLOGUE | $y/SCENE | $y/EPILOGUE )
       return 
      <SCENE>
       <number>{if ( $y/PROLOGUE )
                then ( if ( $z is $y/EPILOGUE ) 
                       then ( 99 ) 
                       else ( $sceneidx - 1 ) )
                else ( if ( $z is $y/EPILOGUE ) 
                       then ( 99 ) 
                       else ( $sceneidx ) )}</number>
       <path>{xdmp:base64-encode(xdmp:describe(for $node in $z/TITLE 
                                      return $node))}</path>
       <SCENETITLE>{fn:normalize-space( fn:string-join($z/TITLE/text(), ""))}
       </SCENETITLE>
      </SCENE>}
     </SCENES>
  </ACT>}
 </ACTS>
</PLAY> 
)
}
  </TRAGEDIES>
  <HISTORIES>
{
 for $x in  xdmp:directory("/shakespeare/plays/")
 where $x/property::no:playtype/text() eq "HISTORY"
 order by doc(base-uri($x))/no:PLAY/no:TITLE/text()
 return
(
<PLAY>
 <uri>{base-uri($x)}</uri>
 {$x/PLAY/TITLE}
 <ACTS>
  {for $y at $actidx in ( $x/PLAY/PROLOGUE | $x/PLAY/ACT )
   return
  <ACT>
    <number>{if ( $x/PLAY/PROLOGUE )
             then ( $actidx - 1 )
             else ( $actidx ) }</number>
    <path>{xdmp:base64-encode(xdmp:describe($y))}</path>
    <ACTTITLE>{fn:normalize-space(fn:string-join($y/TITLE/text(), ""))}
    </ACTTITLE> 
     <SCENES>
      {for $z at $sceneidx in ( $y/PROLOGUE | $y/SCENE | $y/EPILOGUE )
       return 
      <SCENE>
       <number>{if ( $y/PROLOGUE )
                then ( if ( $z is $y/EPILOGUE ) 
                       then ( 99 ) 
                       else ( $sceneidx - 1 ) )
                else ( if ( $z is $y/EPILOGUE ) 
                       then ( 99 ) 
                       else ( $sceneidx ) )}</number>
       <path>{xdmp:base64-encode(xdmp:describe(for $node in $z/TITLE 
                                      return $node))}</path>
       <SCENETITLE>{fn:normalize-space( fn:string-join($z/TITLE/text(), ""))}
       </SCENETITLE>
      </SCENE>}
     </SCENES>
  </ACT>}
 </ACTS>
</PLAY> 
)
}
  </HISTORIES>
</PLAYS>
return
(
xdmp:set-response-content-type("text/html; charset=utf-8"),

<html>
  <head>
    <title>The Plays of William Shakespeare</title>
    <link rel="stylesheet" type="text/css" href="tree.css" />
    <script src="tree.js" language="javascript" type="text/javascript">
    </script>
  </head>
  <body id="docBody" style="background-color: White; color: Black; 
                            margin: 0px 0px 0px 0px;" 
        onload="resizeTree()" onresize="resizeTree()" 
        onselectstart="return false;">
<table cellpadding="5" cellspacing="0" border="0" width="100%">
   <tr>
	<td align="center" colspan="2">
        <p><a href="start.xqy" target="mainFrame">
        <img align="center" src="smallshakes.jpg" /></a></p>
	</td>
   </tr>
   <tr><td align="left"><font size="-2">Powered by MarkLogic Server</font></td>
   <td align="right">
   <font size="-2"><a href="README.txt" target="_blank" type="text/plain">
   README.txt</a>
   </font></td>
   </tr>
   <tr>
	<td colspan="2"><hr /></td>
	
   </tr>
   <tr>
	<td colspan="2">
      <form action="search.xqy" target="mainFrame" method="get" 
      enctype="application/x-www-form-urlencoded" name="search"  id="searchForm">
	<input type="hidden" name="start" id="start" value="1"/>
	 <input type="text" name="query" size="25" maxlength="256" />
         <input type="submit" name="button" value="search"/>
       </form>
	</td>
    </tr>
    <tr align="right"><td colspan="2"><font size="-2"><a href="searchAdv.xqy" target="mainFrame">Advanced Search</a></font>
        </td>
    </tr>
</table>
{(:
  <div style="font-family: verdana; font-size: 8pt; cursor: pointer; 
   margin: 6 4 8 2; text-align: right" 
   onmouseover="this.style.textDecoration='underline'" 
   onmouseout="this.style.textDecoration='none'" 
   onclick="syncTree(window.parent.frames[1].document.URL)">sync toc</div>
:)}
<div id="tree" style="top: 35px; left: 0px;" class="treeDiv">
  <div id="treeRoot" onselectstart="return false" ondragstart="return false">
 {dispatch($tocnode)} 
  </div>
</div>
  </body>
</html>

)

