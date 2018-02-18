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
        [get!: fn(_url, _headers, _options) ->
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
                  },
                  "description": "Issue description"
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
      issues = Jirino.RemoteCalls.get_issue_by_key "XY-123"

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
          {"fields", "summary,priority,status,creator,issuetype,assignee,created,description"}
        ]
      ]

      assert called HTTPoison.get! search_url, search_headers, search_options

      {:ok, creation_date, _} = DateTime.from_iso8601("2020-10-10T11:22:33.000Z")
      assert issues == [%Jirino.Issue{
        key: "XY-123",
        summary: "Issue summary",
        created: creation_date,
        priority: "High Priority",
        status: "In Code Review",
        creator: "Agent Smith",
        type: "Bug",
        assignee: "Sammy Black",
        description: "Issue description"
      }]
    end
  end

  test "should get issues for users" do
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
        [get!: fn(_url, _headers, _options) ->
          %HTTPoison.Response{
            body: """
            {
              "issues": [
                {
                  "key": "XY-123",
                  "fields": {
                    "summary": "Issue 123 summary",
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
                    },
                    "description": null
                  }
                },
                {
                  "key": "ZZ-777",
                  "fields": {
                    "summary": "Issue 777 summary",
                    "created": "2020-11-11T11:22:33.000Z",
                    "priority": {
                      "name": "Low Priority"
                    },
                    "status": {
                      "name": "In Development"
                    },
                    "creator": {
                      "displayName": "Blake Summers"
                    },
                    "issuetype": {
                      "name": "Story"
                    },
                    "assignee": {
                      "name": "Dean Green"
                    },
                    "description": null
                  }
                }
              ],
              "startAt": 0,
              "maxResults": 1,
              "total": 1
            }
            """
          }
        end]
      }
    ]) do
      issues = Jirino.RemoteCalls.get_issues_for_users ["user1@mail.com", "user2@mail.com"]

      search_url = "base_jira_url/rest/api/2/search"
      search_headers = [
        "Authorization": "Basic " <> Base.encode64("username:secrettoken"),
        "Accept": "Application/json; Charset=utf-8"
      ]
      search_options = [
        params: [
          {"maxResults", 50},
          {"startAt", 0},
          {"jql", "assignee = \"user1@mail.com\" OR assignee = \"user2@mail.com\""},
          {"fields", "summary,priority,status,creator,issuetype,assignee,created,description"}
        ]
      ]

      assert called HTTPoison.get! search_url, search_headers, search_options

      {:ok, creation_date1, _} = DateTime.from_iso8601("2020-10-10T11:22:33.000Z")
      {:ok, creation_date2, _} = DateTime.from_iso8601("2020-11-11T11:22:33.000Z")
      issue1 = %Jirino.Issue{
        key: "XY-123",
        summary: "Issue 123 summary",
        created: creation_date1,
        priority: "High Priority",
        status: "In Code Review",
        creator: "Agent Smith",
        type: "Bug",
        assignee: "Sammy Black"
      }
      issue2 = %Jirino.Issue{
        key: "ZZ-777",
        summary: "Issue 777 summary",
        created: creation_date2,
        priority: "Low Priority",
        status: "In Development",
        creator: "Blake Summers",
        type: "Story",
        assignee: "Dean Green"
      }
      assert issues == [issue1, issue2]
    end
  end

  test "should get issues created in the last week" do
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
        [get!: fn(_url, _headers, _options) ->
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
                  },
                  "description": null
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
      issues = Jirino.RemoteCalls.get_latest_issues_for_project "Super Duper Project"

      search_url = "base_jira_url/rest/api/2/search"
      search_headers = [
        "Authorization": "Basic " <> Base.encode64("username:secrettoken"),
        "Accept": "Application/json; Charset=utf-8"
      ]
      search_options = [
        params: [
          {"maxResults", 50},
          {"startAt", 0},
          {"jql", "project = \"Super Duper Project\" AND created >= -7d ORDER BY created DESC"},
          {"fields", "summary,priority,status,creator,issuetype,assignee,created,description"}
        ]
      ]

      assert called HTTPoison.get! search_url, search_headers, search_options

      {:ok, creation_date, _} = DateTime.from_iso8601("2020-10-10T11:22:33.000Z")
      assert issues == [%Jirino.Issue{
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

  test "should get bugs from the backlog" do
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
        [get!: fn(_url, _headers, _options) ->
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
                  },
                  "description": null
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
      issues = Jirino.RemoteCalls.get_backlog_bugs "Super Duper Project"

      search_url = "base_jira_url/rest/api/2/search"
      search_headers = [
        "Authorization": "Basic " <> Base.encode64("username:secrettoken"),
        "Accept": "Application/json; Charset=utf-8"
      ]
      search_options = [
        params: [
          {"maxResults", 50},
          {"startAt", 0},
          {"jql", "project = \"Super Duper Project\" AND issuetype = Bug AND resolution = Unresolved AND (Sprint = EMPTY OR Sprint not in (openSprints(), futureSprints())) ORDER BY created DESC"},
          {"fields", "summary,priority,status,creator,issuetype,assignee,created,description"}
        ]
      ]

      assert called HTTPoison.get! search_url, search_headers, search_options

      {:ok, creation_date, _} = DateTime.from_iso8601("2020-10-10T11:22:33.000Z")
      assert issues == [%Jirino.Issue{
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

  test "should get tickets from the active sprints" do
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
        [get!: fn(_url, _headers, _options) ->
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
                  },
                  "description": null
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
      issues = Jirino.RemoteCalls.get_active_sprint_issues "Super Duper Project"

      search_url = "base_jira_url/rest/api/2/search"
      search_headers = [
        "Authorization": "Basic " <> Base.encode64("username:secrettoken"),
        "Accept": "Application/json; Charset=utf-8"
      ]
      search_options = [
        params: [
          {"maxResults", 50},
          {"startAt", 0},
          {"jql", "project = \"Super Duper Project\" AND Sprint in openSprints() ORDER BY created DESC"},
          {"fields", "summary,priority,status,creator,issuetype,assignee,created,description"}
        ]
      ]

      assert called HTTPoison.get! search_url, search_headers, search_options

      {:ok, creation_date, _} = DateTime.from_iso8601("2020-10-10T11:22:33.000Z")
      assert issues == [%Jirino.Issue{
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

  test "should handle paginated results" do
    response_page_1 = %HTTPoison.Response{
      body: """
      {
        "issues": [{
          "key": "ZZ-111",
          "fields": {
            "summary": "First page issue",
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
            },
            "description": null
          }
        }],
        "startAt": 0,
        "maxResults": 1,
        "total": 2
      }
      """
    }
    response_page_2 = %HTTPoison.Response{
      body: """
      {
        "issues": [{
          "key": "ZZ-222",
          "fields": {
            "summary": "Second page issue",
            "created": "2020-11-11T11:22:33.000Z",
            "priority": {
              "name": "Low Priority"
            },
            "status": {
              "name": "In Development"
            },
            "creator": {
              "displayName": "Bob"
            },
            "issuetype": {
              "name": "Task"
            },
            "assignee": {
              "name": "Ron"
            },
            "description": null
          }
        }],
        "startAt": 1,
        "maxResults": 1,
        "total": 2
      }
      """
    }

    with_mocks([
      {
        Jirino.Utilities,
        [],
        [
          get_config: fn
            key when key == :jiraBaseUrl -> "base_jira_url"
            key when key == :username -> "username"
            key when key == :token -> "secrettoken"
          end,
          display_progress: fn(_loaded, _total, _factor) -> nil end
        ]
      },
      {
        HTTPoison,
        [],
        [get!: fn(_url, _header, options) ->
          {_, startIndex} = Enum.find(
            options[:params],
            fn({key, _}) -> key == "startAt" end
          )

          case startIndex do
            0 -> response_page_1
            1 -> response_page_2
          end
        end]
      }
    ]) do
        issues = Jirino.RemoteCalls.get_issues_for_users ["mrsmith@mail.com"]

        {:ok, creation_date1, _} = DateTime.from_iso8601("2020-10-10T11:22:33.000Z")
        {:ok, creation_date2, _} = DateTime.from_iso8601("2020-11-11T11:22:33.000Z")
        assert issues == [
          %Jirino.Issue{
            key: "ZZ-111",
            summary: "First page issue",
            created: creation_date1,
            priority: "High Priority",
            status: "In Code Review",
            creator: "Agent Smith",
            type: "Bug",
            assignee: "Sammy Black"
          },
          %Jirino.Issue{
            key: "ZZ-222",
            summary: "Second page issue",
            created: creation_date2,
            priority: "Low Priority",
            status: "In Development",
            creator: "Bob",
            type: "Task",
            assignee: "Ron"
          }
        ]
    end
  end
end
