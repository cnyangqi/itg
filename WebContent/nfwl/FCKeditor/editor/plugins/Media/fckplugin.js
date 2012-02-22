/*
 * Media Plugin for FCKeditor 2.5 SVN
 * Copyright (C) 2007 Riceball LEE (riceballl@hotmail.com)
 *
 * == BEGIN LICENSE ==
 *
 * Licensed under the terms of any of the following licenses at your
 * choice:
 *
 *  - GNU General Public License Version 2 or later (the "GPL")
 *    http://www.gnu.org/licenses/gpl.html
 *
 *  - GNU Lesser General Public License Version 2.1 or later (the "LGPL")
 *    http://www.gnu.org/licenses/lgpl.html
 *
 *  - Mozilla Public License Version 1.1 or later (the "MPL")
 *    http://www.mozilla.org/MPL/MPL-1.1.html
 *
 * == END LICENSE ==
 *
 * Plugin to insert "Media" in the editor.
 */

var
  cWindowMediaPlayer = 0
  , cRealMediaPlayer = 1
  , cQuickTimePlayer = 2
  , cFlashPlayer = 3
  , cShockwavePlayer = 4
  , cDefaultMediaPlayer = cWindowMediaPlayer
  ;

var cFckMediaElementName = 'fckmedia'; //embed | object | fckmedia
var cMediaTypeAttrName = 'mediatype';  //lowerCase only!!

var cWMp6Compatible = false;

//const cDefaultMediaPlayer = 0; //!!!DO NOT Use the constant! the IE do not support const!

var
    cMediaPlayerTypes = ['application/x-mplayer2', 'audio/x-pn-realaudio-plugin', 'video/quicktime', 'application/x-shockwave-flash', 'application/x-director']
  , cMediaPlayerClassId = [cWMp6Compatible? 'clsid:05589FA1-C356-11CE-BF01-00AA0055595A' : 'clsid:6BF52A52-394A-11D3-B153-00C04F79FAA6', 'clsid:CFCDAA03-8BE4-11cf-B84B-0020AFBBCCFA'
        , 'clsid:02BF25D5-8C17-4B23-BC80-D3488ABDDC6B', 'clsid:D27CDB6E-AE6D-11cf-96B8-444553540000'
        , 'clsid:166B1BCA-3F9C-11CF-8075-444553540000'
    ]
  , cMediaPlayerCodebase = ['http://microsoft.com/windows/mediaplayer/en/download/', 'http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab'
        , 'http://www.apple.com/quicktime/download/', 'http://www.macromedia.com/go/getflashplayer', 'http://download.macromedia.com/pub/shockwave/cabs/director/sw.cab'
    ]
  ;

var
  cFCKMediaObjectAttrs = {width:1, height:1, align:1, id:1, name:1, 'class':1, className:1, style:1, title:1}; //the 'class' is keyword in IE!!
  //there are not object params in it.
  cFCKMediaSkipParams = {pluginspage:1, type:1}; 

var
  oWindowMediaPlayer = {id: cWindowMediaPlayer, type: cMediaPlayerTypes[cWindowMediaPlayer], ClsId: cMediaPlayerClassId[cWindowMediaPlayer], Codebase: cMediaPlayerCodebase[cWindowMediaPlayer]
    , Params: {autostart:true, enabled:true, enablecontextmenu:true, fullscreen:false, invokeurls:true, mute:false
        , stretchtofit:false, windowlessvideo:false, balance:'', baseurl:'', captioningid:'', currentmarker:''
        , currentposition:'', defaultframe:'', playcount:'', rate:'', uimode:'', volume:''
      }
  };
  oRealMediaPlayer = {id: cRealMediaPlayer, type: cMediaPlayerTypes[cRealMediaPlayer], ClsId: cMediaPlayerClassId[cRealMediaPlayer], Codebase: cMediaPlayerCodebase[cRealMediaPlayer]
    , Params: {autostart:true, loop:false, autogotourl:true, center:false, imagestatus:true, maintainaspect:false
        , nojava:false, prefetch:true, shuffle:false, console:'', controls:'', numloop:'', scriptcallbacks:''
      }
  };
  oQuickTimePlayer = {id: cQuickTimePlayer, type: cMediaPlayerTypes[cQuickTimePlayer], ClsId: cMediaPlayerClassId[cQuickTimePlayer], Codebase: cMediaPlayerCodebase[cQuickTimePlayer]
    , Params: {autoplay:true, loop:false, cache:false, controller:true, correction:['none', 'full'], enablejavascript:false
        , kioskmode:false, autohref:false, playeveryframe:false, targetcache:false, scale:'', starttime:'', endtime:'', target:'', qtsrcchokespeed:''
        , volume:'', qtsrc:''
      }
  };
  oFlashPlayer = {id: cFlashPlayer, type: cMediaPlayerTypes[cFlashPlayer], ClsId: cMediaPlayerClassId[cFlashPlayer], Codebase: cMediaPlayerCodebase[cFlashPlayer]
    , Params: {play:true, loop:false, menu:true, swliveconnect:true, quality:'', scale:'', salign:'', wmode:'', base:''
        , flashvars:''
      }
  };
  oShockwavePlayer = {id: cShockwavePlayer, type: cMediaPlayerTypes[cShockwavePlayer], ClsId: cMediaPlayerClassId[cShockwavePlayer], Codebase: cMediaPlayerCodebase[cShockwavePlayer]
    , Params: {autostart:true, sound:true, progress:false, swliveconnect:false, swvolume:'', swstretchstyle:'', swstretchhalign:'', swstretchvalign:''
      }
  };

