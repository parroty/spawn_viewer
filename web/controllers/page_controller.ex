defmodule SpawnViewer.PageController do
  use Phoenix.Controller

  def index(conn, _params) do
    render conn, "index", target_modules: Config.target_modules
  end

  def analyze(conn, %{"id" => id}) do
    records = SpawnViewer.run(id)
    items = Parser.parse(records)

    data = [{"cols", [[type: "string", id: "Position"],
                      [type: "string", id: "Name"],
                      [type: "date", id: "Start"],
                      [type: "date", id: "End"]]},
            {"rows", items},
            {"p", nil}]

    json conn, [counts: Parser.count_row(records), data: data] |> JSEX.encode!
  end

  def code(conn, %{"id" => id}) do
    code = SpawnViewer.get_code(id)
    text conn, code
  end

  def not_found(conn, _params) do
    render conn, "not_found"
  end

  def error(conn, _params) do
    render conn, "error"
  end
end
