xquery version "0.9-ml"
(:
 : Demo search library
 :
 : Authors:
 :   Michael Blakeley <michael.blakeley@marklogic.com>
 :   modifications by danny
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

module "http://marklogic.com/bill/search"

(: GLOBAL CONSTANTS :)
define variable $g-chars-per-hit { 256 }
define variable $g-tab-width { 200 }

define variable $g-page-size { 10 }
define variable $g-color { "#002c72" }
define variable $g-highlight-color { "#cc0000" }
define variable $g-grey  { "#b5b5b5" }

define variable $g-debug as xs:boolean { fn:false() }

define variable $g-nbsp as xs:string { fn:codepoints-to-string(160) }

define variable $g-elements as xs:string+ { "SCENE", "FM", "PERSONAE",
                                            "EPILOGUE", "PROLOGUE" }

(: number of words before and after search results :)
define variable $g-num as xs:integer { 10 }

define variable $g-near 
{
  xdmp:get-request-field("near", "")
}

define variable $g-near-type 
{
  xdmp:get-request-field("near-type", "and")
}

(: figure out default value for query-type if not specified :)
define variable $g-default-query-type as xs:string {
   (: Make it an exact search if the search term has a ":" or "-" in it 
      but no " " :)
   if ( ( fn:contains(xdmp:get-request-field("query"), ":") or 
          fn:contains(xdmp:get-request-field("query"), "-") ) 
         and fn:not(fn:contains(xdmp:get-request-field("query"), " ")) )
   then ( "exact" )
   else ( "and" )
}

define function debug($s as item()*) {
  if (fn:not($g-debug)) then () else
    xdmp:log(fn:string-join(("DEBUG:", for $i in $s return xdmp:quote($i)), " "))
}

define function get-tab-width() as xs:integer { $g-tab-width }
define function get-nbsp() as xs:string { $g-nbsp }
define function get-active-color() as xs:string { $g-color }
define function get-inactive-color() as xs:string { $g-grey }
define function get-highlight-color() as xs:string { $g-highlight-color }
define function get-page-size() as xs:integer { $g-page-size }

define function do-pagination
($count as xs:integer, $start as xs:integer,
 $query as xs:string, $tag as xs:string)
as item()* {
  (: which page are we on?
      if there are more than 20 pages, display a sliding window
   :)
  let $this := xs:integer(fn:ceiling($start div $g-page-size))
  let $first :=
    if ($count gt 20 and $this gt 10) then ($this - 10) else 1
  let $last :=
    xs:integer(fn:min(( $first + 19, fn:ceiling($count div $g-page-size) )))
  return
  if ($count > $g-page-size) then
    <table align="center"><tr align="center">
      <td>Result Page:</td>{
      if ($this > 1) then
        <td><a href="?start={$start - $g-page-size}&amp;query={
xdmp:url-encode(xdmp:get-request-field("query"))}&amp;query-type={
xdmp:url-encode(xdmp:get-request-field("query-type", $g-default-query-type))
}&amp;near-type={xdmp:url-encode($g-near-type)}&amp;near={
xdmp:url-encode($g-near) }"
              style="font-size:16pt;font-weight:bold">Previous
        </a></td>
      else (),
      for $p in ($first to fn:min((19 + $first, $last)))
        return
          if ($p = $this)
          then
            <td style="font-size:12pt;font-weight:bold;color:#000000">{$p}</td>
          else
            <td><a style="font-size:12pt;font-weight:bold"
              href="?start={(($p - 1) * $g-page-size) + 1}&amp;query={
xdmp:url-encode(xdmp:get-request-field("query"))}&amp;query-type={
xdmp:url-encode(xdmp:get-request-field("query-type", $g-default-query-type))
}&amp;near-type={xdmp:url-encode($g-near-type)}&amp;near={
xdmp:url-encode($g-near) }">
              {$p}</a></td>
      ,
      if (fn:ceiling($count div $g-page-size) > $this) then
        <td><a href="?start={$start + $g-page-size}&amp;query={
xdmp:url-encode(xdmp:get-request-field("query"))}&amp;query-type={
xdmp:url-encode(xdmp:get-request-field("query-type", $g-default-query-type))
}&amp;near-type={xdmp:url-encode($g-near-type)}&amp;near={
xdmp:url-encode($g-near) }" style="font-size:16pt;font-weight:bold">Next
        </a></td>
      else ()
    }
    </tr></table>
  else ()
} (: do-pagination :)


