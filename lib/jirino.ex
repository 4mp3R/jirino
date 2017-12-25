defmodule Jirino do

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
   "issue ISSUE_KEY" - shows a summary for an issue
  """

  def main(args) do
    case args do
      ["team"] -> show_team()
      ["team", "issues"] -> show_team_issues()
      ["issues"] -> show_my_issues()
      ["issue", key] -> show_issue(key)
      _ -> show_help_message()
    end
  end

  defp show_team do
    case Jirino.Utilities.get_config(:team) do
      empty when empty in [[], nil] ->
        IO.puts "The team has not been defined yet!"
      team ->
        team
        |> Enum.map(fn(teammate) -> "-> #{teammate}\n" end)
        |> IO.puts
    end
  end

  defp show_team_issues do
    Jirino.Utilities.get_config(:team)
    |> Enum.map(fn(teammate) -> {teammate, Jirino.RemoteCalls.get_issues(teammate)} end)
    |> Enum.map(fn({teammate, issues}) -> Enum.reduce(
      issues,
      "\n===[#{teammate}'s issues]===\n",
      fn(issue, acc) -> acc <> "#{Jirino.Issue.format_short(issue)}\n" end)
    end)
    |> IO.puts
  end

  defp show_my_issues do
    Jirino.Utilities.get_config(:username)
    |> Jirino.RemoteCalls.get_issues
    |> Enum.map(fn(issue) -> "#{Jirino.Issue.format(issue)}\n" end)
    |> IO.puts
  end

  defp show_issue(key) do
    key
    |> Jirino.RemoteCalls.get_issue
    |> Jirino.Issue.format
    |> IO.puts
  end

  defp show_help_message do
    IO.puts @help_message
  end

end
