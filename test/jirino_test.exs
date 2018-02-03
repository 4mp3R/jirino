defmodule JirinoTest do
  use ExUnit.Case
  import Mock

  doctest Jirino.Utilities
  doctest Jirino.Issue

  test "should show the team members if there are some" do
    with_mocks([
      {
        Jirino.Utilities,
        [],
        [get_config: fn(_) -> ["a","b"] end]
      },
      {
        IO,
        [],
        [puts: fn(_) -> 0 end]
      }
    ]) do
      Jirino.main ["team"]
      assert called Jirino.Utilities.get_config :team
      assert called IO.puts "-> a\n-> b"
    end
  end

  test "should show the info message if no team members are set" do
    with_mocks([
      {
        Jirino.Utilities,
        [],
        [get_config: fn(_) -> [] end]
      },
      {
        IO,
        [],
        [puts: fn(_) -> 0 end]
      }
    ]) do
      Jirino.main ["team"]
      assert called Jirino.Utilities.get_config :team
      assert called IO.puts "The team has not been defined yet!"
    end
  end
end
