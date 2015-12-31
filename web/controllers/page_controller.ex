defmodule SpawnViewer.PageController do
  use SpawnViewer.Web, :controller

  def index(conn, _params) do
    render conn, "index.html", target_modules: Config.target_modules
  end

  def analyze(conn, %{"id" => id}) do
    records = SpawnViewer.run(id)
    items = Parser.parse(records)

    data = %{"cols" => [%{"type" => "string", "id" => "Position"},
                        %{"type" => "string", "id" => "Name"},
                        %{"type" => "date", "id" => "Start"},
                        %{"type" => "date", "id" => "End"}],
            "rows" => items,
            "p" => nil}

    json conn, %{"counts" => Parser.count_row(records), "data" => data}
  end

  def code(conn, %{"id" => id}) do
    code = SpawnViewer.get_code(id)
    text conn, code
  end
end
