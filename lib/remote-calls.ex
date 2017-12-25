
defmodule Jirino.RemoteCalls do

  def init do
    HTTPoison.start
  end

  @doc"""
    Fetches a given issue and fills the Jirino.Issue struct.
  """
  def get_issue(issue) do
    %HTTPoison.Response{body: body} = HTTPoison.get! get_url("/issue/#{issue}"), get_headers()

    {:ok, %{"fields" => fields, "key" => key}} = Poison.decode body

    %{
      "priority" => priority,
      "status" => status,
      "creator" => creator,
      "summary" => summary,
      "description" => description,
      "issuetype" => type
    } = fields

    %{"name" => priority_name} = priority
    %{"name" => status_name} = status
    %{"displayName" => creator_name} = creator
    %{"name" => type_name} = type

    %Jirino.Issue{
      key: key,
      priority: priority_name,
      status: status_name,
      creator: creator_name,
      summary: summary,
      description: description,
      type: type_name
    }
  end

  defp get_url(resource_path) do
    base_url = Application.get_env(:jirino, :jiraBaseUrl)

    "#{base_url}/rest/api/2#{resource_path}"
  end

  defp get_headers do
    username = Application.get_env(:jirino, :username)
    user_token = Application.get_env(:jirino, :token)
    auth_token = Base.encode64 "#{username}:#{user_token}"

    ["Authorization": "Basic #{auth_token}", "Accept": "Application/json; Charset=utf-8"]
  end

end
