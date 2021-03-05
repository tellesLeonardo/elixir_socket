defmodule SocketV1.SocketHandler do
  @behaviour :cowboy_websocket

  alias SocketV1.Helper
  require Logger

  def init(req, state), do: {:cowboy_websocket, req, state, %{ :idle_timeout => 500_000, :inactivity_timeout => 500_000,:max_connections =>  :infinity} }

  def websocket_init(state), do: {:ok, state}

  def websocket_handle({:text, json}, state) do
    message_event =
      Jason.decode!(json, keys: :atoms)
      |> handling_events()

    {:reply, {:text, message_event}, state}
  end

  def websocket_handle(:ping, state) do
    {:reply, {:text, %{message: "pong"} |> Jason.encode! }, state}
  end


  def handling_events(%{event: "auth",command: data}) do
    Logger.info("evento de AUTH do canal #{data.number} iniciado")

    %{ number: data.number, data_info: %{ business: data.business,dedicated: data.dedicated , group: data.group, leads: data.leads, typeAuth: data.typeAuth, stalker: data.stalker } }
    |> Jason.encode!
    |> Logger.info()

    registry_channel(data.number,data)

    %{status: true, message: "authenticated"} |> Jason.encode!
  end


  def handling_events(%{event: "start_response"}) do
    Logger.info("evento: start_response | foi recebido")

    %{ event: "auth", response: %{ status: true, url_media: "uploadLink", url_contacts: "backUpLink" ,message: "connected"}  } |> Jason.encode!
  end

  def handling_events(%{event: "status_message"} = _data) do

    # data |> IO.inspect

    %{ event: "status_message", status: true } |> Jason.encode!
  end

  def handling_events(%{event: "response_message",response: response} = data) do

    Logger.info("event: response_message | recebido do canal #{data.from} as #{response.timestamp} para o canal #{response.from} hash_id #{response.hash_id} ")

    [number_contact, _whatsapp] = String.split(response.from, "@")


    msg =
    case response.data |> String.trim do
      "waifu" ->
        "olá minha waifu venha ser feliz e me de um abraço"

      "1" ->
        "isso pode até ser um teste, mas eu to com força de 100 leões\n\n\n#{Timex.now()}"

      "2" ->
        "sem recados para vc meu amigo\n\n\n#{Timex.now()}"

      "*" ->
        "olá meu consagrado foi finalizado tua comunicação\n\n\n#{Timex.now()}"

      _resp ->
        "canal de teste *CocadaBot* , para navegar entre as oes, selecione um dos menus abaixo:\n\n1 -  Falar com Atendente\n2 -  Deixar um Recado\n* -  Finalizar Atendimento\n\n\n#{Timex.now()}"

    end

    identifier = "#{Timex.now() |> Timex.to_unix()}-#{Helper.random_string(7)}"

    %{
      event: "send_message",
      command: %{
         from: data.from,
         to: number_contact,
         type: "text",
         message: msg,
         campaign: false,
         id: identifier,
         emoji: true,
         intent: true
      },
      data: Timex.now(),
      micro: "0.68281800 1613588974"
    } |> Jason.encode!
  end


  def handling_events(data) do
    # Logger.info("evento #{evt} foi recebido")
      IO.puts "mitica"
      data |> IO.inspect

    # %{ event: "auth", status: true, message: "connected", url_media: "url", url_contacts: "url"	}
    %{} |> Jason.encode!
  end


  def websocket_info(info, state) do
    IO.puts "websocket_info "
    {:reply, {:text, info}, state}
  end

  def registry_channel(number,data \\ []) do
    Registry.SocketV1
    |> Registry.register(number, data)
  end

  def send_event(key,event) do
    Registry.SocketV1
    |> Registry.dispatch(key, fn(value) ->
      [{pid, _value}] = value
      pid |> IO.inspect
      Process.send(pid,event,[])
    end)
  end

  def terminate(_reason, _req, _state) do
    Logger.info("conexão do socket fechada")
    :ok
  end

end
