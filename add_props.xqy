(: add properties so we can tell what is a TRAGEDY, COMEDY, and HISTORY
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

Among scholars, there is not always agreement as to which plays are 
classified as which.  The ones chosen here are reasonably well agreed
upon, although some scholars might disagree.  For example, Richard III
is classified as a history, even though its full title is
"The Tragedy of Richard the Third".  If you disagree with the any of
the classifications, change them.

:)

(: first clean up by removing any properties with this name :)
for $x in xdmp:directory("/shakespeare/plays/")
return 
xdmp:document-remove-properties(base-uri($x),  
     fn:expanded-QName("", "playtype")  );
 
(: add the properties :)
xdmp:document-set-properties("/shakespeare/plays/a_and_c.xml", 
        <playtype>TRAGEDY</playtype>);

xdmp:document-set-properties("/shakespeare/plays/tempest.xml", 
        <playtype>TRAGEDY</playtype>);

xdmp:document-set-properties("/shakespeare/plays/hen_vi_1.xml", 
        <playtype>HISTORY</playtype>);

xdmp:document-set-properties("/shakespeare/plays/hen_v.xml", 
        <playtype>HISTORY</playtype>);

xdmp:document-set-properties("/shakespeare/plays/troilus.xml", 
        <playtype>COMEDY</playtype>);

xdmp:document-set-properties("/shakespeare/plays/titus.xml", 
        <playtype>TRAGEDY</playtype>);

xdmp:document-set-properties("/shakespeare/plays/hen_vi_3.xml", 
        <playtype>HISTORY</playtype>);

xdmp:document-set-properties("/shakespeare/plays/j_caesar.xml", 
        <playtype>TRAGEDY</playtype>);

xdmp:document-set-properties("/shakespeare/plays/rich_ii.xml", 
        <playtype>HISTORY</playtype>);

xdmp:document-set-properties("/shakespeare/plays/hen_iv_2.xml", 
        <playtype>HISTORY</playtype>);

xdmp:document-set-properties("/shakespeare/plays/othello.xml", 
        <playtype>TRAGEDY</playtype>);

xdmp:document-set-properties("/shakespeare/plays/lear.xml", 
        <playtype>TRAGEDY</playtype>);

xdmp:document-set-properties("/shakespeare/plays/hamlet.xml", 
        <playtype>TRAGEDY</playtype>);

xdmp:document-set-properties("/shakespeare/plays/timon.xml", 
        <playtype>TRAGEDY</playtype>);

xdmp:document-set-properties("/shakespeare/plays/win_tale.xml", 
        <playtype>COMEDY</playtype>);

xdmp:document-set-properties("/shakespeare/plays/much_ado.xml", 
        <playtype>COMEDY</playtype>);

xdmp:document-set-properties("/shakespeare/plays/merchant.xml", 
        <playtype>COMEDY</playtype>);

xdmp:document-set-properties("/shakespeare/plays/as_you.xml", 
        <playtype>COMEDY</playtype>);

xdmp:document-set-properties("/shakespeare/plays/hen_vi_2.xml", 
        <playtype>HISTORY</playtype>);

xdmp:document-set-properties("/shakespeare/plays/rich_iii.xml", 
        <playtype>HISTORY</playtype>);

xdmp:document-set-properties("/shakespeare/plays/hen_iv_1.xml", 
        <playtype>HISTORY</playtype>);

xdmp:document-set-properties("/shakespeare/plays/hen_viii.xml", 
        <playtype>HISTORY</playtype>);

xdmp:document-set-properties("/shakespeare/plays/john.xml", 
        <playtype>HISTORY</playtype>);

xdmp:document-set-properties("/shakespeare/plays/all_well.xml", 
        <playtype>COMEDY</playtype>);

xdmp:document-set-properties("/shakespeare/plays/lll.xml", 
        <playtype>COMEDY</playtype>);

xdmp:document-set-properties("/shakespeare/plays/macbeth.xml", 
        <playtype>TRAGEDY</playtype>);

xdmp:document-set-properties("/shakespeare/plays/taming.xml", 
        <playtype>COMEDY</playtype>);

xdmp:document-set-properties("/shakespeare/plays/t_night.xml", 
        <playtype>COMEDY</playtype>);

xdmp:document-set-properties("/shakespeare/plays/m_for_m.xml", 
        <playtype>COMEDY</playtype>);

xdmp:document-set-properties("/shakespeare/plays/cymbelin.xml", 
        <playtype>COMEDY</playtype>);

xdmp:document-set-properties("/shakespeare/plays/com_err.xml", 
        <playtype>COMEDY</playtype>);

xdmp:document-set-properties("/shakespeare/plays/m_wives.xml", 
        <playtype>COMEDY</playtype>);

xdmp:document-set-properties("/shakespeare/plays/dream.xml", 
        <playtype>COMEDY</playtype>);

xdmp:document-set-properties("/shakespeare/plays/pericles.xml", 
        <playtype>COMEDY</playtype>);

xdmp:document-set-properties("/shakespeare/plays/two_gent.xml", 
        <playtype>COMEDY</playtype>);

xdmp:document-set-properties("/shakespeare/plays/r_and_j.xml", 
        <playtype>TRAGEDY</playtype>);

xdmp:document-set-properties("/shakespeare/plays/coriolan.xml", 
        <playtype>TRAGEDY</playtype>);

"added properties for the following:
",
for $x in xdmp:directory("/shakespeare/plays/", "1")
return
( 
  fn:concat(xdmp:node-uri($x), " has the property:
", xdmp:quote(xdmp:document-get-properties(xdmp:node-uri($x), 
                   xs:QName("playtype") ) ), "
" )
);
