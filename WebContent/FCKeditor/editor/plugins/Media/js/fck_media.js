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
 * Scripts related to the Media dialog window (see fck_media.html).
 */

function Import(aSrc) {
   document.write('<scr'+'ipt type=\"text/javascript\" src=\"' + aSrc + '\"></sc' + 'ript>');
};

var oEditor		= window.parent.InnerDialogLoaded() ;
var FCK			= oEditor.FCK ;
var FCKLang		= oEditor.FCKLang ;
var FCKConfig	= oEditor.FCKConfig ;

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


//#### Dialog Tabs

// Set the dialog tabs.
window.parent.AddTab( 'Info', oEditor.FCKLang.DlgInfoTab ) ;

if ( FCKConfig.FlashUpload )
	window.parent.AddTab( 'Upload', FCKLang.DlgLnkUpload ) ;

if ( !FCKConfig.FlashDlgHideAdvanced )
	window.parent.AddTab( 'Advanced', oEditor.FCKLang.DlgAdvancedTag ) ;

// Function called when a dialog tag is selected.
function OnDialogTabChange( tabCode )
{
	ShowE('divInfo'		, ( tabCode == 'Info' ) ) ;
	ShowE('divUpload'	, ( tabCode == 'Upload' ) ) ;
	ShowE('divAdvanced'	, ( tabCode == 'Advanced' ) ) ;
}

// Get the selected media embed (if available).
var oFakeImage = FCK.Selection.GetSelectedElement() ;
var oEmbed ;

if ( oFakeImage )
{
	if ( oFakeImage.tagName == 'IMG' && oFakeImage.getAttribute('_fckmedia') )
		oEmbed = FCK.GetRealElement( oFakeImage ) ;
	else
		oFakeImage = null ;
}

window.onload = function()
{
	// Translate the dialog box texts.
	oEditor.FCKLanguageManager.TranslatePage(document) ;

	// Load the selected element information (if any).
	LoadSelection() ;

	// Show/Hide the "Browse Server" button.
	GetE('tdBrowse').style.display = FCKConfig.MediaBrowser	? '' : 'none' ;

	// Set the actual uploader URL.
	if ( FCKConfig.MediaUpload )
		GetE('frmUpload').action = FCKConfig.MediaUploadURL ;

	window.parent.SetAutoSize( true ) ;

	// Activate the "OK" button.
	window.parent.SetOkButton( true ) ;
}

function LoadSelection()
{
	if ( ! oEmbed ) return ;

	GetE('cmbMeidaPlayerType').value = GetMediaPlayerTypeId(GetAttribute( oEmbed, 'type', '')) ;
	//oEmbed = oEmbed.getElementById('fckMedia');
	GetE('txtUrl').value    = GetAttribute( oEmbed, 'src', '' ) ;
	GetE('txtWidth').value  = GetAttribute( oEmbed, 'width', '' ) ;
	GetE('txtHeight').value = GetAttribute( oEmbed, 'height', '' ) ;

	// Get Advances Attributes
	GetE('txtAttId').value		= oEmbed.id ;
	GetE('chkAutoPlay').checked	= GetAttribute( oEmbed, 'autostart', 'true' ) == 'true' ;
	GetE('chkLoop').checked		= GetAttribute( oEmbed, 'loop', 'true' ) == 'true' ;
	GetE('chkMenu').checked		= GetAttribute( oEmbed, 'menu', 'true' ) == 'true' ;
	GetE('cmbScale').value		= GetAttribute( oEmbed, 'scale', '' ).toLowerCase() ;

	GetE('txtAttTitle').value		= oEmbed.title ;

	if ( oEditor.FCKBrowserInfo.IsIE )
	{
		GetE('txtAttClasses').value = oEmbed.getAttribute('className') || '' ;
		GetE('txtAttStyle').value = oEmbed.style.cssText ;
	}
	else
	{
		GetE('txtAttClasses').value = oEmbed.getAttribute('class',2) || '' ;
		GetE('txtAttStyle').value = oEmbed.getAttribute('style',2) || '' ;
	}

	UpdatePreview() ;
}

//#### The OK button was hit.
function Ok()
{
	if ( GetE('txtUrl').value.length == 0 )
	{
		window.parent.SetSelectedTab( 'Info' ) ;
		GetE('txtUrl').focus() ;

		alert( oEditor.FCKLang.DlgAlertUrl ) ;

		return false ;
	}

	oEditor.FCKUndo.SaveUndoStep() ;
	if ( !oEmbed )
	{
		oEmbed		= FCK.EditorDocument.createElement( cFckMediaElementName ) ;
		oFakeImage  = null ;
	}
	UpdateEmbed( oEmbed ) ;

	if ( !oFakeImage )
	{
		oFakeImage	= oEditor.FCKDocumentProcessor_CreateFakeImage( 'FCK__Media_'+oEmbed.attributes[cMediaTypeAttrName].value, oEmbed ) ;
		oFakeImage.setAttribute( '_fckmedia', 'true', 0 ) ;
		oFakeImage	= FCK.InsertElement( oFakeImage ) ;
	}else {
	  oFakeImage.className = 'FCK__Media_'+oEmbed.attributes[cMediaTypeAttrName].value;
	}

	oEditor.FCKMediaProcessor.RefreshView( oFakeImage, oEmbed ) ;

	return true ;
}

