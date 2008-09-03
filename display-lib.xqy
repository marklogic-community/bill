xquery version "0.9-ml"
(:
 : Demo display library to dynamically transform the XML to xhtml
 :
 : Authors:
 :   Danny <danny@marklogic.com>
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
module "http://marklogic.com/bill/display"

define function passthru(
  $x as node())
as node()*
{
  for $z in $x/node() return dispatch($z)
}

define function dispatch(
  $x as node())
as node()*
{
  if (fn:empty($x)) then () else
  typeswitch ($x)
  case text() return txt($x)

  case element(TITLE) return title($x)
  case element(P) return p($x)
  case element(PERSONAE) return unorderedList($x)
  case element(PERSONA) return listItem($x)
  case element(PGROUP) return para($x)
  case element(GRPDESCR) return groupDesc($x)
  case element(SCNDESCR) return pItalic($x)
  case element(PLAYSUBT) return subtitle($x)
  case element(STAGEDIR) return pItalic($x)
  case element(SPEECH) return speech($x)
  case element(SPEAKER) return pBold($x)
  case element(LINE) return p($x)

  case processing-instruction() return ()

  default return passthru($x)
}


define function txt(
  $x as node()?)
as node()*
{
  if (fn:empty($x) 
        (:or string-length(normalize-space($x)) = 0:)
     ) 
  then () 
  else ( if (fn:starts-with(text {$x}, "
") )
         (:  remove the first line break in a text node  :)
         then (text{ fn:replace(text {$x}, "^[^\n*]\n", "$1" ) } )
         else (text {$x}) )
 
}


define function title(
  $x as element())
as element()
{
  if ($x/parent::PLAY) then
    <span>
       <h1>{ passthru($x) }</h1>
       <p align="right">by William Shakespeare</p>
    </span>
  else if ($x/parent::PERSONAE ) then (
    let $fname := xdmp:get-request-field("fname", fn:string(fn:base-uri($x)))
    return
    <span>
       <ul>
          <li><a href="{fn:concat('displayScene.xqy?fname=', 
               $fname, '&#38;act=1&#38;', 
               if ( fn:exists(fn:doc($fname)/PLAY/ACT[1]/PROLOGUE ) )
                       then ( 'prologue=true' )
                       else ( 'scene=1' ))}">ACT I</a></li>
          <li><a href="{fn:concat('displayScene.xqy?fname=', 
                       xdmp:get-request-field("fname", 
                                 fn:string(xdmp:node-uri($x))), 
                       '&#38;act=2&#38;scene=1')}">ACT II</a></li>
          <li><a href="{fn:concat('displayScene.xqy?fname=', 
                       xdmp:get-request-field("fname", 
                                 fn:string(xdmp:node-uri($x))), 
                       '&#38;act=3&#38;scene=1')}">ACT III</a></li>
          <li><a href="{fn:concat('displayScene.xqy?fname=', 
                       xdmp:get-request-field("fname", 
                                 fn:string(xdmp:node-uri($x))), 
                       '&#38;act=4&#38;scene=1')}">ACT IV</a></li>
          <li><a href="{fn:concat('displayScene.xqy?fname=', 
                       xdmp:get-request-field("fname", 
                                 fn:string(xdmp:node-uri($x))), 
                       '&#38;act=5&#38;scene=1')}">ACT V</a></li>
       </ul>
       <h3><a id="PERSONAE" />{ passthru($x) }</h3>
    </span> )
  else if ($x/parent::ACT) then
    <h2><a id="{fn:string-join(fn:tokenize(fn:normalize-space(
             fn:string-join($x/text(), "")), "\s+" ), "")}"/>{ passthru($x) }</h2>
  else if ($x/parent::SCENE) then
    <h3><a id="{xdmp:base64-encode(xdmp:describe($x))}"/>{ passthru($x) }</h3>
  else if ($x/parent::PROLOGUE) then
    <h3><a id="{xdmp:base64-encode(xdmp:describe($x))
              (: fn:string-join(fn:tokenize(fn:normalize-space(
          fn:string-join($x/text(), "")), "\s+" ), "") :)}"/>{ passthru($x) }</h3>
  else if ($x/parent::EPILOGUE) then
    <h3><a id="{xdmp:base64-encode(xdmp:describe($x))}"/>{ passthru($x) }</h3>
  else
    <h1>{ passthru($x) }</h1>
}

define function p(
  $x as element())
as element()
{
  <div>{$x/text(),  for $line at $idx in $x/(ancestor::SCENE |
                                             ancestor::PROLOGUE |
                                             ancestor::EPILOGUE)[1]
                                            //LINE
                    where $line is $x
                    return 
                       (:  if ( math:modf($idx div 5)[1] eq 0 ) :)
                           if ( ($idx mod 5) eq 0 ) 
                           then ( fn:concat("&#160;&#160;&#160;&#160;&#160;",
                                            xs:string($idx) ) )
                           else (""), <br/>}</div>
}

define function pItalic(
  $x as element())
as element()
{
  <p><i>{$x/text()}</i></p>
}

define function pBold(
  $x as element())
as element()
{
  <p><b>{$x/text()}</b></p>
}

define function groupDesc(
  $x as element())
as element()
{
  <i>&#160;&#160;&#160;{$x/text()}</i>
}

define function subtitle(
  $x as element())
as element()
{
  <p align="center"><b>{$x/text()}</b></p>
}

define function para(
  $x as element())
as element()
{
  <p id="{xdmp:base64-encode(xdmp:describe($x))}">{ passthru($x) }</p>
}

define function speech(
  $x as element())
as element()
{
  <p id="{xdmp:base64-encode(xdmp:describe($x))}">{ passthru($x) }</p>
}

define function unorderedList(
  $x as element())
as element()
{
  <ul>{passthru($x)}</ul>
}

define function listItem(
  $x as element())
as element()
{
  <li>{$x/text()}</li>
}



