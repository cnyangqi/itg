//=================================================================
// JavaScript Tree
// Version 1.0
// by Nicholas C. Zakas, nicholas@nczonline.net
// Copyright (c) 2002 Nicholas C. Zakas.  All Rights Reserved.
//-----------------------------------------------------------------
// Browsers Supported:
//	* Netscape 6.1+
//  * Internet Explorer 5.0+
//=================================================================
// History
//-----------------------------------------------------------------
// January 27, 2002 (Version 1.0)
//  - Works in Netscape 6.1+ and IE 5.0+  
//=================================================================
// Software License
// Copyright (c) 2002 Nicholas C. Zakas.  All Rights Reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
//
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer. 
//
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in
//    the documentation and/or other materials provided with the
//    distribution.
//
// 3. The end-user documentation included with the redistribution,
//    if any, must include the following acknowledgment:  
//       "This product includes software developed by the
//        Nicholas C. Zakas (http://www.nczonline.net/)."
//    Alternately, this acknowledgment may appear in the software itself,
//    if and wherever such third-party acknowledgments normally appear.
//
// 4. Redistributions of any form are free for use in non-commercial
//    ventures. If intent is to use in a commercial product, contact
//    Nicholas C. Zakas at nicholas@nczonline.net for purchasing of
//    a commercial license.
//
// THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESSED OR IMPLIED
// WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
// OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED.  IN NO EVENT SHALL NICHOLAS C. ZAKAS  BE LIABLE FOR ANY 
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE 
// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER 
// IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
// OF THE POSSIBILITY OF SUCH DAMAGE.
//-----------------------------------------------------------------
// Any questions, comments, or suggestions should be e-mailed to 
// nicholas@nczonline.net.  For more information, please visit
// http://www.nczonline.net/. 
//=================================================================




var IMG_PLUS = DIR_IMAGES + "btnPlus.gif";
var IMG_MINUS = DIR_IMAGES + "btnMinus.gif";

var imgPlus = new Image();
imgPlus.src = IMG_PLUS;
var imgMinus = new Image();
imgMinus.src = IMG_MINUS;

var objLocalTree = null;

var INDENT_WIDTH = 8;

var userExpanded = false;

//-----------------------------------------------------------------
// Class jsTree
//-----------------------------------------------------------------
// Author(s)
//  Nicholas C. Zakas (NCZ), 1/27/02
//
// Description
//  The jsTreeNode class encapsulates the functionality of a tree.
//
// Parameters
//  (none)
//-----------------------------------------------------------------
function jsTree() {

    //Public Properties (NCZ, 1/27/02)
    this.root = null;           //the root node of the tree
 
     //Public Collections (NCZ, 1/27/02)
    this.nodes = new Array;     //array for all nodes in the tree
    this.nodesByStrId = new Array;
   
    //Constructor
    //assign to local copy of the tree (NCZ, 1/27/02)
    objLocalTree = this;
}

//-----------------------------------------------------------------
// Method jsTree.createRoot()
//-----------------------------------------------------------------
// Author(s)
//  Nicholas C. Zakas (NCZ), 1/27/02
//
// Description
//  This method creates the root of the tree.
//
// Parameters
//  strIcon (string) - the icon to display for the root.
//  strText (string) - the text to display for the root.
//  strURL (string) - the URL to navigate to when the root is clicked.
//  strTarget (string) - the target for the URL (optional).
//
// Returns
//  The jsTreeNode that was created.
//-----------------------------------------------------------------
jsTree.prototype.createRoot = function(strIdNo, strIcon, strText, strURL, strTarget) {

    //create a new node (NCZ, 1/27/02)
    this.root = new jsTreeNode(strIdNo, strIcon, strText, strURL, strTarget);
    
    //assign an ID for internal tracking (NCZ, 1/27/02)
    this.root.id = "root";
    
    //add it into the array of all nodes (NCZ, 1/27/02)
    this.nodes["root"] = this.root;
    this.nodesByStrId[strIdNo] = this.root;  //wxj added on 2005-02-01
    
    //make sure that the root is expanded (NCZ, 1/27/02)
    this.root.expanded = true;
    
    //return the created node (NCZ, 1/27/02)
    return this.root;
}

