defmodule Jirino do
  
  def token do
    Application.get_env(:jirino, :token)
  end

end
