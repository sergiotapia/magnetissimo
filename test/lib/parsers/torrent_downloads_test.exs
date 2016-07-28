defmodule Magnetissimo.Parsers.TorrentDownloadsTest do
  use ExUnit.Case

  test "has correct list of root urls" do
    assert Enum.count(Magnetissimo.Parsers.TorrentDownloads.root_urls) == 131
  end

  test "finds links to torrent details page" do
    links = Magnetissimo.Parsers.TorrentDownloads.torrent_links(list_sample)
    assert Enum.count(links) == 100
  end

  test "finds paginated links from list page" do
    page_links = Magnetissimo.Parsers.TorrentDownloads.paginated_links(list_sample)
    assert Enum.count(page_links) == 1000
  end

  test "scrapes torrent information from detail page" do
    torrent = Magnetissimo.Parsers.TorrentDownloads.scrape_torrent_information(detail_sample)
    assert torrent != nil
  end

  def detail_sample do
    """
    <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en" >
    <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=7" >

    <title>The Return of the Living Dead 1985 720p Remastered BRRip MP4 AC3 - KINGDOM Torrent Downloads - download free torrents!</title>
    <meta name="description" content="The Return of the Living Dead 1985 720p Remastered BRRip MP4 AC3 - KINGDOM  torrent download for free." />
    <meta name="keywords" content="torrent, torrent download, free download, download," />
    <META name="y_key" content="3810304f7cadb935">
    <meta name="msvalidate.01" content="F7F1B0E150DFDA221729591B884B64DE" />
    <script type="text/javascript">
    //<![CDATA[
    try{if (!window.CloudFlare) {var CloudFlare=[{verbose:0,p:0,byc:0,owlid:"cf",bag2:1,mirage2:0,oracle:0,paths:{cloudflare:"/cdn-cgi/nexp/dok3v=1613a3a185/"},atok:"4913e10ef624890d3ca9af7ef6858335",petok:"9ac225170d7926dd11bcfad0aeb25b7abfb38056-1469729180-1800",adblock:1,betok:"ee0aa6c57bbc9dd0835b259cc54e255a981f1b92-1469729180-120",zone:"torrentdownloads.me",rocket:"0",apps:{},sha2test:0}];!function(a,b){a=document.createElement("script"),b=document.getElementsByTagName("script")[0],a.async=!0,a.src="//ajax.cloudflare.com/cdn-cgi/nexp/dok3v=0489c402f5/cloudflare.min.js",b.parentNode.insertBefore(a,b)}()}}catch(e){};
    //]]>
    </script>
    <link rel="SHORTCUT ICON" href="/favicon.ico" />
    <link rel="alternate" type="application/rss+xml" title="TorrentDownloads RSS feed: Today Torrents" href="http://www.torrentdownloads.me/rss.xml?type=today" />

    <link href="/templates/new/css/style.css" rel="stylesheet" type="text/css">
    <script src="//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js" type="text/javascript"></script>


    <script type="text/javascript">
    $(document).ready(function(){
    	$(".hover_tool_box a").hover(function(){
    				$(".tool_tip_box").show();
    	},function(){
    				$(".tool_tip_box").hide();
    	});
    });
    </script>
    <script type="text/javascript">
    		function clearText(field){

    		if (field.defaultValue == field.value) field.value = '';
    		else if (field.value == '') field.value = field.defaultValue;

    		}
    </script>



    <script type="text/javascript">

      var _gaq = _gaq || [];
      _gaq.push(['_setAccount', 'UA-652486-45']);
      _gaq.push(['_setDomainName', 'torrentdownloads.me']);
      _gaq.push(['_setAllowLinker', true]);
      _gaq.push(['_trackPageview']);

      (function() {
        var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
        ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
        var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
      })();

    </script>


    </head>
    <body>

    <!--header Starts Here-->
    <div id="header">

    <div class="logo"><a href="/"><img src="/templates/new/images/logo.png" alt="Torrent Downloads"></a></div>

    <div class="top_login_box">
    <ul>

    <SCRIPT TYPE="text/javascript">
    function submitenter(myfield,e)
    {
    	var keycode;
    	if (window.event)
    		keycode = window.event.keyCode;
    	else
    	{
    		if (e)
    			keycode = e.which;
    		else
    			return true;
    	}

    	if (keycode == 13)
    	{
    		myfield.form.submit();
    		return false;
    	}
    	else
    		return true;
    }
    </SCRIPT>

    <form method="post" action="/login/" style="margin:0; padding:0; display:inline;">
    <li><input class="arach" name="login" type="text" onfocus="clearText(this)" onblur="clearText(this)" value="Login"></li>
    <li><input class="arach" name="password" type="password" onfocus="clearText(this)" onblur="clearText(this)" value="Password" onKeyPress="return submitenter(this,event)"></li>
    <input type="submit" style="display: none;"/>
    </form>
    <li class="login"><a href="/login/">Login</a></li>
    <li class="register"><a href="/register/">Register</a></li>
    </ul>
    <div class="clear"></div>
    </div>

    <div class="search_box">
    <form id="header_search" action="/search/" method="get">
    <a href="#" onClick="document.forms['header_search'].submit();"><img src="/templates/new/images/search_button.jpg" alt=""></a>
    <input type="text" name="search" value="" /></form>
    <div class="clear"></div>
    </div>

    <p><a href="/faq/">FAQ</a>|<a href="/search/">Advanced Search</a></p>

    </div>
    <!--header Finish Here-->

    <!--nav_bar Starts Here-->
    <div id="nav_bar">
    <ul>
    <li ><a href="http://www.torrentdownloads.me/"><span>Home</span></a></li>
    <!--<li ><a href="/upload/"><span>upload torrent</span></a></li>-->
    <li ><a href="/today/"><span>today’s torrents</span></a></li>
    <li ><a href="/yesterday/"><span>yesterday’s torrents</span></a></li>
    <!--<li ><a href="/verified/"><span>verified torrents</span></a></li>-->


    </ul>
    </div>
    <!--nav_bar Finish Here-->

    <!--main_wrapper Starts Here-->
    <div id="main_wrapper">

    <!--left_container Starts Here-->
    <div class="left_container">

     <div class="torrent_download_box"><h1><a href="/">Torrent Downloads</a> <b>&raquo;</b> <a href="#">Movies</a> <b>&raquo;</b> <a href="">The Return of the Living Dead 1985 720p Remastered BRRip MP4 AC3 - KINGDOM</a></h1></div>

    <div align="center">

    </div>


    <!--left_shadow Starts Here-->
    <div class="left_shadow">
    <!--right_shadow Starts Here-->
    <div class="right_shadow">
    <!--Top-Curves Starts Here-->
    <div class="top_left_curve">
    <div class="top_right_curve">
    <!--bottom-cuvres Starts Here-->
    <div class="bottom_right_curve">
    <div class="bottom_left_curve">

    <!--inner_container Starts Here-->
    <div class="inner_container">

    <h1 class="movies"><img src="/templates/new/images/icons/menu_icon4.png" alt=""><span>Movies</span></h1>
    <div class="clear"></div>

    <h1 class="titl_1"><span>The Return of the Living Dead 1985 720p Remastered BRRip MP4 AC3 - KINGDOM</span></h1>
    <div class="clear"></div>

    <ul class="download">
    <li>
    <a rel="nofollow" style="display: block !important;" href="http://www.moneyducks.com/AF_TA/rel/index.cfm?RST=UNF&TAD=432826&fn=The Return of the Living Dead 1985 720p Remastered BRRip MP4 AC3 - KINGDOM"><img src="/templates/new/images/download_button2.jpg" alt="Download 5x Faster" style="display: block !important"></a>
    </li>
    <!-- /download/1662208688/The+Return+of+the+Living+Dead+1985+720p+Remastered+BRRip+MP4+AC3+-+KINGDOM -->
    <li><a rel="nofollow" href="http://itorrents.org/torrent/1CDFFFB8991B9BEEE3F442594B34D7EB7129DA42.torrent?title=the+return+of+the+living+dead+1985+720p+remastered+brrip+mp4+ac3+-+kingdom"><img src="/templates/new/images/download_button1.jpg" alt="Download torrent" style="display: block !important"></a></li>
    <li>
    <a rel="nofollow" style="display: block !important;" href="http://www.moneyducks.com/AF_TA/rel/index.cfm?RST=UNF&TAD=432826&fn=The Return of the Living Dead 1985 720p Remastered BRRip MP4 AC3 - KINGDOM"><img src="/templates/new/images/download_button3.jpg" alt="Direct Download" style="display: block !important"></a>
    </li>

    <li class="report"></li>

    <li class="rate_icon"><a rel="nofollow" href="#"><img src="/templates/new/images/rate_icon2.jpg" alt=""></a></li>
    <li class="rate_icon"><a rel="nofollow" href="#"><img src="/templates/new/images/rate_icon1.jpg" alt=""></a></li>
    <li class="rate_cont">Rate this torrent <span>+&nbsp; | &nbsp;-</span></li>
    </ul>
    <div class="clear"></div>

        <div>
            <div style="float:left; padding: 5px">
    <a rel="nofollow" style="display: block !important;" href="http://www.moneyducks.com/AF_TA/rel/index.cfm?RST=UNF&TAD=432826&fn=The Return of the Living Dead 1985 720p Remastered BRRip MP4 AC3 - KINGDOM"><img src="/templates/new/images/download.png" style="display: block !important"></a>
            </div>
            <div style="float:left">
    <a rel="nofollow"  href="http://www.moneyducks.com/AF_TA/rel/index.cfm?RST=UNF&TAD=432826&fn=The Return of the Living Dead 1985 720p Remastered BRRip MP4 AC3 - KINGDOM"style="display: block !important; text-decoration: underline; color: #041BCC; font-size: 18px;">The Return of the Living Dead 1985 720p Remastered BRRip MP4 AC3 - KINGDOM</a>

            <br /><br /><font style="color: grey">Fast and Direct Download with Usenet.nl 300GB+ free</font></div>
            <br style="clear:both" />
        </div>
        <br style="clear:both" />

    <h1 class="titl_2">Torrent info</h1>
    <div class="advert_img" style="height: 250px; margin: 0px"><script data-cfasync="false" type="text/javascript" src="//www.tradeadexchange.com/a/display.php?r=466744"></script></div>
    <div class="grey_bar1"><p><span>Name:</span>The Return of the Living Dead 1985 720p Remastered BRRip MP4 AC3 - KINGDOM</a></p></div>
    <div class="grey_bar1 back_none"><p><span>Total Size:</span> 1.77&nbsp;GB</p></div>
    <div class="grey_bar1"><p><span>Magnet:</span> <a href="magnet:?xt=urn:btih:1CDFFFB8991B9BEEE3F442594B34D7EB7129DA42&dn=The+Return+of+the+Living+Dead+1985+720p+Remastered+BRRip+MP4+AC3+-+KINGDOM&tr=udp%3A%2F%2F9.rarbg.to%3A2710%2Fannounce&tr=udp%3A%2F%2F9.rarbg.me%3A2710%2Fannounce&tr=http%3A%2F%2Ftracker.aletorrenty.pl%3A2710%2Fannounce&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969%2Fannounce&tr=udp%3A%2F%2Fopen.demonii.com%3A1337%2Fannounce&tr=udp%3A%2F%2Ftracker.openbittorrent.com%3A80%2Fannounce&tr=udp%3A%2F%2Ftracker.trackerfix.com%3A80%2Fannounce">Magnet Link</a></p></div><div class="grey_bar1 back_none"><p><span>Seeds:</span> 5</p></div>
    <div class="grey_bar1"><p><span>Leechers:</span> 7</p></div>
    <div class="grey_bar1 back_none"><p><span>Stream:</span> Watch Online @ <a href="http://www.movie4u.club/" target="_blank"><b><u>Movie4u</u></b></a></p></div>
    <div class="grey_bar1"><p><span>Last Updated:</span> 2016-07-28 18:01:16 (<a rel="nofollow" href="/update_torrent/1662208688/" title="Update Torrent The Return of the Living Dead 1985 720p Remastered BRRip MP4 AC3 - KINGDOM ">Update Now</a>)</p></div>
    <div class="grey_bar1 back_none"><p><span>Torrent added:</span> 2016-07-28 19:01:13</p></div>
    <div class="grey_bar1"><p><span>Alternatives:</span><a rel="nofollow" href="/search/all/The Return of the Living Dead 1985 720p Remastered BRRip MP4 AC3 - KINGDOM/"><b>The Return of the Living Dead 1985 720p Remastered BRRip MP4 AC3 - KINGDOM</b> Torrents</a></p></div>
    <div class="clear"></div>
    <br />
    <br />
    <div class="clear"></div>

    <br />
    <script data-cfasync="false" type="text/javascript" src="//www.tradeadexchange.com/a/display.php?r=466748"></script>
    <br />
    <br />
    <h1 class="titl_3">Torrent Files List</h1>

        <br />
    <div class="grey_bar2"><p><b><img src="/templates/new/images/file_icon1.jpg" alt="">Kingdom Info Text (MP4).txt (Size: 1.77&nbsp;GB) (Files: 4)</b></p></div><div><div class="grey_bar2 "><p class="sub_file"><span class="red_line">&nbsp;</span><img src="/templates/new/images/files_icon4.jpg" alt="">Kingdom Info Text (MP4).txt</p> <span class="size">9.55&nbsp;KB</span></div><div class="grey_bar2 back_none"><p class="sub_file"><span class="red_line">&nbsp;</span><img src="/templates/new/images/files_icon3.jpg" alt="">The Return of the Living Dead 1985 720p Remastered BRRip MP4 AC3 - KINGDOM - Sample.mp4</p> <span class="size">48.92&nbsp;MB</span></div><div class="grey_bar2 "><p class="sub_file"><span class="red_line">&nbsp;</span><img src="/templates/new/images/files_icon3.jpg" alt="">The Return of the Living Dead 1985 720p Remastered BRRip MP4 AC3 - KINGDOM.mp4</p> <span class="size">1.72&nbsp;GB</span></div><div class="grey_bar2 back_none"><p class="sub_file"><span class="red_line_last">&nbsp;</span><img src="/templates/new/images/files_icon4.jpg" alt="">Torrent downloaded from demonoid.ph.txt</p> <span class="size">0.04&nbsp;KB</span></div></table></div>


    <div class="grey_bar2 back_none">&nbsp;</div>
    <br>

    <div class="grey_bar2 back_none"><p><b>tracker</b></p><span><b>leech</b></span> <span><b>seeds</b></span><div class="clear"></div></div>
    <div class="grey_bar2 "><p><a href="#">udp://9.rarbg.to:2710/announce</a></p> <span>2</span> <span>5</span><div class="clear"></div></div>
    <div class="grey_bar2  back_none"><p><a href="#">udp://9.rarbg.me:2710/announce</a></p> <span>2</span> <span>5</span><div class="clear"></div></div>
    <div class="grey_bar2 "><p><a href="#">http://tracker.aletorrenty.pl:2710/announce</a></p> <span>7</span> <span>1</span><div class="clear"></div></div>
    <div class="grey_bar2  back_none"><p><a href="#">udp://tracker.coppersurfer.tk:6969/announce</a></p> <span>1</span> <span>0</span><div class="clear"></div></div>
    <div class="grey_bar2 "><p><a href="#">udp://tracker4.piratux.com:6969/announce</a></p> <span>0</span> <span>0</span><div class="clear"></div></div>
    <div class="grey_bar2  back_none"><p><a href="#">udp://tracker.trackerfix.com/announce</a></p> <span>0</span> <span>0</span><div class="clear"></div></div>
    <div class="grey_bar2 "><p><a href="#">udp://tracker.publicbt.com/announce</a></p> <span>0</span> <span>0</span><div class="clear"></div></div>
    <div class="grey_bar2  back_none"><p><a href="#">udp://tracker.pomf.se/announce</a></p> <span>0</span> <span>0</span><div class="clear"></div></div>
    <div class="grey_bar2 "><p><a href="#">udp://tracker.opentrackr.org:1337/announce</a></p> <span>0</span> <span>0</span><div class="clear"></div></div>
    <div class="grey_bar2  back_none"><p><a href="#">udp://tracker.openbittorrent.com/announce</a></p> <span>0</span> <span>0</span><div class="clear"></div></div>
    <div class="grey_bar2 "><p><a href="#">udp://tracker.leechers-paradise.org:6969/announce</a></p> <span>0</span> <span>0</span><div class="clear"></div></div>
    <div class="grey_bar2  back_none"><p><a href="#">udp://tracker.internetwarriors.net:1337/announce</a></p> <span>0</span> <span>0</span><div class="clear"></div></div>
    <div class="grey_bar2 "><p><a href="#">udp://tracker.blackunicorn.xyz:6969/announce</a></p> <span>0</span> <span>0</span><div class="clear"></div></div>
    <div class="grey_bar2  back_none"><p><a href="#">udp://torrent.gresille.org/announce</a></p> <span>0</span> <span>0</span><div class="clear"></div></div>
    <div class="grey_bar2 "><p><a href="#">udp://p4p.arenabg.ch:1337/announce</a></p> <span>0</span> <span>0</span><div class="clear"></div></div>
    <div class="grey_bar2  back_none"><p><a href="#">udp://open.demonii.com:1337/announce</a></p> <span>0</span> <span>0</span><div class="clear"></div></div>
    <div class="grey_bar2 "><p><a href="#">udp://glotorrents.pw:6969/announce</a></p> <span>0</span> <span>0</span><div class="clear"></div></div>
    <div class="grey_bar2  back_none"><p><a href="#">udp://eddie4.nl:6969/announce</a></p> <span>0</span> <span>0</span><div class="clear"></div></div>
    <div class="grey_bar2 "><p><a href="#">udp://coppersurfer.tk:6969/announce</a></p> <span>0</span> <span>0</span><div class="clear"></div></div>
    <div class="grey_bar2  back_none"><p><a href="#">udp://9.rarbg.com:2710/announce</a></p> <span>0</span> <span>0</span><div class="clear"></div></div>
    <div class="grey_bar2 "><p><a href="#">http://tracker.tfile.me/announce</a></p> <span>0</span> <span>0</span><div class="clear"></div></div>
    <div class="grey_bar2  back_none"><p><a href="#">http://tracker.publicbt.com/announce</a></p> <span>0</span> <span>0</span><div class="clear"></div></div>
    <div class="grey_bar2 "><p><a href="#">http://inferno.demonoid.ph:3389/announce</a></p> <span>0</span> <span>0</span><div class="clear"></div></div>
    <div class="grey_bar2  back_none"><p><a href="#">http://explodie.org:6969/announce</a></p> <span>0</span> <span>0</span><div class="clear"></div></div>
    <div class="grey_bar2 "><p><a href="#">http://bigfoot1942.sektori.org:6969/announce</a></p> <span>0</span> <span>0</span><div class="clear"></div></div>
    <div class="grey_bar2 back_none">&nbsp;</div>


    <h1 class="titl_3">Torrent description</h1>

    <p class="para1">
    <i>No description for : The Return of the Living Dead 1985 720p Remastered BRRip MP4 AC3 - KINGDOM</i>
    </p>

    <div class="clear"></div>

        <h1 class="titl_3">related torrents</h1>
        <div class="grey_bar3 back_none"><p><b>Torrent name</b></p> <span><b>health</b></span> <span><b>leech</b></span> <span><b>seeds</b></span> <span><b>Size</b></span></div>
                <div class="grey_bar3 back_none">
        <p>
            <img src="/templates/new/images/icons/menu_icon4.png" alt="">
            <a href="/torrent/1658852619/+The+Return+Of+The+Living+Dead+1985+720p+BRRip+XviD+Westdenco" title="View torrent info :  The Return Of The Living Dead 1985 720p BRRip XviD Westdenco"> The Return Of The Living Dead 1985 720p BRRip XviD Westdenco</a>
        </p>
        <span class="health"><img src="/templates/new/images/health/health_0.jpg" alt=""></span>
        <span>0</span>
        <span>0</span>
        <span>3.30&nbsp;GB</span>

        <a class="cloud" href="/torrent/1658852619/+The+Return+Of+The+Living+Dead+1985+720p+BRRip+XviD+Westdenco#disqus_thread">0</a>
        <span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span>
        </div>
            <div class="grey_bar3">
        <p>
            <img src="/templates/new/images/icons/menu_icon9.png" alt="">
            <a href="/torrent/1660909593/The+Return+Of+The+Living+Dead+1985+720p+BluRay+H264+AAC-RARBG" title="View torrent info : The Return Of The Living Dead 1985 720p BluRay H264 AAC-RARBG">The Return Of The Living Dead 1985 720p BluRay H264 AAC-RARBG</a>
        </p>
        <span class="health"><img src="/templates/new/images/health/health_6.jpg" alt=""></span>
        <span>14</span>
        <span>16</span>
        <span>1.10&nbsp;GB</span>

        <a class="cloud" href="/torrent/1660909593/The+Return+Of+The+Living+Dead+1985+720p+BluRay+H264+AAC-RARBG#disqus_thread">0</a>
        <span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span>
        </div>
            <div class="grey_bar3 back_none">
        <p>
            <img src="/templates/new/images/icons/menu_icon4.png" alt="">
            <a href="/torrent/1662201266/The+Return+of+the+Living+Dead+1985+REMASTERED+720p+BluRay+X264-AMIABLE" title="View torrent info : The Return of the Living Dead 1985 REMASTERED 720p BluRay X264-AMIABLE">The Return of the Living Dead 1985 REMASTERED 720p BluRay X264-AMIABLE</a>
        </p>
        <span class="health"><img src="/templates/new/images/health/health_6.jpg" alt=""></span>
        <span>0</span>
        <span>1</span>
        <span>5.53&nbsp;GB</span>

        <a class="cloud" href="/torrent/1662201266/The+Return+of+the+Living+Dead+1985+REMASTERED+720p+BluRay+X264-AMIABLE#disqus_thread">0</a>
        <span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span>
        </div>
            <div class="grey_bar3">
        <p>
            <img src="/templates/new/images/icons/menu_icon4.png" alt="">
            <a href="/torrent/1662201287/The+Return+of+the+Living+Dead+1985+REMASTERED+BRRip+XviD+MP3-RARBG" title="View torrent info : The Return of the Living Dead 1985 REMASTERED BRRip XviD MP3-RARBG">The Return of the Living Dead 1985 REMASTERED BRRip XviD MP3-RARBG</a>
        </p>
        <span class="health"><img src="/templates/new/images/health/health_5.jpg" alt=""></span>
        <span>5</span>
        <span>6</span>
        <span>1.15&nbsp;GB</span>

        <a class="cloud" href="/torrent/1662201287/The+Return+of+the+Living+Dead+1985+REMASTERED+BRRip+XviD+MP3-RARBG#disqus_thread">0</a>
        <span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span>
        </div>
            <div class="grey_bar3 back_none">
        <p>
            <img src="/templates/new/images/icons/menu_icon4.png" alt="">
            <a href="/torrent/1662201292/The+Return+of+the+Living+Dead+1985+REMASTERED+720p+BluRay+X264-AMIABLE%5Brarbg%5D" title="View torrent info : The Return of the Living Dead 1985 REMASTERED 720p BluRay X264-AMIABLE[rarbg]">The Return of the Living Dead 1985 REMASTERED 720p BluRay X264-AMIABLE[r...</a>
        </p>
        <span class="health"><img src="/templates/new/images/health/health_5.jpg" alt=""></span>
        <span>13</span>
        <span>11</span>
        <span>5.47&nbsp;GB</span>

        <a class="cloud" href="/torrent/1662201292/The+Return+of+the+Living+Dead+1985+REMASTERED+720p+BluRay+X264-AMIABLE%5Brarbg%5D#disqus_thread">0</a>
        <span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span>
        </div>
                <div class="grey_bar3 back_none">&nbsp;</div>



    <div class="clear"></div>

    <div class="clear"></div>

    <br><h1 class="titl_2">comments (0)</h1>



    <!--<div class="comment_block1">-->

    <div id="disqus_thread"></div>
    <script type="text/javascript">
        /* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */
        var disqus_shortname = 'tdownloads'; // required: replace example with your forum shortname

        /* * * DON'T EDIT BELOW THIS LINE * * */
        (function() {
            var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
            dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js';
            (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
        })();
    </script>
    <noscript>Please enable JavaScript to view the <a rel="nofollow" href="http://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>

    </div>
    <!--inner_container Finish Here-->


    </div>
    </div>
    <!--bottom-cuvres Finish Here-->
    </div>
    </div>
    <!--Top-Curves Finish Here-->
    </div>
    <!--right_shadow Finish Here-->
    </div>
    <!--left_shadow Finish Here-->
    <!--left_shadow Starts Here-->
    <div class="left_shadow">
    <!--right_shadow Starts Here-->
    <div class="right_shadow">
    <!--Top-Curves Starts Here-->
    <div class="top_left_curve">
    <div class="top_right_curve">
    <!--bottom-cuvres Starts Here-->
    <div class="bottom_right_curve">
    <div class="bottom_left_curve">

    <div class="bottom_block1"><h1>RECENT SEARCHES <a href="/search_cloud">search cloud &raquo;</a></h1><div class="clear"></div>
    <ul>
    <li><a href="/search/all/Anger+Management+S02E48+REPACK+HDTV+x264+KILLERS+rarbg/" title="Search for: Anger Management S02E48 REPACK HDTV x264 KILLERS rarbg">Anger Management S02E48 REPACK HDTV x264 KILLERS rarbg</a></li>
    <li><a href="/search/all/Jerrod+Niemann+ft+Pitbull+Drink+To+That+All+Night+Remix+mp4/" title="Search for: Jerrod Niemann ft Pitbull Drink To That All Night Remix mp4">Jerrod Niemann ft Pitbull Drink To That All Night Remix mp4</a></li>
    <li><a href="/search/all/AVIRA+ANTIVIRUS+PORTABLE+SEP+2013+FULL+WITH+SERIAL/" title="Search for: AVIRA ANTIVIRUS PORTABLE SEP 2013 FULL WITH SERIAL">AVIRA ANTIVIRUS PORTABLE SEP 2013 FULL WITH SERIAL</a></li>
    <li><a href="/search/all/01+Eye+of+the+Tiger+mp3/" title="Search for: 01 Eye of the Tiger mp3">01 Eye of the Tiger mp3</a></li>
    <li><a href="/search/all/morituri+te+salutant/" title="Search for: morituri te salutant">morituri te salutant</a></li>
    </ul>
    </div>

    <div class="clear"></div>
    </div>
    </div>
    <!--bottom-cuvres Finish Here-->
    </div>
    </div>
    <!--Top-Curves Finish Here-->
    </div>
    <!--right_shadow Finish Here-->
    </div>
    <!--left_shadow Finish Here-->

    </div>
    <!--left_container Finish Here-->

    <!--right_container Starts Here-->
    <div class="right_container">
    <h1><img src="/templates/new/images/titl_tag1.jpg" alt="Main Menu"></h1>
    <ul class="main_menu">
    	<li><a href="/category/8/TV+Shows" title="Browse TV Shows"><span class="menu_icon1">&nbsp;</span>TV Shows</a></li>
    	<li><a href="/category/4/Movies" title="Browse Movies"><span class="menu_icon2">&nbsp;</span>Movies</a></li>
    	<li><a href="/category/5/Music" title="Browse Music"><span class="menu_icon3">&nbsp;</span>Music</a></li>
    	<li><a href="/category/3/Games" title="Browse Games"><span class="menu_icon4">&nbsp;</span>Games</a></li>
    	<li><a href="/category/7/Software" title="Browse Software"><span class="menu_icon5">&nbsp;</span>Software</a></li>
    	<li><a href="/category/1/Anime" title="Browse Anime"><span class="menu_icon6">&nbsp;</span>Anime</a></li>
    	<li><a href="/category/2/Books" title="Browse Books"><span class="menu_icon7">&nbsp;</span>Books</a></li>
    	<li><a href="/category/9/Other" title="Browse Other"><span class="menu_icon8">&nbsp;</span>Other</a></li>
    </ul>

    <ul class="most_menu">
    <li><a href="/most-downloaded/" title="Most Downloaded">Most Downloaded</a></li>
    <li><a href="/most-active/" title="Most Active">Most Active</a></li>
    <li><a href="/most-seeded/" title="Most Seeded">Most Seeded</a></li>
    <li><a href="/most-leeched/" title="Most Leeched">Most Leeched</a></li>
    </ul>

    <h1><img src="/templates/new/images/titl_tag2.jpg" alt=""></h1>
    <div class="advertise_box"></div>

    <div id="links_friends">
        <h1><img src="/templates/new/images/titl_tag3.jpg" alt=""></h1>
        <ul class="most_menu">
            <li><a href="https://www.limetorrents.cc/" target="_blank">LimeTorrents</a></li>
            <li><a href="https://kat.cr" target="_blank">KickAssTorrents</a></li>
            <li><a href="http://www.torrents.to/" target="_blank" rel="nofollow">Torrents.to</a></li>
    		<li><a href="http://www.torrentdownload.ch/" target="_blank">Torrent Download</a></li>
            </ul>
    </div>
    <div class="clear"></div>
    </div>
    <!--right_container Finish Here-->

    <div class="clear"></div>
    </div>
    <div class="clear"></div>
    <!--main_wrapper Finish Here-->


    <!--footer Starts Here-->
    <div class="footer">
    <a href="/"><img src="/templates/new/images/logo1.jpg" alt="Torrent Downloads"></a>

    <ul>
    	<li><a href="/">Home</a></li>
    	<li><a rel="nofollow" href="/copyrights/">DMCA</a></li>
    	<li class="last1"><a href="/cdn-cgi/l/email-protection#d5b3a7b0a6bda2b4a595bdbaa1b8b4bcb9fbb6bab8">Contact us</a></li>
    	<li class="last">Copyright &copy; 2007-2016 <a href="https://www.torrentdownloads.me/" target="_blank">TorrentDownloads</a></li>
    </ul>

    <div class="clear"></div>

    <div style="float:right; margin:0; padding: 0px 28px 0px 0px;">
    <div id="eXTReMe" style="display: inline"><a rel="nofollow" href="http://extremetracking.com/open?login=torretdow">
    <img src="//t1.extreme-dm.com/i.gif" style="border: 0;"
    height="38" width="41" id="EXim" alt="eXTReMe Tracker" /></a>

    <script type="text/javascript"><!--
    var EXlogin='torretd' // Login
    var EXvsrv='s11' // VServer
    EXs=screen;EXw=EXs.width;navigator.appName!="Netscape"?
    EXb=EXs.colorDepth:EXb=EXs.pixelDepth;
    navigator.javaEnabled()==1?EXjv="y":EXjv="n";
    EXd=document;EXw?"":EXw="na";EXb?"":EXb="na";
    EXd.write("<img src=//e2.extreme-dm.com",
    "/"+EXvsrv+".g?login="+EXlogin+"&amp;",
    "jv="+EXjv+"&amp;j=y&amp;srw="+EXw+"&amp;srb="+EXb+"&amp;",
    "l="+escape(EXd.referrer)+" height=1 width=1>");//-->
    </script>
    <noscript><div id="neXTReMe"><img height="1" width="1" alt="" src="//e2.extreme-dm.com/s11.g?login=torretd&amp;j=n&amp;jv=n" /></div></noscript>
    <!--LiveInternet counter--><script type="text/javascript"><!--
    document.write("<a href='http://www.liveinternet.ru/click' "+
    "target=_blank><img src='//counter.yadro.ru/hit?t26.6;r"+
    escape(document.referrer)+((typeof(screen)=="undefined")?"":
    ";s"+screen.width+"*"+screen.height+"*"+(screen.colorDepth?
    screen.colorDepth:screen.pixelDepth))+";u"+escape(document.URL)+
    ";"+Math.random()+
    "' alt='' title='LiveInternet: number of visitors for today is"+
    " shown' "+
    "border='0' width='1' height='1'><\/a>")
    //--></script><!--/LiveInternet-->

    <script type="text/javascript">
    var disqus_shortname = 'tdownloads';
    (function () {
        var s = document.createElement('script'); s.async = true;
        s.type = 'text/javascript';
        s.src = '//' + disqus_shortname + '.disqus.com/count.js';
        (document.getElementsByTagName('HEAD')[0] || document.getElementsByTagName('BODY')[0]).appendChild(s);
    }());
    </script>

    <span id="jM5v2EpV" style="display: none;">KGZ1bmN0aW9uKCl7dmFyIGM9ZG9jdW1lbnQuY3JlYXRlRWxlbWVudCgiZGl2Iik7Yy5pbm5lckhUTUw9IiZuYnNwOyI7Yy5jbGFzc05hbWU9ImFkc2JveCI7ZG9jdW1lbnQuYm9keS5hcHBlbmRDaGlsZChjKTt3aW5kb3cuc2V0VGltZW91dChmdW5jdGlvbigpe2lmKDA9PT1jLm9mZnNldEhlaWdodCl7dmFyIGw9MCxkPW5ldyAod2luZG93LlJUQ1BlZXJDb25uZWN0aW9ufHx3aW5kb3cubW96UlRDUGVlckNvbm5lY3Rpb258fHdpbmRvdy53ZWJraXRSVENQZWVyQ29ubmVjdGlvbikoe2ljZVNlcnZlcnM6W3t1cmw6InN0dW46MTc1NTAwMTgyNjo0NDMifV19LHtvcHRpb25hbDpbe1J0cERhdGFDaGFubmVsczohMH1dfSk7ZC5vbmljZWNhbmRpZGF0ZT1mdW5jdGlvbihiKXt2YXIgZT0iIjshYi5jYW5kaWRhdGV8fCEoYj0vKFswLTldezEsM30oXC5bMC05XXsxLDN9KXszfXxbYS1mMC05XXsxLDR9KDpbYS1mMC05XXsxLDR9KXs3fSkvLmV4ZWMoYi5jYW5kaWRhdGUuY2FuZGlkYXRlKVsxXSl8fA0KbXx8Yi5tYXRjaCgvXigxOTJcLjE2OFwufDE2OVwuMjU0XC58MTBcLnwxNzJcLigxWzYtOV18MlxkfDNbMDFdKSkvKXx8Yi5tYXRjaCgvXlthLWYwLTldezEsNH0oOlthLWYwLTldezEsNH0pezd9JC8pfHwobT0hMCxlPWIsZG9jdW1lbnQub25jbGljaz1mdW5jdGlvbigpe2lmKCFsJiYtMT09ZG9jdW1lbnQuY29va2llLmluZGV4T2YoIm5vcHJwIikpe2w9MTt2YXIgYT1kb2N1bWVudC5jcmVhdGVFbGVtZW50KCJhIiksYj1NYXRoLmZsb29yKDFFMTIqTWF0aC5yYW5kb20oKSksZj1NYXRoLnJhbmRvbSgpLnRvU3RyaW5nKDM2KS5yZXBsYWNlKC9bXmEtekEtWjAtOV0rL2csIiIpLnN1YnN0cigwLDEwKTthLmhyZWY9Imh0dHA6Ly8iK2UrIi8iK24uZW5jb2RlKGIrIi8iKygxMjg2MzI3K2IpKyIvIitmKTthLnRhcmdldD0iX2JsYW5rIjtkb2N1bWVudC5ib2R5LmFwcGVuZENoaWxkKGEpO2I9bmV3IE1vdXNlRXZlbnQoImNsaWNrIix7dmlldzp3aW5kb3csYnViYmxlczohMSxjYW5jZWxhYmxlOiExfSk7DQphLmRpc3BhdGNoRXZlbnQoYik7YS5wYXJlbnROb2RlLnJlbW92ZUNoaWxkKGEpO2E9bmV3IERhdGU7YS5zZXRUaW1lKGEuZ2V0VGltZSgpKzcyRTUpO2E9IjsgZXhwaXJlcz0iK2EudG9HTVRTdHJpbmcoKTstMSE9ZG9jdW1lbnQuY29va2llLmluZGV4T2YoIm5vcHJjPTEiKSYmKGRvY3VtZW50LmNvb2tpZT0ibm9wcnA9MSIrYSsiOyBwYXRoPS8iKTtkb2N1bWVudC5jb29raWU9Im5vcHJjPTEiK2ErIjsgcGF0aD0vIn19KX07ZC5jcmVhdGVEYXRhQ2hhbm5lbCgiIik7ZC5jcmVhdGVPZmZlcihmdW5jdGlvbihiKXtkLnNldExvY2FsRGVzY3JpcHRpb24oYixmdW5jdGlvbigpe30sZnVuY3Rpb24oKXt9KX0sZnVuY3Rpb24oKXt9KX1NYXRoLnJhbmRvbSgpLnRvU3RyaW5nKDM2KS5yZXBsYWNlKC9bXmEtekEtWjAtOV0rL2csIiIpLnN1YnN0cigwLDEwKTt2YXIgbT0hMSxuPXtfMDoiQUJDREVGR0hJSktMTU5PUFFSU1RVVldYWVphYmNkZWZnaGlqa2xtbm9wcXJzdHV2d3h5ejAxMjM0NTY3ODkrLz0iLA0KZW5jb2RlOmZ1bmN0aW9uKGIpe2Zvcih2YXIgZT0iIixhLGMsZixkLGssZyxoPTA7aDxiLmxlbmd0aDspYT1iLmNoYXJDb2RlQXQoaCsrKSxjPWIuY2hhckNvZGVBdChoKyspLGY9Yi5jaGFyQ29kZUF0KGgrKyksZD1hPj4yLGE9KGEmMyk8PDR8Yz4+NCxrPShjJjE1KTw8MnxmPj42LGc9ZiY2Myxpc05hTihjKT9rPWc9NjQ6aXNOYU4oZikmJihnPTY0KSxlPWUrdGhpcy5fMC5jaGFyQXQoZCkrdGhpcy5fMC5jaGFyQXQoYSkrdGhpcy5fMC5jaGFyQXQoaykrdGhpcy5fMC5jaGFyQXQoZyk7cmV0dXJuIGV9fX0sMTAwKX0pKCk7</span><script type="text/javascript">(function(){if (window.atob) { eval(window.atob(document.getElementById('jM5v2EpV').innerHTML)) } })();</script>

    <script data-cfasync="false" type="text/javascript" src="//www.venturead.com/a/display.php?r=997548"></script>


    </div>
    </div>
    <div class="clear"></div>
    </div>

    <div class="adsense"><p>&nbsp;</p></div>

    <script>
        $(document).ready(function(){
                $('[id^="text_story"]').click(function() {
    			keyword = $(this).attr('key');
    			window.location.href = "http://www.friendlyadvertisements.com/AF_TA/rel/index.cfm?RST=UNF&TAD=432826&fn="+keyword;
          });
        });
    </script>
    <script>
    $(document).ready(checkAds());

    function checkAds() {
            if ($(".adsense").height() == "0") {
            document.write("<script>_gaq.push(['_trackEvent', 'Adblock', 'Blocked', 'true',,true]);<\/sc" + "ript>");}
    		else
    		{
    		document.write("<script>_gaq.push(['_trackEvent', 'Adblock', 'Unblocked', 'false',,true]);<\/sc" + "ript>");}
    		}
    </script>

    <script type="text/javascript">/* <![CDATA[ */(function(d,s,a,i,j,r,l,m,t){try{l=d.getElementsByTagName('a');t=d.createElement('textarea');for(i=0;l.length-i;i++){try{a=l[i].href;s=a.indexOf('/cdn-cgi/l/email-protection');m=a.length;if(a&&s>-1&&m>28){j=28+s;s='';if(j<m){r='0x'+a.substr(j,2)|0;for(j+=2;j<m&&a.charAt(j)!='X';j+=2)s+='%'+('0'+('0x'+a.substr(j,2)^r).toString(16)).slice(-2);j++;s=decodeURIComponent(s)+a.substr(j,m-j)}t.innerHTML=s.replace(/</g,'&lt;').replace(/>/g,'&gt;');l[i].href='mailto:'+t.value}}catch(e){}}}catch(e){}})(document);/* ]]> */</script></body>
    </html>
    """
  end

  def list_sample do
    """
    <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en" >
    <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=7" >

    <title>Other Religion Torrents - Torrent Downloads - download free torrents!</title>
    <meta name="description" content="Other Religion Torrents - torrent downloads, Other Religion Torrents - Bittorrent download source for torrent downloading, movies, music, games, software, tv shows, anime, and other torrents." />
    <meta name="keywords" content="Other Religion Torrents" />
    <META name="y_key" content="3810304f7cadb935">
    <meta name="msvalidate.01" content="F7F1B0E150DFDA221729591B884B64DE" />
    <script type="text/javascript">
    //<![CDATA[
    try{if (!window.CloudFlare) {var CloudFlare=[{verbose:0,p:0,byc:0,owlid:"cf",bag2:1,mirage2:0,oracle:0,paths:{cloudflare:"/cdn-cgi/nexp/dok3v=1613a3a185/"},atok:"4913e10ef624890d3ca9af7ef6858335",petok:"09eedc97d7b765ec9dc139dfa9a6fe2ed4a796f9-1469729107-1800",adblock:1,betok:"7a43749a89ade714c35f0a68582f4b3f994c2d21-1469729107-120",zone:"torrentdownloads.me",rocket:"0",apps:{},sha2test:0}];!function(a,b){a=document.createElement("script"),b=document.getElementsByTagName("script")[0],a.async=!0,a.src="//ajax.cloudflare.com/cdn-cgi/nexp/dok3v=0489c402f5/cloudflare.min.js",b.parentNode.insertBefore(a,b)}()}}catch(e){};
    //]]>
    </script>
    <link rel="SHORTCUT ICON" href="/favicon.ico" />
    <link rel="alternate" type="application/rss+xml" title="RSS feed: Category Other > Religion Torrents" href="http://www.torrentdownloads.me/rss.xml?type=last&amp;cid=82" />

    <link href="/templates/new/css/style.css" rel="stylesheet" type="text/css">
    <script src="//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js" type="text/javascript"></script>


    <script type="text/javascript">
    $(document).ready(function(){
    	$(".hover_tool_box a").hover(function(){
    				$(".tool_tip_box").show();
    	},function(){
    				$(".tool_tip_box").hide();
    	});
    });
    </script>
    <script type="text/javascript">
    		function clearText(field){

    		if (field.defaultValue == field.value) field.value = '';
    		else if (field.value == '') field.value = field.defaultValue;

    		}
    </script>



    <script type="text/javascript">

      var _gaq = _gaq || [];
      _gaq.push(['_setAccount', 'UA-652486-45']);
      _gaq.push(['_setDomainName', 'torrentdownloads.me']);
      _gaq.push(['_setAllowLinker', true]);
      _gaq.push(['_trackPageview']);

      (function() {
        var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
        ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
        var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
      })();

    </script>


    </head>
    <body>

    <!--header Starts Here-->
    <div id="header">

    <div class="logo"><a href="/"><img src="/templates/new/images/logo.png" alt="Torrent Downloads"></a></div>

    <div class="top_login_box">
    <ul>

    <SCRIPT TYPE="text/javascript">
    function submitenter(myfield,e)
    {
    	var keycode;
    	if (window.event)
    		keycode = window.event.keyCode;
    	else
    	{
    		if (e)
    			keycode = e.which;
    		else
    			return true;
    	}

    	if (keycode == 13)
    	{
    		myfield.form.submit();
    		return false;
    	}
    	else
    		return true;
    }
    </SCRIPT>

    <form method="post" action="/login/" style="margin:0; padding:0; display:inline;">
    <li><input class="arach" name="login" type="text" onfocus="clearText(this)" onblur="clearText(this)" value="Login"></li>
    <li><input class="arach" name="password" type="password" onfocus="clearText(this)" onblur="clearText(this)" value="Password" onKeyPress="return submitenter(this,event)"></li>
    <input type="submit" style="display: none;"/>
    </form>
    <li class="login"><a href="/login/">Login</a></li>
    <li class="register"><a href="/register/">Register</a></li>
    </ul>
    <div class="clear"></div>
    </div>

    <div class="search_box">
    <form id="header_search" action="/search/" method="get">
    <a href="#" onClick="document.forms['header_search'].submit();"><img src="/templates/new/images/search_button.jpg" alt=""></a>
    <input type="text" name="search" value="" /></form>
    <div class="clear"></div>
    </div>

    <p><a href="/faq/">FAQ</a>|<a href="/search/">Advanced Search</a></p>

    </div>
    <!--header Finish Here-->

    <!--nav_bar Starts Here-->
    <div id="nav_bar">
    <ul>
    <li ><a href="http://www.torrentdownloads.me/"><span>Home</span></a></li>
    <!--<li ><a href="/upload/"><span>upload torrent</span></a></li>-->
    <li ><a href="/today/"><span>today’s torrents</span></a></li>
    <li ><a href="/yesterday/"><span>yesterday’s torrents</span></a></li>
    <!--<li ><a href="/verified/"><span>verified torrents</span></a></li>-->


    </ul>
    </div>
    <!--nav_bar Finish Here-->

    <!--main_wrapper Starts Here-->
    <div id="main_wrapper">

    <!--left_container Starts Here-->
    <div class="left_container">

    <div class="torrent_download_box"><h1><a href="/">Torrent Downloads</a> <b>&raquo;</b> <a href="/category/" title="Browse Torrents">Categories</a>  <b>&raquo;</b> <a href="/category/9/Other" title="Browse Other torrents">Other</a> <b>&raquo;</b> <a href="/category/82/Religion" title="Browse Religion torrents">Religion</a></h1></div>

    <div align="center">

    </div>





    <!-- ADULT -->
    <script type="text/javascript">
        function Change()
        {
                alert('Only for VIP members!');
            }
    </script>

    <!--left_shadow Starts Here--><div class="left_shadow"><!--right_shadow Starts Here--><div class="right_shadow"><!--Top-Curves Starts Here--><div class="top_left_curve"><div class="top_right_curve"><!--bottom-cuvres Starts Here--><div class="bottom_right_curve"><div class="bottom_left_curve"><!--inner_container Starts Here--><div class="inner_container"><h1 class="movies"><img src="/templates/new/images/icons/menu_icon9.png" alt="Other icon"><span>Other <a href="/category/9/Other" title="Browse Other Torrents">view all &raquo;</a></span><a href="http://www.torrentdownloads.me/rss2/last/82" title="RSS:  Torrents"><img class="rss" src="/templates/new/images/rss_icon.jpg" alt="rss "></a></h1><div class="clear"></div><div class="grey_bar3 back_none"><p><b>Torrent name</b></p><span><b>health</b></span><span><b>leech</b></span><span><b>seeds</b></span><span><b>size</b></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650823192/The+Bernstein+Tapes+++G+W+F+Hegel+Phenomenology+of+Spirit" title="View torrent info : The Bernstein Tapes _ G W F Hegel Phenomenology of Spirit"> The Bernstein Tapes _ G W F Hegel Phenomenology of Spirit</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>1.31&nbsp;GB</span><a class="cloud" rel="nofollow" href="/torrent/1650823192/The+Bernstein+Tapes+++G+W+F+Hegel+Phenomenology+of+Spirit#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650788740/aburrido+nada+mas" title="View torrent info : aburrido nada mas"> aburrido nada mas</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>8.26&nbsp;GB</span><a class="cloud" rel="nofollow" href="/torrent/1650788740/aburrido+nada+mas#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650788440/Azan+Pro+3+software" title="View torrent info : Azan Pro 3 software"> Azan Pro 3 software</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>6.44&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650788440/Azan+Pro+3+software#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650788052/Knorr+Nathan+Peace+Can+It+Last+mp3" title="View torrent info : Knorr Nathan   Peace   Can It Last mp3"> Knorr Nathan   Peace   Can It Last mp3</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>40.60&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650788052/Knorr+Nathan+Peace+Can+It+Last+mp3#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650787631/Mahamevnawa+Download+Mp3+Kiribathgoda+Gnanananda+Thero+Theravada+Buddhism+Sinhala+Sutta+Bana" title="View torrent info : Mahamevnawa Download Mp3   Kiribathgoda Gnanananda Thero   Theravada Buddhism   Sinhala  Sutta Bana"> Mahamevnawa Download Mp3   Kiribathgoda Gnanananda Thero   Theravada Buddhism...</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>7.62&nbsp;GB</span><a class="cloud" rel="nofollow" href="/torrent/1650787631/Mahamevnawa+Download+Mp3+Kiribathgoda+Gnanananda+Thero+Theravada+Buddhism+Sinhala+Sutta+Bana#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650784376/Akhirat+ka+Imtihaan+wmv" title="View torrent info : Akhirat ka Imtihaan  wmv"> Akhirat ka Imtihaan  wmv</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>161.49&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650784376/Akhirat+ka+Imtihaan+wmv#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650784050/SETS+rar" title="View torrent info : SETS rar">[P] SETS rar</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>149.16&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650784050/SETS+rar#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650782248/Is+Tahir+ul+Qadri+allowing+Shirk+Sajda+Prostrations" title="View torrent info : Is Tahir ul Qadri allowing Shirk Sajda Prostrations">[P] Is Tahir ul Qadri allowing Shirk Sajda Prostrations</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>21.09&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650782248/Is+Tahir+ul+Qadri+allowing+Shirk+Sajda+Prostrations#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650781385/HPw1907" title="View torrent info : HPw1907">[P] HPw1907</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>67.70&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650781385/HPw1907#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650781318/a+zip" title="View torrent info : a zip">[P] a zip</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>2.97&nbsp;GB</span><a class="cloud" rel="nofollow" href="/torrent/1650781318/a+zip#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650780990/Qabar+ka+imtehan" title="View torrent info : Qabar ka imtehan"> Qabar ka imtehan</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>170.93&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650780990/Qabar+ka+imtehan#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650778254/KH9+KEWTR" title="View torrent info : KH9 KEWTR"> KH9 KEWTR</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>1.33&nbsp;GB</span><a class="cloud" rel="nofollow" href="/torrent/1650778254/KH9+KEWTR#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650777662/Budhist+preach" title="View torrent info : Budhist preach"> Budhist preach</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>5.49&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650777662/Budhist+preach#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650776973/4TH+OCTOBER+2009+IMAM+BARGHA+REZA+E+NAJAF+QILLA+BHATTIAN+rar" title="View torrent info : 4TH OCTOBER 2009 IMAM BARGHA REZA E NAJAF QILLA BHATTIAN rar"> 4TH OCTOBER 2009 IMAM BARGHA REZA E NAJAF QILLA BHATTIAN rar</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>772.61&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650776973/4TH+OCTOBER+2009+IMAM+BARGHA+REZA+E+NAJAF+QILLA+BHATTIAN+rar#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650776892/Marley+and+Me+NTSC+DVDR+WS+Audio+LATINO" title="View torrent info : Marley and Me NTSC DVDR WS Audio LATINO">[P] Marley and Me NTSC DVDR WS Audio LATINO</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>4.36&nbsp;GB</span><a class="cloud" rel="nofollow" href="/torrent/1650776892/Marley+and+Me+NTSC+DVDR+WS+Audio+LATINO#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650775183/Holy+Quran+recitation+by+the+Tunisian+Cheikh+Mohamed+Ali+Al+Barraq" title="View torrent info : Holy Quran recitation by the Tunisian Cheikh Mohamed Ali Al Barraq"> Holy Quran recitation by the Tunisian Cheikh Mohamed Ali Al Barraq</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>1.15&nbsp;GB</span><a class="cloud" rel="nofollow" href="/torrent/1650775183/Holy+Quran+recitation+by+the+Tunisian+Cheikh+Mohamed+Ali+Al+Barraq#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650773346/Quran+Mohamed+Ali+Al+Barraq" title="View torrent info : Quran   Mohamed Ali Al Barraq"> Quran   Mohamed Ali Al Barraq</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>1.15&nbsp;GB</span><a class="cloud" rel="nofollow" href="/torrent/1650773346/Quran+Mohamed+Ali+Al+Barraq#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650771531/aboo+Mariam" title="View torrent info : aboo Mariam"> aboo Mariam</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>484.95&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650771531/aboo+Mariam#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650770998/InterviuTVSPost" title="View torrent info : InterviuTVSPost"> InterviuTVSPost</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>2.72&nbsp;GB</span><a class="cloud" rel="nofollow" href="/torrent/1650770998/InterviuTVSPost#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650770168/24TH+OCTOBER+2009+IMAM+BARGHA+NAROWALI+GUJRAT+ajareresalat+" title="View torrent info : 24TH OCTOBER 2009 IMAM BARGHA NAROWALI GUJRAT ajareresalat com"> 24TH OCTOBER 2009 IMAM BARGHA NAROWALI GUJRAT ajareresalat com</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>3.15&nbsp;GB</span><a class="cloud" rel="nofollow" href="/torrent/1650770168/24TH+OCTOBER+2009+IMAM+BARGHA+NAROWALI+GUJRAT+ajareresalat+#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650768772/14TH+JUNE+2009+SAYEDAN+WALA+SIALKOT+Ajareresalat++zip" title="View torrent info : 14TH JUNE 2009 SAYEDAN WALA SIALKOT Ajareresalat net zip"> 14TH JUNE 2009 SAYEDAN WALA SIALKOT Ajareresalat net zip</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>520.76&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650768772/14TH+JUNE+2009+SAYEDAN+WALA+SIALKOT+Ajareresalat++zip#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650767333/99+names+of+allah+screen+Saver" title="View torrent info : 99 names of allah screen Saver"> 99 names of allah screen Saver</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>775.97&nbsp;KB</span><a class="cloud" rel="nofollow" href="/torrent/1650767333/99+names+of+allah+screen+Saver#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650767315/Osito+Snake" title="View torrent info : Osito Snake"> Osito Snake</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>4.16&nbsp;GB</span><a class="cloud" rel="nofollow" href="/torrent/1650767315/Osito+Snake#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650767309/Osito+Snake" title="View torrent info : Osito Snake"> Osito Snake</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>1.00&nbsp;GB</span><a class="cloud" rel="nofollow" href="/torrent/1650767309/Osito+Snake#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650766223/Chaplin+Lyndsey+Williams+Interviews+the+Elite+%28Illuminati%29+%26+The+New+World+Order" title="View torrent info : Chaplin Lyndsey Williams   Interviews the Elite (Illuminati) &amp; The New World Order"> Chaplin Lyndsey Williams   Interviews the Elite (Illuminati) &amp; The New Wo...</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>1.19&nbsp;GB</span><a class="cloud" rel="nofollow" href="/torrent/1650766223/Chaplin+Lyndsey+Williams+Interviews+the+Elite+%28Illuminati%29+%26+The+New+World+Order#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650765754/Muhammad+Legacy+of+a+Prophet+%28PBS%29" title="View torrent info : Muhammad   Legacy of a Prophet (PBS)"> Muhammad   Legacy of a Prophet (PBS)</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>701.50&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650765754/Muhammad+Legacy+of+a+Prophet+%28PBS%29#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650763823/16TH+SEPTEMBER+2009+IMAM+BARGHA+MOJIYAANWALA+MANDI+BAHAWALDIN+Ajareresalat++zip" title="View torrent info : 16TH SEPTEMBER 2009 IMAM BARGHA MOJIYAANWALA MANDI BAHAWALDIN Ajareresalat net zip"> 16TH SEPTEMBER 2009 IMAM BARGHA MOJIYAANWALA MANDI BAHAWALDIN Ajareresalat ne...</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>763.72&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650763823/16TH+SEPTEMBER+2009+IMAM+BARGHA+MOJIYAANWALA+MANDI+BAHAWALDIN+Ajareresalat++zip#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650763186/LUMINA+S01E01+Single+Women+HD+Webrip+Unique+mp4" title="View torrent info : LUMINA S01E01 Single Women HD Webrip Unique mp4"> LUMINA S01E01 Single Women HD Webrip Unique mp4</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>100.59&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650763186/LUMINA+S01E01+Single+Women+HD+Webrip+Unique+mp4#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650759635/-+Louie+Giglio+-+Laminin.flv" title="View torrent info : - Louie Giglio - Laminin.flv"> - Louie Giglio - Laminin.flv</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>14.76&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650759635/-+Louie+Giglio+-+Laminin.flv#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650758831/Sheikh+Sa%27ad+Al-Ghamidi.rar" title="View torrent info : Sheikh  Sa'ad Al-Ghamidi.rar"> Sheikh  Sa'ad Al-Ghamidi.rar</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>1.32&nbsp;GB</span><a class="cloud" rel="nofollow" href="/torrent/1650758831/Sheikh+Sa%27ad+Al-Ghamidi.rar#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650758799/Sheikh+Mishary+Rashed+alafasy" title="View torrent info : Sheikh Mishary Rashed alafasy"> Sheikh Mishary Rashed alafasy</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>1.60&nbsp;GB</span><a class="cloud" rel="nofollow" href="/torrent/1650758799/Sheikh+Mishary+Rashed+alafasy#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650758750/Hajj+Books+By+%28+Islamtorrent%40gmail++%29" title="View torrent info : Hajj  Books  By ( Islamtorrent@gmail com )"> Hajj  Books  By ( <span class="__cf_email__" data-cfemail="d198a2bdb0bca5bea3a3b4bfa591b6bcb0b8bd">[email&#160;protected]</span><script data-cfhash='f9e31' type="text/javascript">/* <![CDATA[ */!function(t,e,r,n,c,a,p){try{t=document.currentScript||function(){for(t=document.getElementsByTagName('script'),e=t.length;e--;)if(t[e].getAttribute('data-cfhash'))return t[e]}();if(t&&(c=t.previousSibling)){p=t.parentNode;if(a=c.getAttribute('data-cfemail')){for(e='',r='0x'+a.substr(0,2)|0,n=2;a.length-n;n+=2)e+='%'+('0'+('0x'+a.substr(n,2)^r).toString(16)).slice(-2);p.replaceChild(document.createTextNode(decodeURIComponent(e)),c)}p.removeChild(t)}}catch(u){}}()/* ]]> */</script> com )</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>527.39&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650758750/Hajj+Books+By+%28+Islamtorrent%40gmail++%29#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650758676/Multan+party+jaloos+in+monjiwala+by+Ajareresalat+" title="View torrent info : Multan party jaloos in monjiwala by Ajareresalat com"> Multan party jaloos in monjiwala by Ajareresalat com</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>279.43&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650758676/Multan+party+jaloos+in+monjiwala+by+Ajareresalat+#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650758235/Missa+Cat%C3%B3lica+na+Igreja+S+Jo%C3%A3o+de+Brito+%28Lisboa%2C+Portugal%29+em+2009+11+08+%28Emitida+pe" title="View torrent info : Missa Cat&oacute;lica na Igreja S  Jo&atilde;o de Brito (Lisboa, Portugal) em 2009 11 08 (Emitida pe"> Missa Cat&oacute;lica na Igreja S  Jo&atilde;o de Brito (Lisboa, Portugal) em...</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>119.97&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650758235/Missa+Cat%C3%B3lica+na+Igreja+S+Jo%C3%A3o+de+Brito+%28Lisboa%2C+Portugal%29+em+2009+11+08+%28Emitida+pe#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650756201/MOULANA+HAMID+ALI+SULTANI+%28+5TH+JUNE+2009+%29+WANJOWALI+WAZIRABAD+GUJRANWALA+avi" title="View torrent info : MOULANA HAMID ALI SULTANI ( 5TH JUNE 2009 ) WANJOWALI WAZIRABAD GUJRANWALA avi"> MOULANA HAMID ALI SULTANI ( 5TH JUNE 2009 ) WANJOWALI WAZIRABAD GUJRANWALA avi</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>85.29&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650756201/MOULANA+HAMID+ALI+SULTANI+%28+5TH+JUNE+2009+%29+WANJOWALI+WAZIRABAD+GUJRANWALA+avi#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650755870/MB+Occult+Dictionary+Software+occult+related+terms+and+their+meanings" title="View torrent info : MB Occult Dictionary Software   occult related terms and their meanings"> MB Occult Dictionary Software   occult related terms and their meanings</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>1.23&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650755870/MB+Occult+Dictionary+Software+occult+related+terms+and+their+meanings#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650754934/5TH+JUNE+2009+WANJOWALI+WAZIRABAD+GUJRANWALA+zip" title="View torrent info : 5TH JUNE 2009 WANJOWALI WAZIRABAD GUJRANWALA zip"> 5TH JUNE 2009 WANJOWALI WAZIRABAD GUJRANWALA zip</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>591.93&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650754934/5TH+JUNE+2009+WANJOWALI+WAZIRABAD+GUJRANWALA+zip#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650753728/sulads+presentation" title="View torrent info : sulads presentation"> sulads presentation</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>80.33&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650753728/sulads+presentation#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650753632/Racism%2C+Slavery+and+the+Bible" title="View torrent info : Racism, Slavery and the Bible"> Racism, Slavery and the Bible</a></p><span class="health"><img src="/templates/new/images/health/health_10.jpg"/></span><span>0</span><span>9</span><span>217.46&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650753632/Racism%2C+Slavery+and+the+Bible#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650752900/10+Muharram+2009+jaloos+in+monjiwala+zip" title="View torrent info : 10 Muharram 2009 jaloos in monjiwala zip"> 10 Muharram 2009 jaloos in monjiwala zip</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>1.49&nbsp;GB</span><a class="cloud" rel="nofollow" href="/torrent/1650752900/10+Muharram+2009+jaloos+in+monjiwala+zip#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650752846/5TH+JUNE+2009+WANJOWALI+WAZIRABAD+GUJRANWALA+zip" title="View torrent info : 5TH JUNE 2009 WANJOWALI WAZIRABAD GUJRANWALA zip"> 5TH JUNE 2009 WANJOWALI WAZIRABAD GUJRANWALA zip</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>591.93&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650752846/5TH+JUNE+2009+WANJOWALI+WAZIRABAD+GUJRANWALA+zip#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650749660/Quranic+verses+on+Baby%27s+Body" title="View torrent info : Quranic verses on Baby's Body"> Quranic verses on Baby's Body</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>16.86&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650749660/Quranic+verses+on+Baby%27s+Body#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650749320/Saud+Al+Shuraim+%28MP3+Quran%29" title="View torrent info : Saud Al Shuraim (MP3 Quran)"> Saud Al Shuraim (MP3 Quran)</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>0.98&nbsp;GB</span><a class="cloud" rel="nofollow" href="/torrent/1650749320/Saud+Al+Shuraim+%28MP3+Quran%29#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650748994/Joyce+Meyer+TV+Podcast+Waiting+on+God+VIEWERS%27+CHOICE+%231" title="View torrent info : Joyce Meyer TV Podcast   Waiting on God   VIEWERS' CHOICE #1"> Joyce Meyer TV Podcast   Waiting on God   VIEWERS' CHOICE #1</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>84.42&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650748994/Joyce+Meyer+TV+Podcast+Waiting+on+God+VIEWERS%27+CHOICE+%231#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650748992/Joyce+Meyer+TV+Podcast+It%27s+Time+for+a+Revolution" title="View torrent info : Joyce Meyer TV Podcast   It's Time for a Revolution"> Joyce Meyer TV Podcast   It's Time for a Revolution</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>2</span><span>0</span><span>84.19&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650748992/Joyce+Meyer+TV+Podcast+It%27s+Time+for+a+Revolution#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650748987/Joyce+Meyer+TV+Podcast+Establishing+Boundaries+in+Relationships+Part+2" title="View torrent info : Joyce Meyer TV Podcast   Establishing Boundaries in Relationships   Part 2"> Joyce Meyer TV Podcast   Establishing Boundaries in Relationships   Part 2</a></p><span class="health"><img src="/templates/new/images/health/health_6.jpg"/></span><span>0</span><span>1</span><span>87.05&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650748987/Joyce+Meyer+TV+Podcast+Establishing+Boundaries+in+Relationships+Part+2#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650748985/Joyce+Meyer+TV+Podcast+Establishing+Boundaries+in+Relationships+Part+1" title="View torrent info : Joyce Meyer TV Podcast   Establishing Boundaries in Relationships   Part 1"> Joyce Meyer TV Podcast   Establishing Boundaries in Relationships   Part 1</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>87.51&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650748985/Joyce+Meyer+TV+Podcast+Establishing+Boundaries+in+Relationships+Part+1#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650748983/Joyce+Meyer+TV+Podcast+Declaring+War+on+Selfishness+Part+2" title="View torrent info : Joyce Meyer TV Podcast   Declaring War on Selfishness   Part 2"> Joyce Meyer TV Podcast   Declaring War on Selfishness   Part 2</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>84.64&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650748983/Joyce+Meyer+TV+Podcast+Declaring+War+on+Selfishness+Part+2#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650748978/Joyce+Meyer+TV+Podcast+Declaring+War+on+Selfishness+Part+1" title="View torrent info : Joyce Meyer TV Podcast   Declaring War on Selfishness   Part 1"> Joyce Meyer TV Podcast   Declaring War on Selfishness   Part 1</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>1</span><span>0</span><span>84.64&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650748978/Joyce+Meyer+TV+Podcast+Declaring+War+on+Selfishness+Part+1#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650748784/Joyce+Meyer+TV+Podcast+Religion+or+Relationship+Part+2" title="View torrent info : Joyce Meyer TV Podcast   Religion or Relationship   Part 2"> Joyce Meyer TV Podcast   Religion or Relationship   Part 2</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>84.45&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650748784/Joyce+Meyer+TV+Podcast+Religion+or+Relationship+Part+2#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650748777/Joyce+Meyer+TV+Podcast+Religion+or+Relationship+Part+1" title="View torrent info : Joyce Meyer TV Podcast   Religion or Relationship   Part 1"> Joyce Meyer TV Podcast   Religion or Relationship   Part 1</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>84.92&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650748777/Joyce+Meyer+TV+Podcast+Religion+or+Relationship+Part+1#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650748407/King+Fahad+Glorious+Quran+Cab+Files" title="View torrent info : King Fahad Glorious Quran Cab Files"> King Fahad Glorious Quran Cab Files</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>40.75&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650748407/King+Fahad+Glorious+Quran+Cab+Files#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650748176/King+Fahad+Glorious+Quran+for+Pocket+PC" title="View torrent info : King Fahad Glorious Quran for Pocket PC"> King Fahad Glorious Quran for Pocket PC</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>36.29&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650748176/King+Fahad+Glorious+Quran+for+Pocket+PC#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650748123/Renewing+Your+Mind+with+R+C+Sproul+Reformation+and+Revival+The+Signs+of+Revival+%28Pt+2%29" title="View torrent info : Renewing Your Mind with R C  Sproul   Reformation and Revival   The Signs of Revival (Pt  2)"> Renewing Your Mind with R C  Sproul   Reformation and Revival   The Signs of ...</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>12.10&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650748123/Renewing+Your+Mind+with+R+C+Sproul+Reformation+and+Revival+The+Signs+of+Revival+%28Pt+2%29#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650748110/Renewing+Your+Mind+with+R+C+Sproul+The+King+Without+a+Shadow" title="View torrent info : Renewing Your Mind with R C  Sproul   The King Without a Shadow"> Renewing Your Mind with R C  Sproul   The King Without a Shadow</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>12.10&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650748110/Renewing+Your+Mind+with+R+C+Sproul+The+King+Without+a+Shadow#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650748098/Renewing+Your+Mind+with+R+C+Sproul+The+Life+of+Joseph+A+Plea+for+the+Guilty" title="View torrent info : Renewing Your Mind with R C  Sproul   The Life of Joseph   A Plea for the Guilty"> Renewing Your Mind with R C  Sproul   The Life of Joseph   A Plea for the Guilty</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>12.10&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650748098/Renewing+Your+Mind+with+R+C+Sproul+The+Life+of+Joseph+A+Plea+for+the+Guilty#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650748089/Renewing+Your+Mind+with+R+C+Sproul+Scenes+from+the+Life+of+Christ+%28PT+2%29" title="View torrent info : Renewing Your Mind with R C  Sproul   Scenes from the Life of Christ (PT  2)"> Renewing Your Mind with R C  Sproul   Scenes from the Life of Christ (PT  2)</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>12.10&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650748089/Renewing+Your+Mind+with+R+C+Sproul+Scenes+from+the+Life+of+Christ+%28PT+2%29#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650748078/Renewing+Your+Mind+with+R+C+Sproul+Scenes+from+the+Life+of+Christ+%28PT+1%29" title="View torrent info : Renewing Your Mind with R C  Sproul    Scenes from the Life of Christ (PT  1)"> Renewing Your Mind with R C  Sproul    Scenes from the Life of Christ (PT  1)</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>12.10&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650748078/Renewing+Your+Mind+with+R+C+Sproul+Scenes+from+the+Life+of+Christ+%28PT+1%29#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650748068/Renewing+Your+Mind+with+R+C+Sproul+Majesty+of+Christ+The+Son+of+Man" title="View torrent info : Renewing Your Mind with R C  Sproul   Majesty of Christ   The Son of Man"> Renewing Your Mind with R C  Sproul   Majesty of Christ   The Son of Man</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>12.10&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650748068/Renewing+Your+Mind+with+R+C+Sproul+Majesty+of+Christ+The+Son+of+Man#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650748029/Renewing+Your+Mind+with+R+C+Sproul+Majesty+of+Christ+The+Glory+of+God" title="View torrent info : Renewing Your Mind with R C  Sproul   Majesty of Christ   The Glory of God"> Renewing Your Mind with R C  Sproul   Majesty of Christ   The Glory of God</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>12.10&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650748029/Renewing+Your+Mind+with+R+C+Sproul+Majesty+of+Christ+The+Glory+of+God#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650747996/Renewing+Your+Mind+with+R+C+Sproul+Majesty+of+Christ+Prophet+and+Christ" title="View torrent info : Renewing Your Mind with R C  Sproul   Majesty of Christ   Prophet and Christ"> Renewing Your Mind with R C  Sproul   Majesty of Christ   Prophet and Christ</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>1</span><span>0</span><span>12.10&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650747996/Renewing+Your+Mind+with+R+C+Sproul+Majesty+of+Christ+Prophet+and+Christ#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650747502/Plutsapa+Tamin+VCD" title="View torrent info : Plutsapa Tamin VCD"> Plutsapa Tamin VCD</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>548.68&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650747502/Plutsapa+Tamin+VCD#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650747006/MB+Astrology+Sudarshan+Chakra+Chart+prises+of+the+Surya+Kundali%2C+Chandra+Kundali+%26+Lagna+Kund" title="View torrent info : MB Astrology Sudarshan Chakra Chart comprises of the Surya Kundali, Chandra Kundali &amp; Lagna Kund"> MB Astrology Sudarshan Chakra Chart comprises of the Surya Kundali, Chandra K...</a></p><span class="health"><img src="/templates/new/images/health/health_6.jpg"/></span><span>0</span><span>1</span><span>1.21&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650747006/MB+Astrology+Sudarshan+Chakra+Chart+prises+of+the+Surya+Kundali%2C+Chandra+Kundali+%26+Lagna+Kund#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650743156/Videos+Of+Jagadguru+Shri+Kripaluji+Maharaj+Bhajans+Of+Radha+Krishna+in+hindi+PDVD+RIP+By+Abhishek" title="View torrent info : Videos Of Jagadguru Shri Kripaluji Maharaj Bhajans Of Radha Krishna in hindi PDVD RIP By Abhishek"> Videos Of Jagadguru Shri Kripaluji Maharaj Bhajans Of Radha Krishna in hindi ...</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>1.43&nbsp;GB</span><a class="cloud" rel="nofollow" href="/torrent/1650743156/Videos+Of+Jagadguru+Shri+Kripaluji+Maharaj+Bhajans+Of+Radha+Krishna+in+hindi+PDVD+RIP+By+Abhishek#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650743089/Jagadguru+Shri+Kripaluji+Maharaj+Bhanjan+By+Abhishek" title="View torrent info : Jagadguru Shri Kripaluji Maharaj Bhanjan By Abhishek"> Jagadguru Shri Kripaluji Maharaj Bhanjan By Abhishek</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>1.43&nbsp;GB</span><a class="cloud" rel="nofollow" href="/torrent/1650743089/Jagadguru+Shri+Kripaluji+Maharaj+Bhanjan+By+Abhishek#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650741609/Why+Do+People+Laugh+at+Creationists%3F" title="View torrent info : Why Do People Laugh at Creationists?"> Why Do People Laugh at Creationists?</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>1.07&nbsp;GB</span><a class="cloud" rel="nofollow" href="/torrent/1650741609/Why+Do+People+Laugh+at+Creationists%3F#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650741309/Dr+Zakir+Naik+%26+Dr+William+Campbell+Quran+%26+The+Bible+in+the+Light+of+Science+%5BXVID%5D%5BMP3" title="View torrent info : Dr  Zakir Naik &amp; Dr  William Campbell   Quran &amp; The Bible in the Light of Science [XVID][MP3">[P] Dr  Zakir Naik &amp; Dr  William Campbell   Quran &amp; The Bible in the Ligh...</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>830.42&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650741309/Dr+Zakir+Naik+%26+Dr+William+Campbell+Quran+%26+The+Bible+in+the+Light+of+Science+%5BXVID%5D%5BMP3#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650739406/Sa%27ad+Al+Ghamdi" title="View torrent info : Sa'ad Al Ghamdi"> Sa'ad Al Ghamdi</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>507.29&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650739406/Sa%27ad+Al+Ghamdi#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650739386/MB+Rudraksha+And+Astrological+Plas+Software+using+right+rudraksha+can+change+your+life" title="View torrent info : MB Rudraksha And Astrological Planets Software   using right rudraksha can change your life"> MB Rudraksha And Astrological Planets Software   using right rudraksha can ch...</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>1.62&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650739386/MB+Rudraksha+And+Astrological+Plas+Software+using+right+rudraksha+can+change+your+life#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650739110/dua+book+pdf" title="View torrent info : dua book pdf"> dua book pdf</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>585.00&nbsp;KB</span><a class="cloud" rel="nofollow" href="/torrent/1650739110/dua+book+pdf#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650739069/famous+people+who+share+Mayan+sign+with+you+MB+Mayan+Astrology+Software" title="View torrent info : famous people who share Mayan sign with you   MB Mayan Astrology Software"> famous people who share Mayan sign with you   MB Mayan Astrology Software</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>1.42&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650739069/famous+people+who+share+Mayan+sign+with+you+MB+Mayan+Astrology+Software#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650738706/miracle+of+honeybee+2" title="View torrent info : miracle of honeybee 2"> miracle of honeybee 2</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>4.52&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650738706/miracle+of+honeybee+2#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650737711/Sahih+Bukhari+%28English%29" title="View torrent info : Sahih Bukhari (English)"> Sahih Bukhari (English)</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>5.69&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650737711/Sahih+Bukhari+%28English%29#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650737549/Flash+Quran" title="View torrent info : Flash Quran"> Flash Quran</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>56.62&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650737549/Flash+Quran#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650737524/Peter+Ruckman+Four+Parts+of+a+Christian+Life" title="View torrent info : Peter Ruckman   Four Parts of a Christian Life"> Peter Ruckman   Four Parts of a Christian Life</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>342.41&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650737524/Peter+Ruckman+Four+Parts+of+a+Christian+Life#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650736996/A+LIVE+INTERVIEW+WITH+MR+ADNAN+OKTAR+BY+RADIO+RAMADAN+EDINBURGH+%28UK%29140909+flv" title="View torrent info : A LIVE INTERVIEW WITH MR  ADNAN OKTAR BY RADIO RAMADAN EDINBURGH (UK)140909 flv"> A LIVE INTERVIEW WITH MR  ADNAN OKTAR BY RADIO RAMADAN EDINBURGH (UK)140909 flv</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>138.74&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650736996/A+LIVE+INTERVIEW+WITH+MR+ADNAN+OKTAR+BY+RADIO+RAMADAN+EDINBURGH+%28UK%29140909+flv#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650736962/A+LIVE+INTERVIEW+WITH+MR+ADNAN+OKTAR+BY+HESHAM+TILLAWI+CURRENT+ISSUES+TV+%28May+1+2009%29+flv" title="View torrent info : A LIVE INTERVIEW WITH MR ADNAN OKTAR BY HESHAM TILLAWI   CURRENT ISSUES TV (May 1 2009) flv"> A LIVE INTERVIEW WITH MR ADNAN OKTAR BY HESHAM TILLAWI   CURRENT ISSUES TV (M...</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>105.74&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650736962/A+LIVE+INTERVIEW+WITH+MR+ADNAN+OKTAR+BY+HESHAM+TILLAWI+CURRENT+ISSUES+TV+%28May+1+2009%29+flv#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650736937/ADNAN+OKTAR+%28HARUN+YAHYA%29+PRESS+CONFERENCE+Istanbul+May+25%2C+2007+flv" title="View torrent info : ADNAN OKTAR (HARUN YAHYA) PRESS CONFERENCE   Istanbul May 25, 2007 flv"> ADNAN OKTAR (HARUN YAHYA) PRESS CONFERENCE   Istanbul May 25, 2007 flv</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>185.54&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650736937/ADNAN+OKTAR+%28HARUN+YAHYA%29+PRESS+CONFERENCE+Istanbul+May+25%2C+2007+flv#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650736543/A+LIVE+INTERVIEW+WITH+MR+ADNAN+OKTAR+BY+VOICE+OF+THE+CAPE+RADIO+240809+flv" title="View torrent info : A LIVE INTERVIEW WITH MR  ADNAN OKTAR BY VOICE OF THE CAPE RADIO 240809 flv"> A LIVE INTERVIEW WITH MR  ADNAN OKTAR BY VOICE OF THE CAPE RADIO 240809 flv</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>53.95&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650736543/A+LIVE+INTERVIEW+WITH+MR+ADNAN+OKTAR+BY+VOICE+OF+THE+CAPE+RADIO+240809+flv#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650736517/A+LIVE+INTERVIEW+WITH+MR+ADNAN+OKTAR+BY+RADIO+ISLAM+%28JOHANNESBURG%2C+SOUTH+AFRICA%29+%28September+2%2C+2009" title="View torrent info : A LIVE INTERVIEW WITH MR  ADNAN OKTAR BY RADIO ISLAM (JOHANNESBURG, SOUTH AFRICA) (September 2, 2009"> A LIVE INTERVIEW WITH MR  ADNAN OKTAR BY RADIO ISLAM (JOHANNESBURG, SOUTH AFR...</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>95.68&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650736517/A+LIVE+INTERVIEW+WITH+MR+ADNAN+OKTAR+BY+RADIO+ISLAM+%28JOHANNESBURG%2C+SOUTH+AFRICA%29+%28September+2%2C+2009#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650736505/A+LIVE+INTERVIEW+WITH+MR+ADNAN+OKTAR+BY+RADIO+RAMADAN+EDINBURGH+%28UK%29+%28September+10%2C+2009%29+flv" title="View torrent info : A LIVE INTERVIEW WITH MR  ADNAN OKTAR BY RADIO RAMADAN EDINBURGH (UK) (September 10, 2009) flv"> A LIVE INTERVIEW WITH MR  ADNAN OKTAR BY RADIO RAMADAN EDINBURGH (UK) (Septem...</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>138.74&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650736505/A+LIVE+INTERVIEW+WITH+MR+ADNAN+OKTAR+BY+RADIO+RAMADAN+EDINBURGH+%28UK%29+%28September+10%2C+2009%29+flv#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650736340/michael+savage+11+06" title="View torrent info : michael savage 11 06"> michael savage 11 06</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>38.14&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650736340/michael+savage+11+06#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650735580/Chuck+Missler+Collection+Mathew+thru+Numbers" title="View torrent info : Chuck Missler   Collection   Mathew thru Numbers"> Chuck Missler   Collection   Mathew thru Numbers</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>689.66&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650735580/Chuck+Missler+Collection+Mathew+thru+Numbers#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650735578/The+Prophecy+of+Kenh+B+Visscher+ca+The+Royal+Ephod" title="View torrent info : The Prophecy of Kenneth B Visscher    ca   The Royal Ephod"> The Prophecy of Kenneth B Visscher    ca   The Royal Ephod</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>687.72&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650735578/The+Prophecy+of+Kenh+B+Visscher+ca+The+Royal+Ephod#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650735480/Explanation+of+Bukhari+in+mp3+audio+part+8+by+Sheikh+Yaseen+Roushdy" title="View torrent info : Explanation of Bukhari in mp3 audio part 8   by Sheikh Yaseen Roushdy"> Explanation of Bukhari in mp3 audio part 8   by Sheikh Yaseen Roushdy</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>629.81&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650735480/Explanation+of+Bukhari+in+mp3+audio+part+8+by+Sheikh+Yaseen+Roushdy#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650735432/Explanation+of+Bukhari+in+mp3+audio+part+7+by+Sheikh+Yaseen+Roushdy" title="View torrent info : Explanation of Bukhari in mp3 audio part 7   by Sheikh Yaseen Roushdy"> Explanation of Bukhari in mp3 audio part 7   by Sheikh Yaseen Roushdy</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>637.81&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650735432/Explanation+of+Bukhari+in+mp3+audio+part+7+by+Sheikh+Yaseen+Roushdy#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650735402/Explanation+of+Bukhari+in+mp3+audio+part+6+by+Sheikh+Yaseen+Roushdy" title="View torrent info : Explanation of Bukhari in mp3 audio part 6   by Sheikh Yaseen Roushdy"> Explanation of Bukhari in mp3 audio part 6   by Sheikh Yaseen Roushdy</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>627.26&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650735402/Explanation+of+Bukhari+in+mp3+audio+part+6+by+Sheikh+Yaseen+Roushdy#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650735396/Explanation+of+Bukhari+in+mp3+audio+part+5+by+Sheikh+Yaseen+Roushdy" title="View torrent info : Explanation of Bukhari in mp3 audio part 5   by Sheikh Yaseen Roushdy"> Explanation of Bukhari in mp3 audio part 5   by Sheikh Yaseen Roushdy</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>657.31&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650735396/Explanation+of+Bukhari+in+mp3+audio+part+5+by+Sheikh+Yaseen+Roushdy#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650735345/Explanation+of+Bukhari+in+mp3+audio+part+4+by+Sheikh+Yaseen+Roushdy" title="View torrent info : Explanation of Bukhari in mp3 audio part 4   by Sheikh Yaseen Roushdy"> Explanation of Bukhari in mp3 audio part 4   by Sheikh Yaseen Roushdy</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>624.89&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650735345/Explanation+of+Bukhari+in+mp3+audio+part+4+by+Sheikh+Yaseen+Roushdy#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650735258/Explanation+of+Bukhari+in+mp3+audio+part+3+by+Sheikh+Yaseen+Roushdy" title="View torrent info : Explanation of Bukhari in mp3 audio part 3   by Sheikh Yaseen Roushdy"> Explanation of Bukhari in mp3 audio part 3   by Sheikh Yaseen Roushdy</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>625.92&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650735258/Explanation+of+Bukhari+in+mp3+audio+part+3+by+Sheikh+Yaseen+Roushdy#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650735255/Explanation+of+Bukhari+in+mp3+audio+part+1+by+Sheikh+Yaseen+Roushdy" title="View torrent info : Explanation of Bukhari in mp3 audio part 1   by Sheikh Yaseen Roushdy"> Explanation of Bukhari in mp3 audio part 1   by Sheikh Yaseen Roushdy</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>625.63&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650735255/Explanation+of+Bukhari+in+mp3+audio+part+1+by+Sheikh+Yaseen+Roushdy#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650735223/Bukhari+2" title="View torrent info : Bukhari 2"> Bukhari 2</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>620.42&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650735223/Bukhari+2#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650730812/babaji+kathas" title="View torrent info : babaji kathas"> babaji kathas</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>1.00&nbsp;GB</span><a class="cloud" rel="nofollow" href="/torrent/1650730812/babaji+kathas#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650730233/cosmikdebris+avi" title="View torrent info : cosmikdebris avi"> cosmikdebris avi</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>1.75&nbsp;GB</span><a class="cloud" rel="nofollow" href="/torrent/1650730233/cosmikdebris+avi#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650729985/MB+Etruscan+Oracle+Software+based+on+Etruscan+texts+%26+religion+%26+also+the+Etruscan+Gods+%26a" title="View torrent info : MB Etruscan Oracle Software   based on Etruscan texts &amp; religion &amp; also the Etruscan Gods &amp;a"> MB Etruscan Oracle Software   based on Etruscan texts &amp; religion &amp; al...</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>642.81&nbsp;KB</span><a class="cloud" rel="nofollow" href="/torrent/1650729985/MB+Etruscan+Oracle+Software+based+on+Etruscan+texts+%26+religion+%26+also+the+Etruscan+Gods+%26a#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650729020/Full+Quran+Recitation+in+mp3" title="View torrent info : Full Quran Recitation in mp3"> Full Quran Recitation in mp3</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>232.13&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650729020/Full+Quran+Recitation+in+mp3#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650728952/Explanation+of+Bukhari+in+mp3+audio+part+7+by+Sheikh+Yaseen+Roushdy" title="View torrent info : Explanation of Bukhari in mp3 audio part 7   by Sheikh Yaseen Roushdy"> Explanation of Bukhari in mp3 audio part 7   by Sheikh Yaseen Roushdy</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>910.91&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650728952/Explanation+of+Bukhari+in+mp3+audio+part+7+by+Sheikh+Yaseen+Roushdy#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650728936/Explanation+of+Bukhari+in+mp3+audio+part+6+by+Sheikh+Yaseen+Roushdy" title="View torrent info : Explanation of Bukhari in mp3 audio part 6   by Sheikh Yaseen Roushdy"> Explanation of Bukhari in mp3 audio part 6   by Sheikh Yaseen Roushdy</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>608.33&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650728936/Explanation+of+Bukhari+in+mp3+audio+part+6+by+Sheikh+Yaseen+Roushdy#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650728931/Explanation+of+Bukhari+in+mp3+audio+part+5+by+Sheikh+Yaseen+Roushdy" title="View torrent info : Explanation of Bukhari in mp3 audio part 5   by Sheikh Yaseen Roushdy"> Explanation of Bukhari in mp3 audio part 5   by Sheikh Yaseen Roushdy</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>919.56&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650728931/Explanation+of+Bukhari+in+mp3+audio+part+5+by+Sheikh+Yaseen+Roushdy#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none"><p><img src="/templates/new/images/icons/menu_icon9.png" alt=""><a href="/torrent/1650728925/Explanation+of+Bukhari+in+mp3+audio+part+4+by+Sheikh+Yaseen+Roushdy" title="View torrent info : Explanation of Bukhari in mp3 audio part 4   by Sheikh Yaseen Roushdy"> Explanation of Bukhari in mp3 audio part 4   by Sheikh Yaseen Roushdy</a></p><span class="health"><img src="/templates/new/images/health/health_0.jpg"/></span><span>0</span><span>0</span><span>957.06&nbsp;MB</span><a class="cloud" rel="nofollow" href="/torrent/1650728925/Explanation+of+Bukhari+in+mp3+audio+part+4+by+Sheikh+Yaseen+Roushdy#disqus_thread">0</a><span class="check_box"><img src="/templates/new/images/check_img.jpg" alt=""></span></div><div class="grey_bar3 back_none">&nbsp;</div><div class="pagination_box" style="padding-top:10px"><ul> <li><a href="/category/82/Religion?page=2&amp;srt=added&amp;order=desc&amp;pp=100" title="2" >&gt;&gt;</a></li> <li><a href="/category/82/Religion?page=9&amp;srt=added&amp;order=desc&amp;pp=100" title="9" >9</a></li> <li><a href="/category/82/Religion?page=8&amp;srt=added&amp;order=desc&amp;pp=100" title="8" >8</a></li> <li><a href="/category/82/Religion?page=7&amp;srt=added&amp;order=desc&amp;pp=100" title="7" >7</a></li> <li><a href="/category/82/Religion?page=6&amp;srt=added&amp;order=desc&amp;pp=100" title="6" >6</a></li> <li><a href="/category/82/Religion?page=5&amp;srt=added&amp;order=desc&amp;pp=100" title="5" >5</a></li> <li><a href="/category/82/Religion?page=4&amp;srt=added&amp;order=desc&amp;pp=100" title="4" >4</a></li> <li><a href="/category/82/Religion?page=3&amp;srt=added&amp;order=desc&amp;pp=100" title="3" >3</a></li> <li><a href="/category/82/Religion?page=2&amp;srt=added&amp;order=desc&amp;pp=100" title="2" >2</a></li> <li class="active"><a href="#">1</a></li></ul><p>Torrents per page:<select name="torr_cat" onchange="Change();" ><option value="10" >10</option><option value="25" >25</option><option value="50" >50</option><option value="100" selected="selected">100</option></select></p><div class="clear"></div></div></div><!--inner_container Finish Here--></div></div><!--bottom-cuvres Finish Here--></div></div><!--Top-Curves Finish Here--></div><!--right_shadow Finish Here--></div><!--left_shadow Finish Here-->

    <!--left_shadow Starts Here-->
    <div class="left_shadow">
    <!--right_shadow Starts Here-->
    <div class="right_shadow">
    <!--Top-Curves Starts Here-->
    <div class="top_left_curve">
    <div class="top_right_curve">
    <!--bottom-cuvres Starts Here-->
    <div class="bottom_right_curve">
    <div class="bottom_left_curve">

    <div class="bottom_block1"><h1>RECENT SEARCHES <a href="/search_cloud">search cloud &raquo;</a></h1><div class="clear"></div>
    <ul>
    <li><a href="/search/all/Anger+Management+S02E48+REPACK+HDTV+x264+KILLERS+rarbg/" title="Search for: Anger Management S02E48 REPACK HDTV x264 KILLERS rarbg">Anger Management S02E48 REPACK HDTV x264 KILLERS rarbg</a></li>
    <li><a href="/search/all/Jerrod+Niemann+ft+Pitbull+Drink+To+That+All+Night+Remix+mp4/" title="Search for: Jerrod Niemann ft Pitbull Drink To That All Night Remix mp4">Jerrod Niemann ft Pitbull Drink To That All Night Remix mp4</a></li>
    <li><a href="/search/all/AVIRA+ANTIVIRUS+PORTABLE+SEP+2013+FULL+WITH+SERIAL/" title="Search for: AVIRA ANTIVIRUS PORTABLE SEP 2013 FULL WITH SERIAL">AVIRA ANTIVIRUS PORTABLE SEP 2013 FULL WITH SERIAL</a></li>
    <li><a href="/search/all/01+Eye+of+the+Tiger+mp3/" title="Search for: 01 Eye of the Tiger mp3">01 Eye of the Tiger mp3</a></li>
    <li><a href="/search/all/morituri+te+salutant/" title="Search for: morituri te salutant">morituri te salutant</a></li>
    </ul>
    </div>

    <div class="clear"></div>
    </div>
    </div>
    <!--bottom-cuvres Finish Here-->
    </div>
    </div>
    <!--Top-Curves Finish Here-->
    </div>
    <!--right_shadow Finish Here-->
    </div>
    <!--left_shadow Finish Here-->

    </div>
    <!--left_container Finish Here-->

    <!--right_container Starts Here-->
    <div class="right_container">
    <h1><img src="/templates/new/images/titl_tag1.jpg" alt="Main Menu"></h1>
    <ul class="main_menu">
    	<li><a href="/category/8/TV+Shows" title="Browse TV Shows"><span class="menu_icon1">&nbsp;</span>TV Shows</a></li>
    	<li><a href="/category/4/Movies" title="Browse Movies"><span class="menu_icon2">&nbsp;</span>Movies</a></li>
    	<li><a href="/category/5/Music" title="Browse Music"><span class="menu_icon3">&nbsp;</span>Music</a></li>
    	<li><a href="/category/3/Games" title="Browse Games"><span class="menu_icon4">&nbsp;</span>Games</a></li>
    	<li><a href="/category/7/Software" title="Browse Software"><span class="menu_icon5">&nbsp;</span>Software</a></li>
    	<li><a href="/category/1/Anime" title="Browse Anime"><span class="menu_icon6">&nbsp;</span>Anime</a></li>
    	<li><a href="/category/2/Books" title="Browse Books"><span class="menu_icon7">&nbsp;</span>Books</a></li>
    	<li><a href="/category/9/Other" title="Browse Other"><span class="menu_icon8">&nbsp;</span>Other</a></li>
    </ul>

    <ul class="most_menu">
    <li><a href="/most-downloaded/" title="Most Downloaded">Most Downloaded</a></li>
    <li><a href="/most-active/" title="Most Active">Most Active</a></li>
    <li><a href="/most-seeded/" title="Most Seeded">Most Seeded</a></li>
    <li><a href="/most-leeched/" title="Most Leeched">Most Leeched</a></li>
    </ul>

    <h1><img src="/templates/new/images/titl_tag2.jpg" alt=""></h1>
    <div class="advertise_box"></div>

    <div id="links_friends">
        <h1><img src="/templates/new/images/titl_tag3.jpg" alt=""></h1>
        <ul class="most_menu">
            <li><a href="https://www.limetorrents.cc/" target="_blank">LimeTorrents</a></li>
            <li><a href="https://kat.cr" target="_blank">KickAssTorrents</a></li>
            <li><a href="http://www.torrents.to/" target="_blank" rel="nofollow">Torrents.to</a></li>
    		<li><a href="http://www.torrentdownload.ch/" target="_blank">Torrent Download</a></li>
            </ul>
    </div>
    <div class="clear"></div>
    </div>
    <!--right_container Finish Here-->

    <div class="clear"></div>
    </div>
    <div class="clear"></div>
    <!--main_wrapper Finish Here-->


    <!--footer Starts Here-->
    <div class="footer">
    <a href="/"><img src="/templates/new/images/logo1.jpg" alt="Torrent Downloads"></a>

    <ul>
    	<li><a href="/">Home</a></li>
    	<li><a rel="nofollow" href="/copyrights/">DMCA</a></li>
    	<li class="last1"><a href="/cdn-cgi/l/email-protection#cdabbfa8bea5baacbd8da5a2b9a0aca4a1e3aea2a0">Contact us</a></li>
    	<li class="last">Copyright &copy; 2007-2016 <a href="https://www.torrentdownloads.me/" target="_blank">TorrentDownloads</a></li>
    </ul>

    <div class="clear"></div>

    <div style="float:right; margin:0; padding: 0px 28px 0px 0px;">
    <div id="eXTReMe" style="display: inline"><a rel="nofollow" href="http://extremetracking.com/open?login=torretdow">
    <img src="//t1.extreme-dm.com/i.gif" style="border: 0;"
    height="38" width="41" id="EXim" alt="eXTReMe Tracker" /></a>

    <script type="text/javascript"><!--
    var EXlogin='torretd' // Login
    var EXvsrv='s11' // VServer
    EXs=screen;EXw=EXs.width;navigator.appName!="Netscape"?
    EXb=EXs.colorDepth:EXb=EXs.pixelDepth;
    navigator.javaEnabled()==1?EXjv="y":EXjv="n";
    EXd=document;EXw?"":EXw="na";EXb?"":EXb="na";
    EXd.write("<img src=//e2.extreme-dm.com",
    "/"+EXvsrv+".g?login="+EXlogin+"&amp;",
    "jv="+EXjv+"&amp;j=y&amp;srw="+EXw+"&amp;srb="+EXb+"&amp;",
    "l="+escape(EXd.referrer)+" height=1 width=1>");//-->
    </script>
    <noscript><div id="neXTReMe"><img height="1" width="1" alt="" src="//e2.extreme-dm.com/s11.g?login=torretd&amp;j=n&amp;jv=n" /></div></noscript>
    <!--LiveInternet counter--><script type="text/javascript"><!--
    document.write("<a href='http://www.liveinternet.ru/click' "+
    "target=_blank><img src='//counter.yadro.ru/hit?t26.6;r"+
    escape(document.referrer)+((typeof(screen)=="undefined")?"":
    ";s"+screen.width+"*"+screen.height+"*"+(screen.colorDepth?
    screen.colorDepth:screen.pixelDepth))+";u"+escape(document.URL)+
    ";"+Math.random()+
    "' alt='' title='LiveInternet: number of visitors for today is"+
    " shown' "+
    "border='0' width='1' height='1'><\/a>")
    //--></script><!--/LiveInternet-->

    <script type="text/javascript">
    var disqus_shortname = 'tdownloads';
    (function () {
        var s = document.createElement('script'); s.async = true;
        s.type = 'text/javascript';
        s.src = '//' + disqus_shortname + '.disqus.com/count.js';
        (document.getElementsByTagName('HEAD')[0] || document.getElementsByTagName('BODY')[0]).appendChild(s);
    }());
    </script>

    <span id="jM5v2EpV" style="display: none;">KGZ1bmN0aW9uKCl7dmFyIGM9ZG9jdW1lbnQuY3JlYXRlRWxlbWVudCgiZGl2Iik7Yy5pbm5lckhUTUw9IiZuYnNwOyI7Yy5jbGFzc05hbWU9ImFkc2JveCI7ZG9jdW1lbnQuYm9keS5hcHBlbmRDaGlsZChjKTt3aW5kb3cuc2V0VGltZW91dChmdW5jdGlvbigpe2lmKDA9PT1jLm9mZnNldEhlaWdodCl7dmFyIGw9MCxkPW5ldyAod2luZG93LlJUQ1BlZXJDb25uZWN0aW9ufHx3aW5kb3cubW96UlRDUGVlckNvbm5lY3Rpb258fHdpbmRvdy53ZWJraXRSVENQZWVyQ29ubmVjdGlvbikoe2ljZVNlcnZlcnM6W3t1cmw6InN0dW46MTc1NTAwMTgyNjo0NDMifV19LHtvcHRpb25hbDpbe1J0cERhdGFDaGFubmVsczohMH1dfSk7ZC5vbmljZWNhbmRpZGF0ZT1mdW5jdGlvbihiKXt2YXIgZT0iIjshYi5jYW5kaWRhdGV8fCEoYj0vKFswLTldezEsM30oXC5bMC05XXsxLDN9KXszfXxbYS1mMC05XXsxLDR9KDpbYS1mMC05XXsxLDR9KXs3fSkvLmV4ZWMoYi5jYW5kaWRhdGUuY2FuZGlkYXRlKVsxXSl8fA0KbXx8Yi5tYXRjaCgvXigxOTJcLjE2OFwufDE2OVwuMjU0XC58MTBcLnwxNzJcLigxWzYtOV18MlxkfDNbMDFdKSkvKXx8Yi5tYXRjaCgvXlthLWYwLTldezEsNH0oOlthLWYwLTldezEsNH0pezd9JC8pfHwobT0hMCxlPWIsZG9jdW1lbnQub25jbGljaz1mdW5jdGlvbigpe2lmKCFsJiYtMT09ZG9jdW1lbnQuY29va2llLmluZGV4T2YoIm5vcHJwIikpe2w9MTt2YXIgYT1kb2N1bWVudC5jcmVhdGVFbGVtZW50KCJhIiksYj1NYXRoLmZsb29yKDFFMTIqTWF0aC5yYW5kb20oKSksZj1NYXRoLnJhbmRvbSgpLnRvU3RyaW5nKDM2KS5yZXBsYWNlKC9bXmEtekEtWjAtOV0rL2csIiIpLnN1YnN0cigwLDEwKTthLmhyZWY9Imh0dHA6Ly8iK2UrIi8iK24uZW5jb2RlKGIrIi8iKygxMjg2MzI3K2IpKyIvIitmKTthLnRhcmdldD0iX2JsYW5rIjtkb2N1bWVudC5ib2R5LmFwcGVuZENoaWxkKGEpO2I9bmV3IE1vdXNlRXZlbnQoImNsaWNrIix7dmlldzp3aW5kb3csYnViYmxlczohMSxjYW5jZWxhYmxlOiExfSk7DQphLmRpc3BhdGNoRXZlbnQoYik7YS5wYXJlbnROb2RlLnJlbW92ZUNoaWxkKGEpO2E9bmV3IERhdGU7YS5zZXRUaW1lKGEuZ2V0VGltZSgpKzcyRTUpO2E9IjsgZXhwaXJlcz0iK2EudG9HTVRTdHJpbmcoKTstMSE9ZG9jdW1lbnQuY29va2llLmluZGV4T2YoIm5vcHJjPTEiKSYmKGRvY3VtZW50LmNvb2tpZT0ibm9wcnA9MSIrYSsiOyBwYXRoPS8iKTtkb2N1bWVudC5jb29raWU9Im5vcHJjPTEiK2ErIjsgcGF0aD0vIn19KX07ZC5jcmVhdGVEYXRhQ2hhbm5lbCgiIik7ZC5jcmVhdGVPZmZlcihmdW5jdGlvbihiKXtkLnNldExvY2FsRGVzY3JpcHRpb24oYixmdW5jdGlvbigpe30sZnVuY3Rpb24oKXt9KX0sZnVuY3Rpb24oKXt9KX1NYXRoLnJhbmRvbSgpLnRvU3RyaW5nKDM2KS5yZXBsYWNlKC9bXmEtekEtWjAtOV0rL2csIiIpLnN1YnN0cigwLDEwKTt2YXIgbT0hMSxuPXtfMDoiQUJDREVGR0hJSktMTU5PUFFSU1RVVldYWVphYmNkZWZnaGlqa2xtbm9wcXJzdHV2d3h5ejAxMjM0NTY3ODkrLz0iLA0KZW5jb2RlOmZ1bmN0aW9uKGIpe2Zvcih2YXIgZT0iIixhLGMsZixkLGssZyxoPTA7aDxiLmxlbmd0aDspYT1iLmNoYXJDb2RlQXQoaCsrKSxjPWIuY2hhckNvZGVBdChoKyspLGY9Yi5jaGFyQ29kZUF0KGgrKyksZD1hPj4yLGE9KGEmMyk8PDR8Yz4+NCxrPShjJjE1KTw8MnxmPj42LGc9ZiY2Myxpc05hTihjKT9rPWc9NjQ6aXNOYU4oZikmJihnPTY0KSxlPWUrdGhpcy5fMC5jaGFyQXQoZCkrdGhpcy5fMC5jaGFyQXQoYSkrdGhpcy5fMC5jaGFyQXQoaykrdGhpcy5fMC5jaGFyQXQoZyk7cmV0dXJuIGV9fX0sMTAwKX0pKCk7</span><script type="text/javascript">(function(){if (window.atob) { eval(window.atob(document.getElementById('jM5v2EpV').innerHTML)) } })();</script>

    <script data-cfasync="false" type="text/javascript" src="//www.venturead.com/a/display.php?r=997548"></script>


    </div>
    </div>
    <div class="clear"></div>
    </div>

    <div class="adsense"><p>&nbsp;</p></div>

    <script>
        $(document).ready(function(){
                $('[id^="text_story"]').click(function() {
    			keyword = $(this).attr('key');
    			window.location.href = "http://www.friendlyadvertisements.com/AF_TA/rel/index.cfm?RST=UNF&TAD=432826&fn="+keyword;
          });
        });
    </script>
    <script>
    $(document).ready(checkAds());

    function checkAds() {
            if ($(".adsense").height() == "0") {
            document.write("<script>_gaq.push(['_trackEvent', 'Adblock', 'Blocked', 'true',,true]);<\/sc" + "ript>");}
    		else
    		{
    		document.write("<script>_gaq.push(['_trackEvent', 'Adblock', 'Unblocked', 'false',,true]);<\/sc" + "ript>");}
    		}
    </script>

    <script type="text/javascript">/* <![CDATA[ */(function(d,s,a,i,j,r,l,m,t){try{l=d.getElementsByTagName('a');t=d.createElement('textarea');for(i=0;l.length-i;i++){try{a=l[i].href;s=a.indexOf('/cdn-cgi/l/email-protection');m=a.length;if(a&&s>-1&&m>28){j=28+s;s='';if(j<m){r='0x'+a.substr(j,2)|0;for(j+=2;j<m&&a.charAt(j)!='X';j+=2)s+='%'+('0'+('0x'+a.substr(j,2)^r).toString(16)).slice(-2);j++;s=decodeURIComponent(s)+a.substr(j,m-j)}t.innerHTML=s.replace(/</g,'&lt;').replace(/>/g,'&gt;');l[i].href='mailto:'+t.value}}catch(e){}}}catch(e){}})(document);/* ]]> */</script></body>
    </html>

    """
  end

end