//-----------------------------------------------------------------
// Method jsTree.buildDOM()
//-----------------------------------------------------------------
// Author(s)
//  Nicholas C. Zakas (NCZ), 1/27/02
//
// Description
//  This method creates the HTML for the tree.
//
// Parameters
//  (none)
//
// Returns
//  (nothing)
//-----------------------------------------------------------------
jsTree.prototype.buildDOM = function(objDOMParent) {

    //call method to add root to document, which will recursively
    //add all other nodes (NCZ, 1/27/02)    
    this.root.addToDOM(objDOMParent);
}

//-----------------------------------------------------------------
// Method jsTree.toggleExpand()
//-----------------------------------------------------------------
// Author(s)
//  Nicholas C. Zakas (NCZ), 1/27/02
//
// Description
//  This toggles the expansion of a node identified by an ID.
//
// Parameters
//  strNodeID (string) - the ID of the node that is being expanded/collapsed.
//
// Returns
//  (nothing)
//-----------------------------------------------------------------
jsTree.prototype.toggleExpand = function(strNodeID) {

    //get the node (NCZ, 1/27/02)
    var objNode = this.nodes[strNodeID];
    
    //determine whether to expand or collapse
    if (objNode.expanded)
        objNode.collapse();
    else
        objNode.expand();
}

//-----------------------------------------------------------------
// Class jsTreeNode
//-----------------------------------------------------------------
// Author(s)
//  Nicholas C. Zakas (NCZ), 1/27/02
//
// Description
//  The jsTreeNode class encapsulates the basic information for a node
//  in the tree.
//
// Parameters
//  strIcon (string) - the icon to display for this node.
//  strText (string) - the text to display for this node.
//  strURL (string) - the URL to navigate to when this node is clicked.
//  strTarget (string) - the target for the URL (optional).
//-----------------------------------------------------------------
function jsTreeNode(strIdNo, strIcon, strText, strURL, strTarget) {

    //Public Properties (NCZ, 1/27/02)
    this.strId = strIdNo; 
    this.icon = strIcon;            //the icon to display
    this.text = strText;            //the text to display
    this.url = strURL;              //the URL to link to
    this.target = strTarget;        //the target for the URL
    
    //Private Properties (NCZ, 1/27/02)
    this.indent = 0;                //the indent for the node
    
    this.nextChildNo = 0;  //子节点下一个序号  用于改进节点id  方便删除  wxj 2005-02-01 added
    
    //Public States (NCZ, 1/27/02)
    this.expanded = userExpanded;          //is this node expanded?
 
    //Public Collections (NCZ, 1/27/02)   
    this.childNodes = new Array;    //the collection of child nodes
}

//-----------------------------------------------------------------
// Method jsTreeNode.addChild()
//-----------------------------------------------------------------
// Author(s)
//  Nicholas C. Zakas (NCZ), 1/27/02
//
// Description
//  This method adds a child node to the current node.
//
// Parameters
//  strIdNo  外部唯一代码
//  strIcon (string) - the icon to display for this node.
//  strText (string) - the text to display for this node.
//  strURL (string) - the URL to navigate to when this node is clicked.
//  strTarget (string) - the target for the URL (optional).
//
// Returns
//  The jsTreeNode that was created.
//-----------------------------------------------------------------
jsTreeNode.prototype.addChild = function (strIdNo, strIcon, strText, strURL, strTarget) {

    //create a new node (NCZ, 1/27/02)
    var objNode = new jsTreeNode(strIdNo, strIcon, strText, strURL, strTarget);
    
    //assign an ID for internal tracking (NCZ, 1/27/02)
    //objNode.id = this.id + "_" + this.childNodes.length;  
    //wxj 2005-02-01将上面一句改为以下两句
    objNode.id = this.id + "_" + this.nextChildNo;
    this.nextChildNo = this.nextChildNo +1;
    
    //assign the indent for this node
    objNode.indent = this.indent + 1;
    
    //add into the array of child nodes (NCZ, 1/27/02)
    this.childNodes[this.childNodes.length] = objNode;
    
    //add it into the array of all nodes (NCZ, 1/27/02)
    objLocalTree.nodes[objNode.id] = objNode;
    
    objLocalTree.nodesByStrId[strIdNo] = objNode;
    
    //return the created node (NCZ, 1/27/02)
    return objNode;
}