var
  oFCKMediaPlayers = [oWindowMediaPlayer, oRealMediaPlayer, oQuickTimePlayer, oFlashPlayer, oShockwavePlayer];

String.prototype.trim = function() {
	return this.replace(/^\s+|\s+$/g,"");
}
String.prototype.ltrim = function() {
	return this.replace(/^\s+/,"");
}
String.prototype.rtrim = function() {
	return this.replace(/\s+$/,"");
}

function debugListMember(o) {
  var s = '\n';
  if (typeof(o) == 'object') 
    s +=o.toSource();
  else
    s+= o;
  return s;
}

function GetMediaPlayerTypeId(aMediaType) {
  for (i = 0; i < cMediaPlayerTypes.length; i++ )
    if (aMediaType.toLowerCase() == cMediaPlayerTypes[i]) return i;
  return cDefaultMediaPlayer;
}

function isInt(aStr) {
  var i = parseInt(aStr);
  if (isNaN(i)) return false;
  i = i.toString();
  return (i == aStr);
}

function DequotedStr(aStr) {
  aStr = aStr.trim();
  //aStr.replace(/^(['"])(.*?)(\1)$/g, '$2');
  if (aStr.length > 2) {
    if (aStr.charAt(0) == '"' && aStr.charAt(aStr.length-1) == '"' )
      aStr = aStr.substring(1,aStr.length-1);
    else if (aStrcharAt(0) == '\'' && aStr.charAt(aStr.length-1) == '\'' )
      aStr = aStr.substring(1,aStr.length-1);
  }
  //alert(aStr+ ': dd:'+aStr.charAt(0)+ aStr.charAt(aStr.length-1));
  return aStr;
}

