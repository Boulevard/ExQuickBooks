defmodule QuickBooksTest do
  use ExUnit.Case, async: false

  doctest QuickBooks

  setup do
    old_env = get_all_env()

    on_exit fn ->
      restore_env(old_env)
    end
  end

  test "oauth_api/0 returns a URL" do
    assert QuickBooks.oauth_api |> String.starts_with?("https")
  end

  test "accounting_api/0 returns the sandbox URL by default" do
    delete_env(:use_production_api)

    assert QuickBooks.accounting_api |> String.starts_with?("https")
    assert QuickBooks.accounting_api |> String.contains?("sandbox")
  end

  test "accounting_api/0 returns the production URL in production" do
    put_env(:use_production_api, true)

    assert QuickBooks.accounting_api |> String.starts_with?("https")
    refute QuickBooks.accounting_api |> String.contains?("sandbox")
  end

  test "backend/0 returns the right module" do
    put_env(:backend, QuickBooks.MockBackend)
    assert QuickBooks.backend == QuickBooks.MockBackend
  end

  test "credentials/0 returns the right credentials" do
    put_env(:consumer_key, "key")
    put_env(:consumer_secret, "secret")

    assert QuickBooks.credentials == [
      consumer_key: "key",
      consumer_secret: "secret"
    ]
  end

  test "credentials/0 raises for missing credentials" do
    delete_env(:consumer_key)
    delete_env(:consumer_secret)

    assert_raise RuntimeError, &QuickBooks.credentials/0
  end

  test "credentials/0 raises for invalid credentials" do
    put_env(:consumer_key, 42)
    put_env(:consumer_secret, 42)

    assert_raise RuntimeError, &QuickBooks.credentials/0
  end

  defp get_all_env do
    Application.get_all_env(:quickbooks)
  end

  defp put_env(key, value) do
    Application.put_env(:quickbooks, key, value)
  end

  defp delete_env(key) do
    Application.delete_env(:quickbooks, key)
  end

  defp restore_env(old_env) do
    new_env = get_all_env()

    for {k, _} <- new_env, do: delete_env(k)
    for {k, v} <- old_env, do: put_env(k, v)

    get_all_env() == old_env || raise """
    Could not restore the application's environment. Check that you're not
    modifying it simultaneously in other tests. Those tests should specify
    `async: false`.
    """
  end
end
