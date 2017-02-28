defmodule QuickBooks do
  @moduledoc """
  API client for QuickBooks Online.
  """

  @credential_config ~w(
    consumer_key
    consumer_secret
  )a

  @doc """
  Returns the configured OAuth credentials.
  """
  def credentials do
    for k <- @credential_config do
      case Application.get_env(:quickbooks, k) do
        v when is_binary(v) -> {k, v}
        nil                 -> raise_missing(k)
        _                   -> raise_invalid(k)
      end
    end
  end

  defp raise_missing(key) do
    raise "QuickBooks configuration value '#{key}' is required."
  end

  defp raise_invalid(key) do
    raise "QuickBooks configuration value '#{key}' is invalid."
  end
end
