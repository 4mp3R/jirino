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

      assert called IO.puts """
        ===[Simon's issues]===
        BB-999 (Task) - In QA :: 2020/11/11 10:10 :: Simon :: Second issue summary

        ===[Tom's issues]===
        AA-777 (Bug) - In Development :: 2020/10/10 10:10 :: Tom :: First issue summary
        """
    end
  end

  test "should show user's issues" do
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
        [get_config: fn key when key == :username -> "me@mail.com" end]
      },
      {
        Jirino.RemoteCalls,
        [],
        [get_issues_for_users: fn users when users == ["me@mail.com"] -> [issue1, issue2] end]
      },
      {
        IO,
        [],
        [puts: fn(_) -> nil end]
      }
    ]) do
      Jirino.main ["issues"]

      assert called IO.puts """
      AA-777 (Bug) - In Development :: 2020/10/10 10:10 :: Tom :: First issue summary
      BB-999 (Task) - In QA :: 2020/11/11 10:10 :: Simon :: Second issue summary\
      """
    end
  end

  test "should show new issues" do
    {:ok, creation_date_1, _} = DateTime.from_iso8601("2020-11-11T10:10:10.000Z")
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

    {:ok, creation_date_2, _} = DateTime.from_iso8601("2020-10-10T10:10:10.000Z")
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
        [get_config: fn key when key == :project -> "Super Duper Project" end]
      },
      {
        Jirino.RemoteCalls,
        [],
        [get_latest_issues_for_project: fn project when project == "Super Duper Project" -> [issue1, issue2] end]
      },
      {
        IO,
        [],
        [puts: fn(_) -> nil end]
      }
    ]) do
      Jirino.main ["issues", "new"]

      assert called IO.puts """
      AA-777 (Bug) - In Development :: 2020/11/11 10:10 :: Tom :: First issue summary
      BB-999 (Task) - In QA :: 2020/10/10 10:10 :: Simon :: Second issue summary\
      """
    end
  end

  test "should show particular issue" do
    {:ok, creation_date, _} = DateTime.from_iso8601("2020-11-11T10:10:10.000Z")
    issue = %Jirino.Issue{
      key: "AA-777",
      type: "Bug",
      priority: "High",
      status: "In Development",
      creator: "Bob",
      summary: "First issue summary",
      description: "Here is the description",
      created: creation_date,
      assignee: "Tom"
    }

    with_mocks([
      {
        Jirino.RemoteCalls,
        [],
        [get_issue_by_key: fn key when key == "AA-123" -> [issue] end]
      },
      {
        IO,
        [],
        [puts: fn(_) -> nil end]
      }
    ]) do
      Jirino.main ["issue", "AA-123"]

      assert called IO.puts """
      AA-777 (Bug) - In Development :: 2020/11/11 10:10 :: Tom :: First issue summary
      Father: Bob, P/High
      ===[Description]===
      Here is the description\
      """
    end
  end

  test "should show active sprint issues" do
    {:ok, creation_date_1, _} = DateTime.from_iso8601("2020-11-11T10:10:10.000Z")
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

    {:ok, creation_date_2, _} = DateTime.from_iso8601("2020-10-10T10:10:10.000Z")
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
          [get_config: fn key when key == :project -> "Super Duper Project" end]
        },
        {
          Jirino.RemoteCalls,
          [],
          [get_active_sprint_issues: fn project when project == "Super Duper Project" -> [issue1, issue2] end]
        },
        {
          IO,
          [],
          [puts: fn(_) -> nil end]
        }
      ]) do
        Jirino.main ["sprint"]

        assert called IO.puts """
        In Development issues:
        AA-777 (Bug) - In Development :: 2020/11/11 10:10 :: Tom :: First issue summary

        In QA issues:
        BB-999 (Task) - In QA :: 2020/10/10 10:10 :: Simon :: Second issue summary

        """
      end
  end

  test "should show backlog issues" do
    {:ok, creation_date_1, _} = DateTime.from_iso8601("2020-11-11T10:10:10.000Z")
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

    {:ok, creation_date_2, _} = DateTime.from_iso8601("2020-10-10T10:10:10.000Z")
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
        [get_config: fn key when key == :project -> "Super Duper Project" end]
      },
      {
        Jirino.RemoteCalls,
        [],
        [get_backlog_bugs: fn project when project == "Super Duper Project" -> [issue1, issue2] end]
      },
      {
        IO,
        [],
        [puts: fn(_) -> nil end]
      }
    ]) do
      Jirino.main ["backlog", "bugs"]

      assert called IO.puts """
      AA-777 (Bug) - In Development :: 2020/11/11 10:10 :: Tom :: First issue summary
      BB-999 (Task) - In QA :: 2020/10/10 10:10 :: Simon :: Second issue summary\
      """
    end
  end
end
