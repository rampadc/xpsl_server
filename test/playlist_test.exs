defmodule PlaylistTest do
  use ExUnit.Case, async: true

  doctest Playlist

  test "creating a playlist" do
    playlist = Playlist.new()

    assert playlist.tracks == []
  end

  test "add new tracks to a playlist" do
    playlist = Playlist.new()

    track1 = Track.new("songwhip_url1", 0)
    track2 = Track.new("songwhip_url2", 2)

    playlist = Playlist.add_track(playlist, track1)
    playlist = Playlist.add_track(playlist, track2)

    assert Map.equal?(List.first(playlist.tracks), track2)

    [_current_track | prev_tracks] = playlist.tracks
    assert Map.equal?(List.first(prev_tracks), track1)
  end
end
