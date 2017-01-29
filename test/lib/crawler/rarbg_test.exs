defmodule Magnetissimo.Crawler.RarbgTest do
  use ExUnit.Case, async: true

  test "scrapes torrent detail links from a page" do
    torrent_links = Magnetissimo.Crawler.Rarbg.torrent_links(list_sample)
    assert Enum.count(torrent_links) == 28
  end

  test "scrapes torrent information from a torrent detail page" do
    torrent = Magnetissimo.Crawler.Rarbg.torrent_information(detail_sample)
    IO.inspect torrent
    assert torrent != nil
  end

  def list_sample do
    """
    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> <html xmlns="http://www.w3.org/1999/xhtml"><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8" /><meta name="robots" content="index,follow" /><meta name="description" content="Torrents , movies , download , music , games , free , RARBG Torrents , filmi , download" /><meta name="keywords" content="Torrents , filmi , download, RARBG Torrents , filmi , download" /><title>RARBG Torrents , filmi , download</title><meta name="robots" content="all" /><meta name="revisit" content="1 day" /><meta http-equiv="pragma" content="no-cache" /><meta http-equiv="expires" content="0" /><meta http-equiv="cache-control" content="no-cache" /><link rel="alternate" type="application/rss+xml" title="RARBG Latest Torrents" href="https://rarbg.to/rss.php" /><link rel="alternate" type="application/rss+xml" title="RARBG Direct Download" href="https://rarbg.to/rssdd.php" /><link rel="search" type="application/opensearchdescription+xml" title="Rarbg torrents" href="/opensearch.xml2" /><link rel="stylesheet" href="//dyncdn.me/static/20/css/styles_v33.css" type="text/css" media="all" />
    </head><body>
    <div id="overlib"></div>
    <!--[if IE 8]><script type="text/javascript">var isIE8 = true;</script><![endif]-->
    <script type="text/javascript" src="//dyncdn.me/static/20/js/jquery-1.11.3.min.js"></script>
    <script type="text/javascript">var pop=document.getElementById("overlib");var xoffset=15;var yoffset=10;var el="";document.onmousemove=function(k){var h,j,m,e,l;if(typeof(isIE8)!="undefined"){h=window.event.x;j=window.event.y;el=window.event.target||window.event.srcElement}else{try{h=k.pageX;j=k.pageY;el=k.target||k.srcElement}catch(k){h=window.event.x;j=window.event.y;h+=document.documentElement.scrollLeft;j+=document.documentElement.scrollTop;el=window.event.target||window.event.srcElement}}h+=xoffset;j+=yoffset;pop.style.top=j+"px";pop.style.left=h+"px"};function overlib(b){pop.innerHTML=b;pop.style.display="block";deAlt(el)}function deAlt(){if(el){if(el.alt){el.alt=""}if(el.title){el.title=""}aKid=el.childNodes||el.children||null;if(aKid){for(var a=0;a<aKid.length;a++){el=aKid[a];deAlt()}}}}function nd(){pop.style.display="none"}function addPlugin(){window.external.AddSearchProvider("https://rarbg.to/plugins/ff.xml")}function addPluginIE(){var l="RARBG.TO";var g="https://rarbg.to/torrents.php?search=TEST";l=l.replace(/^\s+|\s+$/g,"");g=g.replace(/^\s+|\s+$/g,"");var h="UTF-8";if(g.length<1){alert("Please enter the URL of the search results page.");document.getElementById("sURI").focus();return false}if(g.indexOf("TEST")<0){alert("The search results URL must contain the word TEST.  Please check the URL.\nIt's possible that this tool cannot be used to build a query for that search engine.");document.getElementById("sURI").focus();return false}if(l.length<1){alert("Please enter a NAME for the new search provider");document.getElementById("sName").focus();return false}var k="Encoding="+encodeURIComponent(h)+"&Name="+encodeURIComponent(l)+"&URI="+encodeURIComponent(g);var j="http://www.microsoft.com/windows/ie/searchguide/spbuilder.mspx?"+k;try{window.external.AddSearchProvider(j)}catch(m){if(70==(m.number&65535)){alert("For security reasons, you must use the mouse\n(or the Enter key) to click the Install button.")}else{alert("Unable to add search provider. The Create Your\nOwn tool requires Internet Explorer 7.   ["+(m.number&65535)+"]")}}return false}var BrowserDetect={init:function(){this.browser=this.searchString(this.dataBrowser)||"An unknown browser";this.version=this.searchVersion(navigator.userAgent)||this.searchVersion(navigator.appVersion)||"an unknown version";this.OS=this.searchString(this.dataOS)||"an unknown OS"},searchString:function(g){for(var f=0;f<g.length;f++){var e=g[f].string;var h=g[f].prop;this.versionSearchString=g[f].versionSearch||g[f].identity;if(e){if(e.indexOf(g[f].subString)!=-1){return g[f].identity}}else{if(h){return g[f].identity}}}},searchVersion:function(c){var d=c.indexOf(this.versionSearchString);if(d==-1){return}return parseFloat(c.substring(d+this.versionSearchString.length+1))},dataBrowser:[{string:navigator.userAgent,subString:"OmniWeb",versionSearch:"OmniWeb/",identity:"OmniWeb"},{string:navigator.vendor,subString:"Apple",identity:"Safari"},{prop:window.opera,identity:"Opera"},{string:navigator.vendor,subString:"iCab",identity:"iCab"},{string:navigator.vendor,subString:"KDE",identity:"Konqueror"},{string:navigator.userAgent,subString:"Firefox",identity:"Firefox"},{string:navigator.vendor,subString:"Camino",identity:"Camino"},{string:navigator.userAgent,subString:"Netscape",identity:"Netscape"},{string:navigator.userAgent,subString:"MSIE",identity:"Explorer",versionSearch:"MSIE"},{string:navigator.userAgent,subString:"Gecko",identity:"Mozilla",versionSearch:"rv"},{string:navigator.userAgent,subString:"Mozilla",identity:"Netscape",versionSearch:"Mozilla"}],dataOS:[{string:navigator.platform,subString:"Win",identity:"Windows"},{string:navigator.platform,subString:"Mac",identity:"Mac"},{string:navigator.platform,subString:"Linux",identity:"Linux"}]};BrowserDetect.init();function addsearchplugin(){if(BrowserDetect.browser=="Firefox"){addPlugin()}else{if(BrowserDetect.browser=="Explorer"&&BrowserDetect.version==7){addPluginIE()}}}function Bookmark(){var f="RARBG.to";var d="https://rarbg.to";if(window.sidebar){window.sidebar.addPanel(f,d,"")}else{if(window.opera&&window.print){var e=document.createElement("a");e.setAttribute("rel","sidebar");e.setAttribute("href",d);e.setAttribute("title",f);e.click()}else{if(document.all){window.external.AddFavorite(d,f)}}}}if (window != top) top.location.href = location.href;</script>
    <table width="90%" align="center"><tr>
    <td width="10%">
    <a href="/torrents.php" title="Rarbg torrents"><img src="//dyncdn.me/static/20/img/logo_dark_nodomain2_optimized.png" border="0" alt="rarbg torrents" style="margin: 15px 0 0 0;" /></a>
    </td>
    <td width="50%" align="center">

    <script type="text/javascript">function clickclear(thisfield, defaulttext) {if (thisfield.value == defaulttext) {thisfield.value = "";}}function clickrecall(thisfield, defaulttext) {if (thisfield.value == "") {thisfield.value = defaulttext;}}</script>
    	<form action="/login" name="login" method="post" style="position:relative;">
        <table width="100%" border="0" cellpadding="2" cellspacing="0">
    		<tr>
    			<td class="lista" align="left">
    				<table border="0" cellpadding="5" cellspacing="0">
    					<tr>
    						<td class="lista"><input type="text" size="22" name="uid" id="uid" value="User" maxlength="40" style="font-size:12px" onclick="clickclear(this, 'User')" onblur="clickrecall(this,'User')" /></td>
    						<td class="lista"><input type="password" size="22" name="pwd" id="pwd" autocomplete="off" maxlength="40" style="font-size:12px" value="Password" onclick="clickclear(this, 'Password')" onblur="clickrecall(this,'Password')" /></td>
    						<td class="lista" align="center"><input type="submit" value="Login" style="font-size:12px" class="pftext" /></td>
    						<td class="lista">
    					<a href="//dyncdn.me/static/20/searches/rarbg.btsearch"><img src="//dyncdn.me/static/20/img/utorrent3.png" border="0" alt="" /></a> <a onclick="Bookmark()"><img src="//dyncdn.me/static/20/img/bookmark2.png" border="0" alt="" /></a> <a onclick="addsearchplugin()"><img src="//dyncdn.me/static/20/img/ff2.png" border="0" alt="" /></a> 					</td>
    					</tr></table>
    					</td></tr></table>


        </form>
    	</td>

    	<td width="40%" align="right">
    	</td>
        </tr>
        </table>

    <table width="90%" border="0" align="center"><tr>
    <td colspan="2">
    <table class="lista3" width="99%" align="center" style="padding: 20px 0 0 0;">
    <tr>
    <td class="header"></td><td class="header4" align="center">&nbsp; Guest <a class="anal" href="/login">(Login)</a></td><td class="header3 selected" align="center"><a class="anal tdlinkfull1" href="/torrents.php">Torrents</a></td><td class="header3" align="center"><a class="anal tdlinkfull1" href="/chart.php">Box office</a></td><td class="header3" align="center"><a class="anal tdlinkfull1" href="/catalog/">Catalog</a></td><td class="header3" align="center"><a class="anal tdlinkfull1" href="/top10">Top 10</a></td><td class="header3" align="center"><a class="anal tdlinkfull1" href="/viewnews">News</a></td></tr>
    </table>

    </td></tr></table><table width="90%" align="center" border="0" style="margin: -8px auto 0;"><tr>
    <td width="100" valign="top" align="left">
    <br />
    <table width="100%" cellpadding="0" cellspacing="2" style="margin: 0 0 0 5px;"><tr><td class="header5" align="left"><a class="anal tdlinkfull2" href="/torrents.php">View all</a></td></tr><tr><td class="header5" align="left"><a class="anal tdlinkfull2" href="/torrents.php?category=movies">Movies</a></td></tr><tr><td class="header5" align="left"><a class="anal tdlinkfull2" href="/torrents.php?category=1;4">XXX</a></td></tr><tr><td class="header5" align="left"><a class="anal tdlinkfull2" href="/torrents.php?category=1;18;41">TV Shows</a></td></tr><tr><td class="header5" align="left"><a class="anal tdlinkfull2" href="/torrents.php?category=1;27;28;29;30;31;32;40">Games</a></td></tr><tr><td class="header5" align="left"><a class="anal tdlinkfull2" href="/torrents.php?category=1;23;24;25;26">Music</a></td></tr><tr><td class="header5" align="left"><a class="anal tdlinkfull2" href="/torrents.php?category=1;33;34;43">Software</a></td></tr><tr><td class="header5" align="left"><a class="anal tdlinkfull2" href="/torrents.php?category=1;14;15;16;17;21;22;42;18;19;41;27;28;29;30;31;32;40;23;24;25;26;33;34;43;44;45;46;47;48">Non XXX</a></td></tr><tr><td align="left">&nbsp;<br/></td></tr><tr><td class="header5" align="left"><a class="anal tdlinkfull2" href="/trailers.php">Trailers</a></td></tr><tr><td class="header5" align="left"><a class="anal tdlinkfull2" href="/catalog/">Catalog</a></td></tr><tr><td class="header5" align="left"><a class="anal tdlinkfull2" href="/chart.php">Box Office</a></td></tr><tr><td align="left">&nbsp;<br/></td></tr><tr><td class="header5" align="left"><a class="anal tdlinkfull2" href="/index8.php" title="rarbg">New index</a></td></tr><tr><td align="left">&nbsp;<br/></td></tr></table></td>
     <td valign="top">



    <div class="content-rounded"><table class="lista-rounded" style="height:480px;" cellpadding="0" cellspacing="0" width="100%" align="center"><tr><td class="block" align="center" colspan="1" valign="top"><b>Recommended torrents :</b></td></tr><tr><td width="100%" align="justify" valign="top"><div align="center">
    <table><tr><td align="left" class="lista" valign="top"><a title="Lion.2016.DVDScr.XVID.AC3.HQ.Hive-CM8" onmouseover="return overlib('Lion.2016.DVDScr.XVID.AC3.HQ.Hive-CM8')" onmouseout="return nd();" href="/torrent/i1yam7e"><img src="//dyncdn.me/static/over/1336e5de0169c334019044e6937cb852ed5d15c3.jpg?c=6" border="0" alt="Lion.2016.DVDScr.XVID.AC3.HQ.Hive-CM8" /></a></td><td align="left" class="lista" valign="top"><a title="Edge.of.Seventeen.2016.DVDScr.XVID.AC3.HQ.Hive-CM8" onmouseover="return overlib('Edge.of.Seventeen.2016.DVDScr.XVID.AC3.HQ.Hive-CM8')" onmouseout="return nd();" href="/torrent/smh6xvu"><img src="//dyncdn.me/static/over/d26914cd44ca55da87f495f49a5df7c1e3c06af5.jpg?c=3" border="0" alt="Edge.of.Seventeen.2016.DVDScr.XVID.AC3.HQ.Hive-CM8" /></a></td><td align="left" class="lista" valign="top"><a title="Billy.Lynns.Long.Halftime.Walk.2016.1080p.BluRay.x264-GECKOS" onmouseover="return overlib('Billy.Lynns.Long.Halftime.Walk.2016.1080p.BluRay.x264-GECKOS')" onmouseout="return nd();" href="/torrent/9zr4qgs"><img src="//dyncdn.me/static/over/1a00fb0f9bc6320ffdd7a1704e7f76606c2872d3.jpg?c=2" border="0" alt="Billy.Lynns.Long.Halftime.Walk.2016.1080p.BluRay.x264-GECKOS" /></a></td><td align="left" class="lista" valign="top"><a title="iBoy.2017.1080p.NF.WEBRip.DD5.1.x264-SB" onmouseover="return overlib('iBoy.2017.1080p.NF.WEBRip.DD5.1.x264-SB')" onmouseout="return nd();" href="/torrent/kcvhjlw"><img src="//dyncdn.me/static/over/8a92756984c68ebd26eec67ebccfb44b7ba979c9.jpg?c=3" border="0" alt="iBoy.2017.1080p.NF.WEBRip.DD5.1.x264-SB" /></a></td><td align="left" class="lista" valign="top"><a title="A.Monster.Calls.2016.1080p.WEB-DL.AAC2.0.H264-FGT" onmouseover="return overlib('A.Monster.Calls.2016.1080p.WEB-DL.AAC2.0.H264-FGT')" onmouseout="return nd();" href="/torrent/69qnvhd"><img src="//dyncdn.me/static/over/ced6aed12d3a7393dd4cd9644f72285149aca525.jpg?c=1" border="0" alt="A.Monster.Calls.2016.1080p.WEB-DL.AAC2.0.H264-FGT" /></a></td><td align="left" class="lista" valign="top"><a title="War.on.Everyone.2016.1080p.BluRay.X264-AMIABLE" onmouseover="return overlib('War.on.Everyone.2016.1080p.BluRay.X264-AMIABLE')" onmouseout="return nd();" href="/torrent/z3pa2ty"><img src="//dyncdn.me/static/over/564d064ee87a308739dac81658f0b9df3318caba.jpg?c=2" border="0" alt="War.on.Everyone.2016.1080p.BluRay.X264-AMIABLE" /></a></td><td align="left" class="lista" valign="top"><a title="Allied.2016.DVDScr.XVID.AC3.HQ.Hive-CM8" onmouseover="return overlib('Allied.2016.DVDScr.XVID.AC3.HQ.Hive-CM8')" onmouseout="return nd();" href="/torrent/x2sk8l6"><img src="//dyncdn.me/static/over/1a08a2f029f7519fcae9d7b313a649dac9b41530.jpg?c=3" border="0" alt="Allied.2016.DVDScr.XVID.AC3.HQ.Hive-CM8" /></a></td><td align="left" class="lista" valign="top"><a title="Live.by.Night.2016.DVDScr.XVID.AC3.HQ.Hive-CM8" onmouseover="return overlib('Live.by.Night.2016.DVDScr.XVID.AC3.HQ.Hive-CM8')" onmouseout="return nd();" href="/torrent/otq16wl"><img src="//dyncdn.me/static/over/0725763ab9d9bca7cbee75dce34e98a0a4eb866b.jpg?c=3" border="0" alt="Live.by.Night.2016.DVDScr.XVID.AC3.HQ.Hive-CM8" /></a></td></tr></table></div>
    <br>
    <div align="center">
    </div>
    <br /><br />




    <div align="center">
    <form action="/torrents.php" method="get" class="searchTorrent" id="searchTorrent">
      <table border="0">
      <tr>
      <td align="center" style="width: 460px;">
      <input x-webkit-speech="x-webkit-speech" type="text" name="search" id="searchinput" style="width: 440px;" maxlength="60" value="" autocomplete="off" placeholder="Search Torrents" onclick="$('#SearchDescription').show();" onfocus="$('#SearchDescription').show();" onblur="$('#SearchDescription').hide();"  />
      </td>

      <td><button class="btn btn-primary" style="margin:0px !important;" type="submit"><i class="icon-search"></i> Search</button></td>
      <td><a href="#" class="btn btn-primary" onclick="showhideadvsearch('show'); return false;" style="color:#FFF !important;text-decoration:none !important;" id="shadvbutton">&raquo;</td>
      </tr>
      <tr style="display:none" id="SearchDescription"><td style="padding:0px;" colspan="3" align="left"><font size="1pt">You can search in everything - movies, music, games, porn, actors, genres</font></td></tr>

      </table>
      <script type="text/javascript">
      function clear_form_elements_adv(ele) {
      	$(ele).find(':input').each(function() {
      		switch(this.type) {
      			case 'select-multiple':
      			case 'select-one':
      			$(this).val('');
      			break;
      			case 'checkbox':
      			case 'radio':
      			this.checked = false;
      		}
      	});
      }
      function showhideadvsearch(action) {if(action == 'hide') {clear_form_elements_adv('#searchTorrent');$('#divadvsearch').hide();$('#shadvbutton').attr("onclick","showhideadvsearch('show'); return false;");$('#shadvbutton').html('&raquo;');}if(action == 'show') { $('#divadvsearch').show();$('#shadvbutton').attr("onclick","showhideadvsearch('hide'); return false;");$('#shadvbutton').html('&laquo;'); }}
      	</script>
      	  <div align="center"><div style="text-align:left;vertical-align:middle;padding-top:10px;margin-left:3px;display:none;" id="divadvsearch"><div class="divadvscat"><input class="inputadvscat" type="checkbox" name="category[]" value="4"  /> <a href="/torrents.php?category[]=4">XXX (18+)</a> </div> <div class="divadvscat"><input class="inputadvscat" type="checkbox" name="category[]" value="14"  /> <a href="/torrents.php?category[]=14">Movies/XVID</a> </div> <div class="divadvscat"><input class="inputadvscat" type="checkbox" name="category[]" value="48"  /> <a href="/torrents.php?category[]=48">Movies/XVID/720</a> </div> <div class="divadvscat"><input class="inputadvscat" type="checkbox" name="category[]" value="17"  /> <a href="/torrents.php?category[]=17">Movies/x264</a> </div> <div class="divadvscat"><input class="inputadvscat" type="checkbox" name="category[]" value="44"  /> <a href="/torrents.php?category[]=44">Movies/x264/1080</a> </div> <div class="divadvscat"><input class="inputadvscat" type="checkbox" name="category[]" value="45"  /> <a href="/torrents.php?category[]=45">Movies/x264/720</a> </div> <div class="divadvscat"><input class="inputadvscat" type="checkbox" name="category[]" value="47"  /> <a href="/torrents.php?category[]=47">Movies/x264/3D</a> </div> <div class="divadvscat"><input class="inputadvscat" type="checkbox" name="category[]" value="42"  /> <a href="/torrents.php?category[]=42">Movies/Full BD</a> </div> <div class="divadvscat"><input class="inputadvscat" type="checkbox" name="category[]" value="46"  /> <a href="/torrents.php?category[]=46">Movies/BD Remux</a> </div> <div class="divadvscat"><input class="inputadvscat" type="checkbox" name="category[]" value="18"  /> <a href="/torrents.php?category[]=18">TV Episodes</a> </div> <div class="divadvscat"><input class="inputadvscat" type="checkbox" name="category[]" value="41"  /> <a href="/torrents.php?category[]=41">TV HD Episodes</a> </div> <div class="divadvscat"><input class="inputadvscat" type="checkbox" name="category[]" value="23"  /> <a href="/torrents.php?category[]=23">Music/MP3</a> </div> <div class="divadvscat"><input class="inputadvscat" type="checkbox" name="category[]" value="25"  /> <a href="/torrents.php?category[]=25">Music/FLAC</a> </div> <div class="divadvscat"><input class="inputadvscat" type="checkbox" name="category[]" value="27"  /> <a href="/torrents.php?category[]=27">Games/PC ISO</a> </div> <div class="divadvscat"><input class="inputadvscat" type="checkbox" name="category[]" value="28"  /> <a href="/torrents.php?category[]=28">Games/PC RIP</a> </div> <div class="divadvscat"><input class="inputadvscat" type="checkbox" name="category[]" value="40"  /> <a href="/torrents.php?category[]=40">Games/PS3</a> </div> <div class="divadvscat"><input class="inputadvscat" type="checkbox" name="category[]" value="32"  /> <a href="/torrents.php?category[]=32">Games/XBOX-360</a> </div> <div class="divadvscat"><input class="inputadvscat" type="checkbox" name="category[]" value="33"  /> <a href="/torrents.php?category[]=33">Software/PC ISO</a> </div> <div class="divadvscat"><input class="inputadvscat" type="checkbox" name="category[]" value="35"  /> <a href="/torrents.php?category[]=35">e-Books</a> </div> <br style="clear:both;"><a href="#" onclick="clear_form_elements_adv('#searchTorrent'); return false;" class="divadvclearcats">[x] Clear categories</a></div></div></form></div><br style="clear:both;"></div>
    <table width="100%">
    <tr>
    <td colspan="2" align="center">




    <div align="center"><div id="pager_links">Pages: <b>1</b> <a href="/torrents.php?page=2" title="page 2">2</a> <a href="/torrents.php?page=3" title="page 3">3</a> <a href="/torrents.php?page=4" title="page 4">4</a> <a href="/torrents.php?page=5" title="page 5">5</a> <a href="/torrents.php?page=6" title="page 6">6</a> <a href="/torrents.php?page=7" title="page 7">7</a> <a href="/torrents.php?page=8" title="page 8">8</a> <a href="/torrents.php?page=9" title="page 9">9</a><a href="/torrents.php?page=2" title="next page">&raquo;</a></div></div></td>
    </tr>
    <tr><td align="center">


    </td></tr>
    <tr>
    <table width="100%" class="lista2t">
    <tr>
    <td width="48" align="center" class="header6 header40" style="width:48px;">Cat.</td>
    <td align="center" class="header6 header header40"><a class="anal tdlinkfull3" href="/torrents.php?search=&order=filename&by=ASC" />File</a></td>
    <td align="center" class="header6 header header40"><a class="anal tdlinkfull3" href="/torrents.php?search=&order=data&by=ASC" /><i class="icon-arrow-down"></i>Added</a></td>
    <td align="center" class="header6 header header40"><a class="anal tdlinkfull3" href="/torrents.php?search=&order=size&by=ASC" />Size</a></td>
    <td align="center" class="header6 header header40"><a class="anal tdlinkfull3" href="/torrents.php?search=&order=seeders&by=DESC" />S.</a></td>
    <td align="center" class="header6 header header40"><a class="anal tdlinkfull3" href="/torrents.php?search=&order=leechers&by=ASC" />L.</a></td>
    <td align="center" class="header6 header40"><img src="//dyncdn.me/static/20/images/comments.gif" border="0" alt="comments"></td>
    <td align="center" class="header6 header40">Uploader</td>
    </tr>

    <tr class="lista2"><td align="left" class="lista" width="48" style="width:48px;"><a href="/torrents.php?category=44"><img src="//dyncdn.me/static/20/images/categories/cat_new44.gif" border="0" alt="" /></a></td><td align="left" class="lista"><a onmouseover="return overlib('<img src=\'//dyncdn.me/static/over/2af69a191b149ef3dc34ca25d7774273caad872b.jpg\' border=0>')" onmouseout="return nd();" href="/torrent/trp45zu" title="The.Valley.1972.1080p.BluRay.H264.AAC-RARBG">The.Valley.1972.1080p.BluRay.H264.AAC-RARBG</a>  <img src="//dyncdn.me/static/20/img/internal2.png" border="0">    <a href="/torrents.php?imdb=tt0069451"><img src="//dyncdn.me/static/20/images/imdb_thumb.gif" border="0" alt=""></a>      <span class="ncontenticon1485647045"></span> <br><span style="color:DarkSlateGray">Drama IMDB: 6.5/10</span>  </td><td align="center"  width="150px" class="lista">2017-01-29 01:44:06</td><td align="center"  width="100px" class="lista">2.01 GB</td><td align="center"  width="50px" class="lista"><font color="#dd0000">1</font></td><td align="center"  width="50px" class="lista">1</td><td align="center"  width="50px" class="lista">--</td><td align="center" class="lista">Scene</td></tr><tr class="lista2"><td align="left" class="lista" width="48" style="width:48px;"><a href="/torrents.php?category=41"><img src="//dyncdn.me/static/20/images/categories/cat_new41.gif" border="0" alt="" /></a></td><td align="left" class="lista"><a onmouseover="return overlib('<img src=\'//dyncdn.me/static/20/tvdb/55014_small.jpg\' border=0>')" onmouseout="return nd();" href="/torrent/m6g1quf" title="Celebrity.Big.Brother.S19E30.720p.HDTV.x264-PLUTONiUM[rartv]">Celebrity.Big.Brother.S19E30.720p.HDTV.x264-PLUTONiUM[rartv]</a>      <a href="/torrents.php?imdb=tt0279550"><img src="//dyncdn.me/static/20/images/imdb_thumb.gif" border="0" alt=""></a>  <a href="/tv/tt0279550/"><img src="//dyncdn.me/static/20/img/tv2.png" border="0" alt=""></a>    <span class="ncontenticon1485646979"></span> <br><span style="color:DarkSlateGray">Reality-TV IMDB: 4.6/10</span>  </td><td align="center"  width="150px" class="lista">2017-01-29 01:43:00</td><td align="center"  width="100px" class="lista">779.05 MB</td><td align="center"  width="50px" class="lista"><font color="#dd0000">4</font></td><td align="center"  width="50px" class="lista">0</td><td align="center"  width="50px" class="lista">--</td><td align="center" class="lista">rartv</td></tr><tr class="lista2"><td align="left" class="lista" width="48" style="width:48px;"><a href="/torrents.php?category=4"><img src="//dyncdn.me/static/20/images/categories/cat_new4.gif" border="0" alt="" /></a></td><td align="left" class="lista"><a onmouseover="return overlib('<img src=\'//dyncdn.me/static/over/3cbdb3ac8d1e9aae7a31022e0340edacd91660f1.jpg\' border=0>')" onmouseout="return nd();" href="/torrent/n3vy76p" title="Slimewave.16.05.09.Two.Slimy.Dicks.XXX.1080p.x264-GAGViD">Slimewave.16.05.09.Two.Slimy.Dicks.XXX.1080p.x264-GAGViD</a>            <span class="ncontenticon1485646950"></span>   <br><span style="color:DarkSlateGray"></span></td><td align="center"  width="150px" class="lista">2017-01-29 01:42:31</td><td align="center"  width="100px" class="lista">946.45 MB</td><td align="center"  width="50px" class="lista"><font color="#dd0000">4</font></td><td align="center"  width="50px" class="lista">0</td><td align="center"  width="50px" class="lista">--</td><td align="center" class="lista">p33Rn3t</td></tr><tr class="lista2"><td align="left" class="lista" width="48" style="width:48px;"><a href="/torrents.php?category=41"><img src="//dyncdn.me/static/20/images/categories/cat_new41.gif" border="0" alt="" /></a></td><td align="left" class="lista"><a onmouseover="return overlib('<img src=\'//dyncdn.me/static/20/tvdb/320462_small.jpg\' border=0>')" onmouseout="return nd();" href="/torrent/ul57dit" title="Emerald.City.S01E05.Everybody.Lies.720p.AMZN.WEBRip.DD5.1.x264-ViSUM[rartv]">Emerald.City.S01E05.Everybody.Lies.720p.AMZN.WEBRip.DD5.1.x264-ViSUM[rartv]</a>      <a href="/torrents.php?imdb=tt3579018"><img src="//dyncdn.me/static/20/images/imdb_thumb.gif" border="0" alt=""></a>  <a href="/tv/tt3579018/"><img src="//dyncdn.me/static/20/img/tv2.png" border="0" alt=""></a>    <span class="ncontenticon1485646589"></span> <br><span style="color:DarkSlateGray">Adventure, Drama, Fantasy IMDB: 7.3/10</span>  </td><td align="center"  width="150px" class="lista">2017-01-29 01:36:30</td><td align="center"  width="100px" class="lista">1.82 GB</td><td align="center"  width="50px" class="lista"><font color="#cc0000">9</font></td><td align="center"  width="50px" class="lista">4</td><td align="center"  width="50px" class="lista">--</td><td align="center" class="lista">rartv</td></tr><tr class="lista2"><td align="left" class="lista" width="48" style="width:48px;"><a href="/torrents.php?category=41"><img src="//dyncdn.me/static/20/images/categories/cat_new41.gif" border="0" alt="" /></a></td><td align="left" class="lista"><a onmouseover="return overlib('<img src=\'//dyncdn.me/static/20/tvdb/320462_small.jpg\' border=0>')" onmouseout="return nd();" href="/torrent/8mp912q" title="Emerald.City.S01E05.Everybody.Lies.1080p.AMZN.WEBRip.DD5.1.x264-ViSUM[rartv]">Emerald.City.S01E05.Everybody.Lies.1080p.AMZN.WEBRip.DD5.1.x264-ViSUM[rartv]</a>      <a href="/torrents.php?imdb=tt3579018"><img src="//dyncdn.me/static/20/images/imdb_thumb.gif" border="0" alt=""></a>  <a href="/tv/tt3579018/"><img src="//dyncdn.me/static/20/img/tv2.png" border="0" alt=""></a>    <span class="ncontenticon1485646550"></span> <br><span style="color:DarkSlateGray">Adventure, Drama, Fantasy IMDB: 7.3/10</span>  </td><td align="center"  width="150px" class="lista">2017-01-29 01:35:51</td><td align="center"  width="100px" class="lista">3.95 GB</td><td align="center"  width="50px" class="lista"><font color="#cc0000">9</font></td><td align="center"  width="50px" class="lista">14</td><td align="center"  width="50px" class="lista">--</td><td align="center" class="lista">rartv</td></tr><tr class="lista2"><td align="left" class="lista" width="48" style="width:48px;"><a href="/torrents.php?category=18"><img src="//dyncdn.me/static/20/images/categories/cat_new18.gif" border="0" alt="" /></a></td><td align="left" class="lista"><a onmouseover="return overlib('<img src=\'//dyncdn.me/static/20/tvdb/55014_small.jpg\' border=0>')" onmouseout="return nd();" href="/torrent/97or8b2" title="Celebrity.Big.Brother.S19E30.HDTV.x264-PLUTONiUM[rartv]">Celebrity.Big.Brother.S19E30.HDTV.x264-PLUTONiUM[rartv]</a>      <a href="/torrents.php?imdb=tt0279550"><img src="//dyncdn.me/static/20/images/imdb_thumb.gif" border="0" alt=""></a>  <a href="/tv/tt0279550/"><img src="//dyncdn.me/static/20/img/tv2.png" border="0" alt=""></a>    <span class="ncontenticon1485646287"></span> <br><span style="color:DarkSlateGray">Reality-TV IMDB: 4.6/10</span>  </td><td align="center"  width="150px" class="lista">2017-01-29 01:31:28</td><td align="center"  width="100px" class="lista">290.72 MB</td><td align="center"  width="50px" class="lista"><font color="#008000">26</font></td><td align="center"  width="50px" class="lista">9</td><td align="center"  width="50px" class="lista">--</td><td align="center" class="lista">rartv</td></tr><tr class="lista2"><td align="left" class="lista" width="48" style="width:48px;"><a href="/torrents.php?category=17"><img src="//dyncdn.me/static/20/images/categories/cat_new17.gif" border="0" alt="" /></a></td><td align="left" class="lista"><a onmouseover="return overlib('<img src=\'//dyncdn.me/static/over/2b6d36f90c58af9d49d8572eafb2631613496b87.jpg\' border=0>')" onmouseout="return nd();" href="/torrent/yeqbglv" title="100.Streets.2016.LIMITED.DVDRip.x264-CADAVER">100.Streets.2016.LIMITED.DVDRip.x264-CADAVER</a>      <a href="/torrents.php?imdb=tt2990126"><img src="//dyncdn.me/static/20/images/imdb_thumb.gif" border="0" alt=""></a>      <span class="ncontenticon1485645673"></span> <br><span style="color:DarkSlateGray">Drama IMDB: 5.4/10</span>  </td><td align="center"  width="150px" class="lista">2017-01-29 01:21:13</td><td align="center"  width="100px" class="lista">638.28 MB</td><td align="center"  width="50px" class="lista"><font color="#bb0000">12</font></td><td align="center"  width="50px" class="lista">6</td><td align="center"  width="50px" class="lista">--</td><td align="center" class="lista">p33Rn3t</td></tr><tr class="lista2"><td align="left" class="lista" width="48" style="width:48px;"><a href="/torrents.php?category=44"><img src="//dyncdn.me/static/20/images/categories/cat_new44.gif" border="0" alt="" /></a></td><td align="left" class="lista"><a onmouseover="return overlib('<img src=\'//dyncdn.me/static/over/0413de9730bd756ce68c25e9592a45ad9557b1ef.jpg\' border=0>')" onmouseout="return nd();" href="/torrent/ux2mh86" title="Sixteen.Blocks.2006.1080p.BluRay.H264.AAC-RARBG">Sixteen.Blocks.2006.1080p.BluRay.H264.AAC-RARBG</a>  <img src="//dyncdn.me/static/20/img/internal2.png" border="0">    <a href="/torrents.php?imdb=tt0450232"><img src="//dyncdn.me/static/20/images/imdb_thumb.gif" border="0" alt=""></a>      <span class="ncontenticon1485645664"></span> <br><span style="color:DarkSlateGray">Action, Crime, Drama, Thriller IMDB: 6.6/10</span>  </td><td align="center"  width="150px" class="lista">2017-01-29 01:21:05</td><td align="center"  width="100px" class="lista">1.86 GB</td><td align="center"  width="50px" class="lista"><font color="#bb0000">12</font></td><td align="center"  width="50px" class="lista">15</td><td align="center"  width="50px" class="lista"><a href="/torrent/ux2mh86#comments">1</a></td><td align="center" class="lista">Scene</td></tr><tr class="lista2"><td align="left" class="lista" width="48" style="width:48px;"><a href="/torrents.php?category=4"><img src="//dyncdn.me/static/20/images/categories/cat_new4.gif" border="0" alt="" /></a></td><td align="left" class="lista"><a onmouseover="return overlib('<img src=\'//dyncdn.me/static/over/34ec47f045d16dc899d82a0e657f39aa282749a7.jpg\' border=0>')" onmouseout="return nd();" href="/torrent/7dstgpw" title="Slimewave.16.05.16.Pussy.Teatro.And.Final.Cum.Play.XXX.1080p.x264-GAGViD">Slimewave.16.05.16.Pussy.Teatro.And.Final.Cum.Play.XXX.1080p.x264-GAGViD</a>            <span class="ncontenticon1485645563"></span>   <br><span style="color:DarkSlateGray"></span></td><td align="center"  width="150px" class="lista">2017-01-29 01:19:23</td><td align="center"  width="100px" class="lista">852.34 MB</td><td align="center"  width="50px" class="lista"><font color="#dd0000">6</font></td><td align="center"  width="50px" class="lista">13</td><td align="center"  width="50px" class="lista">--</td><td align="center" class="lista">p33Rn3t</td></tr><tr class="lista2"><td align="left" class="lista" width="48" style="width:48px;"><a href="/torrents.php?category=17"><img src="//dyncdn.me/static/20/images/categories/cat_new17.gif" border="0" alt="" /></a></td><td align="left" class="lista"><a onmouseover="return overlib('<img src=\'//dyncdn.me/static/over/f6d25c8bac40c74bda8780cb33b8b74c5e87759f.jpg\' border=0>')" onmouseout="return nd();" href="/torrent/913m7jv" title="Under.The.Shadow.2016.LIMITED.DVDRip.x264-CADAVER">Under.The.Shadow.2016.LIMITED.DVDRip.x264-CADAVER</a>      <a href="/torrents.php?imdb=tt4278962"><img src="//dyncdn.me/static/20/images/imdb_thumb.gif" border="0" alt=""></a>      <span class="ncontenticon1485645226"></span> <br><span style="color:DarkSlateGray">Horror IMDB: 5.1/10</span>  </td><td align="center"  width="150px" class="lista">2017-01-29 01:13:47</td><td align="center"  width="100px" class="lista">313.94 MB</td><td align="center"  width="50px" class="lista"><font color="#aa0000">14</font></td><td align="center"  width="50px" class="lista">6</td><td align="center"  width="50px" class="lista">--</td><td align="center" class="lista">p33Rn3t</td></tr><tr class="lista2"><td align="left" class="lista" width="48" style="width:48px;"><a href="/torrents.php?category=4"><img src="//dyncdn.me/static/20/images/categories/cat_new4.gif" border="0" alt="" /></a></td><td align="left" class="lista"><a onmouseover="return overlib('<img src=\'//dyncdn.me/static/over/6e8c5307f199c8cf8d5d3d7abcdd4212ee806918.jpg\' border=0>')" onmouseout="return nd();" href="/torrent/9woxkl7" title="Slimewave.16.05.23.This.Skinny.Babe.Is.Receiving.A.Gooey.Slimewave.XXX.1080p.x264-GAGViD">Slimewave.16.05.23.This.Skinny.Babe.Is.Receiving.A.Gooey.Slimewave.XXX.1080p.x264-GAGViD</a>            <span class="ncontenticon1485645081"></span>   <br><span style="color:DarkSlateGray"></span></td><td align="center"  width="150px" class="lista">2017-01-29 01:11:22</td><td align="center"  width="100px" class="lista">885.93 MB</td><td align="center"  width="50px" class="lista"><font color="#bb0000">10</font></td><td align="center"  width="50px" class="lista">12</td><td align="center"  width="50px" class="lista">--</td><td align="center" class="lista">p33Rn3t</td></tr><tr class="lista2"><td align="left" class="lista" width="48" style="width:48px;"><a href="/torrents.php?category=41"><img src="//dyncdn.me/static/20/images/categories/cat_new41.gif" border="0" alt="" /></a></td><td align="left" class="lista"><a onmouseover="return overlib('<img src=\'//dyncdn.me/static/20/tvdb/315848_small.jpg\' border=0>')" onmouseout="return nd();" href="/torrent/1e9t3hl" title="Gaycation.S02E04.Deep.South.720p.HDTV.x264-YesTV[rartv]">Gaycation.S02E04.Deep.South.720p.HDTV.x264-YesTV[rartv]</a>      <a href="/torrents.php?imdb=tt5430288"><img src="//dyncdn.me/static/20/images/imdb_thumb.gif" border="0" alt=""></a>  <a href="/tv/tt5430288/"><img src="//dyncdn.me/static/20/img/tv2.png" border="0" alt=""></a>    <span class="ncontenticon1485644418"></span> <br><span style="color:DarkSlateGray">Documentary IMDB: 7.2/10</span>  </td><td align="center"  width="150px" class="lista">2017-01-29 01:00:19</td><td align="center"  width="100px" class="lista">927.70 MB</td><td align="center"  width="50px" class="lista"><font color="#aa0000">14</font></td><td align="center"  width="50px" class="lista">3</td><td align="center"  width="50px" class="lista">--</td><td align="center" class="lista">rartv</td></tr><tr class="lista2"><td align="left" class="lista" width="48" style="width:48px;"><a href="/torrents.php?category=18"><img src="//dyncdn.me/static/20/images/categories/cat_new18.gif" border="0" alt="" /></a></td><td align="left" class="lista"><a onmouseover="return overlib('<img src=\'//dyncdn.me/static/20/tvdb/315848_small.jpg\' border=0>')" onmouseout="return nd();" href="/torrent/dg3in84" title="Gaycation.S02E04.Deep.South.HDTV.x264-YesTV[rartv]">Gaycation.S02E04.Deep.South.HDTV.x264-YesTV[rartv]</a>      <a href="/torrents.php?imdb=tt5430288"><img src="//dyncdn.me/static/20/images/imdb_thumb.gif" border="0" alt=""></a>  <a href="/tv/tt5430288/"><img src="//dyncdn.me/static/20/img/tv2.png" border="0" alt=""></a>    <span class="ncontenticon1485644409"></span> <br><span style="color:DarkSlateGray">Documentary IMDB: 7.2/10</span>  </td><td align="center"  width="150px" class="lista">2017-01-29 01:00:10</td><td align="center"  width="100px" class="lista">280.67 MB</td><td align="center"  width="50px" class="lista"><font color="#990000">17</font></td><td align="center"  width="50px" class="lista">4</td><td align="center"  width="50px" class="lista">--</td><td align="center" class="lista">rartv</td></tr><tr class="lista2"><td align="left" class="lista" width="48" style="width:48px;"><a href="/torrents.php?category=41"><img src="//dyncdn.me/static/20/images/categories/cat_new41.gif" border="0" alt="" /></a></td><td align="left" class="lista"><a onmouseover="return overlib('<img src=\'//dyncdn.me/static/20/tvdb/315848_small.jpg\' border=0>')" onmouseout="return nd();" href="/torrent/sar6uq4" title="Gaycation.S02E03.France.720p.HDTV.x264-YesTV[rartv]">Gaycation.S02E03.France.720p.HDTV.x264-YesTV[rartv]</a>      <a href="/torrents.php?imdb=tt5430288"><img src="//dyncdn.me/static/20/images/imdb_thumb.gif" border="0" alt=""></a>  <a href="/tv/tt5430288/"><img src="//dyncdn.me/static/20/img/tv2.png" border="0" alt=""></a>    <span class="ncontenticon1485644395"></span> <br><span style="color:DarkSlateGray">Documentary IMDB: 7.2/10</span>  </td><td align="center"  width="150px" class="lista">2017-01-29 00:59:56</td><td align="center"  width="100px" class="lista">974.28 MB</td><td align="center"  width="50px" class="lista"><font color="#aa0000">13</font></td><td align="center"  width="50px" class="lista">3</td><td align="center"  width="50px" class="lista">--</td><td align="center" class="lista">rartv</td></tr><tr class="lista2"><td align="left" class="lista" width="48" style="width:48px;"><a href="/torrents.php?category=4"><img src="//dyncdn.me/static/20/images/categories/cat_new4.gif" border="0" alt="" /></a></td><td align="left" class="lista"><a onmouseover="return overlib('<img src=\'//dyncdn.me/static/over/66a93bc98ba7663d480ebb9cf450c0fda00c4fb5.jpg\' border=0>')" onmouseout="return nd();" href="/torrent/4x71mkw" title="Slimewave.16.05.30.Cum.Powered.Car.And.Cum.Powered.Driver.XXX.1080p.x264-GAGViD">Slimewave.16.05.30.Cum.Powered.Car.And.Cum.Powered.Driver.XXX.1080p.x264-GAGViD</a>            <span class="ncontenticon1485644376"></span>   <br><span style="color:DarkSlateGray"></span></td><td align="center"  width="150px" class="lista">2017-01-29 00:59:37</td><td align="center"  width="100px" class="lista">990.29 MB</td><td align="center"  width="50px" class="lista"><font color="#cc0000">9</font></td><td align="center"  width="50px" class="lista">22</td><td align="center"  width="50px" class="lista"><a href="/torrent/4x71mkw#comments">1</a></td><td align="center" class="lista">p33Rn3t</td></tr><tr class="lista2"><td align="left" class="lista" width="48" style="width:48px;"><a href="/torrents.php?category=18"><img src="//dyncdn.me/static/20/images/categories/cat_new18.gif" border="0" alt="" /></a></td><td align="left" class="lista"><a onmouseover="return overlib('<img src=\'//dyncdn.me/static/20/tvdb/315848_small.jpg\' border=0>')" onmouseout="return nd();" href="/torrent/gc1w72k" title="Gaycation.S02E03.France.HDTV.x264-YesTV[rartv]">Gaycation.S02E03.France.HDTV.x264-YesTV[rartv]</a>      <a href="/torrents.php?imdb=tt5430288"><img src="//dyncdn.me/static/20/images/imdb_thumb.gif" border="0" alt=""></a>  <a href="/tv/tt5430288/"><img src="//dyncdn.me/static/20/img/tv2.png" border="0" alt=""></a>    <span class="ncontenticon1485644375"></span> <br><span style="color:DarkSlateGray">Documentary IMDB: 7.2/10</span>  </td><td align="center"  width="150px" class="lista">2017-01-29 00:59:36</td><td align="center"  width="100px" class="lista">300.82 MB</td><td align="center"  width="50px" class="lista"><font color="#aa0000">14</font></td><td align="center"  width="50px" class="lista">2</td><td align="center"  width="50px" class="lista">--</td><td align="center" class="lista">rartv</td></tr><tr class="lista2"><td align="left" class="lista" width="48" style="width:48px;"><a href="/torrents.php?category=41"><img src="//dyncdn.me/static/20/images/categories/cat_new41.gif" border="0" alt="" /></a></td><td align="left" class="lista"><a onmouseover="return overlib('<img src=\'//dyncdn.me/static/20/tvdb/315848_small.jpg\' border=0>')" onmouseout="return nd();" href="/torrent/grsim6n" title="Gaycation.S02E02.India.720p.HDTV.x264-YesTV[rartv]">Gaycation.S02E02.India.720p.HDTV.x264-YesTV[rartv]</a>      <a href="/torrents.php?imdb=tt5430288"><img src="//dyncdn.me/static/20/images/imdb_thumb.gif" border="0" alt=""></a>  <a href="/tv/tt5430288/"><img src="//dyncdn.me/static/20/img/tv2.png" border="0" alt=""></a>    <span class="ncontenticon1485644360"></span> <br><span style="color:DarkSlateGray">Documentary IMDB: 7.2/10</span>  </td><td align="center"  width="150px" class="lista">2017-01-29 00:59:21</td><td align="center"  width="100px" class="lista">838.01 MB</td><td align="center"  width="50px" class="lista"><font color="#bb0000">10</font></td><td align="center"  width="50px" class="lista">2</td><td align="center"  width="50px" class="lista">--</td><td align="center" class="lista">rartv</td></tr><tr class="lista2"><td align="left" class="lista" width="48" style="width:48px;"><a href="/torrents.php?category=18"><img src="//dyncdn.me/static/20/images/categories/cat_new18.gif" border="0" alt="" /></a></td><td align="left" class="lista"><a onmouseover="return overlib('<img src=\'//dyncdn.me/static/20/tvdb/315848_small.jpg\' border=0>')" onmouseout="return nd();" href="/torrent/x1orhei" title="Gaycation.S02E02.India.HDTV.x264-YesTV[rartv]">Gaycation.S02E02.India.HDTV.x264-YesTV[rartv]</a>      <a href="/torrents.php?imdb=tt5430288"><img src="//dyncdn.me/static/20/images/imdb_thumb.gif" border="0" alt=""></a>  <a href="/tv/tt5430288/"><img src="//dyncdn.me/static/20/img/tv2.png" border="0" alt=""></a>    <span class="ncontenticon1485644321"></span> <br><span style="color:DarkSlateGray">Documentary IMDB: 7.2/10</span>  </td><td align="center"  width="150px" class="lista">2017-01-29 00:58:42</td><td align="center"  width="100px" class="lista">260.02 MB</td><td align="center"  width="50px" class="lista"><font color="#bb0000">12</font></td><td align="center"  width="50px" class="lista">1</td><td align="center"  width="50px" class="lista">--</td><td align="center" class="lista">rartv</td></tr><tr class="lista2"><td align="left" class="lista" width="48" style="width:48px;"><a href="/torrents.php?category=17"><img src="//dyncdn.me/static/20/images/categories/cat_new17.gif" border="0" alt="" /></a></td><td align="left" class="lista"><a onmouseover="return overlib('<img src=\'//dyncdn.me/static/over/ed3ec9226989ba7152b587cb235682e1a9777bd0.jpg\' border=0>')" onmouseout="return nd();" href="/torrent/xogb6hy" title="Walk.The.Line.2005.EXTENDED.iNTERNAL.BDRip.x264-FiCO">Walk.The.Line.2005.EXTENDED.iNTERNAL.BDRip.x264-FiCO</a>      <a href="/torrents.php?imdb=tt0358273"><img src="//dyncdn.me/static/20/images/imdb_thumb.gif" border="0" alt=""></a>      <span class="ncontenticon1485643860"></span> <br><span style="color:DarkSlateGray">Biography, Drama, Music, Romance IMDB: 7.9/10</span>  </td><td align="center"  width="150px" class="lista">2017-01-29 00:51:01</td><td align="center"  width="100px" class="lista">850.75 MB</td><td align="center"  width="50px" class="lista"><font color="#cc0000">8</font></td><td align="center"  width="50px" class="lista">6</td><td align="center"  width="50px" class="lista">--</td><td align="center" class="lista">p33Rn3t</td></tr><tr class="lista2"><td align="left" class="lista" width="48" style="width:48px;"><a href="/torrents.php?category=4"><img src="//dyncdn.me/static/20/images/categories/cat_new4.gif" border="0" alt="" /></a></td><td align="left" class="lista"><a onmouseover="return overlib('<img src=\'//dyncdn.me/static/over/23faca3a40b91b1c3cd70bcbc6f9aef92962074f.jpg\' border=0>')" onmouseout="return nd();" href="/torrent/bm8r9te" title="Slimewave.16.06.06.Finding.The.Right.Cock.To.Suck.And.Fuck.XXX.1080p.x264-GAGViD">Slimewave.16.06.06.Finding.The.Right.Cock.To.Suck.And.Fuck.XXX.1080p.x264-GAGViD</a>            <span class="ncontenticon1485642928"></span>   <br><span style="color:DarkSlateGray"></span></td><td align="center"  width="150px" class="lista">2017-01-29 00:35:29</td><td align="center"  width="100px" class="lista">821.06 MB</td><td align="center"  width="50px" class="lista"><font color="#990000">16</font></td><td align="center"  width="50px" class="lista">31</td><td align="center"  width="50px" class="lista">--</td><td align="center" class="lista">p33Rn3t</td></tr><tr class="lista2"><td align="left" class="lista" width="48" style="width:48px;"><a href="/torrents.php?category=45"><img src="//dyncdn.me/static/20/images/categories/cat_new45.gif" border="0" alt="" /></a></td><td align="left" class="lista"><a onmouseover="return overlib('<img src=\'//dyncdn.me/static/over/38ea1ceff6d2e2074ac16bebcef5ec913673d311.jpg\' border=0>')" onmouseout="return nd();" href="/torrent/6pohczb" title="Appleseed.Alpha.2013.720p.BluRay.H264.AAC-RARBG">Appleseed.Alpha.2013.720p.BluRay.H264.AAC-RARBG</a>  <img src="//dyncdn.me/static/20/img/internal2.png" border="0">    <a href="/torrents.php?imdb=tt3638012"><img src="//dyncdn.me/static/20/images/imdb_thumb.gif" border="0" alt=""></a>      <span class="ncontenticon1485642784"></span> <br><span style="color:DarkSlateGray">Animation, Action, Sci-Fi IMDB: 6.6/10</span>  </td><td align="center"  width="150px" class="lista">2017-01-29 00:33:05</td><td align="center"  width="100px" class="lista">1.13 GB</td><td align="center"  width="50px" class="lista"><font color="#bb0000">10</font></td><td align="center"  width="50px" class="lista">19</td><td align="center"  width="50px" class="lista">--</td><td align="center" class="lista">Scene</td></tr><tr class="lista2"><td align="left" class="lista" width="48" style="width:48px;"><a href="/torrents.php?category=45"><img src="//dyncdn.me/static/20/images/categories/cat_new45.gif" border="0" alt="" /></a></td><td align="left" class="lista"><a onmouseover="return overlib('<img src=\'//dyncdn.me/static/over/e95d88bf207220af2a57a7fe055ce53d113b1e19.jpg\' border=0>')" onmouseout="return nd();" href="/torrent/2kqp1o9" title="Babylon.A.D.2008.EXTENDED.CUT.720p.BluRay.H264.AAC-RARBG">Babylon.A.D.2008.EXTENDED.CUT.720p.BluRay.H264.AAC-RARBG</a>  <img src="//dyncdn.me/static/20/img/internal2.png" border="0">    <a href="/torrents.php?imdb=tt0364970"><img src="//dyncdn.me/static/20/images/imdb_thumb.gif" border="0" alt=""></a>      <span class="ncontenticon1485642362"></span> <br><span style="color:DarkSlateGray">Action, Adventure, Sci-Fi, Thriller IMDB: 5.6/10</span>  </td><td align="center"  width="150px" class="lista">2017-01-29 00:26:03</td><td align="center"  width="100px" class="lista">1.22 GB</td><td align="center"  width="50px" class="lista"><font color="#880000">18</font></td><td align="center"  width="50px" class="lista">24</td><td align="center"  width="50px" class="lista"><a href="/torrent/2kqp1o9#comments">1</a></td><td align="center" class="lista">Scene</td></tr><tr class="lista2"><td align="left" class="lista" width="48" style="width:48px;"><a href="/torrents.php?category=4"><img src="//dyncdn.me/static/20/images/categories/cat_new4.gif" border="0" alt="" /></a></td><td align="left" class="lista"><a onmouseover="return overlib('<img src=\'//dyncdn.me/static/over/539171d4705402fa2fbf77bd498e8d02e8df8318.jpg\' border=0>')" onmouseout="return nd();" href="/torrent/6x1d5ch" title="Slimewave.16.06.13.Lady.In.Red.Covered.In.Cum.XXX.1080p.x264-GAGViD">Slimewave.16.06.13.Lady.In.Red.Covered.In.Cum.XXX.1080p.x264-GAGViD</a>            <span class="ncontenticon1485642159"></span>   <br><span style="color:DarkSlateGray"></span></td><td align="center"  width="150px" class="lista">2017-01-29 00:22:40</td><td align="center"  width="100px" class="lista">921.41 MB</td><td align="center"  width="50px" class="lista"><font color="#880000">19</font></td><td align="center"  width="50px" class="lista">30</td><td align="center"  width="50px" class="lista">--</td><td align="center" class="lista">p33Rn3t</td></tr><tr class="lista2"><td align="left" class="lista" width="48" style="width:48px;"><a href="/torrents.php?category=18"><img src="//dyncdn.me/static/20/images/categories/cat_new18.gif" border="0" alt="" /></a></td><td align="left" class="lista"><a onmouseover="return overlib('<img src=\'//dyncdn.me/static/20/tvdb/318937_small.jpg\' border=0>')" onmouseout="return nd();" href="/torrent/5oybjdg" title="Paranormal.Lockdown.S02E07.HDTV.x264-W4F[ettv]">Paranormal.Lockdown.S02E07.HDTV.x264-W4F[ettv]</a>      <a href="/torrents.php?imdb=tt5512658"><img src="//dyncdn.me/static/20/images/imdb_thumb.gif" border="0" alt=""></a>  <a href="/tv/tt5512658/"><img src="//dyncdn.me/static/20/img/tv2.png" border="0" alt=""></a>    <span class="ncontenticon1485641589"></span> <br><span style="color:DarkSlateGray">Reality-TV IMDB: 7.4/10</span>  </td><td align="center"  width="150px" class="lista">2017-01-29 00:13:09</td><td align="center"  width="100px" class="lista">250.05 MB</td><td align="center"  width="50px" class="lista"><font color="#008000">30</font></td><td align="center"  width="50px" class="lista">21</td><td align="center"  width="50px" class="lista">--</td><td align="center" class="lista">ettv</td></tr><tr class="lista2"><td align="left" class="lista" width="48" style="width:48px;"><a href="/torrents.php?category=4"><img src="//dyncdn.me/static/20/images/categories/cat_new4.gif" border="0" alt="" /></a></td><td align="left" class="lista"><a onmouseover="return overlib('<img src=\'//dyncdn.me/static/over/42b120598a04ee747e4707c70e75eac7556692bd.jpg\' border=0>')" onmouseout="return nd();" href="/torrent/yunxzat" title="Slimewave.16.06.20.Rachel.Evans.The.Best.Fucking.And.Sucking.XXX.1080p.x264-GAGViD">Slimewave.16.06.20.Rachel.Evans.The.Best.Fucking.And.Sucking.XXX.1080p.x264-GAGViD</a>            <span class="ncontenticon1485641319"></span>   <br><span style="color:DarkSlateGray">Milf, Small Tits</span></td><td align="center"  width="150px" class="lista">2017-01-29 00:08:39</td><td align="center"  width="100px" class="lista">925.48 MB</td><td align="center"  width="50px" class="lista"><font color="#008000">24</font></td><td align="center"  width="50px" class="lista">61</td><td align="center"  width="50px" class="lista">--</td><td align="center" class="lista">p33Rn3t</td></tr>
    </tr>
    </table>
    <tr><td colspan="2" align="center">
    <div align="center"><div id="pager_links">Pages: <b>1</b> <a href="/torrents.php?page=2" title="page 2">2</a> <a href="/torrents.php?page=3" title="page 3">3</a> <a href="/torrents.php?page=4" title="page 4">4</a> <a href="/torrents.php?page=5" title="page 5">5</a> <a href="/torrents.php?page=6" title="page 6">6</a> <a href="/torrents.php?page=7" title="page 7">7</a> <a href="/torrents.php?page=8" title="page 8">8</a> <a href="/torrents.php?page=9" title="page 9">9</a><a href="/torrents.php?page=2" title="next page">&raquo;</a></div></div>


    <br/>

    <br/>

    </td></tr>
    <tr><td></td></tr>
    <tr><td>
    <div>
    <div align="center">
    </div>
    </div>
    </td></tr>
    <script type="text/javascript">spans=document.getElementsByTagName('span');for(i in spans) {if(/ncontenticon/.test(spans[i].className)) {var spanreplacer = spans[i].className;spanreplacer = spanreplacer.replace('ncontenticon','');if(spanreplacer > 1485650932) {spans[i].innerHTML=spans[i].innerHTML+'<img src="//dyncdn.me/static/20/img/new.png" border="0" alt="new torrent" />';}}}</script>
    </td></tr><tr><td class="block" colspan="1" align="center"></td></tr></table></div></td>
    </tr>
    </table>
    <div align="center">
    SUPPORT : support@rarbg.to <a href="/faq.php">FAQ</a>  DMCA : spam@rarbg.to DMCA INFO HERE : <a href="/dmca_info.php">DMCA Info</a><br />
    <br />
    Sun, 29 Jan 2017 01:48:53 +0100</div>
    <br/>

    <div align="center">
    <a href="/s/Natalie+Lust/">Natalie Lust</a> <a href="/s/%22Alexis+Adams%22/">"Alexis Adams"</a> <a href="/s/karla+kush/">karla kush</a> <a href="/s/allied/">allied</a> <a href="/s/rogue+One/">rogue One</a> </div>
    <script type="text/javascript">
    function mcpslar(name,value,days) {if (days) {var date = new Date();date.setTime(date.getTime()+(days*24*60*60*1000));var expires = "; expires="+date.toGMTString(); } else var expires = "";document.cookie = name+"="+value+expires+"; path=/";}
    mcpslar('wQnP98Kj','wZkvrmuL',5);
    </script>
    <br />
    <div align="center">

    Powered by <a href="//dyncdn.me/static/20/img/hamster.jpg">hamsters 1.0</a><br />
    By using this site you agree to and accept our user agreement. If you havent read the user agreement please do so <a href="/useragreement.php">here</a>
    </div>

    		<script type="text/javascript">
    		function dd_pp_f_d() {
    window.FnxCyr6u = 1;
    setTimeout(function(){ window.FnxCyr6u = 0; }, 5000);
    }
    </script>
    <script>
    var _wm_settings={popunder:{url:"http://adrunnr.com/?placement=401444&redirect",times:3,hours:6,cookie:"expla2",fastbind:true}};
    </script>
    <script type="text/javascript" src="//dyncdn.me/static/20/js/expla5.js"></script>
    <script type='text/javascript'>function mBhJuWMW(name, value, seconds) { var date = new Date(); date.setTime(date.getTime() + (seconds * 1000)); var expires = "; expires=" + date.toGMTString(); document.cookie = name + "=" + value + expires + "; path=/"; }  function a8nJXDwsf(name) { var nameEQ = name + "="; var ca = document.cookie.split(';'); for (var i = 0; i < ca.length; i++) { var c = ca[i]; while (c.charAt(0) == ' ') c = c.substring(1, c.length); if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length, c.length); } return null; } var gxsYTxpt = 0; var mtdwnVGt = a8nJXDwsf('expla'); if (!mtdwnVGt) { gxsYTxpt = 1; mBhJuWMW('expla', 1, 45); } else { mtdwnVGt = parseInt(mtdwnVGt); if (mtdwnVGt < 4) { if (mtdwnVGt >= 1 && mtdwnVGt <= 3) { mBhJuWMW('expla', (mtdwnVGt + 1), 45); gxsYTxpt = 1; } gxsYTxpt = 1; } }  if (gxsYTxpt == 1) { var expla3 = a8nJXDwsf('expla3'); if(expla3 == 1) { gxsYTxpt = 0; } }  if (gxsYTxpt == 1) { var ccEnabled=navigator.ccEnabled?!0:!1;"undefined"!=typeof navigator.ccEnabled||ccEnabled||(document.cookie="tcc",ccEnabled=-1!=document.cookie.indexOf("tcc")?!0:!1); if(!ccEnabled) { gxsYTxpt = 0; } } if (gxsYTxpt == 1) { mBhJuWMW('expla3', 1, 3); } else { if (typeof(_wm) !== 'undefined') { if (_wm.format.popunder.isBinded) { _wm.format.popunder.isTriggered = true; } } } </script>

    		<script>
    	if(window.getComputedStyle) {
    		var bgcolor = window.getComputedStyle(document.body, null).backgroundColor;
    		if (bgcolor != 'rgb(0, 0, 0)') {
    			mcpslar('use_alt_cdn','1',1);
    		}

    	}
    	</script>
    	<script type="text/javascript">
    if (window.top !== window.self) { window.top.location.replace(window.self.location.href); }
    	if(!document.referrer) { var statsy_ref = ''; } else { var statsy_ref = document.referrer.split('/')[2]; }
    	if(!window.screen.height || !window.screen.width) { var statsy_res = ''; } else { var statsy_res = window.screen.height+'x'+window.screen.width; }
    	if(typeof(_wm) == "undefined") { var statsy_ab = 1; } else { var statsy_ab = 2; }
    	$.ajax({type: 'GET',url: ('https:' == document.location.protocol ? 'https://' : 'http://') + 'statsy.net/a.php?ref='+statsy_ref+'&res='+statsy_res+'&ab='+statsy_ab+'',contentType: 'text/plain', async: true, xhrFields: {withCredentials:true},  timeout: 3000, cache: false });



    </script>

    	<script type="text/javascript">
    	function h_ab_m() { mcpslar('ab_u','1',1); location.reload(); }
    	if(typeof(_wm) == "undefined") {
    		var e = document.createElement('div');
    		document.body.insertBefore(e, document.body.childNodes[0]);
    		var e = document.createElement('div');
    		document.body.insertBefore(e, document.body.childNodes[0]);
    		var e = document.createElement('div');
    		document.body.insertBefore(e, document.body.childNodes[0]);
    		var e = document.createElement('div');
    		e.innerHTML = 'If you are missing comments, posters, screenshots , download , magnets , trailer , imdb links its because you are using adblock. The good folks from adblock are blocking everything! <a onclick="h_ab_m();" style="font-color:#FFF !important;text-decoration:underline !important;cursor:pointer;cursor:hand;font-weight:bold;">I understand!</a>';
    		document.body.insertBefore(e, document.body.childNodes[3]);
    		mcpslar('aby','1',7);
    	} else {
    		mcpslar('aby','2',7);
    	}

    	</script>
    	</body></html>
    """
  end

  def detail_sample do
    """
    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> <html xmlns="http://www.w3.org/1999/xhtml"><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8" /><meta name="robots" content="index,follow" /><meta name="description" content="Download The.Valley.1972.1080p.BluRay.H264.AAC-RARBG Torrent - RARBG" /><title>The.Valley.1972.1080p.BluRay.H264.AAC-RARBG Torrent download</title><meta name="robots" content="all" /><meta name="revisit" content="1 day" /><meta http-equiv="pragma" content="no-cache" /><meta http-equiv="expires" content="0" /><meta http-equiv="cache-control" content="no-cache" /><link rel="alternate" type="application/rss+xml" title="RARBG Latest Torrents" href="https://rarbg.to/rss.php" /><link rel="alternate" type="application/rss+xml" title="RARBG Direct Download" href="https://rarbg.to/rssdd.php" /><link rel="search" type="application/opensearchdescription+xml" title="Rarbg torrents" href="/opensearch.xml2" /><link rel="stylesheet" href="//dyncdn.me/static/20/css/styles_v33.css" type="text/css" media="all" />
    </head><body>
    <div id="overlib"></div>
    <!--[if IE 8]><script type="text/javascript">var isIE8 = true;</script><![endif]-->
    <script type="text/javascript" src="//dyncdn.me/static/20/js/jquery-1.11.3.min.js"></script>
    <script type="text/javascript">var pop=document.getElementById("overlib");var xoffset=15;var yoffset=10;var el="";document.onmousemove=function(k){var h,j,m,e,l;if(typeof(isIE8)!="undefined"){h=window.event.x;j=window.event.y;el=window.event.target||window.event.srcElement}else{try{h=k.pageX;j=k.pageY;el=k.target||k.srcElement}catch(k){h=window.event.x;j=window.event.y;h+=document.documentElement.scrollLeft;j+=document.documentElement.scrollTop;el=window.event.target||window.event.srcElement}}h+=xoffset;j+=yoffset;pop.style.top=j+"px";pop.style.left=h+"px"};function overlib(b){pop.innerHTML=b;pop.style.display="block";deAlt(el)}function deAlt(){if(el){if(el.alt){el.alt=""}if(el.title){el.title=""}aKid=el.childNodes||el.children||null;if(aKid){for(var a=0;a<aKid.length;a++){el=aKid[a];deAlt()}}}}function nd(){pop.style.display="none"}function addPlugin(){window.external.AddSearchProvider("https://rarbg.to/plugins/ff.xml")}function addPluginIE(){var l="RARBG.TO";var g="https://rarbg.to/torrents.php?search=TEST";l=l.replace(/^\s+|\s+$/g,"");g=g.replace(/^\s+|\s+$/g,"");var h="UTF-8";if(g.length<1){alert("Please enter the URL of the search results page.");document.getElementById("sURI").focus();return false}if(g.indexOf("TEST")<0){alert("The search results URL must contain the word TEST.  Please check the URL.\nIt's possible that this tool cannot be used to build a query for that search engine.");document.getElementById("sURI").focus();return false}if(l.length<1){alert("Please enter a NAME for the new search provider");document.getElementById("sName").focus();return false}var k="Encoding="+encodeURIComponent(h)+"&Name="+encodeURIComponent(l)+"&URI="+encodeURIComponent(g);var j="http://www.microsoft.com/windows/ie/searchguide/spbuilder.mspx?"+k;try{window.external.AddSearchProvider(j)}catch(m){if(70==(m.number&65535)){alert("For security reasons, you must use the mouse\n(or the Enter key) to click the Install button.")}else{alert("Unable to add search provider. The Create Your\nOwn tool requires Internet Explorer 7.   ["+(m.number&65535)+"]")}}return false}var BrowserDetect={init:function(){this.browser=this.searchString(this.dataBrowser)||"An unknown browser";this.version=this.searchVersion(navigator.userAgent)||this.searchVersion(navigator.appVersion)||"an unknown version";this.OS=this.searchString(this.dataOS)||"an unknown OS"},searchString:function(g){for(var f=0;f<g.length;f++){var e=g[f].string;var h=g[f].prop;this.versionSearchString=g[f].versionSearch||g[f].identity;if(e){if(e.indexOf(g[f].subString)!=-1){return g[f].identity}}else{if(h){return g[f].identity}}}},searchVersion:function(c){var d=c.indexOf(this.versionSearchString);if(d==-1){return}return parseFloat(c.substring(d+this.versionSearchString.length+1))},dataBrowser:[{string:navigator.userAgent,subString:"OmniWeb",versionSearch:"OmniWeb/",identity:"OmniWeb"},{string:navigator.vendor,subString:"Apple",identity:"Safari"},{prop:window.opera,identity:"Opera"},{string:navigator.vendor,subString:"iCab",identity:"iCab"},{string:navigator.vendor,subString:"KDE",identity:"Konqueror"},{string:navigator.userAgent,subString:"Firefox",identity:"Firefox"},{string:navigator.vendor,subString:"Camino",identity:"Camino"},{string:navigator.userAgent,subString:"Netscape",identity:"Netscape"},{string:navigator.userAgent,subString:"MSIE",identity:"Explorer",versionSearch:"MSIE"},{string:navigator.userAgent,subString:"Gecko",identity:"Mozilla",versionSearch:"rv"},{string:navigator.userAgent,subString:"Mozilla",identity:"Netscape",versionSearch:"Mozilla"}],dataOS:[{string:navigator.platform,subString:"Win",identity:"Windows"},{string:navigator.platform,subString:"Mac",identity:"Mac"},{string:navigator.platform,subString:"Linux",identity:"Linux"}]};BrowserDetect.init();function addsearchplugin(){if(BrowserDetect.browser=="Firefox"){addPlugin()}else{if(BrowserDetect.browser=="Explorer"&&BrowserDetect.version==7){addPluginIE()}}}function Bookmark(){var f="RARBG.to";var d="https://rarbg.to";if(window.sidebar){window.sidebar.addPanel(f,d,"")}else{if(window.opera&&window.print){var e=document.createElement("a");e.setAttribute("rel","sidebar");e.setAttribute("href",d);e.setAttribute("title",f);e.click()}else{if(document.all){window.external.AddFavorite(d,f)}}}}if (window != top) top.location.href = location.href;</script>
    <table width="90%" align="center"><tr>
    <td width="10%">
    <a href="/torrents.php" title="Rarbg torrents"><img src="//dyncdn.me/static/20/img/logo_dark_nodomain2_optimized.png" border="0" alt="rarbg torrents" style="margin: 15px 0 0 0;" /></a>
    </td>
    <td width="50%" align="center">

    <script type="text/javascript">function clickclear(thisfield, defaulttext) {if (thisfield.value == defaulttext) {thisfield.value = "";}}function clickrecall(thisfield, defaulttext) {if (thisfield.value == "") {thisfield.value = defaulttext;}}</script>
    	<form action="/login" name="login" method="post" style="position:relative;">
        <table width="100%" border="0" cellpadding="2" cellspacing="0">
    		<tr>
    			<td class="lista" align="left">
    				<table border="0" cellpadding="5" cellspacing="0">
    					<tr>
    						<td class="lista"><input type="text" size="22" name="uid" id="uid" value="User" maxlength="40" style="font-size:12px" onclick="clickclear(this, 'User')" onblur="clickrecall(this,'User')" /></td>
    						<td class="lista"><input type="password" size="22" name="pwd" id="pwd" autocomplete="off" maxlength="40" style="font-size:12px" value="Password" onclick="clickclear(this, 'Password')" onblur="clickrecall(this,'Password')" /></td>
    						<td class="lista" align="center"><input type="submit" value="Login" style="font-size:12px" class="pftext" /></td>
    						<td class="lista">
    					<a href="//dyncdn.me/static/20/searches/rarbg.btsearch"><img src="//dyncdn.me/static/20/img/utorrent3.png" border="0" alt="" /></a> <a onclick="Bookmark()"><img src="//dyncdn.me/static/20/img/bookmark2.png" border="0" alt="" /></a> <a onclick="addsearchplugin()"><img src="//dyncdn.me/static/20/img/ff2.png" border="0" alt="" /></a> 					</td>
    					</tr></table>
    					</td></tr></table>


        </form>
    	</td>

    	<td width="40%" align="right">
    	</td>
        </tr>
        </table>

    <table width="90%" border="0" align="center"><tr>
    <td colspan="2">
    <table class="lista3" width="99%" align="center" style="padding: 20px 0 0 0;">
    <tr>
    <td class="header"></td><td class="header4" align="center">&nbsp; Guest <a class="anal" href="/login">(Login)</a></td><td class="header3" align="center"><a class="anal tdlinkfull1" href="/torrents.php">Torrents</a></td><td class="header3" align="center"><a class="anal tdlinkfull1" href="/chart.php">Box office</a></td><td class="header3" align="center"><a class="anal tdlinkfull1" href="/catalog/">Catalog</a></td><td class="header3" align="center"><a class="anal tdlinkfull1" href="/top10">Top 10</a></td><td class="header3" align="center"><a class="anal tdlinkfull1" href="/viewnews">News</a></td></tr>
    </table>

    </td></tr></table><table width="90%" align="center" border="0" style="margin: -8px auto 0;"><tr>
    <td width="100" valign="top" align="left">
    <br />
    <table width="100%" cellpadding="0" cellspacing="2" style="margin: 0 0 0 5px;"><tr><td class="header5" align="left"><a class="anal tdlinkfull2" href="/torrents.php">View all</a></td></tr><tr><td class="header5" align="left"><a class="anal tdlinkfull2" href="/torrents.php?category=movies">Movies</a></td></tr><tr><td class="header5" align="left"><a class="anal tdlinkfull2" href="/torrents.php?category=1;4">XXX</a></td></tr><tr><td class="header5" align="left"><a class="anal tdlinkfull2" href="/torrents.php?category=1;18;41">TV Shows</a></td></tr><tr><td class="header5" align="left"><a class="anal tdlinkfull2" href="/torrents.php?category=1;27;28;29;30;31;32;40">Games</a></td></tr><tr><td class="header5" align="left"><a class="anal tdlinkfull2" href="/torrents.php?category=1;23;24;25;26">Music</a></td></tr><tr><td class="header5" align="left"><a class="anal tdlinkfull2" href="/torrents.php?category=1;33;34;43">Software</a></td></tr><tr><td class="header5" align="left"><a class="anal tdlinkfull2" href="/torrents.php?category=1;14;15;16;17;21;22;42;18;19;41;27;28;29;30;31;32;40;23;24;25;26;33;34;43;44;45;46;47;48">Non XXX</a></td></tr><tr><td align="left">&nbsp;<br/></td></tr><tr><td class="header5" align="left"><a class="anal tdlinkfull2" href="/trailers.php">Trailers</a></td></tr><tr><td class="header5" align="left"><a class="anal tdlinkfull2" href="/catalog/">Catalog</a></td></tr><tr><td class="header5" align="left"><a class="anal tdlinkfull2" href="/chart.php">Box Office</a></td></tr><tr><td align="left">&nbsp;<br/></td></tr><tr><td class="header5" align="left"><a class="anal tdlinkfull2" href="/index8.php" title="rarbg">New index</a></td></tr><tr><td align="left">&nbsp;<br/></td></tr></table></td>
     <td valign="top">

    <div itemscope itemtype="http://schema.org/Product"><div class="content-rounded"><table class="lista-rounded" style="height:480px;" cellpadding="0" cellspacing="0" width="100%" align="center"><tr><td class="block" align="center" colspan="1" valign="top"><b><h1 class="black" itemprop="name">The.Valley.1972.1080p.BluRay.H264.AAC-RARBG</h1></b></td></tr><tr><td width="100%" align="justify" valign="top"><div><table width="100%" class="lista" border="0" cellspacing="1" cellpadding="0">
    <tr><td align="right" class="header2" width="120"> Torrent:</td><td class="lista"><img src="//dyncdn.me/static/20/img/16x16/download.png" alt="" border="0" /> <a onmouseover="return overlib('Click here to download torrent')" onmouseout="return nd();" href="/download.php?id=trp45zu&f=The.Valley.1972.1080p.BluRay.H264.AAC-RARBG-[rarbg.to].torrent">The.Valley.1972.1080p.BluRay.H264.AAC-RARBG</a> <a href="magnet:?xt=urn:btih:2af69a191b149ef3dc34ca25d7774273caad872b&dn=The.Valley.1972.1080p.BluRay.H264.AAC-RARBG&tr=http%3A%2F%2Ftracker.trackerfix.com%3A80%2Fannounce&tr=udp%3A%2F%2F9.rarbg.me%3A2710&tr=udp%3A%2F%2F9.rarbg.to%3A2710"><img src="//dyncdn.me/static/20/img/magnet.gif" border="0"></a></td></tr>

    		<tr><td align="right" class="header2">VPN:</td><td style="color:#000;border-bottom:1px solid #e5e5e5;padding:2px 3px;">

    		<table>
    		<tr>
    		<td><a href="/vpn_offer.php" target="_blank"><button class="btn btn-mini btn-primary">GET VPN</button></a></td>
    		<td style="height:38px"><b>Downloading torrents is illegal in the United States</b>. Use a <a href="/vpn_offer2.php" target="_blank">VPN</a> to make yourself hidden while downloading torrents.<br/> By using a <a href="/vpn_offer2.php" target="_blank">VPN</a> , your ISP and Government Agencies will not be able to spy on you, neither would they be able to track your online activity!</td>
    		</tr>
    		</table>
    		</td></tr>


    		<tr><td align="right" class="header2" valign="top"> Poster:<br></td><td class="lista"><img itemprop="image" src="//dyncdn.me/posters2/2/2af69a191b149ef3dc34ca25d7774273caad872b.jpg" border="0" alt="The.Valley.1972.1080p.BluRay.H264.AAC-RARBG" /></td></tr>
    <tr><td align="right" class="header2"> Others:</td><td style="color:#000;border-bottom:1px solid #e5e5e5;padding:2px 3px;"><table class="lista"><tbody><tr><td class="header2">Quality</td><td class="header2">Res</td><td class="header2">Sound</td><td class="header2">Codec</td><td class="header2">Name</td><td class="header2">S.</td><td class="header2">L.</td><td class="header2">Size</td></tr><tr class="lista_related"><td class="lista">BRRip</td><td class="lista">720</td><td class="lista">AAC</td><td class="lista">x264</td><td class="lista"><a href="/torrent/ulgscpe">The.Valley.1972.720p.BluRay.H264.AAC-RARBG</a></td><td class="lista"><font color="#008000">25</font></td><td class="lista">36</td><td class="lista">1.28 GB</td></tr><tr class="lista_related"><td class="lista">BRRip</td><td class="lista">-</td><td class="lista">MP3</td><td class="lista">xvid</td><td class="lista"><a href="/torrent/6u2ptsg">The.Valley.1972.BRRip.XviD.MP3-RARBG</a></td><td class="lista"><font color="#008000">25</font></td><td class="lista">21</td><td class="lista">1.32 GB</td></tr><tr class="lista_related"><td class="lista">BRRip</td><td class="lista">1080</td><td class="lista">-</td><td class="lista">x264</td><td class="lista"><a href="/torrent/xwik38z">The.Valley.1972.1080p.BluRay.x264-METH</a></td><td class="lista"><font color="#008000">35</font></td><td class="lista">46</td><td class="lista">6.56 GB</td></tr></tbody></table><br />&nbsp; <a href="/torrents.php?imdb=tt0069451"><button class="btn btn-mini btn-primary"><i class="icon-list"></i> Browse mode</button></a><br /><style type="text/css"> .lista_related:hover { background-color:#DFEFFA !important; } </style><br/></td></tr>
    		<script type="text/javascript">
    		function show_hide_mediainfo() {
    			$('#mediainfo_container').toggle();
    			if($('#a_show_hide_mediainfo').text() == "[+] Show MediaInfo") {
    				$('#a_show_hide_mediainfo').text('[-] Hide MediaInfo');
    			} else {
    				$('#a_show_hide_mediainfo').text('[+] Show MediaInfo');
    			}
    		}
    		</script>
    		<tr><td align="right" class="header2" valign="top"> Description:</td><td class="lista" id="description"><a href="http://imagecurl.com/viewer.php?file=57675740099501367277.png" rel="nofollow" target="_blank"><img border="0" style="max-width:50%" src="http://imagecurl.com/images/57675740099501367277_thumb.png"></a><br />
    <a href="http://imagecurl.com/viewer.php?file=58738061713695995470.png" rel="nofollow" target="_blank"><img border="0" style="max-width:50%" src="http://imagecurl.com/images/58738061713695995470_thumb.png"></a><br />
    <a href="http://imagecurl.com/viewer.php?file=26497671385501847023.png" rel="nofollow" target="_blank"><img border="0" style="max-width:50%" src="http://imagecurl.com/images/26497671385501847023_thumb.png"></a><br />
    <a href="http://imagecurl.com/viewer.php?file=32442566030056727176.png" rel="nofollow" target="_blank"><img border="0" style="max-width:50%" src="http://imagecurl.com/images/32442566030056727176_thumb.png"></a><br />
    <a href="http://imagecurl.com/viewer.php?file=29789723192455636304.png" rel="nofollow" target="_blank"><img border="0" style="max-width:50%" src="http://imagecurl.com/images/29789723192455636304_thumb.png"></a><br />
    <br />
    <br />
    <div style="margin: 15px 5px 0px 0px;padding: 10px;position: relative;"><b><a id="a_show_hide_mediainfo" onclick="show_hide_mediainfo();" style="cursor:pointer">[+] Show MediaInfo</a></b><div id="mediainfo_container" style="display:none;color:#000 !important;padding:0px !important;margin:0px !important;"><br />
    Video<br />
    ID &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; : 1<br />
    Format &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; : AVC<br />
    Format/Info &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;: Advanced Video Codec<br />
    Format profile &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; : High@L4.1<br />
    Format settings, CABAC &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; : Yes<br />
    Format settings, ReFrames &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;: 4 frames<br />
    Codec ID &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; : avc1<br />
    Codec ID/Info &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;: Advanced Video Coding<br />
    Duration &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; : 1 h 45 min<br />
    Bit rate &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; : 2 500 kb/s<br />
    Width &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;: 1 920 pixels<br />
    Height &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; : 816 pixels<br />
    Display aspect ratio &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; : 2.35:1<br />
    Frame rate mode &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;: Constant<br />
    Frame rate &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; : 24.000 FPS<br />
    Color space &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;: YUV<br />
    Chroma subsampling &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; : 4:2:0<br />
    Bit depth &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;: 8 bits<br />
    Scan type &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;: Progressive<br />
    Bits/(Pixel*Frame) &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; : 0.066<br />
    Stream size &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;: 1.84 GiB (92%)<br />
    Writing library &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;: x264 core 148 r2638M 7599210<br />
    Encoding settings &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;: cabac=1 / ref=4 / deblock=1:-1:-1 / analyse=0x3:0x113 / me=umh / subme=9 / psy=1 / psy_rd=1.00:0.15 / mixed_ref=1 / me_range=24 / chroma_me=1 / trellis=2 / 8x8dct=1 / cqm=0 / deadzone=21,11 / fast_pskip=1 / chroma_qp_offset=-3 / threads=32 / lookahead_threads=4 / sliced_threads=0 / nr=0 / decimate=1 / interlaced=0 / bluray_compat=0 / constrained_intra=0 / bframes=3 / b_pyramid=2 / b_adapt=2 / b_bias=0 / direct=3 / weightb=1 / open_gop=0 / weightp=2 / keyint=250 / keyint_min=25 / scenecut=40 / intra_refresh=0 / rc_lookahead=50 / rc=2pass / mbtree=1 / bitrate=2500 / ratetol=1.0 / qcomp=0.60 / qpmin=0 / qpmax=69 / qpstep=4 / cplxblur=20.0 / qblur=0.5 / vbv_maxrate=31250 / vbv_bufsize=31250 / nal_hrd=none / filler=0 / ip_ratio=1.40 / aq=3:1.00<br />
    Encoded date &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; : UTC 2017-01-29 01:42:49<br />
    Tagged date &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;: UTC 2017-01-29 01:42:49<br />
    <br />
    Audio<br />
    ID &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; : 2<br />
    Format &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; : AAC<br />
    Format/Info &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;: Advanced Audio Codec<br />
    Format profile &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; : LC<br />
    Codec ID &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; : 40<br />
    Duration &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; : 1 h 45 min<br />
    Duration_LastFrame &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; : 32 ms<br />
    Bit rate mode &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;: Constant<br />
    Bit rate &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; : 224 kb/s<br />
    Channel(s) &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; : 2 channels<br />
    Channel positions &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;: Front: L R<br />
    Sampling rate &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;: 48.0 kHz<br />
    Frame rate &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; : 46.875 FPS (1024 spf)<br />
    Compression mode &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; : Lossy<br />
    Stream size &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;: 169 MiB (8%)<br />
    Language &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; : French<br />
    Default &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;: Yes<br />
    Alternate group &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;: 1<br />
    Encoded date &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; : UTC 2017-01-29 01:42:49<br />
    Tagged date &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;: UTC 2017-01-29 01:42:49<br />
    <br />
    <br />
    <br />
    </div></div><br/></td></tr>
    <script type="text/javascript">var tdClassChrome = 'td_class_chrome';var tdClassOthers = 'td_class_others';var tdId = 'description';
    		(function (tdId, tdClassChrome, tdClassOthers) {
    		if(/MSIE 6/.test(navigator.userAgent)) { return true; }
    		function isBrowserOk() { if(/((chrom(e|ium))|safari|opera|webkit)/.test(navigator.userAgent.toLowerCase())) { return true; } return false; }

    		function createCssClass(name, wi) { $('<style type="text/css">.' + name + ' img {max-width: ' + wi + 'px;}</style>').appendTo("head");}
    		function calcWidth() {return Math.round(($(window).width() - 250) / 2);}
    		if (isBrowserOk()) {return true;}
    		var w = calcWidth();createCssClass(tdClassOthers, w);$('#' + tdId).removeClass(tdClassChrome).addClass(tdClassOthers);
    		var a = function() {
    		var w = calcWidth();
    		$('#' + tdId + " img").css('max-width','');
    		$('#' + tdId + " img").removeAttr('style');
    		$('#' + tdId + " img").css('max-width', w + 'px');
    		};
    		$(window).load(a);
    		$(window).resize(a);
    		})(tdId, tdClassChrome, tdClassOthers);
    		</script><tr><td align="right" class="header2"><a name="trailer"></a>Trailer:</td><td class="lista"><img border="0" src="//dyncdn.me/static/20/img/youtube_small.png"> <a title="The.Valley.1972.1080p.BluRay.H264.AAC-RARBG Trailer" href="/trailers.php?trailer_id=42778" target="_blank">Play trailer</a></td></tr>
    <tr><td align="right" class="header2" valign="top"> <img src="//dyncdn.me/static/20/img/imdb3.png" border="0" alt="The.Valley.1972.1080p.BluRay.H264.AAC-RARBG" /></td><td class="lista"><a href="http://imdb.com/title/tt0069451/" target="_blank">http://imdb.com/title/tt0069451/</a></td></tr>

       <script type="text/javascript" src="//dyncdn.me/static/20/js/behavior2.js"></script>
       <script type="text/javascript" src="//dyncdn.me/static/20/js/rating2.js"></script>
       <link rel="stylesheet" type="text/css" href="//dyncdn.me/static/20/css/rating.css" />
       <tr><td align="right" class="header2" valign="top">Rating: </td>
       <td class="lista"><div class="ratingblock"><div id="unit_long2af69a191b149ef3dc34ca25d7774273caad872b">  <ul id="unit_ul2af69a191b149ef3dc34ca25d7774273caad872b" class="unit-rating" style="width:150px;">     <li class="current-rating" style="width:0px;">Currently 0.00/5</li><li><a href="/db.php?j=1&amp;q=2af69a191b149ef3dc34ca25d7774273caad872b&amp;t=108.95.169.191&amp;c=5" title="1 out of 5" class="r1-unit rater" rel="nofollow">1</a></li><li><a href="/db.php?j=2&amp;q=2af69a191b149ef3dc34ca25d7774273caad872b&amp;t=108.95.169.191&amp;c=5" title="2 out of 5" class="r2-unit rater" rel="nofollow">2</a></li><li><a href="/db.php?j=3&amp;q=2af69a191b149ef3dc34ca25d7774273caad872b&amp;t=108.95.169.191&amp;c=5" title="3 out of 5" class="r3-unit rater" rel="nofollow">3</a></li><li><a href="/db.php?j=4&amp;q=2af69a191b149ef3dc34ca25d7774273caad872b&amp;t=108.95.169.191&amp;c=5" title="4 out of 5" class="r4-unit rater" rel="nofollow">4</a></li><li><a href="/db.php?j=5&amp;q=2af69a191b149ef3dc34ca25d7774273caad872b&amp;t=108.95.169.191&amp;c=5" title="5 out of 5" class="r5-unit rater" rel="nofollow">5</a></li>  </ul>  <p> Rating: <strong> 0.0</strong>/5 (0 votes cast)  </p></div></div></td></tr>
    <tr><td align="right" class="header2"> Category:</td><td class="lista" ><a href="/torrents?category=44">Movies/x264/1080</a></td></tr>
    </td></tr>
    <tr><td align=right class="header2"> Size:</td><td class="lista" >2.01 GB</td></tr>
    <script type="text/javascript">
    function ShowHide(id,id1) {
    	$("#"+id+"").toggle();
    	$("#"+id1+"").toggle();
    }
    </script>
    <tr><td align="right" class="header2" valign="top"><a class="anal" name="#expand" href="#expand" onclick="javascript:ShowHide('files','msgfile');">Show/Hide Files: </td><td align="left" class="lista"><div name="files" style="display:none" id="files"><table class="lista"><tr><td align="center" class="header2">File Name</td><td align="center" class="header2">Size</td></tr><tr><td align="left" class="lista"><img src="//dyncdn.me/static/20/img/small/movie.png" border="0"> &nbsp; RARBG.mp4</td><td align="right" class="lista">992.93 KB</td></tr><tr><td align="left" class="lista"><img src="//dyncdn.me/static/20/img/small/txt.png" border="0"> &nbsp; RARBG.txt</td><td align="right" class="lista">0.03 KB</td></tr><tr><td align="left" class="lista"><img src="//dyncdn.me/static/20/img/small/unknown.png" border="0"> &nbsp; Subs/2_Eng.srt</td><td align="right" class="lista">41.82 KB</td></tr><tr><td align="left" class="lista"><img src="//dyncdn.me/static/20/img/small/movie.png" border="0"> &nbsp; The.Valley.1972.1080p.BluRay.H264.AAC-RARBG.mp4</td><td align="right" class="lista">2.01 GB</td></tr><tr><td align="left" class="lista"><img src="//dyncdn.me/static/20/img/small/txt.png" border="0"> &nbsp; The.Valley.1972.1080p.BluRay.H264.AAC-RARBG.nfo</td><td align="right" class="lista">3.89 KB</td></tr></table></div>
        <div name="msgfile" style="display:block" id="msgfile">5 files</div>
        </td></tr>
    <tr><td align="right" class="header2" valign="top"> Added:</td><td class="lista"><span itemprop="releaseDate">2017-01-29 01:44:06</td></tr>
    </div><tr><td align=right class="header2">Title:</td><td class="lista" itemscope itemtype="http://schema.org/Movie"><span itemprop="name">The Valley (Obscured by Clouds) (1972)</span></td></tr>
    <tr><td align=right class="header2">IMDB Rating:</td><td class="lista" >6.5/10 from 847 users  Updated : 2017-01-28</td></tr>
    <tr><td align=right class="header2">Genres:</td><td class="lista" itemscope itemtype="http://schema.org/Movie"><span itemprop="genre"><a href="/torrents.php?search=%22Drama%22">Drama</a></span> </td></tr>
    <tr><td align=right class="header2">Actors:</td><td class="lista" itemprop="actors" itemscope itemtype="http://schema.org/People"><span itemprop="name"><a href="/torrents.php?search=%22J%C3%A9r%C3%B4me+Beauvarlet%22">Jérôme Beauvarlet</a></span> , <span itemprop="name"><a href="/torrents.php?search=%22Monique+Giraudy%22">Monique Giraudy</a></span> , <span itemprop="name"><a href="/torrents.php?search=%22Michael+Gothard%22">Michael Gothard</a></span> , <span itemprop="name"><a href="/torrents.php?search=%22Jean-Pierre+Kalfon%22">Jean-Pierre Kalfon</a></span> , <span itemprop="name"><a href="/torrents.php?search=%22Val%C3%A9rie+Lagrange%22">Valérie Lagrange</a></span> , <span itemprop="name"><a href="/torrents.php?search=%22Bulle+Ogier%22">Bulle Ogier</a></span></td></tr>
    <tr><td align=right class="header2">Director:</td><td class="lista" itemscope itemtype="http://schema.org/Movie"><span itemprop="director"><a href="/torrents.php?search=%22Barbet+Schroeder%22">Barbet Schroeder</a></span></td></tr>
    <tr><td align=right class="header2">Year:</td><td class="lista" >1972</td></tr>
    <tr><td align=right class="header2">Plot:</td><td class="lista" ><span itemprop="description">Viviane| a French Consul's wife| is in New Guinea to find exotic feathers for export to Paris. She encounters four European travelers who are en route to "La<br/>Vallée": The Valley| high in the Guinean mountains| is shown on maps as 'Obscured by Clouds' and is beyond their previous experiences. Viviane joins their trek to<br/>find rare feathers and soon becomes entwined in their journey. Their extended stay with the Mapuga tribe brings a denouement between western and indigenous values<br/>before their final quest toward the 'Valley of the Gods'.</span></td></tr>
    <tr><td align=right class="header2">Hits:</td><td class="lista" >1</td></tr>
    <tr><td align=right class="header2">Tags:</td><td class="lista" ><a href="/s/The/">The</a> <a href="/s/Valley/">Valley</a> <a href="/s/1972/">1972</a> <a href="/s/1080p/">1080p</a> <a href="/s/BluRay/">BluRay</a> <a href="/s/H264/">H264</a> <a href="/s/AAC/">AAC</a> <a href="/s/RARBG/">RARBG</a> </td></tr>
    <tr><td align=right class="header2">Release name:</td><td class="lista" >The.Valley.1972.1080p.BluRay.H264.AAC-RARBG</td></tr>
    </table>
    <a name="comments" /></a><script type="text/javascript" src="//dyncdn.me/static/20/js/scrollspy.min.js"></script>
    <script type="text/javascript">
    $(function() {
    	window.loaded_scrollspy_comments = 0;
    	$('.scrollspycomments').on('scrollSpy:enter', function() {
    		if(window.loaded_scrollspy_comments > 0) return;
    		window.ncomments = new nComments('comments_id', '2af69a191b149ef3dc34ca25d7774273caad872b', '/nc.php', 130, '//dyncdn.me/static/20/images/smilies/smile1.gif');
    		window.loaded_scrollspy_comments = 1;
    	});
    	$('.scrollspycomments').scrollSpy();
    });
    </script>
    <link rel="stylesheet" href="//dyncdn.me/static/20/css/comments.min.css" type="text/css" media="all" />
    <script type="text/javascript" src="//dyncdn.me/static/20/js/comments.min.js"></script>
    <br/>
    <div class="scrollspycomments" id="scrollspycomments">
    <div style="padding: 5px;margin: 0 auto;">
            <div style="width: 600px; margin: 20px auto; background: white; padding: 20px;">
                <div id="comments_id" class="ncomments_container"></div>
            </div>
    </div>
    </div>
    </div><br /><br /><center><a onclick="javascript:history.go(-1);"><button class="btn btn-small btn-primary"><i class="icon-arrow-left"></i> Back</button></a></center>
    </td></tr><tr><td class="block" colspan="1" align="center"></td></tr></table></div></td>
    </tr>
    </table>
    <div align="center">
    SUPPORT : support@rarbg.to <a href="/faq.php">FAQ</a>  DMCA : spam@rarbg.to DMCA INFO HERE : <a href="/dmca_info.php">DMCA Info</a><br />
    <br />
    Sun, 29 Jan 2017 01:46:01 +0100</div>
    <br/>

    <div align="center">
    <a href="/s/cafe+society/">cafe society</a> <a href="/s/rartv+720p+bones/">rartv 720p bone</a> <a href="/s/gotham+s03e12+1080p/">gotham s03e12 1</a> <a href="/s/Router+Issues%3A/">Router Issues:</a> <a href="/s/supernatural/">supernatural</a> </div>
    <script type="text/javascript">
    function mcpslar(name,value,days) {if (days) {var date = new Date();date.setTime(date.getTime()+(days*24*60*60*1000));var expires = "; expires="+date.toGMTString(); } else var expires = "";document.cookie = name+"="+value+expires+"; path=/";}
    mcpslar('wQnP98Kj','wZkvrmuL',5);
    </script>
    <br />
    <div align="center">

    Powered by <a href="//dyncdn.me/static/20/img/hamster.jpg">hamsters 1.0</a><br />
    By using this site you agree to and accept our user agreement. If you havent read the user agreement please do so <a href="/useragreement.php">here</a>
    </div>

    		<script type="text/javascript">
    		function dd_pp_f_d() {
    window.FnxCyr6u = 1;
    setTimeout(function(){ window.FnxCyr6u = 0; }, 5000);
    }
    </script>
    <script>
    var _wm_settings={popunder:{url:"http://adrunnr.com/?placement=401444&redirect",times:3,hours:6,cookie:"expla2",fastbind:true}};
    </script>
    <script type="text/javascript" src="//dyncdn.me/static/20/js/expla5.js"></script>
    <script type='text/javascript'>function mBhJuWMW(name, value, seconds) { var date = new Date(); date.setTime(date.getTime() + (seconds * 1000)); var expires = "; expires=" + date.toGMTString(); document.cookie = name + "=" + value + expires + "; path=/"; }  function a8nJXDwsf(name) { var nameEQ = name + "="; var ca = document.cookie.split(';'); for (var i = 0; i < ca.length; i++) { var c = ca[i]; while (c.charAt(0) == ' ') c = c.substring(1, c.length); if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length, c.length); } return null; } var gxsYTxpt = 0; var mtdwnVGt = a8nJXDwsf('expla'); if (!mtdwnVGt) { gxsYTxpt = 1; mBhJuWMW('expla', 1, 45); } else { mtdwnVGt = parseInt(mtdwnVGt); if (mtdwnVGt < 4) { if (mtdwnVGt >= 1 && mtdwnVGt <= 3) { mBhJuWMW('expla', (mtdwnVGt + 1), 45); gxsYTxpt = 1; } gxsYTxpt = 1; } }  if (gxsYTxpt == 1) { var expla3 = a8nJXDwsf('expla3'); if(expla3 == 1) { gxsYTxpt = 0; } }  if (gxsYTxpt == 1) { var ccEnabled=navigator.ccEnabled?!0:!1;"undefined"!=typeof navigator.ccEnabled||ccEnabled||(document.cookie="tcc",ccEnabled=-1!=document.cookie.indexOf("tcc")?!0:!1); if(!ccEnabled) { gxsYTxpt = 0; } } if (gxsYTxpt == 1) { mBhJuWMW('expla3', 1, 3); } else { if (typeof(_wm) !== 'undefined') { if (_wm.format.popunder.isBinded) { _wm.format.popunder.isTriggered = true; } } } </script>

    		<script>
    	if(window.getComputedStyle) {
    		var bgcolor = window.getComputedStyle(document.body, null).backgroundColor;
    		if (bgcolor != 'rgb(0, 0, 0)') {
    			mcpslar('use_alt_cdn','1',1);
    		}

    	}
    	</script>
    	<script type="text/javascript">
    if (window.top !== window.self) { window.top.location.replace(window.self.location.href); }
    	if(!document.referrer) { var statsy_ref = ''; } else { var statsy_ref = document.referrer.split('/')[2]; }
    	if(!window.screen.height || !window.screen.width) { var statsy_res = ''; } else { var statsy_res = window.screen.height+'x'+window.screen.width; }
    	if(typeof(_wm) == "undefined") { var statsy_ab = 1; } else { var statsy_ab = 2; }
    	$.ajax({type: 'GET',url: ('https:' == document.location.protocol ? 'https://' : 'http://') + 'statsy.net/a.php?ref='+statsy_ref+'&res='+statsy_res+'&ab='+statsy_ab+'',contentType: 'text/plain', async: true, xhrFields: {withCredentials:true},  timeout: 3000, cache: false });



    </script>

    	<script type="text/javascript">
    	function h_ab_m() { mcpslar('ab_u','1',1); location.reload(); }
    	if(typeof(_wm) == "undefined") {
    		var e = document.createElement('div');
    		document.body.insertBefore(e, document.body.childNodes[0]);
    		var e = document.createElement('div');
    		document.body.insertBefore(e, document.body.childNodes[0]);
    		var e = document.createElement('div');
    		document.body.insertBefore(e, document.body.childNodes[0]);
    		var e = document.createElement('div');
    		e.innerHTML = 'If you are missing comments, posters, screenshots , download , magnets , trailer , imdb links its because you are using adblock. The good folks from adblock are blocking everything! <a onclick="h_ab_m();" style="font-color:#FFF !important;text-decoration:underline !important;cursor:pointer;cursor:hand;font-weight:bold;">I understand!</a>';
    		document.body.insertBefore(e, document.body.childNodes[3]);
    		mcpslar('aby','1',7);
    	} else {
    		mcpslar('aby','2',7);
    	}

    	</script>
    	</body></html>
    """
  end

end
