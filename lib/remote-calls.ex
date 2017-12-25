
defmodule Jirino.RemoteCalls do

  def init do
    HTTPoison.start
  end

  @doc"""
    Fetches all the issues assigned to the given user and returns a list of Jirino.Issue structs.
  """
  def get_issues(username) do
    options = [
      params: [
        {"jql", "assignee = \"#{username}\""},
        {"fields", "summary,priority,status,creator,issuetype"}
      ]
    ]

    %HTTPoison.Response{body: body} = HTTPoison.get! get_url("/search"), get_headers(), options

    {:ok, %{"issues" => issues}} = Poison.decode body

    Enum.map issues, fn(%{
      "key" => key,
      "fields" => %{
        "summary" => summary,
        "priority" => %{
          "name" => priority_name
        },
        "status" => %{
          "name" => status_name
        },
        "creator" => %{
          "displayName" => creator_name
        },
        "issuetype" => %{
          "name" => type_name
        }
      }
    }) -> %Jirino.Issue{
      key: key,
      summary: summary,
      priority: priority_name,
      status: status_name,
      creator: creator_name,
      type: type_name
    } end
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
    base_url = Jirino.Utilities.get_config(:jiraBaseUrl)

    "#{base_url}/rest/api/2#{resource_path}"
  end

  defp get_headers do
    username = Jirino.Utilities.get_config(:username)
    user_token = Jirino.Utilities.get_config(:token)
    auth_token = Base.encode64 "#{username}:#{user_token}"

    ["Authorization": "Basic #{auth_token}", "Accept": "Application/json; Charset=utf-8"]
  end

end
