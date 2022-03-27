defmodule CacheMe.Cache.Compile do
  @moduledoc false
  import CacheMe.AST, only: [strip_defaults: 1]

  defp hash(payload), do: :crypto.hash(:md5, payload)

  def set(module, name, args, value) do
    Code.compiler_options(ignore_module_conflict: true)

    Code.compile_quoted(
      quote do
        defmodule unquote(module) do
          @moduledoc false

          @doc false
          def unquote(name)(unquote_splicing(args)), do: unquote(Macro.escape(value))
        end
      end
    )

    Code.compiler_options(ignore_module_conflict: false)

    value
  end

  def generate(module, kind, name, args, _opts) do
    fingerprint =
      {module, kind, name, Enum.count(args)}
      |> :erlang.term_to_binary()
      |> hash()
      |> Base.encode16(case: :upper)

    cache = Module.concat(CacheMe.Caches, fingerprint)
    original = :"__cached_#{name}"
    stripped = strip_defaults(args)

    quote do
      defdelegate unquote(name)(unquote_splicing(args)), to: unquote(cache)

      defmodule unquote(cache) do
        @moduledoc false

        @doc false
        def unquote(name)(unquote_splicing(stripped)) do
          unquote(__MODULE__).set(
            unquote(cache),
            unquote(name),
            [unquote_splicing(stripped)],
            unquote(module).unquote(original)(unquote_splicing(stripped))
          )
        end
      end
    end
  end

  ### Management ###
  use GenServer

  def create(table, opts \\ [:named_table, :set, :public, read_concurrency: true])
  def create(table, opts), do: GenServer.call(__MODULE__, {:create, table, opts})

  def start_link(opts \\ [])
  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  @impl GenServer
  def init(opts)
  def init(_), do: {:ok, []}

  @impl GenServer
  def handle_call({:create, name, opts}, _from, tables) do
    if name in tables do
      {:reply, :ok, tables}
    else
      :ets.new(name, opts)
      {:reply, :ok, [name | tables]}
    end
  end

  @impl GenServer
  def handle_info({:ttl, name, key}, tables) do
    :ets.delete(name, key)
    {:noreply, tables}
  end
end