jsTreeNode.prototype.removeChild = function (strIdNo )
{
	var success = false;
	var objNode = objLocalTree.nodesByStrId[strIdNo];  //需要删除的节点
	if( objNode == null ) return success;  //
	if( objNode.childNodes.length >0 ) return success;  //需先删除子节点  根节点不能删除
		
	var nodes = null;
	
	/*
	//从objLocalTree.nodes中删除
	nodes = new Array;
	for( i=0; i < objLocalTree.nodes.length; i++)
	{
		var node = objLocalTree.nodes[i];
		if( node.id != objNode.id )
		{
			nodes[node.id] = node;
		}  
	}
	
	objLocalTree.nodes = nodes;
	
	//从objLocalTree.nodesByStrId中删除
	nodes = new Array;
	for( i=0; i < objLocalTree.nodesByStrId.length; i++)
	{
		var node = objLocalTree.nodesByStrId[i];
		if( node.id != objNode.id )
		{
			nodes[node.id] = node;
		}  
	else
		{
			alert( node.id );
		}
	}
	objLocalTree.nodesByStrId = nodes;	
	*/
	
	//从childNodes中删除
	nodes = new Array;
	for( i=0; i < this.childNodes.length; i++)
	{
		var node = this.childNodes[i];
		if( node.id != objNode.id )
		{
			nodes[nodes.length] = node;
		}  
	}
	this.childNodes = nodes;
	
	return true;
}

