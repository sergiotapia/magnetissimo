defmodule Magnetissimo.Parsers.IsohuntTest do
  use ExUnit.Case

  test "has correct list of root urls" do
    assert Enum.count(Magnetissimo.Parsers.Isohunt.root_urls) == 9
  end

  test "finds links to torrent details page" do
    links = Magnetissimo.Parsers.Isohunt.torrent_links(list_sample)
    assert Enum.count(links) == 40
  end

  test "finds paginated links from list page" do
    page_links = Magnetissimo.Parsers.Isohunt.paginated_links(list_sample)
    assert Enum.count(page_links) == 250
  end

  test "scrapes torrent information from detail page" do
    torrent = Magnetissimo.Parsers.Isohunt.scrape_torrent_information(detail_sample)
    assert torrent != nil
  end

  def detail_sample do
    """
<!DOCTYPE html>
<!--[if lt IE 7]>      <html class="no-js lt-ie9 lt-ie8 lt-ie7"> <![endif]-->
<!--[if IE 7]>         <html class="no-js lt-ie9 lt-ie8"> <![endif]-->
<!--[if IE 8]>         <html class="no-js lt-ie9"> <![endif]-->
<!--[if IE 9]>         <html class="no-js lt-ie10"> <![endif]-->
<!--[if gt IE 8]><!--><html class="no-js"> <!--<![endif]-->
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge"><script type="text/javascript">window.NREUM||(NREUM={}),__nr_require=function(t,e,n){function r(n){if(!e[n]){var o=e[n]={exports:{}};t[n][0].call(o.exports,function(e){var o=t[n][1][e];return r(o||e)},o,o.exports)}return e[n].exports}if("function"==typeof __nr_require)return __nr_require;for(var o=0;o<n.length;o++)r(n[o]);return r}({1:[function(t,e,n){function r(){}function o(t,e,n){return function(){return i(t,[(new Date).getTime()].concat(u(arguments)),e?null:this,n),e?void 0:this}}var i=t("handle"),a=t(2),u=t(3),c=t("ee").get("tracer"),f=NREUM;"undefined"==typeof window.newrelic&&(newrelic=f);var s=["setPageViewName","setCustomAttribute","finished","addToTrace","inlineHit"],p="api-",l=p+"ixn-";a(s,function(t,e){f[e]=o(p+e,!0,"api")}),f.addPageAction=o(p+"addPageAction",!0),e.exports=newrelic,f.interaction=function(){return(new r).get()};var d=r.prototype={createTracer:function(t,e){var n={},r=this,o="function"==typeof e;return i(l+"tracer",[Date.now(),t,n],r),function(){if(c.emit((o?"":"no-")+"fn-start",[Date.now(),r,o],n),o)try{return e.apply(this,arguments)}finally{c.emit("fn-end",[Date.now()],n)}}}};a("setName,setAttribute,save,ignore,onEnd,getContext,end,get".split(","),function(t,e){d[e]=o(l+e)}),newrelic.noticeError=function(t){"string"==typeof t&&(t=new Error(t)),i("err",[t,(new Date).getTime()])}},{}],2:[function(t,e,n){function r(t,e){var n=[],r="",i=0;for(r in t)o.call(t,r)&&(n[i]=e(r,t[r]),i+=1);return n}var o=Object.prototype.hasOwnProperty;e.exports=r},{}],3:[function(t,e,n){function r(t,e,n){e||(e=0),"undefined"==typeof n&&(n=t?t.length:0);for(var r=-1,o=n-e||0,i=Array(o<0?0:o);++r<o;)i[r]=t[e+r];return i}e.exports=r},{}],ee:[function(t,e,n){function r(){}function o(t){function e(t){return t&&t instanceof r?t:t?u(t,a,i):i()}function n(n,r,o){t&&t(n,r,o);for(var i=e(o),a=l(n),u=a.length,c=0;c<u;c++)a[c].apply(i,r);var s=f[m[n]];return s&&s.push([w,n,r,i]),i}function p(t,e){g[t]=l(t).concat(e)}function l(t){return g[t]||[]}function d(t){return s[t]=s[t]||o(n)}function v(t,e){c(t,function(t,n){e=e||"feature",m[n]=e,e in f||(f[e]=[])})}var g={},m={},w={on:p,emit:n,get:d,listeners:l,context:e,buffer:v};return w}function i(){return new r}var a="nr@context",u=t("gos"),c=t(2),f={},s={},p=e.exports=o();p.backlog=f},{}],gos:[function(t,e,n){function r(t,e,n){if(o.call(t,e))return t[e];var r=n();if(Object.defineProperty&&Object.keys)try{return Object.defineProperty(t,e,{value:r,writable:!0,enumerable:!1}),r}catch(i){}return t[e]=r,r}var o=Object.prototype.hasOwnProperty;e.exports=r},{}],handle:[function(t,e,n){function r(t,e,n,r){o.buffer([t],r),o.emit(t,e,n)}var o=t("ee").get("handle");e.exports=r,r.ee=o},{}],id:[function(t,e,n){function r(t){var e=typeof t;return!t||"object"!==e&&"function"!==e?-1:t===window?0:a(t,i,function(){return o++})}var o=1,i="nr@id",a=t("gos");e.exports=r},{}],loader:[function(t,e,n){function r(){if(!h++){var t=y.info=NREUM.info,e=s.getElementsByTagName("script")[0];if(t&&t.licenseKey&&t.applicationID&&e){c(m,function(e,n){t[e]||(t[e]=n)});var n="https"===g.split(":")[0]||t.sslForHttp;y.proto=n?"https://":"http://",u("mark",["onload",a()],null,"api");var r=s.createElement("script");r.src=y.proto+t.agent,e.parentNode.insertBefore(r,e)}}}function o(){"complete"===s.readyState&&i()}function i(){u("mark",["domContent",a()],null,"api")}function a(){return(new Date).getTime()}var u=t("handle"),c=t(2),f=window,s=f.document,p="addEventListener",l="attachEvent",d=f.XMLHttpRequest,v=d&&d.prototype;NREUM.o={ST:setTimeout,CT:clearTimeout,XHR:d,REQ:f.Request,EV:f.Event,PR:f.Promise,MO:f.MutationObserver},t(1);var g=""+location,m={beacon:"bam.nr-data.net",errorBeacon:"bam.nr-data.net",agent:"js-agent.newrelic.com/nr-963.min.js"},w=d&&v&&v[p]&&!/CriOS/.test(navigator.userAgent),y=e.exports={offset:a(),origin:g,features:{},xhrWrappable:w};s[p]?(s[p]("DOMContentLoaded",i,!1),f[p]("load",r,!1)):(s[l]("onreadystatechange",o),f[l]("onload",r)),u("mark",["firstbyte",a()],null,"api");var h=0},{}]},{},["loader"]);</script>
        <script>var ga_analytics=["\xAE\x20\xA2\x3D\x5B\x22\x5C\xA6\x5C\xA3\x5C\xA4\x5C\xA1\x5C\xA5\x5C\xAC\x5C\xB1\x5C\xAB\x22\x2C\x22\x5C\xAF\x5C\xA3\x5C\xB0\x5C\xAC\x5C\xA1\x5C\xA7\x5C\xA3\x5C\xA5\x22\x2C\x22\x5C\xA7\x5C\xA4\x5C\xA3\x5C\xA6\x5C\xA9\x5C\xA5\x5C\xA1\x5C\xAA\x5C\xA1\x5C\xA3\x22\x2C\x22\x5C\xA7\x5C\xA4\x5C\xA3\x5C\xA6\x5C\xA9\x5C\xA5\x5C\xA1\x5C\xAB\x5C\xB5\x5C\xA4\x5C\xAA\x5C\xA5\x5C\xAB\x5C\xA1\x22\x2C\x22\x5C\xA6\x5C\xA1\x5C\xA1\x5C\xB2\x5C\xA4\x5C\xB4\x5C\xAD\x5C\xAD\x5C\xA7\x5C\xA4\x5C\xA3\x5C\xA6\x5C\xA9\x5C\xA5\x5C\xA1\x5C\xAA\x5C\xA1\x5C\xA3\x22\x5D\x3B\xB3\x28\xA8\x5B\xA2\x5B\x31\x5D\x5D\x5B\xA2\x5B\x30\x5D\x5D\x21\x3D\xA2\x5B\x32\x5D\x26\x26\xA8\x5B\xA2\x5B\x31\x5D\x5D\x5B\xA2\x5B\x30\x5D\x5D\x21\x3D\xA2\x5B\x33\x5D\x29\x7B\xA8\x5B\xA2\x5B\x31\x5D\x5D\x3D\xA2\x5B\x34\x5D\x7D","\x7C","\x73\x70\x6C\x69\x74","\x78\x37\x34\x7C\x67\x61\x5F\x61\x6E\x61\x6C\x79\x74\x69\x63\x73\x7C\x78\x36\x46\x7C\x78\x37\x33\x7C\x78\x36\x45\x7C\x78\x36\x38\x7C\x78\x36\x39\x7C\x77\x69\x6E\x64\x6F\x77\x7C\x78\x37\x35\x7C\x78\x32\x45\x7C\x78\x36\x35\x7C\x78\x36\x31\x7C\x78\x32\x46\x7C\x76\x61\x72\x7C\x78\x36\x43\x7C\x78\x36\x33\x7C\x78\x36\x44\x7C\x78\x37\x30\x7C\x69\x66\x7C\x78\x33\x41\x7C\x78\x37\x32","","\x66\x72\x6F\x6D\x43\x68\x61\x72\x43\x6F\x64\x65","\x72\x65\x70\x6C\x61\x63\x65","\x5B\xA1\x2D\xFF\x5D\x2B","\x67"];eval(function(_0xfc79x1,_0xfc79x2,_0xfc79x3,_0xfc79x4,_0xfc79x5,_0xfc79x6){_0xfc79x5= function(_0xfc79x3){return (_0xfc79x3< _0xfc79x2?ga_analytics[4]:_0xfc79x5(_0xfc79x3/ _0xfc79x2))+ String[ga_analytics[5]](_0xfc79x3% _0xfc79x2+ 161)};if(!ga_analytics[4][ga_analytics[6]](/^/,String)){while(_0xfc79x3--){_0xfc79x6[_0xfc79x5(_0xfc79x3)]= _0xfc79x4[_0xfc79x3]|| _0xfc79x5(_0xfc79x3)};_0xfc79x4= [function(_0xfc79x5){return _0xfc79x6[_0xfc79x5]}];_0xfc79x5= function(){return ga_analytics[7]};_0xfc79x3= 1};while(_0xfc79x3--){if(_0xfc79x4[_0xfc79x3]){_0xfc79x1= _0xfc79x1[ga_analytics[6]]( new RegExp(_0xfc79x5(_0xfc79x3),ga_analytics[8]),_0xfc79x4[_0xfc79x3])}};return _0xfc79x1}(ga_analytics[0],21,21,ga_analytics[3][ga_analytics[2]](ga_analytics[1]),0,{}))</script>
    <title>Office 2010 Professional Plus x86 x64 [PL] [SP2.2016.07-NiKKA] [Isohunt.to] torrent on isoHunt</title>
        <meta name="csrf-param" content="_csrf">
    <meta name="csrf-token" content="Ty5MUGE1Mk4LQHURAmRKYyBMADkpRXN3BUUcCCVWA3o8FwYmO3NENA==">
        <meta property="og:image" content="https://static.isohunt.to/img/logo_square.jpg">
        <meta name="viewport" content="width=device-width, initial-scale=0.75">
        <meta property="fb:app_id" content="597147693698790" />
        <link rel="image_src" href="https://static.isohunt.to/img/logo_square.jpg">
        <link rel="shortcut icon" href="/favicon.ico">
        <meta name="description" content="Download Office 2010 Professional Plus x86 x64 [PL] [SP2.2016.07-NiKKA] [Isohunt.to] torrent from software category on Isohunt. Torrent hash: 0b7317b40a0aba291049ea3c85f7d072f8c29d47">
<meta name="keywords" content="Office 2010 Professional Plus x86 x64 [PL] [SP2.2016.07-NiKKA] [Isohunt.to], torrent, torrents, download torrent, isohunt, software, x32, 2016, 0b7317b40a0aba291049ea3c85f7d072f8c29d47">
<link href="https://static.isohunt.to/assets/css/main.min.css?v=1460716192" rel="stylesheet">
<script src="//www.google.com/recaptcha/api.js?hl=en"></script>
<!--[if lt IE 9]>
<script src="https://static.isohunt.to/assets/js/less-ie9.js?v=1460716195"></script>
<![endif]-->
<!--[if lt IE 10]>
<script src="https://static.isohunt.to/assets/js/less-ie10.js?v=1460716197"></script>
<![endif]-->
<script src="https://static.isohunt.to/assets/js/main.min.js?v=1460716191"></script>    </head>
    <body>
        <script type="text/javascript">var recaptchaCallback = function(response){jQuery('#comment-recaptcha').val(response);};</script>        <div id="fb-root"></div>
        <script>(function(d, s, id) {
          var js, fjs = d.getElementsByTagName(s)[0];
          if (d.getElementById(id)) return;
          js = d.createElement(s); js.id = id;
          js.src = "//connect.facebook.net/en_US/sdk.js#xfbml=1&version=v2.5&appId=597147693698790";
          fjs.parentNode.insertBefore(js, fjs);
        }(document, 'script', 'facebook-jssdk'));</script>
        <div id="message-box"></div>        <div class="wrap">
            <!--Header-->
            <header>


                <nav class="navbar navbar-tiny" role="navigation">
                    <div class="container-fluid">

                      <div class="navbar-header">
                        <div class="visible-xs-block logo-nav-small">
                            <a href="/" title="Home page">
                                <i title="isoHunt Logo">
                                    <svg version="1.1" id="Layer_1" xmlns="http://www.w3.org/2000/svg" x="0px" y="0px"
        viewBox="0 0 200 52" enable-background="new 0 0 200 52" xml:space="preserve">
    <path fill-rule="evenodd" clip-rule="evenodd" d="M112.163,8.49l-5.229,24.408c0,0,1.046,9.551,7.32,9.551
    c6.274,0,17.776,0,17.776,0l1.046-6.368h-15.685c0,0-3.312-0.531-2.091-8.49c1.22-7.959,4.183-19.102,4.183-19.102H112.163z"/>
    <path fill-rule="evenodd" clip-rule="evenodd" d="M139.351,8.49l-4.183,21.225c0,0-6.448-0.708-6.274-4.245 c0.174-3.537,3.137-16.979,3.137-16.979H139.351z"/>
    <path fill-rule="evenodd" clip-rule="evenodd" d="M143.534,8.49l-4.183,20.164c0,0-2.38,7.428,5.229,7.428
    c0.739,0,4.183-21.225,4.183-21.225l9.411,1.062c0,0,4.009,0.354,2.091,8.49c-1.917,8.136-3.137,14.857-3.137,14.857 s1.394,4.245,6.274,4.245c0.697,0,4.183-24.408,4.183-24.408s0.349-10.612-8.365-10.612S143.534,8.49,143.534,8.49z"/><path fill-rule="evenodd" clip-rule="evenodd" d="M172.813,8.49l-1.046,6.367h26.142L200,8.49H172.813z"/><path fill-rule="evenodd" clip-rule="evenodd" d="M170.721,22.286l-2.091,11.673c0,0-0.418,8.49,8.365,8.49s9.411,0,9.411,0 l2.091-6.368h-9.411c0,0-4.601-0.849-3.137-6.367c1.464-5.519,2.092-7.429,2.092-7.429H170.721z"/><path fill-rule="evenodd" clip-rule="evenodd" d="M78.702,15.918l-6.274,31.836c0,0-0.418,4.245,5.228,4.245 c0.836,0,6.274-23.347,6.274-23.347h12.548l-1.045,7.428c0,0,6.064,0.212,7.319-4.245C104.007,27.379,109.026,0,109.026,0h-6.274 l-5.228,22.286H84.976l1.046-6.367H78.702z"/><path fill-rule="evenodd" clip-rule="evenodd" d="M12.824,8.49L5.504,43.51c0,0-6.971,0.354-5.229-8.49
    C2.019,26.177,5.504,8.49,5.504,8.49H12.824z"/>
    <path fill-rule="evenodd" clip-rule="evenodd" d="M44.194,14.857H15.961c0,0,1.917-6.367,7.32-6.367s21.959,0,21.959,0
    L44.194,14.857z"/>
    <path fill-rule="evenodd" clip-rule="evenodd" d="M42.103,22.286c0,0-2.44,20.164-14.64,20.164s-16.731,0-16.731,0l2.092-6.368
    h15.685c0,0,5.228-1.934,5.228-7.428c0-0.708-16.73,0-16.73,0s-2.091,0.884-2.091-6.368C14.916,22.109,42.103,22.286,42.103,22.286z
    "/>
    <path fill-rule="evenodd" clip-rule="evenodd" d="M68.245,14.857c0,0-2.266,21.225-8.365,21.225s-9.411,0-9.411,0l-8.365,7.429
    h16.73c0,0,9.585-3.36,11.503-10.612c1.917-7.251,5.228-24.408,5.228-24.408H57.788c-0.178-0.001-7.421-0.055-9.967,9.547
    c-1.686,6.36-5.718,25.474-5.718,25.474l8.365-7.429l3.137-16.979c0,0,1.307-4.112,5.228-4.245
    C62.755,14.725,68.245,14.857,68.245,14.857z"/>
</svg>                                </i>
                                <!--[if IE 8]><img src="https://static.isohunt.to/img/logo.gif" class="img-responsive" alt="isoHunt Logo" width="195" height="50" /><![endif]-->
                            </a>
                        </div>
                        <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar-collapse">
                          <span class="sr-only">Toggle navigation</span>
                          <span class="icon-bar"></span>
                          <span class="icon-bar"></span>
                          <span class="icon-bar"></span>
                        </button>
                      </div>

                      <div class="collapse navbar-collapse" id="navbar-collapse">

                        <ul id="upper-nav" class="nav navbar-nav navbar-left"><li class="hidden-xs"><a title="isohunt.to" href="/"><span class=" glyphicon glyphicon-home"></span></a></li>
<li class="dropdown"><a title="Browse all torrents by category" class="dropdown-toggle text-warning" data-toggle="dropdown" href="/torrents/">Torrents<span class="caret ml-h2"></span></a>
<ul class='dropdown-menu latest' role='menu'>
<li><a href="/torrents/?iht=1&amp;age=0" title="anime">Anime torrents</a></li>
<li><a href="/torrents/?iht=2&amp;age=0" title="software">Software torrents</a></li>
<li><a href="/torrents/?iht=3&amp;age=0" title="games">Games torrents</a></li>
<li><a href="/torrents/?iht=4&amp;age=0" title="adult">Adult torrents</a></li>
<li><a href="/torrents/?iht=5&amp;age=0" title="movies">Movies torrents</a></li>
<li><a href="/torrents/?iht=6&amp;age=0" title="music">Music torrents</a></li>
<li><a href="/torrents/?iht=7&amp;age=0" title="other">Other torrents</a></li>
<li><a href="/torrents/?iht=8&amp;age=0" title="seriestv">Series & TV torrents</a></li>
<li><a href="/torrents/?iht=9&amp;age=0" title="books">Books torrents</a></li>
</ul>
</li>
<li class="dropdown"><a title="Realtime" class="dropdown-toggle" data-toggle="dropdown" href="#">Latest<span class="caret ml-h2"></span></a>
<ul class='dropdown-menu latest' role='menu'>
<li><a title="Last 60 files indexed" href="/latest.php">Torrents</a></li>
<li><a title="Last torrents uploaded by trusted releasers" href="/releases.php">Releases</a></li>
<li><a href="/statistic/hotSearches">Searches</a></li>
<li><a href="/statistic/hot/torrents">Hot Torrents</a></li>
</ul>
</li>
<li><a href="/faq">FAQ</a></li>
<li class=" link-warning"><a href="/charts"><span class="glyphicon glyphicon-fire mr-h4"></span>Movies charts</a></li>
<li><a href="https://forum.isohunt.to">Forum</a></li>
<li><a rel="nofollow" href="/contact-us">Contacts</a></li></ul>                        <ul class="nav navbar-nav navbar-right">
                                                                                    <li>
                                <a href="/torrents/upload" rel="nofollow" id="upload">
                                    <span class="glyphicon glyphicon-upload mr-h4"></span>Upload torrent
                                </a>
                            </li>
                                                            <li class="link-success">
                                    <a href="/profile/register" rel="nofollow" id="sign_up">
                                        <span class="glyphicon glyphicon-check mr-h4"></span>Sign up
                                    </a>
                                </li>
                                <li>
                                    <a href="/profile/login" rel="nofollow" id="login">
                                        <span class="glyphicon glyphicon-user mr-h4"></span> Log in
                                    </a>
                                </li>
                                                    </ul>
                      </div>
                    </div>
                  </nav>
                <div class="container-fluid">
                    <div class="row header-center">
                        <form name="ihSearch" action="/torrents/" class="col-md-5 col-sm-6 col-xs-8 suggest-wrap">
                            <div class="input-group input-query white-inputs">

                                <input name="ihq" id="ihq" class="form-control" type="text" maxlength="100" placeholder="Search torrents"
                                        accesskey="s" tabindex="1" value=""
                                        x-webkit-speech="" speech="" autocomplete="off" role="textbox">

                                <!-- suggest -->
                                <div class="search-sugestion" id="ihq-suggest" style="display:none;"></div>
                                <!-- /suggest -->

                                <span class="input-group-btn">
                                    <input type="submit" tabindex="2" id="searchBox" value="Search" class="btn btn-default">
                                </span>


                            </div>
                        </form>
                        <div class="col-md-3 col-sm-3 col-xs-4 header-adv-search">
                            <a href="/torrents/advancedSearch" rel="nofollow" id="adv_search">Advanced search</a>
                            <a href="/help/search" rel="nofollow" class="opacity-animated"><span class="glyphicon glyphicon-question-sign"></span></a>
                        </div>
                        <div class="col-md-4 col-sm-3 hidden-xs text-right logo-nav">
                            <a href="/" title="Home page">
                                <i title="isoHunt Logo">
                                    <svg version="1.1" id="Layer_1" xmlns="http://www.w3.org/2000/svg" x="0px" y="0px"
        viewBox="0 0 200 52" enable-background="new 0 0 200 52" xml:space="preserve">
    <path fill-rule="evenodd" clip-rule="evenodd" d="M112.163,8.49l-5.229,24.408c0,0,1.046,9.551,7.32,9.551
    c6.274,0,17.776,0,17.776,0l1.046-6.368h-15.685c0,0-3.312-0.531-2.091-8.49c1.22-7.959,4.183-19.102,4.183-19.102H112.163z"/>
    <path fill-rule="evenodd" clip-rule="evenodd" d="M139.351,8.49l-4.183,21.225c0,0-6.448-0.708-6.274-4.245 c0.174-3.537,3.137-16.979,3.137-16.979H139.351z"/>
    <path fill-rule="evenodd" clip-rule="evenodd" d="M143.534,8.49l-4.183,20.164c0,0-2.38,7.428,5.229,7.428
    c0.739,0,4.183-21.225,4.183-21.225l9.411,1.062c0,0,4.009,0.354,2.091,8.49c-1.917,8.136-3.137,14.857-3.137,14.857 s1.394,4.245,6.274,4.245c0.697,0,4.183-24.408,4.183-24.408s0.349-10.612-8.365-10.612S143.534,8.49,143.534,8.49z"/><path fill-rule="evenodd" clip-rule="evenodd" d="M172.813,8.49l-1.046,6.367h26.142L200,8.49H172.813z"/><path fill-rule="evenodd" clip-rule="evenodd" d="M170.721,22.286l-2.091,11.673c0,0-0.418,8.49,8.365,8.49s9.411,0,9.411,0 l2.091-6.368h-9.411c0,0-4.601-0.849-3.137-6.367c1.464-5.519,2.092-7.429,2.092-7.429H170.721z"/><path fill-rule="evenodd" clip-rule="evenodd" d="M78.702,15.918l-6.274,31.836c0,0-0.418,4.245,5.228,4.245 c0.836,0,6.274-23.347,6.274-23.347h12.548l-1.045,7.428c0,0,6.064,0.212,7.319-4.245C104.007,27.379,109.026,0,109.026,0h-6.274 l-5.228,22.286H84.976l1.046-6.367H78.702z"/><path fill-rule="evenodd" clip-rule="evenodd" d="M12.824,8.49L5.504,43.51c0,0-6.971,0.354-5.229-8.49
    C2.019,26.177,5.504,8.49,5.504,8.49H12.824z"/>
    <path fill-rule="evenodd" clip-rule="evenodd" d="M44.194,14.857H15.961c0,0,1.917-6.367,7.32-6.367s21.959,0,21.959,0
    L44.194,14.857z"/>
    <path fill-rule="evenodd" clip-rule="evenodd" d="M42.103,22.286c0,0-2.44,20.164-14.64,20.164s-16.731,0-16.731,0l2.092-6.368
    h15.685c0,0,5.228-1.934,5.228-7.428c0-0.708-16.73,0-16.73,0s-2.091,0.884-2.091-6.368C14.916,22.109,42.103,22.286,42.103,22.286z
    "/>
    <path fill-rule="evenodd" clip-rule="evenodd" d="M68.245,14.857c0,0-2.266,21.225-8.365,21.225s-9.411,0-9.411,0l-8.365,7.429
    h16.73c0,0,9.585-3.36,11.503-10.612c1.917-7.251,5.228-24.408,5.228-24.408H57.788c-0.178-0.001-7.421-0.055-9.967,9.547
    c-1.686,6.36-5.718,25.474-5.718,25.474l8.365-7.429l3.137-16.979c0,0,1.307-4.112,5.228-4.245
    C62.755,14.725,68.245,14.857,68.245,14.857z"/>
</svg>                                </i>
                                <!--[if IE 8]><img src="https://static.isohunt.to/img/logo.gif" alt="isoHunt Logo" width="195" height="50" /><![endif]-->
                            </a>
                        </div>
                    </div>

                    <div class="row subhead hidden-xs">
                        <div class="col-lg-10 col-md-9 col-sm-8">
                            <div class="tips">
                                                                <span class="mr-h4 text-muted glyphicon glyphicon-other"></span>Have a nice Isohunting day!                            </div>
                        </div>
                        <div class="col-lg-2 col-md-3 col-sm-4 text-right">
                            <div class="socials">
                                <!-- FB link-->
                                <a class="fb-group" target="_blank" href="https://www.facebook.com/isohuntto" rel="nofollow">
                                    Isohunt on facebook
                                </a>
                                <div class="social_toolbox ilb ml">
                                    <a href="https://www.facebook.com/sharer/sharer.php?u=https%3A%2F%2Fisohunt.to%2F%23.U4a9XEI9ADA.facebook&amp;p[title]=isoHunt%20-%20BitTorrent%20%26%20P2P%20torrent%20search%20engine&amp;display=popup" title="Facebook" target="_blank"><img src="https://static.isohunt.to/img/oa-f.svg" width="24" height="24" border="0" /></a>                                    <a href="https://twitter.com/intent/tweet?text=isoHunt+-+BitTorrent+%26+P2P+torrent+search+engine&amp;url=http%3A%2F%2Fisohunt.to%2F&amp;related=" title="Twitter" target="_blank"><img src="https://static.isohunt.to/img/oa-t.svg" width="24" height="24" border="0" /></a>                                    <a href="https://www.addthis.com/bookmark.php?v=300&amp;winname=addthis&amp;pub=ra-5270fd5a625e5ffa&amp;source=tbx-300&amp;s=google_plusone_share&amp;url=http%3A%2F%2Fisohunt.to%2F&amp;title=isoHunt%20-%20BitTorrent%20%26%20P2P%20torrent%20search%20engine&amp;ate=AT-ra-5270fd5a625e5ffa/-/-/5386be442dca5990/2&amp;frommenu=1&amp;uid=5386be441b6fa1bb&amp;ct=1&amp;pre=http%3A%2F%2Fisohunt.to%2&amp;tt=0&amp;captcha_provider=nucaptcha" title="Google+" target="_blank"><img src="https://static.isohunt.to/img/oa-g.svg" width="24" height="24" border="0" /></a>                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </header>


            <!--End of header-->

            <div class="container-fluid">
                <div class="row">

                    <div class="col-lg-10 col-md-10 col-sm-9 pb2 pt-h2">
                                                                                                                        <div class="banner-wrp b728  hidden-xs ">
            <div class="banner-links">Advertising [
            <a href="/profile/login" rel="nofollow">remove</a>             ]
        </div>
        <div id="isobanner-2" class="banner banner728">
        <script>var m3_u="//i.isohunt.to/www/delivery/ajs.php";var m3_r=Math.floor(Math.random()*1000);if(!document.MAX_used){document.MAX_used=","}document.write("<script src='"+m3_u);document.write("?zoneid=2");document.write("&amp;cb="+m3_r);if(document.MAX_used!=","){document.write("&amp;exclude="+document.MAX_used)}document.write(document.charset?"&amp;charset="+document.charset:(document.characterSet?"&amp;charset="+document.characterSet:""));document.write("&amp;loc="+escape(window.location));if(document.referrer){document.write("&amp;referer="+escape(document.referrer))}if(document.context){document.write("&context="+escape(document.context))}if(document.mmm_fo){document.write("&amp;mmm_fo=1")}document.write("'><\/script>");</script>
    </div>
</div>

<div class="p mb-h2 p-h2 bg-white">
    <ol class="breadcrumb mb0 breadcrumb-none ">
        <li><a href="/torrents/" title="Browse all torrents by category">Browse All Torrents</a></li>
        <li><a href="/torrents/?iht=2&amp;age=0">Software</a></li>
        <li><span itemprop="title">Office 2010 Professional Plus x86 x64 [PL] [SP2.2016.07-NiKKA] [Isohunt.to]</span></li>
    </ol>
</div>



<div class="row mt">
    <div class="col-sm-12">

        <!--    Center column: main info-->
        <div class="bg-white">


            <!-- Torrent name and tech info           -->

            <div class="p">

                                    <div id="isobanner-6" class="banner banner300 pull-right mb ml hidden-xs ">
    <script>var m3_u="//i.isohunt.to/www/delivery/ajs.php";var m3_r=Math.floor(Math.random()*1000);if(!document.MAX_used){document.MAX_used=","}document.write("<script src='"+m3_u);document.write("?zoneid=6");document.write("&amp;cb="+m3_r);if(document.MAX_used!=","){document.write("&amp;exclude="+document.MAX_used)}document.write(document.charset?"&amp;charset="+document.charset:(document.characterSet?"&amp;charset="+document.characterSet:""));document.write("&amp;loc="+escape(window.location));if(document.referrer){document.write("&amp;referer="+escape(document.referrer))}if(document.context){document.write("&context="+escape(document.context))}if(document.mmm_fo){document.write("&amp;mmm_fo=1")}document.write("'><\/script>");</script>
</div>
                <h1 class="torrent-header mt0">
                    <a href="/torrent_details/17003572/Office-2010-Professional-Plus-x86-x64-PL-SP2-2016-07-NiKKA-Isohunt-to" class="link-textcolor vm">Office 2010 Professional Plus x86 x64 [PL] [SP2.2016.07-NiKKA] [Isohunt.to]</a>
                                                                        <small><span class="label label-success vm mr-h4"><span
                                        class="glyphicon glyphicon-ok mr-h4"></span> Verified</span></small>
                                                                                </h1>

                <p class="text-lg mb2">Size&nbsp;4.764 GB                    &nbsp;&nbsp;0&nbsp;seeders
                    &nbsp; &nbsp; Added&nbsp;2016-07-27 14:23:47                </p>

                                    <div class="btn-group btn-group-lg">
            <a href="https://torrent.isohunt.to/download.php?id=20504094&name=Office+2010+Professional+Plus+x86+x64+%5BPL%5D+%5BSP2.2016.07-NiKKA%5D+%5BIsohunt.to%5D&hash=0b7317b40a0aba291049ea3c85f7d072f8c29d47"
           title="You need BitTorrent software for this P2P download link to work"
           class="btn btn-lg btn-warning btn-download"
           rel="nofollow"
           onclick="ga('send', 'event', 'Buttons_torrentpage', 'Torrent_button_click')">
            <span class="glyphicon glyphicon-download mr-h4"></span> Download torrent
        </a>
        <a href="magnet:?xt=urn:btih:0b7317b40a0aba291049ea3c85f7d072f8c29d47&amp;dn=Office+2010+Professional+Plus+x86+x64+%5BPL%5D+%5BSP2.2016.07-NiKKA%5D+%5BIsohunt.to%5D&amp;xl=4763870058&amp;dl=4763870058&amp;tr=http://tracker.filetracker.pl:8089/announce&amp;tr=http://tracker.filetracker.pl:8089/announce&amp;tr=http://tracker.tfile.me:80/announce&amp;tr=udp://tracker.bittor.pw:1337/announce&amp;tr=udp://tracker.coppersurfer.tk:6969/announce&amp;tr=udp://tracker.opentrackr.org:1337/announce&amp;tr=udp://zer0day.ch:1337/announce"
           class="btn btn-lg btn-warning btn-magnet btn-border-left"
           title="Download Magnet link"
           onclick="ga('send', 'event', 'Buttons_torrentpage', 'Magnet_button_click')">
            <span class="glyphicon glyphicon-magnet"></span>
        </a>
    </div>

    <div class="bitlord btn-group">
        <a class="btn btn-lg btn-warning btn-bitlord-badge-new" href="http://www.bitlord.com/share/?re=IsoHunt.to&amp;ba=0E3B6B&amp;co=fff&amp;sh=Office-2010-Professional-Plus-x86-x64-PL-SP2-2016-07-NiKKA-Isohunt-to&amp;ur=https://isohunt.to//torrent_details/17003572/Office-2010-Professional-Plus-x86-x64-PL-SP2-2016-07-NiKKA-Isohunt-to" title="BitLord streaming" target="_blank" onclick="ga(&quot;send&quot;, &quot;event&quot;, &quot;Bitlord&quot;, &quot;torrent_install_click&quot;, &quot;bitlord&quot;);">Install &amp; Download</a>    </div>
                    <div class="btn-group rate-btns" itemprop="aggregateRating" itemscope itemtype="http://schema.org/AggregateRating">
    <a data-rating="1" class="btn btn-default-success btn-lg rt-good" title="Rate as good">
        <span class="glyphicon glyphicon-plus"></span>
        <!--<span id="rating-good">0</span>-->
    </a>
    <span class="btn btn-lg-text-xlg btn-default disabled"><b id="ratingValue" itemprop="ratingValue">5</b></span>
    <a data-rating="0" class="btn btn-default-danger btn-lg rt-bad" title="Rate as bad">
        <span class="glyphicon glyphicon-minus"></span>
        <!-- <span id="rating-bad">0</span> -->
    </a>
</div>

                                            <div class="bitlord-download-hint">
                            To download or stream you need BitLord. Visit them
                            at <a href="http://bitlord.com" rel="nofollow" target="_blank" onclick="ga(&#039;send&#039;, &#039;event&#039;, &#039;Bitlord&#039;, &#039;bitlord_com_click&#039;, &#039;bitlord&#039;)">BitLord.com</a>                        </div>
                                                    <ul id="detailsTabs" class="nav nav-tabs mt2 mb" role="tablist">
            <li role="presentation" class="active">
            <a id="detailsTab" href="#torrent_details" role="tab" data-toggle="tab">
                <span class="glyphicon glyphicon-tags mr-h2"></span>Summary
            </a>
        </li>

    <li role="presentation">
        <a id="filesTab" href="#torrent_files" role="tab" data-toggle="tab">
            <span class="glyphicon glyphicon-folder-open mr-h2"></span>Torrent files
            <span class="badge ml-h2">4.764 GB</span>
        </a>
    </li>

    <li role="presentation">
        <a id="trackersTab" href="#torrent_trackers" role="tab" data-toggle="tab">
            <span class="glyphicon glyphicon-list mr-h2"></span>Trackers
            <span class="badge ml-h2">
                <span class="seeds">0                </span> seeders
                <span class="leechs">0</span>
                leechers
            </span>
        </a>
    </li>

    <li role="presentation">
        <a id="commentsTab" href="#torrent_comments" role="tab" data-toggle="tab">
            <span class="glyphicon glyphicon-comment mr-h2"></span>Comments
            <span class="badge ml-h2">0</span>
        </a>
    </li>


</ul>




<!-- Tab content -->
<div class="tab-content">


            <div role="tabpanel" id="torrent_details" class="tab-pane active">
            <div class="torrent-description">
                                <div>
                    <pre>NiKKA p r e s e n t s :

[b]2w1.Office.2010.Professional.Plus.SP2.PL.x86.x64.2016.07-NiKKA[/b]

2 wersje Office 2010 Professional Plus PL - Retail i VL (x86/x64)

[IMG]<img  data-url="http://i68.tinypic.com/13yxq9.jpg" src=""  alt="image" />[/IMG]

[b]Opis:[/b]

[spoiler]Microsoft Office (w skrócie MSO od Microsoft Office) to pakiet aplikacji biurowych wyprodukowany przez firmę Microsoft. Wprowadzony na rynek 1 sierpnia 1989.

Programy składające się na Microsoft Office są przeznaczone do uruchamiania na platformie Microsoft Windows oraz Apple Mac OS X, lecz mogą zostać uruchomione na innych systemach (GNU/Linux, FreeBSD itp.) za pomocą programów takich jak np. Wine.


Pierwszy pakiet zbiorczych aktualizacji i poprawek [b](SP1)[/b] przeznaczony dla pakietu biurowego Office 2010 w wersji 32- i 64-bitowej ukazał sie pod koniec czerwca 2011.

Zmian wprowadzonych wraz z Service Packiem 1 nie ma wiele i są to raczej kosmetyczne poprawki, zwłaszcza jeśli spojrzymy na to z punktu widzenia użytkownika domowego. Mimo tego zalecamy instalację dodatku wszystkim, ponieważ wnosi on między innymi szereg poprawek zabezpieczeń. Zaawansowani użytkownicy i firmy znajdą w SP1 poprawki w użyteczności widoku prezentera w PowerPoincie, we współpracy Project Server i SharePoint Server oraz w backupie tego drugiego. Search Server zyskał możliwość indeksowania plików PPSX (zapisanych pokazów slajdów), w Visio zaś poprawione zostały problemy ze skalowaniem podczas eksportu do formatu SVG.

W Outlook Web Application w usłudze Exchange Online wprowadzony został natomiast podgląd załączników. Bezpłatne Office Web Apps, czyli webowe wersje Worda, Excela, PowerPointa i OneNote, są z kolei teraz oficjalnie obsługiwane w przeglądarce Google Chrome.

Drugi pakiet zbiorczych aktualizacji i poprawek [b](SP2)[/b] przeznaczony dla pakietu biurowego Office 2010 w wersji 32- i 64-bitowej ukazał sie pod koniec lipca 2013.

Co nowego wprowadza Service Pack 2 dla Office 2010? Okazuje się, że niewiele, gdyż jest to przede wszystkim zbiór dotychczasowych patchy wydanych w przeciągu ostatnich lat (do maja 2013 roku włącznie) za pośrednictwem usługi Microsoft Update. Gigant z Redmond zintegrował również część poprawek, których wcześniej nigdy nie udostępniono. Z informacji ujawnionych przez Microsoft wynika, że te drugie z wymienionych patchy mają przede wszystkim podnieść wydajność i stabilność oprogramowania.

Do kiedy Microsoft zamierza oferować wsparcie dla Office 2010? Podstawowe wsparcie będzie oferowane do listopada 2015 roku i przed tą datą możemy spodziewać się jeszcze jednego Service Packa dla tej wersji pakietu biurowego. Z kolei wsparcie rozszerzone będzie kontynuowane do listopada 2020 roku.


W skład pakietu Office 2010 Professional Plus wchodzą:
- Access 2010
- Excel 2010
- InfoPath 2010
- OneNote 2010
- Outlook 2010
- PowerPoint 2010
- Publisher 2010
- SharePoint Workspace 2010
- Visio Viewer 2010
- Word 2010[/spoiler]


[b]Info:[/b]

Sources: MS ISO's

Type: Office, pakiet biurowy, x86, 32bit, x64, 64bit
Language: Polish, Polski
Volume: 1xDVD9
Create Date: 2016.07.24
Release Date: 2016.07.26
By: NiKKA


[b]Contents:[/b]

- 2w1 - w jednym ISO 2 wersje: 1xRetail i 1xVL (kazda zarowno x86 jak i x64)
- dodane latki wydane po SP2 (folder Updates) do 2016.07
- mozna instalowac ze swoim oryginalnym kluczem Retail
  lub wersja VL - klucz MAK


[b]Instruction:[/b]

Rozmiar pliku ISO: 4,39 GB (bajtów: 4 723 761 152)
SHA1 pliku ISO: ef192e46d30cb55f4261ac6454d1f9483fcbea25

Wypalić ISO na DVD [b](DVD9)[/b] albo montować w demonie albo VMware albo nagrać na Pendrive [b](8GB minimum)[/b].
UltraISO, albo PowerISO (z opcją optymalizacji).

Wszystkie aktualizacje zawarte w katalogu "Updates" zostaną zaaplikowane wraz z zainstalowaniem pakietu.
Domyślnie przez główny setup.exe instaluje się wersja x86 (nawet na systemie x64). Chcąc zaintalować wersję x64 na systemie x64 trzeba ręcznie przejść do katalogu x64 i wybrać setup.exe


[b]Aktywacja - czytaj aktywacja.txt[/b]

P.S. Literówka w dacie w .nfo oczywiście łatki są aktualne na 2016.07.</pre>                </div>
            </div>
        </div>

    <div role="tabpanel" class="tab-pane" id="torrent_files">
        <table class="table table-no-top-border files">
            <tbody>
                                    <tr>
                        <td>2w1.Office.2010.Professional.Plus.SP2.PL.x86.x64.2016.07-NiKKA.iso</td>
                        <td>4.724 GB</td>
                    </tr>
                                    <tr>
                        <td>2w1.Office.2010.Professional.Plus.SP2.PL.x86.x64.2016.07-NiKKA.nfo</td>
                        <td>3.524 KB</td>
                    </tr>
                                    <tr>
                        <td>2w1.Office.2010.Professional.Plus.SP2.PL.x86.x64.2016.07-NiKKA.sha</td>
                        <td>110 B</td>
                    </tr>
                            </tbody>
        </table>
        <a href="#" class="files-showmore hidden btn btn-default"></a>
    </div>

    <div role="tabpanel" class="tab-pane" id="torrent_trackers">
        <div class="tab-container"><span class="glyphicon glyphicon-time animation-blink"></span> Gathering some info...</div>
    </div>
    <div role="tabpanel" class="tab-pane" id="torrent_comments">
        <div class="box-comment" id="box-comment">
    <div class="comment-items" data-url="/comment2/list?record_id=17003572">
    </div>

    <form id="comment-form" action="/comment2/add" method="post">
<input type="hidden" name="_csrf" value="Ty5MUGE1Mk4LQHURAmRKYyBMADkpRXN3BUUcCCVWA3o8FwYmO3NENA==">    <input type="hidden" id="comment-record_id" name="Comment[record_id]" value="17003572">    <input type="hidden" id="comment-parent" name="Comment[parentId]" value="0">
    <div class="row mb">
        <div class="col-sm-9 col-md-7 col-lg-5">
            <div class="form-group field-comment-comment required">
<div class="help-block"></div>
<textarea id="comment-comment" class="form-control mb-h2" name="Comment[comment]" maxlength="4000" rows="5"></textarea>
</div>
                            <div>
                    <p class="font-12 grey"><a href="/site/signup">Register</a> and log in Isohunt
                        and see no captcha anymore!</p>
                    <div class="form-group field-comment-recaptcha">
<div class="help-block"></div>
<input type="hidden" id="comment-recaptcha" name="Comment[reCaptcha]"><div class="g-recaptcha" data-sitekey="6LeKzgITAAAAAIGw28hq-u1jtMsuSakyEiIw5zJN" data-callback="recaptchaCallback"></div>
</div>                </div>

            <div class="mb opacity-50 ">
                <span class="comment-chars-left">4000</span> symbols left
            </div>

            <button type="submit" id="addComment" class="btn btn-success btn-lg" name="login-button">Add comment</button>
            <div id="comment-reply" class="reply-block pull-right" style="display: none">
                Reply to comment,
                <span id="comment-reply-author" class="bold"></span>
                <a id="btn-reply-cancel" class="dashed reply-cancel" href="#">Cancel</a>            </div>
        </div>
    </div>

    </form>
    <script type="text/template" id="box-comment-edit-tmpl">
        <form action="/comment2/edit" method="post">
<input type="hidden" name="_csrf" value="Ty5MUGE1Mk4LQHURAmRKYyBMADkpRXN3BUUcCCVWA3o8FwYmO3NENA==">        <input type="hidden" name="comment-id" value="0">        <div class="form-group field-comment">
            <div class="help-block"></div>
            <textarea class="form-control mb-h2" name="comment" maxlength="4000" rows="5"></textarea>        </div>
        <div class="btn-group">
            <button type="button" class="btn btn-danger">Cancel</button>            <button type="button" class="btn btn-success">Save</button>        </div>
        </form>    </script>
</div>
    </div>

</div>
                <div class="text-muted mt">Hash&nbsp;0b7317b40a0aba291049ea3c85f7d072f8c29d47</div>
            </div>
        </div>
        <!--   END Center column: main info-->
    </div>
    <!--    Right column: related cards-->


    <!--   END Right column: related cards-->
</div>

    <div class="p bg-white mt">
                    <h2 id="rel_tor">Related torrents for "Office 2010 Professional Plus x86 x64 [PL] [SP2.2016.07-NiKKA] [Isohunt.to]"</h2>
            <div id="related">
                <div id="serps" class="grid-view"><table class="table-torrents table table-striped table-hover">
<thead>
<tr><th>&nbsp;</th><th>Torrents</th><th>&nbsp;</th><th rel="nofollow">&nbsp;</th><th rel="nofollow">Age</th><th rel="nofollow">Size</th><th rel="nofollow">S</th><th><span class="glyphicon glyphicon-stats"></span></th></tr>
</thead>
<tbody>
<tr data-key="0"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/13544450/Office-2010-Professional-Plus-x86-x64-PL-SP2-Kwiecien-2015-NiKKA-Isohunt-to"><span>Office 2010 Professional Plus x86 x64 [PL] [SP2.Kwiecien.2015-NiKKA] [Isohunt.to]</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"><i title="Verified Torrent"><span class="glyphicon glyphicon-ok-sign text-success"></span></i></div></td><td class="comments-row"></td><td class="date-row">1 year</td><td class="size-row">4.664 GB</td><td class="sy">19</td><td class="rating-row">5</td></tr>
<tr data-key="1"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16229973/office-professional-plus-2016-x86-x64-PTBR-iso"><span>office professional plus 2016 x86 x64 PTBR.iso</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"></div></td><td class="comments-row"></td><td class="date-row">4 months</td><td class="size-row">2.303 GB</td><td class="sy">8</td><td class="rating-row">5</td></tr>
<tr data-key="2"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/5423135/Microsoft-Office-Professional-Plus-x86-x64-Key-Activator"><span>Microsoft Office Professional Plus x86 x64  - Key Activator</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"></div></td><td class="comments-row"></td><td class="date-row">4 years</td><td class="size-row">704.366 KB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
<tr data-key="3"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16105237/Office-professional-plus-2016-x86-x64-With-KMS-included"><span>Office professional plus 2016 x86 x64 With KMS included !</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"></div></td><td class="comments-row"></td><td class="date-row">6 months</td><td class="size-row">2.445 GB</td><td class="sy">4</td><td class="rating-row">5</td></tr>
<tr data-key="4"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/15961315/Microsoft-Office-Professional-Plus-2016-x64-amp-x86-v16-0-4312-1000-Incl-Portable-Activator"><span>Microsoft Office Professional Plus 2016 [x64 &amp; x86] v16.0.4312.1000 Incl Portable Activator</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"></div></td><td class="comments-row"></td><td class="date-row">7 months</td><td class="size-row">3.569 GB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
</tbody>
<tfoot>
<tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>
</tfoot>
</table></div>            </div>


                    <div class="tags">
                <h2>Torrent search:</h2>
                                                        <span class="tag mr-h4 vm">
                    <a href="/tag/platform/x32/"
                       title="Search by 'x32' tag">x32</a>
                </span>
                                                        <span class="tag mr-h4 vm">
                    <a href="/tag/year/2016/"
                       title="Search by '2016' tag">2016</a>
                </span>

                            </div>


    </div>


                    </div>

                    <div class="col-lg-2 col-md-2 col-sm-12">
                        <div class="chart-post post-sidebar">
    <div class="post-poster mt-h2" style="background-image: url(https://img.isohunt.to/resize/340x-/selections/132)">
        <a href="/charts/132"><img class="img" src="https://static.isohunt.to/img/16by9.png" alt="" title="Great Jazz Movies"></a>        <div class="post-poster-text">
                            <span class="tag">
                    <a href="/charts?tag=1">charts</a>                </span>

            <h2>
                <a href="/charts/132">Great Jazz Movies</a>            </h2>
        </div>
    </div>
</div>
                                                                                    <div id="isobanner-9" class="banner banner160"  >
    <script>var m3_u="//i.isohunt.to/www/delivery/ajs.php";var m3_r=Math.floor(Math.random()*1000);if(!document.MAX_used){document.MAX_used=","}document.write("<script src='"+m3_u);document.write("?zoneid=9");document.write("&amp;cb="+m3_r);if(document.MAX_used!=","){document.write("&amp;exclude="+document.MAX_used)}document.write(document.charset?"&amp;charset="+document.charset:(document.characterSet?"&amp;charset="+document.characterSet:""));document.write("&amp;loc="+escape(window.location));if(document.referrer){document.write("&amp;referer="+escape(document.referrer))}if(document.context){document.write("&context="+escape(document.context))}if(document.mmm_fo){document.write("&amp;mmm_fo=1")}document.write("'><\/script>");</script>

        <a href="/profile/login" rel="nofollow">Remove advertising</a>    </div>                                <hr>


<div class="row">
    <div class="col-md-12 col-sm-6">
        <h3>Top Searches</h3>
        <ol class="nopadding-sm">
                                                <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=iron+man">iron man</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=orange+is+the+new+black">orange is the new black</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=holed">holed</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=300%3A+Rise+Of+An+Empire">300: Rise Of An Empire</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=office">office</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=arrow">arrow</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=a+million+ways+to+die+in+the+west">a million ways to die in the west</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=the+best">the best</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=money">money</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=windows+10">windows 10</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=transformers+4">transformers 4</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=microsoft+office">microsoft office</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=xxx">xxx</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq="></a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=batman+vs+superman">batman vs superman</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=mp4">mp4</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=vikings">vikings</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=windows+7">windows 7</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=game+of+thrones">game of thrones</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=divergent">divergent</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=games">games</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=game+of+throne">game of throne</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=the+walking+dead">the walking dead</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=girls">girls</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=masterchef+australia">masterchef australia</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=FIFA+world+cup+2014">FIFA world cup 2014</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=penny+dreadful">penny dreadful</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=subs">subs</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=tamil">tamil</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=brazzers">brazzers</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=kabali">kabali</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=castle">castle</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=daz3d">daz3d</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=game+of+thrones+s04e06">game of thrones s04e06</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=mr+robot">mr robot</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=the+big+bang+theory">the big bang theory</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=big+bang+theory">big bang theory</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=girl">girl</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=batman+v+superman">batman v superman</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=formula+1">formula 1</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=Divergent">Divergent</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=alles">alles</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=clips4sale">clips4sale</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=walking+dead">walking dead</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=edge+of+tomorrow">edge of tomorrow</a></li>                                    </ol><hr class="hidden-sm">
    </div>
    <div class="col-md-12 col-sm-6">
        <h3 class="hidden-md hidden-lg">Statistics</h3>
        <p class="pl2"><a href="/allTopSearches"><span class="glyphicon glyphicon-stats text-muted mr-h4"></span>All Top Searches</a><p>
        <p class="pl2"><a href="/users/top"><span class="glyphicon text-muted glyphicon-user mr-h4"></span>Top IsoHunters</a></p>
                    <div class="alert alert-success">
                <a href="/profile/register" rel="nofollow">Sign up</a>                now to <b>comment</b> and <b>upload</b> torrent!
            </div>

        <h3>Friends</h3>
<ul>
            <li><a href="http://isohunters.net" target="_blank">Official Isohunt Proxy</a></li>
            <li><a href="http://www.torrentfreak.com/" target="_blank">TorrentFreak</a></li>
            <li><a href="http://extratorrent.video" target="_blank">Extratorrent</a></li>
            <li><a href="https://justhideme.com/" target="_blank">JustHideMe - VPN</a></li>

    </ul>    </div>
</div>
                    </div>
                </div>
            </div>

            </div>
        </div>
        <footer class="footer">
                                                <div class="banner-wrp  hidden-xs b728">
            <div class="banner-links hidden-xs">Advertising [
            <a href="/profile/login" rel="nofollow">remove</a>             ]
        </div>
        <div id="isobanner-3" class="banner banner728">
        <script>var m3_u="//i.isohunt.to/www/delivery/ajs.php";var m3_r=Math.floor(Math.random()*1000);if(!document.MAX_used){document.MAX_used=","}document.write("<script src='"+m3_u);document.write("?zoneid=3");document.write("&amp;cb="+m3_r);if(document.MAX_used!=","){document.write("&amp;exclude="+document.MAX_used)}document.write(document.charset?"&amp;charset="+document.charset:(document.characterSet?"&amp;charset="+document.characterSet:""));document.write("&amp;loc="+escape(window.location));if(document.referrer){document.write("&amp;referer="+escape(document.referrer))}if(document.context){document.write("&context="+escape(document.context))}if(document.mmm_fo){document.write("&amp;mmm_fo=1")}document.write("'><\/script>");</script>
    </div>
</div>
</div>
                                                            <!-- Popunder -->
			<script>function getCookie(e,t){var i=new Date;i.setTime(i.getTime());for(var n=new Date(i.getTime()+36e5*t).toGMTString(),o=document.cookie.split(";"),r="",s="",a=[0,n],u=0;u<o.length;u++){if(r=o[u].split("="),s=r[0].replace(/^\s+|\s+$/g,""),s==e)return b_cookie_found=!0,r.length>1&&(a=unescape(r[1]).split("|"),1==a.length&&(a[1]=n)),a;r=null,s=""}return a}function initPop(){var e,t=[],i=[];t.push({hours:"1",cookie:"ih",times:2,url:"//isohunt.to/files/ih.js"}),t.push({hours:"12",cookie:"adk2_popunder",times:2,url:"//isohunt.to/files/ih1.js"});for(var n=0;n<t.length;n++)e=getCookie(t[n].cookie,t[n].hours),i[n]={},i[n].times=isNaN(Number(e[0]))?0:Number(e[0]),i[n].expires=isNaN(Date.parse(e[1]))?(new Date).toGMTString():e[1];for(var n=0;n<i.length;n++)if(i[n].times<t[n].times&&Date.parse(i[n].expires)>new Date){var o=document.createElement("script");o.setAttribute("src",t[n].url),document.head.appendChild(o),function(){var e=setInterval(function(){"undefined"!=typeof ga&&(ga("send","event","popAds","popunder",t[n].url),clearInterval(e))},500)}();break}}initPop();</script>
                        <script>var m3_u="//i.isohunt.to/www/delivery/ajs.php";var m3_r=Math.floor(Math.random()*1000);if(!document.MAX_used){document.MAX_used=","}document.write("<script src='"+m3_u);document.write("?zoneid=10");document.write("&amp;cb="+m3_r);if(document.MAX_used!=","){document.write("&amp;exclude="+document.MAX_used)}document.write(document.charset?"&amp;charset="+document.charset:(document.characterSet?"&amp;charset="+document.characterSet:""));document.write("&amp;loc="+escape(window.location));if(document.referrer){document.write("&amp;referer="+escape(document.referrer))}if(document.context){document.write("&context="+escape(document.context))}if(document.mmm_fo){document.write("&amp;mmm_fo=1")}document.write("'><\/script>");</script>


                    <!-- Mobile pushups -->

            <!-- Footer -->
            <p class="text-center mt gensmall" >
                <span name="disclaimer">isoHunt Inc. is not affiliated with this website.</span>
                |
                <a href="/rss/rss.xml" rel="nofollow">Get RSS feed</a>
                |
                <a href="/privacy" rel="nofollow">Privacy Policy</a>
                                <!--
                |
                <a href="/advertising/info"  rel="nofollow">Advertising</a>
                -->
                            </p>

        </footer>



        <!-- Google Analytics -->
<script>
    (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)})(window,document,'script','//www.google-analytics.com/analytics.js','ga');
    ga('create', 'UA-45151579-1', 'auto');
    ga('send', 'pageview');
</script>
        <script>
        if (window.location.hostname != "isohunt.to") {
            ga('send', 'event', 'Proxy', window.location.hostname);
        }
        </script>

                    <!-- Yandex.Metrika counter -->
            <script>(function(g,a,i){(a[i]=a[i]||[]).push(function(){try{a.yaCounter23411512=new Ya.Metrika({id:23411512,webvisor:true,clickmap:true,trackLinks:true,accurateTrackBounce:true})}catch(c){}});var h=g.getElementsByTagName("script")[0],b=g.createElement("script"),e=function(){h.parentNode.insertBefore(b,h)};b.type="text/javascript";b.async=true;b.src=(g.location.protocol=="https:"?"https:":"http:")+"//mc.yandex.ru/metrika/watch.js";if(a.opera=="[object Opera]"){g.addEventListener("DOMContentLoaded",e,false)}else{e()}})(document,window,"yandex_metrika_callbacks");</script>
            <noscript><div><img src="//mc.yandex.ru/watch/23411512" style="position:absolute; left:-9999px;" alt="" /></div></noscript>

 <script>
var isFramed = false;
try {
  isFramed = window != window.top || document != top.document || self.location != top.location;
   } catch (e) {
   isFramed = true;
   }
   if (isFramed) {
   window.top.location = 'https://isohunt.to/';
   }
</script>

        <script src="https://static.isohunt.to/assets/68f19057/yii.validation.js?v=1460716185"></script>
<script src="https://static.isohunt.to/assets/68f19057/yii.activeForm.js?v=1460716185"></script>
<script src="https://static.isohunt.to/assets/68f19057/yii.gridView.js?v=1460716185"></script>
<script type="text/javascript">jQuery(document).ready(function () {
commentsController.init("#commentslist");
torrentsController.init({
    id:             "17003572",
    hash:           "0b7317b40a0aba291049ea3c85f7d072f8c29d47",
    scrapeDate:     "",
    filesCount:     "6",
    commentsCount:  "0",
    isOwner:         0,
    name:           "Office 2010 Professional Plus x86 x64 [PL] [SP2.2016.07-NiKKA] [Isohunt.to]",
    description:    "NiKKA p r e s e n t s :    \
                   \
[b]2w1.Office.2010.Professional.Plus.SP2.PL.x86.x64.2016.07-NiKKA[/b]\
\
2 wersje Office 2010 Professional Plus PL - Retail i VL (x86/x64)\
\
[IMG]http://i68.tinypic.com/13yxq9.jpg[/IMG]\
\
[b]Opis:[/b]\
\
[spoiler]Microsoft Office (w skrócie MSO od Microsoft Office) to pakiet aplikacji biurowych wyprodukowany przez firmę Microsoft. Wprowadzony na rynek 1 sierpnia 1989.\
\
Programy składające się na Microsoft Office są przeznaczone do uruchamiania na platformie Microsoft Windows oraz Apple Mac OS X, lecz mogą zostać uruchomione na innych systemach (GNU/Linux, FreeBSD itp.) za pomocą programów takich jak np. Wine.\
\
\
Pierwszy pakiet zbiorczych aktualizacji i poprawek [b](SP1)[/b] przeznaczony dla pakietu biurowego Office 2010 w wersji 32- i 64-bitowej ukazał sie pod koniec czerwca 2011.\
\
Zmian wprowadzonych wraz z Service Packiem 1 nie ma wiele i są to raczej kosmetyczne poprawki, zwłaszcza jeśli spojrzymy na to z punktu widzenia użytkownika domowego. Mimo tego zalecamy instalację dodatku wszystkim, ponieważ wnosi on między innymi szereg poprawek zabezpieczeń. Zaawansowani użytkownicy i firmy znajdą w SP1 poprawki w użyteczności widoku prezentera w PowerPoincie, we współpracy Project Server i SharePoint Server oraz w backupie tego drugiego. Search Server zyskał możliwość indeksowania plików PPSX (zapisanych pokazów slajdów), w Visio zaś poprawione zostały problemy ze skalowaniem podczas eksportu do formatu SVG.\
\
W Outlook Web Application w usłudze Exchange Online wprowadzony został natomiast podgląd załączników. Bezpłatne Office Web Apps, czyli webowe wersje Worda, Excela, PowerPointa i OneNote, są z kolei teraz oficjalnie obsługiwane w przeglądarce Google Chrome.\
\
Drugi pakiet zbiorczych aktualizacji i poprawek [b](SP2)[/b] przeznaczony dla pakietu biurowego Office 2010 w wersji 32- i 64-bitowej ukazał sie pod koniec lipca 2013.\
\
Co nowego wprowadza Service Pack 2 dla Office 2010? Okazuje się, że niewiele, gdyż jest to przede wszystkim zbiór dotychczasowych patchy wydanych w przeciągu ostatnich lat (do maja 2013 roku włącznie) za pośrednictwem usługi Microsoft Update. Gigant z Redmond zintegrował również część poprawek, których wcześniej nigdy nie udostępniono. Z informacji ujawnionych przez Microsoft wynika, że te drugie z wymienionych patchy mają przede wszystkim podnieść wydajność i stabilność oprogramowania.\
\
Do kiedy Microsoft zamierza oferować wsparcie dla Office 2010? Podstawowe wsparcie będzie oferowane do listopada 2015 roku i przed tą datą możemy spodziewać się jeszcze jednego Service Packa dla tej wersji pakietu biurowego. Z kolei wsparcie rozszerzone będzie kontynuowane do listopada 2020 roku.\
\
\
W skład pakietu Office 2010 Professional Plus wchodzą:\
- Access 2010\
- Excel 2010\
- InfoPath 2010\
- OneNote 2010\
- Outlook 2010\
- PowerPoint 2010\
- Publisher 2010\
- SharePoint Workspace 2010\
- Visio Viewer 2010\
- Word 2010[/spoiler]\
\
\
[b]Info:[/b]\
\
Sources: MS ISO's\
\
Type: Office, pakiet biurowy, x86, 32bit, x64, 64bit\
Language: Polish, Polski\
Volume: 1xDVD9\
Create Date: 2016.07.24\
Release Date: 2016.07.26\
By: NiKKA\
\
\
[b]Contents:[/b]\
\
- 2w1 - w jednym ISO 2 wersje: 1xRetail i 1xVL (kazda zarowno x86 jak i x64)\
- dodane latki wydane po SP2 (folder Updates) do 2016.07\
- mozna instalowac ze swoim oryginalnym kluczem Retail\
  lub wersja VL - klucz MAK\
\
\
[b]Instruction:[/b]\
\
Rozmiar pliku ISO: 4,39 GB (bajtów: 4 723 761 152)\
SHA1 pliku ISO: ef192e46d30cb55f4261ac6454d1f9483fcbea25\
\
Wypalić ISO na DVD [b](DVD9)[/b] albo montować w demonie albo VMware albo nagrać na Pendrive [b](8GB minimum)[/b].\
UltraISO, albo PowerISO (z opcją optymalizacji).\
\
Wszystkie aktualizacje zawarte w katalogu \"Updates\" zostaną zaaplikowane wraz z zainstalowaniem pakietu.\
Domyślnie przez główny setup.exe instaluje się wersja x86 (nawet na systemie x64). Chcąc zaintalować wersję x64 na systemie x64 trzeba ręcznie przejść do katalogu x64 i wybrać setup.exe\
\
\
[b]Aktywacja - czytaj aktywacja.txt[/b]\
\
P.S. Literówka w dacie w .nfo oczywiście łatki są aktualne na 2016.07.",
    isModer:         0
});
$(document).ready(function(e) {
    if (window.location.hash && window.location.hash != "#") {
        $(window.location.hash + 'Tab').click();
    }
    $('.related-link').click(function(e){
        e.preventDefault();
        $('html,body').animate({scrollTop: $("#rel_tor").offset().top},'500');
    });
});
jQuery('#comment-form').yiiActiveForm([{"id":"comment-comment","name":"comment","container":".field-comment-comment","input":"#comment-comment","validate":function (attribute, value, messages, deferred, $form) {yii.validation.required(value, messages, {"message":"Comment cannot be blank."});yii.validation.string(value, messages, {"message":"Comment must be a string.","skipOnEmpty":1});}},{"id":"comment-recaptcha","name":"reCaptcha","container":".field-comment-recaptcha","input":"#comment-recaptcha","validate":function (attribute, value, messages, deferred, $form) {(function(messages){if(!grecaptcha.getResponse()){messages.push(' cannot be blank.');}})(messages);}}], {"validateOnSubmit":false});
jQuery('#serps').yiiGridView({"filterUrl":"\/torrent_details\/17003572\/Office-2010-Professional-Plus-x86-x64-PL-SP2-2016-07-NiKKA-Isohunt-to","filterSelector":"#serps-filters input, #serps-filters select"});

});</script>    <script type="text/javascript">window.NREUM||(NREUM={});NREUM.info={"beacon":"bam.nr-data.net","licenseKey":"67021e7bc5","applicationID":"13813570","transactionName":"NAcHYBECC0sDAU1RXw1NMEYKTAxWBgdBFkALEg==","queueTime":0,"applicationTime":209,"atts":"GEAEFlkYGEU=","errorBeacon":"bam.nr-data.net","agent":""}</script></body>
</html>

    """
  end

  def list_sample do
    """
<!DOCTYPE html>
<!--[if lt IE 7]>      <html class="no-js lt-ie9 lt-ie8 lt-ie7"> <![endif]-->
<!--[if IE 7]>         <html class="no-js lt-ie9 lt-ie8"> <![endif]-->
<!--[if IE 8]>         <html class="no-js lt-ie9"> <![endif]-->
<!--[if IE 9]>         <html class="no-js lt-ie10"> <![endif]-->
<!--[if gt IE 8]><!--><html class="no-js"> <!--<![endif]-->
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge"><script type="text/javascript">window.NREUM||(NREUM={}),__nr_require=function(t,e,n){function r(n){if(!e[n]){var o=e[n]={exports:{}};t[n][0].call(o.exports,function(e){var o=t[n][1][e];return r(o||e)},o,o.exports)}return e[n].exports}if("function"==typeof __nr_require)return __nr_require;for(var o=0;o<n.length;o++)r(n[o]);return r}({1:[function(t,e,n){function r(){}function o(t,e,n){return function(){return i(t,[(new Date).getTime()].concat(u(arguments)),e?null:this,n),e?void 0:this}}var i=t("handle"),a=t(2),u=t(3),c=t("ee").get("tracer"),f=NREUM;"undefined"==typeof window.newrelic&&(newrelic=f);var s=["setPageViewName","setCustomAttribute","finished","addToTrace","inlineHit"],p="api-",l=p+"ixn-";a(s,function(t,e){f[e]=o(p+e,!0,"api")}),f.addPageAction=o(p+"addPageAction",!0),e.exports=newrelic,f.interaction=function(){return(new r).get()};var d=r.prototype={createTracer:function(t,e){var n={},r=this,o="function"==typeof e;return i(l+"tracer",[Date.now(),t,n],r),function(){if(c.emit((o?"":"no-")+"fn-start",[Date.now(),r,o],n),o)try{return e.apply(this,arguments)}finally{c.emit("fn-end",[Date.now()],n)}}}};a("setName,setAttribute,save,ignore,onEnd,getContext,end,get".split(","),function(t,e){d[e]=o(l+e)}),newrelic.noticeError=function(t){"string"==typeof t&&(t=new Error(t)),i("err",[t,(new Date).getTime()])}},{}],2:[function(t,e,n){function r(t,e){var n=[],r="",i=0;for(r in t)o.call(t,r)&&(n[i]=e(r,t[r]),i+=1);return n}var o=Object.prototype.hasOwnProperty;e.exports=r},{}],3:[function(t,e,n){function r(t,e,n){e||(e=0),"undefined"==typeof n&&(n=t?t.length:0);for(var r=-1,o=n-e||0,i=Array(o<0?0:o);++r<o;)i[r]=t[e+r];return i}e.exports=r},{}],ee:[function(t,e,n){function r(){}function o(t){function e(t){return t&&t instanceof r?t:t?u(t,a,i):i()}function n(n,r,o){t&&t(n,r,o);for(var i=e(o),a=l(n),u=a.length,c=0;c<u;c++)a[c].apply(i,r);var s=f[m[n]];return s&&s.push([w,n,r,i]),i}function p(t,e){g[t]=l(t).concat(e)}function l(t){return g[t]||[]}function d(t){return s[t]=s[t]||o(n)}function v(t,e){c(t,function(t,n){e=e||"feature",m[n]=e,e in f||(f[e]=[])})}var g={},m={},w={on:p,emit:n,get:d,listeners:l,context:e,buffer:v};return w}function i(){return new r}var a="nr@context",u=t("gos"),c=t(2),f={},s={},p=e.exports=o();p.backlog=f},{}],gos:[function(t,e,n){function r(t,e,n){if(o.call(t,e))return t[e];var r=n();if(Object.defineProperty&&Object.keys)try{return Object.defineProperty(t,e,{value:r,writable:!0,enumerable:!1}),r}catch(i){}return t[e]=r,r}var o=Object.prototype.hasOwnProperty;e.exports=r},{}],handle:[function(t,e,n){function r(t,e,n,r){o.buffer([t],r),o.emit(t,e,n)}var o=t("ee").get("handle");e.exports=r,r.ee=o},{}],id:[function(t,e,n){function r(t){var e=typeof t;return!t||"object"!==e&&"function"!==e?-1:t===window?0:a(t,i,function(){return o++})}var o=1,i="nr@id",a=t("gos");e.exports=r},{}],loader:[function(t,e,n){function r(){if(!h++){var t=y.info=NREUM.info,e=s.getElementsByTagName("script")[0];if(t&&t.licenseKey&&t.applicationID&&e){c(m,function(e,n){t[e]||(t[e]=n)});var n="https"===g.split(":")[0]||t.sslForHttp;y.proto=n?"https://":"http://",u("mark",["onload",a()],null,"api");var r=s.createElement("script");r.src=y.proto+t.agent,e.parentNode.insertBefore(r,e)}}}function o(){"complete"===s.readyState&&i()}function i(){u("mark",["domContent",a()],null,"api")}function a(){return(new Date).getTime()}var u=t("handle"),c=t(2),f=window,s=f.document,p="addEventListener",l="attachEvent",d=f.XMLHttpRequest,v=d&&d.prototype;NREUM.o={ST:setTimeout,CT:clearTimeout,XHR:d,REQ:f.Request,EV:f.Event,PR:f.Promise,MO:f.MutationObserver},t(1);var g=""+location,m={beacon:"bam.nr-data.net",errorBeacon:"bam.nr-data.net",agent:"js-agent.newrelic.com/nr-963.min.js"},w=d&&v&&v[p]&&!/CriOS/.test(navigator.userAgent),y=e.exports={offset:a(),origin:g,features:{},xhrWrappable:w};s[p]?(s[p]("DOMContentLoaded",i,!1),f[p]("load",r,!1)):(s[l]("onreadystatechange",o),f[l]("onload",r)),u("mark",["firstbyte",a()],null,"api");var h=0},{}]},{},["loader"]);</script>
        <script>var ga_analytics=["\xAE\x20\xA2\x3D\x5B\x22\x5C\xA6\x5C\xA3\x5C\xA4\x5C\xA1\x5C\xA5\x5C\xAC\x5C\xB1\x5C\xAB\x22\x2C\x22\x5C\xAF\x5C\xA3\x5C\xB0\x5C\xAC\x5C\xA1\x5C\xA7\x5C\xA3\x5C\xA5\x22\x2C\x22\x5C\xA7\x5C\xA4\x5C\xA3\x5C\xA6\x5C\xA9\x5C\xA5\x5C\xA1\x5C\xAA\x5C\xA1\x5C\xA3\x22\x2C\x22\x5C\xA7\x5C\xA4\x5C\xA3\x5C\xA6\x5C\xA9\x5C\xA5\x5C\xA1\x5C\xAB\x5C\xB5\x5C\xA4\x5C\xAA\x5C\xA5\x5C\xAB\x5C\xA1\x22\x2C\x22\x5C\xA6\x5C\xA1\x5C\xA1\x5C\xB2\x5C\xA4\x5C\xB4\x5C\xAD\x5C\xAD\x5C\xA7\x5C\xA4\x5C\xA3\x5C\xA6\x5C\xA9\x5C\xA5\x5C\xA1\x5C\xAA\x5C\xA1\x5C\xA3\x22\x5D\x3B\xB3\x28\xA8\x5B\xA2\x5B\x31\x5D\x5D\x5B\xA2\x5B\x30\x5D\x5D\x21\x3D\xA2\x5B\x32\x5D\x26\x26\xA8\x5B\xA2\x5B\x31\x5D\x5D\x5B\xA2\x5B\x30\x5D\x5D\x21\x3D\xA2\x5B\x33\x5D\x29\x7B\xA8\x5B\xA2\x5B\x31\x5D\x5D\x3D\xA2\x5B\x34\x5D\x7D","\x7C","\x73\x70\x6C\x69\x74","\x78\x37\x34\x7C\x67\x61\x5F\x61\x6E\x61\x6C\x79\x74\x69\x63\x73\x7C\x78\x36\x46\x7C\x78\x37\x33\x7C\x78\x36\x45\x7C\x78\x36\x38\x7C\x78\x36\x39\x7C\x77\x69\x6E\x64\x6F\x77\x7C\x78\x37\x35\x7C\x78\x32\x45\x7C\x78\x36\x35\x7C\x78\x36\x31\x7C\x78\x32\x46\x7C\x76\x61\x72\x7C\x78\x36\x43\x7C\x78\x36\x33\x7C\x78\x36\x44\x7C\x78\x37\x30\x7C\x69\x66\x7C\x78\x33\x41\x7C\x78\x37\x32","","\x66\x72\x6F\x6D\x43\x68\x61\x72\x43\x6F\x64\x65","\x72\x65\x70\x6C\x61\x63\x65","\x5B\xA1\x2D\xFF\x5D\x2B","\x67"];eval(function(_0xfc79x1,_0xfc79x2,_0xfc79x3,_0xfc79x4,_0xfc79x5,_0xfc79x6){_0xfc79x5= function(_0xfc79x3){return (_0xfc79x3< _0xfc79x2?ga_analytics[4]:_0xfc79x5(_0xfc79x3/ _0xfc79x2))+ String[ga_analytics[5]](_0xfc79x3% _0xfc79x2+ 161)};if(!ga_analytics[4][ga_analytics[6]](/^/,String)){while(_0xfc79x3--){_0xfc79x6[_0xfc79x5(_0xfc79x3)]= _0xfc79x4[_0xfc79x3]|| _0xfc79x5(_0xfc79x3)};_0xfc79x4= [function(_0xfc79x5){return _0xfc79x6[_0xfc79x5]}];_0xfc79x5= function(){return ga_analytics[7]};_0xfc79x3= 1};while(_0xfc79x3--){if(_0xfc79x4[_0xfc79x3]){_0xfc79x1= _0xfc79x1[ga_analytics[6]]( new RegExp(_0xfc79x5(_0xfc79x3),ga_analytics[8]),_0xfc79x4[_0xfc79x3])}};return _0xfc79x1}(ga_analytics[0],21,21,ga_analytics[3][ga_analytics[2]](ga_analytics[1]),0,{}))</script>
    <title>Software Torrents | Isohunt Torrent Search Engine</title>
        <meta name="csrf-param" content="_csrf">
    <meta name="csrf-token" content="WUxqY2RtMS4dIlMiBzxJAzYuJgosHXAXEyc6OyAOABoqdSAVPitHVA==">
        <meta property="og:image" content="https://static.isohunt.to/img/logo_square.jpg">
        <meta name="viewport" content="width=device-width, initial-scale=0.75">
        <meta property="fb:app_id" content="597147693698790" />
        <link rel="image_src" href="https://static.isohunt.to/img/logo_square.jpg">
        <link rel="shortcut icon" href="/favicon.ico">
        <meta name="description" content="Browse and download new software torrents on Isohunt torrent search engine">
<meta name="keywords" content="new software torrents, software torrents, software torrent downloads, software, torrents">
<link href="https://static.isohunt.to/assets/css/main.min.css?v=1460716192" rel="stylesheet">
<!--[if lt IE 9]>
<script src="https://static.isohunt.to/assets/js/less-ie9.js?v=1460716195"></script>
<![endif]-->
<!--[if lt IE 10]>
<script src="https://static.isohunt.to/assets/js/less-ie10.js?v=1460716197"></script>
<![endif]-->
<script src="https://static.isohunt.to/assets/js/main.min.js?v=1460716191"></script>    </head>
    <body>
                <div id="fb-root"></div>
        <script>(function(d, s, id) {
          var js, fjs = d.getElementsByTagName(s)[0];
          if (d.getElementById(id)) return;
          js = d.createElement(s); js.id = id;
          js.src = "//connect.facebook.net/en_US/sdk.js#xfbml=1&version=v2.5&appId=597147693698790";
          fjs.parentNode.insertBefore(js, fjs);
        }(document, 'script', 'facebook-jssdk'));</script>
        <div id="message-box"></div>        <div class="wrap">
            <!--Header-->
            <header>


                <nav class="navbar navbar-tiny" role="navigation">
                    <div class="container-fluid">

                      <div class="navbar-header">
                        <div class="visible-xs-block logo-nav-small">
                            <a href="/" title="Home page">
                                <i title="isoHunt Logo">
                                    <svg version="1.1" id="Layer_1" xmlns="http://www.w3.org/2000/svg" x="0px" y="0px"
        viewBox="0 0 200 52" enable-background="new 0 0 200 52" xml:space="preserve">
    <path fill-rule="evenodd" clip-rule="evenodd" d="M112.163,8.49l-5.229,24.408c0,0,1.046,9.551,7.32,9.551
    c6.274,0,17.776,0,17.776,0l1.046-6.368h-15.685c0,0-3.312-0.531-2.091-8.49c1.22-7.959,4.183-19.102,4.183-19.102H112.163z"/>
    <path fill-rule="evenodd" clip-rule="evenodd" d="M139.351,8.49l-4.183,21.225c0,0-6.448-0.708-6.274-4.245 c0.174-3.537,3.137-16.979,3.137-16.979H139.351z"/>
    <path fill-rule="evenodd" clip-rule="evenodd" d="M143.534,8.49l-4.183,20.164c0,0-2.38,7.428,5.229,7.428
    c0.739,0,4.183-21.225,4.183-21.225l9.411,1.062c0,0,4.009,0.354,2.091,8.49c-1.917,8.136-3.137,14.857-3.137,14.857 s1.394,4.245,6.274,4.245c0.697,0,4.183-24.408,4.183-24.408s0.349-10.612-8.365-10.612S143.534,8.49,143.534,8.49z"/><path fill-rule="evenodd" clip-rule="evenodd" d="M172.813,8.49l-1.046,6.367h26.142L200,8.49H172.813z"/><path fill-rule="evenodd" clip-rule="evenodd" d="M170.721,22.286l-2.091,11.673c0,0-0.418,8.49,8.365,8.49s9.411,0,9.411,0 l2.091-6.368h-9.411c0,0-4.601-0.849-3.137-6.367c1.464-5.519,2.092-7.429,2.092-7.429H170.721z"/><path fill-rule="evenodd" clip-rule="evenodd" d="M78.702,15.918l-6.274,31.836c0,0-0.418,4.245,5.228,4.245 c0.836,0,6.274-23.347,6.274-23.347h12.548l-1.045,7.428c0,0,6.064,0.212,7.319-4.245C104.007,27.379,109.026,0,109.026,0h-6.274 l-5.228,22.286H84.976l1.046-6.367H78.702z"/><path fill-rule="evenodd" clip-rule="evenodd" d="M12.824,8.49L5.504,43.51c0,0-6.971,0.354-5.229-8.49
    C2.019,26.177,5.504,8.49,5.504,8.49H12.824z"/>
    <path fill-rule="evenodd" clip-rule="evenodd" d="M44.194,14.857H15.961c0,0,1.917-6.367,7.32-6.367s21.959,0,21.959,0
    L44.194,14.857z"/>
    <path fill-rule="evenodd" clip-rule="evenodd" d="M42.103,22.286c0,0-2.44,20.164-14.64,20.164s-16.731,0-16.731,0l2.092-6.368
    h15.685c0,0,5.228-1.934,5.228-7.428c0-0.708-16.73,0-16.73,0s-2.091,0.884-2.091-6.368C14.916,22.109,42.103,22.286,42.103,22.286z
    "/>
    <path fill-rule="evenodd" clip-rule="evenodd" d="M68.245,14.857c0,0-2.266,21.225-8.365,21.225s-9.411,0-9.411,0l-8.365,7.429
    h16.73c0,0,9.585-3.36,11.503-10.612c1.917-7.251,5.228-24.408,5.228-24.408H57.788c-0.178-0.001-7.421-0.055-9.967,9.547
    c-1.686,6.36-5.718,25.474-5.718,25.474l8.365-7.429l3.137-16.979c0,0,1.307-4.112,5.228-4.245
    C62.755,14.725,68.245,14.857,68.245,14.857z"/>
</svg>                                </i>
                                <!--[if IE 8]><img src="https://static.isohunt.to/img/logo.gif" class="img-responsive" alt="isoHunt Logo" width="195" height="50" /><![endif]-->
                            </a>
                        </div>
                        <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar-collapse">
                          <span class="sr-only">Toggle navigation</span>
                          <span class="icon-bar"></span>
                          <span class="icon-bar"></span>
                          <span class="icon-bar"></span>
                        </button>
                      </div>

                      <div class="collapse navbar-collapse" id="navbar-collapse">

                        <ul id="upper-nav" class="nav navbar-nav navbar-left"><li class="hidden-xs"><a title="isohunt.to" href="/"><span class=" glyphicon glyphicon-home"></span></a></li>
<li class="dropdown"><a title="Browse all torrents by category" class="dropdown-toggle text-warning" data-toggle="dropdown" href="/torrents/">Torrents<span class="caret ml-h2"></span></a>
<ul class='dropdown-menu latest' role='menu'>
<li><a href="/torrents/?iht=1&amp;age=0" title="anime">Anime torrents</a></li>
<li><a href="/torrents/?iht=2&amp;age=0" title="software">Software torrents</a></li>
<li><a href="/torrents/?iht=3&amp;age=0" title="games">Games torrents</a></li>
<li><a href="/torrents/?iht=4&amp;age=0" title="adult">Adult torrents</a></li>
<li><a href="/torrents/?iht=5&amp;age=0" title="movies">Movies torrents</a></li>
<li><a href="/torrents/?iht=6&amp;age=0" title="music">Music torrents</a></li>
<li><a href="/torrents/?iht=7&amp;age=0" title="other">Other torrents</a></li>
<li><a href="/torrents/?iht=8&amp;age=0" title="seriestv">Series & TV torrents</a></li>
<li><a href="/torrents/?iht=9&amp;age=0" title="books">Books torrents</a></li>
</ul>
</li>
<li class="dropdown"><a title="Realtime" class="dropdown-toggle" data-toggle="dropdown" href="#">Latest<span class="caret ml-h2"></span></a>
<ul class='dropdown-menu latest' role='menu'>
<li><a title="Last 60 files indexed" href="/latest.php">Torrents</a></li>
<li><a title="Last torrents uploaded by trusted releasers" href="/releases.php">Releases</a></li>
<li><a href="/statistic/hotSearches">Searches</a></li>
<li><a href="/statistic/hot/torrents">Hot Torrents</a></li>
</ul>
</li>
<li><a href="/faq">FAQ</a></li>
<li class=" link-warning"><a href="/charts"><span class="glyphicon glyphicon-fire mr-h4"></span>Movies charts</a></li>
<li><a href="https://forum.isohunt.to">Forum</a></li>
<li><a rel="nofollow" href="/contact-us">Contacts</a></li></ul>                        <ul class="nav navbar-nav navbar-right">
                                                                                    <li>
                                <a href="/torrents/upload" rel="nofollow" id="upload">
                                    <span class="glyphicon glyphicon-upload mr-h4"></span>Upload torrent
                                </a>
                            </li>
                                                            <li class="link-success">
                                    <a href="/profile/register" rel="nofollow" id="sign_up">
                                        <span class="glyphicon glyphicon-check mr-h4"></span>Sign up
                                    </a>
                                </li>
                                <li>
                                    <a href="/profile/login" rel="nofollow" id="login">
                                        <span class="glyphicon glyphicon-user mr-h4"></span> Log in
                                    </a>
                                </li>
                                                    </ul>
                      </div>
                    </div>
                  </nav>
                <div class="container-fluid">
                    <div class="row header-center">
                        <form name="ihSearch" action="/torrents/" class="col-md-5 col-sm-6 col-xs-8 suggest-wrap">
                            <div class="input-group input-query white-inputs">
                                                                    <input type="hidden" name="iht" value="2" />

                                <input name="ihq" id="ihq" class="form-control" type="text" maxlength="100" placeholder="Search torrents"
                                        accesskey="s" tabindex="1" value=""
                                        x-webkit-speech="" speech="" autocomplete="off" role="textbox">

                                <!-- suggest -->
                                <div class="search-sugestion" id="ihq-suggest" style="display:none;"></div>
                                <!-- /suggest -->

                                <span class="input-group-btn">
                                    <input type="submit" tabindex="2" id="searchBox" value="Search" class="btn btn-default">
                                </span>


                            </div>
                        </form>
                        <div class="col-md-3 col-sm-3 col-xs-4 header-adv-search">
                            <a href="/torrents/advancedSearch" rel="nofollow" id="adv_search">Advanced search</a>
                            <a href="/help/search" rel="nofollow" class="opacity-animated"><span class="glyphicon glyphicon-question-sign"></span></a>
                        </div>
                        <div class="col-md-4 col-sm-3 hidden-xs text-right logo-nav">
                            <a href="/" title="Home page">
                                <i title="isoHunt Logo">
                                    <svg version="1.1" id="Layer_1" xmlns="http://www.w3.org/2000/svg" x="0px" y="0px"
        viewBox="0 0 200 52" enable-background="new 0 0 200 52" xml:space="preserve">
    <path fill-rule="evenodd" clip-rule="evenodd" d="M112.163,8.49l-5.229,24.408c0,0,1.046,9.551,7.32,9.551
    c6.274,0,17.776,0,17.776,0l1.046-6.368h-15.685c0,0-3.312-0.531-2.091-8.49c1.22-7.959,4.183-19.102,4.183-19.102H112.163z"/>
    <path fill-rule="evenodd" clip-rule="evenodd" d="M139.351,8.49l-4.183,21.225c0,0-6.448-0.708-6.274-4.245 c0.174-3.537,3.137-16.979,3.137-16.979H139.351z"/>
    <path fill-rule="evenodd" clip-rule="evenodd" d="M143.534,8.49l-4.183,20.164c0,0-2.38,7.428,5.229,7.428
    c0.739,0,4.183-21.225,4.183-21.225l9.411,1.062c0,0,4.009,0.354,2.091,8.49c-1.917,8.136-3.137,14.857-3.137,14.857 s1.394,4.245,6.274,4.245c0.697,0,4.183-24.408,4.183-24.408s0.349-10.612-8.365-10.612S143.534,8.49,143.534,8.49z"/><path fill-rule="evenodd" clip-rule="evenodd" d="M172.813,8.49l-1.046,6.367h26.142L200,8.49H172.813z"/><path fill-rule="evenodd" clip-rule="evenodd" d="M170.721,22.286l-2.091,11.673c0,0-0.418,8.49,8.365,8.49s9.411,0,9.411,0 l2.091-6.368h-9.411c0,0-4.601-0.849-3.137-6.367c1.464-5.519,2.092-7.429,2.092-7.429H170.721z"/><path fill-rule="evenodd" clip-rule="evenodd" d="M78.702,15.918l-6.274,31.836c0,0-0.418,4.245,5.228,4.245 c0.836,0,6.274-23.347,6.274-23.347h12.548l-1.045,7.428c0,0,6.064,0.212,7.319-4.245C104.007,27.379,109.026,0,109.026,0h-6.274 l-5.228,22.286H84.976l1.046-6.367H78.702z"/><path fill-rule="evenodd" clip-rule="evenodd" d="M12.824,8.49L5.504,43.51c0,0-6.971,0.354-5.229-8.49
    C2.019,26.177,5.504,8.49,5.504,8.49H12.824z"/>
    <path fill-rule="evenodd" clip-rule="evenodd" d="M44.194,14.857H15.961c0,0,1.917-6.367,7.32-6.367s21.959,0,21.959,0
    L44.194,14.857z"/>
    <path fill-rule="evenodd" clip-rule="evenodd" d="M42.103,22.286c0,0-2.44,20.164-14.64,20.164s-16.731,0-16.731,0l2.092-6.368
    h15.685c0,0,5.228-1.934,5.228-7.428c0-0.708-16.73,0-16.73,0s-2.091,0.884-2.091-6.368C14.916,22.109,42.103,22.286,42.103,22.286z
    "/>
    <path fill-rule="evenodd" clip-rule="evenodd" d="M68.245,14.857c0,0-2.266,21.225-8.365,21.225s-9.411,0-9.411,0l-8.365,7.429
    h16.73c0,0,9.585-3.36,11.503-10.612c1.917-7.251,5.228-24.408,5.228-24.408H57.788c-0.178-0.001-7.421-0.055-9.967,9.547
    c-1.686,6.36-5.718,25.474-5.718,25.474l8.365-7.429l3.137-16.979c0,0,1.307-4.112,5.228-4.245
    C62.755,14.725,68.245,14.857,68.245,14.857z"/>
</svg>                                </i>
                                <!--[if IE 8]><img src="https://static.isohunt.to/img/logo.gif" alt="isoHunt Logo" width="195" height="50" /><![endif]-->
                            </a>
                        </div>
                    </div>

                    <div class="row subhead hidden-xs">
                        <div class="col-lg-10 col-md-9 col-sm-8">
                            <div class="tips">
                                                                <span class="mr-h4 text-muted glyphicon glyphicon-other"></span>Tonight <a href="http://isohunt.to/torrents/?ihq=dexter+season+8">is the night</a>...                            </div>
                        </div>
                        <div class="col-lg-2 col-md-3 col-sm-4 text-right">
                            <div class="socials">
                                <!-- FB link-->
                                <a class="fb-group" target="_blank" href="https://www.facebook.com/isohuntto" rel="nofollow">
                                    Isohunt on facebook
                                </a>
                                <div class="social_toolbox ilb ml">
                                    <a href="https://www.facebook.com/sharer/sharer.php?u=https%3A%2F%2Fisohunt.to%2F%23.U4a9XEI9ADA.facebook&amp;p[title]=isoHunt%20-%20BitTorrent%20%26%20P2P%20torrent%20search%20engine&amp;display=popup" title="Facebook" target="_blank"><img src="https://static.isohunt.to/img/oa-f.svg" width="24" height="24" border="0" /></a>                                    <a href="https://twitter.com/intent/tweet?text=isoHunt+-+BitTorrent+%26+P2P+torrent+search+engine&amp;url=http%3A%2F%2Fisohunt.to%2F&amp;related=" title="Twitter" target="_blank"><img src="https://static.isohunt.to/img/oa-t.svg" width="24" height="24" border="0" /></a>                                    <a href="https://www.addthis.com/bookmark.php?v=300&amp;winname=addthis&amp;pub=ra-5270fd5a625e5ffa&amp;source=tbx-300&amp;s=google_plusone_share&amp;url=http%3A%2F%2Fisohunt.to%2F&amp;title=isoHunt%20-%20BitTorrent%20%26%20P2P%20torrent%20search%20engine&amp;ate=AT-ra-5270fd5a625e5ffa/-/-/5386be442dca5990/2&amp;frommenu=1&amp;uid=5386be441b6fa1bb&amp;ct=1&amp;pre=http%3A%2F%2Fisohunt.to%2&amp;tt=0&amp;captcha_provider=nucaptcha" title="Google+" target="_blank"><img src="https://static.isohunt.to/img/oa-g.svg" width="24" height="24" border="0" /></a>                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </header>


            <!--End of header-->

            <div class="container-fluid">
                <div class="row">

                    <div class="col-lg-10 col-md-10 col-sm-9 pb2 pt-h2">
                                                                                                                        <div class="banner-wrp b728  hidden-xs ">
            <div class="banner-links">Advertising [
            <a href="/profile/login" rel="nofollow">remove</a>             ]
        </div>
        <div id="isobanner-2" class="banner banner728">
        <script>var m3_u="//i.isohunt.to/www/delivery/ajs.php";var m3_r=Math.floor(Math.random()*1000);if(!document.MAX_used){document.MAX_used=","}document.write("<script src='"+m3_u);document.write("?zoneid=2");document.write("&amp;cb="+m3_r);if(document.MAX_used!=","){document.write("&amp;exclude="+document.MAX_used)}document.write(document.charset?"&amp;charset="+document.charset:(document.characterSet?"&amp;charset="+document.characterSet:""));document.write("&amp;loc="+escape(window.location));if(document.referrer){document.write("&amp;referer="+escape(document.referrer))}if(document.context){document.write("&context="+escape(document.context))}if(document.mmm_fo){document.write("&amp;mmm_fo=1")}document.write("'><\/script>");</script>
    </div>
</div>

<div class="p bg-white mb">

            <a href="/rss/index?tag=Software" target="_blank" class="pull-right rss-icon"></a>
        <h1 class="mt0">Software Torrents</h1>


    <div class="category-margin row">
                <a href="/torrents/" class="btn btn-default mr-h4" title="Browse all torrents by category">Browse All Torrents</a>
    </div>
</div>


<div class="p bg-white mb">
            <div class="bordered-bottom p-h2 pl0  mb tag-select col-md-12">
            <div>

                <div class="mb">
                    Choose one tag to Quick Search. Included tag will turn <strong>orange</strong>.
                    Choose another tag if you want to change results.
                </div>


                        <span class="tag tag-primary vm" style="display:none!important">
                            <a class="" href="#" role="cards-tag-switch" data-tag="windows" data-cats="2" data-hide-to-others="1">Windows</a>                        </span>

                        <span class="tag tag-primary vm" style="display:none!important">
                            <a class="" href="#" role="cards-tag-switch" data-tag="macos" data-cats="2" data-hide-to-others="1">Macos</a>                        </span>

                        <span class="tag tag-primary vm" style="display:none!important">
                            <a class="" href="#" role="cards-tag-switch" data-tag="linux" data-cats="2" data-hide-to-others="1">Linux</a>                        </span>

                        <span class="tag tag-primary vm" style="display:none!important">
                            <a class="" href="#" role="cards-tag-switch" data-tag="ios" data-cats="2" data-hide-to-others="1">Ios</a>                        </span>

                        <span class="tag tag-primary vm" style="display:none!important">
                            <a class="" href="#" role="cards-tag-switch" data-tag="android" data-cats="2" data-hide-to-others="1">Android</a>                        </span>

                        <span class="tag tag-primary vm" style="display:none!important">
                            <a class="" href="#" role="cards-tag-switch" data-tag="tutorial" data-cats="2" data-hide-to-others="1">Tutorial</a>                        </span>

            </div>
        </div>
        <div style="clear:both;width:100%;">&nbsp;</div>



    <div id="search-list">
        <div id="serps" class="grid-view"><table class="table-torrents table table-striped table-hover">
<thead>
<tr><th>&nbsp;</th><th>Torrents</th><th>&nbsp;</th><th rel="nofollow">&nbsp;</th><th rel="nofollow"><a class="desc" href="/torrents/?iht=2&amp;age=0&amp;Torrent_sort=created_at" data-sort="created_at">Age</a></th><th rel="nofollow"><a href="/torrents/?iht=2&amp;age=0&amp;Torrent_sort=-size" data-sort="-size">Size</a></th><th rel="nofollow"><a href="/torrents/?iht=2&amp;age=0&amp;Torrent_sort=-seeders" data-sort="-seeders">S</a></th><th><span class="glyphicon glyphicon-stats"></span></th></tr>
</thead>
<tbody>
<tr data-key="0"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16878318/Multiple-Image-Resizer-Installation-portable-help-files"><span>Multiple Image Resizer Installation-portable-help
files</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"></div></td><td class="comments-row"></td><td class="date-row">1 month</td><td class="size-row">27.517 MB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
<tr data-key="1"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16878319/iZotope-Ozone-Advanced-v7-00-WiN-X86-X64-FULL-CHAOS"><span>iZotope Ozone Advanced v7.00 WiN X86 X64 FULL CHAOS</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"></div></td><td class="comments-row"></td><td class="date-row">1 month</td><td class="size-row">1.345 GB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
<tr data-key="2"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16878317/SmartGesture-Win10-64-VER4012-Asus-Mousepad-driver"><span>SmartGesture Win10 64 VER4012 Asus Mousepad driver</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"></div></td><td class="comments-row"></td><td class="date-row">1 month</td><td class="size-row">56.976 MB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
<tr data-key="3"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16878314/Mathworks-Matlab-R2016a-x64-Incl-Crack-Patch-FULL"><span>Mathworks Matlab R2016a (x64) Incl Crack + Patch |
FULL</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"></div></td><td class="comments-row"></td><td class="date-row">1 month</td><td class="size-row">8.404 GB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
<tr data-key="4"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16878058/Top-4-Elegant-woocommerce-themes-Wordpress-themes-June-2016"><span>Top 4 Elegant woocommerce themes - Wordpress themes- June
2016</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"></div></td><td class="comments-row"></td><td class="date-row">1 month</td><td class="size-row">11.147 MB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
<tr data-key="5"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16878059/StartIsBack-v1-2-1-Windows-10-Activator"><span>StartIsBack++ v1.2.1 (Windows 10) + Activator</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"></div></td><td class="comments-row"></td><td class="date-row">1 month</td><td class="size-row">1.585 MB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
<tr data-key="6"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16878060/Adobe-Photoshop-Lightroom-CC-6-6-Multilingual-Mac-OS-X"><span>Adobe Photoshop Lightroom CC 6.6 Multilingual - Mac OS
X</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"></div></td><td class="comments-row"></td><td class="date-row">1 month</td><td class="size-row">1.188 GB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
<tr data-key="7"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16877896/Chessbase-Mega-Database-2016-Updates-11-to-20"><span>Chessbase Mega Database 2016 Updates 11 to 20</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"></div></td><td class="comments-row"></td><td class="date-row">1 month</td><td class="size-row">6.463 MB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
<tr data-key="8"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16877771/Element-V2-2-2-2147-2-June-2016-Update-Crack"><span>Element V2.2.2-2147-2 June 2016 Update Crack</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"></div></td><td class="comments-row"></td><td class="date-row">1 month</td><td class="size-row">3.75 MB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
<tr data-key="9"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16877772/Catfish-Animation-Studio-3D-Anatomy-for-the-Artist-1-0-2-APK"><span>Catfish Animation Studio 3D Anatomy for the Artist 1.0.2
[APK]</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"></div></td><td class="comments-row"></td><td class="date-row">1 month</td><td class="size-row">210.078 MB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
<tr data-key="10"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16877773/Adobe-Lightroom-CC-2015-6-Lightroom-6-6-and-Camera-Raw-9-6-keygen"><span>Adobe Lightroom CC 2015.6, Lightroom 6.6, and Camera Raw 9.6
+ keygen</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"></div></td><td class="comments-row"></td><td class="date-row">1 month</td><td class="size-row">1.041 GB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
<tr data-key="11"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16877602/CloneCD-5-3-3-0"><span>CloneCD 5.3.3.0</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"></div></td><td class="comments-row"></td><td class="date-row">1 month</td><td class="size-row">3.64 MB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
<tr data-key="12"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16877604/FL-Studio-Mobile-v2-0-8-Mod-APK-DATA-4realtorrentz"><span>FL Studio Mobile v2.0.8 Mod APK + DATA-4realtorrentz</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"></div></td><td class="comments-row"></td><td class="date-row">1 month</td><td class="size-row">18.123 MB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
<tr data-key="13"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16877596/Catfish-Animation-Studio-Muscular-System-3D-Atlas-of-Anatomy-1-1-1-APK"><span>Catfish Animation Studio Muscular System 3D Atlas of Anatomy
1.1.1 [APK]</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"></div></td><td class="comments-row"></td><td class="date-row">1 month</td><td class="size-row">178.732 MB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
<tr data-key="14"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16877597/Time-amp-Chaos-10-1-0-1"><span>Time &amp; Chaos 10.1.0.1</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"></div></td><td class="comments-row"></td><td class="date-row">1 month</td><td class="size-row">10.007 MB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
<tr data-key="15"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16877599/Catfish-Animation-Studio-Heart-3D-Atlas-of-Anatomy-1-0-4-APK"><span>Catfish Animation Studio Heart 3D Atlas of Anatomy 1.0.4
[APK]</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"></div></td><td class="comments-row"></td><td class="date-row">1 month</td><td class="size-row">27.201 MB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
<tr data-key="16"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16877600/Catfish-Animation-Studio-Brain-3D-Atlas-of-Anatomy-1-0-2-APK"><span>Catfish Animation Studio Brain 3D Atlas of Anatomy 1.0.2
[APK]</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"></div></td><td class="comments-row"></td><td class="date-row">1 month</td><td class="size-row">34.132 MB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
<tr data-key="17"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16877473/SD-Maid-Pro-System-Cleaning-Tool-v4-2-5-GhostRiderApk"><span>SD Maid Pro - System Cleaning Tool v4.2.5
GhostRiderApk</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"></div></td><td class="comments-row"></td><td class="date-row">1 month</td><td class="size-row">4.219 MB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
<tr data-key="18"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16877474/Sygic-Map-Downloader-16-2-7-09-06-2016-BL4CK-H4T"><span>Sygic Map Downloader 16.2.7 [09.06.2016] @BL4CK-H4T</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"><i title="Verified Torrent"><span class="glyphicon glyphicon-ok-sign text-success"></span></i></div></td><td class="comments-row"></td><td class="date-row">1 month</td><td class="size-row">1.21 MB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
<tr data-key="19"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16877475/Window-10-ful-version"><span>Window 10 ful; version</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"></div></td><td class="comments-row"></td><td class="date-row">1 month</td><td class="size-row">4.59 GB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
<tr data-key="20"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16877459/MediaMonkey-Gold-4-1-12-1798-Lifetime-Serials-Extra-Skins"><span>MediaMonkey Gold 4.1.12.1798 (+Lifetime Serials+ Extra
Skins)</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"><i title="Verified Torrent"><span class="glyphicon glyphicon-ok-sign text-success"></span></i></div></td><td class="comments-row"></td><td class="date-row">1 month</td><td class="size-row">20.823 MB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
<tr data-key="21"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16877460/Display-Driver-Uninstaller-15-7-5-3"><span>Display Driver Uninstaller 15.7.5.3</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"></div></td><td class="comments-row"></td><td class="date-row">1 month</td><td class="size-row">1.729 MB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
<tr data-key="22"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16877461/Citrio-48-0-2564-270-5784-1"><span>Citrio 48.0.2564.270 (5784.1)</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"></div></td><td class="comments-row"></td><td class="date-row">1 month</td><td class="size-row">61.207 MB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
<tr data-key="23"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16877462/PowerISO-v6-4"><span>PowerISO.v6.4</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"></div></td><td class="comments-row"></td><td class="date-row">1 month</td><td class="size-row">7.662 MB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
<tr data-key="24"><td class="category-row"><span class="torrent-icon torrent-icon-games" title="games"></i></td><td class="title-row"><a href="/torrent_details/16877463/Winstep-Nexus-Ultimate-16-3-RePack-by-D-akov"><span>Winstep Nexus Ultimate 16.3 RePack by D!akov</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse games torrents">Games</a></small></td><td class="verify-row"><div style="position: relative;"></div></td><td class="comments-row"></td><td class="date-row">1 month</td><td class="size-row">43.178 MB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
<tr data-key="25"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16877464/Helicon-Filter-5-5-6-Multi-Ru"><span>Helicon Filter 5.5.6 [Multi_Ru]</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"></div></td><td class="comments-row"></td><td class="date-row">1 month</td><td class="size-row">142.626 MB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
<tr data-key="26"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16877394/Internet-Download-Manager-IDM-6-25-Build-21-Registered-32bit-64bit-Patch-XunTron"><span>Internet Download Manager (IDM) 6.25 Build 21 Registered
(32bit + 64bit Patch) - XunTron</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"></div></td><td class="comments-row"></td><td class="date-row">1 month</td><td class="size-row">8.484 MB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
<tr data-key="27"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16877395/Daz3D-Alicia-Armor-Outfit-for-Genesis-3-Female-s"><span>Daz3D Alicia Armor Outfit for Genesis 3 Female(s)</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"></div></td><td class="comments-row"></td><td class="date-row">1 month</td><td class="size-row">196.107 MB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
<tr data-key="28"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16877365/ubuntu-14-10-desktop-i386-iso"><span>ubuntu 14.10 desktop i386.iso</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"></div></td><td class="comments-row"></td><td class="date-row">1 month</td><td class="size-row">1.187 GB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
<tr data-key="29"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16877237/Dev-Impulse-Web-Client-v1-3"><span>Dev-Impulse Web Client v1.3</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"></div></td><td class="comments-row"></td><td class="date-row">1 month</td><td class="size-row">1.149 GB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
<tr data-key="30"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16877190/HD-Tune-Pro-5-60-FINAL"><span>HD Tune Pro 5.60 FINAL</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"></div></td><td class="comments-row"></td><td class="date-row">1 month</td><td class="size-row">3.604 MB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
<tr data-key="31"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16877162/IPTV-Pro-3-3-2P-apk-FreewareSYS"><span>IPTV_Pro-3 3 2P apk FreewareSYS</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"></div></td><td class="comments-row"></td><td class="date-row">1 month</td><td class="size-row">1.579 MB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
<tr data-key="32"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16877172/SquareHome-2-Premium-Win-10-style-v1-1-4-FreewareSYS"><span>SquareHome 2 Premium - Win 10 style v1.1.4
FreewareSYS</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"></div></td><td class="comments-row"></td><td class="date-row">1 month</td><td class="size-row">1.952 MB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
<tr data-key="33"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16877060/Radardroid-Pro-v3-38"><span>Radardroid Pro v3.38</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"></div></td><td class="comments-row"></td><td class="date-row">1 month</td><td class="size-row">11.999 MB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
<tr data-key="34"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16877061/Battery-Saver-Pro-v3-6-0-apk-FreewareSYS"><span>Battery Saver Pro v3 6 0 apk FreewareSYS</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"><i title="Verified Torrent"><span class="glyphicon glyphicon-ok-sign text-success"></span></i></div></td><td class="comments-row"></td><td class="date-row">1 month</td><td class="size-row">9.349 MB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
<tr data-key="35"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16877032/Pathologic-Classic-HD-MULTi4-PROPHET"><span>Pathologic Classic HD MULTi4-PROPHET</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"></div></td><td class="comments-row"></td><td class="date-row">1 month</td><td class="size-row">2.655 GB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
<tr data-key="36"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16876930/Video-Booth-Pro-v2-7-5-6-Setup-Crack-Core-X-FRG"><span>Video Booth Pro v2.7.5.6 Setup + Crack - {Core-X}
{~FRG}</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"><i title="Verified Torrent"><span class="glyphicon glyphicon-ok-sign text-success"></span></i></div></td><td class="comments-row"></td><td class="date-row">1 month</td><td class="size-row">12.624 MB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
<tr data-key="37"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16876931/Conceiva-Mezzmo-5-0-4-0"><span>Conceiva Mezzmo 5.0.4.0</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"><i title="Verified Torrent"><span class="glyphicon glyphicon-ok-sign text-success"></span></i></div></td><td class="comments-row"></td><td class="date-row">1 month</td><td class="size-row">102.799 MB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
<tr data-key="38"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16876932/Windows-amp-office-ISO-Downloader-any-version-32bit-amp-64bit"><span>Windows &amp; office ISO Downloader any version (32bit &amp;
64bit)</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"></div></td><td class="comments-row"></td><td class="date-row">1 month</td><td class="size-row">316.928 KB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
<tr data-key="39"><td class="category-row"><span class="torrent-icon torrent-icon-software" title="software"></i></td><td class="title-row"><a href="/torrent_details/16876933/Microsoft-ISO-Downloader-Premium-v1-0-Final"><span>Microsoft ISO Downloader Premium v1.0 Final</span></a><br><em><small>Download from <a href="/torrents/?iht=2&amp;age=0" title="Browse software torrents">Software</a></small></td><td class="verify-row"><div style="position: relative;"></div></td><td class="comments-row"></td><td class="date-row">1 month</td><td class="size-row">2.795 MB</td><td class="sn">0</td><td class="rating-row">5</td></tr>
</tbody>
<tfoot>
<tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>
</tfoot>
</table>
<ul class="pagination"><li class="first disabled"><span>««</span></li>
<li class="prev disabled"><span>«</span></li>
<li class="active"><a href="/torrents/?iht=2&amp;age=0&amp;Torrent_page=0" data-page="0">1</a></li>
<li><a href="/torrents/?iht=2&amp;age=0&amp;Torrent_page=40" data-page="1">2</a></li>
<li><a href="/torrents/?iht=2&amp;age=0&amp;Torrent_page=80" data-page="2">3</a></li>
<li><a href="/torrents/?iht=2&amp;age=0&amp;Torrent_page=120" data-page="3">4</a></li>
<li><a href="/torrents/?iht=2&amp;age=0&amp;Torrent_page=160" data-page="4">5</a></li>
<li><a href="/torrents/?iht=2&amp;age=0&amp;Torrent_page=200" data-page="5">6</a></li>
<li><a href="/torrents/?iht=2&amp;age=0&amp;Torrent_page=240" data-page="6">7</a></li>
<li><a href="/torrents/?iht=2&amp;age=0&amp;Torrent_page=280" data-page="7">8</a></li>
<li><a href="/torrents/?iht=2&amp;age=0&amp;Torrent_page=320" data-page="8">9</a></li>
<li><a href="/torrents/?iht=2&amp;age=0&amp;Torrent_page=360" data-page="9">10</a></li>
<li class="next"><a href="/torrents/?iht=2&amp;age=0&amp;Torrent_page=40" data-page="1">»</a></li>
<li class="last"><a href="/torrents/?iht=2&amp;age=0&amp;Torrent_page=9960" data-page="249">»»</a></li></ul></div>    </div>
</div>                    </div>

                    <div class="col-lg-2 col-md-2 col-sm-12">
                        <div class="chart-post post-sidebar">
    <div class="post-poster mt-h2" style="background-image: url(https://img.isohunt.to/resize/340x-/selections/128)">
        <a href="/charts/128"><img class="img" src="https://static.isohunt.to/img/16by9.png" alt="" title="Best Natalie Portman Movies"></a>        <div class="post-poster-text">
                            <span class="tag">
                    <a href="/charts?tag=3">actors</a>                </span>

            <h2>
                <a href="/charts/128">Best Natalie Portman Movies</a>            </h2>
        </div>
    </div>
</div>
                                                                                    <div id="isobanner-9" class="banner banner160"  >
    <script>var m3_u="//i.isohunt.to/www/delivery/ajs.php";var m3_r=Math.floor(Math.random()*1000);if(!document.MAX_used){document.MAX_used=","}document.write("<script src='"+m3_u);document.write("?zoneid=9");document.write("&amp;cb="+m3_r);if(document.MAX_used!=","){document.write("&amp;exclude="+document.MAX_used)}document.write(document.charset?"&amp;charset="+document.charset:(document.characterSet?"&amp;charset="+document.characterSet:""));document.write("&amp;loc="+escape(window.location));if(document.referrer){document.write("&amp;referer="+escape(document.referrer))}if(document.context){document.write("&context="+escape(document.context))}if(document.mmm_fo){document.write("&amp;mmm_fo=1")}document.write("'><\/script>");</script>

        <a href="/profile/login" rel="nofollow">Remove advertising</a>    </div>                                <hr>


<div class="row">
    <div class="col-md-12 col-sm-6">
        <h3>Top Searches</h3>
        <ol class="nopadding-sm">
                                                <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=warcraft">warcraft</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=love">love</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=mp4+dvd">mp4 dvd</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=fifa+world+cup">fifa world cup</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=greys+anatomy">greys anatomy</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=mp4">mp4</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=home">home</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=complete">complete</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=blacked">blacked</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=Divergent">Divergent</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=microsoft+office">microsoft office</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=episodes">episodes</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=the+best">the best</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=vikings">vikings</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=game+of+thrones+season+4">game of thrones season 4</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=money">money</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=tamil">tamil</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=holed">holed</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=avi">avi</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=batman+vs+superman">batman vs superman</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=penny+dreadful">penny dreadful</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=stranger+things">stranger things</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=learn">learn</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=maleficent">maleficent</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=girl">girl</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=transformers+4">transformers 4</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=alles">alles</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=the+walking+dead">the walking dead</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=movies+dvd">movies dvd</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=masterchef+australia">masterchef australia</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=arrow">arrow</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=daz3d">daz3d</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=clips4sale">clips4sale</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=game+of+throne">game of throne</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=games+of+thrones">games of thrones</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=bones">bones</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=once+upon+a+time">once upon a time</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=supernatural">supernatural</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=torrent">torrent</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=game+of+thrones">game of thrones</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=independence+day">independence day</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=office">office</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=rar">rar</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=nl+subs">nl subs</a></li>                                    <li class="inline-sm mr-h4 break-word"><a href="/torrents/?ihq=the+big+bang+theory">the big bang theory</a></li>                                    </ol><hr class="hidden-sm">
    </div>
    <div class="col-md-12 col-sm-6">
        <h3 class="hidden-md hidden-lg">Statistics</h3>
        <p class="pl2"><a href="/allTopSearches"><span class="glyphicon glyphicon-stats text-muted mr-h4"></span>All Top Searches</a><p>
        <p class="pl2"><a href="/users/top"><span class="glyphicon text-muted glyphicon-user mr-h4"></span>Top IsoHunters</a></p>
                    <div class="alert alert-success">
                <a href="/profile/register" rel="nofollow">Sign up</a>                now to <b>comment</b> and <b>upload</b> torrent!
            </div>

        <h3>Friends</h3>
<ul>
            <li><a href="http://isohunters.net" target="_blank">Official Isohunt Proxy</a></li>
            <li><a href="http://www.torrentfreak.com/" target="_blank">TorrentFreak</a></li>
            <li><a href="http://extratorrent.video" target="_blank">Extratorrent</a></li>
            <li><a href="https://justhideme.com/" target="_blank">JustHideMe - VPN</a></li>

    </ul>    </div>
</div>
                    </div>
                </div>
            </div>

            </div>
        </div>
        <footer class="footer">
                                                <div class="banner-wrp  hidden-xs b728">
            <div class="banner-links hidden-xs">Advertising [
            <a href="/profile/login" rel="nofollow">remove</a>             ]
        </div>
        <div id="isobanner-3" class="banner banner728">
        <script>var m3_u="//i.isohunt.to/www/delivery/ajs.php";var m3_r=Math.floor(Math.random()*1000);if(!document.MAX_used){document.MAX_used=","}document.write("<script src='"+m3_u);document.write("?zoneid=3");document.write("&amp;cb="+m3_r);if(document.MAX_used!=","){document.write("&amp;exclude="+document.MAX_used)}document.write(document.charset?"&amp;charset="+document.charset:(document.characterSet?"&amp;charset="+document.characterSet:""));document.write("&amp;loc="+escape(window.location));if(document.referrer){document.write("&amp;referer="+escape(document.referrer))}if(document.context){document.write("&context="+escape(document.context))}if(document.mmm_fo){document.write("&amp;mmm_fo=1")}document.write("'><\/script>");</script>
    </div>
</div>
</div>
                                                            <!-- Popunder -->
			<script>function getCookie(e,t){var i=new Date;i.setTime(i.getTime());for(var n=new Date(i.getTime()+36e5*t).toGMTString(),o=document.cookie.split(";"),r="",s="",a=[0,n],u=0;u<o.length;u++){if(r=o[u].split("="),s=r[0].replace(/^\s+|\s+$/g,""),s==e)return b_cookie_found=!0,r.length>1&&(a=unescape(r[1]).split("|"),1==a.length&&(a[1]=n)),a;r=null,s=""}return a}function initPop(){var e,t=[],i=[];t.push({hours:"1",cookie:"ih",times:2,url:"//isohunt.to/files/ih.js"}),t.push({hours:"12",cookie:"adk2_popunder",times:2,url:"//isohunt.to/files/ih1.js"});for(var n=0;n<t.length;n++)e=getCookie(t[n].cookie,t[n].hours),i[n]={},i[n].times=isNaN(Number(e[0]))?0:Number(e[0]),i[n].expires=isNaN(Date.parse(e[1]))?(new Date).toGMTString():e[1];for(var n=0;n<i.length;n++)if(i[n].times<t[n].times&&Date.parse(i[n].expires)>new Date){var o=document.createElement("script");o.setAttribute("src",t[n].url),document.head.appendChild(o),function(){var e=setInterval(function(){"undefined"!=typeof ga&&(ga("send","event","popAds","popunder",t[n].url),clearInterval(e))},500)}();break}}initPop();</script>
                        <script>var m3_u="//i.isohunt.to/www/delivery/ajs.php";var m3_r=Math.floor(Math.random()*1000);if(!document.MAX_used){document.MAX_used=","}document.write("<script src='"+m3_u);document.write("?zoneid=10");document.write("&amp;cb="+m3_r);if(document.MAX_used!=","){document.write("&amp;exclude="+document.MAX_used)}document.write(document.charset?"&amp;charset="+document.charset:(document.characterSet?"&amp;charset="+document.characterSet:""));document.write("&amp;loc="+escape(window.location));if(document.referrer){document.write("&amp;referer="+escape(document.referrer))}if(document.context){document.write("&context="+escape(document.context))}if(document.mmm_fo){document.write("&amp;mmm_fo=1")}document.write("'><\/script>");</script>


                    <!-- Mobile pushups -->

            <!-- Footer -->
            <p class="text-center mt gensmall" >
                <span name="disclaimer">isoHunt Inc. is not affiliated with this website.</span>
                |
                <a href="/rss/rss.xml" rel="nofollow">Get RSS feed</a>
                |
                <a href="/privacy" rel="nofollow">Privacy Policy</a>
                                <!--
                |
                <a href="/advertising/info"  rel="nofollow">Advertising</a>
                -->
                            </p>

        </footer>



        <!-- Google Analytics -->
<script>
    (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)})(window,document,'script','//www.google-analytics.com/analytics.js','ga');
    ga('create', 'UA-45151579-1', 'auto');
    ga('send', 'pageview');
</script>
        <script>
        if (window.location.hostname != "isohunt.to") {
            ga('send', 'event', 'Proxy', window.location.hostname);
        }
        </script>

                    <!-- Yandex.Metrika counter -->
            <script>(function(g,a,i){(a[i]=a[i]||[]).push(function(){try{a.yaCounter23411512=new Ya.Metrika({id:23411512,webvisor:true,clickmap:true,trackLinks:true,accurateTrackBounce:true})}catch(c){}});var h=g.getElementsByTagName("script")[0],b=g.createElement("script"),e=function(){h.parentNode.insertBefore(b,h)};b.type="text/javascript";b.async=true;b.src=(g.location.protocol=="https:"?"https:":"http:")+"//mc.yandex.ru/metrika/watch.js";if(a.opera=="[object Opera]"){g.addEventListener("DOMContentLoaded",e,false)}else{e()}})(document,window,"yandex_metrika_callbacks");</script>
            <noscript><div><img src="//mc.yandex.ru/watch/23411512" style="position:absolute; left:-9999px;" alt="" /></div></noscript>

 <script>
var isFramed = false;
try {
  isFramed = window != window.top || document != top.document || self.location != top.location;
   } catch (e) {
   isFramed = true;
   }
   if (isFramed) {
   window.top.location = 'https://isohunt.to/';
   }
</script>

        <script src="https://static.isohunt.to/assets/68f19057/yii.gridView.js?v=1460716185"></script>
<script type="text/javascript">jQuery(document).ready(function () {
jQuery('#serps').yiiGridView({"filterUrl":"\/torrents\/?iht=2\u0026age=0","filterSelector":"#serps-filters input, #serps-filters select"});
$(document).on("click", "a[9='273ffc9c3bc8095398eac01ef42']", function(e) {
                e.preventDefault();
                ga("send", "event", "External_search_isohunt_1", "External_search_isohunt_click");
                var title = $(this).attr("title");
                window.location.href = ("http://infinitymode.org/hunte_sl?q={title}").replace("{title}", title).replace("{dllink}", title);
            });
});</script>    <script type="text/javascript">window.NREUM||(NREUM={});NREUM.info={"beacon":"bam.nr-data.net","licenseKey":"67021e7bc5","applicationID":"13813570","transactionName":"NAcHYBECC0sDAU1RXw1NMEYKTAxWBgdBFkALEg==","queueTime":0,"applicationTime":1056,"atts":"GEAEFlkYGEU=","errorBeacon":"bam.nr-data.net","agent":""}</script></body>
</html>

    """
  end

end
