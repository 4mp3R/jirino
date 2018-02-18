  defmodule RemoteCallsTest do
  use ExUnit.Case
  import Mock

  test "should get issue by key" do
    with_mocks([
      {
        Jirino.Utilities,
        [],
        [get_config: fn
          key when key == :jiraBaseUrl -> "base_jira_url"
          key when key == :username -> "username"
          key when key == :token -> "secrettoken"
        end]
      },
      {
        HTTPoison,
        [],
        [get!: fn(url, headers, options) ->
          %HTTPoison.Response{
            body: """
            {
              "issues": [{
                "key": "XY-123",
                "fields": {
                  "summary": "Issue summary",
                  "created": "2020-10-10T11:22:33.000Z",
                  "priority": {
                    "name": "High Priority"
                  },
                  "status": {
                    "name": "In Code Review"
                  },
                  "creator": {
                    "displayName": "Agent Smith"
                  },
                  "issuetype": {
                    "name": "Bug"
                  },
                  "assignee": {
                    "name": "Sammy Black"
                  }
                }
              }],
              "startAt": 0,
              "maxResults": 1,
              "total": 1
            }
            """
          }
        end]
      }
    ]) do
      issue = Jirino.RemoteCalls.get_issue_by_key "XY-123"

      search_url = "base_jira_url/rest/api/2/search"
      search_headers = [
        "Authorization": "Basic " <> Base.encode64("username:secrettoken"),
        "Accept": "Application/json; Charset=utf-8"
      ]
      search_options = [
        params: [
          {"maxResults", 50},
          {"startAt", 0},
          {"jql", "key = \"XY-123\""},
          {"fields", "summary,priority,status,creator,issuetype,assignee,created"}
        ]
      ]

      assert called HTTPoison.get! search_url, search_headers, search_options

      {:ok, creation_date, _} = DateTime.from_iso8601("2020-10-10T11:22:33.000Z")
      assert issue == [%Jirino.Issue{
        key: "XY-123",
        summary: "Issue summary",
        created: creation_date,
        priority: "High Priority",
        status: "In Code Review",
        creator: "Agent Smith",
        type: "Bug",
        assignee: "Sammy Black"
      }]
    end
  end

  test "should get issues for user" do
  end

  test "should get issues created in the last week" do
  end

  test "should get bugs from the backlog" do
  end

  test "should get tickets from the active sprints" do
  end

  test "should handle paginated results" do
  end
end
