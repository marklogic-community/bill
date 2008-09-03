xquery version "0.9-ml"
(:
 : displayScene.xqy  transforms the Shakespeare XML to display it one 
 :                   scene at a time
 :
 : Copyright (c)2002-2008 Mark Logic Corporation. All Rights Reserved.
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

import module namespace d="http://marklogic.com/bill/display" 
       at "display-lib.xqy"
import module namespace s="http://marklogic.com/bill/search" 
       at "search-lib.xqy"

define variable $g-highlight-color { "#cc0000" }

xdmp:set-response-content-type("text/html"),

let $fname :=   xdmp:get-request-field("fname",
                               "http://pubs/3.0doc/xml/admin/admin_inter.xml")
let $search := normalize-space(xdmp:get-request-field("query")) 
let $type := xdmp:get-request-field("query-type", "and")
let $near := normalize-space(xdmp:get-request-field("near", "")) 
let $near-type := normalize-space(xdmp:get-request-field("near-type", "and")) 
let $act := xs:integer(xdmp:get-request-field("act", "0"))
let $sceneVariable := xdmp:get-request-field("scene", "1") 
let $scene := if ( $sceneVariable eq "" )
              then ( 0 )
              else xs:integer($sceneVariable) 
return
<html>
<head>
  <title>{fn:concat(fn:doc($fname)/PLAY/TITLE/text(), ", ",
     if ( fn:not($act eq 0) )
     then (
         fn:doc($fname)/PLAY/ACT[$act]/TITLE/text()
          )
     else (""), ", ",
     if ( fn:not($scene eq 0) )
     then (
         fn:string-join((fn:tokenize(fn:doc($fname)/PLAY/ACT[$act]/SCENE[$scene]/
                  TITLE/text(), " ")[1 to 2]), " ")
          )
    else ( "" )
                   )}</title>
</head>
<body onload="window.parent.frames[0].syncTree(document.URL)">
{ 

let $dispatch := if ( xdmp:get-request-field("prologue") eq "true" )
                 then ( 
             d:dispatch( fn:doc($fname)/PLAY/ACT[$act]/PROLOGUE ) )
                 else ( if ( xdmp:get-request-field("epilogue") eq "true" )
                        then (
             d:dispatch( fn:doc($fname)/PLAY/ACT[$act]/EPILOGUE ) 
                             )
                        else ( if ( xdmp:get-request-field("drama") eq "true" )
                               then (
             d:dispatch( fn:doc($fname)/PLAY/FM ),
             d:dispatch( fn:doc($fname)/PLAY/PERSONAE )
                                    )
                               else ( if ( 
                          xdmp:get-request-field("preprologue") eq "true")
                                      then (
             d:dispatch( fn:doc($fname)/PLAY/PROLOGUE ) )
                                      else (
             d:dispatch( fn:doc($fname)/PLAY/ACT[$act]/SCENE[$scene] )))))
let $navtable :=
(
<table  width="100%">
<tr width="100%"><td width="10%">
{
(: for previous button, when it is scene 1 and an act greater than 1,
   find the last scene in the previous act.  Also, deal with the prologues.
   No need to deal with the epilogues because they only occur at the end of 
   ACT V.
:)
if ( $scene = 1 ) 
then (if ( fn:exists(fn:doc($fname)/PLAY/ACT[$act]/SCENE[$scene]/
                       preceding-sibling::PROLOGUE) )
               then ( <a href={fn:concat('displayScene.xqy?fname=', $fname,
                      '&act=', xs:string($act), 
                      '&prologue=true')}>previous</a> )
               else ( if ( $act > 1 and $scene = 1 ) 
       then ( <a href={fn:concat('displayScene.xqy?fname=', $fname,
                      '&act=', xs:string($act - 1), 
                      '&scene=', 
xs:string( fn:count(fn:doc($fname)/PLAY/ACT[$act]/SCENE[$scene]/
                    ancestor::ACT/preceding-sibling::ACT[1]//SCENE) )
                                 ) }>previous</a> ) 
        else ( if ( fn:exists(fn:doc($fname)/PLAY/ACT[$act]/SCENE[$scene]/
                       preceding-sibling::PROLOGUE) )
               then ( if ( xdmp:get-request-field("prologue") eq "true" and
                           $act > 1 )
                      then ( <a href={fn:concat('displayScene.xqy?fname=', $fname,
                      '&act=', xs:string($act - 1), '&scene=', 
xs:string( fn:count(fn:doc($fname)/PLAY/ACT[$act]/SCENE[$scene]/
                    ancestor::ACT/preceding-sibling::ACT[1]//SCENE) )
                                  ) }>previous</a>  
                            )
                      else ( )
                    )
               else ( if ( fn:exists(fn:doc($fname)/PLAY/PROLOGUE ) )
                      then ( <a href={fn:concat('displayScene.xqy?fname=', 
                      $fname, '&preprologue=true')}>previous</a> )
                      else () )
             ) ) )
else (
 if ( $scene > 1 ) 
 then ( <a href={fn:concat('displayScene.xqy?fname=', $fname,
                      '&act=', xs:string($act), 
                      '&scene=', xs:string($scene - 1))}>previous</a>) 
 else ( if ( xdmp:get-request-field("epilogue") eq "true" )
                             then ( 
          <a href={fn:concat('displayScene.xqy?fname=', $fname,
                      '&act=', xs:string($act - 1), 
                      '&scene=', 
xs:string( fn:count(fn:doc($fname)/PLAY/ACT[$act - 1]//SCENE) )
                                 ) }>previous</a> )
                             else ()
      )
)}</td>
<td>&nbsp;</td>
<td width="10%">
{
(: for next button, figure out if this is the last scene in the act :)
if ( not(xdmp:get-request-field("epilogue") eq "true") and
     not(xdmp:get-request-field("drama") eq "true") and 
     not(xdmp:get-request-field("preprologue") eq "true") and 
     fn:exists(fn:doc($fname)/PLAY/ACT[$act]/SCENE[$scene + 1] ) )
then ( <a href={fn:concat('displayScene.xqy?fname=', $fname,
                      '&act=', xs:string($act), 
                      '&scene=', xs:string($scene + 1))}>next</a> ) 
else (
  if ( $act < 5 and not($act eq 0) and 
              not(xdmp:get-request-field("prologue") eq "true")) 
  then ( <a href={fn:concat('displayScene.xqy?fname=', $fname,
                      '&act=', xs:string($act + 1), 
                      '&scene=', "1")}>next</a> ) 
  else (       (: is there an EPILOGUE after this scene? :)
          if ( not(xdmp:get-request-field("epilogue") eq "true") and 
               not($act eq 0) and
               fn:exists(fn:doc($fname)/PLAY/ACT[$act]/SCENE[$scene]/
                      following-sibling::EPILOGUE ) )
          then ( <a href={fn:concat('displayScene.xqy?fname=', $fname,
                      '&act=', xs:string($act), 
                      '&epilogue=true')}>next</a> )
          else ( if ( xdmp:get-request-field("drama") eq "true")
                 then ( if ( fn:exists(fn:doc($fname)/PLAY/ACT[$act + 1]/
                                       PROLOGUE ) )
                        then ( <a href={fn:concat('displayScene.xqy?fname=', $fname,
                      '&act=', xs:string($act + 1), '&prologue=true')}>next</a> )
                        else ( <a href={fn:concat('displayScene.xqy?fname=', $fname,
                      '&act=', xs:string($act + 1), 
                      '&scene=', xs:string($scene + 1))}>next</a> )
                      )
                 else ( if ( xdmp:get-request-field("prologue") eq "true" )
                        then ( <a href={fn:concat('displayScene.xqy?fname=', 
                               $fname, '&act=', xs:string($act), 
                               '&scene=', "1")}>next</a> )
                        else ( if ( 
                          xdmp:get-request-field("preprologue") eq "true" )
                               then ( 
                              <a href={fn:concat('displayScene.xqy?fname=', 
                               $fname, '&act=1', 
                               '&scene=', "1")}>next</a> )
                                else ( ) )
                      )
               )
       ) 
     )
}</td>
<td width="80%" align="right">{
if ( not(xdmp:get-request-field("drama") eq "true") )
then (
<a href={fn:concat('displayScene.xqy?fname=', 
                    $fname, '&drama=true')}>Dramatis Personae</a>)
else ( "&nbsp;")
}</td></tr>
</table>)
return ($navtable,
d:dispatch(fn:doc($fname)/PLAY/TITLE),
if ( not($act eq 0) ) 
then ( d:dispatch(fn:doc($fname)/PLAY/ACT[$act]/TITLE) ) else (),
if ( $search )
then ( cts:highlight(<node>{$dispatch}</node>, 
                  s:get-query-for-display($search, $type, $near, $near-type),
<span class="cts:highlight" style="color:{$g-highlight-color};
                font-weight:bold">{$cts:text}</span>  ) )
else ( $dispatch ), 
$navtable
)
 }
</body>
</html>

