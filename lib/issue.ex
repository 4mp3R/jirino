
defmodule Jirino.Issue do

  defstruct key: nil,
    type: nil,
    priority: nil,
    status: nil,
    creator: nil,
    summary: nil,
    description: nil,
    created: nil,
    assignee: nil

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
      summary: summary,
      created: created,
      assignee: assignee
      } = issue

      formatted_date = Momento.format(created, "YYYY/MM/DD HH:MM")

      assignee_string = case assignee do
        nil -> ""
        assignee -> " :: " <> assignee
      end

      "#{key} (#{type}) - #{status} :: #{formatted_date}#{assignee_string} :: #{summary}"
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
