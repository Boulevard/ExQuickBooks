defmodule ExQuickBooksTest do
  use ExUnit.Case, async: false

  doctest ExQuickBooks

  setup do
    old_env = get_all_env()
    old_system_env = System.get_env

    on_exit fn ->
      restore_env(old_env)
      restore_system_env(old_system_env)
    end
  end

  test "oauth_api/0 returns a URL" do
    assert ExQuickBooks.oauth_api |> String.starts_with?("https")
  end

  test "accounting_api/0 returns the sandbox URL by default" do
    delete_env :use_production_api

    assert ExQuickBooks.accounting_api |> String.starts_with?("https")
    assert ExQuickBooks.accounting_api |> String.contains?("sandbox")
  end

  test "accounting_api/0 returns the production URL in production" do
    put_env :use_production_api, true

    assert ExQuickBooks.accounting_api |> String.starts_with?("https")
    refute ExQuickBooks.accounting_api |> String.contains?("sandbox")
  end

  test "backend/0 returns the right module" do
    put_env(:backend, ExQuickBooks.MockBackend)
    assert ExQuickBooks.backend == ExQuickBooks.MockBackend
  end

  test "credentials/0 returns the right credentials" do
    put_env :consumer_key, "key"
    put_env :consumer_secret, "secret"

    assert ExQuickBooks.credentials == [
      consumer_key: "key",
      consumer_secret: "secret"
    ]
  end

  test "credentials/0 raises for missing credentials" do
    delete_env :consumer_key
    delete_env :consumer_secret

    assert_raise ArgumentError, &ExQuickBooks.credentials/0
  end

  test "credentials/0 raises for invalid credentials" do
    put_env :consumer_key, 42
    put_env :consumer_secret, 42

    assert_raise ArgumentError, &ExQuickBooks.credentials/0
  end

  test "{:system, ...} syntax is supported" do
    System.put_env %{
      "EXQUICKBOOKS_KEY" => "system_key",
      "EXQUICKBOOKS_SECRET" => "system_secret",
      "EXQUICKBOOKS_USE_PRODUCTION_API" => "true"
    }

    put_env :consumer_key, {:system, "EXQUICKBOOKS_KEY"}
    put_env :consumer_secret, {:system, "EXQUICKBOOKS_SECRET"}
    put_env :use_production_api, {:system, "EXQUICKBOOKS_USE_PRODUCTION_API"}

    assert ExQuickBooks.credentials == [
      consumer_key: "system_key",
      consumer_secret: "system_secret"
    ]

    # Production config flag should be parsed as a boolean
    refute ExQuickBooks.accounting_api |> String.contains?("sandbox")
  end

  defp get_all_env do
    Application.get_all_env(:exquickbooks)
  end

  defp put_env(key, value) do
    Application.put_env(:exquickbooks, key, value)
  end

  defp delete_env(key) do
    Application.delete_env(:exquickbooks, key)
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

  defp restore_system_env(old_env) do
    new_env = System.get_env

    for {k, _} <- new_env, do: System.delete_env(k)
    for {k, v} <- old_env, do: System.put_env(k, v)

    System.get_env == old_env || raise """
    Could not restore the system's environment. Check that you're not modifying
    it simultaneously in other tests. Those tests should specify
    `async: false`.
    """
  end
end
