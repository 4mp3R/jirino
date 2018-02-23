defmodule Jirino do
  @moduledoc """
    Main application module.
  """

  @help_message """
     __   _        _
     \\ \\ (_) _ __ (_) _ __    ___
      \\ \\| || '__|| || '_ \\  / _ \\
   /\\_/ /| || |   | || | | || (_) |
   \\___/ |_||_|   |_||_| |_| \\___/

   Jirino by codwizard[at]gmail[dot]com

   Usage:
   "team" - show the current team composition
   "team issues" - show the issues assigned to team members and make sure they're not twiddling their thumbs
   "issues" - shows all issues assigned to you
   "issues new" - shows recently created issues
   "issue ISSUE_KEY" - shows a summary for an issue
   "sprint" - show issues in current sprint
   "backlog bugs" - shows backlog bugs
   "open ISSUE_KEY" - open an issue page in the web browser
  """

  @doc """
    Main function called with command line arguments.
  """
  def main(["team", "issues"]), do: show_team_issues()
  def main(["team"]), do: show_team()

  def main(["issues", "new"]), do: show_new_issues()
  def main(["issues"]), do: show_my_issues()

  def main(["issue", key]), do: show_issue(key)

  def main(["sprint"]), do: show_active_sprint_issues()

  def main(["backlog", "bugs"]), do: show_backlog_bugs()

  def main(["open", key]), do: open_issue(key)

  def main(_), do: show_help_message()

  defp show_team do
    case Jirino.Utilities.get_config(:team) do
      empty when empty in [[], nil] ->
        IO.puts("The team has not been defined yet!")

      team ->
        team
        |> Enum.map(fn teammate -> "-> #{teammate}" end)
        |> Enum.join("\n")
        |> IO.puts()
    end
  end

  defp show_team_issues do
    chunks =
      Jirino.Utilities.get_config(:team)
      |> Jirino.RemoteCalls.get_issues_for_users()
      |> Enum.group_by(fn issue -> issue.assignee end)
      |> Enum.map(fn {user, issues} ->
        Enum.reduce(issues, "===[#{user}'s issues]===\n", fn issue, acc ->
          acc <> "#{Jirino.Issue.format_short(issue)}\n"
        end)
      end)

    chunks
    |> Enum.join("\n")
    |> IO.puts()
  end

  defp show_my_issues do
    Jirino.Utilities.get_config(:username)
    |> (fn user -> [user] end).()
    |> Jirino.RemoteCalls.get_issues_for_users()
    |> Enum.map(&Jirino.Issue.format_short/1)
    |> Enum.join("\n")
    |> IO.puts()
  end

  defp show_new_issues do
    Jirino.Utilities.get_config(:project)
    |> Jirino.RemoteCalls.get_latest_issues_for_project()
    |> Enum.map(&Jirino.Issue.format_short/1)
    |> Enum.join("\n")
    |> IO.puts()
  end

  defp show_issue(key) do
    key
    |> Jirino.RemoteCalls.get_issue_by_key()
    |> List.first()
    |> Jirino.Issue.format()
    |> IO.puts()
  end

  defp show_active_sprint_issues do
    Jirino.Utilities.get_config(:project)
    |> Jirino.RemoteCalls.get_active_sprint_issues()
    |> Enum.group_by(fn issue -> issue.status end)
    |> Enum.map(fn {status, issues_group} ->
      status_header = "#{status} issues:\n"

      issues_text =
        issues_group
        |> Enum.map(&Jirino.Issue.format_short/1)
        |> Enum.join("\n")

      status_header <> issues_text <> "\n\n"
    end)
    |> Enum.join("")
    |> IO.puts()
  end

  defp show_backlog_bugs do
    Jirino.Utilities.get_config(:project)
    |> Jirino.RemoteCalls.get_backlog_bugs()
    |> Enum.map(&Jirino.Issue.format_short/1)
    |> Enum.join("\n")
    |> IO.puts()
  end

  defp open_issue(key) do
    base_url = Jirino.Utilities.get_config(:jiraBaseUrl)
    {_, os_name} = :os.type()

    case os_name do
      :darwin -> System.cmd("open", ["#{base_url}/browse/#{key}"])
      :linux -> System.cmd("xdg-open", ["#{base_url}/browse/#{key}"])
      _ -> IO.puts("Sorry, your OS is not supported yet :(")
    end
  end

  defp show_help_message do
    IO.puts(@help_message)
  end
end
