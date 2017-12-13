defmodule Jirino do
  
  @help_message """
     __   _        _               
     \\ \\ (_) _ __ (_) _ __    ___  
      \\ \\| || '__|| || '_ \\  / _ \\ 
   /\\_/ /| || |   | || | | || (_) |
   \\___/ |_||_|   |_||_| |_| \\___/ 

   Jirino by codwizard[at]gmail[dot]com

   Usage:
   "issue ISSUE_KEY" - shows a summary for an issue
  """

  def main(args) do
    case args do
      ["issue", key] ->
        key
        |> Jirino.Api.RemoteCalls.get_issue
        |> Jirino.Api.Issue.format
        |> IO.puts
      _ ->
        IO.puts @help_message
    end 
  end

end
