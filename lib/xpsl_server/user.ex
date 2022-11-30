defmodule User do
  @moduledoc false

  @enforce_keys [:name, :icon, :music_provider]
  defstruct [:name, :icon, :music_provider]

  @doc """
  Creates a new user with the given `name`, `icon` and `music provider` as `spotify`.
  """
  def new(name, icon, "spotify") do
    %User{name: name, icon: icon, music_provider: "spotify"}
  end

  @doc """
  Creates a new user with the given `name`, `icon` and `music provider` as `apple_music`.
  """
  def new(name, icon, "apple_music") do
    %User{name: name, icon: icon, music_provider: "apple_music"}
  end

  @doc """
  Rejects any other choices for the music provider
  """
  def new(_name, _icon, invalid_choice) do
    throw("Invalid choice: " <> invalid_choice <> ". Only apple_music and spotify is supported.")
  end
end
