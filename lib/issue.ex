
defmodule Jirino.Issue do
  @moduledoc """
    Defines a struct that represents a Jira issue and contains some basic info about it.
    It also exposes some methods to format such a struct in a human-friendly format.
  """

  defstruct key: nil,
    type: nil,
    priority: nil,
    status: nil,
    creator: nil,
    summary: nil,
    description: nil,
    created: nil,
    assignee: nil

  @doc """
    Formats a given struct in a short human-readable form.

    ##Params
      - issue: Jirino.Issue the issues struct that we want to format.

    ##Examples
      iex> date = %DateTime{ year: 2020, month: 2, day: 29, zone_abbr: "AMT", hour: 22, minute: 11, second: 7, microsecond: {0, 0}, utc_offset: -14400, std_offset: 0, time_zone: "America/Manaus" }
      ...> issue = %Jirino.Issue{ key: "KK-123", type: "Bug", status: "In Code Review", summary: "Summary here", created: date, assignee: "bob@mail.com" }
      ...> Jirino.Issue.format_short issue
      "KK-123 (Bug) - In Code Review :: 2020/02/29 22:11 :: bob@mail.com :: Summary here"

      iex> date = %DateTime{ year: 2020, month: 2, day: 29, zone_abbr: "AMT", hour: 22, minute: 11, second: 7, microsecond: {0, 0}, utc_offset: -14400, std_offset: 0, time_zone: "America/Manaus" }
      ...> issue = %Jirino.Issue{ key: "KK-123", type: "Bug", status: "In Code Review", summary: "Summary here", created: date, assignee: nil }
      ...> Jirino.Issue.format_short issue
      "KK-123 (Bug) - In Code Review :: 2020/02/29 22:11 :: Summary here"
  """
  def format_short(issue) do
    %Jirino.Issue{
      key: key,
      type: type,
      status: status,
      summary: summary,
      created: created,
      assignee: assignee
      } = issue

      formatted_date = Momento.format(created, "YYYY/MM/DD HH:mm")

      assignee_string = case assignee do
        nil -> ""
        assignee -> " :: " <> assignee
      end

      "#{key} (#{type}) - #{status} :: #{formatted_date}#{assignee_string} :: #{summary}"
  end

  @doc """
    Formats a given struct in a human-readable form.

    ##Params
      - issue: Jirino.Issue the issues struct that we want to format.

    ##Examples
      iex> date = %DateTime{ year: 2020, month: 2, day: 29, zone_abbr: "AMT", hour: 22, minute: 11, second: 7, microsecond: {0, 0}, utc_offset: -14400, std_offset: 0, time_zone: "America/Manaus" }
      ...> issue = %Jirino.Issue{ key: "KK-123", type: "Bug", status: "In Code Review", summary: "Summary here", created: date, assignee: "bob@mail.com", priority: "Critical", creator: "sam@mail.com" }
      ...> Jirino.Issue.format issue
      "KK-123 (Bug) - In Code Review :: 2020/02/29 22:11 :: bob@mail.com :: Summary here\\nFather: sam@mail.com, P/Critical"

      iex> date = %DateTime{ year: 2020, month: 2, day: 29, zone_abbr: "AMT", hour: 22, minute: 11, second: 7, microsecond: {0, 0}, utc_offset: -14400, std_offset: 0, time_zone: "America/Manaus" }
      ...> issue = %Jirino.Issue{ key: "KK-123", type: "Bug", status: "In Code Review", summary: "Summary here", created: date, assignee: "bob@mail.com", priority: "Critical", creator: "sam@mail.com", description: "Description here" }
      ...> Jirino.Issue.format issue
      "KK-123 (Bug) - In Code Review :: 2020/02/29 22:11 :: bob@mail.com :: Summary here\\nFather: sam@mail.com, P/Critical\\n===[Description]===\\nDescription here\\n"
  """
  def format(issue) do
    %Jirino.Issue{description: description} = issue

    case description do
      nil -> format_summary(issue)
      _ -> format_summary_and_description(issue)
    end
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
    \n===[Description]===
    #{description}
    """
  end

end
