defmodule PlaylistSupervisorTest do
  use ExUnit.Case, async: true

  doctest XpslServer.PlaylistSupervisor

  alias XpslServer.{PlaylistSupervisor, PlaylistServer}

  describe "open_playlist" do
    test "spawns a playlist server process" do
      name = generate_name()

      assert {:ok, _pid} = PlaylistSupervisor.open_playlist(name)

      via = PlaylistServer.via_tuple(name)
      assert GenServer.whereis(via) |> Process.alive?()
    end

    test "returns an error if playlist is already opened" do
      name = generate_name()

      {:ok, pid} = PlaylistSupervisor.open_playlist(name)
      assert {:error, {:already_started, ^pid}} = PlaylistSupervisor.open_playlist(name)
    end
  end

  describe "close_playlist" do
    test "terminates the process normally" do
      name = generate_name()

      {:ok, _pid} = PlaylistSupervisor.open_playlist(name)

      via = PlaylistServer.via_tuple(name)
      assert :ok = PlaylistSupervisor.close_playlist(name)

      refute GenServer.whereis(via)
    end
  end

  defp generate_name do
    "playlist-#{:rand.uniform(1_000_000)}"
  end
end
