defmodule QuickBooksTest do
  use ExUnit.Case
  doctest QuickBooks

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
