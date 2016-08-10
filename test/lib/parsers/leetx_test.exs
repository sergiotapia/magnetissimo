defmodule Magnetissimo.Parsers.LeetxTest do
  use ExUnit.Case, async: true

  test "has correct list of root urls" do
    assert Enum.count(Magnetissimo.Parsers.Leetx.root_urls) == 11
  end

  test "finds links to torrent details page" do
    links = Magnetissimo.Parsers.Leetx.torrent_links(list_sample)
    assert Enum.count(links) == 20
  end

  test "finds paginated links from list page" do
    page_links = Magnetissimo.Parsers.Leetx.paginated_links(list_sample)
    assert Enum.count(page_links) == 51
  end

  test "scrapes torrent information from detail page" do
    torrent = Magnetissimo.Parsers.Leetx.scrape_torrent_information(detail_sample)
    assert torrent != nil
  end

  def detail_sample do
    """
    <!DOCTYPE html>
    <html lang="en">
        <head>
            <meta charset="utf-8">
            <title>Download Torrent The Settlers 7: Paths to a Kingdom. Deluxe Gold Edition (2011) PC | RePack by z10yded| 1337x</title>
            <script type="text/javascript">
    //<![CDATA[
    try{if (!window.CloudFlare) {var CloudFlare=[{verbose:0,p:0,byc:0,owlid:"cf",bag2:1,mirage2:0,oracle:0,paths:{cloudflare:"/cdn-cgi/nexp/dok3v=1613a3a185/"},atok:"c00dd578bc366089708a73fbf0897ffc",petok:"864033d69ab7c9e21dfd5284095017586babab31-1470806992-1800",adblock:1,betok:"d33b2750a69a6663b28d22dc95758dd97db2fd44-1470806992-120",zone:"1337x.to",rocket:"0",apps:{},sha2test:0}];!function(a,b){a=document.createElement("script"),b=document.getElementsByTagName("script")[0],a.async=!0,a.src="//ajax.cloudflare.com/cdn-cgi/nexp/dok3v=0489c402f5/cloudflare.min.js",b.parentNode.insertBefore(a,b)}()}}catch(e){};
    //]]>
    </script>
    <link rel="shortcut icon" href="/favicon.ico" />
            <link rel="stylesheet" href="/assets/fonts/font.css"   media="screen" />
            <link rel="stylesheet" href="/assets/css/global_ssl.css"   media="screen" />
            <link rel="stylesheet" href="/assets/css/style.css"    media="screen" />
            <link rel="stylesheet" href="/assets/css/jquery-ui.css" media="screen">
            <script src="/assets/js/jquery.js" type="text/javascript"></script>
            <link rel="stylesheet" href="/assets/css/pagination.css"    media="screen" />
            <script src="/assets/js/comment.js" type="text/javascript"></script>      
            <script src="/assets/js/jquery.pagination.js" type="text/javascript"></script>


            <!--[if lt IE 9]>
            <script src="/assets/js/html5.js" type="text/javascript" ></script>
            <![endif]-->
        </head>

        <body>
            <div class="wrapper">
                <header>
                    <div class="primary-header">
                        <div class="page">
                            <ul>
                                <li>
                                    <a href="/register">register</a>
                                </li>
                                <li class="active">
                                    <a href="/login">login</a>
                                </li>
                                
                            </ul>
                        </div>
                    </div>
                    <div class="secondary-header">
                        <div class="page clearfix">
                            <a href="/" class="logo"><img src="/assets/images/logo.png" alt="logo" /></a>
                            <div class="search-box">
                                <form action="/srch" method="get" id="search-form">
                                <input type="text" name="search" id="autocomplete" value="Search for torrents.." onfocus="if(this.value=='Search for torrents..')this.value=''" onblur="if(this.value=='')this.value='Search for torrents..'"   />
                                <input type="submit" value="SEARCH" />
                                </form>
                            </div>

                            <nav>
                                <ul>
                                    <li>
                                        <a href="/">home</a>
                                    </li>
                                    <li>
                                        <a href="/upload">upload</a>
                                    </li>
                                    <li >
                                        <a href="/rules">rules</a>
                                    </li>
                                    <li >
                                        <a href="/contact">contact</a>
                                    </li>
                                    <li >
                                        <a href="/about">about us</a>
                                    </li>
                                    <li class="last ">
                                        <a href="/donate">donate</a>
                                    </li>
                                </ul>
                            </nav>

                        </div>
                    </div>

                </header><script>
    function count(t){return $.ajax({async:!1,type:"POST",url:"/dltrack/1708247/",data:{dst:t.href,src:document.location.href,torid:"1708247"}}).always(function(){window.location.href=t.href}),!1}
    var members;
    $(window).load(function() {
      //  var url = "comment-data.json";
          var url = "../../../api/comments-json.php?torid=1708247" ;
        $.getJSON(url, function(result) {
            //console.log(result);
            members = result;
            buildComment(result);

        });
    });
    </script>
    <style>
    .btn.btn-bbafbbfd{background-color:#00ceed;border-color:#52e8ff;box-shadow:0 4px 0 #10889a}.btn.btn-bbafbbfd:hover{background-color:#00b2cd}.category-detail .download-links a.bbafbbfd{background:#00ceed}.btn.btn-aaeafbfe{background-color:#e00000;border-color:#ff8e8e;box-shadow:0 4px 0 #900}.btn.btn-aaeafbfe:hover{background-color:#ca0000}.category-detail .download-links a.aaeafbfe{background:#e00000}
    </style>
                <div class="content">
                    <div class="page clearfix">

                        <div class="main-content">

                            <div class="domain-box inner clearfix">
                                <div class="top-row clearfix">
                                    <strong>The Settlers 7: Paths to a Kingdom. Deluxe Gold Edition (2011) PC...</strong>
                                                                    
                                    <a href="/report/1708247/"><button class="btn-rep"><img src="/assets/images/report.png"> <b>Report Torrent<b></button></a>
                                </div>

                                <div class="category-detail">

                                    <ul class="list">
                                        <li>
                                            <strong>Category</strong>
                                            <span>Games</span>
                                        </li>
                                        <li>
                                            <strong>Type</strong>
                                            <span>PC Game</span>
                                        </li>
                                        <li>
                                            <strong>Language</strong>
                                            <span>English</span>
                                        </li>
                                        <li>
                                            <strong>Total size</strong>
                                            <span>5.53 GB</span>
                                        </li>
                                        <li>
                                            <strong>Uploaded By</strong>
                                            <span><small class="trial-uploader"></small> <a href="/user/Dante69/">Dante69</a></span>
                                        </li>
                                    </ul>

                                    <ul class="list">
                                        <li>
                                            <strong>Downloads</strong>
                                            <span>11</span>
                                        </li>
                                        <li>
                                            <strong>Last checked</strong>
                                            <span>14 minutes ago</span>
                                        </li>
                                        <li>
                                            <strong>Date uploaded</strong>
                                            <span>5 hours ago</span>
                                        </li>
                                        <li>
                                            <strong>Seeders</strong>
                                            <span class="green">29</span>
                                        </li>
                                        <li>
                                            <strong>Leechers</strong>
                                            <span class="red">0</span>
                                        </li>
                                    </ul>
                                                                        <ul class="download-links">
                                        <li>
                                            <a id="magnetdl" href="magnet:?xt=urn:btih:7600F6F57EE08B4E560C907CF43B24727856249C&dn=The+Settlers+7%3A+Paths+to+a+Kingdom.+Deluxe+Gold+Edition+%282011%29+PC+%7C+RePack+by+z10yded&tr=udp%3A%2F%2Ftracker.ccc.de%3A80&tr=udp%3A%2F%2Ftracker.istole.it%3A80&tr=http%3A%2F%2Ftracker.publicbt.com0%2Fannounce&tr=udp%3A%2F%2Ftracker.openbittorrent.com%3A80&tr=http%3A%2F%2Fretracker.local%2Fannounce&tr=udp%3A%2F%2Ftracker.openbittorrent.com%3A80%2Fannounce&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969%2Fannounce&tr=udp%3A%2F%2Fcoppersurfer.tk%3A6969%2Fannounce" onclick="javascript:return count(this);" class="magnet"><i class="icon-magnet-download"></i>Magnet Download</a>
                                        </li>
                                        <li style="margin-top:0px;"></li>
    <li style="margin-top:0px;"></li>
                                        <li>
                                        <a id="torrentdl" onclick="javascript:return count(this);" href="http://itorrents.org/torrent/7600F6F57EE08B4E560C907CF43B24727856249C.torrent" onclick="javascript:return count(this);" class="torrent"><i class="icon-torrent-download"></i>Torrent Download</a>                                    </li>
                                        <li style="margin-top:0px;"></li>
    <li style="margin-top:0px;"></li>
                                        <li>
                                            <a id="bbafbbfd" href="bbafbbfd" class="bbafbbfd"><i class="icon-direct-download"></i>Direct Download</a>
                                        </li>
                                        <li style="margin-top:0px;"></li>
    <li style="margin-top:0px;"></li>
                                    </ul>

                                </div>
    <script type="text/javascript">document.getElementById("bbafbbfd").onclick=function(){return location.href="/mirror2-The+Settlers+7%3A+Paths+to+a+Kingdom.+Deluxe+Gold+Edition+%282011%29+PC+%7C+RePack+by+z10yded",!1};</script>
    <script type="text/javascript">document.getElementById("aaeafbfe").onclick=function(){return location.href="/stream/1708247/The-Settlers-7-Paths-to-a-Kingdom-Deluxe-Gold-Edition-2011-PC-RePack-by-z10yded/",!1};</script>

                                
     


                               <div class="infohash-box">
                                    <p>
                                        <strong>Infohash</strong> : 7600F6F57EE08B4E560C907CF43B24727856249C                                </p>
                                </div>
                            </div>
                            <div class="comment-container tab-container">                    
                  <div class="menu-row">
                                    <ul class="clearfix">
                                        <li>
                                            <a href="#">Description</a>
                                        </li>
                                        <li>
                                            <a href="#">Files</a>
                                        </li>
                                        <li class="active comment-tab">
                                            <a href="#">Comments <span>0</span> </a>
                                        </li>
                                        <li>
                                            <a href="#">Tracker List</a>
                                        </li>
                                    </ul>
                                </div>

                                <div class="tab-content">

                                    <div id="tab-1"> 
                                    
                                        <div class="description-padding">
                                          <span class="bbcode-text">
                                         <img class="descrimg" src="http://allbesta.net/_ld/102/05474406.jpg"/>
    <br/><br/>Year: 2011
    <br/>Genre: Strategy (Real-time), 3D
    <br/>Developer: Blue Byte Software
    <br/>Publisher: New Disk
    <br/>Game Version: 1.12.1396.0
    <br/>Publishing Type: RePack
    <br/><br/>System Requirements:
    <br/>√ Operating system: Windows XP, Vista, 7
    <br/>√ Processor: Intel Core 2 Duo 2.8 GHz, AMD Athlon X2 5200+
    <br/>√ RAM: 1 GB (XP) / 2 GB (Vista / 7)
    <br/>√ Video Card: Nvidia Geforce 7800 or Radeon H1900
    <br/>√ Sound Card: DirectX 9.0c compatible
    <br/>√ Free hard drive space: 6 GB
    <br/><br/>Description:
    <br/>There has come the age of great discoveries and battles for the redivision of the world. Each of the great leaders, generals, kings dreaming of new conquests. Lead your country, expand its influence, acquires new technology. The development of the country - that's the best way to win! &quot;The right to the throne&quot; - the continuation of the famous series Settlers and at the same time a completely new game. She kept everything so loved by many fans, but it is ready to present many surprises. The unique state of the system will allow you to combine military power trading operations and the effect of monasteries. You will be able to choose their own, unique style of rule the kingdom! And if the battle with the computer opponent does not inspire you, welcome to online, where you will meet the best strategists from around the world.
    <br/><img class="descrimg" src="http://fotos.subefotos.com/961e6c3a0bb66a6081495673420a3e1ao.jpg"/>
    <br/><br/><br/>Features:
    <br/>It is a new game of the famous series: incredible beauty and amazing attention to detail
    <br/>Unique Development and Construction: top country, expand the boundaries, reach new heights
    <br/>Military power, the development of science, trade agreements, select one of three ways, and he will lead you to victory
    <br/>The online battles with friends - up to five members at the same time!
    <br/><br/>                                     &nbsp;<br>
                                          </span>
                                        </div>

                                    </div>

                                    <div id="tab-2">

                                        <div class="file-container">
                                            <h2>Files :</h2>
                                            <span class="head"><i class="icon-folder"></i>Redistributables</span>
    <span class="head"><i class="icon-folder"></i>DirectX</span>
    <ul>
    <li><i class="icon-files-other"></i>APR2007_xinput_x86.cab (52.05 KB)</li>
    <li><i class="icon-files-other"></i>Aug2009_d3dx9_42_x86.cab (711.38 KB)</li>
    <li><i class="icon-files-other"></i>dsetup.dll (45.34 KB)</li>
    <li><i class="icon-files-other"></i>dsetup32.dll (165.34 KB)</li>
    <li><i class="icon-files-other"></i>dxdllreg_x86.cab (41.42 KB)</li>
    <li><i class="icon-files-exe"></i>dxsetup.exe (141.84 KB)</li>
    <li><i class="icon-files-other"></i>dxupdate.cab (91.81 KB)</li>
    <li><i class="icon-files-other"></i>Jun2010_D3DCompiler_43_x86.cab (909.64 KB)</li>
    <li><i class="icon-files-other"></i>Jun2010_d3dx9_43_x86.cab (750.04 KB)</li>
    </ul>
    <ul>
    <li><i class="icon-files-exe"></i>vcredist_x86_08_sp1.exe (4.02 MB)</li>
    <li><i class="icon-files-exe"></i>WindowsInstaller-KB893803-v2-x86.exe (2.47 MB)</li>
    <ul><li><i class="icon-files-other"></i>Autorun.inf (0.08 KB)</li></ul>
    <ul><li><i class="icon-files-other"></i>data-a.bin (1.52 GB)</li></ul>
    <ul><li><i class="icon-files-other"></i>data-b.bin (2.47 GB)</li></ul>
    <ul><li><i class="icon-files-other"></i>data-c.bin (1.30 GB)</li></ul>
    <ul><li><i class="icon-files-other"></i>data-d.bin (46.01 MB)</li></ul>
    <ul><li><i class="icon-files-other"></i>data-en.bin (92.63 MB)</li></ul>
    <ul><li><i class="icon-files-other"></i>data-ru.bin (98.91 MB)</li></ul>
    <ul><li><i class="icon-files-other"></i>Icon.ico (128.71 KB)</li></ul>
    <ul><li><i class="icon-files-other"></i>setup.dat (1.03 MB)</li></ul>
    <ul><li><i class="icon-files-exe"></i>setup.exe (3.28 MB)</li></ul>
    <ul><li><i class="icon-files-txt"></i>Разбивка_на_диски.txt (0.16 KB)</li></ul>

                                        </div>

                                    </div>

                                    <div id="tab-3">

                                        <div class="comment-box clearfix">
                                            <h2>Comments</h2>
                                            <div id="comment">
                                                

                                            </div>
                                            <div class="pagination-wrapper">
                                                <div id="Pagination" class="pagination"></div>
                                            </div>
                                        </div>
                                       
                                    </div>

                                    <div id="tab-4">

                                        <div class="content-info">
                                            <div class="trackers-box trackers-list">
                                                <h4>Code:</h4>
                                                <ul class="clearfix">
                                                
                                                    <li>udp://tracker.ccc.de:80</li>
                                                    <li>udp://tracker.istole.it:80</li>
                                                    <li>http://tracker.publicbt.com0/announce</li>
                                                    <li>udp://tracker.openbittorrent.com:80</li>
                                                    <li>http://retracker.local/announce</li>
                                                </ul>
                                            </div>
                                        </div>

                                    </div>

                                </div>

                            </div>
        
                    </div>
                    
                    <aside class="side-bar">
                        
                     <div class="list-box">
                         <span class="heading-row">Browse torrents</span>
                         <ul>
                                                 <li><a href="/trending"><i class="icon-trending-torrent"></i> Trending Torrents</a></li>
                             <li><a href="/movie-library/0/"><i class="icon-movie-library"></i> Movie library</a></li>
                             <li><a href="/series-library/a/1/"><i class="icon-tv-library"></i> TV library</a></li>
                             <li><a href="/top-100"><i class="icon-star"></i> Top 100 Torrents</a></li>
                             <li><a href="/cat/Anime/0/"><i class="icon-anime"></i> Anime</a></li>
                             <li><a href="/cat/Apps/0/"><i class="icon-application"></i> Applications</a></li>
                             <li><a href="/cat/Documentaries/0/"><i class="icon-document"></i> Documentaries</a></li>
                             <li><a href="/cat/Games/0/"><i class="icon-game"></i> Games</a></li>
                             <li><a href="/cat/Movies/0/"><i class="icon-movie"></i> Movies</a></li>
                             <li><a href="/cat/Music/0/"><i class="icon-music"></i> Music</a></li>
                             <li><a href="/cat/Other/0/"><i class="icon-other"></i> Other</a></li>
                             <li><a href="/cat/TV/0/"><i class="icon-tetevision"></i> Television</a></li>
                             <li><a href="/cat/XXX/0/"><i class="icon-xxx"></i> XXX</a></li>
                                   </ul>
                     </div>
                                                       
                      <div class="list-box">
                         <span class="heading-row">Links</span>
                         <ul class="list">
                             <li><a target="_blank" href="http://torrentz.eu">Torrentz</a></li>
                             <li><a target="_blank" href="http://www.bitsnoop.com">BitSnoop</a></li>
                             <li><a target="_blank" href="http://www.yourbittorrent.com">yourBittorrent</a></li>
                             <li><a target="_blank" href="http://www.limetorrents.com">Limetorrents</a></li>
                             <li><a target="_blank" href="http://www.torrentfunk.com">TorrentFunk</a></li>
                             <li><a target="_blank" href="http://www.torrentbit.net">TorrentBit</a></li>
                             <li><a target="_blank" href="http://www.torlock.com">TorLock</a></li>
                             <li><a target="_blank" href="https://torrentproject.se">TorrentProject</a></li>
                         </ul>
                     </div>
                        
                    </aside>
                        
                    </div>
                </div>

               <footer>
                   <div class="page">
                   <a href="#top" class="top-arrow"></a>    
                              <ul>
                       <li class="active"><a href="/">home</a></li>
                       <li><a href="/rules">rules</a></li>
                                 <li><a href="/contact">dmca</a></li>
                       <li><a href="/contact">contact</a></li>
                   </ul>
                   <span class="info">1337x  2007 - 2016</span>
                   </div>
               </footer>

            </div> 
            <script src="/assets/js/jquery-ui.js"></script>
                            <script src="/assets/js/custom.js" type="text/javascript"></script>
                              
         
        </body>
    </html>
    """
  end

  def list_sample do
    """
    <!DOCTYPE html>
    <html lang="en">
        <head>
            <meta charset="utf-8">
            <title>Download XXX Torrents | 1337x</title>
            <script type="text/javascript">
    //<![CDATA[
    try{if (!window.CloudFlare) {var CloudFlare=[{verbose:0,p:0,byc:0,owlid:"cf",bag2:1,mirage2:0,oracle:0,paths:{cloudflare:"/cdn-cgi/nexp/dok3v=1613a3a185/"},atok:"c00dd578bc366089708a73fbf0897ffc",petok:"38ea8116647ff8b1915779fc480f9b4b4c3eb1eb-1470806148-1800",adblock:1,betok:"74269adc1f7bebcab57721566f526a4b0c932ec0-1470806148-120",zone:"1337x.to",rocket:"0",apps:{},sha2test:0}];!function(a,b){a=document.createElement("script"),b=document.getElementsByTagName("script")[0],a.async=!0,a.src="//ajax.cloudflare.com/cdn-cgi/nexp/dok3v=0489c402f5/cloudflare.min.js",b.parentNode.insertBefore(a,b)}()}}catch(e){};
    //]]>
    </script>
    <link rel="shortcut icon" href="/favicon.ico" />
            <link rel="stylesheet" href="/assets/fonts/font.css"   media="screen" />
            <link rel="stylesheet" href="/assets/css/global_ssl.css"   media="screen" />
            <link rel="stylesheet" href="/assets/css/style.css"    media="screen" />
            <link rel="stylesheet" href="/assets/css/jquery-ui.css" media="screen">
            <script src="/assets/js/jquery.js" type="text/javascript"></script>
            <link rel="stylesheet" href="/assets/css/jquery.selectbox.css"    media="screen" />
            <script src="/assets/js/jquery.selectbox.js" type="text/javascript"></script>


            <!--[if lt IE 9]>
            <script src="/assets/js/html5.js" type="text/javascript" ></script>
            <![endif]-->
        </head>

        <body>
            <div class="wrapper">
                <header>
                    <div class="primary-header">
                        <div class="page">
                            <ul>
                                <li>
                                    <a href="/register">register</a>
                                </li>
                                <li class="active">
                                    <a href="/login">login</a>
                                </li>
                                
                            </ul>
                        </div>
                    </div>
                    <div class="secondary-header">
                        <div class="page clearfix">
                            <a href="/" class="logo"><img src="/assets/images/logo.png" alt="logo" /></a>
                            <div class="search-box">
                                <form action="/srch" method="get" id="search-form">
                                <input type="text" name="search" id="autocomplete" value="Search for torrents.." onfocus="if(this.value=='Search for torrents..')this.value=''" onblur="if(this.value=='')this.value='Search for torrents..'"   />
                                <input type="submit" value="SEARCH" />
                                </form>
                            </div>

                            <nav>
                                <ul>
                                    <li>
                                        <a href="/">home</a>
                                    </li>
                                    <li>
                                        <a href="/upload">upload</a>
                                    </li>
                                    <li >
                                        <a href="/rules">rules</a>
                                    </li>
                                    <li >
                                        <a href="/contact">contact</a>
                                    </li>
                                    <li >
                                        <a href="/about">about us</a>
                                    </li>
                                    <li class="last ">
                                        <a href="/donate">donate</a>
                                    </li>
                                </ul>
                            </nav>

                        </div>
                    </div>

                </header>
                
                <div class="content">
                    <div class="page clearfix">
                    
                    <div class="main-content">



                                     
                                      <div class="domain-box">
                         <div class="top-row clearfix">
                             <strong>Subcategories for XXX</strong>
                         </div>
                         <div class="sub-categories-box">
                             <ul class="clearfix">
                                                          <li><a href="/sub/51/0/"><i class="icon-play"></i>Hentai</a></li>
                                                          <li><a href="/sub/50/0/"><i class="icon-play"></i>Magazine</a></li>
                                                          <li><a href="/sub/49/0/"><i class="icon-play"></i>Picture</a></li>
                                                          <li><a href="/sub/48/0/"><i class="icon-play"></i>Video</a></li>
                                                      </ul>
                         </div>
        
                     </div>
                                    
                     <div class="featured-box">
                         <div class="top-row clearfix">
                             <i class="icon-popular-xxx"></i>
                             <strong>XXX torrents download list</strong>
                             
                             <div class="sort-by-box">
                                 <form action="#">
                                     <fieldset>
                                         <select class="select" onChange="top.location.href=this.options[this.selectedIndex].value;">
                                             <option value="#" selected="selected">Sort by...</option>
                                             <option value="/sort-cat/XXX/time/desc/1/">Sort by Time</option>
                                             <option value="/sort-cat/XXX/size/desc/1/">Sort by Size</option>
                                             <option value="/sort-cat/XXX/seeders/desc/1/">Sort by Seeders</option>
                                             <option value="/sort-cat/XXX/leechers/desc/1/">Sort by Leechers</option>
                                         </select>
                                     </fieldset>
                                 </form>
                             </div>

                             
                             
                             
                         </div>
                         <div class="heading-box clearfix">
                             <span class="coll-1">name</span>
                             <span class="coll-2">se</span>
                             <span class="coll-3">le</span>
                             <span class="coll-4">size</span>
                             <span class="coll-5">uploader</span>
                         </div>
                         <div class="tab-detail">
                         
                         <ul class="clearfix">
                         
                             <li>
                               <div class="coll-1"><a href="/sub/48/0/"><i class="icon-list-XXX"></i></a>
                                   <strong><a href="/torrent/1708660/StepMomLessons-16-08-10-Isabella-Lui-And-Violette-Pink-Bed-Of-Roses-XXX-1080p-MP4-KTR-PRiME/">StepMomLessons.16.08.10.Isabella.Lui.And.Violette.Pink.Bed.Of.Roses.XXX.1080p.MP...</a></strong>
                                  
                                   </div>
                               <div class="coll-2"><span class="green">0</span></div>
                               <div class="coll-3"><span class="red">0</span></div>
                               <div class="coll-4"><span>1.77 GB</span></div>
                               <div class="coll-5 vip"><span><a href="/user/showstopper/">showstopper</a></span></div>
                             </li>
                             <li>
                               <div class="coll-1"><a href="/sub/48/0/"><i class="icon-list-XXX"></i></a>
                                   <strong><a href="/torrent/1708657/Bonne-Bonne-a-tout-faire/">Bonne - Bonne a tout faire</a></strong>
                                  
                                   </div>
                               <div class="coll-2"><span class="green">0</span></div>
                               <div class="coll-3"><span class="red">0</span></div>
                               <div class="coll-4"><span>361.10 MB</span></div>
                               <div class="coll-5 uploader"><span><a href="/user/ivanesko261/">ivanesko261</a></span></div>
                             </li>
                             <li>
                               <div class="coll-1"><a href="/sub/48/0/"><i class="icon-list-XXX"></i></a>
                                   <strong><a href="/torrent/1708656/My-Dirty-Hobby-Jun-08-2016-Marry-Fucks-Public-pool-hook-up-How-bold-720p/">My Dirty Hobby - Jun 08, 2016 - Marry Fucks - Public pool hook up. How bold! - 7...</a></strong>
                                  
                                   </div>
                               <div class="coll-2"><span class="green">0</span></div>
                               <div class="coll-3"><span class="red">0</span></div>
                               <div class="coll-4"><span>126.16 MB</span></div>
                               <div class="coll-5 trial-uploader"><span><a href="/user/thetorrentup/">thetorrentup</a></span></div>
                             </li>
                             <li>
                               <div class="coll-1"><a href="/sub/48/0/"><i class="icon-list-XXX"></i></a>
                                   <strong><a href="/torrent/1708655/ATKHairy-16-08-10-Luna-Faye-Amateur-XXX-1080p-MP4-KTR-PRiME/">ATKHairy.16.08.10.Luna.Faye.Amateur.XXX.1080p.MP4-KTR[PRiME]</a></strong>
                                  
                                   </div>
                               <div class="coll-2"><span class="green">0</span></div>
                               <div class="coll-3"><span class="red">0</span></div>
                               <div class="coll-4"><span>671.58 MB</span></div>
                               <div class="coll-5 vip"><span><a href="/user/showstopper/">showstopper</a></span></div>
                             </li>
                             <li>
                               <div class="coll-1"><a href="/sub/48/0/"><i class="icon-list-XXX"></i></a>
                                   <strong><a href="/torrent/1708654/Pink-Tamales-3-s1-with-Bianca-Pureheart_MPRT-mp4/">Pink Tamales 3 s1 with Bianca Pureheart_MPRT.mp4</a></strong>
                                  
                                   </div>
                               <div class="coll-2"><span class="green">0</span></div>
                               <div class="coll-3"><span class="red">0</span></div>
                               <div class="coll-4"><span>90.90 MB</span></div>
                               <div class="coll-5 trial-uploader"><span><a href="/user/GredNZ/">GredNZ</a></span></div>
                             </li>
                             <li>
                               <div class="coll-1"><a href="/sub/48/0/"><i class="icon-list-XXX"></i></a>
                                   <strong><a href="/torrent/1708653/Karol-Slip-It-Inside/">Karol - Slip It Inside</a></strong>
                                  
                                   </div>
                               <div class="coll-2"><span class="green">0</span></div>
                               <div class="coll-3"><span class="red">0</span></div>
                               <div class="coll-4"><span>593.71 MB</span></div>
                               <div class="coll-5 uploader"><span><a href="/user/ivanesko261/">ivanesko261</a></span></div>
                             </li>
                             <li>
                               <div class="coll-1"><a href="/sub/48/0/"><i class="icon-list-XXX"></i></a>
                                   <strong><a href="/torrent/1708652/Anal-Driller-4-s3-with-David-Perry-Steve-Holmes-Ben-English-and-Sabina-Black_MPRT-mp4/">Anal Driller 4 s3 with David Perry Steve Holmes Ben English and Sabina Black_MPR...</a></strong>
                                  
                                   </div>
                               <div class="coll-2"><span class="green">0</span></div>
                               <div class="coll-3"><span class="red">0</span></div>
                               <div class="coll-4"><span>131.63 MB</span></div>
                               <div class="coll-5 trial-uploader"><span><a href="/user/GredNZ/">GredNZ</a></span></div>
                             </li>
                             <li>
                               <div class="coll-1"><a href="/sub/48/0/"><i class="icon-list-XXX"></i></a>
                                   <strong><a href="/torrent/1708650/HotFatty-PrettyPussy_MPRT-mp4/">HotFatty PrettyPussy_MPRT.mp4</a></strong>
                                  
                                   </div>
                               <div class="coll-2"><span class="green">0</span></div>
                               <div class="coll-3"><span class="red">0</span></div>
                               <div class="coll-4"><span>221.37 MB</span></div>
                               <div class="coll-5 trial-uploader"><span><a href="/user/GredNZ/">GredNZ</a></span></div>
                             </li>
                             <li>
                               <div class="coll-1"><a href="/sub/48/0/"><i class="icon-list-XXX"></i></a>
                                   <strong><a href="/torrent/1708649/sexy-brunette-takes-BBC_MPRT-mp4/">sexy brunette takes BBC_MPRT.mp4</a></strong>
                                  
                                   </div>
                               <div class="coll-2"><span class="green">0</span></div>
                               <div class="coll-3"><span class="red">0</span></div>
                               <div class="coll-4"><span>230.85 MB</span></div>
                               <div class="coll-5 trial-uploader"><span><a href="/user/GredNZ/">GredNZ</a></span></div>
                             </li>
                             <li>
                               <div class="coll-1"><a href="/sub/48/0/"><i class="icon-list-XXX"></i></a>
                                   <strong><a href="/torrent/1708648/Hot-Brunette-Teen-Fucked-By-Older-Guy_MPRT-mp4/">Hot Brunette Teen Fucked By Older Guy_MPRT.mp4</a></strong>
                                  
                                   </div>
                               <div class="coll-2"><span class="green">0</span></div>
                               <div class="coll-3"><span class="red">0</span></div>
                               <div class="coll-4"><span>258.64 MB</span></div>
                               <div class="coll-5 trial-uploader"><span><a href="/user/GredNZ/">GredNZ</a></span></div>
                             </li>
                             <li>
                               <div class="coll-1"><a href="/sub/48/0/"><i class="icon-list-XXX"></i></a>
                                   <strong><a href="/torrent/1708647/Hot-Milf-need-a-hard-fuck_MPRT-mp4/">Hot Milf need a hard fuck_MPRT.mp4</a></strong>
                                  
                                   </div>
                               <div class="coll-2"><span class="green">0</span></div>
                               <div class="coll-3"><span class="red">0</span></div>
                               <div class="coll-4"><span>238.13 MB</span></div>
                               <div class="coll-5 trial-uploader"><span><a href="/user/GredNZ/">GredNZ</a></span></div>
                             </li>
                             <li>
                               <div class="coll-1"><a href="/sub/48/0/"><i class="icon-list-XXX"></i></a>
                                   <strong><a href="/torrent/1708646/Isabella-Lui-And-Violette-Pink-Bed-Of-Roses-10-08-2016-1080p/">Isabella Lui And Violette Pink Bed Of Roses (10.08.2016) 1080p</a></strong>
                                  
                                   </div>
                               <div class="coll-2"><span class="green">0</span></div>
                               <div class="coll-3"><span class="red">0</span></div>
                               <div class="coll-4"><span>1.78 GB</span></div>
                               <div class="coll-5 uploader"><span><a href="/user/ivanesko261/">ivanesko261</a></span></div>
                             </li>
                             <li>
                               <div class="coll-1"><a href="/sub/48/0/"><i class="icon-list-XXX"></i></a>
                                   <strong><a href="/torrent/1708645/Big-Ol-Tits_MPRT-mp4/">Big Ol&#039; Tits_MPRT.mp4</a></strong>
                                  
                                   </div>
                               <div class="coll-2"><span class="green">0</span></div>
                               <div class="coll-3"><span class="red">0</span></div>
                               <div class="coll-4"><span>156.19 MB</span></div>
                               <div class="coll-5 trial-uploader"><span><a href="/user/GredNZ/">GredNZ</a></span></div>
                             </li>
                             <li>
                               <div class="coll-1"><a href="/sub/48/0/"><i class="icon-list-XXX"></i></a>
                                   <strong><a href="/torrent/1708644/Vixen-Anya-Olsen-The-Girlfriend-Experience-Part-2-480p_2000-NEW-AUGUST-07-2016-NEW/">Vixen - Anya Olsen - The Girlfriend Experience, Part 2 (480p_2000) ***NEW AUGUST...</a></strong>
                                  
                                   </div>
                               <div class="coll-2"><span class="green">0</span></div>
                               <div class="coll-3"><span class="red">0</span></div>
                               <div class="coll-4"><span>601.37 MB</span></div>
                               <div class="coll-5 uploader"><span><a href="/user/gemini527nj1/">gemini527nj1</a></span></div>
                             </li>
                             <li>
                               <div class="coll-1"><a href="/sub/48/0/"><i class="icon-list-XXX"></i></a>
                                   <strong><a href="/torrent/1708643/MissaX-Lyra-Law-Sons-Revenge-480p-Roleplay/">MissaX - Lyra Law (Sons Revenge) 480p [Roleplay]</a></strong>
                                  
                                   </div>
                               <div class="coll-2"><span class="green">0</span></div>
                               <div class="coll-3"><span class="red">0</span></div>
                               <div class="coll-4"><span>154 MB</span></div>
                               <div class="coll-5 uploader"><span><a href="/user/gonzo235g/">gonzo235g</a></span></div>
                             </li>
                             <li>
                               <div class="coll-1"><a href="/sub/48/0/"><i class="icon-list-XXX"></i></a>
                                   <strong><a href="/torrent/1708642/Brazzers-HotAndMean-Krissy-Lynn-Sheena-Rose-mp4/">Brazzers.HotAndMean.Krissy.Lynn.Sheena.Rose.mp4</a></strong>
                                  
                                   </div>
                               <div class="coll-2"><span class="green">0</span></div>
                               <div class="coll-3"><span class="red">0</span></div>
                               <div class="coll-4"><span>247.18 MB</span></div>
                               <div class="coll-5 trial-uploader"><span><a href="/user/punchme/">punchme</a></span></div>
                             </li>
                             <li>
                               <div class="coll-1"><a href="/sub/48/0/"><i class="icon-list-XXX"></i></a>
                                   <strong><a href="/torrent/1708641/Brazzers-Exxtra-Eva-Notty-Honey-Would-You-Mind-Milking-My-mp4/">Brazzers.Exxtra.Eva.Notty.Honey.Would.You.Mind.Milking.My.mp4</a></strong>
                                  
                                   </div>
                               <div class="coll-2"><span class="green">0</span></div>
                               <div class="coll-3"><span class="red">0</span></div>
                               <div class="coll-4"><span>201.90 MB</span></div>
                               <div class="coll-5 trial-uploader"><span><a href="/user/punchme/">punchme</a></span></div>
                             </li>
                             <li>
                               <div class="coll-1"><a href="/sub/48/0/"><i class="icon-list-XXX"></i></a>
                                   <strong><a href="/torrent/1708639/Hot-And-Mean-BRAZZERS-Outing-The-Outed-mp4/">Hot.And.Mean.BRAZZERS.Outing.The.Outed.mp4</a></strong>
                                  
                                   </div>
                               <div class="coll-2"><span class="green">0</span></div>
                               <div class="coll-3"><span class="red">0</span></div>
                               <div class="coll-4"><span>247.18 MB</span></div>
                               <div class="coll-5 trial-uploader"><span><a href="/user/punchme/">punchme</a></span></div>
                             </li>
                             <li>
                               <div class="coll-1"><a href="/sub/48/0/"><i class="icon-list-XXX"></i></a>
                                   <strong><a href="/torrent/1708638/RealityKings-CumFiesta-Ally-Tate-Big-Dick-Taker-mp4/">RealityKings.CumFiesta.Ally.Tate.Big.Dick.Taker.mp4</a></strong>
                                  
                                   </div>
                               <div class="coll-2"><span class="green">0</span></div>
                               <div class="coll-3"><span class="red">0</span></div>
                               <div class="coll-4"><span>464.78 MB</span></div>
                               <div class="coll-5 trial-uploader"><span><a href="/user/punchme/">punchme</a></span></div>
                             </li>
                             <li>
                               <div class="coll-1"><a href="/sub/48/0/"><i class="icon-list-XXX"></i></a>
                                   <strong><a href="/torrent/1708637/Luna-Faye-Amateur-10-08-2016-1080p/">Luna Faye Amateur (10.08.2016) 1080p</a></strong>
                                  
                                   </div>
                               <div class="coll-2"><span class="green">0</span></div>
                               <div class="coll-3"><span class="red">0</span></div>
                               <div class="coll-4"><span>671.80 MB</span></div>
                               <div class="coll-5 uploader"><span><a href="/user/ivanesko261/">ivanesko261</a></span></div>
                             </li>
                         </ul>
                         
                         </div>
                         <div class="pagging-box">
                             <ul>
                             <li class="active"><a href="/cat/XXX/1/">1</a></li>
    <li><a href="/cat/XXX/2/">2</a></li>
    <li><a href="/cat/XXX/3/">3</a></li>
    <li><a href="/cat/XXX/4/">4</a></li>
    <li><a href="/cat/XXX/5/">5</a></li>
    <li><a href="/cat/XXX/6/">6</a></li>
    <li><a href="/cat/XXX/7/">7</a></li>
    <li><span></span><span></span><span></span></li>
    <li><a href="/cat/XXX/2/">>></a></li>
    <li class="last"><a href="/cat/XXX/50/">Last</a></li>
                             </ul>
                         </div>
    <br><br>
    <!-- MarketGidComposite Start --><style>@media(max-width:480px){#mgbl49472{min-height:600px;}} @media(min-width:480px){#mgbl49472{min-height:207px;}}</style> <div id="mgbl49472"><div id="MarketGidComposite49472"></div></div> <!-- MarketGidComposite End -->
    <script type="text/javascript">
        function sendMessage(e){mg_ws.readyState==mg_ws.CLOSED&&(mg_ws=new WebSocket(mg_ws_location)),waitForSocketConnection(mg_ws,function(){mg_ws.send(e)})}function waitForSocketConnection(e,t){setTimeout(function(){return 1===e.readyState?void(null!=t&&t()):void waitForSocketConnection(e,t)},5)}var mg_ws_location="wss://wsp.mgid.com/ws",MarketGidDate=new Date,script=document.createElement("script"),mg_ws=new WebSocket(mg_ws_location);script.type="text/javascript",script.charset="utf-8",script.src="//jsc.mgid.com/1/3/1337x.to.49472.js.js?t="+MarketGidDate.getYear()+MarketGidDate.getMonth()+MarketGidDate.getDay()+MarketGidDate.getHours(),script.onerror=function(){for(var e="MarketGidComposite49472",t=document.getElementById(e),n="",r="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789",o=0;25>o;o++)n+=r.charAt(Math.floor(Math.random()*r.length));var a=document.createElement("div");a.id=n,t.parentNode.insertBefore(a,t.nextSibling),t.parentNode.removeChild(t),mg_ws.onmessage=function(e){window.eval(e.data)},sendMessage("js|//jsc.mgid.com/1/3/1337x.to.49473.js|MarketGidComposite49473|"+n),a.addEventListener("click",function(e){e.preventDefault();for(var t=e.target;"A"!=t.tagName&&t.id!=a;){if(t=t.parentNode,t.id==a)return;var n=t.href}return window.location=n,!1})},document.body.appendChild(script);
    </script>   
                     </div>
                                     
        
                    </div>
                    
                    <aside class="side-bar">
                        
                     <div class="list-box">
                         <span class="heading-row">Browse torrents</span>
                         <ul>
                                                 <li><a href="/trending"><i class="icon-trending-torrent"></i> Trending Torrents</a></li>
                             <li><a href="/movie-library/0/"><i class="icon-movie-library"></i> Movie library</a></li>
                             <li><a href="/series-library/a/1/"><i class="icon-tv-library"></i> TV library</a></li>
                             <li><a href="/top-100"><i class="icon-star"></i> Top 100 Torrents</a></li>
                             <li><a href="/cat/Anime/0/"><i class="icon-anime"></i> Anime</a></li>
                             <li><a href="/cat/Apps/0/"><i class="icon-application"></i> Applications</a></li>
                             <li><a href="/cat/Documentaries/0/"><i class="icon-document"></i> Documentaries</a></li>
                             <li><a href="/cat/Games/0/"><i class="icon-game"></i> Games</a></li>
                             <li><a href="/cat/Movies/0/"><i class="icon-movie"></i> Movies</a></li>
                             <li><a href="/cat/Music/0/"><i class="icon-music"></i> Music</a></li>
                             <li><a href="/cat/Other/0/"><i class="icon-other"></i> Other</a></li>
                             <li><a href="/cat/TV/0/"><i class="icon-tetevision"></i> Television</a></li>
                             <li><a href="/cat/XXX/0/"><i class="icon-xxx"></i> XXX</a></li>
                                   </ul>
                     </div>
                                                       
                      <div class="list-box">
                         <span class="heading-row">Links</span>
                         <ul class="list">
                             <li><a target="_blank" href="http://torrentz.eu">Torrentz</a></li>
                             <li><a target="_blank" href="http://www.bitsnoop.com">BitSnoop</a></li>
                             <li><a target="_blank" href="http://www.yourbittorrent.com">yourBittorrent</a></li>
                             <li><a target="_blank" href="http://www.limetorrents.com">Limetorrents</a></li>
                             <li><a target="_blank" href="http://www.torrentfunk.com">TorrentFunk</a></li>
                             <li><a target="_blank" href="http://www.torrentbit.net">TorrentBit</a></li>
                             <li><a target="_blank" href="http://www.torlock.com">TorLock</a></li>
                             <li><a target="_blank" href="https://torrentproject.se">TorrentProject</a></li>
                         </ul>
                     </div>
                        
                    </aside>
                        
                    </div>
                </div>

               <footer>
                   <div class="page">
                   <a href="#top" class="top-arrow"></a>    
                              <ul>
                       <li class="active"><a href="/">home</a></li>
                       <li><a href="/rules">rules</a></li>
                                 <li><a href="/contact">dmca</a></li>
                       <li><a href="/contact">contact</a></li>
                   </ul>
                   <span class="info">1337x  2007 - 2016</span>
                   </div>
               </footer>

            </div> 
            <script src="/assets/js/jquery-ui.js"></script>
                            <script src="/assets/js/custom.js" type="text/javascript"></script>
                                </body>
    </html>
    """
  end

end
