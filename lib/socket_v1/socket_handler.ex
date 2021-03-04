defmodule SocketV1.SocketHandler do

  @behaviour :cowboy_websocket

  def init(req, state) do
    IO.puts "modo avião"
    {:cowboy_websocket, req, state, %{ :idle_timeout => 500_000_000_000, :inactivity_timeout => 500_000_000_000,:max_connections =>  :infinity} }
  end

  def websocket_init(state) do
    IO.puts "websocket_init websocket_init"
    # state |> IO.inspect
    # {:ok, _} = Registry.register(Registry.SocketV1, state.number, state)

    {:ok, state}
  end

  def websocket_handle({:text, json}, state) do
    payload = Jason.decode!(json, keys: :atoms)

    (payload.event, payload)


    |> IO.inspect

    IO.puts "bondae"
    :timer.sleep(100_000)
    device = payload["command"]

    Registry.SocketV1
    |> Registry.register(device, {})

    {:reply, {:text, %{status: true, message: "authenticated"} |> Jason.encode!}, state}
  end


  defp handling_events() do

  end

  # def websocket_handle({:text, json}, state) do
  #   payload = Jason.decode!(json)
  #   message = payload["data"]["message"]
  #   # Registry.SocketV1
  #   # |> Registry.dispatch(state.registry_key, fn(entries) ->
  #   #   for {pid, _} <- entries do
  #   #     if pid != self() do
  #   #       Process.send(pid, message, [])
  #   #     end
  #   #   end
  #   # end)AppMon

  #   # %{url_media: "",url_contacts: "", status: }

  #   {:reply, {:text, "message"}, state}
  # end



  def websocket_info(info, state) do
    IO.puts "websocket_info "
    {:reply, {:text, info}, state}
  end

end
