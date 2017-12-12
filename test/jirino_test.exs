defmodule JirinoTest do
  use ExUnit.Case
  doctest Jirino

  test "greets the world" do
    assert Jirino.hello() == :world
  end
end
