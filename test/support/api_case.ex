defmodule QuickBooks.APICase do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
    end
  end

  alias QuickBooks.MockBackend
  alias QuickBooks.MockResponse

  def load_response(file, overrides \\ %{}) do
    %MockResponse{
      body: File.read!("test/fixtures/#{file}") |> String.strip,
      headers: [],
      status_code: 200
    } |> Map.merge(overrides)
  end

  defdelegate take_request, to: MockBackend
  defdelegate send_response(response), to: MockBackend
end
