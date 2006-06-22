(:
 : Demo: generic search UI for Semi-structured content
 :
 : Authors:
 :   Michael Blakeley <michael.blakeley@marklogic.com>
 :   mods by danny <danny@marklogic.com>
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

import module namespace s="http://marklogic.com/bill/search"
 at "search-lib.xqy"

define variable $query-types as element()+ {
  <option value="and" text="all of the words"/>,
  <option value="or" text="any of the words"/>,
  <option value="exact" text="the exact phrase"/>
}
define variable $g-query {
  fn:normalize-space(xdmp:get-request-field("query"))
}
define variable $g-start as xs:integer {
  xs:integer(xdmp:get-request-field("start", "1"))
}
define variable $g-query-type { xdmp:get-request-field("query-type",  
   (: Make it an exact search if the search term has a ":" in it 
      but no " " :)
   if ( ( fn:contains(xdmp:get-request-field("query"), ":") or 
          fn:contains(xdmp:get-request-field("query"), "-") ) 
         and not(fn:contains(xdmp:get-request-field("query"), " ")) )
   then ( "exact" )
   else ( "and" )) }

define variable $g-results {
  s:get-search-results($g-query, $g-start, $g-query-type, 
                       $s:g-near, $s:g-near-type)
}

define variable $g-count as xs:integer {
  if ( fn:exists($g-results/self::count) )
  then ( xs:integer($g-results/self::count) )
  else 0
}

xdmp:set-response-content-type("text/html; charset=utf-8"),
s:debug(("g-results:", $g-results)),
<html>
  <head>
    <title>Search for {$g-query}</title>
    <link rel="stylesheet" type="text/css" href="styles.css"/>
  </head>
  <body>
    <form method="GET" action="search.xqy" id="searchForm">
      <input type="hidden" name="start" id="start" value="1"/>

      <table border="0" cellspacing="0" cellpadding="1" width="90%">
        <tr>
          <td nowrap="true" class="bold" colspan="2">Search
            <select name="query-type">{
              for $t in $query-types
              return element option {
                $t/@value,
                if ($t/@value = $g-query-type)
                then attribute selected { true() }
                else (),
                fn:data($t/@text)
              }
            }</select>
            <input type="text" name="query" size="31" maxlength="256"
              value="{$g-query}"/>
            <input type="submit" name="button" value="search"/>
          </td>
        </tr>
        <tr>
          <td nowrap="true" height="8"></td>
        </tr>
        <tr><td></td>
           <td align="right"><font size="-2">
              <a href={fn:concat("searchAdv.xqy?query=", $g-query)}>
              Advanced Search</a></font>
           </td>
        </tr>
        <tr>
          <td nowrap="true" height="8"></td>
        </tr>
{
    if (0 lt $g-count) then
      <tr>
      <td nowrap="true" width="50%"
       bgcolor="{ s:get-active-color() }" class="white">
        &#160;
        <span class="small">
          Searched for
          {fn:data($query-types[@value = $g-query-type]/@text)}
          </span>:&nbsp;
          <span class="small bold"
           style="text-decoration:underline">{$g-query}
          </span>
      </td>
      <td align="right" nowrap="true" width="50%"
       bgcolor="{ s:get-active-color() }" class="white">
        &#160;<span class="small">
        Results
        <b>{
             fn:min(($g-count, $g-start))
           } - {
             fn:min((
               $g-count,
               $g-start + fn:count($g-results[fn:name(.) = $s:g-elements]) - 1
             ))
        }</b> of {$g-count}&#160;</span>
      </td>
      </tr>
    else ()
}
</table>
<br/>
<table width="90%">
<tr><td width="100%">{
  (: search results - or not :)
  if (fn:empty($g-query) or fn:string-length($g-query) lt 1) then
    <table width="100%">
      <tr><td><p>Enter one or more search terms.</p></td></tr>
    </table>
  else if ($g-count lt 1) then (
    <p>Your search - <b>{$g-query}</b> - did not match any documents.</p>,
    <ul>
       <li>Are all your words spelled correctly?</li>
       <li>Try using different words, or fewer words</li>
    </ul>
    ) else (
      s:display-search-results(
        $g-results[fn:name(.) = $s:g-elements], $g-results/self::max-score,
        'p', $g-start, $g-query
      ),
      s:do-pagination($g-count, $g-start, $g-query, 'p')
    )
}</td></tr>
<tr><td height="16"></td></tr>
</table>
</form>

</body>
</html>
