
defmodule Jirino.Utilities do

  @doc"""

  """
  def get_config(key) do
    case key do
      :team -> Application.get_env(:jirino, :team)
        |> String.split(",")
      _ -> Application.get_env(:jirino, key)
    end
  end

  @doc"""

  """
  def display_progress(done, total, magnification_factor \\ 1) do
    IO.write(
      IO.ANSI.clear_line
      <> "\rLoading... ["
      <> String.duplicate("=", done * magnification_factor)
      <> String.duplicate(" ", (total - done) * magnification_factor)
      <> "]"
    )

    if done == total do
      IO.write(" Done!\n\n")
    end
  end

end
