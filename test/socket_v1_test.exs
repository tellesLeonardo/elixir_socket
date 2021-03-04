defmodule SocketV1Test do
  use ExUnit.Case
  doctest SocketV1

  test "greets the world" do
    assert SocketV1.hello() == :world
  end
end