(:
    search phrase tokenization:
    * tokenize on double-quotes for user-quoted phrases
    * next, tokenize on whitespace
:)
define function get-query-tokens($input as xs:string?) as element() {
(: This parses the quotes to be exact matches.
   The idea for this comes from /xqzone/search/trunk/query-xml.xqy :)
<tokens>{
let $newInput := fn:string-join(
(: check if there is more than one double-quotation mark.  If there is, 
   tokenize on the double-quotation mark ("), then change the spaces
   in the even tokens to the string "!+!".  This will then allow later
   tokenization on spaces, so you can preserve quoted phrases as phrase
   searches (after re-replacing the "!+!" strings with spaces).  :)
    if ( fn:count(fn:tokenize($input, '"')) > 2 )
    then ( for $i at $count in fn:tokenize($input, '"')
           return
             if ($count mod 2 = 0)
             then fn:replace($i, "\s+", "!+!")
             else $i
         )
    else ( $input ) , " ")
let $tokenInput := fn:tokenize($newInput, "\s+")

return (
for $x in $tokenInput
where $x ne ""
return
<token>{fn:replace($x, "!\+!", " ")}</token>)
}</tokens>

}

define function get-query
($input as xs:string, $type as xs:string, $near as xs:string, 
 $near-type as xs:string) {
  debug(("get-query: ", $input, $type, $near, $near-type)),
let $tokens := get-query-tokens($input)
let $nearTokens := get-query-tokens($near)
let $firstquery := 
   if ($type = "exact")
   then cts:word-query($input)
   else
       (: all words in query :)
       if ($type = "and") 
       then ( cts:and-query(for $token in $tokens//token
                            return 
                            cts:word-query($token/text())) )
       (: any word in query :)
       else if ($type = "or") 
            then cts:or-query(for $token in $tokens//token
                              return 
                              cts:word-query($token/text()))
       (: runtime error :)
       else fn:error(fn:concat("unknown search type: ", $type))
let $secondquery := 
   if ($near-type = "exact")
   then cts:word-query($near)
   else
       (: all words in query :)
       if ($near-type = "and")  
       then ( cts:and-query(for $token in $nearTokens//token
                            return 
                            cts:word-query($token/text())) )
       (: any word in query :)
       else if ($near-type = "or") 
            then ( cts:or-query(for $token in $nearTokens//token
                                return 
                                cts:word-query($token/text())) )
       (: runtime error :)
       else fn:error(fn:concat("unknown search type: ", $near-type))
let $distance := xs:integer(xdmp:get-request-field("distance","100"))
return
  if ($near = "false1" or $near = "")
  then ( $firstquery )
   else ( 
    cts:near-query( ($firstquery, $secondquery), $distance ) 
        )
}

(: Use this function to get the terms to highlight for the dispay page :)
define function get-query-for-display
($search as xs:string, $type as xs:string, 
 $near as xs:string, $near-type as xs:string) {
cts:or-query((
  if ( $type = "exact" )
  then ( cts:word-query($search) )
  else (
    let $tokens := get-query-tokens($search)
    return
    cts:or-query(for $token in $tokens//token
                 return 
                 cts:word-query($token/text()))
       )
,
  if ($near-type = "exact")
  then ( cts:word-query($near) )
  else (
    let $near-tokens := get-query-tokens($near)
    return
    cts:or-query(for $token in $near-tokens//token
                 return 
                 cts:word-query($token/text()))
       )
))
}

define function display-one-result
($result as element(), $ht as xs:string+, $max as xs:integer)
 as item()* {
  debug(("display-one-result:", $result, $ht, $max, xdmp:score($result))),
  let $link := fn:base-uri($result) 
  let $act := for $act at $actidx in fn:doc($link)//ACT
              where $act is $result/ancestor::ACT[1]
              return ($actidx)
  let $scene := 
        let $isItEmpty :=
              for $scene at $sceneidx in fn:doc($link)//ACT[$act]//SCENE
              where $scene is $result
              return xs:string($sceneidx)
         return if ( fn:empty($isItEmpty) )
                then ( "0" )
                else  $isItEmpty
  let $title := fn:doc($link)/PLAY/TITLE/text()
  let $describe := xdmp:base64-encode(xdmp:describe($result))
  let $fulllink := fn:concat('display.xqy?fname=', $link, '&query-type=', 
                        xdmp:url-encode(xdmp:get-request-field("query-type",   
                                                    $g-default-query-type)),
                 '&query=', xdmp:url-encode(xdmp:get-request-field("query")),
                 '&near-type=',  xdmp:url-encode($g-near-type),
                 '&near=',  xdmp:url-encode($g-near))
  let $scenelink := fn:concat( if ( $result/ancestor::ACT )
                    then ( fn:concat('displayScene.xqy?fname=', $link, '&act=', 
                              xs:string($act), '&scene=', $scene ) )
                    else ( fn:concat('displayScene.xqy?fname=', $link, 
                             '&drama=true') ) ,
                  fn:concat('&query-type=', 
                        xdmp:url-encode(xdmp:get-request-field("query-type",   
                                                    $g-default-query-type)),
                 '&query=', xdmp:url-encode(xdmp:get-request-field("query")),
                 '&near-type=',  xdmp:url-encode($g-near-type),
                 '&near=',  xdmp:url-encode($g-near),
(: Is this a prologue? :) if ( $result/self::PROLOGUE )
                          then ( '&prologue=true' )
                          else (''),
(: Is this an epilogue? :) if ( $result/self::EPILOGUE )
                          then ( '&epilogue=true' )
                          else ('') ) )

  return element div {
    element a {
      attribute href { $fulllink },
      $title
    }, $g-nbsp,
    <br/>,
    $g-nbsp, $g-nbsp, element a {
       attribute href {  fn:concat($fulllink, "#", 
           fn:string-join(fn:tokenize(fn:normalize-space(fn:string-join(
              $result/preceding-sibling::TITLE/text(), "") ), "\s+" ), "") )
                      }, 
       $result/preceding-sibling::TITLE/text()
               }, <br/>,
    $g-nbsp, $g-nbsp, $g-nbsp, $g-nbsp, element a {
       attribute href { $scenelink}, 
       $result/TITLE/text()
               }, (: <br/>,
    $g-nbsp, $g-nbsp, $g-nbsp, $g-nbsp, $g-nbsp, $g-nbsp, element a {
       attribute href { fn:concat($fulllink, "#", 
          xdmp:base64-encode(xdmp:describe(
               (: Put this in a FLOWR to strip off the parenthesis from the 
                  describe of the node :)
                        for $x in $result/TITLE return $x )           
                                  ) )
                      }, 
                  $result/TITLE/text()
               }, :)<br/>,
    <font size="-1">{
      (: highlight the search terms in the results, then turn
         return the text plus the highlighted nodes :)
  for $highlight in $result
  return
     let $search := fn:normalize-space(xdmp:get-request-field("query"))
     let $near := fn:normalize-space(xdmp:get-request-field("near", "false1"))
     let $type := xdmp:get-request-field("query-type", $g-default-query-type) 
     let $near-type := xdmp:get-request-field("near-type", $g-default-query-type) 
     let $textHighlight := 
              cts:highlight($highlight, get-query($search, $type, 
                                                  $near, $near-type),
 <span class="cts:highlight" style="color:{$g-highlight-color};
   font-weight:bold"><a href={fn:concat(
(: is this part of an ACT? :)
     if ( fn:not($result/ancestor::ACT) )
     then ( fn:concat('displayScene.xqy?fname=', $link, '&drama=true') )
     else (fn:concat('displayScene.xqy?fname=', $link, '&act=',
        for $act at $actidx in fn:doc($link)//ACT
        where $act is $cts:node/ancestor::ACT[1]
        return xs:string($actidx), '&scene=',
 (: check for empty because we will be casting this to an integer
    and you cannot cast the empty string to an integer :)
        let $isItEmpty :=
            for $scene at $sceneidx in $cts:node/ancestor::ACT[1]//SCENE
            where $scene is $cts:node/ancestor::SCENE[1]
            return xs:string($sceneidx)
        return if ( fn:empty($isItEmpty) )
               then ( "0" )
               else  $isItEmpty
                    )
           ), 
                       
   '&query-type=', xdmp:url-encode(xdmp:get-request-field("query-type",   
   $g-default-query-type)),
  '&query=', xdmp:url-encode(xdmp:get-request-field("query")),
  '&near-type=',  xdmp:url-encode($g-near-type),
  '&near=',  xdmp:url-encode($g-near),
(: Is this a prologue? :) if ( $cts:node/ancestor::PROLOGUE )
                          then ( '&prologue=true' )
                          else (''),
(: Is this an epilogue? :) if ( $cts:node/ancestor::EPILOGUE )
                          then ( '&epilogue=true' )
                          else ('')
           ,  
   (: add the anchor id to the end of the href :)

           (: Is this in a TITLE? :)
         if ( $cts:node/parent::TITLE )
         then ( fn:concat("#", 
                 (: put the name without spaces as the html anchor :)
               fn:string-join(fn:tokenize(fn:normalize-space(
                 fn:string-join($cts:node, "")), "\s+" ), "")) )
         else (
           (: Is this in a STAGEDIR? :)
         if ( $cts:node/parent::STAGEDIR )
         then ( fn:concat("#", 
             xdmp:base64-encode(xdmp:describe(
               (: Figure out where the STAGEDIR is in the structure.  Also, 
                  put this in a FLOWR to strip off the parenthesis from the 
                  describe of the node to ensure 3.0 compatibility. :)
      if ( $cts:node/parent::STAGEDIR/preceding-sibling::SPEECH )
      then (
      for $x in $cts:node/parent::STAGEDIR/preceding-sibling::SPEECH[1]
      return $x 
            )
      else if ( $cts:node/parent::STAGEDIR/preceding-sibling::TITLE )
      then ( 
      for $x in $cts:node/parent::STAGEDIR/preceding-sibling::TITLE[1]
      return $x 
           )
      else if ( $cts:node/parent::STAGEDIR/parent::SPEECH )
      then ( 
      for $x in $cts:node/parent::STAGEDIR/parent::SPEECH[1]
      return $x 
           )
      else ("CANNOTFIGUREITOUT")
                 ) ) ) )
         else (
           (: Is this in a PERSONA? :)
         if ( $cts:node/parent::PERSONA )
         then ( "#PERSONAE" )
         else (
            (: Is this in a LINE? :)
         if ( $cts:node/parent::LINE )
         then ( fn:concat("#", 
          xdmp:base64-encode(xdmp:describe(
               (: Put this in a FLOWR to strip off the parenthesis from the 
                  describe of the node :)
                        for $x in $cts:node/parent::LINE/parent::SPEECH
                        return $x) 
                           ) )
              )
         else (
            (: Just go to the closest TITLE :)
           fn:concat("#", 
          xdmp:base64-encode(xdmp:describe(
               (: Put this in a FLOWR to strip off the parenthesis from the 
                  describe of the node :)
                        for $x in $cts:node/(ancestor::SCENE | 
                                        ancestor::ACT |
                                        ancestor::PLAY)[fn:last()]/
                                TITLE return $x )  ), "") 
              )
            )  )))}>{$cts:text}</a></span>)
       return
       truncateText(<div>{renderText($textHighlight)}</div>)
    }</font>
  }
} (: display-one-result :)

