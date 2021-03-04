defmodule SocketV1.SocketHandler do

  @behaviour :cowboy_websocket

  def init(request, _state) do
    request |> IO.inspect

    # [_elem1, number] = request.path_info
    state = %{registry_key: request.path,number: "number", pid: request.pid }

    {:cowboy_websocket, request, state, %{ :idle_timeout => 500_000_000_000, :inactivity_timeout => 500_000_000_000 } }

  end

  def websocket_init(state) do

    state |> IO.inspect

    # {:ok, _} = Registry.register(Registry.SocketV1, state.number, state)

    {:ok, state}
  end

  def websocket_handle({:text, json}, state) do
    payload = Jason.decode!(json)
    message = payload["data"]["message"]

    # Registry.SocketV1
    # |> Registry.dispatch(state.number, fn(entries) ->
    #   [{pid, _value}] = entries
    #     pid |> IO.inspect
    # #   for {pid, _} <- entries do
    # #     if pid != self() do
    #       Process.send(pid, message, [])
    # #     end
    # #   end
    # end)

    {:reply, {:text, message}, state}
  end

  def websocket_info(info, state) do
    {:reply, {:text, info}, state}
  end

  def via_tupla(id)  do
    {:via, Registry, {:number_register, id}}
  end

end
