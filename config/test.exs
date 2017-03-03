use Mix.Config

config :exquickbooks,
  backend: ExQuickBooks.MockBackend,
  consumer_key: "key",
  consumer_secret: "secret",
  callback_url: "http://localhost/oauth/callback"
