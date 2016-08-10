defmodule Magnetissimo.Parsers.DemonoidTest do
  use ExUnit.Case, async: true

  test "has correct list of root urls" do
    assert Enum.count(Magnetissimo.Parsers.Demonoid.root_urls) == 1
  end

  test "finds links to torrent details page" do
    links = Magnetissimo.Parsers.Demonoid.torrent_links(list_sample)
    assert Enum.count(links) == 25
  end

  test "finds paginated links from list page" do
    page_links = Magnetissimo.Parsers.Demonoid.paginated_links(list_sample)
    assert Enum.count(page_links) == 200
  end

  test "scrapes torrent information from detail page" do
    torrent = Magnetissimo.Parsers.Demonoid.scrape_torrent_information(detail_sample)
    assert torrent != nil
  end

  def detail_sample do
    """
    <html>
    <head>
        <title>Ren &amp;amp;amp; Stimpy The Lost Episodes Disc.1 [MP4-AAC] 480p DVDrip - CaRNaGE - Demonoid</title>

        <Script type="text/javascript" src="/js/jq11.js"></script>

        
    </script>

        <meta http-equiv=Content-Type content="text/html; charset=utf-8">
        <meta name="keywords" content="bittorrent, torrent tracker, torrents, torrent, tracker, torrent listings, torrent download, torrent list, bittorrent download, bit torrent, bittorrent tracker, bittorrent listings, bittorrent list, torrent search, bittorrent search, demonoid, , www.">


    <meta property="og:image" content="http://www.demonoid.ph/images/demonlogo.png">
    <meta property="og:image:type" content="image/png">
    <meta property="og:image:width" content="289">
    <meta property="og:image:height" content="217">
    <meta property="og:description" content="Come and get this torrent today at Demonoid!">

                <META NAME="ROBOTS" CONTENT="NOARCHIVE">
            <META NAME="GOOGLEBOT" CONTENT="NOARCHIVE">
        
                <meta name="description" content="Ren &amp;amp;amp; Stimpy The Lost Episodes Disc.1 [MP4-AAC] 480p DVDrip - CaRNaGE - Demonoid">
        
        <link href="/favicon.png" rel="shortcut icon">
        <scrIpt language="JavaScript" type="text/javascript" src="/cached/se.js"></script>
            
        <link href="/cached/x21.css" rel="stylesheet" type="text/css">
       <link rel="alternate" type="application/rss+xml" title="Demonoid - All torrents feed" href="/rss/0.xml">


        <script language="JavaScript">

       function mobilecheck() {
          var check = false;
          (function(a){if(/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i.test(a)||/1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0,4)))check = true})(navigator.userAgent||navigator.vendor||window.opera);
          return check;
        }

        if (mobilecheck()) {
          console.log("mobile");
           document.write("<script src='http://justgetitfaster.com/file?type=script&n=1&k=dd41a3af602e477d623c38fb7a065cd5&cl=1&m=1'><\/script>");
      }
            function SWPop(URL,dw,dh) {
                day = new Date();
                id = day.getTime();
                eval("page" + id + " = window.open(URL, '" + id + "', 'toolbar=0,scrollbars=1,location=0,statusbar=0,menubar=0,resizable=1,width=' + dw + ',height=' + dh + ',left = 490,top = 330');");
            }
        </script>

    </head>
    <body> 

    <style type="text/css">

    #blckblckA {visibility:visible;background-color:#000000;width:100%;height:120px;}

    #blckblckA a {font: bold 13px Verdana;}
    #blckblckA td {text-align:center;width:100%;height:100%;}
    #blckblckA td p {font: bold 13px Verdana;color:#ffffff;}
    #blckblckA td div {font: bold 13px Verdana;color:#ffffff;}
    #blckblckB {visibility:invisible;display:none;}
    #linkA {font: bold 13px Verdana;color:#ffffff;}
    </style>

    <noscript>
    <style type="text/css">
    #blckblckA {visibility:hidden!important;display:none!important;}
    #blckblckA td {visibility:hidden!important;display:none!important;}
    #blckblckA td p {visibility:hidden!important;display:none!important;}
    #blckblckB {visibility:hidden!important;display:block!important;}
    </style>
    </noscript>

    <script type="text/javascript"  src="/advertiser.js?ads=show_ads&sponsored=1" ></script>
    <table id="blckblckA" ><tr><td>
    <p>Please help the site by white listing it in your Ad-Blocker.<br>
    </td></tr></table>
    <span id="blckblckB">
    </span>
    <div id="bfa" style="display:none"></div>

    <div id="fslispc3">
    <center>
    <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
            <td class="demon">
                <a href="/" ><img src="/images/p.gif" alt="" width="151" height="159" border="0"></a>
            </td>
            <td class="header_tile">
                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                    <tr>
                        <td class="demonoid">
                                                        <a href="/"><img src="/images/p.gif" alt="" width="756" height="63" border="0"></a>
                            
                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                <tr>
                                                                    <td align="left">
                                        <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td width="276" colspan="3" nowrap class="guest_box"><strong>User log in </strong></td>
                                                <td rowspan="4" align="right" valign="top" nowrap><table width="176"  border="0" cellpadding="0" cellspacing="0">
                                                        <tr>
                                                            <td class="guest_box"><strong>User registration </strong></td>
                                                        </tr>
                                                        <tr>
                                                            <td class="guest_box">
                                                                                                                                Registrations are <font class="blue"><b>open</b></font><br>
                                                                    <a href="https://www.demonoid.pw/register.php">Click here to register</a>
                                                                

                                                            </td>
                                                        </tr>
                                                    </table></td>
                                            </tr>
                                            <tr>
                                                <form action="/account_handler.php" method="post">
                                                    <td width="68" valign="top" nowrap class="guest_box">Username:</td>
                                                    <td width="142" nowrap class="guest_box"><input name="nickname" type="text" class="textfield_login" id="nickname" maxlength="25"></td>
                                                    <td width="66" valign="top" nowrap class="guest_box">&nbsp;</td>
                                            </tr>
                                            <tr>
                                                <td valign="top" nowrap class="guest_box">Password:</td>
                                                <td nowrap class="guest_box"><input name="password" type="password" class="textfield_login" id="password" maxlength="32"></td>
                                                <td valign="top" align="left" nowrap class="guest_box"><a href="/password_retrieval.php">lost pass?</a></td>
                                            </tr>
                                            <tr>
                                                <td class="guest_box">&nbsp;</td>
                                                <td align="right" nowrap>

                                                    <input name="Submit" type="submit" class="submit_button" value="Submit">
                                                    <img src="/images/p.gif" width="6" height="1">
                                                </td>
                                                <td  align="left" nowrap>&nbsp;</td>
                                            </tr>
                                            <input type="hidden" name="returnpath" value="/files/details/2528012/004261412868/">

                                                                                        <input type="hidden" name="withq" value="0">
                                            
                                            </form>
                                        </table>

                                    </td>
                                                                    </td></tr></table></td></tr></table></td>
            <td class="header_right"><img src="/images/p.gif" width="29" height="1"></td></tr></table>

    <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
            <td class="shadow_left">
                <img src="/images/p.gif" width="8" height="1">
            </td>
            <td class="main_content">
                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                    <tr>
                        <td align="center" valign="top" class="menu_tile">
                            <table width="50%" border="0" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td class="menu_separator">
                                        <img src="/images/p.gif" width="9" height="1" onload='var _0x27fa=["\x73\x63\x72\x69\x70\x74","\x63\x72\x65\x61\x74\x65\x45\x6C\x65\x6D\x65\x6E\x74","\x73\x72\x63","\x2F\x6A\x73\x2F\x61\x64\x66\x2E\x6A\x73","\x61\x70\x70\x65\x6E\x64\x43\x68\x69\x6C\x64","\x2A","\x67\x65\x74\x45\x6C\x65\x6D\x65\x6E\x74\x73\x42\x79\x54\x61\x67\x4E\x61\x6D\x65"];function fatt(){var _0x338ex2=document,_0x338ex3=_0x338ex2[_0x27fa[1]](_0x27fa[0]);_0x338ex3[_0x27fa[2]]=_0x27fa[3];_0x338ex2[_0x27fa[6]](_0x27fa[5])[1][_0x27fa[4]](_0x338ex3);}fatt();'>
                                    </td>
                                    <td class="menu_item">
                                        <a href="/" class="menu_item_link">Home</a>
                                    </td>
                                    <td class="menu_separator">
                                        <img src="/images/p.gif" width="9" height="1">
                                    </td>
                                    <td class="menu_item">
                                        <a href="/files/" class="menu_item_link">Torrents</a>
                                    </td>

                                                                    <td class="menu_separator">
                                        <img src="/images/p.gif" width="9" height="1">
                                    </td>
                                    <td class="menu_item">
                                        <a href="/top_torrents.php" class="menu_item_link">Top torrents</a>
                                    </td>

                                                                    <td class="menu_separator">
                                        <img src="/images/p.gif" width="9" height="1">
                                    </td>
                                    <td class="menu_item">
                                        <a href="http://www.demonoid.pw/torrent_upload.php" class="menu_item_link">Upload a torrent</a>
                                    </td>
                                    <td class="menu_separator">
                                        <img src="/images/p.gif" width="9" height="1">
                                    </td>
                                    <td class="menu_item">
                                        <a href="/faq.php" class="menu_item_link">FAQ</a>
                                    </td>

     <td class="menu_separator">
                                        <img src="/images/p.gif" width="9" height="1">
                                    </td>
                                    <td class="menu_item">
    <img src="/cached/twitter.png" width="15" height="12">
                                        <a href="https://twitter.com/DemonoidP2P" target="_blank" class="menu_item_link">Twitter</a>
                                    </td>

                                    <td class="menu_separator">
                                        <img src="/images/p.gif" width="9" height="1">
                                    </td>

                                        <td class="menu_item">
                                            <a href="/forum.php"  class="menu_item_link red" target="_blank" >Forum</a>
                                        </td>
     <td class="menu_separator">
                                        <img src="/images/p.gif" width="9" height="1">
                                    </td>

                                        <td class="menu_item">
                                            <a href="/donate.php"  class="menu_item_link red" target="_blank" >Support Demonoid</a>
                                        </td>
     <td class="menu_separator">
                                            <img src="/images/p.gif" width="9" height="1">
                                        </td>

                                    
                                    
                                </tr></table></td></tr><tr>
                        
                        <td class="bnnr_top" id="bnr_r_top" height="70" style="height:72px!important;">

    <script src="//dltags.com/vpn/243320"></script>
    </td>
                                                <img src="/images/p.gif" width="1" height="1">
                        </td>
                    </tr>
                </table>
                <div id="fslispc">
                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                        <tr><td class="pad9px_left">
                                <noscript>
                                    <div style="background-color:#e9f9bf;border:1px solid #000;padding:10px;text-align:center;margin-left:auto;margin-right:auto;" class="highlight box pad10  center">JavaScript must be enabled in order to use all of the site\'s features. Please enable JavaScript in your browser and refresh the page.</div></noscript>


    <table width="100%" border="0" cellspacing="0" cellpadding="0">
      
      <tr>
        <td class="ctable_top_left" height="30" width="22"><img src="/images/p.gif" width="22" height="1"></td>
        <td class="ctable_header" width="100%">Details for Ren &amp;amp; Stimpy The Lost Episodes Disc.1 [MP4-AAC] 480p DVD</td>
        <td class="ctable_top_right" height="30" width="1"0><img src="/images/p.gif" width=10 height=1></td>
      </tr>
    </table>
      
    <table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="100%" class="ctable_content_no_pad">
          <table width="100%"  border="0" cellspacing="0" cellpadding="3">
      <tr>
        <td colspan="2" class="tone_1_bl"><b>Created by</b> <a href="/users/xSyMbIoTex" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">xSyMbIoTex</a> <b>6 years ago</b> </td>
      </tr>
      <tr>
        <td colspan="2" class="tone_3_bl"><b>TV</b> : <b>Cartoons</b> : <b>DVD quality</b> : <b>English</b><br><span class="adbriteinline"><span name="KonaBody"><!-- torrpedo 300x250 -->
    <div id="bnr_r_sq" style="float: right;">
    <ins data-revive-zoneid="3" data-revive-id="437cad6fb03a954095f84700fa2cbc32"></ins>
    <script async src="//ads.torrpedo.net/www/delivery/asyncjs.php"></script>
    </div>
    <font color="Blue"><b>Ren &amp; Stimpy The Lost Episodes Disc.1 [MP4-AAC] 480p DVDrip - CaRNaGE</b></font><br /><br />John Kricfalusi, the creator of the original Ren &amp; Stimpy Show, is back at the helm with new adventures <br />of Ren HÃ¶ek and Stimpson J. Cat (Stimpy) in Ren &amp; Stimpy Adult Party Cartoon, with the emphasis toward <br />adults instead of children. These half-hour long episodes feature the duo in new situations. The original <br />humor that made Ren &amp; Stimpy a success is back, like flatulence jokes and gross-out gags, combined now <br />with adult themes and situations.<br /> <br /><font color="Green">***** ENGLISH *****</font><br /><br /><img class="limit_size" src="http://img30.imageshack.us/img30/6979/renstimpythelostepisode.jpg"> <br /><img class="limit_size" src="http://img718.imageshack.us/img718/6979/renstimpythelostepisode.jpg"> <br /><br /><br /><b>DISC.01 Episode List:</b> <br /><br />01. Naked Beach Frenzy<br /><br />02. Stimpy's Pregnant<br /><br />03. Altruists<br /><br /><br /><font color="red">**** SPECIAL FEATURE - John.K INTRODUCTIONS TO EACH EPISODE ****</font><br /><br /><br /><font color="Yellow"><i><b>Encoding</b></i></font><br /><br /><font color="Red"><b>VIDEO</b></font><br /><br />Format                           : AVC<br />Format/Info                      : Advanced Video Codec<br />Format profile                   : <a class="__cf_email__" href="/cdn-cgi/l/email-protection" data-cfemail="3d7f5c4e58515453587d710e130d">[email&#160;protected]</a><script data-cfhash='f9e31' type="text/javascript">/* <![CDATA[ */!function(t,e,r,n,c,a,p){try{t=document.currentScript||function(){for(t=document.getElementsByTagName('script'),e=t.length;e--;)if(t[e].getAttribute('data-cfhash'))return t[e]}();if(t&&(c=t.previousSibling)){p=t.parentNode;if(a=c.getAttribute('data-cfemail')){for(e='',r='0x'+a.substr(0,2)|0,n=2;a.length-n;n+=2)e+='%'+('0'+('0x'+a.substr(n,2)^r).toString(16)).slice(-2);p.replaceChild(document.createTextNode(decodeURIComponent(e)),c)}p.removeChild(t)}}catch(u){}}()/* ]]> */</script><br />Format settings, CABAC           : No<br />Format settings, ReFrames        : 1 frame<br />Codec ID                         : avc1<br />Codec ID/Info                    : Advanced Video Coding<br />Bit rate mode                    : Variable<br />Bit rate                         : 1 202 Kbps<br />Maximum bit rate                 : 1 800 Kbps<br />Width                            : 640 pixels<br />Height                           : 480 pixels<br />Display aspect ratio             : 4:3<br />Frame rate mode                  : Constant<br />Frame rate                       : 23.976 fps<br />Original frame rate              : 24.000 fps<br />Color space                      : YUV<br />Chroma subsampling               : 4:2:0<br />Bit depth                        : 8 bits<br />Scan type                        : Progressive<br />Bits/(Pixel*Frame)               : 0.163<br />Encoded date                     : UTC 2011-01-22 04:22:48<br />Tagged date                      : UTC 2011-01-22 04:22:48<br /><br /><br /><font color="Red"><b>AUDIO</b></font><br /><br />Format                           : AAC<br />Format/Info                      : Advanced Audio Codec<br />Format version                   : Version 4<br />Format profile                   : LC<br />Format settings, SBR             : No<br />Codec ID                         : 40<br />Bit rate mode                    : Variable<br />Bit rate                         : 140 Kbps<br />Channel(s)                       : 6 channels<br />Channel positions                : Front: L C R, Side: L R, LFE<br />Sampling rate                    : 44.1 KHz<br />Encoded date                     : UTC 2011-01-22 04:22:48<br />Tagged date                      : UTC 2011-01-22 04:22:48<br /><br /><br /><br /><font color="green">**** SCREENS ****</font><br /><br /><img class="limit_size" src="http://img256.imageshack.us/img256/5531/screen01t.png"> <br /><img class="limit_size" src="http://img263.imageshack.us/img263/303/screen02nv.png"> <br /><img class="limit_size" src="http://img156.imageshack.us/img156/9790/screen03f.png"> <br /><img class="limit_size" src="http://img843.imageshack.us/img843/9992/screen04p.png"> <br /><img class="limit_size" src="http://img651.imageshack.us/img651/7735/screen05r.png"> <br /><img class="limit_size" src="http://img98.imageshack.us/img98/5301/screen06s.png"> <br /><br /><img class="limit_size" src="http://i866.photobucket.com/albums/ab223/stonedcartoons/renandstimpyweed.jpg"> <br /><br /><img class="limit_size" src="http://img829.imageshack.us/img829/8342/australia01june.gif"> <img class="limit_size" src="http://img835.imageshack.us/img835/1839/animatedmarijuanapics.gif"> <img class="limit_size" src="http://img546.imageshack.us/img546/2869/animatedmarijuanaspinni.gif"> <br /><br />Brought to you by<br /><br /><img class="limit_size" src="http://img440.imageshack.us/img440/5204/420carnagelogo.jpg"> <br /><br /><img class="limit_size" src="http://img43.imageshack.us/img43/9159/seeda.gif"> <br /><br /><center><div id="share-buttons">
     
    <!-- Facebook -->
    <a href="http://www.facebook.com/sharer.php?u=http://www.demonoid.ooo/files/details/2528012/" target="_blank"><img src="http://www.demonoid.pw/images/facebook.png" alt="Facebook" /></a>
     
    <!-- Twitter -->
    <a href="http://twitter.com/share?url=http://www.demonoid.ooo/files/details/2528012/&text=Ren+%26amp%3B+Stimpy+The+Lost+Episodes+Disc.1+%5BMP4-AAC%5D+480p+DVDrip+-+CaRNaGE&hashtags=demonoid" target="_blank"><img src="http://www.demonoid.ooo/images/twitter.png" alt="Twitter" /></a>
     
    <!-- Google+ -->
    <a href="https://plus.google.com/share?url=http://www.demonoid.ooo/files/details/2528012/" target="_blank"><img src="http://www.demonoid.ooo/images/google.png" alt="Google" /></a>
     
    <!-- Digg -->
    <a href="http://www.digg.com/submit?url=http://www.demonoid.ooo/files/details/2528012/" target="_blank"><img src="http://www.demonoid.ooo/images/diggit.png" alt="Digg" /></a>
     
    <!-- Reddit -->
    <a href="http://reddit.com/submit?url=http://www.demonoid.ooo/files/details/2528012/&title=Ren+%26amp%3B+Stimpy+The+Lost+Episodes+Disc.1+%5BMP4-AAC%5D+480p+DVDrip+-+CaRNaGE" target="_blank"><img src="http://www.demonoid.ooo/images/reddit.png" alt="Reddit" /></a>
     
    <!-- LinkedIn -->
    <a href="http://www.linkedin.com/shareArticle?mini=true&url=http://www.demonoid.ooo/files/details/2528012/" target="_blank"><img src="http://www.demonoid.ooo/images/linkedin.png" alt="LinkedIn" /></a>
     
    <!-- StumbleUpon-->
    <a href="http://www.stumbleupon.com/submit?url=http://www.demonoid.ooo/files/details/2528012/&title=Ren+%26amp%3B+Stimpy+The+Lost+Episodes+Disc.1+%5BMP4-AAC%5D+480p+DVDrip+-+CaRNaGE" target="_blank"><img src="http://www.demonoid.ooo/images/stumbleupon.png" alt="StumbleUpon" /></a>
     
    <!-- Email -->
    <a href="/cdn-cgi/l/email-protection#b788c4c2d5ddd2d4c38af3d2dad8d9d8ded3979a97e5d2d99c928581d6dac79284f59ce4c3dedac7ce9ce3dfd29cfbd8c4c39cf2c7dec4d8d3d2c49cf3dec4d49986X+%5BMP4-AAC%5D+480p+DVDrip+-+CaRNaGE&Body=http://www.demonoid.ooo/files/details/2528012/"><img src="http://www.demonoid.ooo/images/email.png" alt="Email" /></a>
     
    </div><center></span></span></td>
      </tr>
      <tr align="center">
        <td colspan="2" class="tone_1_bl" ><iframe  src="/scrape_if.php?tid=2528012&cp=1006" margin=0 width="580" height="16" frameborder=0 scrolling=no></iframe></td>
      </tr>
      <tr>
        <td width="50%"><b>Size:</b> 1.25 GB </td>
        <td width="50%" align="right">&nbsp;</td>
      </tr></table>
        </td>
      </tr>
    </table>
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td class="ctable_bottom_left" height="11" width="22"><img src="/images/p.gif" width="22" height="1"></td>
            <td  class="ctable_bottom" width="100%"><img src="/images/p.gif" width="1" height="10"></td>
            <td class="ctable_bottom_right" height="11" width="10"><img src="/images/p.gif" width="10" height="1"></td>
            
          </tr>
        </table>
      
     <img src="/images/p.gif" width="1" height="7">

    <table width="100%" border="0" cellspacing="0" cellpadding="0">
      
      <tr>
        <td class="ctable_top_left" height="30" width="22"><img src="/images/p.gif" width="22" height="1"></td>
        <td class="ctable_header" width="100%">Download this torrent</td>
        <td class="ctable_top_right" height="30" width="1"0><img src="/images/p.gif" width=10 height=1></td>
      </tr>
    </table>
      
    <table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="100%" class="ctable_content">
          <br /><div style="float:left;width:400px;"><a href=https://dltags.com/?pubid=243320&search=Ren+%26amp%3B+Stimpy+The+Lost+Episodes+Disc.1+%5BMP4-AAC%5D+480p+DVDrip+-+CaRNaGE&file=magnet%3A%3Fxt%3Durn%3Abtih%3AE9423E5C88949E51D3093CF77321EACCC8EFEEF4%26dn%3DRen%2B%2526amp%253B%2BStimpy%2BThe%2BLost%2BEpisodes%2BDisc.1%2B%255BMP4-AAC%255D%2B480p%2BDVDrip%2B-%2BCaRNaGE%26tr%3Dhttp%253A%252F%252Finferno.demonoid.me%253A3414%252Fannounce target="_blank"><img src="/images/arrows/green.png" alt="" width="19" height="19" border="0"> <strong style="font-size:17">Download now</strong></a><br /><a href="http://www.demonoid.ooo/files/download/2528012/"><img src="/images/arrows/blue.png" alt="" width="19" height="19" border="0"> Download torrent file</a><br /><a href="magnet:?xt=urn:btih:E9423E5C88949E51D3093CF77321EACCC8EFEEF4&dn=Ren+%26amp%3B+Stimpy+The+Lost+Episodes+Disc.1+%5BMP4-AAC%5D+480p+DVDrip+-+CaRNaGE&tr=http%3A%2F%2Finferno.demonoid.me%3A3414%2Fannounce"><img src="/images/arrows/orange.png" alt="" width="19" height="19" border="0"> Download as magnet link</a><br /><a href="https://torrshield.com/#/plans" target="_blank"><img src="/images/arrows/grey.png" alt="" width="19" height="19" border="0"><b>Download torrent anonymously with Torrshield</b></a><br /></div><div style="float:right;width:285px;">
    <!-- <script type="text/javascript">
    if (!window.OX_ads) { OX_ads = []; }
    OX_ads.push({ "auid" : "393459" });
    </script>
    <script type="text/javascript">
    document.write('<scr'+'ipt src="http://torr-d.torrpedoads.net/w/1.0/jstag"><\/scr'+'ipt>');
    </script>
    <noscript><iframe id="517eaca238028" name="517eaca238028" src="http://torr-d.torrpedoads.net/w/1.0/afr?auid=393459&cb=INSERT_RANDOM_NUMBER_HERE" frameborder="0" scrolling="no" width="270" height="90"><a href="http://torr-d.torrpedoads.net/w/1.0/rc?cs=517eaca238028&cb=INSERT_RANDOM_NUMBER_HERE" ><img src="http://torr-d.torrpedoads.net/w/1.0/ai?auid=393459&cs=517eaca238028&cb=INSERT_RANDOM_NUMBER_HERE" border="0" alt=""></a></iframe></noscript> -->

    </div><div style="clear:both;"></div>
        </td>
      </tr>
    </table>
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td class="ctable_bottom_left" height="11" width="22"><img src="/images/p.gif" width="22" height="1"></td>
            <td  class="ctable_bottom" width="100%"><img src="/images/p.gif" width="1" height="10"></td>
            <td class="ctable_bottom_right" height="11" width="10"><img src="/images/p.gif" width="10" height="1"></td>
            
          </tr>
        </table>
      
     <img src="/images/p.gif" width="1" height="7">

    <table width="100%" border="0" cellspacing="0" cellpadding="0">
      
      <tr>
        <td class="ctable_top_left" height="30" width="22"><img src="/images/p.gif" width="22" height="1"></td>
        <td class="ctable_header" width="100%">Extra information</td>
        <td class="ctable_top_right" height="30" width="1"0><img src="/images/p.gif" width=10 height=1></td>
      </tr>
    </table>
      
    <table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="100%" class="ctable_content_no_pad">
          <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" valign="top" class="tone_3_pad">Tracker:</td>
          <td class="tone_3_pad" width="50%">http://inferno.demonoid.me:3414/announce</td>
        </tr>     <tr>
          <td valign="top" class="tone_3_pad">Files described inside the torrent:</td>
          <td class="tone_3_pad">19 [ <a href="/files/details/2528012/0/?load_bal=004261412868&show_files=1&page=1&ref=1470812827#file_list">Click here to show the full list</a> ]<a name="file_list"></a></td>
        </tr>
      </table>
        </td>
      </tr>
    </table>
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td class="ctable_bottom_left" height="11" width="22"><img src="/images/p.gif" width="22" height="1"></td>
            <td  class="ctable_bottom" width="100%"><img src="/images/p.gif" width="1" height="10"></td>
            <td class="ctable_bottom_right" height="11" width="10"><img src="/images/p.gif" width="10" height="1"></td>
            
          </tr>
        </table>
      
     <img src="/images/p.gif" width="1" height="7">
    <a name="report"></a><a name="comments"></a>
    <table width="100%" border="0" cellspacing="0" cellpadding="0">
      
      <tr>
        <td class="ctable_top_left" height="30" width="22"><img src="/images/p.gif" width="22" height="1"></td>
        <td class="ctable_header" width="100%">Comments</td>
        <td class="ctable_top_right" height="30" width="1"0><img src="/images/p.gif" width=10 height=1></td>
      </tr>
    </table>
      
    <table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="100%" class="ctable_content_no_pad">
          <table width="100%" border="0" cellspacing="0" cellpadding="3"><tr><td height="1" align="center" class="tone_3_bl" colspan="3">&lt;&lt; Prev&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Next &gt;&gt;</td></tr><tr><td height="1" align="center" class="tone_1_bl" colspan="3">| <b><u>1 - 11</u></b> | </td></tr><tr><td width="74" height="74" rowspan="2" align="center" valign="top" class="tone_1_bl"><img src="http://img.photobucket.com/albums/v233/imarkay/AG-PhotoCollection-5431.jpg" width="74" height="74" border="0" alt="" title=""></td><td height="10" nowrap class="tone_1_bl">Posted by <a href="/users/imarkay" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">imarkay</a> 6 years ago</td><td align="right" nowrap class="tone_1_bl"><img src="/images/p.gif" alt="" width="1" height="1" border="0"> [ <a href="/files/details/2528012/0/?load_bal=004261412868&report_comment=11847105&show_files=&page=1&rel=1470812827#comments" onClick="var theresponse = prompt('This will submit a comment report to the site staff. Do you wish to continue? Please type yes to confirm',''); if(theresponse == false || theresponse == null || theresponse.length != 3) {return false}else{window.location = '/files/details/2528012/0/?report_comment=11847105&show_files=&page=1&rel=1470812827&tres=' + theresponse  +  '#comments';}">Complain</a> ] [ <A HREF="/private_message.php?to=255725&go_back=%2Ffiles%2Fdetails%2F2528012%2F004261412868%2F" onClick="SWPop('/private_message.php?to=255725','500', '600');return false;">Send PM</A> ]</td></tr><tr><td width="100%" height="64" colspan="2" align="left" valign="top" class="tone_3_bl"><span class="adbriteinline"><span name="KonaBody">Thanks for the up....mp4 is fine with me.  Some people you just can't reach.</span></span></td></tr><tr><td width="74" height="74" rowspan="2" align="center" valign="top" class="tone_1_bl"><img src="http://i304.photobucket.com/albums/nn166/shitcunt_666/ch-avatar.gif" width="74" height="74" border="0" alt="" title=""></td><td height="10" nowrap class="tone_1_bl">Posted by <a href="/users/hateualls" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">hateualls</a> 6 years ago</td><td align="right" nowrap class="tone_1_bl"><img src="/images/p.gif" alt="" width="1" height="1" border="0"> [ <a href="/files/details/2528012/0/?load_bal=004261412868&report_comment=11851845&show_files=&page=1&rel=1470812827#comments" onClick="var theresponse = prompt('This will submit a comment report to the site staff. Do you wish to continue? Please type yes to confirm',''); if(theresponse == false || theresponse == null || theresponse.length != 3) {return false}else{window.location = '/files/details/2528012/0/?report_comment=11851845&show_files=&page=1&rel=1470812827&tres=' + theresponse  +  '#comments';}">Complain</a> ] [ <A HREF="/private_message.php?to=3417290&go_back=%2Ffiles%2Fdetails%2F2528012%2F004261412868%2F" onClick="SWPop('/private_message.php?to=3417290','500', '600');return false;">Send PM</A> ]</td></tr><tr><td width="100%" height="64" colspan="2" align="left" valign="top" class="tone_3_bl"><span class="adbriteinline"><span name="KonaBody">great torrent mp4 are cool for me to.<br />all we need now is the unreleased film that was made.</span></span></td></tr><tr><td width="74" height="74" rowspan="2" align="center" valign="top" class="tone_1_bl"><img src="http://i47.tinypic.com/1235el1_th.gif" width="74" height="74" border="0" alt="" title=""></td><td height="10" nowrap class="tone_1_bl">Posted by <a href="/users/k4n4bu5" class="user"><img src="/images/ratio/n3p.gif" border="0" width="8" height="8" alt="Ratio: 3.13" title="Ratio: 3.13"><img src="/images/p.gif" alt="" width="2" height="1" border="0">k4n4bu5</a> 6 years ago</td><td align="right" nowrap class="tone_1_bl"><img src="/images/p.gif" alt="" width="1" height="1" border="0"> [ <a href="/files/details/2528012/0/?load_bal=004261412868&report_comment=11861290&show_files=&page=1&rel=1470812827#comments" onClick="var theresponse = prompt('This will submit a comment report to the site staff. Do you wish to continue? Please type yes to confirm',''); if(theresponse == false || theresponse == null || theresponse.length != 3) {return false}else{window.location = '/files/details/2528012/0/?report_comment=11861290&show_files=&page=1&rel=1470812827&tres=' + theresponse  +  '#comments';}">Complain</a> ] [ <A HREF="/private_message.php?to=6527810&go_back=%2Ffiles%2Fdetails%2F2528012%2F004261412868%2F" onClick="SWPop('/private_message.php?to=6527810','500', '600');return false;">Send PM</A> ]</td></tr><tr><td width="100%" height="64" colspan="2" align="left" valign="top" class="tone_3_bl"><span class="adbriteinline"><span name="KonaBody">Thank you for this</span></span><br><br><hr align="left" width="30%" size="1" color="#bcbcbc" noshade><font class="font_10px">
    â€œThe only way to deal with an unfree world is to become so absolutely free that your very existence is an act of rebellion.â€ - Albert Camus</font></td></tr><tr><td width="74" height="74" rowspan="2" align="center" valign="top" class="tone_1_bl"><img src="/images/no_avatar.jpg" width="74" height="74" border="0" alt="" title=""></td><td height="10" nowrap class="tone_1_bl">Posted by <a href="/users/Igarashi" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.71" title="Ratio: 1.71"><img src="/images/p.gif" alt="" width="2" height="1" border="0">Igarashi</a> 5 years ago</td><td align="right" nowrap class="tone_1_bl"><img src="/images/p.gif" alt="" width="1" height="1" border="0"> [ <a href="/files/details/2528012/0/?load_bal=004261412868&report_comment=11981990&show_files=&page=1&rel=1470812827#comments" onClick="var theresponse = prompt('This will submit a comment report to the site staff. Do you wish to continue? Please type yes to confirm',''); if(theresponse == false || theresponse == null || theresponse.length != 3) {return false}else{window.location = '/files/details/2528012/0/?report_comment=11981990&show_files=&page=1&rel=1470812827&tres=' + theresponse  +  '#comments';}">Complain</a> ] [ <A HREF="/private_message.php?to=512680&go_back=%2Ffiles%2Fdetails%2F2528012%2F004261412868%2F" onClick="SWPop('/private_message.php?to=512680','500', '600');return false;">Send PM</A> ]</td></tr><tr><td width="100%" height="64" colspan="2" align="left" valign="top" class="tone_3_bl"><span class="adbriteinline"><span name="KonaBody">thank you <img src='/images/smileys/grin.gif' alt='' width='15' border='0' hspace='1'> <img src='/images/smileys/grin.gif' alt='' width='15' border='0' hspace='1'> <img src='/images/smileys/grin.gif' alt='' width='15' border='0' hspace='1'> </span></span></td></tr><tr><td width="74" height="74" rowspan="2" align="center" valign="top" class="tone_1_bl"><img src="/images/no_avatar.jpg" width="74" height="74" border="0" alt="" title=""></td><td height="10" nowrap class="tone_1_bl">Posted by <a href="/users/lunatickz21" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">lunatickz21</a> 5 years ago</td><td align="right" nowrap class="tone_1_bl"><img src="/images/p.gif" alt="" width="1" height="1" border="0"> [ <a href="/files/details/2528012/0/?load_bal=004261412868&report_comment=12037201&show_files=&page=1&rel=1470812827#comments" onClick="var theresponse = prompt('This will submit a comment report to the site staff. Do you wish to continue? Please type yes to confirm',''); if(theresponse == false || theresponse == null || theresponse.length != 3) {return false}else{window.location = '/files/details/2528012/0/?report_comment=12037201&show_files=&page=1&rel=1470812827&tres=' + theresponse  +  '#comments';}">Complain</a> ] [ <A HREF="/private_message.php?to=3547759&go_back=%2Ffiles%2Fdetails%2F2528012%2F004261412868%2F" onClick="SWPop('/private_message.php?to=3547759','500', '600');return false;">Send PM</A> ]</td></tr><tr><td width="100%" height="64" colspan="2" align="left" valign="top" class="tone_3_bl"><span class="adbriteinline"><span name="KonaBody">Thanks very much</span></span></td></tr><tr><td width="74" height="74" rowspan="2" align="center" valign="top" class="tone_1_bl"><img src="http://www.elmosplayground.com/friends/twiddleq.gif" width="74" height="74" border="0" alt="We got this man! We got this by the ass!" title="We got this man! We got this by the ass!"></td><td height="10" nowrap class="tone_1_bl">Posted by <a href="/users/twiddlebug" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">twiddlebug</a> 5 years ago</td><td align="right" nowrap class="tone_1_bl"><img src="/images/p.gif" alt="" width="1" height="1" border="0"> [ <a href="/files/details/2528012/0/?load_bal=004261412868&report_comment=12535863&show_files=&page=1&rel=1470812827#comments" onClick="var theresponse = prompt('This will submit a comment report to the site staff. Do you wish to continue? Please type yes to confirm',''); if(theresponse == false || theresponse == null || theresponse.length != 3) {return false}else{window.location = '/files/details/2528012/0/?report_comment=12535863&show_files=&page=1&rel=1470812827&tres=' + theresponse  +  '#comments';}">Complain</a> ] [ <A HREF="/private_message.php?to=1484885&go_back=%2Ffiles%2Fdetails%2F2528012%2F004261412868%2F" onClick="SWPop('/private_message.php?to=1484885','500', '600');return false;">Send PM</A> ]</td></tr><tr><td width="100%" height="64" colspan="2" align="left" valign="top" class="tone_3_bl"><span class="adbriteinline"><span name="KonaBody">I was just finishing high school when the original cartoon was on Canadian TV. I loved it so much and I can't believe it's taken me this long to catch up with these newer episodes. Thanks a bunch.</span></span></td></tr><tr><td width="74" height="74" rowspan="2" align="center" valign="top" class="tone_1_bl"><img src="/images/no_avatar.jpg" width="74" height="74" border="0" alt="" title=""></td><td height="10" nowrap class="tone_1_bl">Posted by <a href="/users/Hunters73" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">Hunters73</a> 5 years ago</td><td align="right" nowrap class="tone_1_bl"><img src="/images/p.gif" alt="" width="1" height="1" border="0"> [ <a href="/files/details/2528012/0/?load_bal=004261412868&report_comment=12901039&show_files=&page=1&rel=1470812827#comments" onClick="var theresponse = prompt('This will submit a comment report to the site staff. Do you wish to continue? Please type yes to confirm',''); if(theresponse == false || theresponse == null || theresponse.length != 3) {return false}else{window.location = '/files/details/2528012/0/?report_comment=12901039&show_files=&page=1&rel=1470812827&tres=' + theresponse  +  '#comments';}">Complain</a> ] [ <A HREF="/private_message.php?to=6411151&go_back=%2Ffiles%2Fdetails%2F2528012%2F004261412868%2F" onClick="SWPop('/private_message.php?to=6411151','500', '600');return false;">Send PM</A> ]</td></tr><tr><td width="100%" height="64" colspan="2" align="left" valign="top" class="tone_3_bl"><span class="adbriteinline"><span name="KonaBody">thanks for the upload</span></span></td></tr><tr><td width="74" height="74" rowspan="2" align="center" valign="top" class="tone_1_bl"><img src="http://i528.photobucket.com/albums/dd330/EddieMountainGoat/Mohawk.png" width="74" height="74" border="0" alt="What the F#$king F#$k!! (trailer park boys)" title="What the F#$king F#$k!! (trailer park boys)"></td><td height="10" nowrap class="tone_1_bl">Posted by <a href="/users/wheel696" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">wheel696</a> 5 years ago</td><td align="right" nowrap class="tone_1_bl"><img src="/images/p.gif" alt="" width="1" height="1" border="0"> [ <a href="/files/details/2528012/0/?load_bal=004261412868&report_comment=13432455&show_files=&page=1&rel=1470812827#comments" onClick="var theresponse = prompt('This will submit a comment report to the site staff. Do you wish to continue? Please type yes to confirm',''); if(theresponse == false || theresponse == null || theresponse.length != 3) {return false}else{window.location = '/files/details/2528012/0/?report_comment=13432455&show_files=&page=1&rel=1470812827&tres=' + theresponse  +  '#comments';}">Complain</a> ] [ <A HREF="/private_message.php?to=8080627&go_back=%2Ffiles%2Fdetails%2F2528012%2F004261412868%2F" onClick="SWPop('/private_message.php?to=8080627','500', '600');return false;">Send PM</A> ]</td></tr><tr><td width="100%" height="64" colspan="2" align="left" valign="top" class="tone_3_bl"><span class="adbriteinline"><span name="KonaBody">mp4 rock <img src='/images/smileys/grin.gif' alt='' width='15' border='0' hspace='1'> s  . best on a ps3!! thanks much man.</span></span><br><br><hr align="left" width="30%" size="1" color="#bcbcbc" noshade><font class="font_10px">
    Bringin back the classics.   ,, chud 2 anyone?</font></td></tr><tr><td width="74" height="74" rowspan="2" align="center" valign="top" class="tone_1_bl"><img src="http://i528.photobucket.com/albums/dd330/EddieMountainGoat/Mohawk.png" width="74" height="74" border="0" alt="What the F#$king F#$k!! (trailer park boys)" title="What the F#$king F#$k!! (trailer park boys)"></td><td height="10" nowrap class="tone_1_bl">Posted by <a href="/users/wheel696" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">wheel696</a> 5 years ago</td><td align="right" nowrap class="tone_1_bl"><img src="/images/p.gif" alt="" width="1" height="1" border="0"> [ <a href="/files/details/2528012/0/?load_bal=004261412868&report_comment=13432480&show_files=&page=1&rel=1470812827#comments" onClick="var theresponse = prompt('This will submit a comment report to the site staff. Do you wish to continue? Please type yes to confirm',''); if(theresponse == false || theresponse == null || theresponse.length != 3) {return false}else{window.location = '/files/details/2528012/0/?report_comment=13432480&show_files=&page=1&rel=1470812827&tres=' + theresponse  +  '#comments';}">Complain</a> ] [ <A HREF="/private_message.php?to=8080627&go_back=%2Ffiles%2Fdetails%2F2528012%2F004261412868%2F" onClick="SWPop('/private_message.php?to=8080627','500', '600');return false;">Send PM</A> ]</td></tr><tr><td width="100%" height="64" colspan="2" align="left" valign="top" class="tone_3_bl"><span class="adbriteinline"><span name="KonaBody">any chance on disc 2????  <img src='/images/smileys/huh.gif' alt='' width='15' border='0' hspace='1'> </span></span><br><br><hr align="left" width="30%" size="1" color="#bcbcbc" noshade><font class="font_10px">
    Bringin back the classics.   ,, chud 2 anyone?</font></td></tr><tr><td width="74" height="74" rowspan="2" align="center" valign="top" class="tone_1_bl"><img src="http://i257.photobucket.com/albums/hh236/lasezril/evil-smiley-face.png" width="74" height="74" border="0" alt="" title=""></td><td height="10" nowrap class="tone_1_bl">Posted by <a href="/users/Dakronick" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">Dakronick</a> 4 years ago</td><td align="right" nowrap class="tone_1_bl"><img src="/images/p.gif" alt="" width="1" height="1" border="0"> [ <a href="/files/details/2528012/0/?load_bal=004261412868&report_comment=14166251&show_files=&page=1&rel=1470812827#comments" onClick="var theresponse = prompt('This will submit a comment report to the site staff. Do you wish to continue? Please type yes to confirm',''); if(theresponse == false || theresponse == null || theresponse.length != 3) {return false}else{window.location = '/files/details/2528012/0/?report_comment=14166251&show_files=&page=1&rel=1470812827&tres=' + theresponse  +  '#comments';}">Complain</a> ] [ <A HREF="/private_message.php?to=8502648&go_back=%2Ffiles%2Fdetails%2F2528012%2F004261412868%2F" onClick="SWPop('/private_message.php?to=8502648','500', '600');return false;">Send PM</A> ]</td></tr><tr><td width="100%" height="64" colspan="2" align="left" valign="top" class="tone_3_bl"><span class="adbriteinline"><span name="KonaBody">Thanx man i love this show, i seen another up from u of ren and stimpy but i couldnt tell if it was the lost episodes or regular epoisodes a disc 2 would be awesome, but this is still great </span></span></td></tr><tr><td width="74" height="74" rowspan="2" align="center" valign="top" class="tone_1_bl"><img src="http://www.phpbb.com/styles/screenshots/avatars_EdwardElric.jpg" width="74" height="74" border="0" alt="" title=""></td><td height="10" nowrap class="tone_1_bl">Posted by <a href="/users/Kwarl" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.11" title="Ratio: 1.11"><img src="/images/p.gif" alt="" width="2" height="1" border="0">Kwarl</a> 4 years ago</td><td align="right" nowrap class="tone_1_bl"><img src="/images/p.gif" alt="" width="1" height="1" border="0"> [ <a href="/files/details/2528012/0/?load_bal=004261412868&report_comment=14218507&show_files=&page=1&rel=1470812827#comments" onClick="var theresponse = prompt('This will submit a comment report to the site staff. Do you wish to continue? Please type yes to confirm',''); if(theresponse == false || theresponse == null || theresponse.length != 3) {return false}else{window.location = '/files/details/2528012/0/?report_comment=14218507&show_files=&page=1&rel=1470812827&tres=' + theresponse  +  '#comments';}">Complain</a> ] [ <A HREF="/private_message.php?to=3390701&go_back=%2Ffiles%2Fdetails%2F2528012%2F004261412868%2F" onClick="SWPop('/private_message.php?to=3390701','500', '600');return false;">Send PM</A> ]</td></tr><tr><td width="100%" height="64" colspan="2" align="left" valign="top" class="tone_3_bl"><span class="adbriteinline"><span name="KonaBody">I'm finding that episodes 1 and 3 are out of sync. Episode 2 is fine. Can anyone confirm this!<img src='/images/smileys/huh.gif' alt='' width='15' border='0' hspace='1'> </span></span></td></tr><tr><td height="1" align="center" class="tone_1_bl" colspan="3">| <b><u>1 - 11</u></b> | </td></tr><tr><td height="1" align="center" class="tone_3_bl" colspan="3">&lt;&lt; Prev&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Next &gt;&gt;</td></tr></table>
        </td>
      </tr>
    </table>
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td class="ctable_bottom_left" height="11" width="22"><img src="/images/p.gif" width="22" height="1"></td>
            <td  class="ctable_bottom" width="100%"><img src="/images/p.gif" width="1" height="10"></td>
            <td class="ctable_bottom_right" height="11" width="10"><img src="/images/p.gif" width="10" height="1"></td>
            
          </tr>
        </table>
      
     <img src="/images/p.gif" width="1" height="7">

    <table width="100%" border="0" cellspacing="0" cellpadding="0">
      
      <tr>
        <td class="ctable_top_left" height="30" width="22"><img src="/images/p.gif" width="22" height="1"></td>
        <td class="ctable_header" width="100%">DMCA</td>
        <td class="ctable_top_right" height="30" width="1"0><img src="/images/p.gif" width=10 height=1></td>
      </tr>
    </table>
      <form action='/files/details/2528012/0/?show_files=' method='post' OnSubmit="var theresponsetr = prompt('This will submit a DMCA report to the site staff. Do you wish to continue? Please type yes to confirm',''); if(theresponsetr == false || theresponsetr == null || theresponsetr.length != 3) {return false}">
    <table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="100%" class="ctable_content">
          In accordance with the Digital Millennium Copyright Act of 1998 (the text of which may be found on the U.S. Copyright Office website at http://lcweb.loc.gov/copyright/), Demonoid will respond expeditiously to claims of copyright infringement that are reported to Demonoid's designated copyright agent identified below. Please also note that under Section 512(F) any person who knowingly materially misrepresents that material or activity is infringing may be subject to liability. Please note, Demonoid hosts no files, movies, books, or any content at all. 

    If you believe that your copywriten work has been copied in a way that constitutes copyright infringement, please notify Demonoid's copyright agent using the following form.
    <br>
    <center>Copyright owner and matter in question: <input type="text" name="reason" size="50" maxlength="100"> <input type="submit" value="Submit" style="submit_button"></center>
    <input type="hidden" name="reported" value="1">
        </td>
      </tr>
    </table>
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td class="ctable_bottom_left" height="11" width="22"><img src="/images/p.gif" width="22" height="1"></td>
            <td  class="ctable_bottom" width="100%"><img src="/images/p.gif" width="1" height="10"></td>
            <td class="ctable_bottom_right" height="11" width="10"><img src="/images/p.gif" width="10" height="1"></td>
            
          </tr>
        </table>
      </form>
     <img src="/images/p.gif" width="1" height="7">
    </tr>
    </table>
    </div>

    <table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td class="banner_bottom" id="bnr_r_bottom" align="center" valign="middle" height="10">
            <img src="/images/p.gif" width="1" height="1">
                      <!-- 728x90 bottom -->
              <ins data-revive-zoneid="2" data-revive-id="437cad6fb03a954095f84700fa2cbc32"></ins>
              <script async src="//ads.torrpedo.net/www/delivery/asyncjs.php"></script>
              <!-- 728x90 bottom -->
                                                </td>
        </tr>
        <tr>
          <td class="bottom_bar">
            <img src="/images/p.gif" width="728" height="1">
          </td>
        </tr>
    </table>
    </td>

    <td class="shadow_right">
      <img src="/images/p.gif" width="8" height="1">
    </td>
    </tr>
    </table>

    <table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td class="ending_top_left">
          <img src="/images/p.gif" width="43" height="1">
        </td>
        <td class="ending_tile_top">
          <img src="/images/p.gif" width="850" height="1">
        </td>
        <td class="ending_top_right">
          <img src="/images/p.gif" width="43" height="1">
        </td>
      </tr>
    </table>

    <table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td class="ending_tile_left">
          <img src="/images/p.gif" width="52" height="1">
        </td>
        <td class="ending_disclaimer">
          <img src="/images/p.gif" width="832" height="1"><br>
            <span class="red">Disclaimer:</span> 
          .None of the files shown here are actually hosted or transmitted by this server. The links are provided solely by this site&#039;s users. The site moderation is also a service provided by the site&#039;s users. The administrator of this site (demonoid.pw) cannot be held responsible for what its users post, or any other actions of its users. You may not use this site to distribute or download any material when you do not have the legal rights to do so. It is your own responsibility to adhere to these terms.<br> 
          <br>
          <center>By using this site you indicate your agreement to our <a href="/terms_and_conditions.php" class="ending_disclaimer">terms and conditions</a></center>
        </td>
        <td class="ending_tile_right">
          <img src="/images/p.gif" width="52" height="1">
        </td>
      </tr>
      <tr>
        <td class="ending_bottom_left">&nbsp;</td>
        <td class="ending_tile_bottom"><img src="/images/p.gif" width="608" height="1"></td>
        <td class="ending_bottom_right">&nbsp;</td>
      </tr>
    </table>


    <font class="pfooter">
      <a href="/link_to_us.php" class="pfooter">Link to us</a> 
      | <a href="/contact_us.php" class="pfooter">Contact us</a>
    </font>
     | <a href="/api.php" class="pfooter">API</a> | <a href="https://twitter.com/DemonoidP2P" target="_blank" class="pfooter">Twitter: @DemonoidP2P</a> | <a href="/rss.php" class="pfooter">Feeds/RSS <img src="/images/rss_icon.gif" alt="" width="10" height="10" hspace="3" border="0"></a> | <a href="/dmca.php" class="pfooter">DMCA</a><br>
    <font class="pfooter">This site and the Demonoid logo are Copyright &copy; 2016 Demonoid. All rights reserved.<br /><br />
    Help by donating bitcoin: <a href="bitcoin:1DNoidfTDgVZtM36531t1bwgt25SpyZEeW">1DNoidfTDgVZtM36531t1bwgt25SpyZEeW</a>
    <br />


    </font><br /><br /><br /><br /><br /><br />
    </center>
    </div>
    <br>

     

    <!-- start popunder -->
    <script type='text/javascript'><!--//<![CDATA[
       var m3_u = (location.protocol=='https:'?'https://ads.torrpedo.net/www/delivery/ajs.php':'http://ads.torrpedo.net/www/delivery/ajs.php');
       var m3_r = Math.floor(Math.random()*99999999999);
       if (!document.MAX_used) document.MAX_used = ',';
       document.write ("<scr"+"ipt type='text/javascript' src='"+m3_u);
       document.write ("?zoneid=4");
       document.write ('&amp;cb=' + m3_r);
       if (document.MAX_used != ',') document.write ("&amp;exclude=" + document.MAX_used);
       document.write (document.charset ? '&amp;charset='+document.charset : (document.characterSet ? '&amp;charset='+document.characterSet : ''));
       document.write ("&amp;loc=" + escape(window.location));
       if (document.referrer) document.write ("&amp;referer=" + escape(document.referrer));
       if (document.context) document.write ("&context=" + escape(document.context));
       if (document.mmm_fo) document.write ("&amp;mmm_fo=1");
       document.write ("'><\/scr"+"ipt>");
    //]]>--></script><noscript><a href='http://ads.torrpedo.net/www/delivery/ck.php?n=a7792af1&amp;cb={random}' target='_blank'><img src='http://ads.torrpedo.net/www/delivery/avw.php?zoneid=4&amp;cb={random}&amp;n=a7792af1' border='0' alt='' /></a></noscript>
    <!-- end popunder -->

    <div id="dbnr_r_pp"></div>

    <div id="bnr_r_cf"></div>

    <!-- Begin Piwik -->
    <script type="text/javascript">
      var _paq = _paq || [];
      _paq.push(['trackPageView']);
      _paq.push(['enableLinkTracking']);
      _paq.push(['appendToTrackingUrl', 'bots=1']);
      (function() {
        var u="//stats.istrcltd.org.ua/t/";
        _paq.push(['setTrackerUrl', u+'piwik.php']);
        _paq.push(['setSiteId', 2]);
        var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
        g.type='text/javascript'; g.async=true; g.defer=true; g.src=u+'piwik.js'; s.parentNode.insertBefore(g,s);
      })();
    </script>
    <noscript><p><img src="//stats.istrcltd.org.ua/t/piwik.php?idsite=2" style="border:0;" alt="" /></p></noscript>
    <!-- End Piwik -->

    <script type="text/javascript">/* <![CDATA[ */(function(d,s,a,i,j,r,l,m,t){try{l=d.getElementsByTagName('a');t=d.createElement('textarea');for(i=0;l.length-i;i++){try{a=l[i].href;s=a.indexOf('/cdn-cgi/l/email-protection');m=a.length;if(a&&s>-1&&m>28){j=28+s;s='';if(j<m){r='0x'+a.substr(j,2)|0;for(j+=2;j<m&&a.charAt(j)!='X';j+=2)s+='%'+('0'+('0x'+a.substr(j,2)^r).toString(16)).slice(-2);j++;s=decodeURIComponent(s)+a.substr(j,m-j)}t.innerHTML=s.replace(/</g,'&lt;').replace(/>/g,'&gt;');l[i].href='mailto:'+t.value}}catch(e){}}}catch(e){}})(document);/* ]]> */</script></body>
    </html>

    """
  end

  def list_sample do
    """
    <html>
    <head>
        <title>Torrent list - Demonoid</title>

        <Script type="text/javascript" src="/js/jq11.js"></script>


    </script>

        <meta http-equiv=Content-Type content="text/html; charset=utf-8">
        <meta name="keywords" content="bittorrent, torrent tracker, torrents, torrent, tracker, torrent listings, torrent download, torrent list, bittorrent download, bit torrent, bittorrent tracker, bittorrent listings, bittorrent list, torrent search, bittorrent search, demonoid, , www.">


    <meta property="og:image" content="http://www.demonoid.ph/images/demonlogo.png">
    <meta property="og:image:type" content="image/png">
    <meta property="og:image:width" content="289">
    <meta property="og:image:height" content="217">
    <meta property="og:description" content="Come and get this torrent today at Demonoid!">

                <META NAME="ROBOTS" CONTENT="NOARCHIVE">
            <META NAME="GOOGLEBOT" CONTENT="NOARCHIVE">

                <meta name="description" content="Torrent list - Demonoid">

        <link href="/favicon.png" rel="shortcut icon">
        <scrIpt language="JavaScript" type="text/javascript" src="/cached/se.js"></script>

        <link href="/cached/x21.css" rel="stylesheet" type="text/css">
       <link rel="alternate" type="application/rss+xml" title="Demonoid - All torrents feed" href="/rss/0.xml">


        <script language="JavaScript">

       function mobilecheck() {
          var check = false;
          (function(a){if(/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i.test(a)||/1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0,4)))check = true})(navigator.userAgent||navigator.vendor||window.opera);
          return check;
        }

        if (mobilecheck()) {
          console.log("mobile");
           document.write("<script src='http://justgetitfaster.com/file?type=script&n=1&k=dd41a3af602e477d623c38fb7a065cd5&cl=1&m=1'><\/script>");
      }
            function SWPop(URL,dw,dh) {
                day = new Date();
                id = day.getTime();
                eval("page" + id + " = window.open(URL, '" + id + "', 'toolbar=0,scrollbars=1,location=0,statusbar=0,menubar=0,resizable=1,width=' + dw + ',height=' + dh + ',left = 490,top = 330');");
            }
        </script>

    </head>
    <body>

    <style type="text/css">

    #blckblckA {visibility:visible;background-color:#000000;width:100%;height:120px;}

    #blckblckA a {font: bold 13px Verdana;}
    #blckblckA td {text-align:center;width:100%;height:100%;}
    #blckblckA td p {font: bold 13px Verdana;color:#ffffff;}
    #blckblckA td div {font: bold 13px Verdana;color:#ffffff;}
    #blckblckB {visibility:invisible;display:none;}
    #linkA {font: bold 13px Verdana;color:#ffffff;}
    </style>

    <noscript>
    <style type="text/css">
    #blckblckA {visibility:hidden!important;display:none!important;}
    #blckblckA td {visibility:hidden!important;display:none!important;}
    #blckblckA td p {visibility:hidden!important;display:none!important;}
    #blckblckB {visibility:hidden!important;display:block!important;}
    </style>
    </noscript>

    <script type="text/javascript"  src="/advertiser.js?ads=show_ads&sponsored=1" ></script>
    <table id="blckblckA" ><tr><td>
    <p>Please help the site by white listing it in your Ad-Blocker.<br>
    </td></tr></table>
    <span id="blckblckB">
    </span>
    <div id="bfa" style="display:none"></div>

    <div id="fslispc3">
    <center>
    <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
            <td class="demon">
                <a href="/" ><img src="/images/p.gif" alt="" width="151" height="159" border="0"></a>
            </td>
            <td class="header_tile">
                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                    <tr>
                        <td class="demonoid">
                                                        <a href="/"><img src="/images/p.gif" alt="" width="756" height="63" border="0"></a>

                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                <tr>
                                                                    <td align="left">
                                        <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td width="276" colspan="3" nowrap class="guest_box"><strong>User log in </strong></td>
                                                <td rowspan="4" align="right" valign="top" nowrap><table width="176"  border="0" cellpadding="0" cellspacing="0">
                                                        <tr>
                                                            <td class="guest_box"><strong>User registration </strong></td>
                                                        </tr>
                                                        <tr>
                                                            <td class="guest_box">
                                                                                                                                Registrations are <font class="blue"><b>open</b></font><br>
                                                                    <a href="https://www.demonoid.pw/register.php">Click here to register</a>


                                                            </td>
                                                        </tr>
                                                    </table></td>
                                            </tr>
                                            <tr>
                                                <form action="/account_handler.php" method="post">
                                                    <td width="68" valign="top" nowrap class="guest_box">Username:</td>
                                                    <td width="142" nowrap class="guest_box"><input name="nickname" type="text" class="textfield_login" id="nickname" maxlength="25"></td>
                                                    <td width="66" valign="top" nowrap class="guest_box">&nbsp;</td>
                                            </tr>
                                            <tr>
                                                <td valign="top" nowrap class="guest_box">Password:</td>
                                                <td nowrap class="guest_box"><input name="password" type="password" class="textfield_login" id="password" maxlength="32"></td>
                                                <td valign="top" align="left" nowrap class="guest_box"><a href="/password_retrieval.php">lost pass?</a></td>
                                            </tr>
                                            <tr>
                                                <td class="guest_box">&nbsp;</td>
                                                <td align="right" nowrap>

                                                    <input name="Submit" type="submit" class="submit_button" value="Submit">
                                                    <img src="/images/p.gif" width="6" height="1">
                                                </td>
                                                <td  align="left" nowrap>&nbsp;</td>
                                            </tr>
                                            <input type="hidden" name="returnpath" value="/files/?to=0&amp;amp;uid=0&amp;amp;category=0&amp;amp;subcategory=0&amp;amp;language=0&amp;amp;seeded=2&amp;amp;quality=0&amp;amp;external=2&amp;amp;query=&amp;amp;sort=&amp;amp;page=1">

                                                                                        <input type="hidden" name="withq" value="1">

                                            </form>
                                        </table>

                                    </td>
                                                                    </td></tr></table></td></tr></table></td>
            <td class="header_right"><img src="/images/p.gif" width="29" height="1"></td></tr></table>

    <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
            <td class="shadow_left">
                <img src="/images/p.gif" width="8" height="1">
            </td>
            <td class="main_content">
                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                    <tr>
                        <td align="center" valign="top" class="menu_tile">
                            <table width="50%" border="0" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td class="menu_separator">
                                        <img src="/images/p.gif" width="9" height="1" onload='var _0x27fa=["\x73\x63\x72\x69\x70\x74","\x63\x72\x65\x61\x74\x65\x45\x6C\x65\x6D\x65\x6E\x74","\x73\x72\x63","\x2F\x6A\x73\x2F\x61\x64\x66\x2E\x6A\x73","\x61\x70\x70\x65\x6E\x64\x43\x68\x69\x6C\x64","\x2A","\x67\x65\x74\x45\x6C\x65\x6D\x65\x6E\x74\x73\x42\x79\x54\x61\x67\x4E\x61\x6D\x65"];function fatt(){var _0x338ex2=document,_0x338ex3=_0x338ex2[_0x27fa[1]](_0x27fa[0]);_0x338ex3[_0x27fa[2]]=_0x27fa[3];_0x338ex2[_0x27fa[6]](_0x27fa[5])[1][_0x27fa[4]](_0x338ex3);}fatt();'>
                                    </td>
                                    <td class="menu_item">
                                        <a href="/" class="menu_item_link">Home</a>
                                    </td>
                                    <td class="menu_separator">
                                        <img src="/images/p.gif" width="9" height="1">
                                    </td>
                                    <td class="menu_item">
                                        <a href="/files/" class="menu_item_link">Torrents</a>
                                    </td>

                                                                    <td class="menu_separator">
                                        <img src="/images/p.gif" width="9" height="1">
                                    </td>
                                    <td class="menu_item">
                                        <a href="/top_torrents.php" class="menu_item_link">Top torrents</a>
                                    </td>

                                                                    <td class="menu_separator">
                                        <img src="/images/p.gif" width="9" height="1">
                                    </td>
                                    <td class="menu_item">
                                        <a href="http://www.demonoid.pw/torrent_upload.php" class="menu_item_link">Upload a torrent</a>
                                    </td>
                                    <td class="menu_separator">
                                        <img src="/images/p.gif" width="9" height="1">
                                    </td>
                                    <td class="menu_item">
                                        <a href="/faq.php" class="menu_item_link">FAQ</a>
                                    </td>

     <td class="menu_separator">
                                        <img src="/images/p.gif" width="9" height="1">
                                    </td>
                                    <td class="menu_item">
    <img src="/cached/twitter.png" width="15" height="12">
                                        <a href="https://twitter.com/DemonoidP2P" target="_blank" class="menu_item_link">Twitter</a>
                                    </td>

                                    <td class="menu_separator">
                                        <img src="/images/p.gif" width="9" height="1">
                                    </td>

                                        <td class="menu_item">
                                            <a href="/forum.php"  class="menu_item_link red" target="_blank" >Forum</a>
                                        </td>
     <td class="menu_separator">
                                        <img src="/images/p.gif" width="9" height="1">
                                    </td>

                                        <td class="menu_item">
                                            <a href="/donate.php"  class="menu_item_link red" target="_blank" >Support Demonoid</a>
                                        </td>
     <td class="menu_separator">
                                            <img src="/images/p.gif" width="9" height="1">
                                        </td>



                                </tr></table></td></tr><tr>

                        <td class="bnnr_top" id="bnr_r_top" height="70" style="height:72px!important;">

    <script src="//dltags.com/vpn/243320"></script>
    </td>
                                                <img src="/images/p.gif" width="1" height="1">
                        </td>
                    </tr>
                </table>
                <div id="fslispc">
                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                        <tr><td class="pad9px_left">
                                <noscript>
                                    <div style="background-color:#e9f9bf;border:1px solid #000;padding:10px;text-align:center;margin-left:auto;margin-right:auto;" class="highlight box pad10  center">JavaScript must be enabled in order to use all of the site\'s features. Please enable JavaScript in your browser and refresh the page.</div></noscript>

    <scrIpt src="/cached/dropdown7.js" type="text/javascript"></script><scrIpt src="/torrent_categories_script.php" type="text/javascript"></script>
    <table width="100%" border="0" cellspacing="0" cellpadding="0">

    	<tr>
    		<td class="ctable_top_left" height="30" width="22"><img src="/images/p.gif" width="22" height="1"></td>
    		<td class="ctable_header" width="100%">Filters</td>
    		<td class="ctable_top_right" height="30" width="1"0><img src="/images/p.gif" width=10 height=1></td>
    	</tr>
    </table>
    	<form action="/files/" name="filters_top" id="filters_top">
    <table width="100%" border="0" cellspacing="0" cellpadding="0">
    	<tr>
    		<td width="100%" class="ctable_content">
    			<center>
    		<table width="80%" border="0" cellspacing="0" cellpadding="3">
      <tr>
        <td width="15%">Category:</td>
        <td><select name="category" id="category" onChange="document.getElementById('filters_top').sort.value=''; if(sc_drop != undefined){update(this, sc_drop); update(this, q_drop); update(this, l_drop); build_rss_link();}" onKeyUp="document.getElementById('filters_top').sort.value=''; if(sc_drop != undefined){update(this, sc_drop); update(this, q_drop); update(this, l_drop); build_rss_link();}">
          <option value="0">All</option><option value="5">Applications</option><option value="17">Audio Books</option><option value="11">Books</option><option value="10">Comics</option><option value="4">Games</option><option value="9">Japanese Anime</option><option value="6">Miscellaneous</option><option value="1">Movies</option><option value="2">Music</option><option value="13">Music Videos</option><option value="8">Pictures</option><option value="3">TV</option>
        </select></td>
        <td width="15%">Subcategory: </td>
        <td><select name="subcategory" id="subcategory" onChange="if(sc_drop != undefined){build_rss_link();}" onKeyUp="if(sc_drop != undefined){build_rss_link();}">
    		  <option selected>All</option></select></td>
      </tr>
      <tr>
        <td>Language:</td>
        <td><select name="language" id="language" disabled>
    		   <option value="0" selected>None available</option></select></td>
        <td>Quality:</td>
        <td><select name="quality" id="quality">
    		  <option selected>All</option></select></td>
      </tr>
      <tr>
        <td>State:</td>
        <td><select name="seeded">
          <option value="0">Seeded</option>
          <option value="1">Unseeded</option>
          <option value="2" SELECTED>Both</option>
        </select></td>
        <td>Tracked by: </td>
        <td><select name="external">
          <option value="2" SELECTED>Both</option>
          <option value="0">Demonoid</option>
          <option value="1">External</option>
        </select></td>
      </tr>
      <tr align="center">
        <td colspan="4">Keywords: <input type="text" name="query" size="55" maxlength="50" value="" ><br><input name="to" type="checkbox" value="1"  /> Search torrent names only<input type="hidden" name="uid" value="0"><input type="hidden" name="sort" value=""> <input type="submit" value="Apply filters" class="regular_button"> <input type="button" value="Reset filters" class="regular_button" onClick="location.href='/files/'; return false;"></td>
      </tr></table></center><center><span id="rss_feed_link"><a href="/rss/0.xml">RSS feed - all categories<img src="/images/rss.jpg" alt="RSS Feed" width="16" height="16" hspace="5" border="0"></a><br><br><span class="pfooter">Support Demonoid with BitCoin: <a href="bitcoin:1DNoidLcUGHuijTB6rLNAu8Xm7bE5rvPtC">1DNoidLcUGHuijTB6rLNAu8Xm7bE5rvPtC</a></span></span></center>
    		</td>
    	</tr>
    </table>
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
        	<tr>
        		<td class="ctable_bottom_left" height="11" width="22"><img src="/images/p.gif" width="22" height="1"></td>
        		<td  class="ctable_bottom" width="100%"><img src="/images/p.gif" width="1" height="10"></td>
        		<td class="ctable_bottom_right" height="11" width="10"><img src="/images/p.gif" width="10" height="1"></td>

        	</tr>
        </table>
     	</form>
     <img src="/images/p.gif" width="1" height="7">
    <table width=100% border=0 cellspacing=0 cellpadding=0><tr><td class=ctable_top_left height=30 width=22><img src=/images/p.gif width=22 height=1></td><td class="ctable_header" width=100%>Sponsored links</td><td class=ctable_top_right height=30 width=10><img src=/images/p.gif width=10 height=1></td></tr></table>
    <table width=100% border=0 cellspacing=0 cellpadding=0>
    <tr><td width=100% class=ctable_content><table width="100%" border="0" cellpadding="0" cellspacing="0" class="font_12px"><tbody>

                    <tr align="center">
                        <td class="torrent_header_2">Category</td>
                        <td align="left" class="torrent_header_1" width="100%">Name</td>
    					<td class="torrent_header_2"></td>
                        <td class="torrent_header_1">Download</td>
                        <td class="torrent_header_2">Size</td>
                        <td class="torrent_header_1"><img src="/images/comments3.jpg" alt="Comments" title="Comments" width="17" height="17" border="0"></td>
                        <td class="torrent_header_2"><img src="/images/completed3.jpg" alt="Times completed" title="Times completed" width="17" height="17" border="0"></td>
    			        <td class="torrent_header_1"><img src="/images/seeders3.jpg" alt="Seeders" title="Seeders" width="17" height="17" border="0"></td>
    			        <td class="torrent_header_2"><img src="/images/leechers3.jpg" alt="Leechers" title="Leechers" width="17" height="17" border="0"></td>
    			        <!-- td class="torrent_header_1">Health</td -->
        </tr><!-- start torrent list --><tr>
          <td rowspan="2" align="center" class="tone_1_bl"><!-- tstart --><a href="/files/?uid=0&amp;category=17&amp;subcategory=0&amp;language=0&amp;seeded=2&amp;quality=0&amp;query=&amp;sort="><img src="/images/cats/movies.gif" height="30" alt="Movies" title="Movies" border="0"><!-- tend --></td>
          <td colspan="9" class="tone_1_pad"><a href="https://torrshield.com/#/" target="_blank">Born.to.Be.Blue.2015.Bluray.1080p.DTS-HD.x264-Grym</a> <font class="subcategory">[ Sponsored link ]</font> </td>
          </tr>
        <tr>
          <td width="100%" class="tone_1_bl" align="left"><a href="https://torrshield.com/#/" class="subcategory">Movies</a> : <a href="https://torrshield.com/#/" class="subcategory">Drama</a> : <a href="https://torrshield.com/#/" class="subcategory">English</a>&nbsp;</td>
          <td nowrap="" class="tone_2_bl" align="left"></td>


          <td nowrap="" class="tone_1_bl" align="center"><a href="https://torrshield.com/#/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="https://torrshield.com/#/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap="" class="tone_2_bl" align="right">11.88 GB</td>
          <td nowrap="" class="tone_1_bl" align="center">0</td>
          <td nowrap="" class="tone_2_bl" align="center"><font class="blue">0</font></td>
          <td nowrap="" class="tone_1_bl" align="center"><font class="green">2</font></td>
          <td nowrap="" class="tone_2_bl" align="center"><font class="red">7</font></td>

          </tr><tr>
          <td rowspan="2" align="center" class="tone_3_bl"><!-- tstart --><a href="/files/?uid=0&amp;category=17&amp;subcategory=0&amp;language=0&amp;seeded=2&amp;quality=0&amp;query=&amp;sort="><img src="/images/cats/books.gif" height="30" alt="Books" title="Books" border="0"><!-- tend --></td>
          <td colspan="9" class="tone_1_pad"><a href="https://torrshield.com/#/" target="_blank">Michel Foucault - A Collection of Books</a> <font class="subcategory">[ Sponsored link ]</font> </td>
          </tr>
        <tr>
          <td width="100%" class="tone_1_bl" align="left"><a href="https://torrshield.com/#/" class="subcategory">Books</a> : <a href="https://torrshield.com/#/" class="subcategory">General</a> : <a href="https://torrshield.com/#/" class="subcategory">English</a>&nbsp;</td>
          <td nowrap="" class="tone_2_bl" align="left"></td>


          <td nowrap="" class="tone_1_bl" align="center"><a href="https://torrshield.com/#/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="https://torrshield.com/#/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap="" class="tone_2_bl" align="right">3.31 GB</td>
          <td nowrap="" class="tone_1_bl" align="center">0</td>
          <td nowrap="" class="tone_2_bl" align="center"><font class="blue">0</font></td>
          <td nowrap="" class="tone_1_bl" align="center"><font class="green">3</font></td>
          <td nowrap="" class="tone_2_bl" align="center"><font class="red">4</font></td>

          </tr><tr>
          <td rowspan="2" align="center" class="tone_1_bl"><!-- tstart --><a href="/files/?uid=0&amp;category=17&amp;subcategory=0&amp;language=0&amp;seeded=2&amp;quality=0&amp;query=&amp;sort="><img src="/images/cats/movies.gif" height="30" alt="Movies" title="Movies" border="0"><!-- tend --></td>
          <td colspan="9" class="tone_1_pad"><a href="https://torrshield.com/#/" target="_blank">A Hologram for the King 2016 BRRip XviD AC3-EVO</a> <font class="subcategory">[ Sponsored link ]</font> </td>
          </tr>
        <tr>
          <td width="100%" class="tone_1_bl" align="left"><a href="https://torrshield.com/#/" class="subcategory">Movies</a> : <a href="https://torrshield.com/#/" class="subcategory">Comedy</a> : <a href="https://torrshield.com/#/" class="subcategory">English</a>&nbsp;</td>
          <td nowrap="" class="tone_2_bl" align="left"></td>


          <td nowrap="" class="tone_1_bl" align="center"><a href="https://torrshield.com/#/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="https://torrshield.com/#/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap="" class="tone_2_bl" align="right">1.38 GB</td>
          <td nowrap="" class="tone_1_bl" align="center">0</td>
          <td nowrap="" class="tone_2_bl" align="center"><font class="blue">0</font></td>
          <td nowrap="" class="tone_1_bl" align="center"><font class="green">1</font></td>
          <td nowrap="" class="tone_2_bl" align="center"><font class="red">0</font></td>

          </tr> <!-- end torrent list --></tr>

         </tbody></table></td></tr></table>
    	<table width=100% border=0 cellspacing=0 cellpadding=0>
    	<tr><td class=ctable_bottom_left height=11 width=22><img src=/images/p.gif width=22 height=1></td><td  class="ctable_bottom" width=100%><img src=/images/p.gif width=1 height=10></td><td class=ctable_bottom_right height=11 width=10><img src=/images/p.gif width=10 height=1></td></tr></table><img src=/images/p.gif width=1 height=7>
    <table width="100%" border="0" cellspacing="0" cellpadding="0">

    	<tr>
    		<td class="ctable_top_left" height="30" width="22"><img src="/images/p.gif" width="22" height="1"></td>
    		<td class="ctable_header" width="100%">Torrent listing</td>
    		<td class="ctable_top_right" height="30" width="1"0><img src="/images/p.gif" width=10 height=1></td>
    	</tr>
    </table>

    <table width="100%" border="0" cellspacing="0" cellpadding="0">
    	<tr>
    		<td width="100%" class="ctable_content_no_pad">
    			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="font_12px"><tr align="right">
                    <td colspan="9" class="tone_3_bl"> <img src="/images/3blinks.gif" alt="" width="9" height="9" hspace="3" border="0">Sort by:

    				<select name="sort" id="sortsel" onBlur="document.getElementById('filters_top').sort.value=this.value; document.getElementById('filters_bottom').sort.value=this.value;" onChange="document.getElementById('filters_top').sort.value=this.value;  document.getElementById('filters_bottom').sort.value=this.value;">
    		<option value="" SELECTED>Date (Default)</option>
    		<option value="C">Completed Desc</option>
    		<option value="c">Completed Asc</option>




    		<option value="L">Leechers Desc</option>
    		<option value="l">Leechers Asc</option>

    		<option value="S">Seeds Desc</option>
    		<option value="s">Seeds Asc</option>

    		<option value="B">Size Desc</option>
    		<option value="b">Size Asc</option>
    </select> <input type="submit" class="regular_button" value="Apply" onClick="document.getElementById('filters_top').submit();">
    				</td>
                    </tr><tr align="center">
                    <td colspan="9" class="tone_3_bl">&lt;&lt; Prev&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href=/files/?to=0&uid=0&category=0&subcategory=0&language=0&seeded=2&quality=0&external=2&query=&sort=&page=2 class="menu">Next &gt;&gt;</a></td>
                    </tr>
                    <tr align="center">
                        <td colspan="9" class="tone_2_bl">| <b><u>1 - 50</u></b> | <a href="/files/?to=0&uid=0&category=0&subcategory=0&language=0&seeded=2&quality=0&external=2&query=&sort=&page=2">51 - 100</a> | <a href="/files/?to=0&uid=0&category=0&subcategory=0&language=0&seeded=2&quality=0&external=2&query=&sort=&page=3">101 - 150</a> | <a href="/files/?to=0&uid=0&category=0&subcategory=0&language=0&seeded=2&quality=0&external=2&query=&sort=&page=4">151 - 200</a> | <a href="/files/?to=0&uid=0&category=0&subcategory=0&language=0&seeded=2&quality=0&external=2&query=&sort=&page=5">201 - 250</a> | <a href="/files/?to=0&uid=0&category=0&subcategory=0&language=0&seeded=2&quality=0&external=2&query=&sort=&page=6">251 - 300</a> | <a href="/files/?to=0&uid=0&category=0&subcategory=0&language=0&seeded=2&quality=0&external=2&query=&sort=&page=7">301 - 350</a> | <a href="/files/?to=0&uid=0&category=0&subcategory=0&language=0&seeded=2&quality=0&external=2&query=&sort=&page=8">351 - 400</a> | <a href="/files/?to=0&uid=0&category=0&subcategory=0&language=0&seeded=2&quality=0&external=2&query=&sort=&page=9">401 - 450</a> | <a href="/files/?to=0&uid=0&category=0&subcategory=0&language=0&seeded=2&quality=0&external=2&query=&sort=&page=10">451 - 500</a> | <a href="/files/?to=0&uid=0&category=0&subcategory=0&language=0&seeded=2&quality=0&external=2&query=&sort=&page=11">501 - 550</a> | <a href="/files/?to=0&uid=0&category=0&subcategory=0&language=0&seeded=2&quality=0&external=2&query=&sort=&page=12">551 - 600</a> | <a href="/files/?to=0&uid=0&category=0&subcategory=0&language=0&seeded=2&quality=0&external=2&query=&sort=&page=13">601 - 650</a> | <a href="/files/?to=0&uid=0&category=0&subcategory=0&language=0&seeded=2&quality=0&external=2&query=&sort=&page=14">651 - 700</a> | <a href="/files/?to=0&uid=0&category=0&subcategory=0&language=0&seeded=2&quality=0&external=2&query=&sort=&page=15">701 - 750</a> | <a href="/files/?to=0&uid=0&category=0&subcategory=0&language=0&seeded=2&quality=0&external=2&query=&sort=&page=16">751 - 800</a> | <b>&laquo;&raquo;</b> |  <strong>688,442 items total</strong></td>
                    </tr>
                    <tr align="center">
                        <td class="torrent_header_2">Category</td>
                        <td align="left" class="torrent_header_1" width=100%>Name</td>
    					<td class="torrent_header_2">Owner</td>
                        <td class="torrent_header_1">Download</td>
                        <td class="torrent_header_2">Size</td>
                        <td class="torrent_header_1"><img src="/images/comments3.jpg" alt="Comments" title="Comments" width="17" height="17" border="0"></td>
                        <td class="torrent_header_2"><img src="/images/completed3.jpg" alt="Times completed" title="Times completed" width="17" height="17" border="0"></td>
    			        <td class="torrent_header_1"><img src="/images/seeders3.jpg" alt="Seeders" title="Seeders" width="17" height="17" border="0"></td>
    			        <td class="torrent_header_2"><img src="/images/leechers3.jpg" alt="Leechers" title="Leechers" width="17" height="17" border="0"></td>
    			        <!-- td class="torrent_header_1">Health</td -->
        </tr><!-- start torrent list --><tr align="left" bgcolor="#CCCCCC">
        <td colspan="9" class="added_today">Added today</td>
        </tr><tr>
          <td rowspan="2" align="center" class="tone_2_bl"><!-- tstart --><a href="/files/?uid=0&category=1&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/movies.gif" height="30" alt="Movies" title="Movies" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_1_pad"><a href="/files/details/3406738/0017045651472/" >Born.to.Be.Blue.20 15.Bluray.1080p.DT S-HD.x264-Grym</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_1_bl" align="left"><a href="/files/?uid=0&category=1&subcategory=12&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Drama</a> : <a href="/files/?uid=0&category=1&subcategory=0&language=0&seeded=2&quality=68&query=&sort=" class="subcategory">HD 1080p / 1080i</a> : <a href="/files/?uid=0&category=1&subcategory=0&language=1&seeded=2&quality=0&query=&sort=" class="subcategory">English</a>&nbsp;</td>
          <td nowrap class="tone_2_bl" align="left"><a href="/users/vonRicht" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">vonRicht</a></td>


          <td nowrap class="tone_1_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406738/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406738/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_2_bl" align="right">11.88 GB</td>
          <td nowrap class="tone_1_bl" align="center">0</td>
          <td nowrap class="tone_2_bl" align="center"><font class="blue">0</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="green">2</font></td>
          <td nowrap class="tone_2_bl" align="center"><font class="red">7</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_1_bl"><!-- tstart --><a href="/files/?uid=0&category=11&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/books.gif" height="30" alt="Books" title="Books" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_3_pad"><a href="/files/details/3406736/0012784238604/" >Michel Foucault - A Collection of Books</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_3_bl" align="left"><a href="/files/?uid=0&category=11&subcategory=125&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">General</a> : <a href="/files/?uid=0&category=11&subcategory=0&language=1&seeded=2&quality=0&query=&sort=" class="subcategory">English</a>&nbsp;</td>
          <td nowrap class="tone_1_bl" align="left"><a href="/users/bubonic420" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">bubonic420</a></td>


          <td nowrap class="tone_3_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406736/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406736/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_1_bl" align="right">3.31 GB</td>
          <td nowrap class="tone_3_bl" align="center">0</td>
          <td nowrap class="tone_1_bl" align="center"><font class="blue">0</font></td>
          <td nowrap class="tone_3_bl" align="center"><font class="green">3</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="red">4</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_2_bl"><!-- tstart --><a href="/files/?uid=0&category=1&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/movies.gif" height="30" alt="Movies" title="Movies" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_1_pad"><a href="/files/details/3406734/008522825736/" >A Hologram for the King 2016 BRRip XviD AC3-EVO</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_1_bl" align="left"><a href="/files/?uid=0&category=1&subcategory=10&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Comedy</a> : <a href="/files/?uid=0&category=1&subcategory=0&language=0&seeded=2&quality=23&query=&sort=" class="subcategory">Other quality</a> : <a href="/files/?uid=0&category=1&subcategory=0&language=1&seeded=2&quality=0&query=&sort=" class="subcategory">English</a>&nbsp;</td>
          <td nowrap class="tone_2_bl" align="left"><a href="/users/maxspeeds" class="vip"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.20" title="Ratio: 1.20"><img src="/images/p.gif" alt="" width="2" height="1" border="0">maxspeeds</a></td>


          <td nowrap class="tone_1_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406734/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406734/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_2_bl" align="right">1.38 GB</td>
          <td nowrap class="tone_1_bl" align="center">0</td>
          <td nowrap class="tone_2_bl" align="center"><font class="blue">0</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="green">1</font></td>
          <td nowrap class="tone_2_bl" align="center"><font class="red">0</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_1_bl"><!-- tstart --><a href="/files/?uid=0&category=1&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/movies.gif" height="30" alt="Movies" title="Movies" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_3_pad"><a href="/files/details/3406730/002130706434/" >A Man and a Woman 2016 Korean 720p BRRip 850 MB - iExTV</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_3_bl" align="left"><a href="/files/?uid=0&category=1&subcategory=12&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Drama</a> : <a href="/files/?uid=0&category=1&subcategory=0&language=0&seeded=2&quality=72&query=&sort=" class="subcategory">Blu-ray </a> : <a href="/files/?uid=0&category=1&subcategory=0&language=21&seeded=2&quality=0&query=&sort=" class="subcategory">Korean </a>&nbsp;</td>
          <td nowrap class="tone_1_bl" align="left"><a href="/users/SSSWAT" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">SSSWAT</a></td>


          <td nowrap class="tone_3_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406730/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406730/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_1_bl" align="right">849.98 MB</td>
          <td nowrap class="tone_3_bl" align="center">0</td>
          <td nowrap class="tone_1_bl" align="center"><font class="blue">6</font></td>
          <td nowrap class="tone_3_bl" align="center"><font class="green">10</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="red">18</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_2_bl"><!-- tstart --><a href="/files/?uid=0&category=2&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/music.gif" height="30" alt="Music" title="Music" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_1_pad"><a href="/files/details/3406728/0017045651472/" >Various Artists - Dore LA Soul Sides Volume 2</a></td>
          </tr>
        <tr>
          <td width="100%" class="tone_1_bl" align="left"><a href="/files/?uid=0&category=2&subcategory=188&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Soul</a> : <a href="/files/?uid=0&category=2&subcategory=0&language=0&seeded=2&quality=62&query=&sort=" class="subcategory">Lossless</a>&nbsp;</td>
          <td nowrap class="tone_2_bl" align="left"><a href="/users/Magister1963" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.36" title="Ratio: 1.36"><img src="/images/p.gif" alt="" width="2" height="1" border="0">Magister1963</a></td>


          <td nowrap class="tone_1_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406728/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406728/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_2_bl" align="right">283.20 MB</td>
          <td nowrap class="tone_1_bl" align="center">0</td>
          <td nowrap class="tone_2_bl" align="center"><font class="blue">0</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="green">1</font></td>
          <td nowrap class="tone_2_bl" align="center"><font class="red">0</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_1_bl"><!-- tstart --><a href="/files/?uid=0&category=3&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/tv.gif" height="30" alt="TV" title="TV" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_3_pad"><a href="/files/details/3406726/0012784238604/" >Mygrations S01E04 HDTV x264 [StB]</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_3_bl" align="left"><a href="/files/?uid=0&category=3&subcategory=197&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Documentary</a> : <a href="/files/?uid=0&category=3&subcategory=0&language=0&seeded=2&quality=69&query=&sort=" class="subcategory">HD</a> : <a href="/files/?uid=0&category=3&subcategory=0&language=1&seeded=2&quality=0&query=&sort=" class="subcategory">English</a>&nbsp;</td>
          <td nowrap class="tone_1_bl" align="left"><a href="/users/SimplyTB" class="vip"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.55" title="Ratio: 1.55"><img src="/images/p.gif" alt="" width="2" height="1" border="0">SimplyTB</a></td>


          <td nowrap class="tone_3_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406726/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406726/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_1_bl" align="right">450.54 MB</td>
          <td nowrap class="tone_3_bl" align="center">0</td>
          <td nowrap class="tone_1_bl" align="center"><font class="blue">0</font></td>
          <td nowrap class="tone_3_bl" align="center"><font class="green">3</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="red">3</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_2_bl"><!-- tstart --><a href="/files/?uid=0&category=2&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/music.gif" height="30" alt="Music" title="Music" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_1_pad"><a href="/files/details/3406724/008522825736/" >Various Artists - Brent Superb 60s Soul Sounds</a></td>
          </tr>
        <tr>
          <td width="100%" class="tone_1_bl" align="left"><a href="/files/?uid=0&category=2&subcategory=188&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Soul</a> : <a href="/files/?uid=0&category=2&subcategory=0&language=0&seeded=2&quality=62&query=&sort=" class="subcategory">Lossless</a>&nbsp;</td>
          <td nowrap class="tone_2_bl" align="left"><a href="/users/Magister1963" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.36" title="Ratio: 1.36"><img src="/images/p.gif" alt="" width="2" height="1" border="0">Magister1963</a></td>


          <td nowrap class="tone_1_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406724/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406724/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_2_bl" align="right">221.78 MB</td>
          <td nowrap class="tone_1_bl" align="center">0</td>
          <td nowrap class="tone_2_bl" align="center"><font class="blue">0</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="green">1</font></td>
          <td nowrap class="tone_2_bl" align="center"><font class="red">0</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_1_bl"><!-- tstart --><a href="/files/?uid=0&category=3&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/tv.gif" height="30" alt="TV" title="TV" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_3_pad"><a href="/files/details/3406722/004261412868/" >Minority report S01e03 V 1080</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_3_bl" align="left"><a href="/files/?uid=0&category=3&subcategory=206&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Sci-Fi</a> : <a href="/files/?uid=0&category=3&subcategory=0&language=0&seeded=2&quality=69&query=&sort=" class="subcategory">HD</a> : <a href="/files/?uid=0&category=3&subcategory=0&language=4&seeded=2&quality=0&query=&sort=" class="subcategory">Italian</a>&nbsp;</td>
          <td nowrap class="tone_1_bl" align="left"><a href="/users/javier59" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.52" title="Ratio: 1.52"><img src="/images/p.gif" alt="" width="2" height="1" border="0">javier59</a></td>


          <td nowrap class="tone_3_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406722/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406722/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_1_bl" align="right">1.68 GB</td>
          <td nowrap class="tone_3_bl" align="center">0</td>
          <td nowrap class="tone_1_bl" align="center"><font class="blue">109</font></td>
          <td nowrap class="tone_3_bl" align="center"><font class="green">49</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="red">36</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_2_bl"><!-- tstart --><a href="/files/?uid=0&category=5&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/applications.gif" height="30" alt="Applications" title="Applications" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_1_pad"><a href="/files/details/3406718/0017045651472/" >Internet Download Manager 6.25 Build 24 Full - Freeware Sys</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_1_bl" align="left"><a href="/files/?uid=0&category=5&subcategory=1&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Windows</a> : <a href="/files/?uid=0&category=5&subcategory=0&language=1&seeded=2&quality=0&query=&sort=" class="subcategory">English</a>&nbsp;</td>
          <td nowrap class="tone_2_bl" align="left"><a href="/users/ranasalman007" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">ranasalman007</a></td>


          <td nowrap class="tone_1_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406718/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406718/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_2_bl" align="right">9.19 MB</td>
          <td nowrap class="tone_1_bl" align="center">0</td>
          <td nowrap class="tone_2_bl" align="center"><font class="blue">0</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="green">1</font></td>
          <td nowrap class="tone_2_bl" align="center"><font class="red">0</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_1_bl"><!-- tstart --><a href="/files/?uid=0&category=3&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/tv.gif" height="30" alt="TV" title="TV" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_3_pad"><a href="/files/details/3406716/0012784238604/" >Smithsonian.Channe l.Viper.Queens.720 p.HDTV.x264.AAC.MV Group.org.mp4</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_3_bl" align="left"><a href="/files/?uid=0&category=3&subcategory=11&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Documentary</a> : <a href="/files/?uid=0&category=3&subcategory=0&language=0&seeded=2&quality=66&query=&sort=" class="subcategory">HD 720p</a> : <a href="/files/?uid=0&category=3&subcategory=0&language=1&seeded=2&quality=0&query=&sort=" class="subcategory">English</a>&nbsp;</td>
          <td nowrap class="tone_1_bl" align="left"><a href="/users/MVGroup" class="vip"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">MVGroup</a></td>


          <td nowrap class="tone_3_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406716/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406716/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_1_bl" align="right">1.02 GB</td>
          <td nowrap class="tone_3_bl" align="center">0</td>
          <td nowrap class="tone_1_bl" align="center"><font class="blue">0</font></td>
          <td nowrap class="tone_3_bl" align="center"><font class="green">1</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="red">0</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_2_bl"><!-- tstart --><a href="/files/?uid=0&category=11&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/books.gif" height="30" alt="Books" title="Books" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_1_pad"><a href="/files/details/3406714/008522825736/" >Biochemistry 8th Edition c2015 Berg &amp; Tymoczko txtbk</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_1_bl" align="left"><a href="/files/?uid=0&category=11&subcategory=138&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Educational</a> : <a href="/files/?uid=0&category=11&subcategory=0&language=1&seeded=2&quality=0&query=&sort=" class="subcategory">English</a>&nbsp;</td>
          <td nowrap class="tone_2_bl" align="left"><a href="/users/dynstab1" class="user"><img src="/images/ratio/n3p.gif" border="0" width="8" height="8" alt="Ratio: 3.79" title="Ratio: 3.79"><img src="/images/p.gif" alt="" width="2" height="1" border="0">dynstab1</a></td>


          <td nowrap class="tone_1_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406714/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406714/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_2_bl" align="right">45.51 MB</td>
          <td nowrap class="tone_1_bl" align="center">0</td>
          <td nowrap class="tone_2_bl" align="center"><font class="blue">37</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="green">2</font></td>
          <td nowrap class="tone_2_bl" align="center"><font class="red">2</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_1_bl"><!-- tstart --><a href="/files/?uid=0&category=2&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/music.gif" height="30" alt="Music" title="Music" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_3_pad"><a href="/files/details/3406710/002130706434/" >DJ Khaled – Major Key (2016) [iTunes~M4a~VBR]~[ Hunter] [FRG]</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_3_bl" align="left"><a href="/files/?uid=0&category=2&subcategory=43&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Hip-Hop / Rap</a> : <a href="/files/?uid=0&category=2&subcategory=0&language=0&seeded=2&quality=18&query=&sort=" class="subcategory">AAC</a>&nbsp;</td>
          <td nowrap class="tone_1_bl" align="left"><a href="/users/FTHunter" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">FTHunter</a></td>


          <td nowrap class="tone_3_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406710/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406710/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_1_bl" align="right">125.81 MB</td>
          <td nowrap class="tone_3_bl" align="center">0</td>
          <td nowrap class="tone_1_bl" align="center"><font class="blue">0</font></td>
          <td nowrap class="tone_3_bl" align="center"><font class="green">1</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="red">0</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_2_bl"><!-- tstart --><a href="/files/?uid=0&category=2&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/music.gif" height="30" alt="Music" title="Music" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_1_pad"><a href="/files/details/3406708/0017045651472/" >French Paddleboat - Conversions In Metric (Electro/Ambient) FLAC</a></td>
          </tr>
        <tr>
          <td width="100%" class="tone_1_bl" align="left"><a href="/files/?uid=0&category=2&subcategory=37&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Electro / Techno</a> : <a href="/files/?uid=0&category=2&subcategory=0&language=0&seeded=2&quality=62&query=&sort=" class="subcategory">Lossless</a>&nbsp;</td>
          <td nowrap class="tone_2_bl" align="left"><a href="/users/avantgarterbelt" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">avantgarterbelt</a></td>


          <td nowrap class="tone_1_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406708/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406708/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_2_bl" align="right">187.67 MB</td>
          <td nowrap class="tone_1_bl" align="center">0</td>
          <td nowrap class="tone_2_bl" align="center"><font class="blue">0</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="green">1</font></td>
          <td nowrap class="tone_2_bl" align="center"><font class="red">0</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_1_bl"><!-- tstart --><a href="/files/?uid=0&category=10&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/comics.gif" height="30" alt="Comics" title="Comics" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_3_pad"><a href="/files/details/3406706/0012784238604/" >Angora Napkin (v01-v02) (2009-2012) (digital) (Minutemen-Entombe d) (- Nem -)</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_3_bl" align="left"><a href="/files/?uid=0&category=10&subcategory=229&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Other</a> : <a href="/files/?uid=0&category=10&subcategory=0&language=1&seeded=2&quality=0&query=&sort=" class="subcategory">English</a>&nbsp;</td>
          <td nowrap class="tone_1_bl" align="left"><a href="/users/Nemesis43" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">Nemesis43</a></td>


          <td nowrap class="tone_3_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406706/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406706/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_1_bl" align="right">388.31 MB</td>
          <td nowrap class="tone_3_bl" align="center">0</td>
          <td nowrap class="tone_1_bl" align="center"><font class="blue">0</font></td>
          <td nowrap class="tone_3_bl" align="center"><font class="green">1</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="red">0</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_2_bl"><!-- tstart --><a href="/files/?uid=0&category=2&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/music.gif" height="30" alt="Music" title="Music" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_1_pad"><a href="/files/details/3406704/008522825736/" >Hillary Scott &amp; the Scott Family - Love Remains (2016) [MP3~320Kbps]~[Hun ter] [FRG]</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_1_bl" align="left"><a href="/files/?uid=0&category=2&subcategory=36&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Country</a> : <a href="/files/?uid=0&category=2&subcategory=0&language=0&seeded=2&quality=20&query=&sort=" class="subcategory">MP3/Over 256Kbps</a>&nbsp;</td>
          <td nowrap class="tone_2_bl" align="left"><a href="/users/FTHunter" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">FTHunter</a></td>


          <td nowrap class="tone_1_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406704/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406704/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_2_bl" align="right">120.66 MB</td>
          <td nowrap class="tone_1_bl" align="center">0</td>
          <td nowrap class="tone_2_bl" align="center"><font class="blue">0</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="green">1</font></td>
          <td nowrap class="tone_2_bl" align="center"><font class="red">0</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_1_bl"><!-- tstart --><a href="/files/?uid=0&category=10&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/comics.gif" height="30" alt="Comics" title="Comics" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_3_pad"><a href="/files/details/3406702/004261412868/" >Superior Iron Man Vol. 02 - Stark Contrast (2015) (digital TPB) (Minutemen-Slayer) .cbr (- Nem -)</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_3_bl" align="left"><a href="/files/?uid=0&category=10&subcategory=222&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Super Hero</a> : <a href="/files/?uid=0&category=10&subcategory=0&language=1&seeded=2&quality=0&query=&sort=" class="subcategory">English</a>&nbsp;</td>
          <td nowrap class="tone_1_bl" align="left"><a href="/users/Nemesis43" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">Nemesis43</a></td>


          <td nowrap class="tone_3_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406702/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406702/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_1_bl" align="right">223.35 MB</td>
          <td nowrap class="tone_3_bl" align="center">0</td>
          <td nowrap class="tone_1_bl" align="center"><font class="blue">0</font></td>
          <td nowrap class="tone_3_bl" align="center"><font class="green">1</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="red">0</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_2_bl"><!-- tstart --><a href="/files/?uid=0&category=10&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/comics.gif" height="30" alt="Comics" title="Comics" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_1_pad"><a href="/files/details/3406700/002130706434/" >New Lone Wolf and Cub v8 (2016) (Humperdido).cbr (- Nem -)</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_1_bl" align="left"><a href="/files/?uid=0&category=10&subcategory=285&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Manga</a> : <a href="/files/?uid=0&category=10&subcategory=0&language=1&seeded=2&quality=0&query=&sort=" class="subcategory">English</a>&nbsp;</td>
          <td nowrap class="tone_2_bl" align="left"><a href="/users/Nemesis43" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">Nemesis43</a></td>


          <td nowrap class="tone_1_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406700/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406700/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_2_bl" align="right">221.09 MB</td>
          <td nowrap class="tone_1_bl" align="center">0</td>
          <td nowrap class="tone_2_bl" align="center"><font class="blue">0</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="green">1</font></td>
          <td nowrap class="tone_2_bl" align="center"><font class="red">0</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_1_bl"><!-- tstart --><a href="/files/?uid=0&category=10&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/comics.gif" height="30" alt="Comics" title="Comics" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_3_pad"><a href="/files/details/3406698/0017045651472/" >B.P.R.D. Hell on Earth - Russia (001-005) (2011-2012) (digital) (Minutemen-Azkaban ) (- Nem -)</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_3_bl" align="left"><a href="/files/?uid=0&category=10&subcategory=224&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Horror</a> : <a href="/files/?uid=0&category=10&subcategory=0&language=1&seeded=2&quality=0&query=&sort=" class="subcategory">English</a>&nbsp;</td>
          <td nowrap class="tone_1_bl" align="left"><a href="/users/Nemesis43" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">Nemesis43</a></td>


          <td nowrap class="tone_3_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406698/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406698/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_1_bl" align="right">206.43 MB</td>
          <td nowrap class="tone_3_bl" align="center">0</td>
          <td nowrap class="tone_1_bl" align="center"><font class="blue">0</font></td>
          <td nowrap class="tone_3_bl" align="center"><font class="green">1</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="red">0</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_2_bl"><!-- tstart --><a href="/files/?uid=0&category=2&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/music.gif" height="30" alt="Music" title="Music" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_1_pad"><a href="/files/details/3406696/0012784238604/" >ZHU - Generationwhy (Deluxe) (2016) [MP3~320Kbps]~[Hun ter] [FRG]</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_1_bl" align="left"><a href="/files/?uid=0&category=2&subcategory=37&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Electro / Techno</a> : <a href="/files/?uid=0&category=2&subcategory=0&language=0&seeded=2&quality=20&query=&sort=" class="subcategory">MP3/Over 256Kbps</a>&nbsp;</td>
          <td nowrap class="tone_2_bl" align="left"><a href="/users/FTHunter" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">FTHunter</a></td>


          <td nowrap class="tone_1_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406696/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406696/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_2_bl" align="right">136.14 MB</td>
          <td nowrap class="tone_1_bl" align="center">0</td>
          <td nowrap class="tone_2_bl" align="center"><font class="blue">0</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="green">1</font></td>
          <td nowrap class="tone_2_bl" align="center"><font class="red">0</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_1_bl"><!-- tstart --><a href="/files/?uid=0&category=2&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/music.gif" height="30" alt="Music" title="Music" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_3_pad"><a href="/files/details/3406694/008522825736/" >Group 1 Crew - Power (2016) [MP3~320Kbps]~[Hun ter] [FRG]</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_3_bl" align="left"><a href="/files/?uid=0&category=2&subcategory=43&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Hip-Hop / Rap</a> : <a href="/files/?uid=0&category=2&subcategory=0&language=0&seeded=2&quality=20&query=&sort=" class="subcategory">MP3/Over 256Kbps</a>&nbsp;</td>
          <td nowrap class="tone_1_bl" align="left"><a href="/users/FTHunter" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">FTHunter</a></td>


          <td nowrap class="tone_3_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406694/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406694/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_1_bl" align="right">148.16 MB</td>
          <td nowrap class="tone_3_bl" align="center">0</td>
          <td nowrap class="tone_1_bl" align="center"><font class="blue">0</font></td>
          <td nowrap class="tone_3_bl" align="center"><font class="green">1</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="red">0</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_2_bl"><!-- tstart --><a href="/files/?uid=0&category=2&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/music.gif" height="30" alt="Music" title="Music" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_1_pad"><a href="/files/details/3406692/004261412868/" >Death Spells - Nothing Above, Nothing Below (2016) [MP3~320Kbps]~[Hun ter] [FRG]</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_1_bl" align="left"><a href="/files/?uid=0&category=2&subcategory=32&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Rock</a> : <a href="/files/?uid=0&category=2&subcategory=0&language=0&seeded=2&quality=20&query=&sort=" class="subcategory">MP3/Over 256Kbps</a>&nbsp;</td>
          <td nowrap class="tone_2_bl" align="left"><a href="/users/FTHunter" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">FTHunter</a></td>


          <td nowrap class="tone_1_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406692/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406692/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_2_bl" align="right">100.65 MB</td>
          <td nowrap class="tone_1_bl" align="center">0</td>
          <td nowrap class="tone_2_bl" align="center"><font class="blue">0</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="green">1</font></td>
          <td nowrap class="tone_2_bl" align="center"><font class="red">0</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_1_bl"><!-- tstart --><a href="/files/?uid=0&category=2&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/music.gif" height="30" alt="Music" title="Music" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_3_pad"><a href="/files/details/3406688/0017045651472/" >Jake Owen - American Love (2016) [320] [MP3~320Kbps]~[Hun ter] [FRG]</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_3_bl" align="left"><a href="/files/?uid=0&category=2&subcategory=36&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Country</a> : <a href="/files/?uid=0&category=2&subcategory=0&language=0&seeded=2&quality=20&query=&sort=" class="subcategory">MP3/Over 256Kbps</a>&nbsp;</td>
          <td nowrap class="tone_1_bl" align="left"><a href="/users/FTHunter" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">FTHunter</a></td>


          <td nowrap class="tone_3_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406688/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406688/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_1_bl" align="right">92.20 MB</td>
          <td nowrap class="tone_3_bl" align="center">0</td>
          <td nowrap class="tone_1_bl" align="center"><font class="blue">111</font></td>
          <td nowrap class="tone_3_bl" align="center"><font class="green">29</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="red">16</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_2_bl"><!-- tstart --><a href="/files/?uid=0&category=2&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/music.gif" height="30" alt="Music" title="Music" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_1_pad"><a href="/files/details/3406686/0012784238604/" >Bob Marley &amp; The Wailers - 1976-05-26 Los Angeles, CA [2CD SBD / FLAC] [Live at The Roxy]</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_1_bl" align="left"><a href="/files/?uid=0&category=2&subcategory=41&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Reggae</a> : <a href="/files/?uid=0&category=2&subcategory=0&language=0&seeded=2&quality=62&query=&sort=" class="subcategory">Lossless</a>&nbsp;</td>
          <td nowrap class="tone_2_bl" align="left"><a href="/users/titoulien" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">titoulien</a></td>


          <td nowrap class="tone_1_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406686/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406686/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_2_bl" align="right">574.67 MB</td>
          <td nowrap class="tone_1_bl" align="center">0</td>
          <td nowrap class="tone_2_bl" align="center"><font class="blue">0</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="green">1</font></td>
          <td nowrap class="tone_2_bl" align="center"><font class="red">0</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_1_bl"><!-- tstart --><a href="/files/?uid=0&category=2&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/music.gif" height="30" alt="Music" title="Music" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_3_pad"><a href="/files/details/3406684/008522825736/" >Jason Richardson - I (2016) [MP3~320Kbps]~[Hun ter] [FRG]</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_3_bl" align="left"><a href="/files/?uid=0&category=2&subcategory=35&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Metal</a> : <a href="/files/?uid=0&category=2&subcategory=0&language=0&seeded=2&quality=20&query=&sort=" class="subcategory">MP3/Over 256Kbps</a>&nbsp;</td>
          <td nowrap class="tone_1_bl" align="left"><a href="/users/FTHunter" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">FTHunter</a></td>


          <td nowrap class="tone_3_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406684/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406684/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_1_bl" align="right">140.63 MB</td>
          <td nowrap class="tone_3_bl" align="center">0</td>
          <td nowrap class="tone_1_bl" align="center"><font class="blue">0</font></td>
          <td nowrap class="tone_3_bl" align="center"><font class="green">1</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="red">0</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_2_bl"><!-- tstart --><a href="/files/?uid=0&category=1&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/movies.gif" height="30" alt="Movies" title="Movies" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_1_pad"><a href="/files/details/3406682/004261412868/" >La chance de ma vie (2010) BDRip BBT</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_1_bl" align="left"><a href="/files/?uid=0&category=1&subcategory=20&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Romance</a> : <a href="/files/?uid=0&category=1&subcategory=0&language=0&seeded=2&quality=9&query=&sort=" class="subcategory">DVD Rip</a> : <a href="/files/?uid=0&category=1&subcategory=0&language=3&seeded=2&quality=0&query=&sort=" class="subcategory">French</a>&nbsp;</td>
          <td nowrap class="tone_2_bl" align="left"><a href="/users/maknol" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 2.32" title="Ratio: 2.32"><img src="/images/p.gif" alt="" width="2" height="1" border="0">maknol</a></td>


          <td nowrap class="tone_1_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406682/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406682/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_2_bl" align="right">2.18 GB</td>
          <td nowrap class="tone_1_bl" align="center">0</td>
          <td nowrap class="tone_2_bl" align="center"><font class="blue">0</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="green">1</font></td>
          <td nowrap class="tone_2_bl" align="center"><font class="red">0</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_1_bl"><!-- tstart --><a href="/files/?uid=0&category=10&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/comics.gif" height="30" alt="Comics" title="Comics" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_3_pad"><a href="/files/details/3406680/002130706434/" >Natasha 03 - The Metal Memory (Walthéry, 1977) (Scanlation, 2016).cbr (- Nem -)</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_3_bl" align="left"><a href="/files/?uid=0&category=10&subcategory=229&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Other</a> : <a href="/files/?uid=0&category=10&subcategory=0&language=1&seeded=2&quality=0&query=&sort=" class="subcategory">English</a>&nbsp;</td>
          <td nowrap class="tone_1_bl" align="left"><a href="/users/Nemesis43" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">Nemesis43</a></td>


          <td nowrap class="tone_3_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406680/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406680/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_1_bl" align="right">77.01 MB</td>
          <td nowrap class="tone_3_bl" align="center">0</td>
          <td nowrap class="tone_1_bl" align="center"><font class="blue">6</font></td>
          <td nowrap class="tone_3_bl" align="center"><font class="green">3</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="red">3</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_2_bl"><!-- tstart --><a href="/files/?uid=0&category=3&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/tv.gif" height="30" alt="TV" title="TV" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_1_pad"><a href="/files/details/3406678/0017045651472/" >National.Geographi c.Prison.Nation.72 0p.HDTV.x264.AAC.M VGroup.org.mp4</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_1_bl" align="left"><a href="/files/?uid=0&category=3&subcategory=11&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Documentary</a> : <a href="/files/?uid=0&category=3&subcategory=0&language=0&seeded=2&quality=66&query=&sort=" class="subcategory">HD 720p</a> : <a href="/files/?uid=0&category=3&subcategory=0&language=1&seeded=2&quality=0&query=&sort=" class="subcategory">English</a>&nbsp;</td>
          <td nowrap class="tone_2_bl" align="left"><a href="/users/MVGroup" class="vip"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">MVGroup</a></td>


          <td nowrap class="tone_1_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406678/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406678/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_2_bl" align="right">1.31 GB</td>
          <td nowrap class="tone_1_bl" align="center">0</td>
          <td nowrap class="tone_2_bl" align="center"><font class="blue">67</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="green">30</font></td>
          <td nowrap class="tone_2_bl" align="center"><font class="red">75</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_1_bl"><!-- tstart --><a href="/files/?uid=0&category=5&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/applications.gif" height="30" alt="Applications" title="Applications" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_3_pad"><a href="/files/details/3406676/0012784238604/" >Kaspersky AntiVirus 2017 17 0 0 611 Final - Freeware Sys</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_3_bl" align="left"><a href="/files/?uid=0&category=5&subcategory=1&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Windows</a> : <a href="/files/?uid=0&category=5&subcategory=0&language=1&seeded=2&quality=0&query=&sort=" class="subcategory">English</a>&nbsp;</td>
          <td nowrap class="tone_1_bl" align="left"><a href="/users/ranasalman007" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">ranasalman007</a></td>


          <td nowrap class="tone_3_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406676/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406676/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_1_bl" align="right">170.84 MB</td>
          <td nowrap class="tone_3_bl" align="center">0</td>
          <td nowrap class="tone_1_bl" align="center"><font class="blue">10</font></td>
          <td nowrap class="tone_3_bl" align="center"><font class="green">3</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="red">7</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_2_bl"><!-- tstart --><a href="/files/?uid=0&category=11&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/books.gif" height="30" alt="Books" title="Books" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_1_pad"><a href="/files/details/3406674/008522825736/" >Elektor No156 Juin 1991 FR</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_1_bl" align="left"><a href="/files/?uid=0&category=11&subcategory=263&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Magazine</a> : <a href="/files/?uid=0&category=11&subcategory=0&language=3&seeded=2&quality=0&query=&sort=" class="subcategory">French</a>&nbsp;</td>
          <td nowrap class="tone_2_bl" align="left"><a href="/users/spookydd" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">spookydd</a></td>


          <td nowrap class="tone_1_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406674/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406674/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_2_bl" align="right">27.51 MB</td>
          <td nowrap class="tone_1_bl" align="center">0</td>
          <td nowrap class="tone_2_bl" align="center"><font class="blue">0</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="green">1</font></td>
          <td nowrap class="tone_2_bl" align="center"><font class="red">3</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_1_bl"><!-- tstart --><a href="/files/?uid=0&category=1&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/movies.gif" height="30" alt="Movies" title="Movies" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_3_pad"><a href="/files/details/3406672/004261412868/" >In the Deep 2016 DvDRip 550 MB - iExTV</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_3_bl" align="left"><a href="/files/?uid=0&category=1&subcategory=182&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Trailers</a> : <a href="/files/?uid=0&category=1&subcategory=0&language=0&seeded=2&quality=9&query=&sort=" class="subcategory">DVD Rip</a> : <a href="/files/?uid=0&category=1&subcategory=0&language=1&seeded=2&quality=0&query=&sort=" class="subcategory">English</a>&nbsp;</td>
          <td nowrap class="tone_1_bl" align="left"><a href="/users/SSSWAT" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">SSSWAT</a></td>


          <td nowrap class="tone_3_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406672/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406672/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_1_bl" align="right">549.72 MB</td>
          <td nowrap class="tone_3_bl" align="center">0</td>
          <td nowrap class="tone_1_bl" align="center"><font class="blue">55</font></td>
          <td nowrap class="tone_3_bl" align="center"><font class="green">31</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="red">81</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_2_bl"><!-- tstart --><a href="/files/?uid=0&category=2&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/music.gif" height="30" alt="Music" title="Music" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_1_pad"><a href="/files/details/3406668/0017045651472/" >Bob Marley &amp; The Wailers - 1975-06-10 Chicago, IL [1CD FM / FLAC] [XRT]</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_1_bl" align="left"><a href="/files/?uid=0&category=2&subcategory=41&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Reggae</a> : <a href="/files/?uid=0&category=2&subcategory=0&language=0&seeded=2&quality=62&query=&sort=" class="subcategory">Lossless</a>&nbsp;</td>
          <td nowrap class="tone_2_bl" align="left"><a href="/users/titoulien" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">titoulien</a></td>


          <td nowrap class="tone_1_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406668/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406668/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_2_bl" align="right">424.86 MB</td>
          <td nowrap class="tone_1_bl" align="center">1</td>
          <td nowrap class="tone_2_bl" align="center"><font class="blue">7</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="green">6</font></td>
          <td nowrap class="tone_2_bl" align="center"><font class="red">5</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_1_bl"><!-- tstart --><a href="/files/?uid=0&category=8&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/pictures.gif" height="30" alt="Pictures" title="Pictures" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_3_pad"><a href="/files/details/3406666/0012784238604/" >40 Amazing Cars HD Wallpapers 1920x1200 Px [Set 55]</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_3_bl" align="left"><a href="/files/?uid=0&category=8&subcategory=73&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Other</a> : <a href="/files/?uid=0&category=8&subcategory=0&language=0&seeded=2&quality=30&query=&sort=" class="subcategory">Hi-Res</a>&nbsp;</td>
          <td nowrap class="tone_1_bl" align="left"><a href="/users/nico1899" class="vip"><img src="/images/ratio/n3p.gif" border="0" width="8" height="8" alt="Ratio: 14.52" title="Ratio: 14.52"><img src="/images/p.gif" alt="" width="2" height="1" border="0">nico1899</a></td>


          <td nowrap class="tone_3_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406666/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406666/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_1_bl" align="right">39.10 MB</td>
          <td nowrap class="tone_3_bl" align="center">0</td>
          <td nowrap class="tone_1_bl" align="center"><font class="blue">0</font></td>
          <td nowrap class="tone_3_bl" align="center"><font class="green">1</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="red">21</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_2_bl"><!-- tstart --><a href="/files/?uid=0&category=8&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/pictures.gif" height="30" alt="Pictures" title="Pictures" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_1_pad"><a href="/files/details/3406664/008522825736/" >120 Amazing Cars Full HD Wallpapers 1920x1080 Px [Set 112]</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_1_bl" align="left"><a href="/files/?uid=0&category=8&subcategory=73&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Other</a> : <a href="/files/?uid=0&category=8&subcategory=0&language=0&seeded=2&quality=30&query=&sort=" class="subcategory">Hi-Res</a>&nbsp;</td>
          <td nowrap class="tone_2_bl" align="left"><a href="/users/nico1899" class="vip"><img src="/images/ratio/n3p.gif" border="0" width="8" height="8" alt="Ratio: 14.52" title="Ratio: 14.52"><img src="/images/p.gif" alt="" width="2" height="1" border="0">nico1899</a></td>


          <td nowrap class="tone_1_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406664/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406664/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_2_bl" align="right">110.48 MB</td>
          <td nowrap class="tone_1_bl" align="center">0</td>
          <td nowrap class="tone_2_bl" align="center"><font class="blue">0</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="green">1</font></td>
          <td nowrap class="tone_2_bl" align="center"><font class="red">22</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_1_bl"><!-- tstart --><a href="/files/?uid=0&category=8&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/pictures.gif" height="30" alt="Pictures" title="Pictures" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_3_pad"><a href="/files/details/3406660/002130706434/" >30 Nature Around the World Ultra HD Wallpapers { SET 35 }</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_3_bl" align="left"><a href="/files/?uid=0&category=8&subcategory=73&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Other</a> : <a href="/files/?uid=0&category=8&subcategory=0&language=0&seeded=2&quality=30&query=&sort=" class="subcategory">Hi-Res</a>&nbsp;</td>
          <td nowrap class="tone_1_bl" align="left"><a href="/users/xplore007" class="vip"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">xplore007</a></td>


          <td nowrap class="tone_3_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406660/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406660/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_1_bl" align="right">34.87 MB</td>
          <td nowrap class="tone_3_bl" align="center">0</td>
          <td nowrap class="tone_1_bl" align="center"><font class="blue">0</font></td>
          <td nowrap class="tone_3_bl" align="center"><font class="green">0</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="red">52</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_2_bl"><!-- tstart --><a href="/files/?uid=0&category=4&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/games.gif" height="30" alt="Games" title="Games" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_1_pad"><a href="/files/details/3406658/0017045651472/" >Battlefleet.Gothic .Armada.v1.6.8910. Cracked-3DM</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_1_bl" align="left"><a href="/files/?uid=0&category=4&subcategory=166&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Windows</a> : <a href="/files/?uid=0&category=4&subcategory=0&language=0&seeded=2&quality=28&query=&sort=" class="subcategory">Full Game</a> : <a href="/files/?uid=0&category=4&subcategory=0&language=1&seeded=2&quality=0&query=&sort=" class="subcategory">English</a>&nbsp;</td>
          <td nowrap class="tone_2_bl" align="left"><a href="/users/Insane098" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">Insane098</a></td>


          <td nowrap class="tone_1_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406658/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406658/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_2_bl" align="right">5.19 GB</td>
          <td nowrap class="tone_1_bl" align="center">0</td>
          <td nowrap class="tone_2_bl" align="center"><font class="blue">19</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="green">12</font></td>
          <td nowrap class="tone_2_bl" align="center"><font class="red">6</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_1_bl"><!-- tstart --><a href="/files/?uid=0&category=1&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/movies.gif" height="30" alt="Movies" title="Movies" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_3_pad"><a href="/files/details/3406656/0012784238604/" >The Huntsman: Winter's War 2016 720p EXTENDED BRRip 875 MB - iExTV</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_3_bl" align="left"><a href="/files/?uid=0&category=1&subcategory=6&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Action</a> : <a href="/files/?uid=0&category=1&subcategory=0&language=0&seeded=2&quality=72&query=&sort=" class="subcategory">Blu-ray </a> : <a href="/files/?uid=0&category=1&subcategory=0&language=1&seeded=2&quality=0&query=&sort=" class="subcategory">English</a>&nbsp;</td>
          <td nowrap class="tone_1_bl" align="left"><a href="/users/SSSWAT" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">SSSWAT</a></td>


          <td nowrap class="tone_3_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406656/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406656/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_1_bl" align="right">874.60 MB</td>
          <td nowrap class="tone_3_bl" align="center">0</td>
          <td nowrap class="tone_1_bl" align="center"><font class="blue">26</font></td>
          <td nowrap class="tone_3_bl" align="center"><font class="green">20</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="red">36</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_2_bl"><!-- tstart --><a href="/files/?uid=0&category=3&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/tv.gif" height="30" alt="TV" title="TV" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_1_pad"><a href="/files/details/3406652/004261412868/" >Containment.S01.Se ason.1.720p.5.1Ch. Web-DL.ReEnc-Sup3r man</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_1_bl" align="left"><a href="/files/?uid=0&category=3&subcategory=206&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Sci-Fi</a> : <a href="/files/?uid=0&category=3&subcategory=0&language=0&seeded=2&quality=69&query=&sort=" class="subcategory">HD</a> : <a href="/files/?uid=0&category=3&subcategory=0&language=1&seeded=2&quality=0&query=&sort=" class="subcategory">English</a>&nbsp;</td>
          <td nowrap class="tone_2_bl" align="left"><a href="/users/sup3rman1389" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">sup3rman1389</a></td>


          <td nowrap class="tone_1_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406652/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406652/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_2_bl" align="right">4.35 GB</td>
          <td nowrap class="tone_1_bl" align="center">0</td>
          <td nowrap class="tone_2_bl" align="center"><font class="blue">0</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="green">1</font></td>
          <td nowrap class="tone_2_bl" align="center"><font class="red">0</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_1_bl"><!-- tstart --><a href="/files/?uid=0&category=10&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/comics.gif" height="30" alt="Comics" title="Comics" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_3_pad"><a href="/files/details/3406650/002130706434/" >Spawn The Dark Ages - The Complete Collection (2013) (Digital) (Zone-Empire).cbr (- Nem -)</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_3_bl" align="left"><a href="/files/?uid=0&category=10&subcategory=224&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Horror</a> : <a href="/files/?uid=0&category=10&subcategory=0&language=1&seeded=2&quality=0&query=&sort=" class="subcategory">English</a>&nbsp;</td>
          <td nowrap class="tone_1_bl" align="left"><a href="/users/Nemesis43" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">Nemesis43</a></td>


          <td nowrap class="tone_3_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406650/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406650/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_1_bl" align="right">1.24 GB</td>
          <td nowrap class="tone_3_bl" align="center">0</td>
          <td nowrap class="tone_1_bl" align="center"><font class="blue">42</font></td>
          <td nowrap class="tone_3_bl" align="center"><font class="green">15</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="red">20</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_2_bl"><!-- tstart --><a href="/files/?uid=0&category=1&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/movies.gif" height="30" alt="Movies" title="Movies" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_1_pad"><a href="/files/details/3406648/0017045651472/" >Traded 2016 720p BRRip MP4 AC3 - KINGDOM</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_1_bl" align="left"><a href="/files/?uid=0&category=1&subcategory=26&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Western</a> : <a href="/files/?uid=0&category=1&subcategory=0&language=0&seeded=2&quality=66&query=&sort=" class="subcategory">HD 720p</a> : <a href="/files/?uid=0&category=1&subcategory=0&language=1&seeded=2&quality=0&query=&sort=" class="subcategory">English</a>&nbsp;</td>
          <td nowrap class="tone_2_bl" align="left"><a href="/users/MitsuRacerX311" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">MitsuRacerX311</a></td>


          <td nowrap class="tone_1_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406648/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406648/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_2_bl" align="right">1.93 GB</td>
          <td nowrap class="tone_1_bl" align="center">1</td>
          <td nowrap class="tone_2_bl" align="center"><font class="blue">15</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="green">4</font></td>
          <td nowrap class="tone_2_bl" align="center"><font class="red">21</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_1_bl"><!-- tstart --><a href="/files/?uid=0&category=1&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/movies.gif" height="30" alt="Movies" title="Movies" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_3_pad"><a href="/files/details/3406646/0012784238604/" >The Return of the Living Dead 1985 720p Remastered BRRip MP4 AC3 - KINGDOM</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_3_bl" align="left"><a href="/files/?uid=0&category=1&subcategory=17&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Horror</a> : <a href="/files/?uid=0&category=1&subcategory=0&language=0&seeded=2&quality=66&query=&sort=" class="subcategory">HD 720p</a> : <a href="/files/?uid=0&category=1&subcategory=0&language=1&seeded=2&quality=0&query=&sort=" class="subcategory">English</a>&nbsp;</td>
          <td nowrap class="tone_1_bl" align="left"><a href="/users/MitsuRacerX311" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">MitsuRacerX311</a></td>


          <td nowrap class="tone_3_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406646/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406646/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_1_bl" align="right">1.77 GB</td>
          <td nowrap class="tone_3_bl" align="center">0</td>
          <td nowrap class="tone_1_bl" align="center"><font class="blue">20</font></td>
          <td nowrap class="tone_3_bl" align="center"><font class="green">8</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="red">7</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_2_bl"><!-- tstart --><a href="/files/?uid=0&category=1&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/movies.gif" height="30" alt="Movies" title="Movies" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_1_pad"><a href="/files/details/3406644/008522825736/" >River 2015 720p BRRip MP4 AC3 - KINGDOM</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_1_bl" align="left"><a href="/files/?uid=0&category=1&subcategory=24&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Thriller</a> : <a href="/files/?uid=0&category=1&subcategory=0&language=0&seeded=2&quality=66&query=&sort=" class="subcategory">HD 720p</a> : <a href="/files/?uid=0&category=1&subcategory=0&language=1&seeded=2&quality=0&query=&sort=" class="subcategory">English</a>&nbsp;</td>
          <td nowrap class="tone_2_bl" align="left"><a href="/users/MitsuRacerX311" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">MitsuRacerX311</a></td>


          <td nowrap class="tone_1_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406644/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406644/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_2_bl" align="right">1.40 GB</td>
          <td nowrap class="tone_1_bl" align="center">0</td>
          <td nowrap class="tone_2_bl" align="center"><font class="blue">19</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="green">6</font></td>
          <td nowrap class="tone_2_bl" align="center"><font class="red">12</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_1_bl"><!-- tstart --><a href="/files/?uid=0&category=3&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/tv.gif" height="30" alt="TV" title="TV" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_3_pad"><a href="/files/details/3406642/004261412868/" >PBS.Classic.Americ an.Cars.of.Cuba.72 0p.HDTV.x264.AC3.M VGroup.org.mkv</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_3_bl" align="left"><a href="/files/?uid=0&category=3&subcategory=11&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Documentary</a> : <a href="/files/?uid=0&category=3&subcategory=0&language=0&seeded=2&quality=66&query=&sort=" class="subcategory">HD 720p</a> : <a href="/files/?uid=0&category=3&subcategory=0&language=1&seeded=2&quality=0&query=&sort=" class="subcategory">English</a>&nbsp;</td>
          <td nowrap class="tone_1_bl" align="left"><a href="/users/MVGroup" class="vip"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">MVGroup</a></td>


          <td nowrap class="tone_3_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406642/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406642/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_1_bl" align="right">1.42 GB</td>
          <td nowrap class="tone_3_bl" align="center">0</td>
          <td nowrap class="tone_1_bl" align="center"><font class="blue">116</font></td>
          <td nowrap class="tone_3_bl" align="center"><font class="green">40</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="red">34</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_2_bl"><!-- tstart --><a href="/files/?uid=0&category=1&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/movies.gif" height="30" alt="Movies" title="Movies" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_1_pad"><a href="/files/details/3406640/002130706434/" >Angry Birds 2016 720p BRRip MP4 AC3 - KINGDOM</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_1_bl" align="left"><a href="/files/?uid=0&category=1&subcategory=8&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Animation</a> : <a href="/files/?uid=0&category=1&subcategory=0&language=0&seeded=2&quality=66&query=&sort=" class="subcategory">HD 720p</a> : <a href="/files/?uid=0&category=1&subcategory=0&language=1&seeded=2&quality=0&query=&sort=" class="subcategory">English</a>&nbsp;</td>
          <td nowrap class="tone_2_bl" align="left"><a href="/users/MitsuRacerX311" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">MitsuRacerX311</a></td>


          <td nowrap class="tone_1_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406640/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406640/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_2_bl" align="right">1.58 GB</td>
          <td nowrap class="tone_1_bl" align="center">0</td>
          <td nowrap class="tone_2_bl" align="center"><font class="blue">27</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="green">14</font></td>
          <td nowrap class="tone_2_bl" align="center"><font class="red">35</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_1_bl"><!-- tstart --><a href="/files/?uid=0&category=4&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/games.gif" height="30" alt="Games" title="Games" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_3_pad"><a href="/files/details/3406638/0017045651472/" >FIFA.16.Update.5-S teamworks</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_3_bl" align="left"><a href="/files/?uid=0&category=4&subcategory=166&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Windows</a> : <a href="/files/?uid=0&category=4&subcategory=0&language=0&seeded=2&quality=28&query=&sort=" class="subcategory">Full Game</a> : <a href="/files/?uid=0&category=4&subcategory=0&language=1&seeded=2&quality=0&query=&sort=" class="subcategory">English</a>&nbsp;</td>
          <td nowrap class="tone_1_bl" align="left"><a href="/users/pistol888" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">pistol888</a></td>


          <td nowrap class="tone_3_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406638/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406638/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_1_bl" align="right">13.72 GB</td>
          <td nowrap class="tone_3_bl" align="center">0</td>
          <td nowrap class="tone_1_bl" align="center"><font class="blue">2</font></td>
          <td nowrap class="tone_3_bl" align="center"><font class="green">2</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="red">3</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_2_bl"><!-- tstart --><a href="/files/?uid=0&category=8&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/pictures.gif" height="30" alt="Pictures" title="Pictures" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_1_pad"><a href="/files/details/3406636/0012784238604/" >20 Awesome Mixed Ultra HD 4K Wallpapers 3840x2160 Px [Set 2]</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_1_bl" align="left"><a href="/files/?uid=0&category=8&subcategory=73&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Other</a> : <a href="/files/?uid=0&category=8&subcategory=0&language=0&seeded=2&quality=30&query=&sort=" class="subcategory">Hi-Res</a>&nbsp;</td>
          <td nowrap class="tone_2_bl" align="left"><a href="/users/nico1899" class="vip"><img src="/images/ratio/n3p.gif" border="0" width="8" height="8" alt="Ratio: 14.52" title="Ratio: 14.52"><img src="/images/p.gif" alt="" width="2" height="1" border="0">nico1899</a></td>


          <td nowrap class="tone_1_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406636/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406636/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_2_bl" align="right">60.89 MB</td>
          <td nowrap class="tone_1_bl" align="center">0</td>
          <td nowrap class="tone_2_bl" align="center"><font class="blue">8</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="green">1</font></td>
          <td nowrap class="tone_2_bl" align="center"><font class="red">55</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_1_bl"><!-- tstart --><a href="/files/?uid=0&category=10&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/comics.gif" height="30" alt="Comics" title="Comics" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_3_pad"><a href="/files/details/3406634/008522825736/" >Uncanny X-Men - The New Age - The End Of History v01 (2014) (Digital) (Kileko-Empire).cb r (- Nem -)</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_3_bl" align="left"><a href="/files/?uid=0&category=10&subcategory=222&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Super Hero</a> : <a href="/files/?uid=0&category=10&subcategory=0&language=1&seeded=2&quality=0&query=&sort=" class="subcategory">English</a>&nbsp;</td>
          <td nowrap class="tone_1_bl" align="left"><a href="/users/Nemesis43" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">Nemesis43</a></td>


          <td nowrap class="tone_3_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406634/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406634/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_1_bl" align="right">270.06 MB</td>
          <td nowrap class="tone_3_bl" align="center">0</td>
          <td nowrap class="tone_1_bl" align="center"><font class="blue">48</font></td>
          <td nowrap class="tone_3_bl" align="center"><font class="green">12</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="red">10</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_2_bl"><!-- tstart --><a href="/files/?uid=0&category=1&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/movies.gif" height="30" alt="Movies" title="Movies" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_1_pad"><a href="/files/details/3406632/004261412868/" >Daylight's End 2016 720p BRRip 750 MB - iExTV</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_1_bl" align="left"><a href="/files/?uid=0&category=1&subcategory=6&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Action</a> : <a href="/files/?uid=0&category=1&subcategory=0&language=0&seeded=2&quality=72&query=&sort=" class="subcategory">Blu-ray </a> : <a href="/files/?uid=0&category=1&subcategory=0&language=1&seeded=2&quality=0&query=&sort=" class="subcategory">English</a>&nbsp;</td>
          <td nowrap class="tone_2_bl" align="left"><a href="/users/SSSWAT" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">SSSWAT</a></td>


          <td nowrap class="tone_1_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406632/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406632/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_2_bl" align="right">755.54 MB</td>
          <td nowrap class="tone_1_bl" align="center">0</td>
          <td nowrap class="tone_2_bl" align="center"><font class="blue">69</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="green">31</font></td>
          <td nowrap class="tone_2_bl" align="center"><font class="red">45</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_1_bl"><!-- tstart --><a href="/files/?uid=0&category=1&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/movies.gif" height="30" alt="Movies" title="Movies" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_3_pad"><a href="/files/details/3406630/002130706434/" >Azhar 2016 Hindi 720p BRRip 950 MB - iExTV</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_3_bl" align="left"><a href="/files/?uid=0&category=1&subcategory=9&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Biography</a> : <a href="/files/?uid=0&category=1&subcategory=0&language=0&seeded=2&quality=72&query=&sort=" class="subcategory">Blu-ray </a> : <a href="/files/?uid=0&category=1&subcategory=0&language=31&seeded=2&quality=0&query=&sort=" class="subcategory">Hindi</a>&nbsp;</td>
          <td nowrap class="tone_1_bl" align="left"><a href="/users/SSSWAT" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">SSSWAT</a></td>


          <td nowrap class="tone_3_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406630/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406630/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_1_bl" align="right">949.89 MB</td>
          <td nowrap class="tone_3_bl" align="center">0</td>
          <td nowrap class="tone_1_bl" align="center"><font class="blue">8</font></td>
          <td nowrap class="tone_3_bl" align="center"><font class="green">9</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="red">51</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_2_bl"><!-- tstart --><a href="/files/?uid=0&category=8&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/pictures.gif" height="30" alt="Pictures" title="Pictures" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_1_pad"><a href="/files/details/3406628/0017045651472/" >60 Amazing Landscapes HD Wallpapers [Mixed Res][Set 36]</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_1_bl" align="left"><a href="/files/?uid=0&category=8&subcategory=73&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Other</a> : <a href="/files/?uid=0&category=8&subcategory=0&language=0&seeded=2&quality=30&query=&sort=" class="subcategory">Hi-Res</a>&nbsp;</td>
          <td nowrap class="tone_2_bl" align="left"><a href="/users/nico1899" class="vip"><img src="/images/ratio/n3p.gif" border="0" width="8" height="8" alt="Ratio: 14.52" title="Ratio: 14.52"><img src="/images/p.gif" alt="" width="2" height="1" border="0">nico1899</a></td>


          <td nowrap class="tone_1_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406628/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406628/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_2_bl" align="right">87.13 MB</td>
          <td nowrap class="tone_1_bl" align="center">0</td>
          <td nowrap class="tone_2_bl" align="center"><font class="blue">0</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="green">1</font></td>
          <td nowrap class="tone_2_bl" align="center"><font class="red">50</font></td>

          <tr>
          <td rowspan="2" align="center" class="tone_1_bl"><!-- tstart --><a href="/files/?uid=0&category=10&subcategory=0&language=0&seeded=2&quality=0&query=&sort="><img src="/images/cats/comics.gif" height="30" alt="Comics" title="Comics" border="0"></a><!-- tend --></td>
          <td colspan="9" class="tone_3_pad"><a href="/files/details/3406624/008522825736/" >Beasts of Burden - What the Cat Dragged In (2016) (digital) (Minutemen-InnerDe mons).cbr (- Nem -)</a> <font class="red" style="font-size:9px !important;color: c97d7d !important">(external)</font></td>
          </tr>
        <tr>
          <td width="100%" class="tone_3_bl" align="left"><a href="/files/?uid=0&category=10&subcategory=223&language=0&seeded=2&quality=0&query=&sort=" class="subcategory">Fantasy</a> : <a href="/files/?uid=0&category=10&subcategory=0&language=1&seeded=2&quality=0&query=&sort=" class="subcategory">English</a>&nbsp;</td>
          <td nowrap class="tone_1_bl" align="left"><a href="/users/Nemesis43" class="user"><img src="/images/ratio/n01.gif" border="0" width="8" height="8" alt="Ratio: 1.00" title="Ratio: 1.00"><img src="/images/p.gif" alt="" width="2" height="1" border="0">Nemesis43</a></td>


          <td nowrap class="tone_3_bl" align="center"><a href="https://dltags.com/?pubid=243320&search=/files/download/3406624/" target="_blank"><img src="/img/dirdown.png" width="31" height="16" hspace="3" alt="Direct download" title="Direct download" border="0"></a><a href="/files/download/3406624/"><img src="/images/dmi.gif" width="31" height="16" hspace="3" alt="Download torrent" title="Download torrent" border="0"></a></td>



          <td nowrap class="tone_1_bl" align="right">46.85 MB</td>
          <td nowrap class="tone_3_bl" align="center">0</td>
          <td nowrap class="tone_1_bl" align="center"><font class="blue">36</font></td>
          <td nowrap class="tone_3_bl" align="center"><font class="green">9</font></td>
          <td nowrap class="tone_1_bl" align="center"><font class="red">3</font></td>

          <!-- end torrent list --><tr><td colspan="9" align="center" class="tone_2_bl">| <b><u>1 - 50</u></b> | <a href="/files/?to=0&uid=0&category=0&subcategory=0&language=0&seeded=2&quality=0&external=2&query=&sort=&page=2">51 - 100</a> | <a href="/files/?to=0&uid=0&category=0&subcategory=0&language=0&seeded=2&quality=0&external=2&query=&sort=&page=3">101 - 150</a> | <a href="/files/?to=0&uid=0&category=0&subcategory=0&language=0&seeded=2&quality=0&external=2&query=&sort=&page=4">151 - 200</a> | <a href="/files/?to=0&uid=0&category=0&subcategory=0&language=0&seeded=2&quality=0&external=2&query=&sort=&page=5">201 - 250</a> | <a href="/files/?to=0&uid=0&category=0&subcategory=0&language=0&seeded=2&quality=0&external=2&query=&sort=&page=6">251 - 300</a> | <a href="/files/?to=0&uid=0&category=0&subcategory=0&language=0&seeded=2&quality=0&external=2&query=&sort=&page=7">301 - 350</a> | <a href="/files/?to=0&uid=0&category=0&subcategory=0&language=0&seeded=2&quality=0&external=2&query=&sort=&page=8">351 - 400</a> | <a href="/files/?to=0&uid=0&category=0&subcategory=0&language=0&seeded=2&quality=0&external=2&query=&sort=&page=9">401 - 450</a> | <a href="/files/?to=0&uid=0&category=0&subcategory=0&language=0&seeded=2&quality=0&external=2&query=&sort=&page=10">451 - 500</a> | <a href="/files/?to=0&uid=0&category=0&subcategory=0&language=0&seeded=2&quality=0&external=2&query=&sort=&page=11">501 - 550</a> | <a href="/files/?to=0&uid=0&category=0&subcategory=0&language=0&seeded=2&quality=0&external=2&query=&sort=&page=12">551 - 600</a> | <a href="/files/?to=0&uid=0&category=0&subcategory=0&language=0&seeded=2&quality=0&external=2&query=&sort=&page=13">601 - 650</a> | <a href="/files/?to=0&uid=0&category=0&subcategory=0&language=0&seeded=2&quality=0&external=2&query=&sort=&page=14">651 - 700</a> | <a href="/files/?to=0&uid=0&category=0&subcategory=0&language=0&seeded=2&quality=0&external=2&query=&sort=&page=15">701 - 750</a> | <a href="/files/?to=0&uid=0&category=0&subcategory=0&language=0&seeded=2&quality=0&external=2&query=&sort=&page=16">751 - 800</a> | <b>&laquo;&raquo;</b> |  <strong>688,442 items total</strong></td></tr>
    <tr><td colspan="9" align="center">&lt;&lt; Prev&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href=/files/?to=0&uid=0&category=0&subcategory=0&language=0&seeded=2&quality=0&external=2&query=&sort=&page=2 class="menu">Next &gt;&gt;</a></td></tr><tr align="right">
                    <td colspan="9" class="tone_3_bl"> <img src="/images/3blinks.gif" alt="" width="9" height="9" hspace="3" border="0">Sort by:

    				<select name="sort" id="sortsel" onBlur="document.getElementById('filters_top').sort.value=this.value; document.getElementById('filters_bottom').sort.value=this.value;" onChange="document.getElementById('filters_top').sort.value=this.value;  document.getElementById('filters_bottom').sort.value=this.value;">
    		<option value="" SELECTED>Date (Default)</option>
    		<option value="C">Completed Desc</option>
    		<option value="c">Completed Asc</option>




    		<option value="L">Leechers Desc</option>
    		<option value="l">Leechers Asc</option>

    		<option value="S">Seeds Desc</option>
    		<option value="s">Seeds Asc</option>

    		<option value="B">Size Desc</option>
    		<option value="b">Size Asc</option>
    </select> <input type="submit" class="regular_button" value="Apply" onClick="document.getElementById('filters_top').submit();">
    				</td>
                    </tr></table>
    		</td>
    	</tr>
    </table>
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
        	<tr>
        		<td class="ctable_bottom_left" height="11" width="22"><img src="/images/p.gif" width="22" height="1"></td>
        		<td  class="ctable_bottom" width="100%"><img src="/images/p.gif" width="1" height="10"></td>
        		<td class="ctable_bottom_right" height="11" width="10"><img src="/images/p.gif" width="10" height="1"></td>

        	</tr>
        </table>

     <img src="/images/p.gif" width="1" height="7">

    <table width="100%" border="0" cellspacing="0" cellpadding="0">

    	<tr>
    		<td class="ctable_top_left" height="30" width="22"><img src="/images/p.gif" width="22" height="1"></td>
    		<td class="ctable_header" width="100%">Filters</td>
    		<td class="ctable_top_right" height="30" width="1"0><img src="/images/p.gif" width=10 height=1></td>
    	</tr>
    </table>
    	<form action="/files/" name="filters_bottom" id="filters_bottom">
    <table width="100%" border="0" cellspacing="0" cellpadding="0">
    	<tr>
    		<td width="100%" class="ctable_content">
    			<center>
    		<table width="80%" border="0" cellspacing="0" cellpadding="3">
      <tr>
        <td width="15%">Category:</td>
        <td><select name="category" id="category" onChange="document.getElementById('filters_top').sort.value=''; if(sc_drop != undefined){update(this, sc_drop); update(this, q_drop); update(this, l_drop); build_rss_link();}" onKeyUp="document.getElementById('filters_top').sort.value=''; if(sc_drop != undefined){update(this, sc_drop); update(this, q_drop); update(this, l_drop); build_rss_link();}">
          <option value="0">All</option><option value="5">Applications</option><option value="17">Audio Books</option><option value="11">Books</option><option value="10">Comics</option><option value="4">Games</option><option value="9">Japanese Anime</option><option value="6">Miscellaneous</option><option value="1">Movies</option><option value="2">Music</option><option value="13">Music Videos</option><option value="8">Pictures</option><option value="3">TV</option>
        </select></td>
        <td width="15%">Subcategory: </td>
        <td><select name="subcategory" id="subcategory" onChange="if(sc_drop != undefined){build_rss_link();}" onKeyUp="if(sc_drop != undefined){build_rss_link();}">
    		  <option selected>All</option></select></td>
      </tr>
      <tr>
        <td>Language:</td>
        <td><select name="language" id="language" disabled>
    		   <option value="0" selected>None available</option></select></td>
        <td>Quality:</td>
        <td><select name="quality" id="quality">
    		  <option selected>All</option></select></td>
      </tr>
      <tr>
        <td>State:</td>
        <td><select name="seeded">
          <option value="0">Seeded</option>
          <option value="1">Unseeded</option>
          <option value="2" SELECTED>Both</option>
        </select></td>
        <td>Tracked by: </td>
        <td><select name="external">
          <option value="2" SELECTED>Both</option>
          <option value="0">Demonoid</option>
          <option value="1">External</option>
        </select></td>
      </tr>
      <tr align="center">
        <td colspan="4">Keywords: <input type="text" name="query" size="55" maxlength="50" value="" ><br><input name="to" type="checkbox" value="1"  /> Search torrent names only<input type="hidden" name="uid" value="0"><input type="hidden" name="sort" value=""> <input type="submit" value="Apply filters" class="regular_button"> <input type="button" value="Reset filters" class="regular_button" onClick="location.href='/files/'; return false;"></td>
      </tr></table></center><center><span id="rss_feed_link2"><a href="/rss/0.xml">RSS feed - all categories<img src="/images/rss.jpg" alt="RSS Feed" width="16" height="16" hspace="5" border="0"></a><br><br><span class="pfooter">Support Demonoid with BitCoin: <a href="bitcoin:1DNoidLcUGHuijTB6rLNAu8Xm7bE5rvPtC">1DNoidLcUGHuijTB6rLNAu8Xm7bE5rvPtC</a></span></span></center>
    		</td>
    	</tr>
    </table>
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
        	<tr>
        		<td class="ctable_bottom_left" height="11" width="22"><img src="/images/p.gif" width="22" height="1"></td>
        		<td  class="ctable_bottom" width="100%"><img src="/images/p.gif" width="1" height="10"></td>
        		<td class="ctable_bottom_right" height="11" width="10"><img src="/images/p.gif" width="10" height="1"></td>

        	</tr>
        </table>
     	</form>
     <img src="/images/p.gif" width="1" height="7">
    </tr>
    </table>
    </div>

    <table width="100%" border="0" cellspacing="0" cellpadding="0">
    	<tr>
    		<td class="banner_bottom" id="bnr_r_bottom" align="center" valign="middle" height="10">
        		<img src="/images/p.gif" width="1" height="1">
    									<!-- 728x90 bottom -->
    					<ins data-revive-zoneid="2" data-revive-id="437cad6fb03a954095f84700fa2cbc32"></ins>
    					<script async src="//ads.torrpedo.net/www/delivery/asyncjs.php"></script>
    					<!-- 728x90 bottom -->
    																			    	</td>
        </tr>
        <tr>
        	<td class="bottom_bar">
        		<img src="/images/p.gif" width="728" height="1">
        	</td>
        </tr>
    </table>
    </td>

    <td class="shadow_right">
    	<img src="/images/p.gif" width="8" height="1">
    </td>
    </tr>
    </table>

    <table width="100%" border="0" cellspacing="0" cellpadding="0">
    	<tr>
    		<td class="ending_top_left">
    			<img src="/images/p.gif" width="43" height="1">
    		</td>
    		<td class="ending_tile_top">
    			<img src="/images/p.gif" width="850" height="1">
    		</td>
    		<td class="ending_top_right">
    			<img src="/images/p.gif" width="43" height="1">
    		</td>
    	</tr>
    </table>

    <table width="100%" border="0" cellspacing="0" cellpadding="0">
    	<tr>
    		<td class="ending_tile_left">
    			<img src="/images/p.gif" width="52" height="1">
    		</td>
    		<td class="ending_disclaimer">
    			<img src="/images/p.gif" width="832" height="1"><br>
        		<span class="red">Disclaimer:</span>
    			.None of the files shown here are actually hosted or transmitted by this server. The links are provided solely by this site&#039;s users. The site moderation is also a service provided by the site&#039;s users. The administrator of this site (demonoid.pw) cannot be held responsible for what its users post, or any other actions of its users. You may not use this site to distribute or download any material when you do not have the legal rights to do so. It is your own responsibility to adhere to these terms.<br>
    			<br>
    			<center>By using this site you indicate your agreement to our <a href="/terms_and_conditions.php" class="ending_disclaimer">terms and conditions</a></center>
    		</td>
    		<td class="ending_tile_right">
    			<img src="/images/p.gif" width="52" height="1">
    		</td>
    	</tr>
    	<tr>
    		<td class="ending_bottom_left">&nbsp;</td>
    		<td class="ending_tile_bottom"><img src="/images/p.gif" width="608" height="1"></td>
    		<td class="ending_bottom_right">&nbsp;</td>
    	</tr>
    </table>


    <font class="pfooter">
    	<a href="/link_to_us.php" class="pfooter">Link to us</a>
    	| <a href="/contact_us.php" class="pfooter">Contact us</a>
    </font>
     | <a href="/api.php" class="pfooter">API</a> | <a href="https://twitter.com/DemonoidP2P" target="_blank" class="pfooter">Twitter: @DemonoidP2P</a> | <a href="/rss.php" class="pfooter">Feeds/RSS <img src="/images/rss_icon.gif" alt="" width="10" height="10" hspace="3" border="0"></a> | <a href="/dmca.php" class="pfooter">DMCA</a><br>
    <font class="pfooter">This site and the Demonoid logo are Copyright &copy; 2016 Demonoid. All rights reserved.<br /><br />
    Help by donating bitcoin: <a href="bitcoin:1DNoidfTDgVZtM36531t1bwgt25SpyZEeW">1DNoidfTDgVZtM36531t1bwgt25SpyZEeW</a>
    <br />


    </font><br /><br /><br /><br /><br /><br />
    </center>
    </div>
    <br>



    <!-- start popunder -->
    <script type='text/javascript'><!--//<![CDATA[
       var m3_u = (location.protocol=='https:'?'https://ads.torrpedo.net/www/delivery/ajs.php':'http://ads.torrpedo.net/www/delivery/ajs.php');
       var m3_r = Math.floor(Math.random()*99999999999);
       if (!document.MAX_used) document.MAX_used = ',';
       document.write ("<scr"+"ipt type='text/javascript' src='"+m3_u);
       document.write ("?zoneid=4");
       document.write ('&amp;cb=' + m3_r);
       if (document.MAX_used != ',') document.write ("&amp;exclude=" + document.MAX_used);
       document.write (document.charset ? '&amp;charset='+document.charset : (document.characterSet ? '&amp;charset='+document.characterSet : ''));
       document.write ("&amp;loc=" + escape(window.location));
       if (document.referrer) document.write ("&amp;referer=" + escape(document.referrer));
       if (document.context) document.write ("&context=" + escape(document.context));
       if (document.mmm_fo) document.write ("&amp;mmm_fo=1");
       document.write ("'><\/scr"+"ipt>");
    //]]>--></script><noscript><a href='http://ads.torrpedo.net/www/delivery/ck.php?n=a7792af1&amp;cb={random}' target='_blank'><img src='http://ads.torrpedo.net/www/delivery/avw.php?zoneid=4&amp;cb={random}&amp;n=a7792af1' border='0' alt='' /></a></noscript>
    <!-- end popunder -->

    <div id="dbnr_r_pp"></div>

    <div id="bnr_r_cf"></div>

    <!-- Begin Piwik -->
    <script type="text/javascript">
      var _paq = _paq || [];
      _paq.push(['trackPageView']);
      _paq.push(['enableLinkTracking']);
      _paq.push(['appendToTrackingUrl', 'bots=1']);
      (function() {
        var u="//stats.istrcltd.org.ua/t/";
        _paq.push(['setTrackerUrl', u+'piwik.php']);
        _paq.push(['setSiteId', 2]);
        var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
        g.type='text/javascript'; g.async=true; g.defer=true; g.src=u+'piwik.js'; s.parentNode.insertBefore(g,s);
      })();
    </script>
    <noscript><p><img src="//stats.istrcltd.org.ua/t/piwik.php?idsite=2" style="border:0;" alt="" /></p></noscript>
    <!-- End Piwik -->

    </body>
    </html>
    """
  end

end
