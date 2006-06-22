(:
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

declare namespace xh="http://www.w3.org/1999/xhtml"
declare namespace no=""
default element namespace = "http://www.w3.org/1999/xhtml"

import module namespace 
       d="http://marklogic.com/bill/display" at "display-lib.xqy"
import module namespace 
       s="http://marklogic.com/bill/search" at "search-lib.xqy"

define variable $g-highlight-color { "#cc0000" }

xdmp:set-response-content-type("text/html"),

let $fname :=   xdmp:get-request-field("fname",
                               "http://pubs/3.0doc/xml/admin/admin_inter.xml") 
return
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <title>{doc($fname)/PLAY/TITLE/text()}</title>
</head>
<body onload="window.parent.frames[0].syncTree(document.URL)">
{ 
let $search := normalize-space(xdmp:get-request-field("query"))
let $type := xdmp:get-request-field("query-type", "and")
let $near := normalize-space(xdmp:get-request-field("near", ""))
let $near-type := xdmp:get-request-field("near-type", "and")
let $dispatch := d:dispatch(doc($fname)/no:PLAY )
return
if ( $search )
then ( for $highlight in $dispatch
       return cts:highlight($highlight, s:get-query-for-display($search, $type,
                                                            $near, $near-type),
<span class="cts:highlight" style="color:{$s:g-highlight-color};
                font-weight:bold">{$cts:text}</span> ) )
else ( $dispatch )

 }
</body>
</html>

