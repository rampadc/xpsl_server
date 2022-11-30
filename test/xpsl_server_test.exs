defmodule XpslServerTest do
  use ExUnit.Case
  doctest XpslServer

  test "greets the world" do
    assert XpslServer.hello() == :world
  end
end