define function display-search-results
($results as element()*, $max-score as xs:integer,
 $tag as xs:string, $start as xs:integer, $search as xs:string)
as element()* {
  let $highlight-toks := get-query-tokens($search)//token/text()[. ne ""]
  return (
    debug(("display-search-results: highlight-toks = ", $highlight-toks)),
    for $r at $i in $results
    return element {$tag} {
      display-one-result($r, $highlight-toks, $max-score)
    }
  )
} (: display-search-results :)

define function get-search-results
($search as xs:string?, $start as xs:integer, $type as xs:string, 
 $near as xs:string?, $near-type as xs:string)
 as element()* {
  (: check for empty query :)
  debug(("get-search-results:", $search)),
  (: forbid empty queries :)
  if (fn:empty($search) or fn:string-length($search) lt 1) then () else
    (: construct and execute search by elements :)
    let $query := get-query($search, $type, $near, $near-type)
    let $results := (
      if ($start gt 1) 
      then cts:search(//element()[fn:name(.) = $g-elements], $query)[1]  
      else (),
      cts:search(//element()[fn:name(.) = $g-elements], $query)  
        [$start to $start + $g-page-size - 1]
    )
    return (
      debug(("get-search-results:", $query)),
      (: full count, for pagination and results summary :)
      element count { 
      fn:count( cts:search(//element()[fn:name(.) = $g-elements], $query) 
           )
      },
      if (fn:count($results) gt 0) then (
        element max-score { xdmp:score($results[1]) },
        $results[ (if ($start gt 1) then 2 else 1) to fn:last() ]
      ) else ()
    )
} (: get-search-results :)

define function renderText(
      $x as item()*)
as item()*
{
       if (fn:empty($x)) then () else
       typeswitch($x)
             (: do *not* normalize-space here because we want to 
                preserve leading spaces in the text nodes :)
          case text() return (fn:string-join($x, ""))
          case element(pagenum) return ""
          case element (span) return 
                 if ( $x/@class eq "cts:highlight" ) 
                 then ( $x )
       (: else  ( fn:concat(" ", normalize-space(fn:string-join($x, ""))," ") ) :)
                 else  ( fn:normalize-space(fn:string-join($x, "")) )
          case processing-instruction() return ()

          default return for $z in $x/node() return renderText($z)
}

define function truncateText(
    $x as item())
as item()*
{
if (fn:empty($x)) then () else
   typeswitch($x)
        (: return the $g_num words before and after the highlight term :)
   case text() return
        ( (: is there a highlight node before? :)
          if ( $x/preceding-sibling::node()[1][self::span] )
                 then ((: if so, print the first $g_num words :)
                    let $tokens := cts:tokenize($x)
                    let $count := fn:count($tokens)
                    let $truncateTokens := if ( $count < $g-num ) 
                                      then ( $tokens ) 
                                      else ( $tokens[1 to $g-num] )
                    return
                    if ( $count < $g-num )
                    then ( (: is there a highlight node after? :)
                          if ( $x/following-sibling::node()[1][self::span] )
                          then ( (: if there is a highlight node after, we do 
                                    not want to double count it :) )
                          else (
                            fn:concat(
               (: If the first token is punctuation, then no space before :)
                             if ($tokens[1] instance of cts:punctuation )
                             then ("")
                             else (" "), fn:string-join($tokens, "") )
                         ) )
                    else ( fn:concat(
                 (: If the first token is punctuation, then no space before :)
                             if ($truncateTokens[1] instance of cts:punctuation )
                             then ("")
                             else (" "), fn:string-join( $truncateTokens , ""), 
                                  " "), <b>...</b>, "&nbsp;" 
                         ) 
                      )
                 else (""),
        (: is there a highlight node after? :)
        if ( $x/following-sibling::node()[1][self::span] )
        then ( (: if so, print the last $g_num words :)
                 let $tokens := cts:tokenize($x)
                 let $count := fn:count($tokens)
                 let $truncateTokens := if ( $count < $g-num ) 
                             then ( $tokens ) 
                             else ( $tokens[fn:last() - $g-num to fn:last()] )
                 return
                 if ( $count < $g-num )
                 then ( fn:concat(fn:string-join($tokens, ""),
              (: If the last token is not punctuation, then add space after :)
                    if (fn:not($tokens[fn:last()] instance of cts:punctuation) )
                    then (" ")
                    else ("") )
                       )
                 else ( fn:concat(fn:string-join( $truncateTokens , ""),
              (: If the last token is not punctuation, then add space after :)
                           if (fn:not($tokens[fn:last()] instance of cts:punctuation) )
                           then (" ")
                           else ("") )
                       )
               )
          else ("" )
           )
   case element (span) return $x
   default return for $z in $x/node() return truncateText($z)  
} (: truncateText :)

(: lib.xqy :)
