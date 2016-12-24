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

  def process(json_data) do
    GenServer.call(__MODULE__, {:process, json_data})
  end
end
