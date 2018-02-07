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
        [get_config: fn key when key == :team -> ["a","b"] end]
      },
      {
        IO,
        [],
        [puts: fn(_) -> nil end]
      }
    ]) do
      Jirino.main ["team"]
      assert called IO.puts "-> a\n-> b"
    end
  end

  test "should show the info message if no team members are set" do
    with_mocks([
      {
        Jirino.Utilities,
        [],
        [get_config: fn key when key == :team -> [] end]
      },
      {
        IO,
        [],
        [puts: fn(_) -> nil end]
      }
    ]) do
      Jirino.main ["team"]
      assert called IO.puts "The team has not been defined yet!"
    end
  end

  test "should show user's issues" do
    issue1 = %Jirino.Issue{ description: "Issue 1" }
    issue2 = %Jirino.Issue{ description: "Issue 2" }

    with_mocks([
      {
        Jirino.Utilities,
        [],
        [get_config: fn key when key == :username -> "me@mail.com" end]
      },
      {
        Jirino.RemoteCalls,
        [],
        [get_issues_for_users: fn users when users == ["me@mail.com"] -> [issue1, issue2] end]
      },
      {
        Jirino.Issue,
        [],
        [format: fn
          issue when issue == issue1 -> "My formatted issue 1"
          issue when issue == issue2 -> "My formatted issue 2"
        end]
      },
      {
        IO,
        [],
        [puts: fn(_) -> nil end]
      }
    ]) do
      Jirino.main ["issues"]
      assert called IO.puts "My formatted issue 1\nMy formatted issue 2"
    end
  end
end
