defmodule UserTest do
  use ExUnit.Case

  alias User

  @moduletag :capture_log

  doctest User

  test "creates a new Spotify user" do
    spotify_user = User.new("spotify user", "😅", "spotify")

    assert spotify_user.name == "spotify user"
    assert spotify_user.icon == "😅"
    assert spotify_user.music_provider == "spotify"
  end

  test "creates a new Apple Music user" do
    spotify_user = User.new("apple music user", "🥰", "apple_music")

    assert spotify_user.name == "apple music user"
    assert spotify_user.icon == "🥰"
    assert spotify_user.music_provider == "apple_music"
  end

  test "creates a non-Apple Music/Spotify will throw" do
    assert catch_throw(User.new("invalid user", "🥰", "not_apple_music_or_spotify"))


  end
end
