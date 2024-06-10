defmodule POPWeb.CollectionLive do
  use POPWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.back navigate={~p"/"}>Home</.back>

    <.header>
      Collection Items Optimistic Updates
      <:subtitle>
        The example includes list of items that can be deleted. The deletion can be done with or without optimistic updates. If the "Failures" checkbox is checked, the deletion will fail randomly. If the "Throttling" checkbox is checked, the deletion will take between 1 and 2 seconds to complete. We recover from the failure by showing a flash message and un-hiding the item that failed to delete.
      </:subtitle>
    </.header>

    <div class="mx-auto mt-8 w-full max-w-md">
      <div class="flex justify-between text-xs uppercase">
        <div class="ml-2 flex items-center gap-1.5 text-gray-500">
          <.icon name="hero-server" class="w-4 h-4 text-gray-500" />
          <span class="font-medium">Server State</span>
        </div>
        <div class="mr-2 text-gray-500">
          Items: <span class="font-medium text-gray-700"><%= Enum.count(@items) %></span>
        </div>
      </div>
      <div class="mt-1 border p-2.5 rounded-2xl border-zinc-400 bg-zinc-50">
        <code class="text-xs text-zinc-800 bg-zinc-50">
          <%= if @items != [] do %>
            [<%= for item <- @items do %>
              <%= "%{id: #{item.id}, name: #{item.name}}" %>
            <% end %>]
          <% else %>
            []
          <% end %>
        </code>
      </div>

      <div class="flex justify-end">
        <.simple_form
          for={@form}
          class={@items == [] && "opacity-40"}
          container_class="mt-10 flex items-center gap-6"
          phx-change="change"
        >
          <.input type="checkbox" field={@form[:failures]} disabled={@items == []} label="Failures" />

          <.input
            type="checkbox"
            field={@form[:throttling]}
            disabled={@items == []}
            label="Throttling"
          />

          <.input
            type="checkbox"
            field={@form[:optimistic]}
            disabled={@items == []}
            label="Optimistic"
          />
        </.simple_form>
      </div>

      <div class="mt-4 flex flex-col items-center justify-center gap-6">
        <%= if @items != [] do %>
          <ol id="items-list" class="w-full flex flex-col gap-3">
            <%= for item <- @items do %>
              <li
                id={"fruit-#{item.id}"}
                class="flex items-center justify-between gap-4 p-2.5 rounded-2xl shadow-sm border border-gray-200 bg-gray-50/40"
                phx-hook="ListItem"
                phx-mounted={
                  JS.transition(
                    {"transition transform duration-400 ease-in", "opacity-0", "opacity-100"},
                    time: 400
                  )
                }
                phx-remove={
                  JS.hide(
                    transition:
                      {"transition transform duration-400 ease-out", "opacity-100",
                       "opacity-0 -translate-x-32"},
                    time: 400
                  )
                }
              >
                <div class="flex items-center gap-4">
                  <div class={[
                    "flex items-center justify-center w-12 h-12 rounded-xl",
                    item_class(item)
                  ]}>
                    <.icon name="hero-star-mini" class="w-6 h-6 text-white" />
                  </div>
                  <div>
                    <div class="text-lg font-medium"><%= item.name %></div>
                    <div class="text-sm text-gray-500"><%= item.description %></div>
                  </div>
                </div>
                <div class="flex items-center gap-4">
                  <button
                    class="group py-2 px-3 rounded-xl bg-transparent transition hover:bg-red-50/80"
                    phx-click={delete_item(item.id, @form[:optimistic].value)}
                  >
                    <.icon
                      name="hero-trash"
                      class="w-5 h-5 transition-colors text-zinc-700 group-hover:text-red-700"
                    />
                    <span class="sr-only">Delete</span>
                  </button>
                </div>
              </li>
            <% end %>
          </ol>
        <% else %>
          <div class="flex flex-col items-center">
            <span class="text-center text-gray-500">
              You hate all the fruits! :)
            </span>
            <.button phx-click="reset" class="mt-4">Restock!</.button>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(form: to_form(%{"optimistic" => true, "throttling" => true, "failures" => false}))
      |> assign(items: get_fruits())

    {:ok, socket}
  end

  @impl true
  def handle_event("change", params, socket) do
    socket = assign(socket, form: params_to_form(params))
    {:noreply, socket}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    throttling? = Map.get(socket.assigns.form.source, "throttling", false)
    failures? = Map.get(socket.assigns.form.source, "failures", false)

    if throttling?, do: POP.Helpers.slow_function(1000..2000)

    socket =
      if failures? do
        if :rand.uniform() > 0.4 do
          socket
          |> put_flash(:error, "Failed to delete item #{id}!")
          |> push_event("unhide", %{id: id, container: "flex"})
        else
          updated_items = delete_fruit(socket.assigns.items, id)
          assign(socket, items: updated_items)
        end
      else
        updated_items = delete_fruit(socket.assigns.items, id)
        assign(socket, items: updated_items)
      end

    {:noreply, socket}
  end

  def handle_event("reset", _payload, socket) do
    {:noreply, assign(socket, items: get_fruits())}
  end

  defp params_to_form(params) do
    params
    |> Enum.map(fn
      {k, v} when is_binary(v) -> {k, String.to_existing_atom(v)}
      item -> item
    end)
    |> Map.new()
    |> to_form()
  end

  defp delete_item(item_id, true) do
    %JS{}
    |> JS.exec("phx-remove", to: "#fruit-#{item_id}")
    |> JS.push("delete", value: %{"id" => item_id})
  end

  defp delete_item(item_id, false) do
    JS.push("delete", value: %{"id" => item_id})
  end

  defp get_fruits do
    [
      %{id: 1, name: "Strawberries", description: "Red fruit"},
      %{id: 2, name: "Bananas", description: "Yellow fruit"},
      %{id: 3, name: "Apples", description: "Green fruit"},
      %{id: 4, name: "Blueberries", description: "Blue fruit"},
      %{id: 5, name: "Grapes", description: "Purple fruit"}
    ]
  end

  defp delete_fruit(items, id) do
    Enum.reject(items, &(&1.id == id))
  end

  ## Helpers

  defp item_class(%{name: "Strawberries"}), do: "bg-red-200"
  defp item_class(%{name: "Bananas"}), do: "bg-amber-200"
  defp item_class(%{name: "Apples"}), do: "bg-emerald-200"
  defp item_class(%{name: "Blueberries"}), do: "bg-blue-200"
  defp item_class(%{name: "Grapes"}), do: "bg-violet-200"
  defp item_class(%{name: _}), do: "bg-gray-200"
end
