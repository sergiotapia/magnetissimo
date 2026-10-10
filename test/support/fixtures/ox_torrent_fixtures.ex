defmodule Magnetissimo.OxTorrentFixtures do
  @moduledoc """
  Synthetic OxTorrent pages for tests: the search results and a release's own
  page.

  Shaped after the real site. Load-bearing details: the results page links
  releases from a strip of covers as well as from its table, and only the
  table rows are hits; a row's title carries HTML entities; the release page's
  magnet link lists its trackers unencoded and carries no name; the page
  gives the day it was posted, day first.
  """

  @hash_upper "F83EF8ECB9ECEBA1C55267264478EE4552A2A095"
  @other_hash "d258c5a9516892ac422ae3d2922ca26a1c8195b0"

  def hash_upper, do: @hash_upper
  def other_hash, do: @other_hash

  @doc "A page of search results with two releases, and a cover strip that is not one."
  def search_body do
    rows = [
      row(
        "/detail/77524",
        "The.Woman.in.Cabin.10.2025.MULTi.2160p.WEB.H265-FW",
        "Films",
        "8.42 GB",
        seeders: 16,
        leechers: 5
      ),
      row("/detail/1234", "Windows.&amp;.Internet.Pratique.N.170.pdf", "Ebooks", "575.59 MB",
        seeders: 3,
        leechers: 0
      )
    ]

    results_page(rows)
  end

  @doc "Search results listing a release at each of `paths`, newest first."
  def search_body(paths) do
    paths
    |> Enum.map(&row(&1, &1, "Films", "1.00 GB", seeders: 1, leechers: 1))
    |> results_page()
  end

  @doc "Search results that match nothing."
  def empty_search_body, do: results_page([])

  @doc "The page for The Woman in Cabin 10, its infohash uppercased."
  def cabin_body, do: release_body(@hash_upper, "26/10/2025")

  @doc "The page for the Windows magazine."
  def magazine_body, do: release_body(@other_hash, "03/02/2026")

  @doc "A release page whose magnet link has gone missing."
  def no_hash_body do
    String.replace(cabin_body(), ~r/<a href="magnet:[^"]*">/, "<a>")
  end

  defp results_page(rows) do
    """
    <script type="e5c237e9ea6cf5ff03b2a173-text/javascript">window['ZpQw9XkLmN8c3vR3']='A3BYEDFX';</script>
    <html><body>
    <div class="bloc-torrent">
    <div class="title"><i class="fa fa-bars"></i> Top Films</div>
    <div class="cover">
    \t\t\t\t\t<a href="/detail/77865">
    \t\t\t\t\t<img style="width:146px;height:182px;" title="Frankenstein FRENCH WEBRIP 2025" alt="Frankenstein FRENCH WEBRIP 2025" src="https://zimage.cc/uploads/screen/7ae0.webp">
    \t\t\t\t\t<b>Télécharger !</b>
    \t\t\t\t\t</a></div>
    </div>
    \t<table class="table table-hover">
    <thead>
    \t\t\t\t  <th class="cust-table">Type</th>
                       <th class="cust-table">Nom du torrent</th>
                      </thead>
    \t\t<tbody>
    \t\t<div class="block-detail">
    <div class="title"><i class="fas fa-search"></i> cabin</div></div>
    #{Enum.join(rows, "\n")}
    \t\t</tbody>
        </table>
    \t\t<ul class="pagination">
    \t\t\t   <li class="disabled"><a>[1-#{length(rows)}]</a></li>
    \t\t\t</ul>
    </body></html>
    """
  end

  defp row(path, title, category, size, swarm) do
    """
    <tr>
    <td class="type liste-accueil-type" title="#{category}"><a href="/category/x"><i class="#{category}"></i></a></td>
    <td class="liste-accueil-nom"> <div class="maxi"><a href="#{path}" title="#{title}">#{title}</a></div></td>
    <td class="liste-accueil-taille" title="Taille">#{size}</td>
    <td class="sources liste-accueil-sources" title="Sources">#{swarm[:seeders]}</td>
    <td class="clients liste-accueil-clients" title="Clients">#{swarm[:leechers]}</td>
    <td class="compl liste-accueil-compl" title="Complétés"> 2100</td>
    <td class="date liste-accueil-date" title="Date"><i class="fa-regular fa-clock"></i> 11 mois</td>
        </tr>
    """
  end

  defp release_body(hash, date) do
    """
    <html><body>
    <div class="block-detail">
    <div class="title"><i class="fa fa-bars" aria-hidden="true"></i> The.Woman.in.Cabin.10.2025.MULTi.2160p.WEB.H265-FW</div></div>
    <span class="icon_desc"><i class="fa fa-list-alt" aria-hidden="true"></i><a href="/category/films" title="Films"> Films</a></span>
    <span class="icon_date"><i class="fa fa-clock" aria-hidden="true"></i> #{date}</span>
    <table class="table">
    \t\t\t\t  <tr>
    \t\t\t\t\t<td style="padding-top:10px;">Télécharger:</td>
    \t\t\t\t\t<td width="81%" align="left"><a href="/get_torrents/#{hash}"><div class="downtorrent"><button class="buttons">Télécharger le torrent</button></div></a> <a href="magnet:?xt=urn:btih:#{hash}&tr=udp://tracker.opentrackr.org:1337/announce&tr=http://atrack.pow7.com/announce&tr=udp://tracker.opentrackr.org:1337/announce"><div class="downmagnet"><button class="buttons">Magnet Link</button></div></a></td>
    \t\t\t\t  </tr>
    \t\t\t\t  <tr>
    \t\t\t\t\t<td>Titre:</td>
    \t\t\t\t\t<td width="81%" align="left"><strong><div class="maximums">La Disparue de la cabine 10 - The Woman In Cabin 10 MULTI 4K 2025</div></strong></td>
    \t\t\t\t  </tr>
    \t\t\t\t  <tr>
    \t\t\t\t\t<td>Sous-Catégories:</td>
    \t\t\t\t\t<td width="81%" align="left"><strong>Policier, Thriller</strong></td>
    \t\t\t\t  </tr>
    \t\t\t\t  <tr>
    \t\t\t\t\t<td>Poids du fichier:</td>
    \t\t\t\t\t<td width="81%" align="left"><strong>8.42 GB</strong></td>
    \t\t\t\t  </tr>
    </table>
    </body></html>
    """
  end
end
