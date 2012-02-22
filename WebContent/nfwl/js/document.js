//=================================================================
// JavaScript String Buffer
// Version 1.0
// by Nicholas C. Zakas, nicholas@nczonline.net
// Copyright (c) 2002 Nicholas C. Zakas.  All Rights Reserved.
//-----------------------------------------------------------------
// Browsers Supported:
//	* Netscape 6.0+
//  * Internet Explorer 5.0+
//  * Netscape Navigator 4.7x
//=================================================================
// History
//-----------------------------------------------------------------
// January 19, 2001  
//  - Released Version 1.0
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
//-----------------------------------------------------------------

//-----------------------------------------------------------------
// Object jsDocument
//
// jsDocument helps to speed up printing to the screen from Javascripts.
// Tests have shown that String concatenation (using +=) takes up some
// considerable time.  Many Javascripts create an output string by concatenating
// throughout the run, which eats up the clock.  In order to alleviate that,
// jsDocument stores data in an array, and then joins all array elements with one
// join command, making for much speedier processing.
//-----------------------------------------------------------------
function jsDocument() {
	this.text = new Array();		//array to store the string
	this.write = function (str) { this.text[this.text.length] = str; }
	this.writeln = function (str) { this.text[this.text.length] = str + "\n"; }
	this.toString = function () { return this.text.join(""); }
	this.clear = function () { delete this.text; this.text = null; this.text = new Array; }
}
