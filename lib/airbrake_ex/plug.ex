defmodule AirbrakeEx.Plug do
  @moduledoc """
  Add the `AirbrakeEx.Plug` to you web application Plug stack
  to send all exceptions to `airbrake`

  ```elixir
  defmodule YourApp.Router do
    use Phoenix.Router
    use AirbrakeEx.Plug

    # ...
  end
  ```
  """

  alias AirbrakeEx.{ExceptionParser, Notifier}

  defmacro __using__(_env) do
    quote location: :keep do
      use Plug.ErrorHandler

      def handle_errors(conn, %{kind: :error, reason: exception, stack: stacktrace}) do
        exception = ExceptionParser.parse(exception, stacktrace)
        session = AirbrakeEx.Utils.detuple(conn.private[:plug_session])

        Notifier.notify(
          exception,
          params: conn.params,
          session: session,
          context: %{url: Plug.Conn.request_url(conn)}
        )
      end

      def handle_errors(_conn, _map), do: nil
    end
  end
end
