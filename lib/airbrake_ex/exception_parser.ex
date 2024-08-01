defmodule AirbrakeEx.ExceptionParser do
  @moduledoc false

  alias AirbrakeEx.Utils

  def parse(exception, stacktrace \\ []) do
    filter_params = AirbrakeEx.Config.get(:airbrake_ex, :filter_parameters, [])
    filtered_exception = struct(exception.__struct__, Utils.filter(exception, filter_params))
    filtered_stacktrace = Utils.filter(stacktrace, filter_params)

    %{
      type: exception.__struct__,
      message: Exception.message(filtered_exception),
      backtrace: stacktrace(filtered_stacktrace)
    }
  end

  defp stacktrace(stacktrace) do
    Enum.map(stacktrace, fn
      {module, function, args, params} ->
        file = Keyword.get(params, :file)
        line_number = Keyword.get(params, :line, 0)

        function =
          if file do
            "#{function}#{args(args)}"
          else
            "#{module}.#{function}#{args(args)}"
          end

        file_path =
          if file do
            "(#{module}) #{file}"
          else
            "unknown"
          end

        %{
          file: file_path,
          line: line_number,
          function: function
        }
    end)
  end

  defp args(args) when is_integer(args) do
    "/#{args}"
  end

  defp args(args) when is_list(args) do
    "(#{args |> Enum.map(&inspect(&1)) |> Enum.join(", ")})"
  end
end
