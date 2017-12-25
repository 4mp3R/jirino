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
   "issue ISSUE_KEY" - shows a summary for an issue
  """

  def main(args) do
    case args do
      ["team"] -> show_team()
      ["issue", key] -> show_issue(key)
      _ -> show_help_message()
    end
  end

  defp show_team do
    case Application.get_env(:jirino, :team) do
      empty when empty in [[], nil] ->
        IO.puts "The team has not been defined yet!"
      team ->
        team
        |> Enum.map(fn(teammate) -> "-> #{teammate}\n" end)
        |> IO.puts
    end
  end

  defp show_issue(key) do
    key
    |> Jirino.Api.RemoteCalls.get_issue
    |> Jirino.Api.Issue.format
    |> IO.puts
  end

  defp show_help_message do
    IO.puts @help_message
  end

end
