
defmodule Jirino.Issue do

  defstruct key: nil,
    type: nil,
    priority: nil,
    status: nil,
    creator: nil,
    summary: nil,
    description: nil

  def format(issue) do
    %Jirino.Issue{description: description} = issue

    case description do
      nil -> format_summary(issue)
      _ -> format_summary_and_description(issue)
    end
  end

  def format_short(issue) do
    %Jirino.Issue{
      key: key,
      type: type,
      status: status,
      summary: summary
      } = issue

      "#{key} (#{type}) - #{status} :: #{summary}"
  end

  defp format_summary(issue) do
    %Jirino.Issue{
      creator: creator,
      priority: priority
    } = issue

    format_short(issue) <> "\nFather: #{creator}, P/#{priority}"
  end

  defp format_summary_and_description(issue) do
    %Jirino.Issue{description: description} = issue

    format_summary(issue) <> """
    ===[Description]===
    #{description}
    """
  end

end
