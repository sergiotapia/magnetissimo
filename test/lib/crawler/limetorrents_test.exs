defmodule Magnetissimo.Crawler.LimeTorrentsTest do
  use ExUnit.Case, async: true

  test "scrapes torrent information from detail page" do
    torrent = Magnetissimo.Crawler.LimeTorrents.torrent_information(detail_sample)
    assert torrent != nil
  end

  def detail_sample do
    """
    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml">
    <head>
    <meta name="description" content="Download Hacksaw Ridge (2016) BRRip XviD AC3-EVO torrent for free." />
    <title>Hacksaw Ridge (2016) BRRip XviD AC3-EVO Torrent Download - LimeTorrents</title>
    <script type="text/javascript">
    //<![CDATA[
    try{if (!window.CloudFlare) {var CloudFlare=[{verbose:0,p:0,byc:0,owlid:"cf",bag2:1,mirage2:0,oracle:0,paths:{cloudflare:"/cdn-cgi/nexp/dok3v=1613a3a185/"},atok:"05b8e2bf13ea918af795d9ab6a87c619",petok:"65a75453266505ebb0e5317acf22c97c1b8568a7-1482804718-1800",adblock:1,betok:"7c285dc7e01cf6278ff3566b513e3eb98ddab35e-1482804718-120",zone:"limetorrents.cc",rocket:"0",apps:{}}];!function(a,b){a=document.createElement("script"),b=document.getElementsByTagName("script")[0],a.async=!0,a.src="//ajax.cloudflare.com/cdn-cgi/nexp/dok3v=f2befc48d1/cloudflare.min.js",b.parentNode.insertBefore(a,b)}()}}catch(e){};
    //]]>
    </script>
    <link rel="shortcut icon" type="image/x-icon" href="//www.limetorrents.cc/static/favicon.ico" />
    <link href="//www.limetorrents.cc/static/main-11.css" rel="stylesheet" type="text/css" />
    <link rel="search" type="application/opensearchdescription+xml" title="Limetorrents.cc Torrents Search" href="//www.limetorrents.cc/opensearch.xml" />
    <link rel="alternate" type="application/rss+xml" title="Limetorrents.cc RSS feed" href="//www.limetorrents.cc/rss/" />
    <meta name="google-site-verification" content="nCPdSbqbDmoaLUuJ5w57c28lMLABsikFW6RrEFVxslg" />
    <meta name="msvalidate.01" content="C5D3EE0B24D80CFC05FF8403D06A835E" />
    <meta name="yandex-verification" content="b2db008c395fdf77" />
    <meta name="author" content="Limetorrents.cc"/>
    <script src="//ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js" type="text/javascript"></script>
    </head>
    <body>
    <div id="fb-root"></div>
    <script>(function(d, s, id) {
      var js, fjs = d.getElementsByTagName(s)[0];
      if (d.getElementById(id)) return;
      js = d.createElement(s); js.id = id;
      js.src = "//connect.facebook.net/en_US/sdk.js#xfbml=1&version=v2.3";
      fjs.parentNode.insertBefore(js, fjs);
    }(document, 'script', 'facebook-jssdk'));</script>
    <div id="header">
    	<div id="headerleft">
        <form action="/post/search.php" id="searchform" name="searchform" method="post">
            <div id="logo"><a href="/" target="_top" class="csprite_logo" title="Verified Torrent Downloads - LimeTorrents.cc"></a><br />

    		<p>
            <label class="labelheader"><input type="radio" checked="checked" name="catname" value="all" />All torrents</label>
            <label class="labelheader"><input type="radio"  name="catname" value="anime" />Anime</label>
            <label class="labelheader"><input type="radio"  name="catname" value="applications" />Applications</label>
            <label class="labelheader"><input type="radio"  name="catname" value="games" />Games</label>
            <label class="labelheader"><input type="radio"  name="catname" value="movies" />Movies</label>
            <label class="labelheader"><input type="radio"  name="catname" value="music" />Music</label>
            <label class="labelheader"><input type="radio"  name="catname" value="tv" />TV shows</label>
            <label class="labelheader"><input type="radio"  name="catname" value="other" />Other</label>
            </p>
            </div>
            <div id="search">

                <div id="searchdiv">
                    <div id="searchfieldouter">
                        <input type="text" class="searchfield" name="q" value="" />
                    </div>
                </div>
                <div id="searchbutton"><button type="submit" class="searchbuttonimg"></button>
                </div>

            </div>
            </form>
    	</div>
        <div id="headerright">
            <div id="userlogin">
                        <form action="/process.php" method="post">
                Users Login<br />
                Email: <input type="text" name="email" value="" class="headerinput" /><br />
                Password: <input type="password" name="password" class="headerinput"/><br />
                <input type="hidden" name="sublogin" value="1" />
                <input type="hidden" name="remember" value="1" />
                <input type="submit" value="Login" class="userloginbutton"/></form>
                <a href="/register/">Create an account</a><br />
                <a href="/recover/">Forgot your password?</a>
                    </div>
    	</div>
    </div>
    <div class="clearboth"></div>
    <div id="navbar">

        <div style="float:left">
    	<div id="mainnav">
        	<a href="/">HOME</a> |
            <a href="/browse-torrents/">BROWSE</a> |
            <a href="/index.php?page=top100">TOP TORRENTS</a> |
    	    <a href="/index.php?page=latest100">LATEST TORRENTS</a> |
            <a href="/search-cloud/">SEARCH CLOUD</a> |
            <a href="/register/">REGISTER</a> |
            <a href="/faq/">FAQ</a> |
            <a href="/rss/">RSS</a> |
            <a href="/contact/">CONTACT</a> |
    	</div></div>
            <div class="clearboth"></div>
    </div>
    <div id="navbar2"><a href="/friends/">My Friends</a>&nbsp &nbsp;|&nbsp;&nbsp;
    <a href="/messages/">Messages</a> &nbsp;&nbsp;|&nbsp;&nbsp;
    <a href="/feedback/">Feedback</a> &nbsp;&nbsp;|&nbsp;&nbsp;
    <a href="/upload/">Upload a torrent</a>&nbsp;&nbsp;|&nbsp;&nbsp;
    <a href="/bookmarks/">Bookmarks</a>&nbsp;&nbsp;|&nbsp;&nbsp;
    <a href="/personal-rss/">Personal RSS Feed</a>&nbsp;&nbsp;|&nbsp;&nbsp;
    <a href="/profile/">My Profile</a></div>
    <div class="clearboth"></div>
    <div id="maincontentouter">
        <div id="rightbar">
                	<div>
            	<div class="head">
                	Quick Browse            </div>
                <div>
                	<span class="left"><a href="/browse-torrents/Movies/">Movies</a></span><span class="right"><a href="/rss/16/" class="csprite_rssfeed"></a></span><br />
                </div>
                <div>
                	<span class="left"><a href="/browse-torrents/TV-shows/">TV shows</a></span><span class="right"><a href="/rss/20/" class="csprite_rssfeed"></a></span><br />
                </div>
                <div>
                	<span class="left"><a href="/browse-torrents/Music/">Music</a></span><span class="right"><a href="/rss/17/" class="csprite_rssfeed"></a></span><br />
                </div>
                <div>
                	<span class="left"><a href="/browse-torrents/Games/">Games</a></span><span class="right"><a href="/rss/8/" class="csprite_rssfeed"></a></span><br />
                </div>
                <div>
                	<span class="left"><a href="/browse-torrents/Applications/">Applications</a></span><span class="right"><a href="/rss/2/" class="csprite_rssfeed"></a></span><br />
                </div>
                <div>
                	<span class="left"><a href="/browse-torrents/Anime/">Anime</a></span><span class="right"><a href="/rss/1/" class="csprite_rssfeed"></a></span><br />
                </div>
                <div>
                	<span class="left"><a href="/browse-torrents/Other/">Other</a></span><span class="right"><a href="/rss/21/" class="csprite_rssfeed"></a></span><br />
                </div>
            </div>
            <div>
             <div class="head">
                 Facebook
                </div>
    			<div class="fb-page" data-href="https://www.facebook.com/limetor" data-width="180" data-height="400" data-small-header="true" data-adapt-container-width="false" data-hide-cover="false" data-show-facepile="true" data-show-posts="false"><div class="fb-xfbml-parse-ignore"><blockquote cite="https://www.facebook.com/limetor"><a href="https://www.facebook.com/limetor">LimeTorrents</a></blockquote></div></div>
                <div>
                </div>
            </div>
        	<div>
        	<div class="head">
                 Advertising
                </div>
    <center><iframe height="602" width="160" frameborder="0" scrolling="no" src="/ad1.html"></iframe></center><br>

            </div>
        	<div>
            <div class="head">
                	Friends            </div>
    <div> <a href="http://www.torrentdownload.ch/" target="_blank">Torrent Download</a> </div>
    <div> <a href="http://movie4u.cc/" target="_blank">Movie4u</a> </div>
    <div> <a href="http://1337x.to/" target="_blank">1337x.to</a> </div>
    <div> <a href="https://www.torrentdownloads.me/" target="_blank">Torrent Downloads</a> </div>
    </div>
    <br>
    <center><br><script type="text/javascript"><!--
    document.write("<a href='http://www.liveinternet.ru/click' "+
    "target=_blank><img src='//counter.yadro.ru/hit?t26.6;r"+
    escape(document.referrer)+((typeof(screen)=="undefined")?"":
    ";s"+screen.width+"*"+screen.height+"*"+(screen.colorDepth?
    screen.colorDepth:screen.pixelDepth))+";u"+escape(document.URL)+
    ";"+Math.random()+
    "' alt='' title='LiveInternet: number of visitors for today is"+
    " shown' "+
    "border='0' width='88' height='15'><\/a>")
    //--></script><br>

    <br>
    </center>
            </div>
        </div>
    	<div id="content">
    <h1>
    Hacksaw Ridge (2016) BRRip XviD AC3-EVO</h1>
    <br />&nbsp;&nbsp;&nbsp;&nbsp;<span class="greenish">Seeders : 0</span>
    &nbsp;&nbsp;&nbsp;&nbsp;
    <span class="reddish">Leechers : 0</span>
    <br />
    <table width="100%"><tr><td style="vertical-align:top">
    <div class="torrentinfo">
    <table>
    <tr><td align="right"><b>Hash</b> :</td><td>28BA706E5115DFEADA85942676C82E8F2715CC61</td></tr>
    <tr><td align="right"><b>Added</b> :</td><td>3 minutes ago  in <a href="/browse-torrents/Movies">Movies</a></td></tr>
    <tr><td align="right"><b>Size</b> :</td><td>779.11 MB</td></tr>
    <tr><td align="right"><b>Stream</b> :</td><td>WATCH ONLINE @<a href="http://www.movie4u.club/" target="_blank"><u><b> Movie4u</u></b></a></td></tr>
    </table>

    <br />
    <br />

        <div>
            <div style="float:left; margin: 0px; padding: 5px">

    <a rel="nofollow" href="http://www.fducks.com/AF_TA/rel/index.cfm?RST=UNF&TAD=432823&fn=Hacksaw Ridge (2016) BRRip XviD AC3-EVO" style="display: block !important"><img src="/static/images/download2.png" style="display: block !important"></a>
            </div>
            <div style="float:left">
    <a rel="nofollow" href="http://www.fducks.com/AF_TA/rel/index.cfm?RST=UNF&TAD=432823&fn=Hacksaw Ridge (2016) BRRip XviD AC3-EVO" style="display: block !important; text-decoration: underline; color: green; font-size: 18px;">Hacksaw Ridge (2016) BRRip XviD AC3-EVO</a>
            <br /><font style="color: grey">Free and Direct Download 300GB+ free</font></div>
            <br style="clear:both" />
        </div>

    <br />
    <div class="downloadarea">
    <div class="dltorrent">
    <a href="http://itorrents.org/torrent/28BA706E5115DFEADA85942676C82E8F2715CC61.torrent?title=[limetorrents.cc]Hacksaw.Ridge..2016..BRRip.XviD.AC3-EVO" rel="nofollow" class="csprite_dltorrent" title="Download Hacksaw Ridge (2016) BRRip XviD AC3-EVO torrent"></a><p><a href="http://itorrents.org/torrent/28BA706E5115DFEADA85942676C82E8F2715CC61.torrent?title=[limetorrents.cc]Hacksaw.Ridge..2016..BRRip.XviD.AC3-EVO" rel="nofollow">Download torrent</a></p></div>
    </div>

    <div class="downloadareabig" style="width: 250px">
    <div class="dltorrent">
    <div>
    <a rel="nofollow" href="http://www.fducks.com/AF_TA/rel/index.cfm?RST=UNF&TAD=432823&fn=Hacksaw Ridge (2016) BRRip XviD AC3-EVO" style="display: block !important" class="csprite_dltorrent" title="FREE Download Hacksaw+Ridge+%282016%29+BRRip+XviD+AC3-EVO"></a>
    </div>
    <p>
    <a rel="nofollow" href="http://www.fducks.com/AF_TA/rel/index.cfm?RST=UNF&TAD=432823&fn=Hacksaw Ridge (2016) BRRip XviD AC3-EVO" style="display: block !important">FREE Download</a>
    </p>
    </div>
    </div>
    <br /><br /><br /><br />

    <div class="downloadarea">
    <div class="dltorrent">
    <a href="magnet:?xt=urn:btih:28BA706E5115DFEADA85942676C82E8F2715CC61&dn=Hacksaw+Ridge+%282016%29+BRRip+XviD+AC3-EVO&tr=udp%3A%2F%2Fp4p.arenabg.ch%3A1337%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2710%2Fannounce&tr=udp%3A%2F%2Ftracker.zer0day.to%3A1337%2Fannounce&tr=udp%3A%2F%2Fcoppersurfer.tk%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969%2Fannounce" rel="nofollow" class="csprite_dltorrent" title="Download Hacksaw Ridge (2016) BRRip XviD AC3-EVO magnet"></a>
    <p><a href="magnet:?xt=urn:btih:28BA706E5115DFEADA85942676C82E8F2715CC61&dn=Hacksaw+Ridge+%282016%29+BRRip+XviD+AC3-EVO&tr=udp%3A%2F%2Fp4p.arenabg.ch%3A1337%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2710%2Fannounce&tr=udp%3A%2F%2Ftracker.zer0day.to%3A1337%2Fannounce&tr=udp%3A%2F%2Fcoppersurfer.tk%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969%2Fannounce" rel="nofollow">Magnet Link</a></p></div>
    </div>

    <div class="downloadarea">
    <div class="dltorrent">
    <div><a href="#" class="csprite_addtobm" title="Add this torrent to your Limetorrents bookmarks"></a></div><p>
    <a href="/register/" class="tt">Add to bookmarks<span class="tooltip"><span class="top"></span><span class="middle">Login or create a FREE account to enable this!</span><span class="bottom"></span></span></a></p>
    </div>
    </div>

    <div class="downloadareabig">
    <div class="dltorrent">
    <div><a href="#" class="csprite_addtofeed" title="Add this torrent to your Limetorrents personal rss feed"></a></div><p>
    <a href="/register/" class="tt">Add to RSS<span class="tooltip"><span class="top"></span><span class="middle">Login or create a FREE account to enable this!</span><span class="bottom"></span></span></a></p>

    </div>
    </div>
    </div>
    </td><td style="vertical-align:top;" width="32%">
    	<div class="torrentvoting">
                <span class="greenish">0</span> <a href="/register/" class="csprite_vupbig tt"><span class="tooltipa"><span class="top"></span><span class="middle">Login or create a FREE account to vote for torrents!</span><span class="bottom"></span></span></a>&nbsp;&nbsp;&nbsp;
            <span class="reddish">0</span> <a href="/register/" class="csprite_vdownbig tt"><span class="tooltipa"><span class="top"></span><span class="middle">Login or create a FREE account to vote for torrents!</span><span class="bottom"></span></span></a>

        </div>

        </td></tr>
    </table>

    <br />

    <h2>Trackers List</h2>
    <div id="output">

    <table id="trackerstable">
    <table class="table3" cellpadding="6" cellspacing="0" id="trackerstable">
        <tr><th class="thleft">Tracker Name</th><th class="thnormal">Last&nbsp;Check</th><th class="thnormal">Status</th><th class="thnormal">Seeders</th><th class="thright">Leechers</th></tr></table></table>
    </div>


    <div id="updatestatslink" style="display:inline"><span class="csprite_upatestats"></span> <a href="javascript:toggle('updatestatslink');" onclick="sR('/post/updatestats.php','torrent_id=8524904&amp;infohash=28BA706E5115DFEADA85942676C82E8F2715CC61','POST','output'); return true">Update trackers info</a></div> <div id="loading_layer" style="display:none;"><span class="greenish">Updating <img src="//www.limetorrents.cc/static/images/loading.gif" alt="Loading..." width="16" height="5" title="Loading..." /></span></div><br /><br />
    <br />

    <br />
    <h2>Torrent File Content (2 files)</h2>
    <br />
    <div class="fileline"><span class="csprite_doc_dir"></span> Hacksaw Ridge (2016) BRRip.XviD.AC3-EVO<br />&nbsp;&nbsp;&nbsp;&nbsp;<span class="csprite_doc_video"></span> Hacksaw Ridge.avi -  <div class="filelinesize">779.11 MB</div><br /></div><div class="fileline">&nbsp;&nbsp;&nbsp;&nbsp;<span class="csprite_doc_doc"></span> ReadMe.txt -  <div class="filelinesize">215 bytes</div><br /></div><br style="clear:left"/><br />
    <h2>Related torrents</h2>
    <table class="table2" cellpadding="6" cellspacing="0">
    <tr><th class="thleft"><span style="float:left">Torrent Name</span></th><th class="thnormal">Added</th><th class="thnormal">Size</th><th class="thnormal">Seed</th><th class="thnormal">Leech</th><th class="thright">Health</th></tr><tr bgcolor="#F4F4F4"><td class="tdleft"><div class="tt-name"><a href="/Hacksaw-Ridge-2016-HDCAM-x264-AC3[PRiME]-torrent-8427084.html">Hacksaw Ridge 2016 HDCAM x264 AC3[PRiME]</a></div><div class="tt-options"><div class="tt-vdown"> <img src="/static/images/verified16.png" width="16" height="16" alt="Verified torrent" title="Verified torrent" /></div></div></td><td class="tdnormal">Last Month - in Movies</a></td><td class="tdnormal">1.93 GB</td><td class="tdseed">78</td><td class="tdleech">59</td><td class="tdright"><div class="hb5"></div></td></tr><tr bgcolor="#FFFFFF"><td class="tdleft"><div class="tt-name"><a href="/Hacksaw-Ridge-2016-HDCAM-x264-AC3-TuttyFruity-torrent-8426868.html">Hacksaw Ridge 2016 HDCAM x264 AC3-TuttyFruity</a></div><div class="tt-options"><div class="tt-vdown"> <img src="/static/images/verified16.png" width="16" height="16" alt="Verified torrent" title="Verified torrent" /></div></div></td><td class="tdnormal">Last Month - in Movies</a></td><td class="tdnormal">1.95 GB</td><td class="tdseed">158</td><td class="tdleech">128</td><td class="tdright"><div class="hb6"></div></td></tr><tr bgcolor="#F4F4F4"><td class="tdleft"><div class="tt-name"><a href="/Hacksaw-Ridge-2016-HDCAM-x264-AC3-TuttyFruity-torrent-8426748.html">Hacksaw Ridge 2016 HDCAM x264 AC3-TuttyFruity</a></div><div class="tt-options"><div class="tt-comment">1 <img src="/static/images/comment16.png" alt="Comments" title="Comments" /></div><div class="tt-vup">1 <img src="/static/images/vup16.png" alt="Good" title="Good" /></div><div class="tt-vdown"> <img src="/static/images/verified16.png" width="16" height="16" alt="Verified torrent" title="Verified torrent" /></div></div></td><td class="tdnormal">Last Month - in Movies</a></td><td class="tdnormal">1.95 GB</td><td class="tdseed">2,349</td><td class="tdleech">1,693</td><td class="tdright"><div class="hb10"></div></td></tr><tr bgcolor="#FFFFFF"><td class="tdleft"><div class="tt-name"><a href="/The-Accountant-2016-BRRip-XviD-AC3-EVO-torrent-8521965.html">The Accountant 2016 BRRip XviD AC3-EVO</a></div><div class="tt-options"><div class="tt-vdown"> <img src="/static/images/verified16.png" width="16" height="16" alt="Verified torrent" title="Verified torrent" /></div></div></td><td class="tdnormal">2 days ago - in Movies</a></td><td class="tdnormal">1.39 GB</td><td class="tdseed">276</td><td class="tdleech">281</td><td class="tdright"><div class="hb7"></div></td></tr><tr bgcolor="#F4F4F4"><td class="tdleft"><div class="tt-name"><a href="/The-Birth-of-a-Nation-2016-BRRip-XviD-AC3-EVO-torrent-8521335.html">The Birth of a Nation 2016 BRRip XviD AC3-EVO</a></div><div class="tt-options"></div></td><td class="tdnormal">3 days ago - in Movies</a></td><td class="tdnormal">1.36 GB</td><td class="tdseed">71</td><td class="tdleech">49</td><td class="tdright"><div class="hb5"></div></td></tr><tr bgcolor="#FFFFFF"><td class="tdleft"><div class="tt-name"><a href="/The-Accountant-2016-BRRip-XviD-AC3-EVO-torrent-8521297.html">The Accountant 2016 BRRip XviD AC3-EVO</a></div><div class="tt-options"><div class="tt-vdown"> <img src="/static/images/verified16.png" width="16" height="16" alt="Verified torrent" title="Verified torrent" /></div></div></td><td class="tdnormal">3 days ago - in Movies</a></td><td class="tdnormal">1.39 GB</td><td class="tdseed">248</td><td class="tdleech">327</td><td class="tdright"><div class="hb7"></div></td></tr></table>
    <br /><h2>Comments (0 Comments)</h2><br />
    <br /><br />
    Please login or <a href="/register/">create a <b>FREE account</b></a> to post comments	</div>
    </div>
    <div class="clearboth"></div>
    <div><h3>Latest Searches</h3>
    <div class="recentsearch"> | <a href="/search/all/bigtitsatwork-bridgette-b-titty-heist-ii-the-negotiator-480p-new-april-21-2015/" title="search bigtitsatwork bridgette b titty heist ii the negotiator 480p new april 21 2015 torrents">bigtitsatwork bridgette b titty heist ii the negotiator 480p new april 21 2015</a> | <a href="/search/all/code-s02e08/" title="search code s02e08 torrents">code s02e08</a> | <a href="/search/all/DaneJones -Cindy-Loarn-Teen-in-red-panties-and-high-heels-12-02-16-720p/" title="search DaneJones   Cindy Loarn Teen in red panties and high heels 12 02 16 720p torrents">DaneJones   Cindy Loarn Teen in red panties and high heels 12 02 16 720p</a> | <a href="/search/all/k-michelle-mothers-p/" title="search k michelle mothers p torrents">k michelle mothers p</a> | <a href="/search/all/Hot-MILF-Alena-Croft-Ariella-Ferrera/" title="search Hot MILF Alena Croft Ariella Ferrera torrents">Hot MILF Alena Croft Ariella Ferrera</a> | <a href="/search/all/RB-an-Hip-Hop-music/" title="search RB an Hip Hop music torrents">RB an Hip Hop music</a> | <a href="/search/all/once-upon-a-time-single/" title="search once upon a time single torrents">once upon a time single</a> | <a href="/search/all/so-thick-of/" title="search so thick of torrents">so thick of</a> | <a href="/search/all/tudo-nosso-nada-deles/" title="search tudo nosso nada deles torrents">tudo nosso nada deles</a> | <a href="/search/all/S-H-I-E-L-D-mp4-season-1/" title="search S H I E L D mp4 season 1 torrents">S H I E L D mp4 season 1</a> | </div></div>
    <div class="clearboth"></div>
    <div id="footer">2009-2016 LimeTorrents.cc | <a href="http://www.limetor.net/"> Limetorrents</a> | <a rel="nofollow" href="/privacy/">Privacy</a> | <a rel="nofollow" href="/dmca/">DMCA</a> | <a href="/rss/">RSS Feed</a>



    </div>

    <script type="text/javascript"> document.forms.searchform.q.focus(); </script>
    <script type="text/javascript" src="//www.limetorrents.cc/static/javascript.js"></script>
    <script type="text/javascript">

      var _gaq = _gaq || [];
      _gaq.push(['_setAccount', 'UA-652486-46']);
      _gaq.push(['_setDomainName', 'limetorrents.cc']);
      _gaq.push(['_setAllowLinker', true]);
      _gaq.push(['_trackPageview']);

      (function() {
        var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
        ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
        var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
      })();

    </script>

    <div class="adsense"><p>&nbsp;</p></div>
    <script>
        $(document).ready(function(){
                $('[id^="text_story"]').click(function() {
    			keyword = $(this).attr('key');
    			window.location.href = "http://www.friendlyadvertisements.com/AF_TA/rel/index.cfm?RST=UNF&TAD=432823&fn="+keyword;
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
    </body>
    </html>
    """
  end

end
