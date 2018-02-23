defmodule Jirino.Utilities do
  @moduledoc """
    A module that contains some utility functions for Jirino.
  """

  @doc """
    Gets a Jirino configuration value by key. The configuration is defined in *config/config.exs*.

    ##Params
      - key: Atom The key of the configuration which value we want to get

    ##Examples
      Jirino.Utilities.get_config :jiraBaseUrl
  """
  def get_config(key) do
    case key do
      :team ->
        Application.get_env(:jirino, :team)
        |> String.split(",")

      _ ->
        Application.get_env(:jirino, key)
    end
  end

  @doc """
    Displays a progress bar in the terminal.
    Each time it's called with total < done it re-draws the bar.
    Once the total == done it draws the complete bar and 2 new lines.

    ##Params
      - done: Integer The amount of work that has been done
      - total: Integer The total amount of work to be done
      - magnification_factor: Integer The stretch factor that allows to "magnify" the bar

    ##Example
      iex> Jirino.Utilities.display_progress(1, 5, 2)
      "#{IO.ANSI.clear_line()}\\rLoading... [==        ]"

      iex> Jirino.Utilities.display_progress(5, 5)
      "#{IO.ANSI.clear_line()}\\rLoading... [=====] Done!\\n\\n"
  """
  def display_progress(done, total, magnification_factor \\ 1) do
    progress_text =
      IO.ANSI.clear_line() <>
        "\rLoading... [" <>
        String.duplicate("=", done * magnification_factor) <>
        String.duplicate(" ", (total - done) * magnification_factor) <> "]"

    if done == total do
      progress_text <> " Done!\n\n"
    else
      progress_text
    end
  end
end
