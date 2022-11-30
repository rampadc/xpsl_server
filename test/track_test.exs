defmodule TrackTest do
  use ExUnit.Case, async: true

  doctest Track

  test "creating a track" do
    track = Track.new("https://songwhip.com", 0)

    assert track.songwhip_url == "https://songwhip.com"
    assert track.current_position_seconds == 0
  end
end