//-----------------------------------------------------------------
// Method jsTreeNode.addToDOM()
//-----------------------------------------------------------------
// Author(s)
//  Nicholas C. Zakas (NCZ), 1/27/02
//
// Description
//  This method adds DOM elements to a parent DOM element.
//
// Parameters
//  objDOMParent (HTMLElement) - the parent DOM element to add to.
//
// Returns
//  (nothing)
//-----------------------------------------------------------------
jsTreeNode.prototype.addToDOM = function (objDOMParent) {

    //create the URL (NCZ, 1/27/02)
    var strHTMLLink = "";
    
    if( this.url && this.url.length > 0 ) 
    {
      strHTMLLink = "<a href=\"" + this.url + "\"";
      if (this.target && this.target.length >0) strHTMLLink += " target=\"" + this.target + "\"";
      strHTMLLink += ">";
    }  
    else
	{
      if (this.childNodes.length > 0 && this.id != 'root') {
        strHTMLLink = "<a href='#' onclick=\"javascript:objLocalTree.toggleExpand('" + this.id + "')\">";
      }
	}
    
    //create the layer for the node (NCZ, 1/27/02)
    var objNodeDiv = document.createElement("div");
    
    //add it to the DOM parent element (NCZ, 1/27/02)
    objDOMParent.appendChild(objNodeDiv);
    
    //create string buffer (NCZ, 1/27/02)
    var d = new jsDocument;
    
    //begin the table (NCZ, 1/27/02)
    d.writeln("<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\"><tr>");
    
    //no indent needed for root or level under root (NCZ, 1/27/02)
    if (this.indent > 1) {
        d.write("<td width=\"");
        d.write(this.indent * INDENT_WIDTH);
        d.write("\">&nbsp;</td>");
    }
    
    //there is no plus/minus image for the root (NCZ, 1/27/02)
    if (this.indent > 0) {
    
        d.write("<td width=\"18\" align=\"center\">");
        
        //if there are children, then add a plus/minus image (NCZ, 1/27/02)
        if (this.childNodes.length > 0) {
            d.write("<a href='#javascript:return false;' onclick=\"javascript:objLocalTree.toggleExpand('");
            d.write(this.id);
            d.write("')\"><img src=\"");
            d.write(this.expanded ? imgMinus.src : imgPlus.src);
            d.write("\" border=\"0\" hspace=\"1\" id=\"");
            d.write("imgPM_" + this.id);
            d.write("\" /></a>");
        }
        
        d.write("</td>");
    }
    
    //finish by drawing the icon and text (NCZ, 1/27/02)
    d.write("<td width=\"22\">" + this.icon + "</td>");
    d.write("<td>"+strHTMLLink + this.text );
    //if( this.url && this.url.length > 0 ) d.write("</a>");
    d.write("</a>");
    d.writeln("</td></tr></table>");
        
    //assign the HTML to the layer (NCZ, 1/27/02)
    objNodeDiv.innerHTML = d;
    
    //create the layer for the children (NCZ, 1/27/02)
    var objChildNodesLayer = document.createElement("div");
    objChildNodesLayer.setAttribute("id", "divChildren_" + this.id);
    objChildNodesLayer.style.position = "relative";
    objChildNodesLayer.style.display = (this.expanded ? "block" : "none");
    objNodeDiv.appendChild(objChildNodesLayer);
    
    //call for all children (NCZ, 1/27/02)
    for (var i=0; i < this.childNodes.length; i++)
        this.childNodes[i].addToDOM(objChildNodesLayer);
}

//-----------------------------------------------------------------
// Method jsTreeNode.collapse()
//-----------------------------------------------------------------
// Author(s)
//  Nicholas C. Zakas (NCZ), 1/27/02
//
// Description
//  This method expands the jsTreeNode's children to be hidden.
//
// Parameters
//  (none)
//
// Returns
//  (nothing)
//-----------------------------------------------------------------
jsTreeNode.prototype.collapse = function () {

    //check to see if the node is already collapsed (NCZ, 1/27/02)
    if (!this.expanded) {
    
        //throw an error (NCZ, 1/27/02)
        throw "Node is already collapsed"

    } else {
    
        //change the state of the node (NCZ, 1/27/02)
        this.expanded = false;
        
        //change the plus/minus image to be plus (NCZ, 1/27/02)
        document.images["imgPM_" + this.id].src = imgPlus.src;
        
        //hide the child nodes (NCZ, 1/27/02)
        document.getElementById("divChildren_" + this.id).style.display = "none";
    }
}


//-----------------------------------------------------------------
// Method jsTreeNode.expand()
//-----------------------------------------------------------------
// Author(s)
//  Nicholas C. Zakas (NCZ), 1/27/02
//
// Description
//  This method expands the jsTreeNode's children to be displayed.
//
// Parameters
//  (none)
//
// Returns
//  (nothing)
//-----------------------------------------------------------------
jsTreeNode.prototype.expand = function () {

    //check to see if the node is already expanded (NCZ, 1/27/02)
    if (this.expanded) {
    
        //throw an error (NCZ, 1/27/02)
        throw "Node is already expanded"
    
    } else {
    
        //change the state of the node (NCZ, 1/27/02)
        this.expanded = true;
        
        //change the plus/minus image to be minus (NCZ, 1/27/02)
        document.images["imgPM_" + this.id].src = imgMinus.src;
        
        //show the child nodes (NCZ, 1/27/02)
        document.getElementById("divChildren_" + this.id).style.display = "block";
    }
}
