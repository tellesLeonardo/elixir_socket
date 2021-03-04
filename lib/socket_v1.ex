defmodule SocketV1 do

  use Application
  import Supervisor.Spec, warn: false


  def start(_type, _args) do

    children = [

      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: SocketV1.Router,
        options: [ dispatch: dispatch(), port: 4000]
        ),

      Registry.child_spec( keys: :unique, name: Registry.SocketV1 )
    ]


    opts = [strategy: :one_for_one, name: SocketV1.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp dispatch do
    [
      {:_,
        [
          {"/", SocketV1.SocketHandler, []}
          # {:_, Plug.Cowboy.Handler, {SocketV1.Router, []}}
        ]
      }
    ]
  end
end
