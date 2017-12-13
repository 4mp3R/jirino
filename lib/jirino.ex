defmodule Jirino do
  
  def main(args) do
    case args do
      ["issue", key] ->
        key
        |> Jirino.Api.RemoteCalls.get_issue
        |> Jirino.Api.Issue.format
        |> IO.puts
    end 
  end

end
