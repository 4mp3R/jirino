
defmodule Jirino.Api.Issue do
  
  defstruct key: nil,
    type: nil,
    priority: nil,
    status: nil,
    creator: nil,
    summary: nil,
    description: nil

  def format(issue) do
    %Jirino.Api.Issue{
      key: key,
      type: type,
      priority: priority,
      status: status,
      creator: creator,
      summary: summary,
      description: description
      } = issue

    """
    #{key} (#{type}) - #{status} :: #{summary}
    Father: #{creator}
    ======
    #{description}
    """
  end

end
