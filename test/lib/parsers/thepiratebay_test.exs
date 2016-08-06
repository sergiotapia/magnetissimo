defmodule Magnetissimo.Parsers.ThePirateBayTest do
  use ExUnit.Case, async: true

  test "has correct list of root urls" do
    assert Enum.count(Magnetissimo.Parsers.ThePirateBay.root_urls) == 1
  end

  test "finds links to torrent details page" do
    links = Magnetissimo.Parsers.ThePirateBay.torrent_links(list_sample)
    assert Enum.count(links) == 30
  end

  test "finds paginated links from list page" do
    page_links = Magnetissimo.Parsers.ThePirateBay.paginated_links(list_sample)
    assert Enum.count(page_links) == 300
  end

  test "scrapes torrent information from detail page" do
    torrent = Magnetissimo.Parsers.ThePirateBay.scrape_torrent_information(detail_sample)
    IO.inspect torrent
    assert torrent != nil
  end

  def list_sample do
    """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <title>Audio &gt; Audio - TPB</title>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
        <meta name="google-site-verification" content="bERYeomIC5eBWlPLupPPYPYGA9GvAUKzFHh3WIw24Xs" />
        <link rel="search" type="application/opensearchdescription+xml" href="/opensearch.xml" title="Search The Pirate Bay" />
        <link rel="stylesheet" type="text/css" href="//thepiratebay.org/static/css/pirate6.css"/>
        <link rel="dns-prefetch" href="//syndication.exoclick.com/">
        <link rel="dns-prefetch" href="//main.exoclick.com/">
        <link rel="dns-prefetch" href="//static-ssl.exoclick.com/">
        <link rel="dns-prefetch" href="//ads.exoclick.com/">
        <link rel="canonical" href="//thepiratebay.org/browse/100" />
        <style type="text/css">
            .searchBox{
                margin: 6px;
                width: 300px;
                vertical-align: middle;
                padding: 2px;
                background-image:url('//thepiratebay.org/static/img/icon-https.gif');
                background-repeat:no-repeat;
                background-position: right;
            }
            .detLink {
                font-size: 1.2em;
                font-weight: 400;
            }
            .detDesc {
                color: #4e5456;
            }
            .detDesc a:hover {
                color: #000099;
                text-decoration: underline;
            }
            .sortby {
                text-align: left;
                float: left;
            }
            .detName {
                padding-top: 3px;
                padding-bottom: 2px;
            }
            .viewswitch {
                font-style: normal;
                float: right;
                text-align: right;
                font-weight: normal;
            }
        </style>
        <script src="//thepiratebay.org/static/js/jquery.min.js" type="text/javascript"></script>
        <script src="//thepiratebay.org/static/js/tpb.js" type="text/javascript"></script>
        <meta name="description" content="Browse and Download any torrent from the category Audio. Direct download via magnet link."/>
        <meta name="keywords" content="Audio direct download torrent magnet tpb piratebay browse category audio"/>

        <script language="javascript" type="text/javascript">if (top.location != self.location) {top.location.replace(self.location);}</script>
    </head>

    <body>
        <div id="header">

            <form method="get" id="q" action="/s/">
                <a href="/" class="img"><img src="//thepiratebay.org/static/img/tpblogo_sm_ny.gif" id="TPBlogo" alt="The Pirate Bay" /></a>
                <b><a href="/" title="Search Torrents">Search Torrents</a></b>&nbsp;&nbsp;|&nbsp;
     <a href="/browse" title="Browse Torrents">Browse Torrents</a>&nbsp;&nbsp;|&nbsp;
     <a href="/recent" title="Recent Torrent">Recent Torrents</a>&nbsp;&nbsp;|&nbsp;
     <a href="/tv/" title="TV shows">TV shows</a>&nbsp;&nbsp;|&nbsp;
     <a href="/music" title="Music">Music</a>&nbsp;&nbsp;|&nbsp;
     <a href="/top" title="Top 100">Top 100</a>
                <br /><input type="search" class="inputbox" title="Pirate Search" name="q" placeholder="Search here..." value="" /><input value="Pirate Search" type="submit" class="submitbutton" $disabled /><br />            <label for="audio" title="Audio"><input id="audio" name="audio" onclick="javascript:rmAll();" type="checkbox"/>Audio</label>
                <label for="video" title="Video"><input id="video" name="video" onclick="javascript:rmAll();" type="checkbox"/>Video</label>
                <label for="apps" title="Applications"><input id="apps" name="apps" onclick="javascript:rmAll();" type="checkbox"/>Applications</label>
                <label for="games" title="Games"><input id="games" name="games" onclick="javascript:rmAll();" type="checkbox"/>Games</label>
                <label for="porn" title="Porn"><input id="porn" name="porn" onclick="javascript:rmAll();" type="checkbox"/>Porn</label>
                <label for="other" title="Other"><input id="other" name="other" onclick="javascript:rmAll();" type="checkbox"/>Other</label>

                <select id="category" name="category" onchange="javascript:setAll();">
                    <option value="0">All</option>
                    <optgroup label="Audio">
                        <option value="101">Music</option>
                        <option value="102">Audio books</option>
                        <option value="103">Sound clips</option>
                        <option value="104">FLAC</option>
                        <option value="199">Other</option>
                    </optgroup>
                    <optgroup label="Video">
                        <option value="201">Movies</option>
                        <option value="202">Movies DVDR</option>
                        <option value="203">Music videos</option>
                        <option value="204">Movie clips</option>
                        <option value="205">TV shows</option>
                        <option value="206">Handheld</option>
                        <option value="207">HD - Movies</option>
                        <option value="208">HD - TV shows</option>
                        <option value="209">3D</option>
                        <option value="299">Other</option>
                    </optgroup>
                    <optgroup label="Applications">
                        <option value="301">Windows</option>
                        <option value="302">Mac</option>
                        <option value="303">UNIX</option>
                        <option value="304">Handheld</option>
                        <option value="305">IOS (iPad/iPhone)</option>
                        <option value="306">Android</option>
                        <option value="399">Other OS</option>
                    </optgroup>
                    <optgroup label="Games">
                        <option value="401">PC</option>
                        <option value="402">Mac</option>
                        <option value="403">PSx</option>
                        <option value="404">XBOX360</option>
                        <option value="405">Wii</option>
                        <option value="406">Handheld</option>
                        <option value="407">IOS (iPad/iPhone)</option>
                        <option value="408">Android</option>
                        <option value="499">Other</option>
                    </optgroup>
                    <optgroup label="Porn">
                        <option value="501">Movies</option>
                        <option value="502">Movies DVDR</option>
                        <option value="503">Pictures</option>
                        <option value="504">Games</option>
                        <option value="505">HD - Movies</option>
                        <option value="506">Movie clips</option>
                        <option value="599">Other</option>
                    </optgroup>
                    <optgroup label="Other">
                        <option value="601">E-books</option>
                        <option value="602">Comics</option>
                        <option value="603">Pictures</option>
                        <option value="604">Covers</option>
                        <option value="605">Physibles</option>
                        <option value="699">Other</option>
                    </optgroup>
                </select>

                <input type="hidden" name="page" value="0" />
                <input type="hidden" name="orderby" value="99" />
            </form>
        </div><!-- // div:header -->

        <h2><span>Browse Audio &gt; Audio</span>&nbsp;</h2>

    <div id="content">
                <div id="sky-right">
                     <iframe src="//thepiratebay.org/static/ads/exo_na/sky2.html" width="160" height="600" frameborder="0" scrolling="no"></iframe>
                </div>
        
             <iframe src="//thepiratebay.org/static/ads/exo_na/center.html" id="sky-center" width="728" height="90" frameborder="0" scrolling="no"></iframe>
        <div id="main-content">
    <table id="searchResult">
        <thead id="tableHead">
            <tr class="header">
                <th><a href="/browse/100/0/13/0" title="Order by Type">Type</a></th>
                <th><div class="sortby"><a href="/browse/100/0/1/0" title="Order by Name">Name</a> (Order by: <a href="/browse/100/0/4/0" title="Order by Uploaded">Uploaded</a>, <a href="/browse/100/0/5/0" title="Order by Size">Size</a>, <span style="white-space: nowrap;"><a href="/browse/100/0/11/0" title="Order by ULed by">ULed by</a></span>, <a href="/browse/100/0/7/0" title="Order by Seeders">SE</a>, <a href="/browse/100/0/9/0" title="Order by Leechers">LE</a>)</div><div class="viewswitch"> View: <a href="/switchview.php?view=s">Single</a> / Double&nbsp;</div></th>
                <th><abbr title="Seeders"><a href="/browse/100/0/7/0" title="Order by Seeders">SE</a></abbr></th>
                <th><abbr title="Leechers"><a href="/browse/100/0/9/0" title="Order by Leechers">LE</a></abbr></th>
            </tr>
        </thead>
        <tr>
            <td class="vertTh">
                <center>
                    <a href="/browse/100" title="More from this category">Audio</a><br />
                    (<a href="/browse/104" title="More from this category">FLAC</a>)
                </center>
            </td>
            <td>
    <div class="detName">           <a href="/torrent/15497693/Enzo_Enzo_-_Oui_(1997)[FLAC]-ESCORT" class="detLink" title="Details for Enzo Enzo - Oui (1997)[FLAC]-ESCORT">Enzo Enzo - Oui (1997)[FLAC]-ESCORT</a>
    </div>
    <a href="magnet:?xt=urn:btih:fb67c5e7a45cf2e35654a4c19a07180120cbd17b&dn=Enzo+Enzo+-+Oui+%281997%29%5BFLAC%5D-ESCORT&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Fzer0day.ch%3A1337&tr=udp%3A%2F%2Fopen.demonii.com%3A1337&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Fexodus.desync.com%3A6969" title="Download this torrent using magnet"><img src="//thepiratebay.org/static/img/icon-magnet.gif" alt="Magnet link" /></a><img src="//thepiratebay.org/static/img/11x11p.png" /><img src="//thepiratebay.org/static/img/11x11p.png" />
                <font class="detDesc">Uploaded Today&nbsp;03:12, Size 284.17&nbsp;MiB, ULed by <a class="detDesc" href="/user/FordEscort0/" title="Browse FordEscort0">FordEscort0</a></font>
            </td>
            <td align="right">2</td>
            <td align="right">1</td>
        </tr>
        <tr class="alt">
            <td class="vertTh">
                <center>
                    <a href="/browse/100" title="More from this category">Audio</a><br />
                    (<a href="/browse/101" title="More from this category">Music</a>)
                </center>
            </td>
            <td>
    <div class="detName">           <a href="/torrent/15497471/No_Man_s_Sky__Music_for_an_Infinite_Universe_(WAV)" class="detLink" title="Details for No Man's Sky: Music for an Infinite Universe (WAV)">No Man's Sky: Music for an Infinite Universe (WAV)</a>
    </div>
    <a href="magnet:?xt=urn:btih:e3b1da1775b6a03df8716f1cea1749fe80d65058&dn=No+Man%27s+Sky%3A+Music+for+an+Infinite+Universe+%28WAV%29&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Fzer0day.ch%3A1337&tr=udp%3A%2F%2Fopen.demonii.com%3A1337&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Fexodus.desync.com%3A6969" title="Download this torrent using magnet"><img src="//thepiratebay.org/static/img/icon-magnet.gif" alt="Magnet link" /></a><img src="//thepiratebay.org/static/img/11x11p.png" /><img src="//thepiratebay.org/static/img/11x11p.png" />
                <font class="detDesc">Uploaded Today&nbsp;02:51, Size 1.1&nbsp;GiB, ULed by <a class="detDesc" href="/user/dlokk/" title="Browse dlokk">dlokk</a></font>
            </td>
            <td align="right">1</td>
            <td align="right">2</td>
        </tr>
        <tr>
            <td class="vertTh">
                <center>
                    <a href="/browse/100" title="More from this category">Audio</a><br />
                    (<a href="/browse/101" title="More from this category">Music</a>)
                </center>
            </td>
            <td>
    <div class="detName">           <a href="/torrent/15496936/MY_SELECTION_OF_MUSIC_FROM_ALL_TIMES_PART_247" class="detLink" title="Details for MY SELECTION OF MUSIC FROM ALL TIMES PART 247">MY SELECTION OF MUSIC FROM ALL TIMES PART 247</a>
    </div>
    <a href="magnet:?xt=urn:btih:3b9b607ad9339970d0f7932ab00b0a8db04646f3&dn=MY+SELECTION+OF+MUSIC+FROM+ALL+TIMES+PART+247&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Fzer0day.ch%3A1337&tr=udp%3A%2F%2Fopen.demonii.com%3A1337&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Fexodus.desync.com%3A6969" title="Download this torrent using magnet"><img src="//thepiratebay.org/static/img/icon-magnet.gif" alt="Magnet link" /></a><a href="/user/Lucpenta"><img src="//thepiratebay.org/static/img/trusted.png" alt="Trusted" title="Trusted" style="width:11px;" border='0' /></a><img src="//thepiratebay.org/static/img/11x11p.png" />
                <font class="detDesc">Uploaded Today&nbsp;01:47, Size 150.63&nbsp;MiB, ULed by <a class="detDesc" href="/user/Lucpenta/" title="Browse Lucpenta">Lucpenta</a></font>
            </td>
            <td align="right">4</td>
            <td align="right">3</td>
        </tr>
        <tr class="alt">
            <td class="vertTh">
                <center>
                    <a href="/browse/100" title="More from this category">Audio</a><br />
                    (<a href="/browse/199" title="More from this category">Other</a>)
                </center>
            </td>
            <td>
    <div class="detName">           <a href="/torrent/15496491/Opie__amp__Anthony__Jocktober_-_Complete_Collection" class="detLink" title="Details for Opie &amp; Anthony: Jocktober - Complete Collection">Opie &amp; Anthony: Jocktober - Complete Collection</a>
    </div>
    <a href="magnet:?xt=urn:btih:c4bf30536de75308bb34385e76d7af2b97521b78&dn=Opie+%26amp%3B+Anthony%3A+Jocktober+-+Complete+Collection&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Fzer0day.ch%3A1337&tr=udp%3A%2F%2Fopen.demonii.com%3A1337&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Fexodus.desync.com%3A6969" title="Download this torrent using magnet"><img src="//thepiratebay.org/static/img/icon-magnet.gif" alt="Magnet link" /></a><img src="//thepiratebay.org/static/img/11x11p.png" /><img src="//thepiratebay.org/static/img/11x11p.png" />
                <font class="detDesc">Uploaded Today&nbsp;00:32, Size 7.76&nbsp;GiB, ULed by <i>Anonymous</i></font>
            </td>
            <td align="right">4</td>
            <td align="right">8</td>
        </tr>
        <tr>
            <td class="vertTh">
                <center>
                    <a href="/browse/100" title="More from this category">Audio</a><br />
                    (<a href="/browse/104" title="More from this category">FLAC</a>)
                </center>
            </td>
            <td>
    <div class="detName">           <a href="/torrent/15496154/King_Crimson_2015-12-10_Tokyo_Japan_Orchard_Hall_16_44_FLAC8" class="detLink" title="Details for King Crimson 2015-12-10 Tokyo Japan Orchard Hall 16 44 FLAC8">King Crimson 2015-12-10 Tokyo Japan Orchard Hall 16 44 FLAC8</a>
    </div>
    <a href="magnet:?xt=urn:btih:d8853fa9dc34b039e8cb0520d82ee336916b4308&dn=King+Crimson+2015-12-10+Tokyo+Japan+Orchard+Hall+16+44+FLAC8&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Fzer0day.ch%3A1337&tr=udp%3A%2F%2Fopen.demonii.com%3A1337&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Fexodus.desync.com%3A6969" title="Download this torrent using magnet"><img src="//thepiratebay.org/static/img/icon-magnet.gif" alt="Magnet link" /></a><img src="//thepiratebay.org/static/img/11x11p.png" /><img src="//thepiratebay.org/static/img/11x11p.png" />
                <font class="detDesc">Uploaded Y-day&nbsp;23:22, Size 813.53&nbsp;MiB, ULed by <a class="detDesc" href="/user/Audioarchivist/" title="Browse Audioarchivist">Audioarchivist</a></font>
            </td>
            <td align="right">1</td>
            <td align="right">27</td>
        </tr>
        <tr class="alt">
            <td class="vertTh">
                <center>
                    <a href="/browse/100" title="More from this category">Audio</a><br />
                    (<a href="/browse/104" title="More from this category">FLAC</a>)
                </center>
            </td>
            <td>
    <div class="detName">           <a href="/torrent/15496129/King_Crimson_2015-12-10_Tokyo_Japan_Orchard_Hall_24_96_FLAC8" class="detLink" title="Details for King Crimson 2015-12-10 Tokyo Japan Orchard Hall 24 96 FLAC8">King Crimson 2015-12-10 Tokyo Japan Orchard Hall 24 96 FLAC8</a>
    </div>
    <a href="magnet:?xt=urn:btih:036175c48d2190de90f04667d42342275d50cccf&dn=King+Crimson+2015-12-10+Tokyo+Japan+Orchard+Hall+24+96+FLAC8&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Fzer0day.ch%3A1337&tr=udp%3A%2F%2Fopen.demonii.com%3A1337&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Fexodus.desync.com%3A6969" title="Download this torrent using magnet"><img src="//thepiratebay.org/static/img/icon-magnet.gif" alt="Magnet link" /></a><img src="//thepiratebay.org/static/img/11x11p.png" /><img src="//thepiratebay.org/static/img/11x11p.png" />
                <font class="detDesc">Uploaded Y-day&nbsp;23:19, Size 3.04&nbsp;GiB, ULed by <a class="detDesc" href="/user/Audioarchivist/" title="Browse Audioarchivist">Audioarchivist</a></font>
            </td>
            <td align="right">1</td>
            <td align="right">22</td>
        </tr>
        <tr>
            <td class="vertTh">
                <center>
                    <a href="/browse/100" title="More from this category">Audio</a><br />
                    (<a href="/browse/199" title="More from this category">Other</a>)
                </center>
            </td>
            <td>
    <div class="detName">           <a href="/torrent/15495672/Twiddle_-_2016-07-29_Waterfront_Park__Burlington__VT_[FLAC]" class="detLink" title="Details for Twiddle - 2016-07-29 Waterfront Park, Burlington, VT [FLAC]">Twiddle - 2016-07-29 Waterfront Park, Burlington, VT [FLAC]</a>
    </div>
    <a href="magnet:?xt=urn:btih:dfd82d40483673af29cb0c898dcfb42e0d9992f6&dn=Twiddle+-+2016-07-29+Waterfront+Park%2C+Burlington%2C+VT+%5BFLAC%5D&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Fzer0day.ch%3A1337&tr=udp%3A%2F%2Fopen.demonii.com%3A1337&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Fexodus.desync.com%3A6969" title="Download this torrent using magnet"><img src="//thepiratebay.org/static/img/icon-magnet.gif" alt="Magnet link" /></a><img src="//thepiratebay.org/static/img/icon_comment.gif" alt="This torrent has 1 comments." title="This torrent has 1 comments." /><a href="/user/Jooge"><img src="//thepiratebay.org/static/img/trusted.png" alt="Trusted" title="Trusted" style="width:11px;" border='0' /></a>
                <font class="detDesc">Uploaded Y-day&nbsp;22:22, Size 724.57&nbsp;MiB, ULed by <a class="detDesc" href="/user/Jooge/" title="Browse Jooge">Jooge</a></font>
            </td>
            <td align="right">5</td>
            <td align="right">1</td>
        </tr>
        <tr class="alt">
            <td class="vertTh">
                <center>
                    <a href="/browse/100" title="More from this category">Audio</a><br />
                    (<a href="/browse/104" title="More from this category">FLAC</a>)
                </center>
            </td>
            <td>
    <div class="detName">           <a href="/torrent/15495550/Ziggy_Marley_-_Live_at_The_Palladium_[Flac][TntVillage]" class="detLink" title="Details for Ziggy Marley - Live at The Palladium [Flac][TntVillage]">Ziggy Marley - Live at The Palladium [Flac][TntVillage]</a>
    </div>
    <a href="magnet:?xt=urn:btih:d85351290e4398cba533ae2476df429cc0e9cd73&dn=Ziggy+Marley+-+Live+at+The+Palladium+%5BFlac%5D%5BTntVillage%5D&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Fzer0day.ch%3A1337&tr=udp%3A%2F%2Fopen.demonii.com%3A1337&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Fexodus.desync.com%3A6969" title="Download this torrent using magnet"><img src="//thepiratebay.org/static/img/icon-magnet.gif" alt="Magnet link" /></a><img src="//thepiratebay.org/static/img/11x11p.png" /><img src="//thepiratebay.org/static/img/11x11p.png" />
                <font class="detDesc">Uploaded Y-day&nbsp;22:16, Size 348.83&nbsp;MiB, ULed by <a class="detDesc" href="/user/funk1971/" title="Browse funk1971">funk1971</a></font>
            </td>
            <td align="right">14</td>
            <td align="right">3</td>
        </tr>
        <tr>
            <td class="vertTh">
                <center>
                    <a href="/browse/100" title="More from this category">Audio</a><br />
                    (<a href="/browse/104" title="More from this category">FLAC</a>)
                </center>
            </td>
            <td>
    <div class="detName">           <a href="/torrent/15495287/Downchild_Blues_Band_-_Blood_Run_Hot_(1981)_[FLAC]" class="detLink" title="Details for Downchild Blues Band - Blood Run Hot (1981) [FLAC]">Downchild Blues Band - Blood Run Hot (1981) [FLAC]</a>
    </div>
    <a href="magnet:?xt=urn:btih:f12d31dbc615d1115ed681741844feda4045fc50&dn=Downchild+Blues+Band+-+Blood+Run+Hot+%281981%29+%5BFLAC%5D&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Fzer0day.ch%3A1337&tr=udp%3A%2F%2Fopen.demonii.com%3A1337&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Fexodus.desync.com%3A6969" title="Download this torrent using magnet"><img src="//thepiratebay.org/static/img/icon-magnet.gif" alt="Magnet link" /></a><img src="//thepiratebay.org/static/img/icon_comment.gif" alt="This torrent has 1 comments." title="This torrent has 1 comments." /><img src="//thepiratebay.org/static/img/vip.gif" alt="VIP" title="VIP" style="width:11px;" border='0' />
                <font class="detDesc">Uploaded Y-day&nbsp;20:54, Size 225.05&nbsp;MiB, ULed by <i>Anonymous</i></font>
            </td>
            <td align="right">9</td>
            <td align="right">5</td>
        </tr>
        <tr class="alt">
            <td class="vertTh">
                <center>
                    <a href="/browse/100" title="More from this category">Audio</a><br />
                    (<a href="/browse/104" title="More from this category">FLAC</a>)
                </center>
            </td>
            <td>
    <div class="detName">           <a href="/torrent/15495282/Downchild_Blues_Band_-_A_Case_Of_The_Blues_(1998)_[FLAC]" class="detLink" title="Details for Downchild Blues Band - A Case Of The Blues (1998) [FLAC]">Downchild Blues Band - A Case Of The Blues (1998) [FLAC]</a>
    </div>
    <a href="magnet:?xt=urn:btih:b27a3c8b601b1fd0432a00dd8127656c8b844e18&dn=Downchild+Blues+Band+-+A+Case+Of+The+Blues+%281998%29+%5BFLAC%5D&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Fzer0day.ch%3A1337&tr=udp%3A%2F%2Fopen.demonii.com%3A1337&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Fexodus.desync.com%3A6969" title="Download this torrent using magnet"><img src="//thepiratebay.org/static/img/icon-magnet.gif" alt="Magnet link" /></a><img src="//thepiratebay.org/static/img/icon_comment.gif" alt="This torrent has 1 comments." title="This torrent has 1 comments." /><img src="//thepiratebay.org/static/img/vip.gif" alt="VIP" title="VIP" style="width:11px;" border='0' />
                <font class="detDesc">Uploaded Y-day&nbsp;20:51, Size 340.34&nbsp;MiB, ULed by <i>Anonymous</i></font>
            </td>
            <td align="right">11</td>
            <td align="right">4</td>
        </tr>
        <tr>
            <td class="vertTh">
                <center>
                    <a href="/browse/100" title="More from this category">Audio</a><br />
                    (<a href="/browse/101" title="More from this category">Music</a>)
                </center>
            </td>
            <td>
    <div class="detName">           <a href="/torrent/15495265/Touhou_Soundtracks_6-15_(OPUS)" class="detLink" title="Details for Touhou Soundtracks 6-15 (OPUS)">Touhou Soundtracks 6-15 (OPUS)</a>
    </div>
    <a href="magnet:?xt=urn:btih:8d20ccdadb4519eee2749c03a0ffcfd4ebabb453&dn=Touhou+Soundtracks+6-15+%28OPUS%29&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Fzer0day.ch%3A1337&tr=udp%3A%2F%2Fopen.demonii.com%3A1337&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Fexodus.desync.com%3A6969" title="Download this torrent using magnet"><img src="//thepiratebay.org/static/img/icon-magnet.gif" alt="Magnet link" /></a><img src="//thepiratebay.org/static/img/11x11p.png" /><img src="//thepiratebay.org/static/img/11x11p.png" />
                <font class="detDesc">Uploaded Y-day&nbsp;20:40, Size 1.19&nbsp;GiB, ULed by <i>Anonymous</i></font>
            </td>
            <td align="right">1</td>
            <td align="right">0</td>
        </tr>
        <tr class="alt">
            <td class="vertTh">
                <center>
                    <a href="/browse/100" title="More from this category">Audio</a><br />
                    (<a href="/browse/199" title="More from this category">Other</a>)
                </center>
            </td>
            <td>
    <div class="detName">           <a href="/torrent/15495119/Laura_Ingraham_Aug_5_Dr_Sebestian_Gorka.mp3" class="detLink" title="Details for Laura Ingraham Aug 5 Dr Sebestian Gorka.mp3">Laura Ingraham Aug 5 Dr Sebestian Gorka.mp3</a>
    </div>
    <a href="magnet:?xt=urn:btih:00176f91ce3329f700057f939eaa7e4cf57fba8d&dn=Laura+Ingraham+Aug+5+Dr+Sebestian+Gorka.mp3&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Fzer0day.ch%3A1337&tr=udp%3A%2F%2Fopen.demonii.com%3A1337&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Fexodus.desync.com%3A6969" title="Download this torrent using magnet"><img src="//thepiratebay.org/static/img/icon-magnet.gif" alt="Magnet link" /></a><img src="//thepiratebay.org/static/img/11x11p.png" /><img src="//thepiratebay.org/static/img/11x11p.png" />
                <font class="detDesc">Uploaded Y-day&nbsp;20:08, Size 32.91&nbsp;MiB, ULed by <i>Anonymous</i></font>
            </td>
            <td align="right">1</td>
            <td align="right">0</td>
        </tr>
        <tr>
            <td class="vertTh">
                <center>
                    <a href="/browse/100" title="More from this category">Audio</a><br />
                    (<a href="/browse/102" title="More from this category">Audio books</a>)
                </center>
            </td>
            <td>
    <div class="detName">           <a href="/torrent/15495115/Paolo_Bacigalupi_-_Audiobook_Collection" class="detLink" title="Details for Paolo Bacigalupi - Audiobook Collection">Paolo Bacigalupi - Audiobook Collection</a>
    </div>
    <a href="magnet:?xt=urn:btih:212a69069789feb25f62b8d56f18c07c7b7a1d58&dn=Paolo+Bacigalupi+-+Audiobook+Collection&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Fzer0day.ch%3A1337&tr=udp%3A%2F%2Fopen.demonii.com%3A1337&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Fexodus.desync.com%3A6969" title="Download this torrent using magnet"><img src="//thepiratebay.org/static/img/icon-magnet.gif" alt="Magnet link" /></a><img src="//thepiratebay.org/static/img/11x11p.png" /><img src="//thepiratebay.org/static/img/11x11p.png" />
                <font class="detDesc">Uploaded Y-day&nbsp;20:05, Size 2.42&nbsp;GiB, ULed by <a class="detDesc" href="/user/Laverna/" title="Browse Laverna">Laverna</a></font>
            </td>
            <td align="right">7</td>
            <td align="right">6</td>
        </tr>
        <tr class="alt">
            <td class="vertTh">
                <center>
                    <a href="/browse/100" title="More from this category">Audio</a><br />
                    (<a href="/browse/102" title="More from this category">Audio books</a>)
                </center>
            </td>
            <td>
    <div class="detName">           <a href="/torrent/15495112/Michael_Swanwick_-_The_Iron_Dragon_s_Daughter" class="detLink" title="Details for Michael Swanwick - The Iron Dragon's Daughter">Michael Swanwick - The Iron Dragon's Daughter</a>
    </div>
    <a href="magnet:?xt=urn:btih:5f9869d88b9e69d3a2fa31fd3ab9ce3359bc3a51&dn=Michael+Swanwick+-+The+Iron+Dragon%27s+Daughter&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Fzer0day.ch%3A1337&tr=udp%3A%2F%2Fopen.demonii.com%3A1337&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Fexodus.desync.com%3A6969" title="Download this torrent using magnet"><img src="//thepiratebay.org/static/img/icon-magnet.gif" alt="Magnet link" /></a><img src="//thepiratebay.org/static/img/11x11p.png" /><img src="//thepiratebay.org/static/img/11x11p.png" />
                <font class="detDesc">Uploaded Y-day&nbsp;20:00, Size 408.54&nbsp;MiB, ULed by <a class="detDesc" href="/user/Laverna/" title="Browse Laverna">Laverna</a></font>
            </td>
            <td align="right">9</td>
            <td align="right">12</td>
        </tr>
        <tr>
            <td class="vertTh">
                <center>
                    <a href="/browse/100" title="More from this category">Audio</a><br />
                    (<a href="/browse/102" title="More from this category">Audio books</a>)
                </center>
            </td>
            <td>
    <div class="detName">           <a href="/torrent/15495108/Michael_Swanwick_-_Bones_of_the_Earth" class="detLink" title="Details for Michael Swanwick - Bones of the Earth">Michael Swanwick - Bones of the Earth</a>
    </div>
    <a href="magnet:?xt=urn:btih:1426fffdf9e4665d107327f01f795e24f5af45c1&dn=Michael+Swanwick+-+Bones+of+the+Earth&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Fzer0day.ch%3A1337&tr=udp%3A%2F%2Fopen.demonii.com%3A1337&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Fexodus.desync.com%3A6969" title="Download this torrent using magnet"><img src="//thepiratebay.org/static/img/icon-magnet.gif" alt="Magnet link" /></a><img src="//thepiratebay.org/static/img/11x11p.png" /><img src="//thepiratebay.org/static/img/11x11p.png" />
                <font class="detDesc">Uploaded Y-day&nbsp;19:57, Size 309.09&nbsp;MiB, ULed by <a class="detDesc" href="/user/Laverna/" title="Browse Laverna">Laverna</a></font>
            </td>
            <td align="right">6</td>
            <td align="right">7</td>
        </tr>
        <tr class="alt">
            <td class="vertTh">
                <center>
                    <a href="/browse/100" title="More from this category">Audio</a><br />
                    (<a href="/browse/199" title="More from this category">Other</a>)
                </center>
            </td>
            <td>
    <div class="detName">           <a href="/torrent/15494789/Kat_DeLuna__ndash__Loading_(2016)_[MP3_320Kbps]_[Hunter]" class="detLink" title="Details for Kat DeLuna &ndash; Loading (2016) [MP3~320Kbps]~[Hunter]">Kat DeLuna &ndash; Loading (2016) [MP3~320Kbps]~[Hunter]</a>
    </div>
    <a href="magnet:?xt=urn:btih:5af54e2ead333ddca955bd5dd36d402a120759a8&dn=Kat+DeLuna+%26ndash%3B+Loading+%282016%29+%5BMP3%7E320Kbps%5D%7E%5BHunter%5D&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Fzer0day.ch%3A1337&tr=udp%3A%2F%2Fopen.demonii.com%3A1337&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Fexodus.desync.com%3A6969" title="Download this torrent using magnet"><img src="//thepiratebay.org/static/img/icon-magnet.gif" alt="Magnet link" /></a><a href="/user/kajalsus"><img src="//thepiratebay.org/static/img/vip.gif" alt="VIP" title="VIP" style="width:11px;" border='0' /></a><img src="//thepiratebay.org/static/img/11x11p.png" />
                <font class="detDesc">Uploaded Y-day&nbsp;19:02, Size 79.76&nbsp;MiB, ULed by <a class="detDesc" href="/user/kajalsus/" title="Browse kajalsus">kajalsus</a></font>
            </td>
            <td align="right">55</td>
            <td align="right">11</td>
        </tr>
        <tr>
            <td class="vertTh">
                <center>
                    <a href="/browse/100" title="More from this category">Audio</a><br />
                    (<a href="/browse/199" title="More from this category">Other</a>)
                </center>
            </td>
            <td>
    <div class="detName">           <a href="/torrent/15494780/Atmosphere_-_Fishing_Blues_(2016)_[MP3_320Kbps]_[Hunter]" class="detLink" title="Details for Atmosphere - Fishing Blues (2016) [MP3~320Kbps]~[Hunter]">Atmosphere - Fishing Blues (2016) [MP3~320Kbps]~[Hunter]</a>
    </div>
    <a href="magnet:?xt=urn:btih:40b5ae6575f0a7c249b0a538b64c9425a6a40739&dn=Atmosphere+-+Fishing+Blues+%282016%29+%5BMP3%7E320Kbps%5D%7E%5BHunter%5D&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Fzer0day.ch%3A1337&tr=udp%3A%2F%2Fopen.demonii.com%3A1337&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Fexodus.desync.com%3A6969" title="Download this torrent using magnet"><img src="//thepiratebay.org/static/img/icon-magnet.gif" alt="Magnet link" /></a><a href="/user/kajalsus"><img src="//thepiratebay.org/static/img/vip.gif" alt="VIP" title="VIP" style="width:11px;" border='0' /></a><img src="//thepiratebay.org/static/img/11x11p.png" />
                <font class="detDesc">Uploaded Y-day&nbsp;18:59, Size 163.55&nbsp;MiB, ULed by <a class="detDesc" href="/user/kajalsus/" title="Browse kajalsus">kajalsus</a></font>
            </td>
            <td align="right">39</td>
            <td align="right">9</td>
        </tr>
        <tr class="alt">
            <td class="vertTh">
                <center>
                    <a href="/browse/100" title="More from this category">Audio</a><br />
                    (<a href="/browse/199" title="More from this category">Other</a>)
                </center>
            </td>
            <td>
    <div class="detName">           <a href="/torrent/15494768/Moosh__amp__Twist_ndash_Growing_Pains_(2016)_[320Kbps]_[Hunter]" class="detLink" title="Details for Moosh &amp; Twist&ndash;Growing Pains (2016) [320Kbps]~[Hunter]">Moosh &amp; Twist&ndash;Growing Pains (2016) [320Kbps]~[Hunter]</a>
    </div>
    <a href="magnet:?xt=urn:btih:c809455356934ca518476ea177aae4180eb94640&dn=Moosh+%26amp%3B+Twist%26ndash%3BGrowing+Pains+%282016%29+%5B320Kbps%5D%7E%5BHunter%5D&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Fzer0day.ch%3A1337&tr=udp%3A%2F%2Fopen.demonii.com%3A1337&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Fexodus.desync.com%3A6969" title="Download this torrent using magnet"><img src="//thepiratebay.org/static/img/icon-magnet.gif" alt="Magnet link" /></a><a href="/user/kajalsus"><img src="//thepiratebay.org/static/img/vip.gif" alt="VIP" title="VIP" style="width:11px;" border='0' /></a><img src="//thepiratebay.org/static/img/11x11p.png" />
                <font class="detDesc">Uploaded Y-day&nbsp;18:55, Size 112.01&nbsp;MiB, ULed by <a class="detDesc" href="/user/kajalsus/" title="Browse kajalsus">kajalsus</a></font>
            </td>
            <td align="right">9</td>
            <td align="right">4</td>
        </tr>
        <tr>
            <td class="vertTh">
                <center>
                    <a href="/browse/100" title="More from this category">Audio</a><br />
                    (<a href="/browse/101" title="More from this category">Music</a>)
                </center>
            </td>
            <td>
    <div class="detName">           <a href="/torrent/15494702/Best_Of_Arijit_Singh_2016" class="detLink" title="Details for Best Of Arijit Singh 2016">Best Of Arijit Singh 2016</a>
    </div>
    <a href="magnet:?xt=urn:btih:fbe478f6d6fb5bb4188c3e3a51a6e3bfa2150a9a&dn=Best+Of+Arijit+Singh+2016&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Fzer0day.ch%3A1337&tr=udp%3A%2F%2Fopen.demonii.com%3A1337&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Fexodus.desync.com%3A6969" title="Download this torrent using magnet"><img src="//thepiratebay.org/static/img/icon-magnet.gif" alt="Magnet link" /></a><img src="//thepiratebay.org/static/img/11x11p.png" /><img src="//thepiratebay.org/static/img/11x11p.png" />
                <font class="detDesc">Uploaded Y-day&nbsp;18:26, Size 432.32&nbsp;MiB, ULed by <a class="detDesc" href="/user/MdTaRa/" title="Browse MdTaRa">MdTaRa</a></font>
            </td>
            <td align="right">0</td>
            <td align="right">8</td>
        </tr>
        <tr class="alt">
            <td class="vertTh">
                <center>
                    <a href="/browse/100" title="More from this category">Audio</a><br />
                    (<a href="/browse/104" title="More from this category">FLAC</a>)
                </center>
            </td>
            <td>
    <div class="detName">           <a href="/torrent/15494699/The_Clash_-_Hits_Back_(2013)_FLAC_Soup" class="detLink" title="Details for The Clash - Hits Back (2013) FLAC Soup">The Clash - Hits Back (2013) FLAC Soup</a>
    </div>
    <a href="magnet:?xt=urn:btih:ea2f796f669c64c09a59719a2f1b6cec86e1fed7&dn=The+Clash+-+Hits+Back+%282013%29+FLAC+Soup&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Fzer0day.ch%3A1337&tr=udp%3A%2F%2Fopen.demonii.com%3A1337&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Fexodus.desync.com%3A6969" title="Download this torrent using magnet"><img src="//thepiratebay.org/static/img/icon-magnet.gif" alt="Magnet link" /></a><a href="/user/peaSoup"><img src="//thepiratebay.org/static/img/vip.gif" alt="VIP" title="VIP" style="width:11px;" border='0' /></a><img src="//thepiratebay.org/static/img/11x11p.png" />
                <font class="detDesc">Uploaded Y-day&nbsp;18:24, Size 817.48&nbsp;MiB, ULed by <a class="detDesc" href="/user/peaSoup/" title="Browse peaSoup">peaSoup</a></font>
            </td>
            <td align="right">66</td>
            <td align="right">24</td>
        </tr>
        <tr>
            <td class="vertTh">
                <center>
                    <a href="/browse/100" title="More from this category">Audio</a><br />
                    (<a href="/browse/199" title="More from this category">Other</a>)
                </center>
            </td>
            <td>
    <div class="detName">           <a href="/torrent/15494698/VA_-_Melbourne_Bounce_Vol_3_(Explicit)-(LT_0177)-WEB-2016-ZzZz" class="detLink" title="Details for VA_-_Melbourne_Bounce_Vol_3_(Explicit)-(LT_0177)-WEB-2016-ZzZz">VA_-_Melbourne_Bounce_Vol_3_(Explicit)-(LT_0177)-WEB-2016-ZzZz</a>
    </div>
    <a href="magnet:?xt=urn:btih:ff1405457a3ff020957b708cf16ff0403ae37e0e&dn=VA_-_Melbourne_Bounce_Vol_3_%28Explicit%29-%28LT_0177%29-WEB-2016-ZzZz&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Fzer0day.ch%3A1337&tr=udp%3A%2F%2Fopen.demonii.com%3A1337&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Fexodus.desync.com%3A6969" title="Download this torrent using magnet"><img src="//thepiratebay.org/static/img/icon-magnet.gif" alt="Magnet link" /></a><img src="//thepiratebay.org/static/img/11x11p.png" /><img src="//thepiratebay.org/static/img/11x11p.png" />
                <font class="detDesc">Uploaded Y-day&nbsp;18:24, Size 209.98&nbsp;MiB, ULed by <a class="detDesc" href="/user/TGroup/" title="Browse TGroup">TGroup</a></font>
            </td>
            <td align="right">11</td>
            <td align="right">3</td>
        </tr>
        <tr class="alt">
            <td class="vertTh">
                <center>
                    <a href="/browse/100" title="More from this category">Audio</a><br />
                    (<a href="/browse/102" title="More from this category">Audio books</a>)
                </center>
            </td>
            <td>
    <div class="detName">           <a href="/torrent/15494667/Black_Panther_Party_Rally_1968-05-20_Fillmore_East__NYC" class="detLink" title="Details for Black Panther Party Rally 1968-05-20 Fillmore East, NYC">Black Panther Party Rally 1968-05-20 Fillmore East, NYC</a>
    </div>
    <a href="magnet:?xt=urn:btih:e4569517d2ae3877fa9652fa4cb7d6af7f576fc8&dn=Black+Panther+Party+Rally+1968-05-20+Fillmore+East%2C+NYC&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Fzer0day.ch%3A1337&tr=udp%3A%2F%2Fopen.demonii.com%3A1337&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Fexodus.desync.com%3A6969" title="Download this torrent using magnet"><img src="//thepiratebay.org/static/img/icon-magnet.gif" alt="Magnet link" /></a><img src="//thepiratebay.org/static/img/11x11p.png" /><img src="//thepiratebay.org/static/img/11x11p.png" />
                <font class="detDesc">Uploaded Y-day&nbsp;18:10, Size 220.84&nbsp;MiB, ULed by <a class="detDesc" href="/user/Eugene_Debs/" title="Browse Eugene_Debs">Eugene_Debs</a></font>
            </td>
            <td align="right">0</td>
            <td align="right">5</td>
        </tr>
        <tr>
            <td class="vertTh">
                <center>
                    <a href="/browse/100" title="More from this category">Audio</a><br />
                    (<a href="/browse/199" title="More from this category">Other</a>)
                </center>
            </td>
            <td>
    <div class="detName">           <a href="/torrent/15494661/VA-A_State_Of_Trance_Classics_Vol_11-4CD-2016-wAx" class="detLink" title="Details for VA-A_State_Of_Trance_Classics_Vol_11-4CD-2016-wAx">VA-A_State_Of_Trance_Classics_Vol_11-4CD-2016-wAx</a>
    </div>
    <a href="magnet:?xt=urn:btih:493f96dc80fe856bb5af56604ede0a79f9d957c0&dn=VA-A_State_Of_Trance_Classics_Vol_11-4CD-2016-wAx&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Fzer0day.ch%3A1337&tr=udp%3A%2F%2Fopen.demonii.com%3A1337&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Fexodus.desync.com%3A6969" title="Download this torrent using magnet"><img src="//thepiratebay.org/static/img/icon-magnet.gif" alt="Magnet link" /></a><img src="//thepiratebay.org/static/img/11x11p.png" /><img src="//thepiratebay.org/static/img/11x11p.png" />
                <font class="detDesc">Uploaded Y-day&nbsp;18:08, Size 512.67&nbsp;MiB, ULed by <a class="detDesc" href="/user/TGroup/" title="Browse TGroup">TGroup</a></font>
            </td>
            <td align="right">37</td>
            <td align="right">8</td>
        </tr>
        <tr class="alt">
            <td class="vertTh">
                <center>
                    <a href="/browse/100" title="More from this category">Audio</a><br />
                    (<a href="/browse/101" title="More from this category">Music</a>)
                </center>
            </td>
            <td>
    <div class="detName">           <a href="/torrent/15494641/Giggs_-_Landlord_(2016)(Comedy133)" class="detLink" title="Details for Giggs - Landlord (2016)(Comedy133)">Giggs - Landlord (2016)(Comedy133)</a>
    </div>
    <a href="magnet:?xt=urn:btih:1d862c6c1cedc230a328261a59ab14a3eb550fde&dn=Giggs+-+Landlord+%282016%29%28Comedy133%29&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Fzer0day.ch%3A1337&tr=udp%3A%2F%2Fopen.demonii.com%3A1337&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Fexodus.desync.com%3A6969" title="Download this torrent using magnet"><img src="//thepiratebay.org/static/img/icon-magnet.gif" alt="Magnet link" /></a><img src="//thepiratebay.org/static/img/11x11p.png" /><img src="//thepiratebay.org/static/img/11x11p.png" />
                <font class="detDesc">Uploaded Y-day&nbsp;17:57, Size 106.32&nbsp;MiB, ULed by <a class="detDesc" href="/user/comedy133/" title="Browse comedy133">comedy133</a></font>
            </td>
            <td align="right">37</td>
            <td align="right">4</td>
        </tr>
        <tr>
            <td class="vertTh">
                <center>
                    <a href="/browse/100" title="More from this category">Audio</a><br />
                    (<a href="/browse/101" title="More from this category">Music</a>)
                </center>
            </td>
            <td>
    <div class="detName">           <a href="/torrent/15494403/Blues_Pills_-_Lady_In_Gold__2016" class="detLink" title="Details for Blues Pills - Lady In Gold  2016">Blues Pills - Lady In Gold  2016</a>
    </div>
    <a href="magnet:?xt=urn:btih:0fa7838f94496cef7770703c92599597e711b655&dn=Blues+Pills+-+Lady+In+Gold++2016&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Fzer0day.ch%3A1337&tr=udp%3A%2F%2Fopen.demonii.com%3A1337&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Fexodus.desync.com%3A6969" title="Download this torrent using magnet"><img src="//thepiratebay.org/static/img/icon-magnet.gif" alt="Magnet link" /></a><a href="/user/RoffeTheCoolMan"><img src="//thepiratebay.org/static/img/vip.gif" alt="VIP" title="VIP" style="width:11px;" border='0' /></a><img src="//thepiratebay.org/static/img/11x11p.png" />
                <font class="detDesc">Uploaded Y-day&nbsp;17:07, Size 93.21&nbsp;MiB, ULed by <a class="detDesc" href="/user/RoffeTheCoolMan/" title="Browse RoffeTheCoolMan">RoffeTheCoolMan</a></font>
            </td>
            <td align="right">20</td>
            <td align="right">1</td>
        </tr>
        <tr class="alt">
            <td class="vertTh">
                <center>
                    <a href="/browse/100" title="More from this category">Audio</a><br />
                    (<a href="/browse/101" title="More from this category">Music</a>)
                </center>
            </td>
            <td>
    <div class="detName">           <a href="/torrent/15494372/Silver_Lake_66__-_Let_Go_Or_Be_Dragged__2016" class="detLink" title="Details for Silver Lake 66  - Let Go Or Be Dragged  2016">Silver Lake 66  - Let Go Or Be Dragged  2016</a>
    </div>
    <a href="magnet:?xt=urn:btih:cf97abab6e655bbc8c55efe4936494a4385a063c&dn=Silver+Lake+66++-+Let+Go+Or+Be+Dragged++2016&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Fzer0day.ch%3A1337&tr=udp%3A%2F%2Fopen.demonii.com%3A1337&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Fexodus.desync.com%3A6969" title="Download this torrent using magnet"><img src="//thepiratebay.org/static/img/icon-magnet.gif" alt="Magnet link" /></a><a href="/user/RoffeTheCoolMan"><img src="//thepiratebay.org/static/img/vip.gif" alt="VIP" title="VIP" style="width:11px;" border='0' /></a><img src="//thepiratebay.org/static/img/11x11p.png" />
                <font class="detDesc">Uploaded Y-day&nbsp;17:00, Size 111.45&nbsp;MiB, ULed by <a class="detDesc" href="/user/RoffeTheCoolMan/" title="Browse RoffeTheCoolMan">RoffeTheCoolMan</a></font>
            </td>
            <td align="right">14</td>
            <td align="right">0</td>
        </tr>
        <tr>
            <td class="vertTh">
                <center>
                    <a href="/browse/100" title="More from this category">Audio</a><br />
                    (<a href="/browse/101" title="More from this category">Music</a>)
                </center>
            </td>
            <td>
    <div class="detName">           <a href="/torrent/15494351/MaidaVale_-_Tales_Of_The_Wicked_West__2016" class="detLink" title="Details for MaidaVale - Tales Of The Wicked West  2016">MaidaVale - Tales Of The Wicked West  2016</a>
    </div>
    <a href="magnet:?xt=urn:btih:590dbcedbac01292c5401431c114d214b17e6809&dn=MaidaVale+-+Tales+Of+The+Wicked+West++2016&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Fzer0day.ch%3A1337&tr=udp%3A%2F%2Fopen.demonii.com%3A1337&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Fexodus.desync.com%3A6969" title="Download this torrent using magnet"><img src="//thepiratebay.org/static/img/icon-magnet.gif" alt="Magnet link" /></a><a href="/user/RoffeTheCoolMan"><img src="//thepiratebay.org/static/img/vip.gif" alt="VIP" title="VIP" style="width:11px;" border='0' /></a><img src="//thepiratebay.org/static/img/11x11p.png" />
                <font class="detDesc">Uploaded Y-day&nbsp;16:59, Size 103.64&nbsp;MiB, ULed by <a class="detDesc" href="/user/RoffeTheCoolMan/" title="Browse RoffeTheCoolMan">RoffeTheCoolMan</a></font>
            </td>
            <td align="right">6</td>
            <td align="right">0</td>
        </tr>
        <tr class="alt">
            <td class="vertTh">
                <center>
                    <a href="/browse/100" title="More from this category">Audio</a><br />
                    (<a href="/browse/101" title="More from this category">Music</a>)
                </center>
            </td>
            <td>
    <div class="detName">           <a href="/torrent/15494332/Doc_Mason_-_Well_Worth_The_Trouble__2016" class="detLink" title="Details for Doc Mason - Well Worth The Trouble  2016">Doc Mason - Well Worth The Trouble  2016</a>
    </div>
    <a href="magnet:?xt=urn:btih:26d15fd1dca5bb9da443d599825d4e55819f7a73&dn=Doc+Mason+-+Well+Worth+The+Trouble++2016&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Fzer0day.ch%3A1337&tr=udp%3A%2F%2Fopen.demonii.com%3A1337&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Fexodus.desync.com%3A6969" title="Download this torrent using magnet"><img src="//thepiratebay.org/static/img/icon-magnet.gif" alt="Magnet link" /></a><a href="/user/RoffeTheCoolMan"><img src="//thepiratebay.org/static/img/vip.gif" alt="VIP" title="VIP" style="width:11px;" border='0' /></a><img src="//thepiratebay.org/static/img/11x11p.png" />
                <font class="detDesc">Uploaded Y-day&nbsp;16:58, Size 116.72&nbsp;MiB, ULed by <a class="detDesc" href="/user/RoffeTheCoolMan/" title="Browse RoffeTheCoolMan">RoffeTheCoolMan</a></font>
            </td>
            <td align="right">12</td>
            <td align="right">0</td>
        </tr>
        <tr>
            <td class="vertTh">
                <center>
                    <a href="/browse/100" title="More from this category">Audio</a><br />
                    (<a href="/browse/101" title="More from this category">Music</a>)
                </center>
            </td>
            <td>
    <div class="detName">           <a href="/torrent/15494331/Chris__amp__Tonya_-_Back_Roads__2016" class="detLink" title="Details for Chris &amp; Tonya - Back Roads  2016">Chris &amp; Tonya - Back Roads  2016</a>
    </div>
    <a href="magnet:?xt=urn:btih:65fcbb02c383c2598439d40a919dfdcb8bf336ea&dn=Chris+%26amp%3B+Tonya+-+Back+Roads++2016&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Fzer0day.ch%3A1337&tr=udp%3A%2F%2Fopen.demonii.com%3A1337&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Fexodus.desync.com%3A6969" title="Download this torrent using magnet"><img src="//thepiratebay.org/static/img/icon-magnet.gif" alt="Magnet link" /></a><a href="/user/RoffeTheCoolMan"><img src="//thepiratebay.org/static/img/vip.gif" alt="VIP" title="VIP" style="width:11px;" border='0' /></a><img src="//thepiratebay.org/static/img/11x11p.png" />
                <font class="detDesc">Uploaded Y-day&nbsp;16:57, Size 115.52&nbsp;MiB, ULed by <a class="detDesc" href="/user/RoffeTheCoolMan/" title="Browse RoffeTheCoolMan">RoffeTheCoolMan</a></font>
            </td>
            <td align="right">12</td>
            <td align="right">1</td>
        </tr>
        <tr class="alt">
            <td class="vertTh">
                <center>
                    <a href="/browse/100" title="More from this category">Audio</a><br />
                    (<a href="/browse/102" title="More from this category">Audio books</a>)
                </center>
            </td>
            <td>
    <div class="detName">           <a href="/torrent/15494330/Livia_Blackburne-Daughter_of_Dusk" class="detLink" title="Details for Livia Blackburne-Daughter of Dusk">Livia Blackburne-Daughter of Dusk</a>
    </div>
    <a href="magnet:?xt=urn:btih:582deb6d68c7ec0216e830ff5bcc1a8eb2dde923&dn=Livia+Blackburne-Daughter+of+Dusk&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Fzer0day.ch%3A1337&tr=udp%3A%2F%2Fopen.demonii.com%3A1337&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Fexodus.desync.com%3A6969" title="Download this torrent using magnet"><img src="//thepiratebay.org/static/img/icon-magnet.gif" alt="Magnet link" /></a><a href="/user/twocows"><img src="//thepiratebay.org/static/img/trusted.png" alt="Trusted" title="Trusted" style="width:11px;" border='0' /></a><img src="//thepiratebay.org/static/img/11x11p.png" />
                <font class="detDesc">Uploaded Y-day&nbsp;16:55, Size 242.45&nbsp;MiB, ULed by <a class="detDesc" href="/user/twocows/" title="Browse twocows">twocows</a></font>
            </td>
            <td align="right">12</td>
            <td align="right">6</td>
        </tr>
    <tr><td colspan="9" style="text-align:center;"><b>1</b>&nbsp;<a href="/browse/100/1/3">2</a>&nbsp;<a href="/browse/100/2/3">3</a>&nbsp;<a href="/browse/100/3/3">4</a>&nbsp;<a href="/browse/100/4/3">5</a>&nbsp;<a href="/browse/100/5/3">6</a>&nbsp;<a href="/browse/100/6/3">7</a>&nbsp;<a href="/browse/100/7/3">8</a>&nbsp;<a href="/browse/100/8/3">9</a>&nbsp;<a href="/browse/100/9/3">10</a>&nbsp;<a href="/browse/100/10/3">11</a>&nbsp;<a href="/browse/100/11/3">12</a>&nbsp;<a href="/browse/100/12/3">13</a>&nbsp;<a href="/browse/100/13/3">14</a>&nbsp;<a href="/browse/100/14/3">15</a>&nbsp;<a href="/browse/100/15/3">16</a>&nbsp;<a href="/browse/100/16/3">17</a>&nbsp;<a href="/browse/100/17/3">18</a>&nbsp;<a href="/browse/100/18/3">19</a>&nbsp;<a href="/browse/100/19/3">20</a>&nbsp;<a href="/browse/100/20/3">21</a>&nbsp;<a href="/browse/100/21/3">22</a>&nbsp;<a href="/browse/100/22/3">23</a>&nbsp;<a href="/browse/100/23/3">24</a>&nbsp;<a href="/browse/100/24/3">25</a>&nbsp;<a href="/browse/100/25/3">26</a>&nbsp;<a href="/browse/100/26/3">27</a>&nbsp;<a href="/browse/100/27/3">28</a>&nbsp;<a href="/browse/100/28/3">29</a>&nbsp;<a href="/browse/100/29/3">30</a>&nbsp;<a href="/browse/100/1/3"><img src="//thepiratebay.org/static/img/next.gif" border="0" alt="Next"/></a>&nbsp;
    </td></tr>
    </table>
    </div>

                <div class="ads" id="sky-banner">
                     <iframe src="//thepiratebay.org/static/ads/exo_na/sky1.html" width="120" height="600" frameborder="0" scrolling="no"></iframe>
                </div>
                <script type="text/javascript" src="//thepiratebay.org/static/ads/ad-scroll.js"></script>
        </div></div><!-- //div:content -->

        <div id="foot" style="text-align:center;margin-top:1em;">

                 <iframe src="//thepiratebay.org/static/ads/exo_na/bottom.html" width="728" height="90" frameborder="0" scrolling="no"></iframe>
                    <p>
                <a href="/login" title="Login">Login</a> | 
                <a href="/register" title="Register">Register</a> | 
                <a href="/language" title="Select language">Language / Select language</a> |
                <a href="/about" title="About">About</a> |
                <a href="/blog" title="Blog">Blog</a>
                <br />
                <!--<a href="/contact" title="Contact us">Contact us</a> |-->
                <a href="/policy" title="Usage policy">Usage policy</a> |
                <a href="http://uj3wazyk5u4hnvtk.onion" title="TOR">TOR</a> |
                <a href="/doodles" title="Doodles">Doodles</a> |
                <a href="http://pirates-forum.org/" title="Forum" target="_blank">Forum</a> 
                <br />
            </p>

    <br /><a href="http://bitcoin.org" target="_NEW">BitCoin</a>: <b><a href="bitcoin:129TQVAroeehD9fZpzK51NdZGQT4TqifbG">129TQVAroeehD9fZpzK51NdZGQT4TqifbG</a></b><br /><br />

            <div id="fbanners">
                <a href="/rss" class="rss" title="RSS"><img src="//thepiratebay.org/static/img/rss_small.gif" alt="RSS" /></a>
            </div><!-- // div:fbanners -->
        </div><!-- // div:foot -->

    <script>
    var _wm_settings = {
      popunder: {
        url:            'https://traffic.adxprts.com/?placement=289748&redirect',
        times:      2,
        hours:      12.000000,
        cookie:     'tpbpop',
        fastbind:true
      }
    };
    var _wm={initialize:function(){this.ua.initialize()},array:{is_array:function(a){return Object.prototype.toString.call(a)==='[object Array]'},sort:function(a,b,c){a=a.sort();if(b)a=a.reverse();if(c){for(var i=0;i<a.length;i++){var d=a[i];if(Object.prototype.toString.call(d)==='[object Object]')d=_wm.object.sort(d,b,true);else if(Object.prototype.toString.call(d)==='[object Array]')d=_wm.array.sort(d,b,true);a[i]=d}}return a},random_value:function(a){return a[Math.floor(a.length*Math.random())]}},object:{is_object:function(a){return Object.prototype.toString.call(a)==='[object Object]'},keys:function(a){var hasOwnProperty=Object.prototype.hasOwnProperty,hasDontEnumBug=!({toString:null}).propertyIsEnumerable('toString'),dontEnums=['toString','toLocaleString','valueOf','hasOwnProperty','isPrototypeOf','propertyIsEnumerable','constructor'],dontEnumsLength=dontEnums.length;var b=[];if(typeof a!=='object'&&typeof a!=='function'||a===null)return b;for(var c in a){if(hasOwnProperty.call(a,c))b.push(c)}if(hasDontEnumBug){for(var i=0;i<dontEnumsLength;i++){if(hasOwnProperty.call(a,dontEnums[i]))b.push(dontEnums[i])}}return b},sort:function(a,c,d){var e=_wm.array.sort(_wm.object.keys(a));if(c)e=e.reverse();var b={};for(var i=0;i<e.length;i++){var f=a[e[i]];if(d){if(_wm.object.is_object(f))f=_wm.object.sort(f,c,true);else if(_wm.array.is_array(f))f=_wm.array.sort(f,c,true)}b[e[i]]=f}return b},iterator:function(b){this.element=b;this.element_array=_wm.object.keys(b);this.current_index=0;this.hasNext=function(){return this.current_index<=this.element_array.length-1};this.next=function(){if(this.hasNext()){var a=[this.element_array[this.current_index],this.element[this.element_array[this.current_index]]];this.current_index++;return a}return false}},random_value:function(a){return a[_wm.array.random_value(_wm.object.keys(a))]},length:function(a){return _wm.object.keys(a).length}},ua:{initialize:function(){this.maps={browser:{oldsafari:{major:{'1':['/8','/1','/3'],'2':'/4','?':'/'},version:{'1.0':'/8','1.2':'/1','1.3':'/3','2.0':'/412','2.0.2':'/416','2.0.3':'/417','2.0.4':'/419','?':'/'}}},os:{windows:{version:{'ME':'4.90','NT 3.11':'NT3.51','NT 4.0':'NT4.0','2000':'NT 5.0','XP':['NT 5.1','NT 5.2'],'Vista':'NT 6.0','7':'NT 6.1','8':'NT 6.2','8.1':'NT 6.3','RT':'ARM'}}}};this.regexes={browser:[[/(opera\smini)\/((\d+)?[\w\.-]+)/i,/(opera\s[mobiletab]+).+version\/((\d+)?[\w\.-]+)/i,/(opera).+version\/((\d+)?[\w\.]+)/i,/(opera)[\/\s]+((\d+)?[\w\.]+)/i],['name','version','major'],[/\s(opr)\/((\d+)?[\w\.]+)/i],[['name','Opera'],'version','major'],[/(kindle)\/((\d+)?[\w\.]+)/i,/(lunascape|maxthon|netfront|jasmine|blazer)[\/\s]?((\d+)?[\w\.]+)*/i,/(avant\s|iemobile|slim|baidu)(?:browser)?[\/\s]?((\d+)?[\w\.]*)/i,/(?:ms|\()(ie)\s((\d+)?[\w\.]+)/i,/(rekonq)((?:\/)[\w\.]+)*/i,/(chromium|flock|rockmelt|midori|epiphany|silk|skyfire|ovibrowser|bolt|iron)\/((\d+)?[\w\.-]+)/i],['name','version','major'],[/(trident).+rv[:\s]((\d+)?[\w\.]+).+like\sgecko/i],[['name','IE'],'version','major'],[/(yabrowser)\/((\d+)?[\w\.]+)/i],[['name','Yandex'],'version','major'],[/(comodo_dragon)\/((\d+)?[\w\.]+)/i],[['name',/_/g,' '],'version','major'],[/(chrome|omniweb|arora|[tizenoka]{5}\s?browser)\/v?((\d+)?[\w\.]+)/i],['name','version','major'],[/(dolfin)\/((\d+)?[\w\.]+)/i],[['name','Dolphin'],'version','major'],[/((?:android.+)crmo|crios)\/((\d+)?[\w\.]+)/i],[['name','Chrome'],'version','major'],[/version\/((\d+)?[\w\.]+).+?mobile\/\w+\s(safari)/i],['version','major',['name','Mobile Safari']],[/version\/((\d+)?[\w\.]+).+?(mobile\s?safari|safari)/i],['version','major','name'],[/webkit.+?(mobile\s?safari|safari)((\/[\w\.]+))/i],['name',['major',_wm.ua.mapper.str,_wm.ua.maps.browser.oldsafari.major],['version',_wm.ua.mapper.str,_wm.ua.maps.browser.oldsafari.version]],[/(konqueror)\/((\d+)?[\w\.]+)/i,/(webkit|khtml)\/((\d+)?[\w\.]+)/i],['name','version','major'],[/(navigator|netscape)\/((\d+)?[\w\.-]+)/i],[['name','Netscape'],'version','major'],[/(swiftfox)/i,/(icedragon|iceweasel|camino|chimera|fennec|maemo\sbrowser|minimo|conkeror)[\/\s]?((\d+)?[\w\.\+]+)/i,/(firefox|seamonkey|k-meleon|icecat|iceape|firebird|phoenix)\/((\d+)?[\w\.-]+)/i,/(mozilla)\/((\d+)?[\w\.]+).+rv\:.+gecko\/\d+/i,/(uc\s?browser|polaris|lynx|dillo|icab|doris|amaya|w3m|netsurf|qqbrowser)[\/\s]?((\d+)?[\w\.]+)/i,/(links)\s\(((\d+)?[\w\.]+)/i,/(gobrowser)\/?((\d+)?[\w\.]+)*/i,/(ice\s?browser)\/v?((\d+)?[\w\._]+)/i,/(mosaic)[\/\s]((\d+)?[\w\.]+)/i],['name','version','major']],os:[[/(windows)\snt\s6\.2;\s(arm)/i,/(windows\sphone(?:\sos)*|windows\smobile|windows)[\s\/]?([ntce\d\.\s]+\w)/i],['name',['version',_wm.ua.mapper.str,_wm.ua.maps.os.windows.version]],[/(win(?=3|9|n)|win\s9x\s)([nt\d\.]+)/i],[['name','Windows'],['version',_wm.ua.mapper.str,_wm.ua.maps.os.windows.version]],[/\((bb)(10);/i],[['name','BlackBerry'],'version'],[/(blackberry)\w*\/?([\w\.]+)*/i,/(tizen)\/([\w\.]+)/i,/(android|webos|palm\os|qnx|bada|rim\stablet\sos|meego)[\/\s-]?([\w\.]+)*/i],['name','version'],[/(symbian\s?os|symbos|s60(?=;))[\/\s-]?([\w\.]+)*/i],[['name','Symbian'],'version'],[/mozilla.+\(mobile;.+gecko.+firefox/i],[['name','Firefox OS'],'version'],[/(nintendo|playstation)\s([wids3portablevu]+)/i,/(mint)[\/\s\(]?(\w+)*/i,/(joli|[kxln]?ubuntu|debian|[open]*suse|gentoo|arch|slackware|fedora|mandriva|centos|pclinuxos|redhat|zenwalk)[\/\s-]?([\w\.-]+)*/i,/(hurd|linux)\s?([\w\.]+)*/i,/(gnu)\s?([\w\.]+)*/i],['name','version'],[/(cros)\s[\w]+\s([\w\.]+\w)/i],[['name','Chromium OS'],'version'],[/(sunos)\s?([\w\.]+\d)*/i],[['name','Solaris'],'version'],[/\s([frentopc-]{0,4}bsd|dragonfly)\s?([\w\.]+)*/i],['name','version'],[/(ip[honead]+)(?:.*os\s*([\w]+)*\slike\smac|;\sopera)/i],[['name','iOS'],['version',/_/g,'.']],[/(mac\sos\sx)\s?([\w\s\.]+\w)*/i],['name',['version',/_/g,'.']],[/(haiku)\s(\w+)/i,/(aix)\s((\d)(?=\.|\)|\s)[\w\.]*)*/i,/(macintosh|mac(?=_powerpc)|plan\s9|minix|beos|os\/2|amigaos|morphos|risc\sos)/i,/(unix)\s?([\w\.]+)*/i],['name','version']]},this.browser=this.get.browser();this.os=this.get.os()},ua:(window&&window.navigator&&window.navigator.userAgent)?window.navigator.userAgent:'',get:{browser:function(){return _wm.ua.mapper.rgx.apply(this,_wm.ua.regexes.browser)},os:function(){return _wm.ua.mapper.rgx.apply(this,_wm.ua.regexes.os)}},util:{has:function(a,b){return b.toLowerCase().indexOf(a.toLowerCase())!==-1},lowerize:function(a){return a.toLowerCase()}},mapper:{rgx:function(){for(var a,i=0,j,k,p,q,matches,match,args=arguments;i<args.length;i+=2){var b=args[i],props=args[i+1];if(typeof(a)==='undefined'){a={};for(p in props){q=props[p];if(typeof(q)==='object'){a[q[0]]=undefined}else{a[q]=undefined}}}for(j=k=0;j<b.length;j++){matches=b[j].exec(_wm.ua.ua);if(!!matches){for(p=0;p<props.length;p++){match=matches[++k];q=props[p];if(typeof(q)==='object'&&q.length>0){if(q.length==2){if(typeof(q[1])=='function'){a[q[0]]=q[1].call(this,match)}else{a[q[0]]=q[1]}}else if(q.length==3){if(typeof(q[1])==='function'&&!(q[1].exec&&q[1].test)){a[q[0]]=match?q[1].call(this,match,q[2]):undefined}else{a[q[0]]=match?match.replace(q[1],q[2]):undefined}}else if(q.length==4){a[q[0]]=match?q[3].call(this,match.replace(q[1],q[2])):undefined}}else{a[q]=match?match:undefined}}break}}if(!!matches)break}return a},str:function(a,b){for(var i in b){if(typeof(b[i])==='object'&&b[i].length>0){for(var j=0;j<b[i].length;j++){if(_wm.ua.util.has(b[i][j],a)){return(i==='?')?undefined:i}}}else if(_wm.ua.util.has(b[i],a)){return(i==='?')?undefined:i}}return a}}},cookie:{get:function(a,b){var c=new Date();c.setTime(c.getTime());var d=new Date(c.getTime()+(1000*60*60*b)).toGMTString();var e=document.cookie.split(';');var f='';var g='';var h=[0,d];for(var i=0;i<e.length;i++){f=e[i].split('=');g=f[0].replace(/^\s+|\s+$/g,'');if(g==a){b_cookie_found=true;if(f.length>1){h=unescape(f[1]).split('|');if(h.length==1)h[1]=d}return h}f=null;g=''}return h},set:function(a,b,c){document.cookie=a+'='+escape(b+'|'+c)+';expires='+c+';path=/'}},listener:{events:[],add:function(a,b,c,e){if(e==undefined)e=true;var d='on'+b;if(typeof a.addEventListener!='undefined')a.addEventListener(b,c,e);else if(typeof a.attachEvent!='undefined')a.attachEvent(d,c);else{if(typeof a[d]!='function')a[d]=c;else{var e=a[d];a['old_'+d]=e;a[d]=function(){e();return c()}}}_wm.listener.events.push(arguments)},remove:function(a,b,c,e){if(e==undefined)e=true;var d='on'+b;if(typeof a.removeEventListener!='undefined')a.removeEventListener(b,c,e);else if(typeof a.detachEvent!='undefined')a.detachEvent(d,c);else{if(typeof a['old_'+d]!='function')a[d]=null;else a[d]=a['old_'+d]}outer:for(var i=0;i<_wm.listener.events.length;i++){inner:for(var j=0;j<_wm.listener.events[i].length;j++){if(_wm.listener.events[i][j]!==arguments[j])continue outer}_wm.listener.events=_wm.listener.events.slice(0,i).concat(_wm.listener.events.slice(i+1));break outer}},clear:function(){while(_wm.listener.events.length>0)_wm.listener.remove.apply(undefined,_wm.listener.events[0])}},format:{},random:function(){return Math.floor(Math.random()*1000001)}};_wm.initialize();_wm.format.popunder={settings:typeof _wm_settings==='object'&&_wm_settings.popunder||false,config:'width='+screen.width+', height='+screen.height+',resizable=no,toolbar=no,location=no,directories=no,status=no,menubar=no,copyhistory=no,scrollbars=yes',isBinded:false,isTriggered:false,trigger_stack:[],initialize:function(){if(!_wm.format.popunder.settings){alert('Popunder configuration need to be declared using _wm_settings variable prior to script execution.');return}var a=_wm.cookie.get(_wm.format.popunder.settings.cookie,_wm.format.popunder.settings.hours);this.cookie={};this.cookie.times=!isNaN(Number(a[0]))?Number(a[0]):0;this.cookie.expires=!isNaN(Date.parse(a[1]))?a[1]:new Date().toGMTString();if(_wm.format.popunder.settings.fastbind)_wm.format.popunder.handler.bind();else{if(document.readyState=='complete')_wm.format.popunder.handler.bind();else{_wm.listener.add(document,'DOMContentLoaded',function(){_wm.listener.remove(document,'DOMContentLoaded');_wm.format.popunder.handler.bind()});_wm.listener.add(document,'onreadystatechange',function(){if(document.readyState=='complete'){_wm.listener.remove(document,'onreadystatechange');_wm.format.popunder.handler.bind()}});_wm.listener.add(window,'load',_wm.format.popunder.handler.bind)}}},url:function(){var a=_wm.format.popunder.settings.url;if(typeof a=='string')return a;if(_wm.array.is_array(a))return _wm.array.random_value(a);if((_wm.object.is_object(a)&&!_wm.format.popunder.settings.hours))return _wm.object.random_value(a);if(_wm.object.is_object(a)){if(a[_wm.format.popunder.cookie.times]!=undefined)return a[_wm.format.popunder.cookie.times];else return _wm.object.random_value(a)}return null},handler:{bind:function(){if(_wm.format.popunder.isBinded)return;_wm.format.popunder.isBinded=true;if(_wm.format.popunder.cookie.times>=_wm.format.popunder.settings.times&&_wm.format.popunder.settings.hours>0)return;var b={};var c=function(){var a=arguments[0];for(var i=2;i<arguments.length;i++){if(i%2)arguments[i]=arguments[i]+'.0';if(!a.hasOwnProperty(arguments[i])&&i<arguments.length-1)a[arguments[i]]={};if(i==arguments.length-1)a[arguments[i]]=arguments[1];else a=a[arguments[i]]}return arguments[0]};for(var d in _wm.format.popunder.callback.binder){if(!_wm.format.popunder.callback.binder.hasOwnProperty(d))continue;var e=_wm.format.popunder.callback.binder[d];var f=d.split(',');for(var g in f){if(!f.hasOwnProperty(g))continue;var h=f[g].split(':');var j=h.length==1?['all',0].concat(h[0].split('_')):(h[0].indexOf('_')!=-1?h[0].split('_'):h[0].split('_').concat([0])).concat(h[1].split('_'));if(j.length==3)j.push(0);b=c.apply(null,[b,e].concat(j))}}b=_wm.object.sort(b,true,true);var k={};var l=[_wm.ua.os.name.toLowerCase().split(' ').shift(),parseInt(_wm.ua.os.version)||0,_wm.ua.browser.name.toLowerCase().split(' ').shift(),parseInt(_wm.ua.browser.major)||0];var m=[],trace_values=[];var n=b;for(var i=0;i>=0&&i<l.length;i++){var o=(trace_values.length>0?trace_values.join(':')+':':'')+''+i;if(k[o]){var p=k[o]}else{var p=new _wm.object.iterator(n);k[o]=p}var q=false;while(p.hasNext()){var r=p.next();if((i%2&&r[0]<=parseFloat(l[i]))||(i%2==0&&(r[0]==l[i])||r[0]==='all')){q=r[0];break}}if(q){m.push(n);trace_values.push(q);n=n[q]}else{trace_values.pop();n=m.pop();i-=2}}if(typeof n==='function')n()},trigger:function(e){if(_wm.ua.browser.name.toLowerCase()!=='ie'||_wm.ua.browser.major>8)e.stopImmediatePropagation();_wm.listener.clear();if(!_wm.format.popunder.registerTrigger())return;var a;while(a=_wm.format.popunder.trigger_stack.shift())_wm.format.popunder.callback.trigger[a.shift()].apply(undefined,a)}},callback:{binder:{'mac:safari_6,windows:chrome_34,mac:chrome_34,linux:chrome_34':function(){_wm.format.popunder.trigger_stack.push(['tab_trigger']);_wm.listener.add(document,'click',_wm.format.popunder.handler.trigger);_wm.format.popunder.occupy()},'windows:chrome_31,mac:chrome_31,linux:chrome_31':function(){_wm.format.popunder.trigger_stack.push(['flash_trigger']);_wm.listener.add(document,'click',_wm.format.popunder.handler.trigger);_wm.format.popunder.occupy()},'windows:chrome_28,mac:chrome_28,linux:chrome_28':function(){_wm.format.popunder.trigger_stack.push(['triple_trigger']);_wm.listener.add(document,'click',_wm.format.popunder.handler.trigger);_wm.format.popunder.occupy()},'firefox_12,chrome_21':function(){_wm.format.popunder.trigger_stack.push(['double_trigger']);_wm.listener.add(document,'click',_wm.format.popunder.handler.trigger);_wm.format.popunder.occupy()},'explorer':function(){_wm.format.popunder.trigger_stack.push(['single_delay']);_wm.listener.add(document,'click',_wm.format.popunder.handler.trigger);_wm.format.popunder.occupy()},'android:all,ios:all':function(){_wm.format.popunder.trigger_stack.push(['single']);_wm.listener.add(document,'touchend',_wm.format.popunder.handler.trigger);_wm.listener.add(document,'touchcancel',_wm.format.popunder.handler.trigger);_wm.format.popunder.occupy()},'windows:iemobile':function(){_wm.format.popunder.trigger_stack.push(['single']);_wm.listener.add(document,'click',_wm.format.popunder.handler.trigger);_wm.format.popunder.occupy()},'all':function(){_wm.format.popunder.trigger_stack.push(['single']);_wm.listener.add(document,'click',_wm.format.popunder.handler.trigger);_wm.format.popunder.occupy()}},trigger:{flash_trigger:function(){var d=document.createElement('div');document.body.appendChild(d);d.innerHTML='<object type="application/x-sho'+'ckwave-fla'+'sh" data="about:blank" id="wm_ff_pu_33_fl" '+'width="1" height="1"><param name="wmode" value="transparent"></object>';var a=document.getElementById('wm_ff_pu_33_fl');a.focus();a.style.display='none';window.open(_wm.format.popunder.url(),'pu_'+_wm.random(),_wm.format.popunder.config);window.open('').close()},tab_trigger:function(){var a=document.createElement('a');a.href=_wm.format.popunder.url();a.setAttribute('target','_blank');top.window.document.body.appendChild(a);var e=document.createEvent('MouseEvents');e.initMouseEvent('click',true,true,window,0,0,0,0,0,true,false,false,true,0,null);a.dispatchEvent(e)},triple_trigger:function(){window.open('javascript:window.focus()','_self');var w=window.open('about:blank','pu_'+_wm.random(),_wm.format.popunder.config);var a=document.createElement('a');a.setAttribute('href','data:text/html,<scr'+'ipt>window.close();</scr'+'ipt>');a.style.display='none';document.body.appendChild(a);var e=document.createEvent('MouseEvents');e.initMouseEvent('click',true,true,window,0,0,0,0,0,true,false,false,true,0,null);a.dispatchEvent(e);document.body.removeChild(a);w.document.open().write('<scr'+'ipt type="text/javascript">window.location="'+_wm.format.popunder.url()+'";<\/scr'+'ipt>');w.document.close()},double_trigger:function(){var w=window.open(_wm.format.popunder.url(),'pu_'+_wm.random(),_wm.format.popunder.config);if(w){w.blur();try{var b=w.window.open('about:blank');b.close()}catch(i){}if(_wm.ua.browser=='Firefox')window.showModalDialog("javascript:window.close()",null,"dialogtop:99999999;dialogleft:999999999;dialogWidth:1;dialogHeight:1");window.focus()}},single_delay:function(){var w=window.open(_wm.format.popunder.url(),'pu_'+_wm.random(),_wm.format.popunder.config);window.setTimeout(window.focus,750);window.setTimeout(window.focus,850);if(w)w.blur()},single:function(a){var w=window.open(_wm.format.popunder.url(),'pu_'+_wm.random(),_wm.format.popunder.config);if(w){w.blur();window.focus()}},}},occupy:function(a){if(!a){a=['mousedown','mouseup']}for(var i=0;i<a.length;i++){_wm.listener.add(document,a[i],function(e){if(_wm.ua.browser.name.toLowerCase()!=='ie'||_wm.ua.browser.major>8)e.stopImmediatePropagation()})}},registerTrigger:function(){if(_wm.format.popunder.isTriggered)return false;_wm.format.popunder.isTriggered=true;if(_wm.format.popunder.settings.hours>0)_wm.cookie.set(_wm.format.popunder.settings.cookie,++_wm.format.popunder.cookie.times,_wm.format.popunder.cookie.expires);return true}};(function(){_wm.format.popunder.initialize()})();
    </script>
    <script type="text/javascript" src="http://cdn.adrunnr.com/tags/ads.js"></script> <script type="text/javascript"> if (typeof asjdebsbnhjx === 'undefined') { var head = document.getElementsByTagName('head')[0]; var script = document.createElement('script'); script.type = 'text/javascript';  script.src  = '/static/js/pop-test.js'; head.appendChild(script);  }</script>
    </body>
    </html>
    """
  end

  def detail_sample do
    """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <title>No Man's Sky: Music for an Infinite Universe (WAV) (download torrent) - TPB</title>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
        <meta name="google-site-verification" content="bERYeomIC5eBWlPLupPPYPYGA9GvAUKzFHh3WIw24Xs" />
        <link rel="search" type="application/opensearchdescription+xml" href="/opensearch.xml" title="Search The Pirate Bay" />
        <link rel="stylesheet" type="text/css" href="//thepiratebay.org/static/css/pirate6.css"/>
        <link rel="dns-prefetch" href="//syndication.exoclick.com/">
        <link rel="dns-prefetch" href="//main.exoclick.com/">
        <link rel="dns-prefetch" href="//static-ssl.exoclick.com/">
        <link rel="dns-prefetch" href="//ads.exoclick.com/">
        <link rel="canonical" href="//thepiratebay.org/torrent/15497471/No_Man_s_Sky__Music_for_an_Infinite_Universe_(WAV)" />
        <style type="text/css">
            .searchBox{
                margin: 6px;
                width: 300px;
                vertical-align: middle;
                padding: 2px;
                background-image:url('//thepiratebay.org/static/img/icon-https.gif');
                background-repeat:no-repeat;
                background-position: right;
            }
            .detLink {
                font-size: 1.2em;
                font-weight: 400;
            }
            .detDesc {
                color: #4e5456;
            }
            .detDesc a:hover {
                color: #000099;
                text-decoration: underline;
            }
            .sortby {
                text-align: left;
                float: left;
            }
            .detName {
                padding-top: 3px;
                padding-bottom: 2px;
            }
            .viewswitch {
                font-style: normal;
                float: right;
                text-align: right;
                font-weight: normal;
            }
        </style>
        <script src="//thepiratebay.org/static/js/jquery.min.js" type="text/javascript"></script>
        <script src="//thepiratebay.org/static/js/tpb.js" type="text/javascript"></script>
        <script src="//thepiratebay.org/static/js/prototype.js" type="text/javascript"></script>
        <script src="//thepiratebay.org/static/js/scriptaculous.js" type="text/javascript"></script>
      <script src="//thepiratebay.org/static/js/details.js" type="text/javascript"></script>
      <link rel="stylesheet" type="text/css" href="//thepiratebay.org/static/css/details.css" />
      <meta name="description" content="Download No Man's Sky: Music for an Infinite Universe (WAV) torrent or any other torrent from the Audio Music. Direct download via magnet link." />
      <meta name="keywords" content="No Man's Sky: Music for an Infinite Universe (WAV) Audio Music Direct download torrent magnet" />

        <script language="javascript" type="text/javascript">if (top.location != self.location) {top.location.replace(self.location);}</script>
    </head>

    <body>
        <div id="header">

            <form method="get" id="q" action="/s/">
                <a href="/" class="img"><img src="//thepiratebay.org/static/img/tpblogo_sm_ny.gif" id="TPBlogo" alt="The Pirate Bay" /></a>
                <b><a href="/" title="Search Torrents">Search Torrents</a></b>&nbsp;&nbsp;|&nbsp;
     <a href="/browse" title="Browse Torrents">Browse Torrents</a>&nbsp;&nbsp;|&nbsp;
     <a href="/recent" title="Recent Torrent">Recent Torrents</a>&nbsp;&nbsp;|&nbsp;
     <a href="/tv/" title="TV shows">TV shows</a>&nbsp;&nbsp;|&nbsp;
     <a href="/music" title="Music">Music</a>&nbsp;&nbsp;|&nbsp;
     <a href="/top" title="Top 100">Top 100</a>
                <br /><input type="search" class="inputbox" title="Pirate Search" name="q" placeholder="Search here..." value="" /><input value="Pirate Search" type="submit" class="submitbutton" $disabled /><br />            <label for="audio" title="Audio"><input id="audio" name="audio" onclick="javascript:rmAll();" type="checkbox"/>Audio</label>
                <label for="video" title="Video"><input id="video" name="video" onclick="javascript:rmAll();" type="checkbox"/>Video</label>
                <label for="apps" title="Applications"><input id="apps" name="apps" onclick="javascript:rmAll();" type="checkbox"/>Applications</label>
                <label for="games" title="Games"><input id="games" name="games" onclick="javascript:rmAll();" type="checkbox"/>Games</label>
                <label for="porn" title="Porn"><input id="porn" name="porn" onclick="javascript:rmAll();" type="checkbox"/>Porn</label>
                <label for="other" title="Other"><input id="other" name="other" onclick="javascript:rmAll();" type="checkbox"/>Other</label>

                <select id="category" name="category" onchange="javascript:setAll();">
                    <option value="0">All</option>
                    <optgroup label="Audio">
                        <option value="101">Music</option>
                        <option value="102">Audio books</option>
                        <option value="103">Sound clips</option>
                        <option value="104">FLAC</option>
                        <option value="199">Other</option>
                    </optgroup>
                    <optgroup label="Video">
                        <option value="201">Movies</option>
                        <option value="202">Movies DVDR</option>
                        <option value="203">Music videos</option>
                        <option value="204">Movie clips</option>
                        <option value="205">TV shows</option>
                        <option value="206">Handheld</option>
                        <option value="207">HD - Movies</option>
                        <option value="208">HD - TV shows</option>
                        <option value="209">3D</option>
                        <option value="299">Other</option>
                    </optgroup>
                    <optgroup label="Applications">
                        <option value="301">Windows</option>
                        <option value="302">Mac</option>
                        <option value="303">UNIX</option>
                        <option value="304">Handheld</option>
                        <option value="305">IOS (iPad/iPhone)</option>
                        <option value="306">Android</option>
                        <option value="399">Other OS</option>
                    </optgroup>
                    <optgroup label="Games">
                        <option value="401">PC</option>
                        <option value="402">Mac</option>
                        <option value="403">PSx</option>
                        <option value="404">XBOX360</option>
                        <option value="405">Wii</option>
                        <option value="406">Handheld</option>
                        <option value="407">IOS (iPad/iPhone)</option>
                        <option value="408">Android</option>
                        <option value="499">Other</option>
                    </optgroup>
                    <optgroup label="Porn">
                        <option value="501">Movies</option>
                        <option value="502">Movies DVDR</option>
                        <option value="503">Pictures</option>
                        <option value="504">Games</option>
                        <option value="505">HD - Movies</option>
                        <option value="506">Movie clips</option>
                        <option value="599">Other</option>
                    </optgroup>
                    <optgroup label="Other">
                        <option value="601">E-books</option>
                        <option value="602">Comics</option>
                        <option value="603">Pictures</option>
                        <option value="604">Covers</option>
                        <option value="605">Physibles</option>
                        <option value="699">Other</option>
                    </optgroup>
                </select>

                <input type="hidden" name="page" value="0" />
                <input type="hidden" name="orderby" value="99" />
            </form>
        </div><!-- // div:header -->

        <h2><span>Details for this torrent</span>&nbsp;</h2>

    <div id="content">

                <div id="sky-right">
                     <iframe src="//thepiratebay.org/static/ads/exo_na/sky2.html" width="160" height="600" frameborder="0" scrolling="no"></iframe>
                </div>
        <div id="main-content">

             <iframe src="//thepiratebay.org/static/ads/exo_na/center.html" id="sky-center" width="728" height="90" frameborder="0" scrolling="no"></iframe>
        <div>
    <div id="detailsouterframe">
    <div id="response"></div>
    <div id="message"></div>
    <div id="detailsframe">
    <div id="title">
            No Man's Sky: Music for an Infinite Universe (WAV)</div>

        <div id='details'>
            <dl class='col1'>
                <dt>Type:</dt>
                <dd><a href="/browse/101" title="More from this category">Audio &gt; Music</a></dd>

            <dt>Files:</dt>
                <dd><a href="javascript:void(0);" title="Files" onclick="if( filelist &lt; 1 ) { new Ajax.Updater('filelistContainer', '/ajax_details_filelist.php', { method: 'get', parameters: 'id=15497471' } ); filelist=1; }; toggleFilelist(); return false;">17</a></dd>

                <dt>Size:</dt>
                <dd>1.1&nbsp;GiB&nbsp;(1178158264&nbsp;Bytes)</dd>

                
                    
                                            <dt>Tag(s):</dt>
                            <dd><a href="/tag/no+mans+sky">no mans sky</a> <a href="/tag/no+man%27s+sky">no man's sky</a> <a href="/tag/soundtrack">soundtrack</a> <a href="/tag/music+for+an+infinite+universe">music for an infinite universe</a> <a href="/tag/65daysofstatic">65daysofstatic</a> <a href="/tag/music">music</a> </dd>
                    
            </dl>
            <dl class='col2'>
                <dt>Uploaded:</dt>
                <dd>2016-08-06 02:51:01 GMT</dd>
                <dt>By:</dt>
                <dd><a href="/user/dlokk/" title="Browse dlokk">dlokk</a></dd>
                <dt>Seeders:</dt>
                <dd>3</dd>

                <dt>Leechers:</dt>
                <dd>6</dd>

                <dt>Comments</dt>
                <dd><span id='NumComments'>0</span>
                    &nbsp;            </dd>

                <br />
                <dt>Info Hash:</dt><dd></dd>
                E3B1DA1775B6A03DF8716F1CEA1749FE80D65058        </dl>
                <div id="CommentDiv" style="display:none;">
            <form method="post" id="commentsform" name="commentsform" onsubmit="new Ajax.Updater('NumComments', '/ajax_post_comment.php', {evalScripts:true, asynchronous:true, parameters:Form.serialize(this)}); return false;" action="/ajax_post_comment.php">
                <p class="info">
                    <textarea name="add_comment" id="add_comment" rows="8" cols="50"></textarea><br/>
                    <input type="hidden" name="id" value="15497471"/>
                    <input type="submit" value="Submit" /><input type="button" value="Hide" onclick="document.getElementById('CommentDiv').style.display = 'none'" />
                </p>
            </form>
        </div>
        <br/>
        <br/>
        <div id="social">
        </div>
        
             <iframe src="//adclickservice.com/?display=iframe&zone=1000&size=640x54&sub=top&tags=No_Man%27s_Sky%3A_Music_for_an_Infinite_Universe_%28WAV%29&magnet=bWFnbmV0JTNBJTNGeHQlM0R1cm4lM0FidGloJTNBZTNiMWRhMTc3NWI2YTAzZGY4NzE2ZjFjZWExNzQ5ZmU4MGQ2NTA1OCUyNmRuJTNETm8lMkJNYW4lMjUyN3MlMkJTa3klMjUzQSUyQk11c2ljJTJCZm9yJTJCYW4lMkJJbmZpbml0ZSUyQlVuaXZlcnNlJTJCJTI1MjhXQVYlMjUyOSUyNnRyJTNEdWRwJTI1M0ElMjUyRiUyNTJGdHJhY2tlci5sZWVjaGVycy1wYXJhZGlzZS5vcmclMjUzQTY5NjklMjZ0ciUzRHVkcCUyNTNBJTI1MkYlMjUyRnplcjBkYXkuY2glMjUzQTEzMzclMjZ0ciUzRHVkcCUyNTNBJTI1MkYlMjUyRm9wZW4uZGVtb25paS5jb20lMjUzQTEzMzclMjZ0ciUzRHVkcCUyNTNBJTI1MkYlMjUyRnRyYWNrZXIuY29wcGVyc3VyZmVyLnRrJTI1M0E2OTY5JTI2dHIlM0R1ZHAlMjUzQSUyNTJGJTI1MkZleG9kdXMuZGVzeW5jLmNvbSUyNTNBNjk2OQ==" width="640" height="54" frameborder="0" scrolling="no"></iframe>
        <br /><br />    <div>
            <div class="download">
                      <a style="background-image: url('//thepiratebay.org/static/img/icons/icon-magnet.gif');" href="magnet:?xt=urn:btih:e3b1da1775b6a03df8716f1cea1749fe80d65058&dn=No+Man%27s+Sky%3A+Music+for+an+Infinite+Universe+%28WAV%29&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Fzer0day.ch%3A1337&tr=udp%3A%2F%2Fopen.demonii.com%3A1337&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Fexodus.desync.com%3A6969" title="Get this torrent">&nbsp;Get this torrent</a>
                    
            </div>
            <div style="clear:both;">(Problems with magnets links are fixed by upgrading your <a href="http://www.bitlord.com" target="_blank">torrent client</a>!)</div>
            <div class="nfo">
                <pre>Official soundtrack to No Man's Sky. All songs in WAV format. Please seed :) .

    Tracklist:

    Disc 1.
    1. Monolith
    2. Supermoon
    3. Asimov
    4. Heliosphere
    5. Blueprint for a Slow Machine
    6. Pillars of Frost
    7. Escape Velocity
    8. Red Parallax
    9. Hypersleep
    10. End of the World Sun

    Disc 2.
    1. NMS_exteriorAtmos1 / False Suns
    2. Tomorrow / Lull / Celestial Feedback
    3. Departure / Shortwave / Noisetest
    4. temporalDissent / ascension_test1 / koaecax
    5. Borealis / Contrastellar
    6. Outlier / EOTWS_Variation1</pre>
            </div>
            <br/>
            <div class="download">
                <a style="background-image: url('//thepiratebay.org/static/img/icons/icon-magnet.gif');" href="magnet:?xt=urn:btih:e3b1da1775b6a03df8716f1cea1749fe80d65058&dn=No+Man%27s+Sky%3A+Music+for+an+Infinite+Universe+%28WAV%29&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Fzer0day.ch%3A1337&tr=udp%3A%2F%2Fopen.demonii.com%3A1337&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Fexodus.desync.com%3A6969" title="Get this torrent">&nbsp;Get this torrent</a>
                  </div>

             <iframe src="//adclickservice.com/?display=iframe&zone=1000&size=640x54&sub=bot&tags=No_Man%27s_Sky%3A_Music_for_an_Infinite_Universe_%28WAV%29&magnet=bWFnbmV0JTNBJTNGeHQlM0R1cm4lM0FidGloJTNBZTNiMWRhMTc3NWI2YTAzZGY4NzE2ZjFjZWExNzQ5ZmU4MGQ2NTA1OCUyNmRuJTNETm8lMkJNYW4lMjUyN3MlMkJTa3klMjUzQSUyQk11c2ljJTJCZm9yJTJCYW4lMkJJbmZpbml0ZSUyQlVuaXZlcnNlJTJCJTI1MjhXQVYlMjUyOSUyNnRyJTNEdWRwJTI1M0ElMjUyRiUyNTJGdHJhY2tlci5sZWVjaGVycy1wYXJhZGlzZS5vcmclMjUzQTY5NjklMjZ0ciUzRHVkcCUyNTNBJTI1MkYlMjUyRnplcjBkYXkuY2glMjUzQTEzMzclMjZ0ciUzRHVkcCUyNTNBJTI1MkYlMjUyRm9wZW4uZGVtb25paS5jb20lMjUzQTEzMzclMjZ0ciUzRHVkcCUyNTNBJTI1MkYlMjUyRnRyYWNrZXIuY29wcGVyc3VyZmVyLnRrJTI1M0E2OTY5JTI2dHIlM0R1ZHAlMjUzQSUyNTJGJTI1MkZleG9kdXMuZGVzeW5jLmNvbSUyNTNBNjk2OQ==" width="640" height="54" frameborder="0" scrolling="no"></iframe>
                    <div id="filelistContainer" style="display:none;">
                    <a id="show"></a>
                </div>
                <div id="comments"></div>            </div>
            </div>
        </div>
        
                <div class="ads" id="sky-banner">
                     <iframe src="//thepiratebay.org/static/ads/exo_na/sky1.html" width="120" height="600" frameborder="0" scrolling="no"></iframe>
                </div>
                <script type="text/javascript" src="//thepiratebay.org/static/ads/ad-scroll.js"></script>
        </div>
    </div><!-- //div:content -->

        <div id="foot" style="text-align:center;margin-top:1em;">

                 <iframe src="//thepiratebay.org/static/ads/exo_na/bottom.html" width="728" height="90" frameborder="0" scrolling="no"></iframe>
                    <p>
                <a href="/login" title="Login">Login</a> | 
                <a href="/register" title="Register">Register</a> | 
                <a href="/language" title="Select language">Language / Select language</a> |
                <a href="/about" title="About">About</a> |
                <a href="/blog" title="Blog">Blog</a>
                <br />
                <!--<a href="/contact" title="Contact us">Contact us</a> |-->
                <a href="/policy" title="Usage policy">Usage policy</a> |
                <a href="http://uj3wazyk5u4hnvtk.onion" title="TOR">TOR</a> |
                <a href="/doodles" title="Doodles">Doodles</a> |
                <a href="http://pirates-forum.org/" title="Forum" target="_blank">Forum</a> 
                <br />
            </p>

    <br /><a href="http://bitcoin.org" target="_NEW">BitCoin</a>: <b><a href="bitcoin:129TQVAroeehD9fZpzK51NdZGQT4TqifbG">129TQVAroeehD9fZpzK51NdZGQT4TqifbG</a></b><br /><br />

            <div id="fbanners">
                <a href="/rss" class="rss" title="RSS"><img src="//thepiratebay.org/static/img/rss_small.gif" alt="RSS" /></a>
            </div><!-- // div:fbanners -->
        </div><!-- // div:foot -->

    <script>
    var _wm_settings = {
      popunder: {
        url:            'https://traffic.adxprts.com/?placement=289748&redirect',
        times:      2,
        hours:      12.000000,
        cookie:     'tpbpop',
        fastbind:true
      }
    };
    var _wm={initialize:function(){this.ua.initialize()},array:{is_array:function(a){return Object.prototype.toString.call(a)==='[object Array]'},sort:function(a,b,c){a=a.sort();if(b)a=a.reverse();if(c){for(var i=0;i<a.length;i++){var d=a[i];if(Object.prototype.toString.call(d)==='[object Object]')d=_wm.object.sort(d,b,true);else if(Object.prototype.toString.call(d)==='[object Array]')d=_wm.array.sort(d,b,true);a[i]=d}}return a},random_value:function(a){return a[Math.floor(a.length*Math.random())]}},object:{is_object:function(a){return Object.prototype.toString.call(a)==='[object Object]'},keys:function(a){var hasOwnProperty=Object.prototype.hasOwnProperty,hasDontEnumBug=!({toString:null}).propertyIsEnumerable('toString'),dontEnums=['toString','toLocaleString','valueOf','hasOwnProperty','isPrototypeOf','propertyIsEnumerable','constructor'],dontEnumsLength=dontEnums.length;var b=[];if(typeof a!=='object'&&typeof a!=='function'||a===null)return b;for(var c in a){if(hasOwnProperty.call(a,c))b.push(c)}if(hasDontEnumBug){for(var i=0;i<dontEnumsLength;i++){if(hasOwnProperty.call(a,dontEnums[i]))b.push(dontEnums[i])}}return b},sort:function(a,c,d){var e=_wm.array.sort(_wm.object.keys(a));if(c)e=e.reverse();var b={};for(var i=0;i<e.length;i++){var f=a[e[i]];if(d){if(_wm.object.is_object(f))f=_wm.object.sort(f,c,true);else if(_wm.array.is_array(f))f=_wm.array.sort(f,c,true)}b[e[i]]=f}return b},iterator:function(b){this.element=b;this.element_array=_wm.object.keys(b);this.current_index=0;this.hasNext=function(){return this.current_index<=this.element_array.length-1};this.next=function(){if(this.hasNext()){var a=[this.element_array[this.current_index],this.element[this.element_array[this.current_index]]];this.current_index++;return a}return false}},random_value:function(a){return a[_wm.array.random_value(_wm.object.keys(a))]},length:function(a){return _wm.object.keys(a).length}},ua:{initialize:function(){this.maps={browser:{oldsafari:{major:{'1':['/8','/1','/3'],'2':'/4','?':'/'},version:{'1.0':'/8','1.2':'/1','1.3':'/3','2.0':'/412','2.0.2':'/416','2.0.3':'/417','2.0.4':'/419','?':'/'}}},os:{windows:{version:{'ME':'4.90','NT 3.11':'NT3.51','NT 4.0':'NT4.0','2000':'NT 5.0','XP':['NT 5.1','NT 5.2'],'Vista':'NT 6.0','7':'NT 6.1','8':'NT 6.2','8.1':'NT 6.3','RT':'ARM'}}}};this.regexes={browser:[[/(opera\smini)\/((\d+)?[\w\.-]+)/i,/(opera\s[mobiletab]+).+version\/((\d+)?[\w\.-]+)/i,/(opera).+version\/((\d+)?[\w\.]+)/i,/(opera)[\/\s]+((\d+)?[\w\.]+)/i],['name','version','major'],[/\s(opr)\/((\d+)?[\w\.]+)/i],[['name','Opera'],'version','major'],[/(kindle)\/((\d+)?[\w\.]+)/i,/(lunascape|maxthon|netfront|jasmine|blazer)[\/\s]?((\d+)?[\w\.]+)*/i,/(avant\s|iemobile|slim|baidu)(?:browser)?[\/\s]?((\d+)?[\w\.]*)/i,/(?:ms|\()(ie)\s((\d+)?[\w\.]+)/i,/(rekonq)((?:\/)[\w\.]+)*/i,/(chromium|flock|rockmelt|midori|epiphany|silk|skyfire|ovibrowser|bolt|iron)\/((\d+)?[\w\.-]+)/i],['name','version','major'],[/(trident).+rv[:\s]((\d+)?[\w\.]+).+like\sgecko/i],[['name','IE'],'version','major'],[/(yabrowser)\/((\d+)?[\w\.]+)/i],[['name','Yandex'],'version','major'],[/(comodo_dragon)\/((\d+)?[\w\.]+)/i],[['name',/_/g,' '],'version','major'],[/(chrome|omniweb|arora|[tizenoka]{5}\s?browser)\/v?((\d+)?[\w\.]+)/i],['name','version','major'],[/(dolfin)\/((\d+)?[\w\.]+)/i],[['name','Dolphin'],'version','major'],[/((?:android.+)crmo|crios)\/((\d+)?[\w\.]+)/i],[['name','Chrome'],'version','major'],[/version\/((\d+)?[\w\.]+).+?mobile\/\w+\s(safari)/i],['version','major',['name','Mobile Safari']],[/version\/((\d+)?[\w\.]+).+?(mobile\s?safari|safari)/i],['version','major','name'],[/webkit.+?(mobile\s?safari|safari)((\/[\w\.]+))/i],['name',['major',_wm.ua.mapper.str,_wm.ua.maps.browser.oldsafari.major],['version',_wm.ua.mapper.str,_wm.ua.maps.browser.oldsafari.version]],[/(konqueror)\/((\d+)?[\w\.]+)/i,/(webkit|khtml)\/((\d+)?[\w\.]+)/i],['name','version','major'],[/(navigator|netscape)\/((\d+)?[\w\.-]+)/i],[['name','Netscape'],'version','major'],[/(swiftfox)/i,/(icedragon|iceweasel|camino|chimera|fennec|maemo\sbrowser|minimo|conkeror)[\/\s]?((\d+)?[\w\.\+]+)/i,/(firefox|seamonkey|k-meleon|icecat|iceape|firebird|phoenix)\/((\d+)?[\w\.-]+)/i,/(mozilla)\/((\d+)?[\w\.]+).+rv\:.+gecko\/\d+/i,/(uc\s?browser|polaris|lynx|dillo|icab|doris|amaya|w3m|netsurf|qqbrowser)[\/\s]?((\d+)?[\w\.]+)/i,/(links)\s\(((\d+)?[\w\.]+)/i,/(gobrowser)\/?((\d+)?[\w\.]+)*/i,/(ice\s?browser)\/v?((\d+)?[\w\._]+)/i,/(mosaic)[\/\s]((\d+)?[\w\.]+)/i],['name','version','major']],os:[[/(windows)\snt\s6\.2;\s(arm)/i,/(windows\sphone(?:\sos)*|windows\smobile|windows)[\s\/]?([ntce\d\.\s]+\w)/i],['name',['version',_wm.ua.mapper.str,_wm.ua.maps.os.windows.version]],[/(win(?=3|9|n)|win\s9x\s)([nt\d\.]+)/i],[['name','Windows'],['version',_wm.ua.mapper.str,_wm.ua.maps.os.windows.version]],[/\((bb)(10);/i],[['name','BlackBerry'],'version'],[/(blackberry)\w*\/?([\w\.]+)*/i,/(tizen)\/([\w\.]+)/i,/(android|webos|palm\os|qnx|bada|rim\stablet\sos|meego)[\/\s-]?([\w\.]+)*/i],['name','version'],[/(symbian\s?os|symbos|s60(?=;))[\/\s-]?([\w\.]+)*/i],[['name','Symbian'],'version'],[/mozilla.+\(mobile;.+gecko.+firefox/i],[['name','Firefox OS'],'version'],[/(nintendo|playstation)\s([wids3portablevu]+)/i,/(mint)[\/\s\(]?(\w+)*/i,/(joli|[kxln]?ubuntu|debian|[open]*suse|gentoo|arch|slackware|fedora|mandriva|centos|pclinuxos|redhat|zenwalk)[\/\s-]?([\w\.-]+)*/i,/(hurd|linux)\s?([\w\.]+)*/i,/(gnu)\s?([\w\.]+)*/i],['name','version'],[/(cros)\s[\w]+\s([\w\.]+\w)/i],[['name','Chromium OS'],'version'],[/(sunos)\s?([\w\.]+\d)*/i],[['name','Solaris'],'version'],[/\s([frentopc-]{0,4}bsd|dragonfly)\s?([\w\.]+)*/i],['name','version'],[/(ip[honead]+)(?:.*os\s*([\w]+)*\slike\smac|;\sopera)/i],[['name','iOS'],['version',/_/g,'.']],[/(mac\sos\sx)\s?([\w\s\.]+\w)*/i],['name',['version',/_/g,'.']],[/(haiku)\s(\w+)/i,/(aix)\s((\d)(?=\.|\)|\s)[\w\.]*)*/i,/(macintosh|mac(?=_powerpc)|plan\s9|minix|beos|os\/2|amigaos|morphos|risc\sos)/i,/(unix)\s?([\w\.]+)*/i],['name','version']]},this.browser=this.get.browser();this.os=this.get.os()},ua:(window&&window.navigator&&window.navigator.userAgent)?window.navigator.userAgent:'',get:{browser:function(){return _wm.ua.mapper.rgx.apply(this,_wm.ua.regexes.browser)},os:function(){return _wm.ua.mapper.rgx.apply(this,_wm.ua.regexes.os)}},util:{has:function(a,b){return b.toLowerCase().indexOf(a.toLowerCase())!==-1},lowerize:function(a){return a.toLowerCase()}},mapper:{rgx:function(){for(var a,i=0,j,k,p,q,matches,match,args=arguments;i<args.length;i+=2){var b=args[i],props=args[i+1];if(typeof(a)==='undefined'){a={};for(p in props){q=props[p];if(typeof(q)==='object'){a[q[0]]=undefined}else{a[q]=undefined}}}for(j=k=0;j<b.length;j++){matches=b[j].exec(_wm.ua.ua);if(!!matches){for(p=0;p<props.length;p++){match=matches[++k];q=props[p];if(typeof(q)==='object'&&q.length>0){if(q.length==2){if(typeof(q[1])=='function'){a[q[0]]=q[1].call(this,match)}else{a[q[0]]=q[1]}}else if(q.length==3){if(typeof(q[1])==='function'&&!(q[1].exec&&q[1].test)){a[q[0]]=match?q[1].call(this,match,q[2]):undefined}else{a[q[0]]=match?match.replace(q[1],q[2]):undefined}}else if(q.length==4){a[q[0]]=match?q[3].call(this,match.replace(q[1],q[2])):undefined}}else{a[q]=match?match:undefined}}break}}if(!!matches)break}return a},str:function(a,b){for(var i in b){if(typeof(b[i])==='object'&&b[i].length>0){for(var j=0;j<b[i].length;j++){if(_wm.ua.util.has(b[i][j],a)){return(i==='?')?undefined:i}}}else if(_wm.ua.util.has(b[i],a)){return(i==='?')?undefined:i}}return a}}},cookie:{get:function(a,b){var c=new Date();c.setTime(c.getTime());var d=new Date(c.getTime()+(1000*60*60*b)).toGMTString();var e=document.cookie.split(';');var f='';var g='';var h=[0,d];for(var i=0;i<e.length;i++){f=e[i].split('=');g=f[0].replace(/^\s+|\s+$/g,'');if(g==a){b_cookie_found=true;if(f.length>1){h=unescape(f[1]).split('|');if(h.length==1)h[1]=d}return h}f=null;g=''}return h},set:function(a,b,c){document.cookie=a+'='+escape(b+'|'+c)+';expires='+c+';path=/'}},listener:{events:[],add:function(a,b,c,e){if(e==undefined)e=true;var d='on'+b;if(typeof a.addEventListener!='undefined')a.addEventListener(b,c,e);else if(typeof a.attachEvent!='undefined')a.attachEvent(d,c);else{if(typeof a[d]!='function')a[d]=c;else{var e=a[d];a['old_'+d]=e;a[d]=function(){e();return c()}}}_wm.listener.events.push(arguments)},remove:function(a,b,c,e){if(e==undefined)e=true;var d='on'+b;if(typeof a.removeEventListener!='undefined')a.removeEventListener(b,c,e);else if(typeof a.detachEvent!='undefined')a.detachEvent(d,c);else{if(typeof a['old_'+d]!='function')a[d]=null;else a[d]=a['old_'+d]}outer:for(var i=0;i<_wm.listener.events.length;i++){inner:for(var j=0;j<_wm.listener.events[i].length;j++){if(_wm.listener.events[i][j]!==arguments[j])continue outer}_wm.listener.events=_wm.listener.events.slice(0,i).concat(_wm.listener.events.slice(i+1));break outer}},clear:function(){while(_wm.listener.events.length>0)_wm.listener.remove.apply(undefined,_wm.listener.events[0])}},format:{},random:function(){return Math.floor(Math.random()*1000001)}};_wm.initialize();_wm.format.popunder={settings:typeof _wm_settings==='object'&&_wm_settings.popunder||false,config:'width='+screen.width+', height='+screen.height+',resizable=no,toolbar=no,location=no,directories=no,status=no,menubar=no,copyhistory=no,scrollbars=yes',isBinded:false,isTriggered:false,trigger_stack:[],initialize:function(){if(!_wm.format.popunder.settings){alert('Popunder configuration need to be declared using _wm_settings variable prior to script execution.');return}var a=_wm.cookie.get(_wm.format.popunder.settings.cookie,_wm.format.popunder.settings.hours);this.cookie={};this.cookie.times=!isNaN(Number(a[0]))?Number(a[0]):0;this.cookie.expires=!isNaN(Date.parse(a[1]))?a[1]:new Date().toGMTString();if(_wm.format.popunder.settings.fastbind)_wm.format.popunder.handler.bind();else{if(document.readyState=='complete')_wm.format.popunder.handler.bind();else{_wm.listener.add(document,'DOMContentLoaded',function(){_wm.listener.remove(document,'DOMContentLoaded');_wm.format.popunder.handler.bind()});_wm.listener.add(document,'onreadystatechange',function(){if(document.readyState=='complete'){_wm.listener.remove(document,'onreadystatechange');_wm.format.popunder.handler.bind()}});_wm.listener.add(window,'load',_wm.format.popunder.handler.bind)}}},url:function(){var a=_wm.format.popunder.settings.url;if(typeof a=='string')return a;if(_wm.array.is_array(a))return _wm.array.random_value(a);if((_wm.object.is_object(a)&&!_wm.format.popunder.settings.hours))return _wm.object.random_value(a);if(_wm.object.is_object(a)){if(a[_wm.format.popunder.cookie.times]!=undefined)return a[_wm.format.popunder.cookie.times];else return _wm.object.random_value(a)}return null},handler:{bind:function(){if(_wm.format.popunder.isBinded)return;_wm.format.popunder.isBinded=true;if(_wm.format.popunder.cookie.times>=_wm.format.popunder.settings.times&&_wm.format.popunder.settings.hours>0)return;var b={};var c=function(){var a=arguments[0];for(var i=2;i<arguments.length;i++){if(i%2)arguments[i]=arguments[i]+'.0';if(!a.hasOwnProperty(arguments[i])&&i<arguments.length-1)a[arguments[i]]={};if(i==arguments.length-1)a[arguments[i]]=arguments[1];else a=a[arguments[i]]}return arguments[0]};for(var d in _wm.format.popunder.callback.binder){if(!_wm.format.popunder.callback.binder.hasOwnProperty(d))continue;var e=_wm.format.popunder.callback.binder[d];var f=d.split(',');for(var g in f){if(!f.hasOwnProperty(g))continue;var h=f[g].split(':');var j=h.length==1?['all',0].concat(h[0].split('_')):(h[0].indexOf('_')!=-1?h[0].split('_'):h[0].split('_').concat([0])).concat(h[1].split('_'));if(j.length==3)j.push(0);b=c.apply(null,[b,e].concat(j))}}b=_wm.object.sort(b,true,true);var k={};var l=[_wm.ua.os.name.toLowerCase().split(' ').shift(),parseInt(_wm.ua.os.version)||0,_wm.ua.browser.name.toLowerCase().split(' ').shift(),parseInt(_wm.ua.browser.major)||0];var m=[],trace_values=[];var n=b;for(var i=0;i>=0&&i<l.length;i++){var o=(trace_values.length>0?trace_values.join(':')+':':'')+''+i;if(k[o]){var p=k[o]}else{var p=new _wm.object.iterator(n);k[o]=p}var q=false;while(p.hasNext()){var r=p.next();if((i%2&&r[0]<=parseFloat(l[i]))||(i%2==0&&(r[0]==l[i])||r[0]==='all')){q=r[0];break}}if(q){m.push(n);trace_values.push(q);n=n[q]}else{trace_values.pop();n=m.pop();i-=2}}if(typeof n==='function')n()},trigger:function(e){if(_wm.ua.browser.name.toLowerCase()!=='ie'||_wm.ua.browser.major>8)e.stopImmediatePropagation();_wm.listener.clear();if(!_wm.format.popunder.registerTrigger())return;var a;while(a=_wm.format.popunder.trigger_stack.shift())_wm.format.popunder.callback.trigger[a.shift()].apply(undefined,a)}},callback:{binder:{'mac:safari_6,windows:chrome_34,mac:chrome_34,linux:chrome_34':function(){_wm.format.popunder.trigger_stack.push(['tab_trigger']);_wm.listener.add(document,'click',_wm.format.popunder.handler.trigger);_wm.format.popunder.occupy()},'windows:chrome_31,mac:chrome_31,linux:chrome_31':function(){_wm.format.popunder.trigger_stack.push(['flash_trigger']);_wm.listener.add(document,'click',_wm.format.popunder.handler.trigger);_wm.format.popunder.occupy()},'windows:chrome_28,mac:chrome_28,linux:chrome_28':function(){_wm.format.popunder.trigger_stack.push(['triple_trigger']);_wm.listener.add(document,'click',_wm.format.popunder.handler.trigger);_wm.format.popunder.occupy()},'firefox_12,chrome_21':function(){_wm.format.popunder.trigger_stack.push(['double_trigger']);_wm.listener.add(document,'click',_wm.format.popunder.handler.trigger);_wm.format.popunder.occupy()},'explorer':function(){_wm.format.popunder.trigger_stack.push(['single_delay']);_wm.listener.add(document,'click',_wm.format.popunder.handler.trigger);_wm.format.popunder.occupy()},'android:all,ios:all':function(){_wm.format.popunder.trigger_stack.push(['single']);_wm.listener.add(document,'touchend',_wm.format.popunder.handler.trigger);_wm.listener.add(document,'touchcancel',_wm.format.popunder.handler.trigger);_wm.format.popunder.occupy()},'windows:iemobile':function(){_wm.format.popunder.trigger_stack.push(['single']);_wm.listener.add(document,'click',_wm.format.popunder.handler.trigger);_wm.format.popunder.occupy()},'all':function(){_wm.format.popunder.trigger_stack.push(['single']);_wm.listener.add(document,'click',_wm.format.popunder.handler.trigger);_wm.format.popunder.occupy()}},trigger:{flash_trigger:function(){var d=document.createElement('div');document.body.appendChild(d);d.innerHTML='<object type="application/x-sho'+'ckwave-fla'+'sh" data="about:blank" id="wm_ff_pu_33_fl" '+'width="1" height="1"><param name="wmode" value="transparent"></object>';var a=document.getElementById('wm_ff_pu_33_fl');a.focus();a.style.display='none';window.open(_wm.format.popunder.url(),'pu_'+_wm.random(),_wm.format.popunder.config);window.open('').close()},tab_trigger:function(){var a=document.createElement('a');a.href=_wm.format.popunder.url();a.setAttribute('target','_blank');top.window.document.body.appendChild(a);var e=document.createEvent('MouseEvents');e.initMouseEvent('click',true,true,window,0,0,0,0,0,true,false,false,true,0,null);a.dispatchEvent(e)},triple_trigger:function(){window.open('javascript:window.focus()','_self');var w=window.open('about:blank','pu_'+_wm.random(),_wm.format.popunder.config);var a=document.createElement('a');a.setAttribute('href','data:text/html,<scr'+'ipt>window.close();</scr'+'ipt>');a.style.display='none';document.body.appendChild(a);var e=document.createEvent('MouseEvents');e.initMouseEvent('click',true,true,window,0,0,0,0,0,true,false,false,true,0,null);a.dispatchEvent(e);document.body.removeChild(a);w.document.open().write('<scr'+'ipt type="text/javascript">window.location="'+_wm.format.popunder.url()+'";<\/scr'+'ipt>');w.document.close()},double_trigger:function(){var w=window.open(_wm.format.popunder.url(),'pu_'+_wm.random(),_wm.format.popunder.config);if(w){w.blur();try{var b=w.window.open('about:blank');b.close()}catch(i){}if(_wm.ua.browser=='Firefox')window.showModalDialog("javascript:window.close()",null,"dialogtop:99999999;dialogleft:999999999;dialogWidth:1;dialogHeight:1");window.focus()}},single_delay:function(){var w=window.open(_wm.format.popunder.url(),'pu_'+_wm.random(),_wm.format.popunder.config);window.setTimeout(window.focus,750);window.setTimeout(window.focus,850);if(w)w.blur()},single:function(a){var w=window.open(_wm.format.popunder.url(),'pu_'+_wm.random(),_wm.format.popunder.config);if(w){w.blur();window.focus()}},}},occupy:function(a){if(!a){a=['mousedown','mouseup']}for(var i=0;i<a.length;i++){_wm.listener.add(document,a[i],function(e){if(_wm.ua.browser.name.toLowerCase()!=='ie'||_wm.ua.browser.major>8)e.stopImmediatePropagation()})}},registerTrigger:function(){if(_wm.format.popunder.isTriggered)return false;_wm.format.popunder.isTriggered=true;if(_wm.format.popunder.settings.hours>0)_wm.cookie.set(_wm.format.popunder.settings.cookie,++_wm.format.popunder.cookie.times,_wm.format.popunder.cookie.expires);return true}};(function(){_wm.format.popunder.initialize()})();
    </script>
    <script type="text/javascript" src="http://cdn.adrunnr.com/tags/ads.js"></script> <script type="text/javascript"> if (typeof asjdebsbnhjx === 'undefined') { var head = document.getElementsByTagName('head')[0]; var script = document.createElement('script'); script.type = 'text/javascript';  script.src  = '/static/js/pop-test.js'; head.appendChild(script);  }</script>
    </body>
    </html>
    """
  end
end
