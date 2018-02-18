# Jirino

## Setup instructions
- Clone the repo
- [Install](https://elixir-lang.org/install.html) Erlang and Elixir if you don't have them already
- Install the dependencies by running `mix deps.get`

## Build & install
- mix escript.build
- mix escript.install

In order to be able to run Jirino from anywhere in the console, please add the `~/.mix/escripts` in your *$PATH*.

## Configuration
Jirino must be configured before it can be used. It reads user's settings from the environment variables so you can change
them without rebuilding and reinstalling the escript.
Here are the environment variables to set:
- JIRINO_USERNAME : The username or email for your Jira user, like `bobby@gmail.com`.
- JIRINO_TOKEN : Your Atlassian API token that can be set up [here](https://id.atlassian.com/manage/api-tokens).
- JIRINO_BASE_URL : Your Jira's base URL, like `company.atlassian.net`.
- JIRINO_PROJECT : The name of the project you're working on, like `My Cool Project`.
- JIRINO_TEAM : The comma-separated list of names or emails of the members of your team, like: `bob@company.com,sam@company.com,sally@company.com`.

It might be handy creating a `.jirino` file in which you can set and export such environment variables and then load such a file
during the shell init with `source .jirino` (for example, from `.bashrc`).

## Usage
Run Jirino wihtout arguments to show the usage banner that'll list all the possible arguments and features :)

## Tests
You can run unit and doc tests with `mix test`

## Documentation
You can generate documentation for all modules and functions by running `mix docs`
