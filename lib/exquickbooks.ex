defmodule ExQuickBooks do
  @moduledoc """
  API client for QuickBooks Online.

  ## Configuration

  You can configure the application through `Mix.Config`:

  ```
  config :exquickbooks,
    consumer_key: "key",
    consumer_secret: "secret",
    use_production_api: true
  ```

  ### Accepted configuration keys

  #### `:consumer_key`, `:consumer_secret`

  Required. OAuth consumer credentials which you can get for your application
  at <https://developer.intuit.com/getstarted>.

  Please note that there are different credentials for the sandbox and
  production APIs.

  #### `:use_production_api`

  Optional, `false` by default. Set to `false` to use the QuickBooks Sandbox,
  `true` to connect to the production APIs.

  ### Reading environment variables

  If you store configuration in the system’s environment variables, you can
  have ExQuickBooks read them at runtime:

  ```
  config :exquickbooks,
    consumer_key: {:system, "EXQUICKBOOKS_KEY"},
    consumer_secret: {:system, "EXQUICKBOOKS_SECRET"}
  ```

  This syntax works for binary and boolean values. Booleans are parsed from
  `"true"` and `"false"`, otherwise the binary is used as is.
  """

  @backend_config :backend
  @credential_config [:consumer_key, :consumer_secret]
  @use_production_api_config :use_production_api
  @minorversion :minorversion
  @default_minorversion 12

  # Returns the Intuit OAuth API URL.
  @doc false
  def oauth_api do
    "https://oauth.intuit.com/oauth/v1/"
  end

  # Returns the QuickBooks Accounting API URL.
  @doc false
  def accounting_api do
    case get_env(@use_production_api_config, false) do
      url when is_binary(url) -> url
      true -> "https://quickbooks.api.intuit.com/v3/"
      false -> "https://sandbox-quickbooks.api.intuit.com/v3/"
    end
  end

  # Returns the configured HTTP backend.
  @doc false
  def backend do
    case get_env(@backend_config) do
      backend when is_atom(backend) ->
        backend

      nil ->
        raise_missing(@backend_config)

      other ->
        raise_invalid(@backend_config, other)
    end
  end

  # Returns the configured OAuth credentials.
  @doc false
  def credentials do
    for k <- @credential_config, into: %{} do
      case get_env(k) do
        v when is_binary(v) ->
          {k, v}

        nil ->
          raise_missing(k)

        v ->
          raise_invalid(k, v)
      end
    end
  end

  def minorversion do
    get_env(@minorversion, @default_minorversion)
  end

  # Returns a value from the application's environment. If the value matches
  # the {:system, ...} syntax, a system environment variable will be retrieved
  # instead and parsed.
  defp get_env(key, default \\ nil) do
    with {:system, var} <- Application.get_env(:exquickbooks, key, default) do
      case System.get_env(var) do
        "true" -> true
        "false" -> false
        value -> value
      end
    end
  end

  defp raise_missing(key) do
    raise ArgumentError,
      message: """
      ExQuickBooks config #{inspect(key)} is required.
      """
  end

  defp raise_invalid(key, value) do
    raise ArgumentError,
      message: """
      ExQuickBooks config #{inspect(key)} is invalid, got: #{inspect(value)}
      """
  end
end
