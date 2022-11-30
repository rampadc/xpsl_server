defmodule XpslServer.PlaylistServer do
  @moduledoc """
  A playlist server process that holds a `Playlist` struct as its state
  """

  use GenServer

  require Logger

  @timeout :timer.hours(2)

  def start_link(playlist_name) do
    GenServer.start_link(__MODULE__, { playlist_name }, name: via_tuple(playlist_name))
  end

  def init({playlist_name}) do
    playlist =
      case :ets.lookup(:playlists_table, playlist_name) do
        [] ->
          playlist = Playlist.new()
          :ets.insert(:playlists_table, {playlist_name})
          playlist
        [{^playlist_name, playlist}] ->
          playlist
      end

    Logger.info("Spawned playlist server process called '#{playlist_name}}'")
    {:ok, playlist, @timeout}
  end

  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end

  def via_tuple(playlist_name) do
    {:via, Registry, {XpslServer.PlaylistRegistry, playlist_name}}
  end

  def playlist_pid(playlist_name) do
    playlist_name
    |> via_tuple()
    |> GenServer.whereis()
  end

  def terminate({:shutdown, :timeout}, _playlist) do
    :ets.delete(:playlists_table, current_playlist_name())
    :ok
  end

  def terminate(_reason, _playlist) do
    :ok
  end

  defp current_playlist_name do
    Registry.keys(XpslServer.PlaylistRegistry, self()) |> List.first
  end
end
