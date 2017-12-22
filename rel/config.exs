use Mix.Releases.Config,
    # This sets the default release built by `mix release`
    default_release: :default,
    # This sets the default environment used by `mix release`
    default_environment: :prod

# For a full list of config options for both releases
# and environments, visit https://hexdocs.pm/distillery/configuration.html


# You may define one or more environments in this file,
# an environment's settings will override those of a release
# when building in that environment, this combination of release
# and environment configuration is called a profile

environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: :"l5P0n|OU6tZ}$2:.@cYG|o`Glg3GD5[5RD.gR])S$PS}@Og(=s;%7~?f!%sB|k`G"
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"%t>{w.p<B}^[(NAK_~&^p*K_OLM_*SJ,{@iyt>tai!A)%mT$~,cR1mCCj9^cXO~~"
end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix release`, the first release in the file
# will be used by default

release :magnetissimo do
  set version: current_version(:magnetissimo)
  set applications: [html_entities: :load, floki: :load]
end
