defmodule QuickBooks do
  @moduledoc """
  API client for QuickBooks Online.
  """

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
  Returns the configured OAuth callback URL.
  """
  def callback_url do
    case get_env(@callback_config) do
      url when is_binary(url) -> url
      nil                     -> raise_missing(@callback_config)
      _                       -> raise_invalid(@callback_config)
    end
  end

  @doc """
  Returns the configured OAuth credentials.
  """
  def credentials do
    for k <- @credential_config do
      case get_env(k) do
        v when is_binary(v) -> {k, v}
        nil                 -> raise_missing(k)
        _                   -> raise_invalid(k)
      end
    end
  end

  defp get_env(key, default \\ nil) do
    Application.get_env(:quickbooks, key, default)
  end

  defp raise_missing(key) do
    raise "QuickBooks configuration value '#{key}' is required."
  end

  defp raise_invalid(key) do
    raise "QuickBooks configuration value '#{key}' is invalid."
  end
end
