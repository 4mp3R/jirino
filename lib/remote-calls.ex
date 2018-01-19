
defmodule Jirino.RemoteCalls do

  def init do
    HTTPoison.start
  end


  defp get_issues(jql) do
    options = [
      params: [
        {"jql", jql},
        {"fields", "summary,priority,status,creator,issuetype,assignee,created"}
      ]
    ]

    %HTTPoison.Response{body: body} = HTTPoison.get! get_url("/search"), get_headers(), options

    {:ok, %{"issues" => issues}} = Poison.decode body

    Enum.map issues, fn(%{
      "key" => key,
      "fields" => %{
        "summary" => summary,
        "created" => created_iso_date_string,
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
        },
        "assignee" => assignee
      }
    }) ->
      assignee_name = case assignee do
        nil -> nil
        assignee ->
          %{"name" => assignee_name} = assignee
          assignee_name
      end

      { :ok, created, _ } = DateTime.from_iso8601(created_iso_date_string)

      %Jirino.Issue{
      key: key,
      summary: summary,
      created: created,
      priority: priority_name,
      status: status_name,
      creator: creator_name,
      type: type_name,
      assignee: assignee_name
    }
    end
  end

  @doc"""
    Gets Jira issues for a given user.
  """
  def get_issues_for_user(user) do
    get_issues("assignee = \"#{user}\"")
  end

  @doc"""
    Gets Jira issues created in the past week.
  """
  def get_latest_issues_for_project(project) do
    get_issues("project = \"#{project}\" AND created >= -7d ORDER BY created DESC")
  end

  @doc"""
    Gets the bugs that are in the backlog.
  """
  def get_backlog_bugs(project) do
    get_issues("project = \"#{project}\" AND issuetype = Bug AND resolution = Unresolved AND (Sprint = EMPTY OR Sprint not in (openSprints(), futureSprints())) ORDER BY created DESC")
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
