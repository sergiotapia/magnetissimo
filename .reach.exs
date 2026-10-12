# Architecture policy checked by `mix reach.check --arch` (part of
# `mix precommit`).
[
  layers: [
    # The application starts both layers, so it sits above them.
    app: "Magnetissimo.Application",
    web: ["MagnetissimoWeb", "MagnetissimoWeb.*"],
    domain: ["Magnetissimo", "Magnetissimo.*"]
  ],
  deps: [
    forbidden: [
      # The domain never reaches into the web layer.
      {:domain, :web}
    ]
  ],
  calls: [
    forbidden: [
      # LiveViews and controllers call contexts and never touch Repo directly.
      {"MagnetissimoWeb.*", ["Magnetissimo.Repo", "Magnetissimo.Repo.*", "Ecto.Query.*"]},
      # Every source is scraped through Req, so timeouts, retries and a dead
      # site are handled in one place instead of once per crawler.
      {"*", ["HTTPoison.*", "Tesla.*", "Finch.request", "Finch.stream", ":httpc.*"]},
      # Nothing shells out. The DHT's UDP and TCP sockets are :gen_udp and
      # :gen_tcp, not ports.
      {"*", ["System.cmd", "System.shell", "Port.open"]},
      # Never build atoms from input.
      {"*", ["String.to_atom", "List.to_atom"]},
      # Logger, not stdout.
      {"*", ["IO.puts", "IO.inspect"]}
    ]
  ]
]
