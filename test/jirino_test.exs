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

  test "should show team issues" do
    {:ok, creation_date_1, _} = DateTime.from_iso8601("2020-10-10T10:10:10.000Z")
    issue1 = %Jirino.Issue{
      key: "AA-777",
      type: "Bug",
      priority: "High",
      status: "In Development",
      creator: "Bob",
      summary: "First issue summary",
      description: "Here is the description",
      created: creation_date_1,
      assignee: "Tom"
    }

    {:ok, creation_date_2, _} = DateTime.from_iso8601("2020-11-11T10:10:10.000Z")
    issue2 = %Jirino.Issue{
      key: "BB-999",
      type: "Task",
      priority: "Low",
      status: "In QA",
      creator: "Bob",
      summary: "Second issue summary",
      description: "Here is another description",
      created: creation_date_2,
      assignee: "Simon"
    }

    with_mocks([
      {
        Jirino.Utilities,
        [],
        [get_config: fn key when key == :team -> ["me@mail.com", "teammate@mail.com"] end]
      },
      {
        Jirino.RemoteCalls,
        [],
        [get_issues_for_users: fn users when users == ["me@mail.com", "teammate@mail.com"] -> [issue1, issue2] end]
      },
      {
        IO,
        [],
        [puts: fn(_) -> nil end]
      }
    ]) do
      Jirino.main ["team", "issues"]

      assert outputs == [
        """
        ===[Tom's issues]===
        AA-777 (Bug) - In Development :: 2020/10/10 10:10 :: Tom :: First issue summary
        """,
        """
        ===[Simon's issues]===
        BB-999 (Task) - In QA :: 2020/11/11 10:10 :: Simon :: Second issue summary
        """
      ]
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
