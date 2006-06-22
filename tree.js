/* Copyright © 2002 Jean-Claude Manoli [jc@manoli.net]
 *
 * This software is provided 'as-is', without any express or implied warranty.
 * In no event will the author(s) be held liable for any damages arising from
 * the use of this software.
 * 
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 * 
 *   1. The origin of this software must not be misrepresented; you must not
 *      claim that you wrote the original software. If you use this software
 *      in a product, an acknowledgment in the product documentation would be
 *      appreciated but is not required.
 * 
 *   2. Altered source versions must be plainly marked as such, and must not
 *      be misrepresented as being the original software.
 * 
 *   3. This notice may not be removed or altered from any source distribution.
 */ 

var treeSelected = null; //last treeNode clicked

//pre-load tree nodes images
var imgPlus = new Image();
imgPlus.src="treenodeplus.gif";
var imgMinus = new Image();
imgMinus.src="treenodeminus.gif";
var imgDot = new Image();
imgPlus.src="treenodedot.gif";


function findNode(el)
{
// Takes element and determines if it is a treeNode.
// If not, seeks a treeNode in its parents.
	while (el != null)
	{
		if (el.className == "treeNode")
		{
			break;
		}
		else
		{
			el = el.parentNode;
		}
	}
	return el;
}


function clickAnchor(el)
{
// handles click on a TOC link
//
	expandNode(el.parentNode);
	selectNode(el.parentNode);
	el.blur();
}


function selectNode(el)
{
// Un-selects currently selected node, if any, and selects the specified node
//
	if (treeSelected != null)
	{
		setSubNodeClass(treeSelected, 'A', 'treeUnselected');
	}
	setSubNodeClass(el, 'A', 'treeSelected');
	treeSelected = el;
}


function setSubNodeClass(el, nodeName, className)
{
// Sets the specified class name on el's first child that is a nodeName element
//
	var child;
	for (var i=0; i < el.childNodes.length; i++)
	{
		child = el.childNodes[i];
		if (child.nodeName == nodeName)
		{
			child.className = className;
			break;
		}
	}
}


function expandCollapse(el)
{
//	If source treeNode has child nodes, expand or collapse view of treeNode
//
	if (el == null)
		return;	//Do nothing if it isn't a treeNode
		
	var child;
	var imgEl;
	for(var i=0; i < el.childNodes.length; i++)
	{
		child = el.childNodes[i];
		if (child.src)
		{
			imgEl = child;
		}
		else if (child.className == "treeSubnodesHidden")
		{
			child.className = "treeSubnodes";
			imgEl.src = "treenodeminus.gif";
			break;
		}
		else if (child.className == "treeSubnodes")
		{
			child.className = "treeSubnodesHidden";
			imgEl.src = "treenodeplus.gif";
			break;
		}
	}
}


function expandNode(el)
{
//	If source treeNode has child nodes, expand it
//
	var child;
	var imgEl;
	for(var i=0; i < el.childNodes.length; i++)
	{
		child = el.childNodes[i];
		if (child.src)
		{
			imgEl = child;
		}
		if (child.className == "treeSubnodesHidden")
		{
			child.className = "treeSubnodes";
			imgEl.src = "treenodeminus.gif";
			break;
		}
	}
}


function syncTree(href)
{
// Selects and scrolls into view the node that references the specified URL
//
	var loc = new String();
	loc = href;
	if (loc.substring(0, 7) == 'file://')
	{
		loc = 'file:///' + loc.substring(7, loc.length);
		loc = loc.replace(/\\/g, '/');
	}
// danny;6/14/05: Made minor modifications to parse my strange URLs
// add test for query-type and remove from href
// also remove anchor from href
	if (loc.indexOf("query-type") >= 0 )
	{
                loc = loc.substr(0, loc.indexOf("query-type") - 1 )
	}
// TOC urls go to displayScene.xqy
        if (loc.indexOf("display.xqy") >= 0 )
        {
               loc = loc.replace(/display.xqy/g, 'displayScene.xqy');
// these links nre set up for the scene (not the whole play), so they 
// point to the dramatis personae page
               loc = loc + "&drama=true"
        }

//	var base = loc.substr(0, loc.lastIndexOf('/') + 1);
// change URL parsing to deal with request fields
	var scheme = location.protocol;
	var host = location.host;
	var base = scheme + "//" + host + "/";
	
	var tocEl = findHref(document.getElementById('treeRoot'), loc, base);
	if (tocEl != null)
	{
		selectAndShowNode(tocEl);
	}
}

function findHref(node, href, base)
{
// find the <a> element with the specified href value
//
	var el;
	var anchors = node.getElementsByTagName('A');
	for (var i = 0; i < anchors.length; i++)
	{
		el = anchors[i];
		var aref = new String();
		aref = el.getAttribute('href');
		
		if ((aref.substring(0, 7) != 'http://') 
			&& (aref.substring(0, 8) != 'https://')
			&& (aref.substring(0, 7) != 'file://'))
		{
			aref = base + aref;
		}
		
		if (aref == href)
		{
			return el;
		}
	}
	return null;
}

// danny; 6-19-2006; This is a new version of this function.  It
// simply always scrolls to the selected item.  I could never
// get the original version (below) to scroll properly.  
function selectAndShowNode(node)
{
// Selects and scrolls into view the specified node

	var el = findNode(node);
	if (el != null) 
	{
		selectNode(el);
		do 
		{
			expandNode(el);
			el = findNode(el.parentNode);
		} while ((el != null))  
		
	//vertical scroll element into view
        var treeDiv = document.getElementById('tree');
        var nodePosition;

        nodePosition = node.offsetTop + treeDiv.offsetTop;
        // offset by 400 to make up for the picture and the form 
        window.scroll(0, nodePosition - 400 );
        }
}


function selectAndShowNode_orig(node)
{
// Selects and scrolls into view the specified node
//
	var el = findNode(node);
	if (el != null) 
	{
		selectNode(el);
		do 
		{
			expandNode(el);
			el = findNode(el.parentNode);
		} while ((el != null))  
		
		//vertical scroll element into view
		var windowTop;
		var windowBottom;
		var treeDiv = document.getElementById('tree');

                var nodePosition;
		
		var ua = window.navigator.userAgent.toLowerCase();
		if ((i = ua.indexOf('msie')) != -1)
		{
			windowTop = node.offsetTop - treeDiv.scrollTop;
			windowBottom = treeDiv.clientHeight - windowTop - node.offsetHeight;

		}
		else if (ua.indexOf('gecko') != -1)
		{
			windowTop = node.offsetTop - treeDiv.offsetTop - treeDiv.scrollTop;
			windowBottom = treeDiv.clientHeight - windowTop - node.offsetHeight;


		}
		else 
		{
			return;
		}
		
		if (windowTop < 0 )
		{
			treeDiv.scrollTop += windowTop - 18;
			return;
		}
		if (windowBottom < 0 )
		{
			treeDiv.scrollTop -= windowBottom - 18;
			return;
		}
	}
}


function resizeTree()
{
	var treeDiv = document.getElementById('tree');
	//treeDiv.setAttribute('style', 'width: ' + document.body.offsetWidth + 'px; height: ' + (document.body.offsetHeight - 27) + 'px;');
	treeDiv.style.width = document.documentElement.offsetWidth;
	treeDiv.style.height = document.documentElement.offsetHeight - 27;
}
