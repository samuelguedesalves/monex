# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :monex,
  ecto_repos: [Monex.Repo]

# Configure the repo table key type
config :monex, Monex.Repo,
  migration_primary_key: [type: :binary_id],
  migration_foreign_key: [type: :binary_id]

# Guardian configs
config :monex, Monex.AuthGuardian,
  issuer: "monex",
  secret_key:
    System.get_env(
      "GUARDIAN_SECRET",
      "7sip0WNndEEd9SrDQDS+8MX7g/LCUJQxteYUrxzh0c9NJp+pwMqpGvdKu4pFqqro"
    )


# Configures the endpoint
config :monex, MonexWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: MonexWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Monex.PubSub,
  live_view: [signing_salt: "rIpzuFNW"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
