defmodule XpslServer.PlaylistServer do
  @moduledoc """
  A playlist server process that holds a `Playlist` struct as its state
  """

  use GenServer

  require Logger

  @timeout :timer.minutes(30)

  def start_link(playlist_name) do
    GenServer.start_link(__MODULE__, { playlist_name }, name: via_tuple(playlist_name))
  end

  def init({playlist_name}) do
    playlist =
      case :ets.lookup(:playlists_table, playlist_name) do
        [] ->
          playlist = Playlist.new()
          :ets.insert(:playlists_table, {playlist_name, playlist})
          playlist
        [{^playlist_name, playlist}] ->
          playlist
      end

    Logger.info("Spawned playlist server process called '#{playlist_name}}'")
    {:ok, playlist, @timeout}
  end

  def queue(playlist_name, track) do
    GenServer.call(via_tuple(playlist_name), {:queue, track})
  end

  def next(playlist_name) do
    GenServer.call(via_tuple(playlist_name), {:next})
  end

  def previous(playlist_name) do
    GenServer.call(via_tuple(playlist_name), {:previous})
  end

  def handle_call({:queue, track}, _from, playlist) do
    new_playlist = Playlist.queue(playlist, track)
    :ets.insert(:playlists_table, {current_playlist_name(), new_playlist})
    {:reply, new_playlist, new_playlist, @timeout}
  end

  def handle_call({:next}, _from, playlist) do
    new_playlist = Playlist.next(playlist)
    :ets.insert(:playlists_table, {current_playlist_name(), new_playlist})
    {:reply, new_playlist, new_playlist, @timeout}
  end

  def handle_call({:previous}, _from, playlist) do
    new_playlist = Playlist.previous(playlist)
    :ets.insert(:playlists_table, {current_playlist_name(), new_playlist})
    {:reply, new_playlist, new_playlist, @timeout}
  end

  def via_tuple(playlist_name) do
    {:via, Registry, {XpslServer.PlaylistRegistry, playlist_name}}
  end

  def playlist_pid(playlist_name) do
    playlist_name
    |> via_tuple()
    |> GenServer.whereis()
  end

  def handle_info(:timeout, playlist) do
    {:stop, {:shutdown, :timeout}, playlist}
  end

  def terminate({:shutdown, :timeout}, _playlist) do
    :ets.delete(:playlists_table, current_playlist_name())
    :ok
  end

  def terminate(reason, _playlist) do
    Logger.info("Catch-all terminate. Reason: #{reason}}")
    :ok
  end

  defp current_playlist_name do
    Registry.keys(XpslServer.PlaylistRegistry, self()) |> List.first
  end
end
