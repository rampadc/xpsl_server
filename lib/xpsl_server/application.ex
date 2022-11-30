defmodule XpslServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: XpslServer.PlaylistRegistry},
    ]

    :ets.new(:playlists_table, [:public, :named_table])

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: XpslServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
