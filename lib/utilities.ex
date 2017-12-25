
defmodule Jirino.Utilities do

  def get_config(key) do
    Application.get_env(:jirino, key)
  end

end
