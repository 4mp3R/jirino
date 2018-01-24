
defmodule Jirino.Utilities do

  def get_config(key) do
    case key do
      :team -> Application.get_env(:jirino, :team)
        |> String.split(",")
      _ -> Application.get_env(:jirino, key)
    end
  end

end
