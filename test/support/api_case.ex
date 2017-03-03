defmodule ExQuickBooks.APICase do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
    end
  end

  alias ExQuickBooks.MockBackend
  alias ExQuickBooks.MockResponse

  def http_200_response do
    %MockResponse{
      body: "",
      headers: [],
      status_code: 200
    }
  end

  def http_400_response do
    %MockResponse{
      body: "400 Bad Request",
      headers: [],
      status_code: 400
    }
  end

  def load_response(file) do
    %MockResponse{
      body: "test/fixtures/#{file}" |> File.read! |> String.strip,
      headers: [],
      status_code: 200
    }
  end

  defdelegate take_request, to: MockBackend
  defdelegate send_response(response), to: MockBackend
end