function WrapObjectToMedia(html, aMediaElementName) {
  //check media first
  function _ConvertMedia( m, params )
  {
    //split params to array
    m = params;
    var params  = params.match(/[\s]*(.+?)=['"](.*?)['"][\s]*/gi);
    var vObjectAttrs = '';
    var Result = '';
    var vParamName, vParamValue;
    var vIsMedia = false;
    for (var i = 0; i < params.length; i++) {
      vPos = params[i].indexOf('=');
      vParamName = params[i].substring(0, vPos).trim();
      vParamName = vParamName.toLowerCase();
      vParamValue = params[i].substring(vPos+1);
      vParamValue = DequotedStr(vParamValue);
      if (vParamName == cMediaTypeAttrName) {
        //alert(vParamName+':'+vParamValue);
        if (isInt(vParamValue)) {
          vIsMedia = true;
          vObjectAttrs += ' '+ cMediaTypeAttrName + '="' + vParamValue + '"';
          vObjectAttrs += ' classid="' +  oFCKMediaPlayers[vParamValue].ClsId + '"';
          vObjectAttrs += ' codebase="' +  oFCKMediaPlayers[vParamValue].Codebase + '"';
        }else {
          break;
        }
      } else if (cFCKMediaObjectAttrs[vParamName]) {
        vObjectAttrs += ' ' + vParamName + '="' + vParamValue + '"';
      } else if (!cFCKMediaSkipParams[vParamName]) {
        Result += '<param name="' + vParamName + '" value="' + vParamValue + '"/>';
      }
    } //for
    //wrap the <object> tag to <embed>
    if (vIsMedia) {
      Result = '<object' + vObjectAttrs + '>' + Result + '<embed' + m + '></embed></object>';
      //alert(Result);
      return Result;
    }
  }

  if (aMediaElementName == '') aMediaElementName = cFckMediaElementName;
  var regexMedia = new RegExp( '<'+aMediaElementName+'(.+?)><\/'+aMediaElementName+'>', 'gi' );
  //var regexMedia = /<fckMedia\s+(.+?)><\/fckMedia>/gi;
  //alert('b:'+html);
  return html.replace( regexMedia, _ConvertMedia ) ;
}


// Register the related command.
FCKCommands.RegisterCommand( 'Media', new FCKDialogCommand( 'Media', FCKLang.DlgMediaTitle, FCKPlugins.Items['Media'].Path + 'fck_media.html', 450, 428 ) ) ;

// Create the "Media" toolbar button.
var oMediaItem = new FCKToolbarButton( 'Media', FCKLang.MediaBtn,  FCKLang.MediaBtnTooltip) ;
oMediaItem.IconPath = FCKPlugins.Items['Media'].Path + 'images/media.gif' ;

FCKToolbarItems.RegisterItem( 'Media', oMediaItem ) ;

//--------------------------------------------------
function _Import(aSrc) {
   //document.write('<scr'+'ipt type=\"text/javascript\" src=\"' + aSrc + '\"></sc' + 'ript>');

  var vElement = document.createElement("script");
  vElement.type= "text/javascript";
  vElement.src= aSrc;

  var head=document.getElementsByTagName("head")[0];
  head.appendChild(vElement);

};

function _ImportCSS(aSrc) {
  var vElement = document.createElement("link");
  vElement.rel   = "stylesheet";
  vElement.type  = "text/css";
  vElement.href  = aSrc;
  //vElement.title= 'ddd';
  //vElement.disabled=false;

  var head=document.getElementsByTagName("head")[0];
  head.appendChild(vElement);
};

//_Import(FCKConfig.PluginsPath + 'media/js/fck_media_inc.js');


var FCKMediaProcessor = FCKDocumentProcessor.AppendNew() ;

//hack to add the media css to FCKEditingArea.
FCKMediaProcessor.EditingArea_StartBefore = function ( html, secondCall )
{
  var sHeadExtra = '<link href="' + FCKConfig.PluginsPath + 'media/css/fck_media.css" rel="stylesheet" type="text/css" _fcktemp="true" />' ;
  html = html.replace( FCKRegexLib.HeadCloser, sHeadExtra + '$&' ) ;
  return arguments;
}
FCKEditingArea.prototype.Start =  Inject(FCKEditingArea.prototype.Start, FCKMediaProcessor.EditingArea_StartBefore);

//hack and rewrite FCKConfig.ProtectedSource.Protect, for i do not wanna walk through twice.
FCKConfig.ProtectedSource.Protect = function( html )
{
  var codeTag = this._CodeTag ;
  function _Replace( protectedSource )
  {
    //check if it is the media object:
    if (protectedSource.match(/<object[\s\S]+?<\/object>/gi) && (protectedSource.indexOf(cMediaTypeAttrName+'=') >=0)) {
      var regexEmbed = new RegExp('<embed\\s+(.+?)><\/embed>', 'i');
      return '<'+cFckMediaElementName + ' '+ protectedSource.match(regexEmbed)[1] + '></'+cFckMediaElementName+'>';
    }

    var index = FCKTempBin.AddElement( protectedSource ) ;
    return '<!--{' + codeTag + index + '}-->' ;

  }

  for ( var i = 0 ; i < this.RegexEntries.length ; i++ )
  {
    html = html.replace( this.RegexEntries[i], _Replace ) ;
  }

  return html ;
}

//hacked FCKConfig.ProtectedSource.Revert
FCKMediaProcessor.ProtectedSource_RevertBefore = function ( html, clearBin )
{
  html = WrapObjectToMedia(html, cFckMediaElementName);
  return arguments;
}
FCKConfig.ProtectedSource.Revert = Inject(FCKConfig.ProtectedSource.Revert, FCKMediaProcessor.ProtectedSource_RevertBefore)

FCKMediaProcessor.ProcessDocument = function( aDocument )
{
  /* convert the source to WSWG design
  Sample code:
  This is some <embed src="/UserFiles/Flash/Yellow_Runners.swf" mediatype="0"></embed><strong>sample text</strong>. You are&nbsp;<a name="fred"></a> using <a href="http://www.fckeditor.net/">FCKeditor</a>.
  */

  var aEmbeds = aDocument.getElementsByTagName( cFckMediaElementName ) ;

  var oEmbed ;
  var i = aEmbeds.length - 1 ;

  while ( i >= 0 && ( oEmbed = aEmbeds[i--] ) )
  {
    if (typeof(oEmbed.attributes[ cMediaTypeAttrName ]) != 'undefined') {

      var vTypeId = oEmbed.attributes[ cMediaTypeAttrName ].value ;
  
      if (isInt(vTypeId))
      {
        var oCloned = oEmbed.cloneNode( true ) ;
  
        var oImg = FCKDocumentProcessor_CreateFakeImage( 'FCK__Media_'+vTypeId, oCloned ) ;
        oImg.setAttribute( '_fckmedia', 'true', 0 ) ;
  
        FCKMediaProcessor.RefreshView( oImg, oEmbed ) ;
  
        oEmbed.parentNode.replaceChild(oImg, oEmbed);
      }
    }
  }
}

FCKMediaProcessor.RefreshView = function( placeHolderImage, originalEmbed )
{

  if ( originalEmbed.getAttribute( 'width' ) > 0 )
    placeHolderImage.style.width = FCKTools.ConvertHtmlSizeToStyle( originalEmbed.getAttribute( 'width' ) ) ;

  if ( originalEmbed.getAttribute( 'height' ) > 0 )
    placeHolderImage.style.height = FCKTools.ConvertHtmlSizeToStyle( originalEmbed.getAttribute( 'height' ) ) ;
}

// Open the Media Properties dialog on double click.
FCKMediaProcessor.OnDoubleClick = function( e )
{
  if ( e.tagName == 'IMG' && e.getAttribute('_fckmedia') == 'true' )
    FCKCommands.GetCommand( 'Media' ).Execute() ;
}

FCK.RegisterDoubleClickHandler( FCKMediaProcessor.OnDoubleClick, 'IMG' ) ;


FCK.ContextMenu.RegisterListener( {
        AddItems : function( menu, tag, tagName )
        {
                // under what circumstances do we display this option
                if ( tagName == 'IMG' && tag.getAttribute( '_fckmedia' ) )
                {
                        // when the option is displayed, show a separator  the command
                        menu.AddSeparator() ;
                        // the command needs the registered command name, the title for the context menu, and the icon path
                        menu.AddItem( 'Media', FCKLang.DlgMediaTitle, oMediaItem.IconPath ) ;
                }
        }}
);


FCKMediaProcessor.GetRealElementAfter = function( fakeElement, Result ) 
{
  if ( fakeElement.getAttribute('_fckmedia') )
  {
    if ( fakeElement.style.width.length > 0 )
        Result.width = FCKTools.ConvertStyleSizeToHtml( fakeElement.style.width ) ;

    if ( fakeElement.style.height.length > 0 )
        Result.height = FCKTools.ConvertStyleSizeToHtml( fakeElement.style.height ) ;
  }

  return Result ;
}
FCK.GetRealElement = Inject(FCK.GetRealElement, undefined, FCKMediaProcessor.GetRealElementAfter)

/*
  @desc  inject the function
  @param aOrgFunc     the original function to be injected.
  @param aBeforeExec  this is called before the execution of the aOrgFunc.
                      you must return the arguments if you wanna modify the value of the aOrgFunc's arguments .
  @param aAtferExec   this is called after the execution of the aOrgFunc.
                      you must add a result argument at the last argument of the aAtferExec function if you wanna 
                      get the result value of the aOrgFunc.
                      you must return the result if you wanna modify the result value of the aOrgFunc .

  @Usage  Obj.prototype.aMethod = Inject(Obj.prototype.aMethod, aFunctionBeforeExec[, aFunctionAtferExec]);
  @author  Aimingoo&Riceball

  eg:
  var doTest = function (a) {return a};
  function beforeTest(a) { alert('before exec: a='+a); a += 3; return arguments;};
  function afterTest(a, result) { alert('after exec: a='+a+'; result='+result); return result+5;};
  
  doTest = Inject(doTest, beforeTest, afterTest);
  
  alert (doTest(2));
  the result should be 10.

*/
function Inject( aOrgFunc, aBeforeExec, aAtferExec ) {
  return function() {
    if (typeof(aBeforeExec) == 'function') arguments = aBeforeExec.apply(this, arguments) || arguments;
    //convert arguments object to array
    var Result, args = [].slice.call(arguments); 
    args.push(aOrgFunc.apply(this, args));
    if (typeof(aAtferExec) == 'function') Result = aAtferExec.apply(this, args);
    return (typeof(Result) != 'undefined')?Result:args.pop();
  }
}
