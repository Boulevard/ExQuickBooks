use Mix.Config

config :quickbooks,
  backend: QuickBooks.MockBackend,
  consumer_key: "key",
  consumer_secret: "secret",
  callback_url: "http://localhost/oauth/callback"