function UpdateEmbed( e )
{
  var vMediaPlayerTypeId = parseInt(GetE('cmbMeidaPlayerType' ).value);
  var vParam;

  vMediaPlayerTypeId = (vMediaPlayerTypeId==NaN) ? cDefaultMediaPlayer : vMediaPlayerTypeId;
	SetAttribute( e, cMediaTypeAttrName			, vMediaPlayerTypeId );

	SetAttribute( e, 'type'			, cMediaPlayerTypes[vMediaPlayerTypeId] );
	SetAttribute( e, 'pluginspage'	, cMediaPlayerCodebase[vMediaPlayerTypeId] ) ;

	SetAttribute( e, 'src', GetE('txtUrl').value ) ;
	SetAttribute( e, "width" , GetE('txtWidth').value ) ;
	SetAttribute( e, "height", GetE('txtHeight').value ) ;

	// Advances Attributes

	SetAttribute( e, 'id'	, GetE('txtAttId').value ) ;
	SetAttribute( e, 'scale', GetE('cmbScale').value ) ;

	SetAttribute( e, 'autostart', GetE('chkAutoPlay').checked ? 'true' : 'false' ) ;
	SetAttribute( e, 'loop', GetE('chkLoop').checked ? 'true' : 'false' ) ;
	SetAttribute( e, 'menu', GetE('chkMenu').checked ? 'true' : 'false' ) ;

	SetAttribute( e, 'title'	, GetE('txtAttTitle').value ) ;

	if ( oEditor.FCKBrowserInfo.IsIE )
	{
		SetAttribute( e, 'className', GetE('txtAttClasses').value ) ;
		e.style.cssText = GetE('txtAttStyle').value ;
	}
	else
	{
		SetAttribute( e, 'class', GetE('txtAttClasses').value ) ;
		SetAttribute( e, 'style', GetE('txtAttStyle').value ) ;
	}
}

var ePreview ;

function SetPreviewElement( previewEl )
{
	ePreview = previewEl ;

	if ( GetE('txtUrl').value.length > 0 )
		UpdatePreview() ;
}

function UpdatePreview()
{
	if ( !ePreview )
		return ;

	while ( ePreview.firstChild )
		ePreview.removeChild( ePreview.firstChild ) ;

	if ( GetE('txtUrl').value.length == 0 )
		ePreview.innerHTML = '&nbsp;' ;
	else
	{
		var oDoc	= ePreview.ownerDocument || ePreview.document ;
		var e		= oDoc.createElement( 'EMBED' ) ;
    var vMediaPlayerTypeId = parseInt(GetE('cmbMeidaPlayerType').value);
    vMediaPlayerTypeId = (vMediaPlayerTypeId==NaN) ? cDefaultMediaPlayer : vMediaPlayerTypeId;

		SetAttribute( e, 'src', GetE('txtUrl').value ) ;
		SetAttribute( e, cMediaTypeAttrName, vMediaPlayerTypeId);
		SetAttribute( e, 'type', cMediaPlayerTypes[vMediaPlayerTypeId] ) ;
		SetAttribute( e, 'width', '100%' ) ;
		SetAttribute( e, 'height', '100%' ) ;

		ePreview.appendChild( e ) ;

		//e.innerHTML = WrapObjectToMedia(e.innerHTML, 'embed') ; //IE can not support!
		ePreview.innerHTML = WrapObjectToMedia(ePreview.innerHTML, 'embed'); 

	}
}

// <embed id="ePreview" src="fck_flash/claims.swf" width="100%" height="100%" style="visibility:hidden" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer">

function BrowseServer()
{
	OpenFileBrowser( FCKConfig.MediaBrowserURL, FCKConfig.MediaBrowserWindowWidth, FCKConfig.MediaBrowserWindowHeight ) ;
}

function SetUrl( url, width, height )
{
	GetE('txtUrl').value = url ;

	if ( width )
		GetE('txtWidth').value = width ;

	if ( height )
		GetE('txtHeight').value = height ;

	UpdatePreview() ;

	window.parent.SetSelectedTab( 'Info' ) ;
}

function OnUploadCompleted( errorNumber, fileUrl, fileName, customMsg )
{
	switch ( errorNumber )
	{
		case 0 :	// No errors
			alert( 'Your file has been successfully uploaded' ) ;
			break ;
		case 1 :	// Custom error
			alert( customMsg ) ;
			return ;
		case 101 :	// Custom warning
			alert( customMsg ) ;
			break ;
		case 201 :
			alert( 'A file with the same name is already available. The uploaded file has been renamed to "' + fileName + '"' ) ;
			break ;
		case 202 :
			alert( 'Invalid file type' ) ;
			return ;
		case 203 :
			alert( "Security error. You probably don't have enough permissions to upload. Please check your server." ) ;
			return ;
		default :
			alert( 'Error on file upload. Error number: ' + errorNumber ) ;
			return ;
	}

	SetUrl( fileUrl ) ;
	GetE('frmUpload').reset() ;
}

var oUploadAllowedExtRegex	= new RegExp( FCKConfig.MediaUploadAllowedExtensions, 'i' ) ;
var oUploadDeniedExtRegex	= new RegExp( FCKConfig.MediaUploadDeniedExtensions, 'i' ) ;

function CheckUpload()
{
	var sFile = GetE('txtUploadFile').value ;

	if ( sFile.length == 0 )
	{
		alert( 'Please select a file to upload' ) ;
		return false ;
	}

	if ( ( FCKConfig.MediaUploadAllowedExtensions.length > 0 && !oUploadAllowedExtRegex.test( sFile ) ) ||
		( FCKConfig.MediaUploadDeniedExtensions.length > 0 && oUploadDeniedExtRegex.test( sFile ) ) )
	{
		OnUploadCompleted( 202 ) ;
		return false ;
	}

	return true ;
}
