defmodule AirbrakeEx.ExceptionParser do
  @moduledoc false

  alias AirbrakeEx.Utils

  def parse(exception, stacktrace \\ []) do
    filter_params = AirbrakeEx.Config.get(:airbrake_ex, :filter_parameters, [])
    filtered_exception = struct(exception.__struct__, Utils.filter(exception, filter_params))

    %{
      type: exception.__struct__,
      message: Exception.message(filtered_exception),
      backtrace: stacktrace(stacktrace, filter_params)
    }
  end

  defp stacktrace(stacktrace, filter_params) do
    Enum.map(stacktrace, fn
      {module, function, args, params} ->
        file = Keyword.get(params, :file)
        line_number = Keyword.get(params, :line, 0)
        filtered_args = args(args, filter_params)

        function =
          if file do
            "#{function}#{filtered_args}"
          else
            "#{module}.#{function}#{filtered_args}"
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

  defp args(args, _) when is_integer(args) do
    "/#{args}"
  end

  defp args(args, filter_params) when is_list(args) do
    "(#{args |> Enum.map(&inspect(Utils.filter(&1, filter_params))) |> Enum.join(", ")})"
  end
end
