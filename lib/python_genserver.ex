defmodule Krihelinator.PythonGenServer do
  use GenServer

  @moduledoc """
  Spins a python interpeter to do data analysis with pandas.
  """

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  ##### Callbacks #####

  def init([]) do
    :python.start_link(python_path: 'python')
  end

  def handle_call({:process, data}, _from, py_interpeter) do
    data = :python.call(py_interpeter, :analytics, :process, [data])
    {:reply, data, py_interpeter}
  end

  ##### Client side #####

  def process(languages, value_field) do
    languages
    |> Enum.flat_map(fn language ->
      for datum <- language.history do
        %{name: language.name,
          timestamp: datum.timestamp,
          value: Map.fetch!(datum, value_field)}
      end
    end)
    |> Poison.encode!()
    |> process_json()
  end

  def process_json("[]"), do: "[]"
  def process_json(json_data) do
    GenServer.call(__MODULE__, {:process, json_data})
  end
end
