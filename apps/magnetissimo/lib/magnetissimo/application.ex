defmodule Magnetissimo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Magnetissimo.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Magnetissimo.PubSub}
      # Start a worker by calling: Magnetissimo.Worker.start_link(arg)
      # {Magnetissimo.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Magnetissimo.Supervisor)
  end
end
