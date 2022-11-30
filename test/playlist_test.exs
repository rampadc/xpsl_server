defmodule PlaylistTest do
  use ExUnit.Case, async: true

  doctest Playlist

  test "creating a playlist" do
    playlist = Playlist.new()

    assert playlist.tracks == []
    assert playlist.previous_tracks == []
  end

  test "queue a track" do
    playlist = Playlist.new()

    track1 = Track.new("songwhip_url1", 0)
    track2 = Track.new("songwhip_url2", 2)

    playlist = Playlist.queue(playlist, track1)
    playlist = Playlist.queue(playlist, track2)

    assert Map.equal?(List.first(playlist.tracks), track2)

    [_current_track | prev_tracks] = playlist.tracks
    assert Map.equal?(List.first(prev_tracks), track1)
  end

  test "get the next track" do
    playlist = Playlist.new()

    track1 = Track.new("songwhip_url1", 0)
    track2 = Track.new("songwhip_url2", 2)

    playlist = playlist |> Playlist.queue(track1) |> Playlist.queue(track2) |> Playlist.next()

    assert Map.equal?(List.first(playlist.tracks), track1)
    assert Map.equal?(List.first(playlist.previous_tracks), track2)
  end

  test "previous tracks should return the same playlist if there are no tracks in previous_tracks list" do
    playlist = Playlist.new()

    track1 = Track.new("songwhip_url1", 0)
    track2 = Track.new("songwhip_url2", 2)

    playlist = playlist
               |> Playlist.queue(track1)
               |> Playlist.queue(track2)
    new_playlist = Playlist.previous(playlist)

    assert new_playlist.previous_tracks == []
    assert new_playlist.tracks == playlist.tracks
  end

  test "previous track command should move the head of `previous_tracks` list to the head of `tracks` list" do
    playlist = Playlist.new()

    track1 = Track.new("songwhip_url1", 0)
    track2 = Track.new("songwhip_url2", 2)

    playlist = playlist
               |> Playlist.queue(track1)  # tracks: [t1]
               |> Playlist.queue(track2)  # tracks: [t2, t1]
               |> Playlist.next()         # tracks: [t1], previous_tracks: [t2]
               |> Playlist.previous()  # tracks: [t2, t1], previous_tracks: []

    assert Map.equal?(List.first(playlist.tracks), track2)
    assert playlist.previous_tracks == []
  end
end
