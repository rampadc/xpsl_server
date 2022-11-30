defmodule Track do
  @derive {Jason.Encoder, only: [:songwhip_url, :current_position_seconds]}

  @enforce_keys [:songwhip_url, :current_position_seconds]
  defstruct [:songwhip_url, :current_position_seconds]

  @doc """
  Creates a new Track with a Songwhip URL and current position in the track to be played
  """
  def new(songwhip_url, current_position_seconds) do
    %Track{songwhip_url: songwhip_url, current_position_seconds: current_position_seconds}
  end
end
