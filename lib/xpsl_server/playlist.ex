defmodule Playlist do
  @enforce_keys [:tracks, :previous_tracks]
  defstruct tracks: nil, previous_tracks: nil

  @doc """
  Creates a new playlist with an empty list of tracks
  """
  def new() do
    %Playlist{tracks: [], previous_tracks: []}
  end

  @doc """
  Add a track to the playlist
  """
  def queue(playlist, track) do
    %{playlist | tracks: [track | playlist.tracks]}
  end

  @doc """
  Next track command moves the current track to the top of the `previous_tracks` list
  """
  def next(playlist) do
    {current_track, future_tracks} = List.pop_at(playlist.tracks, 0)
    %{playlist | tracks: future_tracks, previous_tracks: [current_track | playlist.previous_tracks]}
  end

  @doc """
  Previous track command moves the top `previous_tracks` track to the head of the currently playing `tracks` list
  """
  def previous(playlist) do
    {to_be_current_track, other_previous_tracks} = List.pop_at(playlist.previous_tracks, 0)

    if to_be_current_track do
      %{playlist | tracks: [to_be_current_track | playlist.tracks], previous_tracks: other_previous_tracks}
    else
      playlist
    end
  end
end
