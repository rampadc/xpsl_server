defmodule XpslServer.PlaylistSupervisor do
  @moduledoc """
  A supervisor that starts `PlaylistServer` processes dynamically.
  """

  use DynamicSupervisor

  alias XpslServer.PlaylistServer

  def start_link(_args) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc """
  Start a `PlaylistServer` process and supervises it
  """
  def open_playlist(playlist_name) do
    child_spec = %{
      id: PlaylistServer,
      start: {PlaylistServer, :start_link, [playlist_name]},
      restart: :transient # restarts only if child crashes (terminates abnormally), default `permanent` will restart timed-out processes
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  @doc """
  Terminates the `PlaylistServer` process normally. Do not restart.
  """
  def close_playlist(playlist_name) do
    :ets.delete(:playlists_table, playlist_name)

    child_pid = PlaylistServer.playlist_pid(playlist_name)
    DynamicSupervisor.terminate_child(__MODULE__, child_pid)
  end

  def list_playlists() do
    DynamicSupervisor.which_children(__MODULE__)
    |> Enum.map(fn {_, pid, _, _} ->
      Registry.keys(XpslServer.PlaylistRegistry, pid) |> List.first()
    end)
    |> Enum.sort()
  end
end
