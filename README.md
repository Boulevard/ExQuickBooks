# ExQuickBooks

[![Build Status][semaphore-badge]][semaphore]

**QuickBooks Online API client for Elixir.**

## Features

Everything is still a work in progress.

- OAuth 1.0a
- Data queries
- Item API
- Preferences API
- SalesReceipt API

## Installation

The package can be installed by adding `exquickbooks` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [{:exquickbooks, "~> 0.8.0"}]
end
```

The docs can be found at <https://hexdocs.pm/exquickbooks>.

## Development

1. Write tests.
2. Write code. Test with `mix test`.
3. See tests. See tests run. Run tests, run!

[semaphore]: https://semaphoreci.com/boulevard/exquickbooks
[semaphore-badge]: https://semaphoreci.com/api/v1/projects/19242d95-e2d6-4ef1-9fd3-85108a098b94/1200409/badge.svg
