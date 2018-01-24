# Jirino

## Setup instructions
- Create a secret config file `cp config/secret.exs.dist config/secret.exs`
- Put in the token value taken from the `cloud.session.token`

## Build & install
- mix escript.build
- mix escript.install

In order to be able to run Jirino from anywhere in the console, please add the `~/.mix/escripts` in your *$PATH*.

## Configuration
Jirino to be configured before it can be used. It read user settings from the invironment variables so you can change
them without rebuilding and reinstalling the escript.
Here are the environment variables to set:
- JIRINO_USERNAME : The username or email for your Jira user, like `bobby@gmail.com`.
- JIRINO_TOKEN : Your Atlassian API token that can be set up [here](https://id.atlassian.com/manage/api-tokens).
- JIRINO_BASE_URL : Your Jira's base URL, like `company.atlassian.net`.
- JIRINO_PROJECT : The name of the project you're working on, like `My Cool Project`.
- JIRINO_TEAM : The comma-separated list of names or emails of the members of your team, like: `bob@company.com,sam@company.com,sally@company.com`.

## Usage
Run Jirino wihtout arguments to show the usage banner that'll list all the possibile arguments and features :)
