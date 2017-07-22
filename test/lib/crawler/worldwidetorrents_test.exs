defmodule Magnetissimo.Crawler.WorldWideTorrentsTest do
  use ExUnit.Case, async: true

  test "scrapes torrent information from page" do
    torrents = Magnetissimo.Crawler.WorldWideTorrents.torrent_information(list_sample())
    assert torrents != nil
  end

  def list_sample do
    """
    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml">
    <head><meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
    <title>WorldWide Torrents : Browse Torrents</title>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <meta http-equiv="X-UA-Compatible" content="IE=9"/>
    <meta http-equiv="cache-control" content="no-cache"/>
    <meta http-equiv="pragma" content="no-cache"/>
    <meta name="author" content="World Wide Torrents"/>
    <meta name="generator" content="World Wide Torrents"/>
    <meta name="description" content="WorldWide Torrents Community, A place to download TV series, movies, music, games torrents, make friends and to have fun, A Place to call home"/>
    <meta name="keywords" content="torrents, worldwide torrents, WWRG, WWT, torrents download, browse torrents, search torrents, best torrent site, fast torrent download, safe torrents, Movie torrents, TV torrents, Ebook torrents, Music Torrents, Games Torrent, kat alternative, torrentz alternative,"/>


    <script type="text/javascript">
    //<![CDATA[
    try{if (!window.CloudFlare) {var CloudFlare=[{verbose:0,p:0,byc:0,owlid:"cf",bag2:1,mirage2:0,oracle:0,paths:{cloudflare:"/cdn-cgi/nexp/dok3v=1613a3a185/"},atok:"039d0bf706437cb4584d30bfd59bc69d",petok:"c18a2d06aecd328cff1cc03bb832e912584a6fa9-1485658683-1800",zone:"worldwidetorrents.eu",rocket:"a",apps:0}];document.write('<script type="text/javascript" src="//ajax.cloudflare.com/cdn-cgi/nexp/dok3v=f2befc48d1/cloudflare.min.js"><'+'\/script>');}}catch(e){};
    //]]>
    </script>
    <link rel="shortcut icon" href="/themes/NB-TT-2c/images/favicon.ico"/>
    <link rel="stylesheet" type="text/css" href="/themes/NB-TT-2c/theme.css"/>
    <link rel="stylesheet" type="text/css" href="/css/glyphicons.css"/>
    <!--[if IE]>
        <link rel="stylesheet" type="text/css" href="/themes/NB-TT-2c/css/ie.css" />
    <![endif]-->

    <script type="text/rocketscript" data-rocketsrc="/backend/java_klappe.js"></script>
    <!--[if lte IE 6]>
        <script type="text/javascript" src="/themes/NB-TT-2c/js/pngfix/supersleight-min.js"></script>
    <![endif]-->
    </head>

    <body>
    <div id='wrapper'>
    <div id='header'>
    <div id='infobar'>

    <div class="fltLeft">
    <form action="/torrents-search.php" method="get"><input type="text" name="search" placeholder="Enter Search Keyword" size="40" style="padding: 1px 20px; border-radius: 2px; border: 0px currentColor; border-image: none; height: 22px;" autocomplete="off"> <input type="submit" value="Search Torrents" style="border-radius: 2px; border: 0px currentColor; border-image: none; height: 24px;"/></form>
    </div>
    <div class="fltRight">
    <a href="/account-login-signup.php">Login/Sign Up</a>
    </div>

    </div>
    <div class='header'>
    <a href='/'><div id='logo'></div></a>
    </div>
    <div id='menu'>

    <ul class='menu' id='torrents?page=0'>
    <li class='myLink1'><a href='/index.php'><span>Home</span></a></li>
    <li class='myLink2'><a href='/forums.php'><span>Forums</span></a></li>
    <li class='myLink3'><a href='/torrents-upload.php'><span>Upload Torrent</span></a></li>
    <li class='myLink4'><a href='/torrents.php'><span>Browse Torrents</span></a></li>
    <li class='myLink5'><a href='/torrents-today.php'><span>Today's Torrents</span></a></li>
    <li class='myLink6'><a href='/torrents-search.php'><span>Search Torrents</span></a></li>
    <li class='myLink7'><a href='/faq.php'><span>FAQ</span></a></li>
    </ul>

    </div>
    </div>
    <div class='myTable'>
    <div class='myTrow'>
    <div class='shad-l'><img src='/themes/NB-TT-2c/images/blank.gif' width='9px' height='9px' alt='blank'/></div>
    <div class='main'>
    <table width='100%' border='0' cellspacing='10' cellpadding='0'>
    <tr>
    <td valign='top'>
    <script type="text/rocketscript" data-rocketsrc="https://trust.zone/api_ip_info.php?js=1"></script>
    <div style="text-align:center;font-family:Tahoma;">
    <div style="font-size:18pt;padding:10px 0;text-align:center;color:red;">
    Warning! Use a VPN When Downloading Torrents!
    </div>
    <div style="padding:0 0 8px;font-size:14px;line-height:25px;">
    <div style="font-weight:bold;">
    Your IP Address is <span style="color:red"><script lang="javascript" type="text/rocketscript">document.write(tz_ipaddress);</script></span>. Location is <span style="color:red"><script lang="javascript" type="text/rocketscript">document.write(tz_country)</script></span>
    </div>
    Your Internet Provider <span style="color:red;font-weight:bold;"><script type="text/rocketscript">document.write(tz_isp)</script></span> is tracking your torrent activity! Hide your IP ADDRESS with a VPN!<br/>
    We strongly recommend using <a href="https://trust.zone/go/r.php?RID=B-0Xc1y-MDAxNDg0NzIzMDQ0" style="text-decoration:underline" target="_blank">Trust.Zone VPN</a> to anonymize your torrenting. <span style="color:red;font-weight:bold;">It's FREE!</span>
    </div>
    <a href="https://trust.zone/go/r.php?RID=B-0Xc1y-MDAxNDg0NzIzMDQ0" target="_blank" style="width:200px;margin:10px auto;display:block;text-decoration:none;font-size:14px;background:#e02c3c;color:#fff;border-radius:4px;padding:7px 0 8px;font-weight:bold;border:1px solid black;" onmouseover="this.style.color='#000';" onmouseout="this.style.color='#fff';">
    Get VPN Now for FREE!
    </a>
    </div>

    <script data-rocketsrc="https://code.jquery.com/jquery-1.12.4.min.js" type="text/rocketscript"></script><div class='myFrame'>
    <div class='myF-caption'>Browse Torrents</div>
    <div class='wrapper'>
    <div class='myF-content'><center><b>Categories:</b> - <a href='torrents.php'>Show all of</a> - <a href='torrents.php?parent_cat=Anime'>Anime</a> - <a href='torrents.php?parent_cat=Apps'>Apps</a> - <a href='torrents.php?parent_cat=Books'>Books</a> - <a href='torrents.php?parent_cat=Comics'>Comics</a> - <a href='torrents.php?parent_cat=Documentaries'>Documentaries</a> - <a href='torrents.php?parent_cat=Games'>Games</a> - <a href='torrents.php?parent_cat=Movies'>Movies</a> - <a href='torrents.php?parent_cat=Music'>Music</a> - <a href='torrents.php?parent_cat=Other'>Other</a> - <a href='torrents.php?parent_cat=TV'>TV</a> - <a href='torrents.php?parent_cat=TV%2FHD'>TV/HD</a> - <a href='torrents.php?parent_cat=Unity+Asset'>Unity Asset</a> - <a href='torrents.php?parent_cat=XXX'>XXX</a><br/><br/>
    </center><br/><br/><div align='right'><form id='sort' action=''>Sort By: <select name='sort' onchange='window.location="torrents.php?sort="+this.options[this.selectedIndex].value+"&amp;order="+document.forms["sort"].order.options[document.forms["sort"].order.selectedIndex].value'><option value='id' selected='selected'>Added</option><option value='name'>Name</option><option value='comments'>Comments</option><option value='size'>Size</option><option value='times_completed'>Completed</option><option value='seeders'>Seeders</option><option value='leechers'>Leechers</option></select>&nbsp;<select name='order' onchange='window.location="torrents.php?order="+this.options[this.selectedIndex].value+"&amp;sort="+document.forms["sort"].sort.options[document.forms["sort"].sort.selectedIndex].value'><option selected='selected' value='asc'>Ascend</option><option value='desc' selected='selected'>Descend</option></select></form></div><table align="center" class="ttable_headinner" width="100%"><thead><tr class="ttable_head"><th width='750' height='5' anligne align='center'>Torrents Name</th><th width='35' height='1'>DL</th><th width='35' height='1'><img src='https://worldwidetorrents.eu/images/mag.png' alt="magnet"/></th><th width='35' height='1' anligne align='center'><img src='https://worldwidetorrents.eu/images/com.png' alt="CM"/></th><th width='74' height='1' anligne align='center'>Size</th><th width='60'>S</th><th width='60'>L</th><th width='54' height='1' anligne align='center'>Age</th><th width='74' height='1' anligne align='center'>Health</th></tr></thead><tr class='t-row'>
    <td class='ttable_col1' nowrap='nowrap'>&nbsp;<a title="The Autumnlands + Tooth & Claw (001-014+TPB v01) (2014-2017) (digital) (Minutemen-Slayer+Son of Ultron-Empire) (Rq) (- Nem -)" href="torrents-details.php?id=43274&amp;hit=1"><b>The Autumnlands + Tooth &amp; Claw (001-014+TPB v01) (2014-2017) (digital) (Minutemen-Slayer+Son of Ultr...</b></a></br></br><sup>by <a href='account-details.php?id=36'><font color='#45968B'>Nemesis43</font></a> in <a title="Comics" href="torrents.php?parent_cat=Comics">Comics</a>&nbsp;> <a title="Nem43 Comics" href="torrents.php?cat=132">Nem43 Comics</a></sup></td><td class='ttable_col2' align='center'><a href="download.php?id=43274&amp;name=The%20Autumnlands%20%2B%20Tooth%20%26%20Claw%20%28001-014%2B%29%282014-2017%29%28digital%29%28Minutemen-Slayer%2B%29.torrent"><img src='https://worldwidetorrents.eu/images/downl.png' border='0' alt="Download .torrent"/></a></td><td class='ttable_col1' align='center'><a href="magnet:?xt=urn:btih:91c09f08bf2895727fffad3dab3d01d4cbcabfa8&dn=The%20Autumnlands%20%2B%20Tooth%20%26%20Claw%20%28001-014%2B%29%282014-2017%29%28digital%29%28Minutemen-Slayer%2B%29.torrent&tr=udp://tracker.coppersurfer.tk:6969/announce">&nbsp;<sole><img src="https://worldwidetorrents.eu/images/mag.png"></a></td><td class='ttable_col2' align='center'><font size='1' face='verdana'><a href='comments.php?type=torrent&amp;id=43274'>0<img src='https://worldwidetorrents.eu/images/com.png' alt="CM"/></a></font></td><td class='ttable_col1' align='center'>1.19 GB</td>
    <td class='ttable_col2' align='center'><font color='green'><b>0</b></font></td>
    <td class='ttable_col1' align='center'><font color='#ff0000'><b>0</b></font></td>
    <td class='ttable_col2' align='center'>8 mins ago</td><td class='ttable_col1' align='center'><img src='https://worldwidetorrents.eu/images/health/health_0.gif' alt=''/></td>
    </tr>
    <tr class='t-row'>
    <td class='ttable_col1' nowrap='nowrap'>&nbsp;<a title="Apocalypse The Second World War 720p" href="torrents-details.php?id=43273&amp;hit=1"><b>Apocalypse The Second World War 720p</b></a></br></br><sup>by <a href='account-details.php?id=1506'><font color='#7CFC00'>WarhoundOne</font></a> in <a title="TV" href="torrents.php?parent_cat=TV">TV</a>&nbsp;> <a title="HD" href="torrents.php?cat=41">HD</a></sup></td><td class='ttable_col2' align='center'><a href="download.php?id=43273&amp;name=Apocalypse%20The%20Second%20World%20War%20720p.torrent"><img src='https://worldwidetorrents.eu/images/downl.png' border='0' alt="Download .torrent"/></a></td><td class='ttable_col1' align='center'><a href="magnet:?xt=urn:btih:482f9296d5699ca245f38083ebee98043200697e&dn=Apocalypse%20The%20Second%20World%20War%20720p.torrent&tr=udp://tracker.leechers-paradise.org:6969/announce">&nbsp;<sole><img src="https://worldwidetorrents.eu/images/mag.png"></a></td><td class='ttable_col2' align='center'><font size='1' face='verdana'><a href='comments.php?type=torrent&amp;id=43273'>0<img src='https://worldwidetorrents.eu/images/com.png' alt="CM"/></a></font></td><td class='ttable_col1' align='center'>6.27 GB</td>
    <td class='ttable_col2' align='center'><font color='green'><b>19</b></font></td>
    <td class='ttable_col1' align='center'><font color='#ff0000'><b>18</b></font></td>
    <td class='ttable_col2' align='center'>17 mins ago</td><td class='ttable_col1' align='center'><img src='https://worldwidetorrents.eu/images/health/health_10.gif' alt=''/></td>
    </tr>
    <tr class='t-row'>
    <td class='ttable_col1' nowrap='nowrap'>&nbsp;<a title="Apocalypse - World War One" href="torrents-details.php?id=43272&amp;hit=1"><b>Apocalypse - World War One</b></a></br></br><sup>by <a href='account-details.php?id=1506'><font color='#7CFC00'>WarhoundOne</font></a> in <a title="TV" href="torrents.php?parent_cat=TV">TV</a>&nbsp;> <a title="HD" href="torrents.php?cat=41">HD</a></sup></td><td class='ttable_col2' align='center'><a href="download.php?id=43272&amp;name=Apocalypse%20-%20World%20War%20One.torrent"><img src='https://worldwidetorrents.eu/images/downl.png' border='0' alt="Download .torrent"/></a></td><td class='ttable_col1' align='center'><a href="magnet:?xt=urn:btih:d644c9866e10b06b77f55438205785b921f287b8&dn=Apocalypse%20-%20World%20War%20One.torrent&tr=udp://tracker.leechers-paradise.org:6969/announce">&nbsp;<sole><img src="https://worldwidetorrents.eu/images/mag.png"></a></td><td class='ttable_col2' align='center'><font size='1' face='verdana'><a href='comments.php?type=torrent&amp;id=43272'>0<img src='https://worldwidetorrents.eu/images/com.png' alt="CM"/></a></font></td><td class='ttable_col1' align='center'>4.91 GB</td>
    <td class='ttable_col2' align='center'><font color='green'><b>21</b></font></td>
    <td class='ttable_col1' align='center'><font color='#ff0000'><b>24</b></font></td>
    <td class='ttable_col2' align='center'>19 mins ago</td><td class='ttable_col1' align='center'><img src='https://worldwidetorrents.eu/images/health/health_9.gif' alt=''/></td>
    </tr>
    <tr class='t-row'>
    <td class='ttable_col1' nowrap='nowrap'>&nbsp;<a title="National Geographic - MARS Complete Series 720p" href="torrents-details.php?id=43271&amp;hit=1"><b>National Geographic - MARS Complete Series 720p</b></a></br></br><sup>by <a href='account-details.php?id=1506'><font color='#7CFC00'>WarhoundOne</font></a> in <a title="TV" href="torrents.php?parent_cat=TV">TV</a>&nbsp;> <a title="HD" href="torrents.php?cat=41">HD</a></sup></td><td class='ttable_col2' align='center'><a href="download.php?id=43271&amp;name=National%20Geographic%20-%20MARS%20Complete%20Series%20720p.torrent"><img src='https://worldwidetorrents.eu/images/downl.png' border='0' alt="Download .torrent"/></a></td><td class='ttable_col1' align='center'><a href="magnet:?xt=urn:btih:b89cfdb746aa79840f78b3af23c82c61e642b191&dn=National%20Geographic%20-%20MARS%20Complete%20Series%20720p.torrent&tr=udp://tracker.leechers-paradise.org:6969/announce">&nbsp;<sole><img src="https://worldwidetorrents.eu/images/mag.png"></a></td><td class='ttable_col2' align='center'><font size='1' face='verdana'><a href='comments.php?type=torrent&amp;id=43271'>0<img src='https://worldwidetorrents.eu/images/com.png' alt="CM"/></a></font></td><td class='ttable_col1' align='center'>4.14 GB</td>
    <td class='ttable_col2' align='center'><font color='green'><b>203</b></font></td>
    <td class='ttable_col1' align='center'><font color='#ff0000'><b>130</b></font></td>
    <td class='ttable_col2' align='center'>25 mins ago</td><td class='ttable_col1' align='center'><img src='https://worldwidetorrents.eu/images/health/health_10.gif' alt=''/></td>
    </tr>
    <tr class='t-row'>
    <td class='ttable_col1' nowrap='nowrap'>&nbsp;<a title="Dirty Mature Friends Boating Orgy On An Lake" href="torrents-details.php?id=43270&amp;hit=1"><b>Dirty Mature Friends Boating Orgy On An Lake</b></a></br></br><sup>by <a href='account-details.php?id=8557'><font color='#dc9100'>egool</font></a> in <a title="XXX" href="torrents.php?parent_cat=XXX">XXX</a>&nbsp;> <a title="Pictures" href="torrents.php?cat=71">Pictures</a></sup></td><td class='ttable_col2' align='center'><a href="download.php?id=43270&amp;name=Dirty%20Mature%20Friends%20Boating%20Orgy%20On%20An%20Lake.torrent"><img src='https://worldwidetorrents.eu/images/downl.png' border='0' alt="Download .torrent"/></a></td><td class='ttable_col1' align='center'><a href="magnet:?xt=urn:btih:87236c4ad29bfb359fb0a3a5223c585c7b1e208a&dn=Dirty%20Mature%20Friends%20Boating%20Orgy%20On%20An%20Lake.torrent&tr=udp://62.138.0.158:1337/announce">&nbsp;<sole><img src="https://worldwidetorrents.eu/images/mag.png"></a></td><td class='ttable_col2' align='center'><font size='1' face='verdana'><a href='comments.php?type=torrent&amp;id=43270'>0<img src='https://worldwidetorrents.eu/images/com.png' alt="CM"/></a></font></td><td class='ttable_col1' align='center'>30.22 MB</td>
    <td class='ttable_col2' align='center'><font color='green'><b>0</b></font></td>
    <td class='ttable_col1' align='center'><font color='#ff0000'><b>0</b></font></td>
    <td class='ttable_col2' align='center'>25 mins ago</td><td class='ttable_col1' align='center'><img src='https://worldwidetorrents.eu/images/health/health_0.gif' alt=''/></td>
    </tr>
    <tr class='t-row'>
    <td class='ttable_col1' nowrap='nowrap'>&nbsp;<a title="WWE NXT TakeOver San Antonio Pre Show 720p WEB h264-HEEL [TJET]" href="torrents-details.php?id=43269&amp;hit=1"><b>WWE NXT TakeOver San Antonio Pre Show 720p WEB h264-HEEL [TJET]</b></a></br></br><sup>by <a href='account-details.php?id=1506'><font color='#7CFC00'>WarhoundOne</font></a> in <a title="TV/HD" href="torrents.php?parent_cat=TV/HD">TV/HD</a>&nbsp;> <a title="Sports" href="torrents.php?cat=113">Sports</a></sup></td><td class='ttable_col2' align='center'><a href="download.php?id=43269&amp;name=WWE%20NXT%20TakeOver%20San%20Antonio%20Pre%20Show%20720p%20WEB%20h264-HEEL%20%5BTJET%5D.torrent"><img src='https://worldwidetorrents.eu/images/downl.png' border='0' alt="Download .torrent"/></a></td><td class='ttable_col1' align='center'><a href="magnet:?xt=urn:btih:795d7e89f7d9d562d6dcfa67f11e185699214671&dn=WWE%20NXT%20TakeOver%20San%20Antonio%20Pre%20Show%20720p%20WEB%20h264-HEEL%20%5BTJET%5D.torrent&tr=udp://tracker.ilibr.org:80/announce">&nbsp;<sole><img src="https://worldwidetorrents.eu/images/mag.png"></a></td><td class='ttable_col2' align='center'><font size='1' face='verdana'><a href='comments.php?type=torrent&amp;id=43269'>0<img src='https://worldwidetorrents.eu/images/com.png' alt="CM"/></a></font></td><td class='ttable_col1' align='center'>1.88 GB</td>
    <td class='ttable_col2' align='center'><font color='green'><b>22</b></font></td>
    <td class='ttable_col1' align='center'><font color='#ff0000'><b>109</b></font></td>
    <td class='ttable_col2' align='center'>37 mins ago</td><td class='ttable_col1' align='center'><img src='https://worldwidetorrents.eu/images/health/health_2.gif' alt=''/></td>
    </tr>
    <tr class='t-row'>
    <td class='ttable_col1' nowrap='nowrap'>&nbsp;<a title="WWE NXT TakeOver San Antonio Pre Show WEB h264-HEEL [TJET]" href="torrents-details.php?id=43268&amp;hit=1"><b>WWE NXT TakeOver San Antonio Pre Show WEB h264-HEEL [TJET]</b></a></br></br><sup>by <a href='account-details.php?id=1506'><font color='#7CFC00'>WarhoundOne</font></a> in <a title="TV/HD" href="torrents.php?parent_cat=TV/HD">TV/HD</a>&nbsp;> <a title="Sports" href="torrents.php?cat=113">Sports</a></sup></td><td class='ttable_col2' align='center'><a href="download.php?id=43268&amp;name=WWE%20NXT%20TakeOver%20San%20Antonio%20Pre%20Show%20WEB%20h264-HEEL%20%5BTJET%5D.torrent"><img src='https://worldwidetorrents.eu/images/downl.png' border='0' alt="Download .torrent"/></a></td><td class='ttable_col1' align='center'><a href="magnet:?xt=urn:btih:14ae9d604effe30ad497eda3e1cf4dcd4e8a2b1e&dn=WWE%20NXT%20TakeOver%20San%20Antonio%20Pre%20Show%20WEB%20h264-HEEL%20%5BTJET%5D.torrent&tr=udp://tracker.ilibr.org:80/announce">&nbsp;<sole><img src="https://worldwidetorrents.eu/images/mag.png"></a></td><td class='ttable_col2' align='center'><font size='1' face='verdana'><a href='comments.php?type=torrent&amp;id=43268'>0<img src='https://worldwidetorrents.eu/images/com.png' alt="CM"/></a></font></td><td class='ttable_col1' align='center'>770.26 MB</td>
    <td class='ttable_col2' align='center'><font color='green'><b>73</b></font></td>
    <td class='ttable_col1' align='center'><font color='#ff0000'><b>237</b></font></td>
    <td class='ttable_col2' align='center'>39 mins ago</td><td class='ttable_col1' align='center'><img src='https://worldwidetorrents.eu/images/health/health_3.gif' alt=''/></td>
    </tr>
    <tr class='t-row'>
    <td class='ttable_col1' nowrap='nowrap'>&nbsp;<a title="Curvy American Blonde Mature Naked In And Outdoor" href="torrents-details.php?id=43267&amp;hit=1"><b>Curvy American Blonde Mature Naked In And Outdoor</b></a></br></br><sup>by <a href='account-details.php?id=8557'><font color='#dc9100'>egool</font></a> in <a title="XXX" href="torrents.php?parent_cat=XXX">XXX</a>&nbsp;> <a title="Pictures" href="torrents.php?cat=71">Pictures</a></sup></td><td class='ttable_col2' align='center'><a href="download.php?id=43267&amp;name=Curvy%20American%20Blonde%20Mature%20Naked%20In%20And%20Outdoor.torrent"><img src='https://worldwidetorrents.eu/images/downl.png' border='0' alt="Download .torrent"/></a></td><td class='ttable_col1' align='center'><a href="magnet:?xt=urn:btih:011419abeba6bbca3670a8aade60e2399b2f00fa&dn=Curvy%20American%20Blonde%20Mature%20Naked%20In%20And%20Outdoor.torrent&tr=udp://62.138.0.158:1337/announce">&nbsp;<sole><img src="https://worldwidetorrents.eu/images/mag.png"></a></td><td class='ttable_col2' align='center'><font size='1' face='verdana'><a href='comments.php?type=torrent&amp;id=43267'>0<img src='https://worldwidetorrents.eu/images/com.png' alt="CM"/></a></font></td><td class='ttable_col1' align='center'>84.44 MB</td>
    <td class='ttable_col2' align='center'><font color='green'><b>0</b></font></td>
    <td class='ttable_col1' align='center'><font color='#ff0000'><b>0</b></font></td>
    <td class='ttable_col2' align='center'>43 mins ago</td><td class='ttable_col1' align='center'><img src='https://worldwidetorrents.eu/images/health/health_0.gif' alt=''/></td>
    </tr>
    <tr class='t-row'>
    <td class='ttable_col1' nowrap='nowrap'>&nbsp;<a title="Jacqueline Koyanagi - [Tangled Axon 01] - Ascension Epub [WHO]" href="torrents-details.php?id=43266&amp;hit=1"><b>Jacqueline Koyanagi - [Tangled Axon 01] - Ascension Epub [WHO]</b></a></br></br><sup>by <a href='account-details.php?id=1506'><font color='#7CFC00'>WarhoundOne</font></a> in <a title="Books" href="torrents.php?parent_cat=Books">Books</a>&nbsp;> <a title="Fiction" href="torrents.php?cat=54">Fiction</a></sup></td><td class='ttable_col2' align='center'><a href="download.php?id=43266&amp;name=Jacqueline%20Koyanagi%20-%20%5BTangled%20Axon%2001%5D%20-%20Ascension%20%28epub%29.epub.torrent"><img src='https://worldwidetorrents.eu/images/downl.png' border='0' alt="Download .torrent"/></a></td><td class='ttable_col1' align='center'><a href="magnet:?xt=urn:btih:b34bf60e57e004335983a62067007b793cf6ee4c&dn=Jacqueline%20Koyanagi%20-%20%5BTangled%20Axon%2001%5D%20-%20Ascension%20%28epub%29.epub.torrent&tr=udp://tracker.zer0day.to:1337/announce">&nbsp;<sole><img src="https://worldwidetorrents.eu/images/mag.png"></a></td><td class='ttable_col2' align='center'><font size='1' face='verdana'><a href='comments.php?type=torrent&amp;id=43266'>0<img src='https://worldwidetorrents.eu/images/com.png' alt="CM"/></a></font></td><td class='ttable_col1' align='center'>506.98 kB</td>
    <td class='ttable_col2' align='center'><font color='green'><b>0</b></font></td>
    <td class='ttable_col1' align='center'><font color='#ff0000'><b>1</b></font></td>
    <td class='ttable_col2' align='center'>58 mins ago</td><td class='ttable_col1' align='center'><img src='https://worldwidetorrents.eu/images/health/health_0.gif' alt=''/></td>
    </tr>
    <tr class='t-row'>
    <td class='ttable_col1' nowrap='nowrap'>&nbsp;<a title="Barley Legal Vacation Teens Topless And Naked 2" href="torrents-details.php?id=43265&amp;hit=1"><b>Barley Legal Vacation Teens Topless And Naked 2</b></a></br></br><sup>by <a href='account-details.php?id=8557'><font color='#dc9100'>egool</font></a> in <a title="XXX" href="torrents.php?parent_cat=XXX">XXX</a>&nbsp;> <a title="Pictures" href="torrents.php?cat=71">Pictures</a></sup></td><td class='ttable_col2' align='center'><a href="download.php?id=43265&amp;name=Barley%20Legal%20Vacation%20Teens%20Topless%20And%20Naked%202.torrent"><img src='https://worldwidetorrents.eu/images/downl.png' border='0' alt="Download .torrent"/></a></td><td class='ttable_col1' align='center'><a href="magnet:?xt=urn:btih:3f7effb1ee6e722645beea0241617398994c2364&dn=Barley%20Legal%20Vacation%20Teens%20Topless%20And%20Naked%202.torrent&tr=udp://62.138.0.158:1337/announce">&nbsp;<sole><img src="https://worldwidetorrents.eu/images/mag.png"></a></td><td class='ttable_col2' align='center'><font size='1' face='verdana'><a href='comments.php?type=torrent&amp;id=43265'>0<img src='https://worldwidetorrents.eu/images/com.png' alt="CM"/></a></font></td><td class='ttable_col1' align='center'>15.54 MB</td>
    <td class='ttable_col2' align='center'><font color='green'><b>0</b></font></td>
    <td class='ttable_col1' align='center'><font color='#ff0000'><b>0</b></font></td>
    <td class='ttable_col2' align='center'>59 mins ago</td><td class='ttable_col1' align='center'><img src='https://worldwidetorrents.eu/images/health/health_0.gif' alt=''/></td>
    </tr>
    <tr class='t-row'>
    <td class='ttable_col1' nowrap='nowrap'>&nbsp;<a title="Seanan McGuire - Every Heart a Doorway Epub [WHO]" href="torrents-details.php?id=43264&amp;hit=1"><b>Seanan McGuire - Every Heart a Doorway Epub [WHO]</b></a></br></br><sup>by <a href='account-details.php?id=1506'><font color='#7CFC00'>WarhoundOne</font></a> in <a title="Books" href="torrents.php?parent_cat=Books">Books</a>&nbsp;> <a title="Fiction" href="torrents.php?cat=54">Fiction</a></sup></td><td class='ttable_col2' align='center'><a href="download.php?id=43264&amp;name=Seanan%20McGuire%20-%20Every%20Heart%20a%20Doorway%20%28retail%29%20%28epub%29.epub.torrent"><img src='https://worldwidetorrents.eu/images/downl.png' border='0' alt="Download .torrent"/></a></td><td class='ttable_col1' align='center'><a href="magnet:?xt=urn:btih:cc0c98f3be4dd14f570f0f11f91afc41623085a6&dn=Seanan%20McGuire%20-%20Every%20Heart%20a%20Doorway%20%28retail%29%20%28epub%29.epub.torrent&tr=udp://tracker.zer0day.to:1337/announce">&nbsp;<sole><img src="https://worldwidetorrents.eu/images/mag.png"></a></td><td class='ttable_col2' align='center'><font size='1' face='verdana'><a href='comments.php?type=torrent&amp;id=43264'>0<img src='https://worldwidetorrents.eu/images/com.png' alt="CM"/></a></font></td><td class='ttable_col1' align='center'>939.77 kB</td>
    <td class='ttable_col2' align='center'><font color='green'><b>0</b></font></td>
    <td class='ttable_col1' align='center'><font color='#ff0000'><b>0</b></font></td>
    <td class='ttable_col2' align='center'>1 hr ago</td><td class='ttable_col1' align='center'><img src='https://worldwidetorrents.eu/images/health/health_0.gif' alt=''/></td>
    </tr>
    <tr class='t-row'>
    <td class='ttable_col1' nowrap='nowrap'>&nbsp;<a title="[Comix] Twenty 4 (Erich von Gotha, lamusardine) [All Sex, Group sex] " href="torrents-details.php?id=43263&amp;hit=1"><b>[Comix] Twenty 4 (Erich von Gotha, lamusardine) [All Sex, Group sex] </b></a></br></br><sup>by <a href='account-details.php?id=8557'><font color='#dc9100'>egool</font></a> in <a title="XXX" href="torrents.php?parent_cat=XXX">XXX</a>&nbsp;> <a title="Pictures" href="torrents.php?cat=71">Pictures</a></sup></td><td class='ttable_col2' align='center'><a href="download.php?id=43263&amp;name=%5BComix%5D%20Twenty%204%20%28Erich%20von%20Gotha%2C%20lamusardine%29%20%5BAll%20Sex%2C%20Group%20sex%5D.torrent"><img src='https://worldwidetorrents.eu/images/downl.png' border='0' alt="Download .torrent"/></a></td><td class='ttable_col1' align='center'><a href="magnet:?xt=urn:btih:3fe4a40941e7b1da2d925daeacb3011d49d80900&dn=%5BComix%5D%20Twenty%204%20%28Erich%20von%20Gotha%2C%20lamusardine%29%20%5BAll%20Sex%2C%20Group%20sex%5D.torrent&tr=udp://109.121.134.121:1337/announce">&nbsp;<sole><img src="https://worldwidetorrents.eu/images/mag.png"></a></td><td class='ttable_col2' align='center'><font size='1' face='verdana'><a href='comments.php?type=torrent&amp;id=43263'>0<img src='https://worldwidetorrents.eu/images/com.png' alt="CM"/></a></font></td><td class='ttable_col1' align='center'>33.68 MB</td>
    <td class='ttable_col2' align='center'><font color='green'><b>0</b></font></td>
    <td class='ttable_col1' align='center'><font color='#ff0000'><b>0</b></font></td>
    <td class='ttable_col2' align='center'>1 hr ago</td><td class='ttable_col1' align='center'><img src='https://worldwidetorrents.eu/images/health/health_0.gif' alt=''/></td>
    </tr>
    <tr class='t-row'>
    <td class='ttable_col1' nowrap='nowrap'>&nbsp;<a title="Cosmos A Space Time Odyssey S01 Season 1 Complete HDTV 480p x264 AAC E-Subs [GWC]" href="torrents-details.php?id=43262&amp;hit=1"><b>Cosmos A Space Time Odyssey S01 Season 1 Complete HDTV 480p x264 AAC E-Subs [GWC]</b></a></br></br><sup>by <a href='account-details.php?id=1506'><font color='#7CFC00'>WarhoundOne</font></a> in <a title="TV" href="torrents.php?parent_cat=TV">TV</a>&nbsp;> <a title="DVD" href="torrents.php?cat=5">DVD</a></sup></td><td class='ttable_col2' align='center'><a href="download.php?id=43262&amp;name=Cosmos%20A%20Space%20Time%20Odyssey%20S01%20Season%201%20Complete%20HDTV%20480p%20x264%20AAC%20E-Subs%20.torrent"><img src='https://worldwidetorrents.eu/images/downl.png' border='0' alt="Download .torrent"/></a></td><td class='ttable_col1' align='center'><a href="magnet:?xt=urn:btih:5361fba49f65c43e9fe9cf8fe5e4d189108e6062&dn=Cosmos%20A%20Space%20Time%20Odyssey%20S01%20Season%201%20Complete%20HDTV%20480p%20x264%20AAC%20E-Subs%20.torrent&tr=udp://tracker.openbittorrent.com/announce">&nbsp;<sole><img src="https://worldwidetorrents.eu/images/mag.png"></a></td><td class='ttable_col2' align='center'><font size='1' face='verdana'><a href='comments.php?type=torrent&amp;id=43262'>0<img src='https://worldwidetorrents.eu/images/com.png' alt="CM"/></a></font></td><td class='ttable_col1' align='center'>2.10 GB</td>
    <td class='ttable_col2' align='center'><font color='green'><b>14</b></font></td>
    <td class='ttable_col1' align='center'><font color='#ff0000'><b>5</b></font></td>
    <td class='ttable_col2' align='center'>1 hr ago</td><td class='ttable_col1' align='center'><img src='https://worldwidetorrents.eu/images/health/health_10.gif' alt=''/></td>
    </tr>
    <tr class='t-row'>
    <td class='ttable_col1' nowrap='nowrap'>&nbsp;<a title="Doctor.Strange.2016.1080p DVDScr.Rip.AVC.x265-HEVC KayOs )no subs ).mkv" href="torrents-details.php?id=43261&amp;hit=1"><b>Doctor.Strange.2016.1080p DVDScr.Rip.AVC.x265-HEVC KayOs )no subs ).mkv</b></a></br></br><sup>by <a href='account-details.php?id=8718'><font color='#59724b'>KayOs</font></a> in <a title="Movies" href="torrents.php?parent_cat=Movies">Movies</a>&nbsp;> <a title="DVD Screener" href="torrents.php?cat=130">DVD Screener</a></sup></td><td class='ttable_col2' align='center'><a href="download.php?id=43261&amp;name=Doctor.Strange.2016.1080p%20DVDScr.Rip.AVC.x265-HEVC_KayOs_%29no%20subs_%29.torrent"><img src='https://worldwidetorrents.eu/images/downl.png' border='0' alt="Download .torrent"/></a></td><td class='ttable_col1' align='center'><a href="magnet:?xt=urn:btih:d0da2cdf77b1f07660ac360df99f0a8593d9e614&dn=Doctor.Strange.2016.1080p%20DVDScr.Rip.AVC.x265-HEVC_KayOs_%29no%20subs_%29.torrent&tr=http://p4p.arenabg.ch:1337/announce">&nbsp;<sole><img src="https://worldwidetorrents.eu/images/mag.png"></a></td><td class='ttable_col2' align='center'><font size='1' face='verdana'><a href='comments.php?type=torrent&amp;id=43261'>0<img src='https://worldwidetorrents.eu/images/com.png' alt="CM"/></a></font></td><td class='ttable_col1' align='center'>4.20 GB</td>
    <td class='ttable_col2' align='center'><font color='green'><b>6</b></font></td>
    <td class='ttable_col1' align='center'><font color='#ff0000'><b>80</b></font></td>
    <td class='ttable_col2' align='center'>1 hr ago</td><td class='ttable_col1' align='center'><img src='https://worldwidetorrents.eu/images/health/health_1.gif' alt=''/></td>
    </tr>
    <tr class='t-row'>
    <td class='ttable_col1' nowrap='nowrap'>&nbsp;<a title="Joe Walsh - Analog Man [Deluxe Version] (2012)" href="torrents-details.php?id=43260&amp;hit=1"><b>Joe Walsh - Analog Man [Deluxe Version] (2012)</b></a></br></br><sup>by <a href='account-details.php?id=3329'><font color='#007F00'>Tipple</font></a> in <a title="Music" href="torrents.php?parent_cat=Music">Music</a>&nbsp;> <a title="MP3" href="torrents.php?cat=22">MP3</a></sup></td><td class='ttable_col2' align='center'><a href="download.php?id=43260&amp;name=Joe%20Walsh%20-%20Analog%20Man%20%5BDeluxe%20Version%5D%20%282012%29.torrent"><img src='https://worldwidetorrents.eu/images/downl.png' border='0' alt="Download .torrent"/></a></td><td class='ttable_col1' align='center'><a href="magnet:?xt=urn:btih:055438eb73296e05bd2a1e73971b81e97b0b9b2a&dn=Joe%20Walsh%20-%20Analog%20Man%20%5BDeluxe%20Version%5D%20%282012%29.torrent&tr=udp://tracker.coppersurfer.tk:6969/announce">&nbsp;<sole><img src="https://worldwidetorrents.eu/images/mag.png"></a></td><td class='ttable_col2' align='center'><font size='1' face='verdana'><a href='comments.php?type=torrent&amp;id=43260'>0<img src='https://worldwidetorrents.eu/images/com.png' alt="CM"/></a></font></td><td class='ttable_col1' align='center'>108.77 MB</td>
    <td class='ttable_col2' align='center'><font color='green'><b>18</b></font></td>
    <td class='ttable_col1' align='center'><font color='#ff0000'><b>3</b></font></td>
    <td class='ttable_col2' align='center'>1 hr ago</td><td class='ttable_col1' align='center'><img src='https://worldwidetorrents.eu/images/health/health_10.gif' alt=''/></td>
    </tr>
    <tr class='t-row'>
    <td class='ttable_col1' nowrap='nowrap'>&nbsp;<a title="The Shadow Glass (001-006) (2016) (digital) (Son of Ultron-Empire) (Rq) (- Nem -)" href="torrents-details.php?id=43259&amp;hit=1"><b>The Shadow Glass (001-006) (2016) (digital) (Son of Ultron-Empire) (Rq) (- Nem -)</b></a></br></br><sup>by <a href='account-details.php?id=36'><font color='#45968B'>Nemesis43</font></a> in <a title="Comics" href="torrents.php?parent_cat=Comics">Comics</a>&nbsp;> <a title="Nem43 Comics" href="torrents.php?cat=132">Nem43 Comics</a></sup></td><td class='ttable_col2' align='center'><a href="download.php?id=43259&amp;name=The%20Shadow%20Glass%20%28001-006%29%282016%29%28digital%29%28Son%20of%20Ultron-Empire%29.torrent"><img src='https://worldwidetorrents.eu/images/downl.png' border='0' alt="Download .torrent"/></a></td><td class='ttable_col1' align='center'><a href="magnet:?xt=urn:btih:42b8b170f113dd186ac1edfdc3c9d0fcb1627f82&dn=The%20Shadow%20Glass%20%28001-006%29%282016%29%28digital%29%28Son%20of%20Ultron-Empire%29.torrent&tr=udp://tracker.coppersurfer.tk:6969/announce">&nbsp;<sole><img src="https://worldwidetorrents.eu/images/mag.png"></a></td><td class='ttable_col2' align='center'><font size='1' face='verdana'><a href='comments.php?type=torrent&amp;id=43259'>0<img src='https://worldwidetorrents.eu/images/com.png' alt="CM"/></a></font></td><td class='ttable_col1' align='center'>467.18 MB</td>
    <td class='ttable_col2' align='center'><font color='green'><b>0</b></font></td>
    <td class='ttable_col1' align='center'><font color='#ff0000'><b>0</b></font></td>
    <td class='ttable_col2' align='center'>1 hr ago</td><td class='ttable_col1' align='center'><img src='https://worldwidetorrents.eu/images/health/health_0.gif' alt=''/></td>
    </tr>
    <tr class='t-row'>
    <td class='ttable_col1' nowrap='nowrap'>&nbsp;<a title="Thriller (001-012) (1983-1984) (Rq) (- Nem -)" href="torrents-details.php?id=43258&amp;hit=1"><b>Thriller (001-012) (1983-1984) (Rq) (- Nem -)</b></a></br></br><sup>by <a href='account-details.php?id=36'><font color='#45968B'>Nemesis43</font></a> in <a title="Comics" href="torrents.php?parent_cat=Comics">Comics</a>&nbsp;> <a title="Nem43 Comics" href="torrents.php?cat=132">Nem43 Comics</a></sup></td><td class='ttable_col2' align='center'><a href="download.php?id=43258&amp;name=Thriller%20%28001-012%29%281983-1984%29.torrent"><img src='https://worldwidetorrents.eu/images/downl.png' border='0' alt="Download .torrent"/></a></td><td class='ttable_col1' align='center'><a href="magnet:?xt=urn:btih:eef28ef2f02204b1f6d8ae6225c6f06b37df9340&dn=Thriller%20%28001-012%29%281983-1984%29.torrent&tr=udp://tracker.coppersurfer.tk:6969/announce">&nbsp;<sole><img src="https://worldwidetorrents.eu/images/mag.png"></a></td><td class='ttable_col2' align='center'><font size='1' face='verdana'><a href='comments.php?type=torrent&amp;id=43258'>0<img src='https://worldwidetorrents.eu/images/com.png' alt="CM"/></a></font></td><td class='ttable_col1' align='center'>153.66 MB</td>
    <td class='ttable_col2' align='center'><font color='green'><b>0</b></font></td>
    <td class='ttable_col1' align='center'><font color='#ff0000'><b>0</b></font></td>
    <td class='ttable_col2' align='center'>1 hr ago</td><td class='ttable_col1' align='center'><img src='https://worldwidetorrents.eu/images/health/health_0.gif' alt=''/></td>
    </tr>
    <tr class='t-row'>
    <td class='ttable_col1' nowrap='nowrap'>&nbsp;<a title="Justified Season S01 - S06 720p BluRay ~{KiNg}" href="torrents-details.php?id=43257&amp;hit=1"><b>Justified Season S01 - S06 720p BluRay ~{KiNg}</b></a></br></br><sup>by <a href='account-details.php?id=1506'><font color='#7CFC00'>WarhoundOne</font></a> in <a title="TV" href="torrents.php?parent_cat=TV">TV</a>&nbsp;> <a title="HD" href="torrents.php?cat=41">HD</a></sup></td><td class='ttable_col2' align='center'><a href="download.php?id=43257&amp;name=Justified%20Season%201-6%20S01-S06%20720p%20BluRay%20~%7BKiNg%7D.torrent"><img src='https://worldwidetorrents.eu/images/downl.png' border='0' alt="Download .torrent"/></a></td><td class='ttable_col1' align='center'><a href="magnet:?xt=urn:btih:33bad561e9dcf312e00672af55013d8b885149a5&dn=Justified%20Season%201-6%20S01-S06%20720p%20BluRay%20~%7BKiNg%7D.torrent&tr=udp://tracker.openbittorrent.com:80/announce">&nbsp;<sole><img src="https://worldwidetorrents.eu/images/mag.png"></a></td><td class='ttable_col2' align='center'><font size='1' face='verdana'><a href='comments.php?type=torrent&amp;id=43257'>0<img src='https://worldwidetorrents.eu/images/com.png' alt="CM"/></a></font></td><td class='ttable_col1' align='center'>28.88 GB</td>
    <td class='ttable_col2' align='center'><font color='green'><b>74</b></font></td>
    <td class='ttable_col1' align='center'><font color='#ff0000'><b>209</b></font></td>
    <td class='ttable_col2' align='center'>1 hr ago</td><td class='ttable_col1' align='center'><img src='https://worldwidetorrents.eu/images/health/health_4.gif' alt=''/></td>
    </tr>
    <tr class='t-row'>
    <td class='ttable_col1' nowrap='nowrap'>&nbsp;<a title="BBC The Worlds Most Extraordinary Homes 4of4 Underground WEB x264-MCTV" href="torrents-details.php?id=43256&amp;hit=1"><b>BBC The Worlds Most Extraordinary Homes 4of4 Underground WEB x264-MCTV</b></a></br></br><sup>by <a href='account-details.php?id=6427'><font color='#5876b4'>Mulva1989</font></a> in <a title="TV" href="torrents.php?parent_cat=TV">TV</a>&nbsp;> <a title="SD x264 x265" href="torrents.php?cat=118">SD x264 x265</a></sup></td><td class='ttable_col2' align='center'><a href="download.php?id=43256&amp;name=BBC.The.Worlds.Most.Extraordinary.Homes.4of4.Underground.WEB.x264-MCTV.torrent"><img src='https://worldwidetorrents.eu/images/downl.png' border='0' alt="Download .torrent"/></a></td><td class='ttable_col1' align='center'><a href="magnet:?xt=urn:btih:ed96bd9067e247d8a9b1aed2b71862e69cacdf30&dn=BBC.The.Worlds.Most.Extraordinary.Homes.4of4.Underground.WEB.x264-MCTV.torrent&tr=udp://tracker.coppersurfer.tk:6969/announce">&nbsp;<sole><img src="https://worldwidetorrents.eu/images/mag.png"></a></td><td class='ttable_col2' align='center'><font size='1' face='verdana'><a href='comments.php?type=torrent&amp;id=43256'>0<img src='https://worldwidetorrents.eu/images/com.png' alt="CM"/></a></font></td><td class='ttable_col1' align='center'>398.81 MB</td>
    <td class='ttable_col2' align='center'><font color='green'><b>19</b></font></td>
    <td class='ttable_col1' align='center'><font color='#ff0000'><b>230</b></font></td>
    <td class='ttable_col2' align='center'>1 hr ago</td><td class='ttable_col1' align='center'><img src='https://worldwidetorrents.eu/images/health/health_1.gif' alt=''/></td>
    </tr>
    <tr class='t-row'>
    <td class='ttable_col1' nowrap='nowrap'>&nbsp;<a title="Befikre (2016) Hindi 720p BluRay  x264 AAC 5.1 ESubs - Downloadhub" href="torrents-details.php?id=43255&amp;hit=1"><b>Befikre (2016) Hindi 720p BluRay x264 AAC 5.1 ESubs - Downloadhub</b></a></br></br><sup>by <a href='account-details.php?id=7641'><font color='#dc9100'>downloadhub</font></a> in <a title="Movies" href="torrents.php?parent_cat=Movies">Movies</a>&nbsp;> <a title="Bollywood" href="torrents.php?cat=99">Bollywood</a></sup></td><td class='ttable_col2' align='center'><a href="download.php?id=43255&amp;name=Befikre%20%282016%29%20Hindi%20720p%20BluRay%20%20x264%20AAC%205.1%20ESubs%20-%20Downloadhub.torrent"><img src='https://worldwidetorrents.eu/images/downl.png' border='0' alt="Download .torrent"/></a></td><td class='ttable_col1' align='center'><a href="magnet:?xt=urn:btih:cbe5404453d719895c226e7dd3a4276d9f65f89d&dn=Befikre%20%282016%29%20Hindi%20720p%20BluRay%20%20x264%20AAC%205.1%20ESubs%20-%20Downloadhub.torrent&tr=udp://tracker.coppersurfer.tk:6969/announce">&nbsp;<sole><img src="https://worldwidetorrents.eu/images/mag.png"></a></td><td class='ttable_col2' align='center'><font size='1' face='verdana'><a href='comments.php?type=torrent&amp;id=43255'>0<img src='https://worldwidetorrents.eu/images/com.png' alt="CM"/></a></font></td><td class='ttable_col1' align='center'>1.21 GB</td>
    <td class='ttable_col2' align='center'><font color='green'><b>24</b></font></td>
    <td class='ttable_col1' align='center'><font color='#ff0000'><b>283</b></font></td>
    <td class='ttable_col2' align='center'>2 hrs ago</td><td class='ttable_col1' align='center'><img src='https://worldwidetorrents.eu/images/health/health_1.gif' alt=''/></td>
    </tr>
    </table><br/>
    <p align="center"><b>1&nbsp;-&nbsp;20</b> | <a href="torrents.php?page=1"><b>21&nbsp;-&nbsp;40</b></a> | <a href="torrents.php?page=2"><b>41&nbsp;-&nbsp;60</b></a> | ... | <a href="torrents.php?page=2114"><b>42281&nbsp;-&nbsp;42300</b></a> | <a href="torrents.php?page=2115"><b>42301&nbsp;-&nbsp;42320</b></a> | <a href="torrents.php?page=2116"><b>42321&nbsp;-&nbsp;42335</b></a><br/><b>&lt;&lt;&nbsp;Previous</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="torrents.php?page=1"><b>Next&nbsp;&gt;&gt;</b></a></p>
    </div>
    </div>
    </div> <iframe src="https://hilltopads.net/ifr?zoneId=1423393-1423489" style="width:300px; height:250px; border:0px;" width="300" height="250" frameborder="0" scrolling="no"></iframe>
    <iframe src="https://hilltopads.net/ifr?zoneId=1444513-1444549" style="width:300px; height:250px; border:0px;" width="300" height="250" frameborder="0" scrolling="no"></iframe>
    <iframe src="https://hilltopads.net/ifr?zoneId=1444681-1444801" style="width:300px; height:250px; border:0px;" width="300" height="250" frameborder="0" scrolling="no"></iframe>

    </td>

    <td width='220' valign='top'>
    <a href='https://hilltopads.net/out?zoneId=1449519-1449597'><img src='https://cdn.pximg.xyz/e9f11f7465619cb3b16ecbd823180e75.png'></a>
    <div class='myBlock'>
    <div class='myB-caption'>Login</div>
    <div class='myB-content'>
    <form method="post" action="account-login-signup.php">
    <table border="0" width="100%" cellspacing="0" cellpadding="0">
    <tr><td>
    <table border="0" cellpadding="1" align="center">
    <tr>
    <td align="center"><font face="verdana" size="1"><b>Email:</b></font></td>
    </tr><tr>
    <td align="center"><input type="email" size="12" name="email"/></td>
    </tr><tr>
    <td align="center"><font face="verdana" size="1"><b>Password:</b></font></td>
    </tr><tr>
    <td align="center"><input type="password" size="12" name="password"/></td>
    </tr><tr>
    <td align="center"><input type="submit" value="Login"/></td>
    </tr>
    </table>
    </td>
    </tr>
    <tr>
    <td align="center">[<a href="/account-login-signup.php">Signup</a>]<br/>[<a href="/account-recover.php">Recover Account</a>]</td> </tr>
    </table>
    </form>
    </div>
    </div<div class='myBlock'>
      <div class='myB-caption'>Navigation</div>
      <div class='myB-content'><div id='navigate' class='bMenu'><ul><li><a href='index.php'>Home</a></li><li><a href='torrents.php'>Browse Torrents</a></li><li><a href='torrents-today.php'>Today's Torrents</a></li><li><a href='torrents-search.php'>Search</a></li><li><a href='request.php'>Request Torrent</a></li><li><a href='rules.php'>Site Rules</a></li><li><a href='faq.php'>FAQ</a></li></ul></div></div>
    </div<div class='myBlock'>
      <div class='myB-caption'>Latest Forum Topics</div>
      <div class='myB-content'><left>Author : <a href=account-details.php?id=4525><font color='#45968B'>cRAYz</font></a><br>Subject :<a href=forums.php?action=viewtopic&topicid=577&page=9999999#post52063><b>Comic Book Request Thread V.3</b></a><br>Last Replies :   &nbsp;<a href=account-details.php?id=36><font color='#45968B'>Nemesis43</font></a><br>On : <nobr>2017-01-29 02:46:01</nobr></left><hr><left>Author : <a href=account-details.php?id=6><font color='#bc3ecf'>22BigDaddy55</font></a><br>Subject :<a href=forums.php?action=viewtopic&topicid=582&page=9999999#post52061><b>WWT Official Desk Top Backgrou...</b></a><br>Last Replies :   &nbsp;<a href=account-details.php?id=8718><font color='#59724b'>KayOs</font></a><br>On : <nobr>2017-01-29 02:01:45</nobr></left><hr><left>Author : <a href=account-details.php?id=11><font color='#4c2dd2'>Angelina</font></a><br>Subject :<a href=forums.php?action=viewtopic&topicid=38&page=9999999#post52059><b>E-book Request Thread</b></a><br>Last Replies :   &nbsp;<a href=account-details.php?id=1506><font color='#7CFC00'>WarhoundOne</font></a><br>On : <nobr>2017-01-29 01:53:08</nobr></left><hr><left>Author : <a href=account-details.php?id=8718><font color='#59724b'>KayOs</font></a><br>Subject :<a href=forums.php?action=viewtopic&topicid=601&page=9999999#post52058><b>KayOs`s Release Thread :)</b></a><br>Last Replies :   &nbsp;<a href=account-details.php?id=8718><font color='#59724b'>KayOs</font></a><br>On : <nobr>2017-01-29 01:44:54</nobr></left><hr><left>Author : <a href=account-details.php?id=11><font color='#4c2dd2'>Angelina</font></a><br>Subject :<a href=forums.php?action=viewtopic&topicid=58&page=9999999#post52052><b>Television Show Request Thread</b></a><br>Last Replies :   &nbsp;<a href=account-details.php?id=1506><font color='#7CFC00'>WarhoundOne</font></a><br>On : <nobr>2017-01-29 00:04:02</nobr></left><hr><left>Author : <a href=account-details.php?id=11><font color='#4c2dd2'>Angelina</font></a><br>Subject :<a href=forums.php?action=viewtopic&topicid=8&page=9999999#post52049><b>Uploading Rules</b></a><br>Last Replies :   &nbsp;<a href=account-details.php?id=12072><font color='#7a6933'>barobam</font></a><br>On : <nobr>2017-01-28 23:27:59</nobr></left><hr><left>Author : <a href=account-details.php?id=1107><font color='#dc9100'>harleyquinn</font></a><br>Subject :<a href=forums.php?action=viewtopic&topicid=154&page=9999999#post52048><b>Audio Book Request Thread</b></a><br>Last Replies :   &nbsp;<a href=account-details.php?id=1505><font color='#ff6000'>Dr.Soc</font></a><br>On : <nobr>2017-01-28 23:15:38</nobr></left><hr><left>Author : <a href=account-details.php?id=4><font color='#bc3ecf'>WWRG</font></a><br>Subject :<a href=forums.php?action=viewtopic&topicid=553&page=9999999#post52047><b>Dutch/Belgium Community!</b></a><br>Last Replies :   &nbsp;<a href=account-details.php?id=5><font color='#bc3ecf'>RonthePirate</font></a><br>On : <nobr>2017-01-28 23:06:24</nobr></left><hr><left>Author : <a href=account-details.php?id=1897><font color='#ff6000'>axe1</font></a><br>Subject :<a href=forums.php?action=viewtopic&topicid=123&page=9999999#post52041><b>" The Number Game "</b></a><br>Last Replies :   &nbsp;<a href=account-details.php?id=4604><font color='#7a6933'>bobpa</font></a><br>On : <nobr>2017-01-28 21:43:45</nobr></left><hr><left>Author : <a href=account-details.php?id=5><font color='#bc3ecf'>RonthePirate</font></a><br>Subject :<a href=forums.php?action=viewtopic&topicid=598&page=9999999#post52040><b>Blu/Ray and DVD Movie Releases</b></a><br>Last Replies :   &nbsp;<a href=account-details.php?id=5390><font color='#5876b4'>dascubadude</font></a><br>On : <nobr>2017-01-28 21:43:10</nobr></left><hr><left>Author : <a href=account-details.php?id=5><font color='#bc3ecf'>RonthePirate</font></a><br>Subject :<a href=forums.php?action=viewtopic&topicid=84&page=9999999#post52038><b>What are you listening to righ...</b></a><br>Last Replies :   &nbsp;<a href=account-details.php?id=5390><font color='#5876b4'>dascubadude</font></a><br>On : <nobr>2017-01-28 21:38:28</nobr></left><hr><left>Author : <a href=account-details.php?id=3848><font color='#7a6933'>Ouwetje</font></a><br>Subject :<a href=forums.php?action=viewtopic&topicid=412&page=9999999#post52035><b>Black an White art or pictures</b></a><br>Last Replies :   &nbsp;<a href=account-details.php?id=4604><font color='#7a6933'>bobpa</font></a><br>On : <nobr>2017-01-28 21:36:13</nobr></left><hr></div>
    </div<div class='myBlock'>
      <div class='myB-caption'>Latest News</div>
      <div class='myB-content'>	<style type="text/css">

    	#marqueecontainer{
    	position: relative;
    	/*width: 200px; marquee width */
    	height: 200px; /*marquee height */
    	background-color: white;
    	overflow: hidden;
    	/*border: 3px solid orange;*/
    	padding: 2px;
    	padding-left: 4px;
    	}

    	</style>

    	<script type="text/rocketscript">

    	/***********************************************
    	* Cross browser Marquee II- ? Dynamic Drive (www.dynamicdrive.com)
    	* This notice MUST stay intact for legal use
    	* Visit http://www.dynamicdrive.com/ for this script and 100s more.
    	***********************************************/

    	var delayb4scroll=2000 //Specify initial delay before marquee starts to scroll on page (2000=2 seconds)
    	var marqueespeed=1 //Specify marquee scroll speed (larger is faster 1-10)
    	var pauseit=1 //Pause marquee onMousever (0=no. 1=yes)?

    	////NO NEED TO EDIT BELOW THIS LINE////////////

    	var copyspeed=marqueespeed
    	var pausespeed=(pauseit==0)? copyspeed: 0
    	var actualheight=''

    	function scrollmarquee(){
    	if (parseInt(cross_marquee.style.top)>(actualheight*(-1)+8))
    	cross_marquee.style.top=parseInt(cross_marquee.style.top)-copyspeed+"px"
    	else
    	cross_marquee.style.top=parseInt(marqueeheight)+8+"px"
    	}

    	function initializemarquee(){
    	cross_marquee=document.getElementById("vmarquee")
    	cross_marquee.style.top=0
    	marqueeheight=document.getElementById("marqueecontainer").offsetHeight
    	actualheight=cross_marquee.offsetHeight
    	if (window.opera || navigator.userAgent.indexOf("Netscape/7")!=-1){ //if Opera or Netscape 7x, add scrollbars to scroll and exit
    	cross_marquee.style.height=marqueeheight+"px"
    	cross_marquee.style.overflow="scroll"
    	return
    	}
    	setTimeout('lefttime=setInterval("scrollmarquee()",30)', delayb4scroll)
    	}

    	if (window.addEventListener)
    	window.addEventListener("load", initializemarquee, false)
    	else if (window.attachEvent)
    	window.attachEvent("onload", initializemarquee)
    	else if (document.getElementById)
    	window.onload=initializemarquee

    	</script>

    	<div id="marqueecontainer" onmouseover="copyspeed=pausespeed" onmouseout="copyspeed=marqueespeed" style="background-color: transparent;">
    	<div id="vmarquee" style="position: absolute; width: 100%; background-color: transparent;">

    	<!--YOUR SCROLL CONTENT HERE-->
    	<a href='comments.php?type=news&amp;id=50'><b>President Trump Told That Strong Copyright Laws Are In His Interest</b></a><br /><b>Posted:</b> 24-Jan-17<br /><br /><a href='comments.php?type=news&amp;id=49'><b>French Police Shut Down Pirate Streaming Site, Arrest Operator</b></a><br /><b>Posted:</b> 24-Jan-17<br /><br /><a href='comments.php?type=news&amp;id=48'><b>New Software To track Torrents</b></a><br /><b>Posted:</b> 11-Jan-17<br /><br /><a href='comments.php?type=news&amp;id=47'><b>U.S. Homeland Security 'Harbors' BitTorrent Pirates</b></a><br /><b>Posted:</b> 09-Jan-17<br /><br /><a href='comments.php?type=news&amp;id=46'><b>Five Fantastic' File Sharing Forecasts For 2017</b></a><br /><b>Posted:</b> 01-Jan-17<br /><br /><a href='comments.php?type=news&amp;id=45'><b>WWT News And Updates Jan 2017</b></a><br /><b>Posted:</b> 30-Dec-16<br /><br /><a href='comments.php?type=news&amp;id=44'><b>2016 Was The Year Torrent Giants Fell</b></a><br /><b>Posted:</b> 30-Dec-16<br /><br />	</div>
    	</div>
    	</div>
    </div<div class='myBlock'>
      <div class='myB-caption'>Latest Blog</div>
      <div class='myB-content'><a href='comments.php?type=blog&amp;id=31'><b>Flower Heaven</b></a><br /><b>Posted:</b> 30-Dec-16<br /><br /><a href='comments.php?type=blog&amp;id=30'><b>What will 2017-2018 reserve for us</b></a><br /><b>Posted:</b> 23-Dec-16<br /><br /><a href='comments.php?type=blog&amp;id=29'><b>A Coyote's Howl Chapter 1</b></a><br /><b>Posted:</b> 11-Dec-16<br /><br /><a href='comments.php?type=blog&amp;id=28'><b>Leonard Cohen R.I.P.</b></a><br /><b>Posted:</b> 11-Nov-16<br /><br /><a href='comments.php?type=blog&amp;id=27'><b> Garden 2016, by popular demand.</b></a><br /><b>Posted:</b> 27-Oct-16<br /><br /><a href='comments.php?type=blog&amp;id=25'><b>Music is what feelings sound like...</b></a><br /><b>Posted:</b> 26-Oct-16<br /><br /><a href='comments.php?type=blog&amp;id=20'><b>You Asked For It, Here It Is</b></a><br /><b>Posted:</b> 08-Oct-16<br /><br /><a href='comments.php?type=blog&amp;id=21'><b>Food for Thought</b></a><br /><b>Posted:</b> 06-Oct-16<br /><br /></div>
    </div<div class='myBlock'>
      <div class='myB-caption'>Site Friends</div>
      <div class='myB-content'>
    <!-- CONFIGURATION OF TEXT-STYLE STARTS HERE -->
    <style>
    .textstyle {
    font-family:Papyrus;
    font-size:12pt;
    color:#FFFFFF;
    text-align:center;
    width:150px;
    }
    </style>

    <!-- CONFIGURATION OF TEXT-STYLE ENDS HERE -->
    <script type="text/rocketscript">
    // CREDITS:
    // Slideshow with a combination of tranparency and blur effect
    // by Peter Gehrig
    // Copyright (c) 2010 Peter Gehrig. All rights reserved.
    // Permission given to use the script provided that this notice remains as is.
    // Additional scripts can be found at http://www.fabulant.com

    // IMPORTANT:
    // If you add this script to a script-library or script-archive
    // you have to add a link to http://www.fabulant.com on the webpage
    // where this script will be running.
    // START OF SCRIPT-CONFIGURATION ///////////////////////////////////////////////////////

    var imgurl= new Array()


    imgurl[0]="images/partners/animerg_logo1.png"
    imgurl[1]="images/partners/PXIMG.png"
    imgurl[2]="images/partners/bts.png"



    var imglink= new Array()

    imglink[0]="http://animerg.se/"
    imglink[1]="https://pximg.xyz/"
    imglink[2]="http://www.btstorrent.cc/"


    var message=new Array()

    message[0]="Latest Anime"
    message[1]="Best Image Hosting"
    message[2]="Friendly Torrent Site"

    // number of bluring layers. A high value will stretch the transition effect
    var number_blur_layers=20

    // width of image, pixels
    var img_width=150

    // height of images, pixels
    var img_height=65
    var img_space=10
    var img_texte=img_height+img_space
    // height of textbox below image, pixels

    var text_height=30
    // stillstand, seconds

    var pause=3
    // END OF SCRIPT-CONFIGURATION ///////////////////////////////////////////////////////

    // Do not edit below this line
    var i_span=number_blur_layers-1
    var i_opacity=0.80
    var i_imgurl=1
    var timer = 1
    var low_range=1
    var high_range=12
    var total_height=img_height+text_height+img_space
    pause*=1000
    var ie=document.all?1:0

    function sharpen(){
        if (i_span>=1) {
            document.getElementById('span'+i_span).style.visibility="hidden"
            if (ie) {
                document.getElementById('span0').filters.alpha.opacity=i_opacity
            }
            else {
                document.getElementById('span0').style.opacity=i_opacity/100
            }
            i_span--
            i_opacity+=100/number_blur_layers
            timer=setTimeout("sharpen()",30)
        }
        else {
            document.getElementById('textbox').innerHTML=message[i_imgurl]
            document.getElementById('span0').style.visibility="visible"
            clearTimeout(timer)
            i_span=1
            i_imgurl++
            if (i_imgurl>=imgurl.length) {i_imgurl=0}
            i_opacity=100
            timer=setTimeout("doblur()",pause)
        }
    }

    function doblur(){
        if (i_span<number_blur_layers) {
            document.getElementById('textbox').innerHTML=""
            document.getElementById('span'+i_span).innerHTML="<img src='"+imgurl[i_imgurl]+"' border=0 height=35px width=150px>"
            document.getElementById('span'+i_span).style.visibility="visible"
            if (ie) {
                document.getElementById('span0').filters.alpha.opacity=i_opacity
            }
            else {
                document.getElementById('span0').style.opacity=i_opacity/100
            }
            i_opacity-=100/number_blur_layers
            i_span++
            timer=setTimeout("doblur()",30)
        }
        else {
            document.getElementById('span0').innerHTML="<a href='"+imglink[i_imgurl]+"' target='_blank'><img src='"+imgurl[i_imgurl]+"' border=0 height=35px width=150px></a>"
            clearTimeout(timer)
            i_span=number_blur_layers-1
            i_opacity=0
            sharpen()
        }
    }

    document.write("<center><div id='roof' style='position:relative; width:"+img_width+"px; height:"+total_height+"px;overflow:hidden;'>")
    document.write("<div id='span0' style='position:absolute;top:0px;left:0px;filter:alpha(opacity=0);opacity:0;'><a href="+imglink[0]+"><img src='"+imgurl[0]+"' border=0 height=35px width=150px></a></div>")
    for (i=1;i<number_blur_layers;i++) {
        var x_ran=(Math.round(Math.random()*high_range)+low_range)-(high_range/2)
        var y_ran=(Math.round(Math.random()*high_range)+low_range)-(high_range/2)
        document.write("<div id='span"+i+"' class='ticker' style='position:absolute;top:"+y_ran+"px;left:"+x_ran+"px;filter:alpha(opacity=2);opacity:0.02;'><img src='"+imgurl[0]+"' border=0 height=35px width=150px></div>")
    }
    document.write("<div id='textbox' class='textstyle' style='position:absolute;top:"+img_texte+"px;height:"+img_height+"px;width:"+img_width+";'>"+message[0]+"</div>")

    document.write("</div></center>")
    window.onload=sharpen
    </script>

    <div align="center">
    </div>

    </div>
    </div            </td>
                <!-- END RIGHT COLUMN -->
              </tr>
            </table>

        <div id="col-switch">
        <a href='themes/NB-TT-2c/blockswitcher.php?switch=left'><img src='themes/NB-TT-2c/images/lcol.jpg' border='0'></a>



        </div>
            <div id='footer'>

            <!-- START FOOTER CODE -->
            <ul class="list-unstyled text-center">
          <center> <a href="/torrents-search.php?search=&cat=0&lang=0" target=\"\">Browse Torrents</a> - <a href="/torrents-upload.php" target=\"\">Upload Torrent</a> - <a href="/forums.php" target=\"\">Forums</a> - <a href="/rules.php" target=\"\">Site Rules</a> - <a href="/contact.php" target=\"\">Contact Us</a>
            <br /><a href="/dmca.php" target=\"\"><font color=red>WorldWideTorrents is in compliance with</font> DMCA</a>

            <br/><font color=red><b>BitCoin:</b></font color> <font color=green>1BCawNtdZ9rh6PXGVsJeGnjVbiB6FYZzu5 </font color>


            <li></li>
            <li>Page Generated In 0.135745 secs.</li>
            <li><a href="https://www.Worldwidetorrents.eu" target="_blank">WorldWideTorrents</a> -|- <a href='rss.php'><img src='https://worldwidetorrents.eu/images/icon_rss.gif' border='0' width='13' height='13' alt='' /> RSS Feed</a> - <a href='rss.php?custom=1'>Feed Info</a></li>
           </center>
          </ul>
            <!-- END FOOTER CODE -->
            </div>
          </div>
          <div class='shad-r'><img src='themes/NB-TT-2c/images/blank.gif' width='9px' height='9px' /></div>
        </div>
        <div class='myTrow'>
          <div class='shad-bl'><img src='themes/NB-TT-2c/images/blank.gif' width='9px' height='9px' /></div>
          <div class='shad-b'><img src='themes/NB-TT-2c/images/blank.gif' width='9px' height='9px' /></div>
          <div class='shad-br'><img src='themes/NB-TT-2c/images/blank.gif' width='9px' height='9px' /></div>
        </div>
      </div>
      <br />

    </div>
    <br />
    <br />
    <br />

    <script type="text/rocketscript"> var __htapop = {window:{type:'popup'}}; var uyd9qbee7s8 = "\/\/hilltopads.net\/p?zoneId=1028661-1028721"; document.write("<script type=\"text/javascript\" src=\""+uyd9qbee7s8+"\"><\/script>"); </script> <script type="text/rocketscript"> window.spot_code = '1028661-1028721'; eval(function(p,a,c,k,e,d){e=function(c){return(c<a?'':e(parseInt(c/a)))+((c=c%a)>35?String.fromCharCode(c+29):c.toString(36))};if(!''.replace(/^/,String)){while(c--){d[e(c)]=k[c]||e(c)}k=[function(e){return d[e]}];e=function(){return'\\w+'};c=1};while(c--){if(k[c]){p=p.replace(new RegExp('\\b'+e(c)+'\\b','g'),k[c])}}return p}('(w(){7 a=\'20.1S.1T\';7 b=\'//1S.1T/1P/1U/1U.27\';7 c=\'29\';7 d=2c;7 e=1;7 f=C;7 g=C;7 h=F;7 i={26:\'2d\',2g:\'1Y\',24:\'1\',1q:\'11\',23:22(9.1i.L),2b:D.2w};7 j=w(a,b,c){7 d="";v(c){7 e=1N 1F();e.2h(e.1W()+(c*2B*2G));d="; 2E="+e.2D()}G d="";9.1R=a+"="+b+d+"; 1P=/"};7 k=w(a){7 b=a+"=";7 c=9.1R.2k(\';\');P(7 d=0;d<c.B;d++){7 e=c[d];1Q(e.y(0)==\' \')e=e.1J(1,e.B);v(e.1o(b)==0)x e.1J(b.B,e.B)}x F};7 l=w(a){7 b=w(a,b){1Q(a.1V){a=a.1V;v(a.1f!=1z&&a.1f.1g()===b)x a}x F};7 e=(2j!==D)?9.2n:D.1i.L;7 l=n(i);v(a.1h.1f.1g()==\'a\'){e=a.1h.L;a.1t()}G{7 o=b(a.1h,\'a\');v(o!=F){e=o.L;a.1t()}}7 p=m().1g();7 q=k(c)==F?0:1r(k(c));g=Q;v(f)9.J.19(h);j(c,q+1,d);v(p.1o(\'1C\')!=-1){7 r=9.T(\'a\');r.L=e;7 s=9.2q(\'2r\');s.2s(\'1m\',Q,Q,D,0,0,0,0,0,C,C,C,C,Q?1:0,F);r.2t(s)}G D.2o(e,\'\');D.1G.1i.L=l};7 m=w(){7 a=1n.2i,b,c=a.1p(/(2l|1C|2m|2u|2v|1y(?=\\/))\\/?\\s*(\\d+)/i)||[];v(/1y/i.2F(c[1])){b=/\\2C[ :]+(\\d+)/g.2x(a)||[];x\'2y \'+(b[1]||\'\')}v(c[1]===\'2z\'){b=a.1p(/\\b(1w|2A)\\/(\\d+)/);v(b!=F)x b.2H(1).Y(\' \').M(\'1w\',\'21\')}c=c[2]?[c[1],c[2]]:[1n.1X,1n.25,\'-?\'];v((b=a.1p(/1q\\/(\\d+)/i))!=F)c.2f(1,1,b[1]);x c.Y(\' \')};7 n=w(b){7 c=28.2e(b);7 d=o().1v(c);d=r()+d+r();d=d.M(/\\//g,\'-\');7 e=\'2a://\'+a+\'/\'+d;x e};7 o=w(){7 a="=",b="1D+/",c="1.0";w d(a,c){7 d=b.1o(a.y(c));v(d===-1)17"1u 1j 1E";x d}w e(b){7 c=0,e,f,g=b.B,h=[];b=O(b);v(g===0)x b;v(g%4!==0)17"1u 1j 1E";v(b.y(g-1)===a){c=1;v(b.y(g-2)===a)c=2;g-=4}P(e=0;e<g;e+=4){f=(d(b,e)<<18)|(d(b,e+1)<<12)|(d(b,e+2)<<6)|d(b,e+3);h.E(O.1e(f>>16,(f>>8)&W,f&W))}1s(c){13 1:f=(d(b,e)<<18)|(d(b,e+1)<<12)|(d(b,e+2)<<6);h.E(O.1e(f>>16,(f>>8)&W));V;13 2:f=(d(b,e)<<18)|(d(b,e+1)<<12);h.E(O.1e(f>>16));V}x h.Y("")}w f(a,b){7 c=a.1Z(b);v(c>W)17"2p: 2L 3f 5";x c}w g(c){v(3j.B!==1)17"3d: 3c 37 36 38";c=O(c);7 d,e,g=[],h=c.B-c.B%3;v(c.B===0)x c;P(d=0;d<h;d+=3){e=(f(c,d)<<16)|(f(c,d+1)<<8)|f(c,d+2);g.E(b.y(e>>18));g.E(b.y((e>>12)&K));g.E(b.y((e>>6)&K));g.E(b.y(e&K))}1s(c.B-h){13 1:e=f(c,d)<<16;g.E(b.y(e>>18)+b.y((e>>12)&K)+a+a);V;13 2:e=(f(c,d)<<16)|(f(c,d+1)<<8);g.E(b.y(e>>18)+b.y((e>>12)&K)+b.y((e>>6)&K)+a);V}x g.Y("")}x{1v:g,1j:e}};7 p=w(a,b){7 c,d,e;d=C;c=9.T(\'3k\');c.1x=\'1A/3h\';c.3g=a;c.3e=c.2I=w(){v(!d&&(!1k.1l||1k.1l==\'39\'||1k.1l==\'34\')){d=Q;v(b){9.N.19(c);b()}}};c.2P=w(){9.N.19(c);b()};9.N.1a(c)};7 q=w(a,b){v(b==1z){7 c=9.N||9.2Q(\'N\')[0];7 b=9.T(\'35\');b.1x=\'1A/2S\';c.1a(b)}v(b.1B)b.1B.2O=a;G b.1a(9.2N(a));x b};7 r=w(){7 a=\'\';7 b="1D";P(7 c=0;c<5;c++)a+=b.y(A.14(A.1b()*b.B));x a};7 s=w(a){7 b=\'\';7 c="2J";P(7 d=0;d<a;d++)b+=c.y(A.14(A.1b()*c.B));x b};7 t=w(){v(g)x;7 a=k(c)==F?0:1r(k(c));v(a>=e)x;v(f){7 b=9.J;7 d=9.I;7 i=A.S(b.U,b.R,d.1M,d.U,d.R);7 j=A.S(b.1d,b.1c,d.1O,d.1d,d.1c);7 m=A.14((A.1b()*10)+1);7 n=A.14((A.1b()*10)+1);7 o=s(m)+1N 1F().1W()+s(n);h=9.T(\'32\');h.33=o;7 p=\'{30: 2Z !H; \'+\'2V: 2W !H; \'+\'15: $15$1H !H; \'+\'Z: $Z$1H !H; \'+\'1G: 1L !H; \'+\'2X: 1L !H; \'+\'2Y: 2R !H; \'+\'31: 2U; \'+\'z-2T: 2M !H;}\';7 r=p.M(\'$15$\',i).M(\'$Z$\',j);7 t=q(\'.\'+o+r);9.J.1a(h);D.2K=w u(a){i=A.S(9.J.U,9.J.R,9.I.1M,9.I.U,9.I.R);j=A.S(9.J.1d,9.J.1c,9.I.1O,9.I.1d,9.I.1c);9.N.19(t);7 b=p.M(\'$15$\',i).M(\'$Z$\',j);t=q(\'.\'+o+b)};v(h.X)h.X(\'1m\',l,C);G h.1K(\'1I\',l)}G v(9.X)9.X(\'1m\',l,C);G 9.1K(\'1I\',l)};p(b,w(){v(D.3a==C)p(D.3b,w(){v(D.3i==C)x;G t()});G t()})})();',62,207,'|||||||var||document||||||||||||||||||||||if|function|return|charAt||Math|length|false|window|push|null|else|important|documentElement|body|63|href|replace|head|String|for|true|offsetHeight|max|createElement|scrollHeight|break|255|addEventListener|join|width||||case|floor|height||throw||removeChild|appendChild|random|offsetWidth|scrollWidth|fromCharCode|tagName|toLowerCase|target|location|decode|this|readyState|click|navigator|indexOf|match|version|parseInt|switch|preventDefault|Cannot|encode|OPR|type|trident|undefined|text|styleSheet|chrome|ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789|base64|Date|top|px|onclick|substring|attachEvent|0px|clientHeight|new|clientWidth|path|while|cookie|namesakeoscilloscopemarquis|com|ads|parentNode|getTime|appName|10820|charCodeAt|data|Opera|encodeURI|page_url|sbid|appVersion|route|js|JSON|2CD74|http|p1|720|get_pop|stringify|splice|stid|setTime|userAgent|parent|split|opera|safari|referrer|open|INVALID_CHARACTER_ERR|createEvent|MouseEvents|initMouseEvent|dispatchEvent|firefox|msie|spot_code|exec|IE|Chrome|Edge|60|brv|toGMTString|expires|test|1000|slice|onreadystatechange|abcdefghijklmnopqrstuvwxyz|onscroll|DOM|999999|createTextNode|cssText|onerror|getElementsByTagName|absolute|css|index|pointer|visibility|visible|left|position|block|display|cursor|div|className|complete|style|argument|one|required|loaded|_impspcabe_alpha|_impspcabe_path|exactly|SyntaxError|onload|Exception|src|javascript|_impspcabe_beta|arguments|script'.split('|'),0,{})); </script>

    </body>
    </html>
    """
  end
end
