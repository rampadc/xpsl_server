defmodule PlaylistServerTest do
  use ExUnit.Case

  alias XpslServer.PlaylistServer

  @moduletag :capture_log

  doctest PlaylistServer

  test "spawning a playlist server process" do
    playlist_name = generate_playlist_name()
    assert {:ok, _pid} = PlaylistServer.start_link(playlist_name)
  end

  test "a playlist process is registered under a unique name" do
    playlist_name = generate_playlist_name()

    assert {:ok, _pid} = PlaylistServer.start_link(playlist_name)
    assert {:error, _reason} = PlaylistServer.start_link(playlist_name)
  end

  test "add 1 track" do
    playlist_name = generate_playlist_name()
    {:ok, _pid} = PlaylistServer.start_link(playlist_name)

    track1 = Track.new("track_url", 0)
    new_playlist = PlaylistServer.queue(playlist_name, track1)

    assert Map.equal?(List.first(new_playlist.tracks), track1)
  end

  test "next track" do
    playlist_name = generate_playlist_name()
    {:ok, _pid} = PlaylistServer.start_link(playlist_name)

    track1 = Track.new("track_url", 0)
    PlaylistServer.queue(playlist_name, track1)
    new_playlist = PlaylistServer.next(playlist_name)

    assert Map.equal?(List.first(new_playlist.previous_tracks), track1)
    assert new_playlist.tracks == []
  end

  test "prev track" do
    playlist_name = generate_playlist_name()
    {:ok, _pid} = PlaylistServer.start_link(playlist_name)

    track1 = Track.new("track_url", 0)
    PlaylistServer.queue(playlist_name, track1)
    PlaylistServer.next(playlist_name)
    new_playlist = PlaylistServer.previous(playlist_name)

    assert Map.equal?(List.first(new_playlist.tracks), track1)
    assert new_playlist.previous_tracks == []
  end

  test "stores initial state in ETS when started" do
    playlist_name = generate_playlist_name()
    {:ok, _pid} = PlaylistServer.start_link(playlist_name)

    assert [{^playlist_name, playlist}] = :ets.lookup(:playlists_table, playlist_name)

    assert playlist.tracks == []
    assert playlist.previous_tracks == []
  end

  test "update state in ETS when new track is queued" do
    playlist_name = generate_playlist_name()
    {:ok, _pid} = PlaylistServer.start_link(playlist_name)

    track1 = Track.new("track_url", 0)
    PlaylistServer.queue(playlist_name, track1)
    assert [{^playlist_name, ets_playlist}] = :ets.lookup(:playlists_table, playlist_name)

    assert Map.equal?(List.first(ets_playlist.tracks), track1)
  end

  test "gets its initial state from ETS if previously stored" do
    playlist_name = generate_playlist_name()

    track1 = Track.new("track_url", 0)
    playlist = Playlist.new()
    playlist = Playlist.queue(playlist, track1)
    :ets.insert(:playlists_table, {playlist_name, playlist})

    {:ok, _pid} = PlaylistServer.start_link(playlist_name)
    assert [{^playlist_name, ets_playlist}] = :ets.lookup(:playlists_table, playlist_name)

    assert Map.equal?(List.first(ets_playlist.tracks), track1)
  end

  describe "playlist_pid" do
    test "returns a PID if it has been registered" do
      playlist_name = generate_playlist_name()
      {:ok, pid} = PlaylistServer.start_link(playlist_name)
      assert ^pid = PlaylistServer.playlist_pid(playlist_name)
    end

    test "returns nil if the playlist does not exist" do
      refute PlaylistServer.playlist_pid("nonexistent-game")
    end
  end

  defp generate_playlist_name do
    "playlist-#{:rand.uniform(1_000_000)}"
  end
end
