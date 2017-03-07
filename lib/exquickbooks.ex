defmodule ExQuickBooks do
  @moduledoc """
  API client for QuickBooks Online.
  """

  @backend_config :backend
  @callback_config :callback_url
  @credential_config [:consumer_key, :consumer_secret]
  @use_production_api_config :use_production_api

  @doc """
  Returns the Intuit OAuth API URL.
  """
  def oauth_api do
    "https://oauth.intuit.com/oauth/v1/"
  end

  @doc """
  Returns the QuickBooks Accounting API URL.
  """
  def accounting_api do
    if get_env(@use_production_api_config, false) do
      "https://quickbooks.api.intuit.com/v3/"
    else
      "https://sandbox-quickbooks.api.intuit.com/v3/"
    end
  end

  @doc """
  Returns the configured HTTP backend.
  """
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

  @doc """
  Returns the configured OAuth callback URL.
  """
  def callback_url do
    case get_env(@callback_config) do
      url when is_binary(url) ->
        url
      nil ->
        raise_missing(@callback_config)
      other ->
        raise_invalid(@callback_config, other)
    end
  end

  @doc """
  Returns the configured OAuth credentials.
  """
  def credentials do
    for k <- @credential_config do
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

  # Returns a value from the application's environment. If the value matches
  # the {:system, ...} syntax, a system environment variable will be retrieved
  # instead and parsed.
  defp get_env(key, default \\ nil) do
    with {:system, var} <- Application.get_env(:exquickbooks, key, default) do
      case System.get_env(var) do
        "true"  -> true
        "false" -> false
         value  -> value
      end
    end
  end

  defp raise_missing(key) do
    raise ArgumentError, message: """
    ExQuickBooks config #{inspect(key)} is required.
    """
  end

  defp raise_invalid(key, value) do
    raise ArgumentError, message: """
    ExQuickBooks config #{inspect(key)} is invalid, got: #{inspect(value)}
    """
  end
end
