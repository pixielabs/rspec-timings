# RSpec-timings

Collect RSpec test results with a view to catching new performance issues as
they're introduced.

## Requirements

* Ruby 3.1.4
* Rails 6

## Getting started

There's two parts to storing test results with rspec-timings:

1. You'll need this app deployed somewhere, e.g. on Heroku, and a project set up
in it corresponding to the app you're monitoring.
2. In the app you wish to monitor, you'll need to add an extra step in your
CI to send the test results to rspec-timings.

## Running locally

#### Setup credentials

Generate new credentials and set the secret_key_base:

```bash
rails credentials:edit
```

#### Install Dependencies

```
bundle install
yarn
```

#### Setup Database

```
# create an empty database
bundle exec rails db:create
```

#### Start App
```
foreman start
```

Everything in rspec-timings is behind [Balrog](https://github.com/pixielabs/balrog/).
In test and development, the password is 'password' (see `config/initializers/balrog.rb`).

Once you have generated the balrog password hash, update the `.env`

### Setting up a project

## Setup credentials

Generate new credentials and set the secret_key_base:

```bash
rails secret # to be copied into credentials
rails credentials:edit
```

Once your rspec-timings app is deployed, you'll need to login with the password you created using Balrog.
Create a new project for the app you wish to monitor, and note the
project UID as you'll need it to send the test results.

## Viewing Summary Reports for Pull Requests on GitHub

To view a summary of the top five most significant changes in your tests for
each pull request, you need to set up a GitHub App. This app will have
permission to monitor your repository and automatically generate summary
reports for your pull requests.

First, set up a [Github App](https://docs.github.com/en/apps/creating-github-apps/about-creating-github-apps/about-creating-github-apps).

The webhook url is `https://your-deployed-rspec-timings-app.com/webhooks/github`

Configure the following permissions:

* Commit statuses -> Read and write
* Pull requests -> Read and write

Second, install the Github App on the repository you wish to monitor.

As part of this, you will get a Github private key, which you should add to
your `.env`. You can copy `.env.sample` to `.env` to see the required variables.

* `GITHUB_APP_ID`
* `GITHUB_PRIVATE_KEY`

### Sending test results

In addition to the test results, you will need the project UID, branch name and
commit number. The test results should be sent as XML formatted by
[rspec_junit_formatter](https://github.com/sj26/rspec_junit_formatter).

With your test results saved as XML, e.g. in `/tmp/test-results/rspec.xml`, you
can then add a simple curl request to your CI config:

```
curl https://your-deployed-rspec-timings-app.com/project/{project_uid}/test_runs \
-F file=@/tmp/test-results/rspec.xml \
-F branch=BRANCH \
-F commit=COMMIT
```
