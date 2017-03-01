defmodule QuickBooksTest do
  use ExUnit.Case, async: false

  doctest QuickBooks

  test "oauth_api/0 returns a URL" do
    assert QuickBooks.oauth_api |> String.starts_with?("https")
  end

  test "accounting_api/0 returns the sandbox URL by default" do
    Application.delete_env(:quickbooks, :use_production_api)

    assert QuickBooks.accounting_api |> String.starts_with?("https")
    assert QuickBooks.accounting_api |> String.contains?("sandbox")
  end

  test "accounting_api/0 returns the production URL in production" do
    Application.put_env(:quickbooks, :use_production_api, true)

    assert QuickBooks.accounting_api |> String.starts_with?("https")
    refute QuickBooks.accounting_api |> String.contains?("sandbox")
  end

  test "backend/0 returns the right module" do
    Application.put_env(:quickbooks, :backend, QuickBooks.MockBackend)
    assert QuickBooks.backend == QuickBooks.MockBackend
  end

  test "credentials/0 returns the right credentials" do
    Application.put_env(:quickbooks, :consumer_key, "key")
    Application.put_env(:quickbooks, :consumer_secret, "secret")

    assert QuickBooks.credentials == [
      consumer_key: "key",
      consumer_secret: "secret"
    ]
  end

  test "credentials/0 raises for missing credentials" do
    Application.delete_env(:quickbooks, :consumer_key)
    Application.delete_env(:quickbooks, :consumer_secret)

    assert_raise RuntimeError, &QuickBooks.credentials/0
  end

  test "credentials/0 raises for invalid credentials" do
    Application.put_env(:quickbooks, :consumer_key, 42)
    Application.put_env(:quickbooks, :consumer_secret, 42)

    assert_raise RuntimeError, &QuickBooks.credentials/0
  end
end
