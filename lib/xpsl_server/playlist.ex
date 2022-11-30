defmodule Playlist do
  @enforce_keys [:tracks]
  defstruct tracks: nil

  @doc """
  Creates a new playlist with an empty list of tracks
  """
  def new() do
    %Playlist{tracks: []}
  end

  @doc """
  Add a track to the playlist
  """
  def add_track(playlist, track) do
    %{playlist | tracks: [track | playlist.tracks]}
  end
end
