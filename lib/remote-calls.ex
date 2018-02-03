
defmodule Jirino.RemoteCalls do

  def init do
    HTTPoison.start
  end

  defp get_issues(jql, startAt \\ 0) do
    options = [
      params: [
        {"maxResults", 50},
        {"startAt", startAt},
        {"jql", jql},
        {"fields", "summary,priority,status,creator,issuetype,assignee,created"}
      ]
    ]

    response = try do
      HTTPoison.get! get_url("/search"), get_headers(), options
    rescue
      error in HTTPoison.Error ->
        IO.puts "[!] Netowrk Error: " <> HTTPoison.Error.message(error)
        Process.exit self(), :normal
    end

    %HTTPoison.Response{body: body} = response

    {
      :ok,
      %{
        "issues" => issues,
        "startAt" => startIndex,
        "maxResults" => resultsPerPage,
        "total" => total
      }
    } = Poison.decode body

    issues = Enum.map issues, fn(%{
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

    pages_loaded = div(startIndex, resultsPerPage) + 1
    total_pages = div(total, resultsPerPage) + 1

    if total_pages > 1 do
      Jirino.Utilities.display_progress(pages_loaded, total_pages, 4)
    end

    issues = case pages_loaded < total_pages do
      true -> issues ++ get_issues(jql, startIndex + resultsPerPage)
      false -> issues
    end

    issues
  end

  @doc"""
    Get detatils of a Jira ticket by its key.
  """
  def get_issue_by_key(issue_key) do
    get_issues("key = \"#{issue_key}\"")
  end

  @doc"""
    Gets Jira issues for a given user.
  """
  def get_issues_for_users(users) do
    users
    |> Enum.map(fn(user) -> "assignee = \"#{user}\"" end)
    |> Enum.join(" OR ")
    |> get_issues
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
    Gets the tickets that are in the active sprints.
  """
  def get_active_sprint_issues(project) do
    get_issues("project = \"#{project}\" AND Sprint in openSprints() ORDER BY created DESC")
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
